module VCLog

  class VCS

    ### = GIT 
    ###
    class GIT

      def initialize

      end

      #
      def changelog
        @changelog ||= generate_changelog
      end

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

    end

  end

end

