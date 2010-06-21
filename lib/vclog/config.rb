require 'vclog/heuristics'

module VCLog

  #
  class Config

    # File glob used to find the vclog configuration directory.
    CONFIG_GLOB = '{.vclog,.config/vclog,config/vclog}/'

    # File glob used to find project root directory.
    ROOT_GLOB = '{.vclog/,.config/vclog/,config/vclog/,.git/,README*}/'

    #
    def initialize(root=nil)
      @root  = root || lookup_root || Dir.pwd
      @dir   = Dir[File.join(root, CONFIG_GLOB)]
      @level = 0
    end

    # Project's root directory.
    attr :root

    # Configuration directory.
    attr :dir

    # Default change level.
    #
    # TODO: get from config file.
    attr_accessor :level

    #
    def heuristics
      @heuristics ||= Heuristics.load(heuristics_file)
    end

    #
    def heuristics_file
      @heuristics_file ||= Dir[File.join(dir, 'rules.rb')].first
    end

    # Find project root. This searches up from the current working
    # directory for the following paths (in order):
    #
    #   .vclog/
    #   .config/vclog/
    #   config/vclog/
    #   .git/
    #   README*
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
