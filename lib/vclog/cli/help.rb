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

      end
    end

  end

end
end
