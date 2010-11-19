module VCLog

  #
  def self.cli(*argv)
    argv ||= ARGV.dup
    begin
      #opt = global_parser.order!(argv)
      cmd = argv.shift unless argv.first =~ /^-/
      cmd = cmd || 'changelog'
      cli = CLI.factory(cmd)
      cli.run(argv)
    rescue => err
      if $DEBUG
        raise err
      else
        puts err.message
        exit -1
      end
    end
  end

  # = Command Line Interface
  #
  # == SYNOPSIS
  #
  # VCLog provides cross-vcs ChangeLogs. It works by
  # parsing the native changelog a VCS system produces
  # into a common model, which then can be used to
  # produce Changelogs in a variety of formats.
  #
  # VCLog currently support git, hg and svn, with cvs and darcs in the works.
  #
  # == EXAMPLES
  #
  # To produce a GNU-like changelog:
  #
  #  $ vclog
  #
  # For XML format:
  #
  #  $ vclog -f xml
  #
  # Or for a micorformat-ish HTML:
  #
  #  $ vclog -f html
  #
  # To use the library programmatically, please see the API documentation.

  module CLI
    require 'vclog/repo'

    require 'vclog/cli/help'
    require 'vclog/cli/changelog'
    require 'vclog/cli/history'
    require 'vclog/cli/formats'
    require 'vclog/cli/bump'
    require 'vclog/cli/version'
    require 'vclog/cli/autotag'

    #
    def self.factory(name)
      # find the closet matching term
      terms = register.map{ |cli| cli.terms }.flatten
      term = terms.select{ |term| /^#{name}/ =~ term }.first
      # get the class that goes with the term
      cmdclass = register.find{ |cli| cli.terms.include?(term) }
      raise "Unknown command -- #{name}" unless cmdclass
      cmdclass.new
    end

  end
end
