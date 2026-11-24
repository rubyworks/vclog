require 'vclog/cli/abstract'

module VCLog::CLI

  #
  class Autotag < Abstract

    #
    def self.terms
      ['autotag']
    end

    #
    def parser
      super do |opt|
        opt.banner = "Usage: vclog autotag [options]"
        opt.separator(" ")
        opt.separator("DESCRIPTION:")
        opt.separator("  Ensure each entry in History has been tagged.")
        opt.separator(" ")
        opt.separator("SPECIAL OPTIONS:")
        opt.on('--prefix', '-p PREFIX', 'tag label prefix'){ |prefix| options[:prefix] = prefix }
        opt.on('--file'  , '-f FILE', 'specify history file'){ |file| options[:history_file] = file }
        opt.on('--force' , '-y', 'perform tagging without confirmation'){ options[:force] = true }
        opt.on('--dryrun', '-n', 'run in dryrun mode'){ $DRYRUN = true }
      end
    end

    #
    def execute
      repo.autotag(options[:prefix])
    end

  end

end
