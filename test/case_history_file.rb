testcase VCLog::HistoryFile do

  test "finds the history file whatever its case" do
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'History.md'), "## 1.0.0 / 2020-02-02\n\nA note.\n")
      VCLog::HistoryFile.new(dir).tags.map{ |t| t.name }.assert == ['1.0.0']
    end
  end

  test "raises when there is none" do
    Dir.mktmpdir do |dir|
      RuntimeError.assert.raised?{ VCLog::HistoryFile.new(dir) }
    end
  end

  test "each release heading becomes a tag" do
    tags = VCLog::HistoryFile.new(git_fixture).tags
    tags.map{ |t| t.name }.assert == ['0.2.0', '0.1.0']
    tags.first.date.strftime('%Y-%m-%d').assert == '2020-01-04'
    tags.first.message.assert == "The second release fixes the frobnicator."
  end

  test "news is the latest release note" do
    VCLog::HistoryFile.new(git_fixture).news.assert == "The second release fixes the frobnicator."
  end

end
