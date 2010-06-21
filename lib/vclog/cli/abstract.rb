require 'ostruct'
require 'optparse'

module VCLog
module CLI

  #
  def self.register
    @register ||= []
  end

  #
  class Abstract

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
      @options = OpenStruct.new
    end

    #
    def options
      @options
    end

    #
    def parser(&block)
      parser = OptionParser.new(&block)

      parser.on('--debug', 'show debugging information') do
        $DEBUG = true
      end
      parser.on('--help' , '-h', 'display this help information') do
        puts parser
        exit
      end
      parser
    end

    # Setup options common to templating commands.
    #
    # parser - instance of options parser
    #
    # Returns a instance of OptionParser.
    def template_options(parser)
      parser.separator(" ")
      parser.separator("OUTPUT OPTIONS: (use varies with format)")
      parser.on('--format', '-f FORMAT', "output format") do |format|
        options.format = format.to_sym
      end
      parser.on('--style <URI>', "provide a stylesheet URI (css or xsl) for HTML or XML format") do |uri|
        options.stylesheet = uri
      end
      parser.on('--title', '-t TITLE', "document title") do |string|
        options.title = string
      end
      parser.on('--detail', '-d', "provide details") do
        options.extra = true
      end
      parser.on('--id', "include revision id") do
        options.revision = true
      end
      parser.on('--level', '-l NUMBER', "lowest level of commit to display [0]") do |num|
        options.level = num.to_i
      end
      parser
    end

    # Run the command.
    def run(argv=nil)
      argv ||= ARGV.dup

      parser.parse!(argv)

      @root = Dir.pwd  # TODO: find root
      @conf = VCLog::Config.new(@root)
      @vcs  = VCLog::Adapters.factory(@conf)

      execute
    end

  end

end
end
