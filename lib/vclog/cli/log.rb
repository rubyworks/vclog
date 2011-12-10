require 'vclog/cli/abstract'

module VCLog::CLI

  # VCLog provides cross-vcs ChangeLogs. It works by
  # parsing the native changelog a VCS system produces
  # into a common model, which then can be used to
  # produce Changelogs in a variety of formats.
  #
  # VCLog currently support git, hg and svn, with cvs and
  # darcs in the works.
  #
  # To produce a GNU-like changelog:
  #
  #   $ vclog
  #
  # For XML format:
  #
  #   $ vclog -f xml
  #
  # Or for a micorformat-ish HTML:
  #
  #   $ vclog -f html
  #
  # To use the library programmatically, please see the API documentation.
  #
  class Log < Abstract

    # Setup options for log command.
    #
    # Returns a instance of OptionParser.
    def parser
      super do |parser|
        parser.banner = 'Usage: vclog [options]'
        parser.separator(' ')
        parser.separator('Print a change log or release history.')
        parser.separator(' ')
        parser.separator('OPTIONS: (use varies with format)')
        parser.on('-f', '--format FORMAT', 'output format (ansi,gnu,html,...)') do |format|
          options[:format] = format.to_sym
        end
        parser.on('-r', '--release', '--history', 'show release history, instead of changelog') do
          options[:type] = :history
        end
        parser.on('--style URI', 'provide a stylesheet URI (css or xsl) for HTML or XML format') do |uri|
          options[:stylesheet] = uri
        end
        parser.on('-t', '--title TITLE', 'document title') do |string|
          options[:title] = string
        end
        parser.on('-i', '--id', 'include reference/revision id in output') do
          options[:reference] = true  # TODO: change to :id ?
        end
        parser.on('-l', '--level NUMBER', 'lowest level of commit to display (default: 0)') do |num|
          options[:level] = num.to_i
        end
        parser.on('-m', '--message', 'use full commit message, instead of just subject/summary') do
          options[:message] = true
        end
        parser.on('-p', '--point', 'split commits into per-point entries') do
          options[:point] = true
        end
        parser.on('-x', '--no-detail', 'exclude detail from history report') do
          options[:extra] = false  # TODO: rename to :detail or :no_detail ?
        end
        parser.on('-v', '--version NUM', 'use as current version number') do |num|
          options[:version] = num
        end
        #parser.on('--typed', "catagorize by commit type") do
        #  typed = true
        #end
      end
    end

    #
    def execute
      puts repo.report(options)
    end

  end

end
