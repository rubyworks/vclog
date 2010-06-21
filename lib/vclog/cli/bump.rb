require 'vclog/cli/abstract'

module VCLog
module CLI

  class Bump < Abstract

    #
    def self.terms
      ['bump']
    end

    #
    def parser
      super do |opt|
        opt.banner = "vclog bump"
        opt.separator("Display a bumped version number.")
      end
    end

    #
    def execute
      puts vcs.bump(version)
    end

  end

end
end
