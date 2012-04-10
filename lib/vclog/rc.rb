require 'rc/interface'

RC.run('vclog') do |config|
  VCLog.rc_config = config
end

class << VCLog
  attr_accessor :rc_config
end

