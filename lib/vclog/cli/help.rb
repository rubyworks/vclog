require 'vclog/cli/abstract'

module VCLog
module CLI

  class Help < Abstract

    #
    def self.terms
      ['help']
    end

    #
    def parser
      super do |opt|
        opt.banner = "Usage: vclog help"
      end
    end

    #
    def execute
      if cmd = arguments.first
        VCLog::CLI.cli(cmd, '--help')
      else
        puts "Usage: vclog [command] [options]"
        puts
        puts "COMMANDS:"
        puts "  changelog      produce a Change Log"
        puts "  history        produce a Release History"
        puts "  formats        list available formats"
        puts "  version        display the current version"
        puts "  bump           display next reasonable version"
        puts "  autotag        create tags for history file entries"
        puts "  help           show help information"
        puts
      end
    end

  end

end
end
