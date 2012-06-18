require 'rc/api'

configure 'vclog' do |config|
  VCLog.configure(&config) if config.profile?
end

