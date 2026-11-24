testcase "VCLog" do

  test "VERSION is set" do
    ::VCLog::VERSION.assert =~ /\A\d+\.\d+\.\d+\z/
  end

end
