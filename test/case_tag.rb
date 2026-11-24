testcase VCLog::Tag do

  def tag(name)
    VCLog::Tag.new(:name=>name, :date=>'2020-01-01', :who=>'Tester', :msg=>'')
  end

  test "tags sort newest version first" do
    names = %w[0.2.0 0.10.0 0.1.0 1.0.0].map{ |n| tag(n) }.sort.map{ |t| t.name }
    names.assert == %w[1.0.0 0.10.0 0.2.0 0.1.0]
  end

  test "a v prefix doesn't matter" do
    names = %w[v0.2.0 v0.10.0].map{ |n| tag(n) }.sort.map{ |t| t.name }
    names.assert == %w[v0.10.0 v0.2.0]
  end

  test "HEAD sorts before any version" do
    names = [tag('9.0.0'), tag('HEAD')].sort.map{ |t| t.name }
    names.assert == %w[HEAD 9.0.0]
  end

end

testcase VCLog::Change do

  test "a change with an empty message has an empty summary" do
    change = VCLog::Change.new(:id=>'1', :date=>'2020-01-01', :who=>'Tester', :msg=>'')
    change.summary.assert == ''
    change.details.assert == ''
  end

end
