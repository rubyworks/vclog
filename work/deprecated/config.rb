require 'vclog/heuristics'

module VCLog

  #
  class Config

    # File glob used to find the vclog configuration directory.
    CONFIG_GLOB = '{.vclog,.config/vclog,config/vclog}/'

    #
    def initialize(root, options={})
      @root  = root
      @dir   = Dir[File.join(root, CONFIG_GLOB)]
      @level = options[:level] || 0
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

  end

end
