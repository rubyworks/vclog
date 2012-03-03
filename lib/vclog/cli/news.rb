require 'vclog/cli/abstract'

module VCLog::CLI

  #
  class News < Abstract

    #
    def self.terms
      ['news']
    end

    #
    def parser
      super do |opt|
        opt.banner = "Usage: vclog-news"
        opt.separator(" ")
        opt.separator("Display first release note from history file.")
      end
    end

    #
    def execute
      puts repo.history_file.news #(version)
    end

  end

end
