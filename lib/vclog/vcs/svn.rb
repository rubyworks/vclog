module VCLog

  class VCS

    # = SVN
    #
    # SVN's raw log format:
    #
    #   ------------------------------------------------------------------------
    #   r34 | transami | 2006-08-02 22:10:11 -0400 (Wed, 02 Aug 2006) | 2 lines
    #
    #   change foo to work better
    #
    class SVN < VCS

      #
      def extract_changes
        log = []

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

          msg, type = *split_type(msg)

          log << [rev, date, who, msg, type]
        end

        log
      end

      #
      def extract_tags
        list = []
        tagdir = tag_directory

        if tagdir
          tags = Dir.entries(tagdir).select{ |e| e.index('.') != 0 && e =~ /\d(.*)$/ }
        else
          tags = []
        end

        tags.each do |path|
          dir = File.join(tagdir, path)

          info = `svn info #{dir}`
          info = YAML.load(info)
          md = /(\d.*)$/.match(info['Path'])
          name = md ? md[1] : path
          date = info['Last Changed Date']
          who  = info['Last Changed Author']
          rev  = info['Revision']

          commit = `svn log -r BASE #{dir}`
          msg  = commit.lines.to_a[2..-2].join("\n").strip

          list << [name, date, who, msg]
        end
        list
      end

      # This isn't perfect, but is there really anyway for it to be?
      # It ascends up the current directory tree looking for the 
      # best candidate for a tags directory.
      def tag_directory
        fnd = nil
        dir = root
        while dir != '/' do
          entries = Dir.entries(dir)
          if entries.include?('.svn')
            if entries.include?('tags')
              break(fnd = File.join(dir, 'tags'))
            else
              entries = entries.reject{ |e| e.index('.') == 0 }
              entries = entries.reject{ |e| e !~ /\d$/ }
              break(fnd = dir) unless entries.empty?
            end
          else
            break(fnd=nil)
          end
          dir = File.dirname(dir)
        end
        fnd
      end

    end#class SVN

  end#class VCS

end#module VCLog

