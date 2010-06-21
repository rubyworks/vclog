require 'vclog/heuristics'

module VCLog

  #
  class Config

    GLOB = '{.vclog,.config/vclog,config/vclog}/'

    #
    def initialize(root=nil)
      @root = root || lookup_root || Dir.pwd
      @conf = Dir[File.join(root, GLOB)]
    end

    # Project's root directory.
    attr :root

    # Configuration directory.
    attr :conf

    #
    def heuristics
      @heuristics ||= Heuristics.load(heuristics_file)
    end

    #
    def heuristics_file
      @heuristics_file ||= Dir[File.join(conf, 'rules.rb')].first
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
        check = Dir['{.vclog/,.config/vclog/,config/vclog/,.git/,README*}/'].first
        if check
          root = path 
          break
        end
      end
      root || Dir.pwd
    end

  end

end
