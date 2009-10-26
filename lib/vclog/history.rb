module VCLog

  require 'vclog/facets'
  require 'vclog/changelog'
  require 'vclog/tag'
  require 'vclog/release'

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

    attr :vcs

    attr_accessor :marker

    attr_accessor :title

    # Current working version.
    attr_accessor :version

    attr_accessor :verbose # ???

    #
    def initialize(vcs, opts={})
      @vcs = vcs
      @marker    = opts[:marker]  || "#"
      @title     = opts[:title]   || "RELEASE HISTORY"
      @version   = opts[:version]
      @verbose   = opts[:verbose]
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

        tags = tags()

        ver  = vcs.bump(version)
        time = ::Time.now
        user = ENV['USER']  # TODO: get user name from vcs

        tags << Tag.new(ver, time, user, "FIXME")

        # TODO: Do we need to add a Time.now tag?
        # add current verion to release list (if given)
        #previous_version = tags[0].name
        #if current_version < previous_version  # TODO: need to use natural comparision
        #  raise ArgumentError, "Release version is less than previous version (#{previous_version})."
        #end
        #rels << [current_version, current_release || Time.now]
        #rels = rels.uniq      # only uniq releases

        # sort by release date
        tags = tags.sort{ |a,b| a.date <=> b.date }

        # organize into deltas
        deltas, last = [], nil
        tags.each do |tag|
          deltas << [last, tag]
          last = tag
        end

        # gather changes for each delta and build log
        deltas.each do |gt, lt|
          if gt
            gt_vers, gt_date = gt.name, gt.date
            lt_vers, lt_date = lt.name, lt.date
            #gt_date = Time.parse(gt_date) unless Time===gt_date
            #lt_date = Time.parse(lt_date) unless Time===lt_date
            log = changelog.after(gt_date).before(lt_date)
          else
            lt_vers, lt_date = lt.name, lt.date
            #lt_date = Time.parse(lt_date) unless Time===lt_date
            log = changelog.before(lt_date)
          end

          rel << Release.new(lt, log.changes)
        end
        rel
      )
    end

    #
    def to_s
      to_markdown #gnu
    end

    # TODO
    def to_gnu
    end

    # Translate history into an XML document.
    def to_xml(xsl=nil)
      require 'rexml/document'
      xml = REXML::Document.new('<history></history>')
      #xml << REXML::XMLDecl.default
      root = xml.root
      releases.each do |release|
        rel = root.add_element('release')
        tel = rel.add_element('tag')
        tel.add_element('name').add_text(release.tag.name)
        tel.add_element('date').add_text(release.tag.date.to_s)
        tel.add_element('author').add_text(release.tag.author)
        tel.add_element('message').add_text(release.tag.message)
        cel = rel.add_element('changes')
        release.changes.sort{|a,b| b.date <=> a.date}.each do |entry|
          el = cel.add_element('entry')
          el.add_element('date').add_text(entry.date.to_s)
          el.add_element('author').add_text(entry.author)
          el.add_element('type').add_text(entry.type)
          el.add_element('revision').add_text(entry.revision)
          el.add_element('message').add_text(entry.message)
        end
      end
      out = String.new
      fmt = REXML::Formatters::Pretty.new
      fmt.compact = true
      fmt.write(xml, out)
      #
      txt  = %[<?xml version="1.0"?>\n]
      txt += %[<?xml-stylesheet href="#{xsl}" type="text/xsl" ?>\n] if xsl
      txt += out
      txt
    end

    # Translate history into a HTML document.
    #
    # TODO: Need to add some headers.
    #
    def to_html(css=nil)
      require 'rexml/document'
      xml = REXML::Document.new('<div class="history"></div>')
      #xml << REXML::XMLDecl.default
      root = xml.root
      releases.each do |release|
        rel = root.add_element('div')
        rel.add_attribute('class', 'release')
        tel = rel.add_element('div')
        tel.add_attribute('class', 'tag')
        tel.add_element('div').add_text(release.tag.name).add_attribute('class', 'name')
        tel.add_element('div').add_text(release.tag.date.to_s).add_attribute('class', 'date')
        tel.add_element('div').add_text(release.tag.author).add_attribute('class', 'author')
        tel.add_element('div').add_text(release.tag.message).add_attribute('class', 'message')
        cel = rel.add_element('ul')
        cel.add_attribute('class', 'changes')
        release.changes.sort{|a,b| b.date <=> a.date}.each do |entry|
          el = cel.add_element('li')
          el.add_attribute('class', 'entry')
          el.add_element('div').add_text(entry.date.to_s).add_attribute('class', 'date')
          el.add_element('div').add_text(entry.author).add_attribute('class', 'author')
          el.add_element('div').add_text(entry.type).add_attribute('class', 'type')
          el.add_element('div').add_text(entry.revision).add_attribute('class', 'revision')
          el.add_element('div').add_text(entry.message).add_attribute('class', 'message')
        end
      end
      out = String.new
      fmt = REXML::Formatters::Pretty.new
      fmt.compact = true
      fmt.write(xml, out)
      #
      x = []
      x << %[<html>]
      x << %[<head>]
      x << %[  <title>ChangeLog</title>]
      x << %[  <style>]
      x << %[    body{font-family: sans-serif;}]
      x << %[    #changelog{width:800px;margin:0 auto;}]
      x << %[    li{padding: 10px;}]
      x << %[    .date{font-weight: bold; color: gray; float: left; padding: 0 5px;}]
      x << %[    .author{color: red;}]
      x << %[    .message{padding: 5 0; font-weight: bold;}]
      x << %[    .revison{font-size: 0.8em;}]
      x << %[  </style>]
      x << %[  <link rel="stylesheet" href="#{css}" type="text/css">] if css
      x << %[</head>]
      x << %[<body>]
      x << out
      x << %[</body>]
      x << %[</html>]
      x.join("\n")
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

    # Translate history into a Markdown formatted document.
    def to_markdown(rev=false)
      to_markup('#', rev)
    end

    # Translate history into a RDoc formatted document.
    def to_rdoc(rev=false)
      to_markup('=', rev)
    end

    #
    def to_markup(marker, rev=false)
      entries = []
      releases.each do |release|
        tag     = release.tag
        changes = release.changes
        change_text = to_markup_changes(changes, rev)
        unless change_text.strip.empty?
          if verbose
            entries << "#{marker*2} #{tag.name} / #{tag.date.strftime('%Y-%m-%d')}\n\n#{tag.message}\n\nChanges:\n\n#{change_text}"
          else
            entries << "#{marker*2} #{tag.name} / #{tag.date.strftime('%Y-%m-%d')}\n\n#{change_text}"
          end
        end
      end
      # reverse entries order and make into document
      marker + " #{title}\n\n" +  entries.reverse.join("\n")
    end

  private

    #
    def to_markup_changes(changes, rev=false)
      groups = changes.group_by{ |e| e.type_number }
      string = ""
      5.times do |n|
        entries = groups[n]
        next if !entries
        next if entries.empty?
        string << "* #{entries.size} #{entries[0].type_phrase}\n\n"
        entries.sort!{|a,b| a.date <=> b.date }
        entries.each do |entry|
          #string << "== #{date}  #{who}\n\n"  # no email :(
          if rev
            text = "#{entry.message} (##{entry.revison})"
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

  end

end

