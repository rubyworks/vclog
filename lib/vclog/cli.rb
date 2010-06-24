module VCLog

  # = vclog Command
  #
  # == SYNOPSIS
  #
  # VCLog provides cross-vcs ChangeLogs. It works by
  # parsing the native changelog a VCS system produces
  # into a common model, which then can be used to
  # produce Changelogs in a variety of formats.
  #
  # VCLog currently support SVN and Git. CVS, Darcs and
  # Mercurial/Hg are in the works.
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

    require 'vclog/config'
    require 'vclog/adapters'

    require 'vclog/cli/help'
    require 'vclog/cli/changelog'
    require 'vclog/cli/history'
    require 'vclog/cli/list'
    require 'vclog/cli/bump'
    require 'vclog/cli/version'

    def self.main(*argv)
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

# VCLog Copyright (c) 2008 Thomas Sawyer

=begin
  #
  def self.vclog
    type    = :log
    format  = :gnu
    vers    = nil
    style   = nil
    output  = nil
    title   = nil
    version = nil
    extra   = false  require 'vclog/cli/help'
    rev     = false
    typed   = false

    optparse = OptionParser.new do |opt|

      opt.banner = "Usage: vclog [--TYPE] [-f FORMAT] [OPTIONS] [DIR]"

      opt.on('--current', '-c', "display current version number") do
        type = :curr
      end

      opt.on('--bump', '-b', "display a bumped version number") do
        type = :bump
      end

      opt.on('--formats', '-F', "list supported formats") do
        puts "gnu rdoc markdown xml html atom rss json yaml"
        exit
      end

      opt.on('--help' , '-h', 'display this help information') do
        puts opt
        exit
      end

      opt.separator(" ")
      opt.separator("FORMAT OPTIONS: (use varies with format)")

      opt.on('--format', '-f FORMAT', "output format") do |format|
        format = format.to_sym
      end

      opt.on('--style <URI>', "provide a stylesheet URI (css or xsl) for HTML or XML format") do |uri|
        style = uri
      end

      opt.on('--version', '-v NUM', "current version number") do |num|
        version = num
      end


      #opt.on('--typed', "catagorize by commit type") do
      #  typed = true
      #end

      opt.on('--title', '-t TITLE', "document title") do |string|
        title = string
      end

      opt.on('--detail', '-d', "provide details") do
        extra = true
      end

      opt.on('--id', "include revision id") do
        rev = true
      end

      opt.on('--style URI', "provide a stylesheet URI (css or xsl) for HTML or XML format") do |uri|
        style = uri
      end

      # DEPRECATE
      opt.on('--output', '-o FILE', "send output to a file instead of stdout") do |out|
        output = out
      end

      opt.separator(" ")
      opt.separator("SYSTEM OPTIONS:")

      opt.on('--debug', "show debugging information") do
        $DEBUG = true
      end
    end

    optparse.parse!(ARGV)

    root = ARGV.shift || Dir.pwd
    conf = VCLog::Config.new(root)
    vcs  = VCLog::Adapters.factory(conf)

    case type
    when :bump
      puts vcs.bump(version)
      exit
    when :curr
      if vcs.tags.empty?
        puts "0.0.0"
      else
        puts vcs.tags.last.name #TODO: ensure latest
      end
      exit
    when :log
      doctype = :changelog
      #log = vcs.changelog
      #log = log.typed if typed  #TODO: ability to select types?
    when :rel
      doctype = :history
      #log = vcs.history(:title=>title, :extra=>extra, :version=>version)
    else
      raise "huh?"
      #log = vcs.changelog
      #log = log.typed if typed  #TODO: ability to select types?
    end

    options = { 
      :title      => title,
      :extra      => extra,
      :version    => version,
      :revision   => rev,
      :stylesheet => style 
    }

    txt = vcs.display(doctype, format, options)

    #case format
    #when :xml
    #  txt = log.to_xml(style)   # xsl stylesheet url
    #when :html
    #  txt = log.to_html(style)  # css stylesheet url
    #when :yaml
    #  txt = log.to_yaml
    #when :json
    #  txt = log.to_json
    #when :markdown
    #  txt = log.to_markdown(rev)
    #when :rdoc
    #  txt = log.to_rdoc(rev)
    #else #:gnu
    #  txt = log.to_gnu(rev)
    #end

    if output
      File.open(output, 'w') do |f|
        f << txt
      end
    else
      puts txt
    end
  end

  #def self.changelog_file(file)
  #  if file && File.file?(file)
  #    file
  #  else
  #    Dir.glob('{history,changes,changelog}{,.*}', File::FNM_CASEFOLD).first
  #  end
  #end
=end

