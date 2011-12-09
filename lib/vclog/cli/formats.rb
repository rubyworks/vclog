require 'vclog/cli/abstract'

module VCLog::CLI

  # Command to display a list of available formats.
  #
  class Formats < Abstract

    #
    def self.terms
      ['formats', 'templates']
    end

    #
    def parser
      super do |opt|
        opt.banner = "Usage: vclog-formats"
      end
    end

    #
    def execute
      puts "  ansi  gnu  rdoc  markdown  xml  html  atom  rss  json  yaml"
    end

  end

end
