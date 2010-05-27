require 'vclog/adapters/abstract'

module VCLog
module Adapters

  # = SVN
  #
  # NOTE: Unfortunately the SVN adapater is very slow. If hits the server
  # every time the 'svn log' command is issued. When generating a History
  # that's one hit for every tag. If anyone knows a better way please have
  # at it --maybe future versions of SVN will improve the situation.
  #
  class Svn < Abstract

    def initialize(root)
      begin
        require 'xmlsimple'
      rescue LoadError
        "VCLog requires xmlsimple for SVN support"
      end
      super(root)
    end

    #
    def extract_changes
      log = []

      xml = `svn log --xml`.strip

      commits = XmlSimple.xml_in(xml, {'KeyAttr' => 'rev'})
      commits = commits['logentry']

      commits.each do |com|
        rev  = com["revision"]
        msg  = [com["msg"]].flatten.compact.join('').strip
        who  = [com["author"]].flatten.compact.join('').strip
        date = [com["date"]].flatten.compact.join('').strip

        next if msg.empty?
        next if msg == "*** empty log message ***"

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

        # using yaml, but maybe use xml instead?
        info = `svn info #{dir}`
        info = YAML.load(info)
        md = /(\d.*)$/.match(info['Path'])
        name = md ? md[1] : path
        date = info['Last Changed Date']
        who  = info['Last Changed Author']
        rev  = info['Revision']

        # get last commit
        xml = `svn log -l1 --xml #{dir}`
        commits = XmlSimple.xml_in(xml, {'KeyAttr' => 'rev'})
        commit = commits['logentry'].first

        msg  = [commit["msg"]].flatten.compact.join('').strip
        date = [commit["date"]].flatten.compact.join('').strip

        list << [name, rev, date, who, msg]
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

  end

end
end

