require 'vclog/heuristics'
#require 'vclog/rc'

module VCLog

  # Get/set master configruation(s).
  def self.configure(&block)
    @config ||= []
    @config << block if block
    @config
  end

  # Encapsulates configuration settings for running vclog.
  #
  # We recommend putting vclog configuration in a project's `etc/vclog.rb`
  # file. For Rails projects, however, `config/vclog.rb` can be used. If
  # usig a subdirectory is not suitable to a project then simply using
  # the more traditional `.vclog` file works too.
  #
  class Config

    # File glob for identifying the project's root directory.
    #
    # NOTE: SVN support is limited to repos with a trunk directory.
    ROOT_GLOB = "{.git,.hg,_darcs,.svn/trunk}"

    #
    # Default vclog config file glob looks for these possible matches:
    #
    # * vclog.rb
    # * etc/vclog.rb
    # * config/vclog.rb
    #
    # The configuration file can also be a hidden dot file if preferred:
    #
    # * .vclog
    # * .etc/vclog.rb
    # * .config/vclog.rb
    #
    # Root files have precedence over files in subdirectories, and the `.rb`
    # file extension is optional in all cases.
    #
    FILE_GLOBS = [ '{,.}vclog{,.rb}', '{.,}{etc/,config/}vclog{,.rb}' ]

    #
    #
    #
    def initialize(options={})
      @root    = options[:root]  || lookup_root
      @level   = options[:level] || 0
      @force   = options[:force] || false
      @version = options[:version]
    end

    #
    # Project's root directory.
    #
    attr :root

    #
    # Default change level.
    #
    def level
      heuristics.level
    end

    #
    # Force mode active?
    #
    def force?
      @force
    end

    #
    # Indicates the version of HEAD.
    #
    def version
      @version
    end

    #
    # Load heuristics.
    #
    def heuristics
      @heuristics ||= (
        if file
          Heuristics.load(file)
        else
          h = Heuristics.new
          if config = VCLog.configure
            config.each{ |c| c.call(h) }
          end
          h
        end
      )
    end

    #
    # Which version control system?
    #
    def vcs_type
      @vcs_type ||= (
        dir = nil
        Dir.chdir(root) do
          dir = Dir.glob("{.git,.hg,.svn,_darcs}").first
        end
        dir[1..-1] if dir
      )
    end

    #
    # The vclog config file.
    #
    def file
      DEFAULT_GLOBS.find{ |g| Dir.glob(g).first }
    end

    #
    # Find project root. This searches up from the current working
    # directory for a source control manager directory.
    #
    # * `.git/`
    # * `.hg/`
    # * `_darcs/`
    # * `.svn/trunk`
    #
    # If all else fails the current directory is returned.
    #
    def lookup_root
      root = nil
      Dir.ascend(Dir.pwd) do |path|
        check = Dir[ROOT_GLOB].first
        if check
          root = path 
          break
        end
      end
      root || Dir.pwd
    end

  end

end
