testcase VCLog::Heuristics do

  def change(message)
    VCLog::Change.new(:id=>'1', :date=>'2020-01-01', :who=>'Tester', :msg=>message)
  end

  test "a trailing mark in brackets sets the type" do
    c = change("Fix it. [bug]")
    VCLog::Heuristics.new.apply(c)
    c.type.assert == :bug
    c.label.assert == "Bug Fixes"
    c.level.assert == 1
    c.message.assert == "Fix it."
  end

  test "a leading word and colon sets the type" do
    c = change("doc: Explain it.")
    VCLog::Heuristics.new.apply(c)
    c.type.assert == :doc
    c.message.assert == "Explain it."
  end

  test "an unmarked change is nominal" do
    c = change("Do something.")
    VCLog::Heuristics.new.apply(c)
    c.type.assert == :default
    c.level.assert == 0
  end

  test "rules can be given as a script" do
    h = VCLog::Heuristics.eval(<<-END)
      type :chore, -4, "Chores"
      on(/tidy/) do |commit|
        commit.type = :chore
      end
    END
    c = change("tidy up")
    h.apply(c)
    c.label.assert == "Chores"
    c.level.assert == -4
  end

  test "rules are loaded from a project's config file" do
    Dir.mktmpdir do |dir|
      Dir.mkdir(File.join(dir, 'etc'))
      File.write(File.join(dir, 'etc', 'vclog.rb'), %[type :chore, -4, "Chores"\n])
      config = VCLog::Config.new(:root=>dir)
      config.file.assert == File.join(dir, 'etc', 'vclog.rb')
      config.heuristics.types[:chore].label.assert == "Chores"
    end
  end

end
