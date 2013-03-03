require 'vclog/metadata'

testcase "VCLog" do

  test "VERSION is set" do
    ::VCLog::VERSION.assert == File.read('index/version').strip
  end

end

