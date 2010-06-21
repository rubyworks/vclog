module VCLog
module Adapters

  require 'time'
  require 'pathname'

  require 'vclog/formatter'
  require 'vclog/changelog'
  require 'vclog/history'
  require 'vclog/change'
  require 'vclog/tag'

  # TODO: Might we have a NO-VCS changelog based on
  #       LOG: entries in source files?

  # = Version Control System
  class Abstract

    # Root location.
    attr :root

    # Heuristics object.
    attr :heuristics

    # Minimu change level.
    attr :level

    #
    def initialize(config)
      @root       = config.root  # File.expand_path(config.root)
      @heuristics = config.heuristics
      @level      = config.level.to_i
    end

    #
    def tags
      @tags ||= extract_tags.map{ |t| Tag===t ? t : Tag.new(*t) }
    end

    #
    def changes
      @changes ||= (
        changes = []
        extract_changes.each do |c|
          raise "how did this happen?" if Change == c
          rev, date, who, msg = *c
          type, level, label = *heuristics.lookup(msg)
          next if level < self.level
          changes << Change.new(rev, date, who, msg, type, level, label)
        end
        changes
      )
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
    def history
      @history ||= History.new(self)
    end

    #
    def display(type, format, options)
      @options = options
      formatter = Formatter.new(self)
      formatter.display(type, format, options)
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

  private

    #
    def version_tag?(tag_name)
      /(v|\d)/i =~ tag_name
    end

=begin
    # Looks for a "[type]" indicator at the end of the commit message.
    # If that is not found, it looks at front of message for
    # "[type]" or "[type]:". Failing that it tries just "type:".
    #
    def split_type(note)
      note = note.strip
      if md = /\[(.*?)\]\Z/.match(note)
        t = md[1].strip.downcase
        n = note[0...(md.begin(0))]
      elsif md = /\A\[(.*?)\]\:?/.match(note)
        t = md[1].strip.downcase
        n = note[md.end(0)..-1]
      elsif md = /\A(\w+?)\:/.match(note)
        t = md[1].strip.downcase
        n = note[md.end(0)..-1]
      else
        n, t = note, nil
      end
      n.gsub!(/^\s*?\n/m,'') # remove blank lines
      return n, t
    end
=end

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

    # Find vclog config directory. This searches up from the current
    # working directory for the following paths (in order):
    #
    #   .vclog/
    #   .config/vclog/
    #    config/vclog/
    #
    def lookup_config
      conf = nil
      Dir.ascend(Dir.pwd) do |path|
        check = Dir['{.vclog/,.config/vclog/,config/vclog/}/'].first
        if check
          conf = path 
          break
        end
      end
      conf
    end

  public

    #
    def user
      ENV['USER']
    end

    #
    def email
      ENV['EMAIL']
    end

    #
    def repository
      nil
    end

    #
    def uuid
      nil
    end

  end

end
end

