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

      end
    end

  end

end
end
