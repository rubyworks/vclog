$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'assay/ae'
require 'open3'
require 'tmpdir'
require 'fileutils'
require 'rbconfig'
require 'vclog'

module Spectrum::World

  PROJECT = File.expand_path('..', __dir__)

  # A small Git repository with a known history, built once per run.
  #
  #   2020-01-01  Initial commit. [admin]
  #   2020-01-02  Add the frobnicator. [major]      <- 0.1.0 (annotated)
  #   2020-01-03  bug: Fix the frobnicator.
  #   2020-01-04  Update the manual. [doc]          <- 0.2.0 (lightweight), no files
  #   ...
  #   2020-01-07  Polish the frobnicator.           <- 0.10.0 (annotated)
  #   2020-01-08  Add a second frobnicator.
  #
  def git_fixture
    $vclog_git_fixture ||= build_git_fixture
  end

  # Run one of the project's commands in a directory, as a user would.
  # Returns standard output, standard error and the exit status.
  def run_command(line, dir)
    name, *args = line.split(' ')
    out, err, status = Open3.capture3(
      fixture_env, RbConfig.ruby, "-I#{PROJECT}/lib", "#{PROJECT}/bin/#{name}", *args, :chdir=>dir
    )
    return out, err, status.exitstatus
  end

private

  def fixture_env
    { 'GIT_CONFIG_GLOBAL' => File::NULL, 'GIT_CONFIG_SYSTEM' => File::NULL, 'RUBYOPT' => nil }
  end

  def build_git_fixture
    dir = Dir.mktmpdir('vclog-git-')
    at_exit{ FileUtils.remove_entry(dir) if File.directory?(dir) }

    git = lambda do |date, *args|
      env = fixture_env.merge('GIT_AUTHOR_DATE'=>"#{date} 12:00:00 +0000", 'GIT_COMMITTER_DATE'=>"#{date} 12:00:00 +0000")
      out, status = Open3.capture2e(env, 'git', '-C', dir, *args)
      raise "git #{args.join(' ')} failed:\n#{out}" unless status.success?
    end

    commit = lambda do |date, message, file=nil|
      if file
        File.write(File.join(dir, file), "#{message}\n", :mode=>'a')
        git.call(date, 'add', file)
      end
      git.call(date, 'commit', '-q', '--allow-empty', '-m', message)
    end

    git.call('2020-01-01', 'init', '-q', '-b', 'master')
    git.call('2020-01-01', 'config', 'user.name', 'Tester')
    git.call('2020-01-01', 'config', 'user.email', 'tester@example.com')
    git.call('2020-01-01', 'config', 'commit.gpgsign', 'false')
    git.call('2020-01-01', 'config', 'tag.gpgsign', 'false')

    File.write(File.join(dir, 'HISTORY.md'), <<-END.gsub(/^ {6}/, ''))
      # RELEASE HISTORY

      ## 0.2.0 / 2020-01-04

      The second release fixes the frobnicator.

      Changes:

      * Fix the frobnicator.

      ## 0.1.0 / 2020-01-02

      The first release.

      Changes:

      * Add the frobnicator.
    END

    commit.call('2020-01-01', 'Initial commit. [admin]', 'HISTORY.md')
    commit.call('2020-01-02', 'Add the frobnicator. [major]', 'frob.rb')
    git.call('2020-01-02', 'tag', '-a', '-m', 'The first release.', '0.1.0')
    commit.call('2020-01-03', 'bug: Fix the frobnicator.', 'frob.rb')
    commit.call('2020-01-04', 'Update the manual. [doc]')
    git.call('2020-01-04', 'tag', '0.2.0')
    commit.call('2020-01-07', "Polish the frobnicator.\n\n* Sand it.\n* Paint it.", 'frob.rb')
    git.call('2020-01-07', 'tag', '-a', '-m', 'Add a coat of paint.', '0.10.0')
    commit.call('2020-01-08', 'Add a second frobnicator.', 'frob2.rb')

    dir
  end

end
