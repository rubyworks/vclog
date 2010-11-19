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
        opt.banner = "Usage: vclog bump"
        opt.separator(" ")
        opt.separator("Display a bumped version number.")
      end
    end

    #
    def execute
      puts repo.bump #(version)
    end

  end

end
end
