module VCLog

  require 'vclog/changelog'
  require 'vclog/history'
  require 'vclog/tag'

  class VCS

    ### = GIT 
    ###
    class GIT

      def initialize
      end

      #
      def changelog
        @changelog ||= ChangeLog.new(changes)
      end

      #
      def history(opts={})
        @history ||= History.new(self, opts)
      end

      #
      #
      def changes
        @changes ||= extract_changes
      end

      #
      def tags
        @tags ||= extract_tags
      end

=begin
      #
      #
      def generate_changelog
        log = Changelog.new

        changelog ||= `git-log`.strip

        changes = changelog.split(/^commit/m)

        changes.shift # throw the first (empty) entry away

        changes.each do |text|
          date, who, rev, msg = nil, nil, nil, []
          text.each_line do |line|
            unless rev
              rev = line.strip
              next
            end
            if md = /^Author:(.*?)$/.match(line)
              who = md[1]
            elsif md = /^Date:(.*?)$/m.match(line)
              date = Time.parse(md[1])
            else
              msg << line.strip
            end
          end
          log.change(date, who, rev, msg.join("\n"))
        end

        @changelog = log
      end
=end

      # Collect changes.
      #
      def extract_changes
        list = []
        changelog = `git-log`.strip
        changes = changelog.split(/^commit/m)
        changes.shift # throw the first (empty) entry away
        changes.each do |text|
          date, who, rev, msg = nil, nil, nil, []
          text.each_line do |line|
            unless rev
              rev = line.strip
              next
            end
            if md = /^Author:(.*?)$/.match(line)
              who = md[1]
            elsif md = /^Date:(.*?)$/m.match(line)
              date = Time.parse(md[1])
            else
              msg << line.strip
            end
          end
          msg = msg.join("\n")
          msg, type = *split_type(msg)
          list << [rev, date, who, msg, type]
        end
        list
      end

      # Collect tags.
      #
      # `git show 1.0` produces:
      #
      #   tag 1.0
      #   Tagger: 7rans <transfire@gmail.com>
      #   Date:   Sun Oct 25 09:27:58 2009 -0400
      #
      #   version 1.0
      #   commit
      #   ...
      #
      def extract_tags
        list = []
        tags = `git tag -l`
        tags.split(/\s+/).each do |tag|
          info = `git show #{tag}`
          md = /\Atag(.*?)\n(.*?)^commit/m.match(info)
          who, date, *msg = *md[2].split(/\n/)
          who  = who.split(':')[1].strip
          date = date[date.index(':')+1..-1].strip
          msg  = msg.join("\n")
          list << Tag.new(tag, date, who, msg)
        end
        list
      end

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

    end

  end

end

