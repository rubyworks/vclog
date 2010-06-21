module VCLog

  #
  class Metadata

    def initialize
      if file = Dir['PROFILE{,.yml}'].first
        @profile = YAML.load(File.new(file))
      end
    end

  end

end
