require 'vclog/repo'

require 'vclog/cli/log'
require 'vclog/cli/formats'
require 'vclog/cli/bump'
require 'vclog/cli/version'
require 'vclog/cli/news'
require 'vclog/cli/autotag'

module VCLog

  # The `vclog` command line. The first argument can name a command;
  # without one, a change log is printed.
  #
  #   vclog [log] [options]
  #   vclog history [options]
  #   vclog version
  #   vclog bump
  #   vclog news
  #   vclog formats
  #   vclog autotag [options]
  #   vclog help [command]
  #
  module CLI

    # What each command does, in the order they are listed by `help`.
    COMMANDS = [
      ['log',     Log,     'print a change log (the default)'],
      ['history', Log,     'print a release history'],
      ['version', Version, 'print the current version'],
      ['bump',    Bump,    'print the next version, judging by the changes'],
      ['news',    News,    'print the latest release note of the history file'],
      ['formats', Formats, 'list the output formats'],
      ['autotag', Autotag, 'tag each release in the history file not yet tagged']
    ]

    # Other names a command answers to.
    ALIASES = { 'changelog'=>'log', 'release'=>'history', 'templates'=>'formats' }

    #
    # Run the command line.
    #
    def self.run(argv=ARGV)
      argv = argv.dup
      name = ALIASES[argv.first] || argv.first

      case name
      when 'help'
        argv.shift
        help(argv.first)
      when 'history'
        argv.shift
        Log.run(['--history'] + argv)
      else
        command = COMMANDS.find{ |term, _, _| term == name }
        if command
          argv.shift
          command[1].run(argv)
        elsif name && name !~ /\A-/
          $stderr.puts "vclog: unknown command -- #{name}"
          $stderr.puts "Try `vclog help`."
          exit(-1)
        else
          Log.run(argv)
        end
      end
    end

    #
    # Print the list of commands, or the help of one of them.
    #
    def self.help(name=nil)
      name    = ALIASES[name] || name
      command = COMMANDS.find{ |term, _, _| term == name }
      if command
        command[1].run(name == 'history' ? ['--history', '--help'] : ['--help'])
      elsif name
        $stderr.puts "vclog: unknown command -- #{name}"
        exit(-1)
      else
        puts "Usage: vclog [command] [options]"
        puts
        puts "COMMANDS:"
        COMMANDS.each do |term, _, description|
          puts "  %-9s %s" % [term, description]
        end
        puts "  %-9s %s" % ['help', 'show this list, or the options of a command']
        puts
        puts "With no command, a change log is printed. See `vclog help log`"
        puts "for its options."
      end
    end

  end

end
