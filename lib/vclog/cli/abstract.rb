require 'vclog'
require 'optparse'

module VCLog
  module CLI

    #
    def self.register
      @register ||= []
    end

    # Abstract base class for all command classes.
    #
    class Abstract

      #
      def self.run(argv)
        new.run(argv)
      rescue => err
        if $DEBUG
          raise err
        else
          puts err.message
          exit -1
        end
      end

      #
      def self.inherited(subclass)
        CLI.register << subclass
      end

      #
      def self.terms
        [name.split('::').last.downcase]
      end

      #
      def initialize
        @options = {}
      end

      #
      def options
        @options
      end

      #
      def parser(&block)
        parser = OptionParser.new(&block)

        parser.separator " "
        parser.separator "SYSTEM OPTIONS:"
        parser.on('--debug', 'show debugging information') do
          $DEBUG = true
        end
        parser.on('--help' , '-h', 'display this help information') do
          puts parser
          exit
        end
        parser
      end

      # Run the command.
      def run(argv=nil)
        argv ||= ARGV.dup

        parser.parse!(argv)

        @arguments = argv

        root  = Dir.pwd  # TODO: find root

        @repo = VCLog::Repo.new(root, options)

        execute
      end

      # Repo is set in #run.
      def repo
        @repo
      end

      #
      attr :arguments

    end

  end
end
