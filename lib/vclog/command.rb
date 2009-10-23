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
    format = :gnu
    typed  = false
    rev    = false
    vers   = nil
    style  = nil
    output = nil

    optparse = OptionParser.new do |opt|
      opt.separator("FORMAT (choose one):")

      opt.on('--gnu', "GNU standard format") do
        format = :gnu
      end

      opt.on('--xml [XSL]', "XML format") do |file|
        format = :xml
        style  = file
      end

      opt.on('--yaml', "YAML format") do
        format = :yaml
      end

      opt.on('--json', "JSON format") do
        format = :json
      end

      opt.on('--html [CSS]', "HTML micro-like format") do |file|
        format = :html
        style  = file
      end

      opt.on('--rel <VER>', "release format") do |version|
        format = :rel
        vers = version
      end

      opt.on('--rev <VER>', "release format w/ revison ids") do |version|
        format = :rev
        vers = version
      end

      opt.separator("OTHER OPTIONS:")

      opt.on('--typed', "catagorize by commit type") do
        typed = true
      end

      #opt.on('--style [FILE]', "provide a stylesheet (css or xsl)") do |val|
      #  style = val
      #end

      opt.on('--output', '-o [FILE]', "send output to a file instead of stdout") do |out|
        output = out
      end

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

    vcs = VCLog::VCS.new

    changelog = vcs.changelog

    if typed
      changelog = changelog.typed
    end

    case format
    when :xml
      log = changelog.format_xml(style)   # xsl stylesheet url
    when :html
      log = changelog.format_html(style)  # css stylesheet url
    when :yaml
      log = changelog.format_yaml
    when :json
      log = changelog.format_json
    when :rel
      file = changelog_file(output)
      raise "no previous log to go by" unless file
      log = changelog.format_rel(file, vers, nil, false)
    when :rev
      file = changelog_file(output)
      raise "no previous log to go by" unless file
      log = changelog.format_rel(file, vers, nil, true)
    else #:gnu
      log = changelog.to_s
    end

    if output
      File.open(output, 'w') do |f|
        f << log
      end
    else
      puts log
    end
  end

  def self.changelog_file(file)
    if file && File.file?(file)
      file
    else
      Dir.glob('{history,changes,changelog}{,.*}', File::FNM_CASEFOLD).first
    end
  end

end

# VCLog Copyright (c) 2008 Thomas Sawyer

