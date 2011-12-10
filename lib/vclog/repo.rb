require 'confection'

require 'vclog/adapters'
require 'vclog/heuristics'
require 'vclog/history_file'

module VCLog

  #
  class Repo

    ## Remove some undeeded methods to make way for delegation to scm adapter.
    #%w{display}.each{ |name| undef_method(name) }
    #
    ## File glob used to find the vclog configuration directory.
    #CONFIG_GLOB = '{.,.config/,config/,task/,tasks/}vclog{,.rb}'

    # File glob used to find project root directory.
    ROOT_GLOB = '{.git/,.hg/,_darcs/,.svn/}'

    # Project's root directory.
    attr :root

    #
    attr :options

    # Default change level.
    # TODO: get from config file?
    attr :level

    # Use change points, instead of whole changes?
    attr :point

    #
    def initialize(root, options={})
      @root    = root || lookup_root
      @options = options

      #@config_directory = Dir[File.join(@root, CONFIG_GLOB)]

      @point   = options[:point]
      @level   = (options[:level] || 0).to_i

      vcs_type = read_vcs_type

      raise ArgumentError, "Not a recognized version control system." unless vcs_type

      @adapter = Adapters.const_get(vcs_type.capitalize).new(self)
    end

    # Returns instance of an Adapter subclass.
    def adapter
      @adapter
    end

    #
    #def config_directory
    #  @config_directory
    #end

    #
    def force?
      options[:force]
    end

    #
    def read_vcs_type
      dir = nil
      Dir.chdir(root) do
        dir = Dir.glob("{.git,.hg,.svn,_darcs}").first
      end
      dir[1..-1] if dir
    end

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

    # Load heuristics script.
    def heuristics
      @heuristics ||= Heuristics.new(&Confection[:vclog])
    end

    # Heurtistics script.
    #def heuristics_file
    #  @heuristics_file ||= Dir[File.join(root, CONFIG_GLOB)].first
    #end

    # Access to Repo's HISTORY file.
    def history_file
      @history_file ||= HistoryFile.new(options[:history_file] || root)
    end

    # Read history file and make a commit tag for any release not already
    # tagged. Unless the force option is set the user will be prompted for
    # each new tag.
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
    def changes
      @changes ||= (
        apply_heuristics(adapter.changes)
      )
    end

    #
    def change_points
      @change_points ||= (
         apply_heuristics(adapter.change_points)
      )
    end

    #
    def apply_heuristics(changes)
      changes.each do |change|
        change.apply_heuristics(heuristics)
      end
      changes.select do |change|
        change.level >= self.level
      end
    end

    #
    def changelog
      @changelog ||= ChangeLog.new(changes)
    end

    #
    def history
      @history ||= History.new(self)
    end

    #
    def report(options)
      formatter = Formatter.new(self)  #, options)
      formatter.report(options)
    end

    # TODO: allow config of these levels thresholds ?
    def bump
      max = history.releases[0].changes.map{ |c| c.level }.max
      if max > 1
        bump_part('major')
      elsif max >= 0
        bump_part('minor')
      else
        bump_part('patch')
      end
    end

    # Provides a bumped version number.
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

    # Delegate missing methods to SCM adapter.
    def method_missing(s, *a, &b)
      if adapter.respond_to?(s)
        adapter.send(s, *a, &b)
      else
        super(s,*a,&b)
      end
    end

   private

    # Ask yes/no question.
    def ask_yn(message)
      case ask(message)
      when 'y', 'Y', 'yes'
        true
      else
        false
      end
    end

    # Returns a String.
    def new_tag_message(label, tag)
      "#{label} / #{tag.date.strftime('%Y-%m-%d')}\n#{tag.message}"
    end

  end

end
