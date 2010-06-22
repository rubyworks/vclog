require 'vclog/cli/abstract'

module VCLog
module CLI

  class List < Abstract

    #
    def self.terms
      ['list', 'templates']
    end

    #
    def parser
      super do |opt|
        opt.banner = "Usage: vclog list"
      end
    end

    #
    def execute
      puts "  ansi  gnu  rdoc  markdown  xml  html  atom  rss  json  yaml"
    end

  end

end
end
