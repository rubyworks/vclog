require 'vclog/cli/abstract'

module VCLog
module CLI

  #
  class Autotag < Abstract

    #
    def self.terms
      ['autotag']
    end

    #
    def parser
      super do |opt|
        opt.banner = "Usage: vclog autotag"
        opt.separator(" ")
        opt.separator("DESCRIPTION:")
        opt.separator("  Ensure each entry in History has been tagged.")
        opt.separator(" ")
        opt.separator("SPECIAL OPTIONS:")
        opt.on('--prefix', '-p', 'tag label prefix'){ options[:prefix] = true }
        opt.on('--force', '-f', 'perform tagging without confirmation'){ options[:force] = true }
      end
    end

    #
    def execute
      repo.autotag(options[:prefix])
    end

  end

end
end
