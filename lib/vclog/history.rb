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
  # But we can also extract the release information from a
  # release history file, if provided. And it's release
  # information should take precidence. ???
  #
  #
  # TODO: Extract output formating from delta parser.
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
      @title   = opts[:title] || "RELEASE HISTORY"
      @extra   = opts[:extra]
      @version = opts[:version]
    end

    # Tag list from version control system.
    def tags
      @tags ||= vcs.tags
    end

    # Change list from version control system.

    def changes
      @changes ||= vcs.changes
    end

    # Changelog object

    def changelog
      @changlog ||= vcs.changelog #ChangeLog.new(changes)
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

        # gather changes for each delta and build log
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
      @groups ||= changes.group_by{ |e| e.type_number }
    end

    #
    def to_h
      releases.map{ |rel| rel.to_h }
    end



    # Same as to_gnu.

    #def to_s(rev=false)
    #  to_gnu(rev)
    #end

=begin
    # TODO: What would GNU history look like?

    def to_gnu(rev=false)
      to_markdown(rev)
    end

    # Translate history into a YAML document.

    def to_yaml(*args)
      require 'yaml'
      releases.to_yaml(*args)
    end

    # Translate history into a JSON document.

    def to_json
      require 'json'
      releases.to_json
    end
=end

=begin
    # Translate history into a XML document.

    def to_xml(xsl=nil)
      tmp = File.read(File.join(DIR, 'templates', 'history.xml'))
      erb = ERB.new(tmp)
      erb.result(binding)
    end

    # Translate history into a HTML document.

    def to_html(css=nil)
      tmp = File.read(File.join(DIR, 'templates', 'history.html'))
      erb = ERB.new(tmp)
      erb.result(binding)
    end

    # Translate history into a RDoc document.

    def to_rdoc(rev=false)
      tmp = File.read(File.join(DIR, 'templates', 'history.rdoc'))
      erb = ERB.new(tmp)
      erb.result(binding)
    end

    # Translate history into a Markdown formatted document.

    def to_markdown(rev=false)
      tmp = File.read(File.join(DIR, 'templates', 'history.markdown'))
      erb = ERB.new(tmp)
      erb.result(binding)
    end
=end

=begin
    #
    def to_markup(marker, rev=false)
      entries = []
      releases.each do |release|
        tag     = release.tag
        changes = release.changes
        change_text = to_markup_changes(changes, rev)
        unless change_text.strip.empty?
          if extra
            entries << "#{marker*2} #{tag.name} / #{tag.date.strftime('%Y-%m-%d')}\n\n#{tag.message}\n\nChanges:\n\n#{change_text}"
          else
            entries << "#{marker*2} #{tag.name} / #{tag.date.strftime('%Y-%m-%d')}\n\n#{change_text}"
          end
        end
      end
      # reverse entries order and make into document
      marker + " #{title}\n\n" +  entries.reverse.join("\n")
    end
=end

  private

=begin
    #
    def to_markup_changes(changes, rev=false)
      groups = changes.group_by{ |e| e.type_number }
      string = ""
      groups.keys.sort.each do |n|
        entries = groups[n]
        next if !entries
        next if entries.empty?
        string << "* #{entries.size} #{entries[0].type_phrase}\n\n"
        entries.sort!{|a,b| a.date <=> b.date }
        entries.each do |entry|
          #string << "== #{date}  #{who}\n\n"  # no email :(
          if rev
            text = "#{entry.message} (##{entry.revision})"
          else
            text = "#{entry.message}"
          end
          text = text.tabto(6)
          text[4] = '*'
          #entry = entry.join(' ').tabto(6)
          #entry[4] = '*'
          string << text
          string << "\n"
        end
        string << "\n"
      end
      string
    end
=end


=begin
    # Extract release tags from a release file.
    #
    # TODO: need to extract message (?)
    #
    def releases_from_file(file)
      return [] unless file
      clog = File.read(file)
      tags = clog.scan(/^(==|##)(.*?)$/)
      rels = tags.collect do |t|
        parse_version_tag(t[1])
      end
      @marker = tags[0][0]
      return rels
    end

    #
    def parse_version_tag(tag)
      version, date = *tag.split('/')
      version, date = version.strip, date.strip
      return version, date
    end
=end

=begin
  private

    #
    def h(input)
       result = input.to_s.dup
       result.gsub!("&", "&amp;")
       result.gsub!("<", "&lt;")
       result.gsub!(">", "&gt;")
       result.gsub!("'", "&apos;")
       #result.gsub!("@", "&at;")
       result.gsub!("\"", "&quot;")
       return result
    end
=end

  end

end

