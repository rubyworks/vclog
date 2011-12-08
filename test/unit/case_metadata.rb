require File.expand_path(File.dirname(__FILE__) + '/helper')
require 'vclog/metadata'

testcase "VCLog" do

  test "VERSION is set" do
    ::VCLog::VERSION.assert == File.read('profile/version').strip
  end

end

