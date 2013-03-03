#!/usr/bin/env ruby

Test.run :default do |run|
  require 'citron'
  require 'ae'

  run.files << 'test/case_*.rb'
end

Test.run :spec do |run|
  require 'lime'
  require 'ae'

  run.files << 'spec/feature_*.rb'
end

