require 'vclog/heuristics'
require 'vclog/rc'

module VCLog

  # Get/set master configruation(s).
  def self.configure(&block)
    @config ||= []
    @config << block if block
    @config
  end

  # Encapsulates configuration settings for running vclog.
  #
  class Config

    #
    # Default vclog config file glob looks for these possible matches in order:
    #
    # * .vclog
    # * .config/vclog
    # * config/vclog
    #
    # File may have optional `.rb` extension.
    #
    DEFAULT_GLOB = '{.,.config/,config/}vclog{,.rb}'

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
          if config = VCLog.configure
            proc = Proc.new do
              config.each do |c|
                instance_eval(&c)
              end
            end
            Heuristics.new(&proc)
          else
            Heuristics.new
          end
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
      Dir.glob(DEFAULT_GLOB).first
    end

    #
    # Find project root. This searches up from the current working
    # directory for a .map configuration file or source control 
    # manager directory.
    #
    #   .ruby/
    #   .map
    #   .git/
    #   .hg/
    #   .svn/
    #   _darcs/
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
