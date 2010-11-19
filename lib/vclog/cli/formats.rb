require 'vclog/cli/abstract'

module VCLog
module CLI

  class Formats < Abstract

    #
    def self.terms
      ['formats', 'templates']
    end

    #
    def parser
      super do |opt|
        opt.banner = "Usage: vclog formats"
      end
    end

    #
    def execute
      puts "  ansi  gnu  rdoc  markdown  xml  html  atom  rss  json  yaml"
    end

  end

end
end
