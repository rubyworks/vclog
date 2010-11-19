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
        puts "  version        display the current tag version"
        puts "  bump           display next reasonable version"
        puts "  list           display format selection"
        puts "  autotag        create tags for history entries"
        puts "  help           show help information"
        puts
      end
    end

  end

end
end
