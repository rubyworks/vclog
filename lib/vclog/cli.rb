module VCLog

  require 'vclog/vcs'
  require 'optparse'

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
  #  $ vclog --xml
  #
  # Or for a micorformat-ish HTML:
  #
  #  $ vclog --html
  #
  # To use the library programmatically, please see the API documentation.

  def self.run
    begin
      vclog
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
  def self.vclog
    type    = :log
    format  = :gnu
    vers    = nil
    style   = nil
    output  = nil
    title   = nil
    version = nil
    extra   = false
    rev     = false
    typed   = false

    optparse = OptionParser.new do |opt|

      opt.banner = "Usage: vclog [TYPE] [FORMAT] [OPTIONS] [DIR]"

      opt.separator(" ")
      opt.separator("OUTPUT TYPE (choose one):")

      opt.on('--log', '--changelog', '-l', "changelog (default)") do
        type = :log
      end

      opt.on('--rel', '--history', '-r', "release history") do
        type = :rel
      end

      opt.on('--bump', '-b', "display a bumped version number") do
        doctype = :bump
      end

      opt.on('--current', '-c', "display current version number") do
        doctype = :curr
      end

      opt.separator(" ")
      opt.separator("FORMAT (choose one):")

      opt.on('--gnu', "GNU standard format (default)") do
        format = :gnu
      end

      opt.on('--xml', "XML format") do
        format = :xml
      end

      opt.on('--yaml', "YAML format") do
        format = :yaml
      end

      opt.on('--json', "JSON format") do
        format = :json
      end

      opt.on('--html', "HTML micro-like format") do
        format = :html
      end

      opt.on('--rdoc', "RDoc format") do
        format = :rdoc
      end

      opt.on('--markdown', '-m', "Markdown format") do
        format = :markdown
      end

      opt.separator(" ")    
      opt.separator("OTHER OPTIONS:")

      #opt.on('--typed', "catagorize by commit type") do
      #  typed = true
      #end

      opt.on('--title <TITLE>', "document title, used by some formats") do |string|
        title = string
      end

      opt.on('--extra', '-e', "provide extra output, used by some formats") do
        extra = true
      end

      opt.on('--version', '-v <NUM>', "current version to use for release history") do |num|
        version = num
      end

      opt.on('--style [FILE]', "provide a stylesheet name (css or xsl) for xml and html formats") do |val|
        style = val
      end

      opt.on('--id', "include revision ids (in formats that normally do not)") do
        rev = true
      end

      # DEPRECATE
      opt.on('--output', '-o [FILE]', "send output to a file instead of stdout") do |out|
        output = out
      end

      opt.separator(" ")
      opt.separator("STANDARD OPTIONS:")

      opt.on('--debug', "show debugging infromation") do
        $DEBUG = true
      end

      opt.on_tail('--help' , '-h', 'display this help information') do
        puts opt
        exit
      end
    end

    optparse.parse!(ARGV)

    root = ARGV.shift || Dir.pwd

    vcs = VCLog::VCS.factory #(root)

    case type
    when :bump
      puts vcs.bump(version)
      exit
    when :curr
      puts vcs.tags.last.name #TODO: ensure latest
      exit
    when :log
      log = vcs.changelog
      #log = log.typed if typed  #TODO: ability to select types?
    when :rel
      log = vcs.history(:title=>title, :extra=>extra, :version=>version)
    else
      raise "huh?"
      #log = vcs.changelog
      #log = log.typed if typed  #TODO: ability to select types?
    end

    case format
    when :xml
      txt = log.to_xml(style)   # xsl stylesheet url
    when :html
      txt = log.to_html(style)  # css stylesheet url
    when :yaml
      txt = log.to_yaml
    when :json
      txt = log.to_json
    when :markdown
      txt = log.to_markdown(rev)
    when :rdoc
      txt = log.to_rdoc(rev)
    else #:gnu
      txt = log.to_gnu(rev)
    end

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

end

# VCLog Copyright (c) 2008 Thomas Sawyer

