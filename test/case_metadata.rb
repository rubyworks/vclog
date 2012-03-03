require 'vclog/metadata'

testcase "VCLog" do

  test "VERSION is set" do
    ::VCLog::VERSION.assert == File.read('meta/version').strip
  end

end

