require 'rake/clean'
CLOBBER.include 'pkg'

require 'bundler/gem_helper'

# Bundler tags releases as v1.2.3, but VCLog's tags have always been
# plain version numbers, so keep it that way.
class Bundler::GemHelper
  def version_tag
    version.to_s
  end
end

Bundler::GemHelper.install_tasks

desc 'run unit tests'
task 'test:unit' do
  sh 'rubytest -Ilib -r spectrum/testcase -r ./test/helper test/case_*.rb'
end

desc 'run features'
task 'test:features' do
  sh 'rubytest -Ilib -r spectrum/feature -r ./test/helper spec/feature_*.rb'
end

desc 'run all tests'
task 'test' => ['test:unit', 'test:features']

task 'default' => 'test'
