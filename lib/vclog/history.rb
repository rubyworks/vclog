module VCLog

  require 'vclog/facets'
  require 'vclog/changelog'
  require 'vclog/tag'
  require 'vclog/release'
  require 'erb'

  # = Release History Class
  #
  # A Release History is very similar to a ChangeLog.
  # It differs in that it is divided into releases with
  # version, release date and release note.
  #
  # The release version, date and release note can be
  # descerened from the underlying SCM by identifying
  # the hard tag commits.
  #
  # TODO: Extract output formating from delta parser. Later---Huh?
  #
  class History

    # Location of this file in the file system.
    DIR = File.dirname(__FILE__)

    attr :vcs

    # Alternate title.
    attr_accessor :title

    # Current working version.
    attr_accessor :version

    # Provide extra information.
    attr_accessor :extra

    #
    def initialize(vcs, opts={})
      @vcs     = vcs

      opts = OpenStruct.new(opts) if Hash === opts

      #@title   = opts.title || "RELEASE HISTORY"
      #@extra   = opts.extra
      #@version = opts.version

      @level =  opts.level || 0
    end

    # Tag list from version control system.
    def tags
      @tags ||= vcs.tags
    end

    # Changelog object
    def changelog
      @changlog ||= vcs.changelog #ChangeLog.new(changes)
    end

    # Change list from version control system filter for level setting.
    def changes
      @changes ||= (
        vcs.changes.select{ |c| c.level >= @level }
      )
    end

    #
    def releases
      @releases ||= (
        rel = []

        tags = self.tags

        ver  = vcs.bump(version)
        user = vcs.user
        time = ::Time.now

        tags << Tag.new(ver, 'current', time, user, "Current Development")

        # TODO: Do we need to add a Time.now tag?
        # add current verion to release list (if given)
        #previous_version = tags[0].name
        #if current_version < previous_version  # TODO: need to use natural comparision
        #  raise ArgumentError, "Release version is less than previous version (#{previous_version})."
        #end
        #rels << [current_version, current_release || Time.now]
        #rels = rels.uniq      # only uniq releases

        # sort by release date
        #tags = tags.sort{ |a,b| b.name <=> a.name }
        tags = tags.sort{ |a,b| b.date <=> a.date }

        # organize into deltas
        delta = {}
        last  = nil
        tags.sort.each do |tag|
          delta[tag] = [last, tag.date]
          last = tag.date
        end

        # gather changes for each delta
        delta.each do |tag, (ended, started)|
          if ended
            set = changes.select{ |c| c.date < ended && c.date > started }
            #gt_vers, gt_date = gt.name, gt.date
            #lt_vers, lt_date = lt.name, lt.date
            #gt_date = Time.parse(gt_date) unless Time===gt_date
            #lt_date = Time.parse(lt_date) unless Time===lt_date
            #log = changelog.after(gt).before(lt)
          else
            #lt_vers, lt_date = lt.name, lt.date
            #lt_date = Time.parse(lt_date) unless Time===lt_date
            #log = changelog.before(lt_date)
            set = changes.select{ |c| c.date > started }
          end

          rel << Release.new(tag, set)
        end
        rel
      )
    end

    # Group +changes+ by tag type.
    def groups(changes)
      @groups ||= changes.group_by{ |e| e.type }
    end

    #
    def to_h
      releases.map{ |rel| rel.to_h }
    end

  end

end

