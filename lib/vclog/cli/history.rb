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
        opt.on('--version', '-v NUM', "current version number") do |num|
          options.version = num
        end

        template_options(opt)
      end
    end

    #
    def execute
      format = options.format || 'ansi'
      output = @vcs.display(:history, format, options)
      puts output
    end

  end

end
end
