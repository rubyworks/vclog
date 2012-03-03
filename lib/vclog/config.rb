require 'vclog/heuristics'

module VCLog

  # Encapsulates configuration settings for running vclog.
  #
  class Config

    #
    # If not in a default location a `.map` entry can be used to
    # tell vclog where the config file it located.
    #
    # @example
    #   ---
    #   vclog: task/vclog.rb
    #
    MAP_FILE = ".map"

    #
    # Default vclog config file glob looks for these possible matches in order:
    #
    # * .vclog
    # * .config/vclog
    # * config/vclog
    # * .dot/vclog
    # * dot/vclog
    #
    # File may have optional `.rb` extension.
    #
    DEFAULT_GLOB = '{.,.config/,config/.dot/,dot/}vclog{,.rb}'

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
          Heuristics.new
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
      if glob = file_map['vclog']
        Dir.glob(glob).first
      else
        Dir.glob(DEFAULT_GLOB).first
      end
    end

    # 
    # Project's map file, if present.
    #
    def map_file
      file = File.join(root, MAP_FILE)
      return file if File.exist?(file)
      return nil
    end

    #
    # Load the map file.
    #
    def file_map
      @file_map ||= (
        map_file ? YAML.load_file(map_file) : {}
      )
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
