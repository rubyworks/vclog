module VCLog

  require 'time'
  require 'vclog/changelog'
  require 'vclog/history'
  require 'vclog/change'
  require 'vclog/tag'

  # TODO: Might we have a NO-VCS changelog based on
  #       LOG: entries in source files?

  # = Version Control System
  class VCS

    def self.factory(root=nil)
      root = root || Dir.pwd
      type = read_type(root)
      raise ArgumentError, "Not a recognized version control system." unless type
      VCS.const_get(type.upcase).new(root)
    end

    def self.read_type(root)
      dir = nil
      Dir.chdir(root) do
        dir = Dir.glob("{.svn,.git,.hg,_darcs}").first
      end
      dir[1..-1] if dir
    end

    attr :root

    #
    def initialize(root)
      @root = File.expand_path(root)
    end

    def tags
      @tags ||= extract_tags.map{ |t| Tag===t ? t : Tag.new(*t) }
    end

    def changes
      @changes ||= extract_changes.map{ |c| Change===c ? c : Change.new(*c) }
    end

    #
    def extract_tags
      raise "Not Implemented"
    end

    #
    def extract_changes
      raise "Not Implemented"
    end

    #
    def changelog
      ChangeLog.new(changes)
    end

    #
    def history(opts={})
      @history ||= History.new(self, opts)
    end

    # Provides a bumped version number.
    def bump(part=nil)
      return part unless ['major', 'minor', 'patch', ''].include?(part.to_s)

      if tags.last
        v = tags.last.name   # TODO: ensure the latest version
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

  private

    # Looks for a "[type]" indicator at the end of the message.
    def split_type(note)
      note = note.strip
      if md = /\A.*?\[(.*?)\]\s*$/.match(note)
        t = md[1].strip.downcase
        n = note.sub(/\[#{md[1]}\]\s*$/, "")
      else
        n, t = note, nil
      end
      n.gsub!(/^\s*?\n/m,'') # remove blank lines
      return n, t
    end

=begin
    # Write the ChangeLog to file.

    def write_changelog( log, file )
      if File.directory?(file)
        file = File.join( file, DEFAULT_CHANGELOG_FILE )
      end
      File.open(file,'w+'){ |f| f << log }
      puts "Change log written to #{file}."
    end

    # Write version stamp to file.

    def write_version( stamp, file )
      if File.directory?(file)
        file = File.join( file, DEFAULT_VERSION_FILE )
      end
      File.open(file,'w'){ |f| f << stamp }
      puts "#{file} saved."
    end

    # Format the version stamp.

    def format_version_stamp( version, status=nil, date=nil )
      if date.respond_to?(:strftime)
        date = date.strftime("%Y-%m-%d")
      else
        date = Time.now.strftime("%Y-%m-%d")
      end
      status = nil if status.to_s.strip.empty?
      stamp = []
      stamp << version
      stamp << status if status
      stamp << "(#{date})"
      stamp.join(' ')
    end
=end

  end

  require 'vclog/vcs/svn'
  require 'vclog/vcs/git'
  #require 'vclog/vcs/hg'
  #require 'vclog/vcs/darcs'

end

