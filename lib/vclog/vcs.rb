module VCLog

  require 'time'
  require 'vclog/changelog'
  require 'vclog/vcs/svn'
  require 'vclog/vcs/git'
  #require 'vclog/vcs/hg'
  #require 'vclog/vcs/darcs'

  # TODO: Might we have a NO-VCS changelog based on
  #       LOG: entries in source files?

  # = Version Control System
  class VCS

    attr :type

    def initialize(root=nil)
      @root = root || Dir.pwd
      @type = read_type
      raise ArgumentError, "Not a recognized version control system." unless @type
    end

    def read_type
      dir = nil
      Dir.chdir(@root) do
        dir = Dir.glob("{.svn,.git,.hg,_darcs}").first
      end
      dir[1..-1] if dir
    end

    def delegate
      @delegate ||= VCS.const_get(type.upcase).new
    end

    #
    def method_missing(s, *a, &b)
      delegate.send(s, *a, &b)
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

end

