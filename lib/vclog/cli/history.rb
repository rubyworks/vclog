require 'vclog/cli/abstract'

module VCLog
module CLI

  class History < Abstract

    #
    def self.terms
      ['history', 'release']
    end

    #
    def parser
      super do |opt|
        opt.banner = "Usage: vclog history [options]\n" +
                     "       vclog release [options]"
        opt.separator " "
        opt.separator("Print a Release History.")
        opt.separator(" ")
        opt.separator "SPECIAL OPTIONS:"
        opt.on('--version', '-v NUM', "use as if current version number") do |num|
          options[:version] = num
        end
        template_options(opt)
      end
    end

    #
    def execute
      format = options[:format] || 'ansi'
      output = repo.display(:history, format, options)
      puts output
    end

  end

end
end
