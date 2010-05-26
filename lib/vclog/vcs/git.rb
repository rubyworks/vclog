module VCLog

  require 'vclog/vcs'

  class VCS

    # = GIT Adapter
    #
    class GIT < VCS

      #def initialize
      #end

      #
      #def changelog
      #  @changelog ||= ChangeLog.new(changes)
      #end

      #
      #def history(opts={})
      #  @history ||= History.new(self, opts)
      #end

      # Collect changes.
      #
      def extract_changes
        list = []
        changelog = `git log`.strip
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
          list << [tag, date, who, msg]
        end
        list
      end

    end#class GIT

  end#class VCS

end#module VCLog

