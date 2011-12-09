require 'vclog/cli/abstract'

module VCLog::CLI

  # Display the current version.
  #
  class Version < Abstract

    #
    def self.terms
      ['version']
    end

    #
    def parser
      super do |opt|
        opt.banner = "Usage: vclog version"
        opt.separator(" ")
        opt.separator("Display the current version number.")
      end
    end

    #
    def execute
      puts repo.version
    end

  end

end
