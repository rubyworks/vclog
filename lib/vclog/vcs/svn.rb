module VCLog

  class VCS

    # = SVN
    #
    # Raw SVN format:
    #
    #   ------------------------------------------------------------------------
    #   r34 | transami | 2006-08-02 22:10:11 -0400 (Wed, 02 Aug 2006) | 2 lines
    #
    #   change foo to work better
    #
    class SVN

      def initialize
      end

      ###
      def changelog
        @changelog ||= generate_changelog
      end

      ###
      def generate_changelog
        log = Changelog.new

        txt = `svn log`.strip

        com = txt.split(/^[-]+$/)

        com.each do |msg|
          msg = msg.strip

          next if msg.empty?

          idx = msg.index("\n")
          head = msg.slice!(0...idx)
          rev, who, date, cnt = *head.split('|')

          rev  = rev.strip
          who  = who.strip
          msg  = msg.strip

          date = Time.parse(date)

          log.change(date, who, rev, msg)
        end

        @changelog = log
      end

    end

  end

end

