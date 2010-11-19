require 'vclog/cli/abstract'

module VCLog
module CLI

  class Changelog < Abstract

    #
    def self.terms
      ['log', 'changelog']
    end

    #
    def parser
      super do |opt|
        opt.banner = "Usage: vclog [changelog | log] [options]"
        opt.separator(" ")
        opt.separator("Print a Change Log.")
        template_options(opt)
      end
    end

    #
    def execute
      format = options.format || 'ansi'
      output = repo.display(:changelog, format, options)
      puts output
    end

  end

end
end
