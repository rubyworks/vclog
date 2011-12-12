require 'confection'

require 'vclog/core_ext'
require 'vclog/adapters'
require 'vclog/heuristics'
require 'vclog/history_file'
require 'vclog/changelog'
require 'vclog/tag'
require 'vclog/release'
require 'vclog/report'

module VCLog

  #
  class Repo

    #
    # File glob used to find project root directory.
    #
    ROOT_GLOB = '{.git/,.hg/,_darcs/,.svn/}'

    #
    # Project's root directory.
    #
    attr :root

    #
    # Options hash.
    #
    attr :options

    #
    # Setup new Repo instance.
    #
    def initialize(root, options={})
      @root    = root || lookup_root
      @options = options

      vcs_type = read_vcs_type

      raise ArgumentError, "Not a recognized version control system." unless vcs_type

      @adapter = Adapters.const_get(vcs_type.capitalize).new(self)
    end

    #
    # Returns instance of an Adapter subclass.
    #
    def adapter
      @adapter
    end

    #
    # Check force option.
    #
    def force?
      options[:force]
    end

    #
    #
    #
    def read_vcs_type
      dir = nil
      Dir.chdir(root) do
        dir = Dir.glob("{.git,.hg,.svn,_darcs}").first
      end
      dir[1..-1] if dir
    end

    #
    # Find project root. This searches up from the current working
    # directory for a Confection configuration file or source control 
    # manager directory.
    #
    #   .co
    #   .git/
    #   .hg/
    #   .svn/
    #   _darcs/
    #
    # If all else fails the current directory is returned.
    #
    def lookup_root
      root = nil
      Dir.ascend(Dir.pwd) do |path|
        check = Dir[ROOT_GLOB].first
        if check
          root = path 
          break
        end
      end
      root || Dir.pwd
    end

    #
    # Load heuristics script.
    #
    def heuristics
      @heuristics ||= Heuristics.new(&Confection[:vclog])
    end

    #
    # Access to Repo's HISTORY file.
    #
    def history_file
      @history_file ||= HistoryFile.new(options[:history_file] || root)
    end

    #
    # Read history file and make a commit tag for any release not already
    # tagged. Unless the force option is set the user will be prompted for
    # each new tag.
    #
    def autotag(prefix=nil)
      history_file.tags.each do |tag|
        label = "#{prefix}#{tag.name}"
        if not adapter.tag?(label)
          chg = adapter.change_by_date(tag.date)
          if chg
            if force? or ask_yn(new_tag_message(label, tag) + "\nCreate tag? [yN] ")
              adapter.tag(chg.rev, label, tag.date, tag.message)
            end
          else
            puts "No commit found for #{label} #{tag.date.strftime('%Y-%m-%d')}."
          end
        end
      end
    end

    #
    # List of all changes.
    #
    def changes
      @changes ||= apply_heuristics(adapter.changes)
    end

    #
    # List of all change points.
    #
    def change_points
      @change_points ||= apply_heuristics(adapter.change_points)
    end

    #
    # Apply heuristics to changes.
    #
    def apply_heuristics(changes)
      changes.each do |change|
        change.apply_heuristics(heuristics)
      end
    end

    #
    # Collect releases for the given set of +changes+.
    #
    # Releases are groups of changes segregated by tags. The release version,
    # release date and release note are defined by hard tag commits.
    #
    # @param [Array<Change>] changes
    #   List of Change objects.
    #
    # @return [Array<Release>]
    #   List of Release objects.
    #
    def releases(changes)
      rel  = []
      tags = self.tags.dup

      #ver  = repo.bump(version)

      name = options[:version] || 'HEAD'
      user = adapter.user
      date = ::Time.now + (3600 * 24) # one day ahead

      change = Change.new(:id=>'HEAD', :date=>date, :who=>user)

      tags << Tag.new(:name=>name, :date=>date, :who=>user, :msg=>"Current Development", :commit=>change)

      # TODO: Do we need to add a Time.now tag?
      # add current verion to release list (if given)
      #previous_version = tags[0].name
      #if current_version < previous_version  # TODO: need to use natural comparision
      #  raise ArgumentError, "Release version is less than previous version (#{previous_version})."
      #end

      # sort by release date
      tags = tags.sort{ |a,b| a.date <=> b.date }

      # organize into deltas
      delta = []
      last  = nil
      tags.each do |tag|
        delta << [tag, [last, tag.commit.date]]
        last = tag.commit.date
      end

      # gather changes for each delta
      delta.each do |tag, (started, ended)|
        if started
          set = changes.select{ |c| c.date >= started && c.date < ended  }
          #gt_vers, gt_date = gt.name, gt.date
          #lt_vers, lt_date = lt.name, lt.date
          #gt_date = Time.parse(gt_date) unless Time===gt_date
          #lt_date = Time.parse(lt_date) unless Time===lt_date
          #log = changelog.after(gt).before(lt)
        else
          #lt_vers, lt_date = lt.name, lt.date
          #lt_date = Time.parse(lt_date) unless Time===lt_date
          #log = changelog.before(lt_date)
          set = changes.select{ |c| c.date < ended }
        end
        rel << Release.new(tag, set)
      end
      rel.sort
    end

    #
    # Print a report with given options. 
    #
    def report(options)
      report = Report.new(self, options)
      report.print
    end

    #
    # Make an educated guess as to the next version number based on
    # changes made since previous release.
    #
    # @return [String] version number
    #
    # @todo Allow configuration of version bump thresholds
    #
    def bump
      last_release = releases(changes).first
      max = last_release.changes.map{ |c| c.level }.max
      if max > 1
        bump_part('major')
      elsif max >= 0
        bump_part('minor')
      else
        bump_part('patch')
      end
    end

    #
    # Provides a bumped version number.
    #
    def bump_part(part=nil)
      raise "bad version part - #{part}" unless ['major', 'minor', 'patch', 'build', ''].include?(part.to_s)

      if tags.last
        v = tags[-1].name # TODO: ensure the latest version
        v = tags[-2].name if v == 'HEAD'
      else
        v = '0.0.0'
      end

      v = v.split(/\W/)    # TODO: preserve split chars

      case part.to_s
      when 'major'
        v[0] = v[0].succ
        (1..(v.size-1)).each{ |i| v[i] = '0' }
        v.join('.')
      when 'minor'
        v[1] = '0' unless v[1]
        v[1] = v[1].succ
        (2..(v.size-1)).each{ |i| v[i] = '0' }
        v.join('.')
      when 'patch'
        v[1] = '0' unless v[1]
        v[2] = '0' unless v[2]
        v[2] = v[2].succ
        (3..(v.size-1)).each{ |i| v[i] = '0' }
        v.join('.')
      else
        v[-1] = '0' unless v[-1]
        v[-1] = v[-1].succ
        v.join('.')
      end
    end

    #
    # Delegate missing methods to SCM adapter.
    #
    def method_missing(s, *a, &b)
      if adapter.respond_to?(s)
        adapter.send(s, *a, &b)
      else
        super(s,*a,&b)
      end
    end

  private

    #
    # Ask yes/no question.
    #
    def ask_yn(message)
      case ask(message)
      when 'y', 'Y', 'yes'
        true
      else
        false
      end
    end

    #
    # Returns a String.
    #
    def new_tag_message(label, tag)
      "#{label} / #{tag.date.strftime('%Y-%m-%d')}\n#{tag.message}"
    end

  end

end
