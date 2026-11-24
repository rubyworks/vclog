testcase VCLog::Adapters::Git do

  setup do
    @repo = VCLog::Repo.new(git_fixture, {})
  end

  test "every commit is a change, newest first" do
    @repo.changes.size.assert == 6
    @repo.changes.first.message.assert == "Add a second frobnicator."
    @repo.changes.last.message.assert == "Initial commit."
  end

  test "a change has an author, a date, an id and its files" do
    change = @repo.changes.find{ |c| c.message == "Add the frobnicator." }
    change.author.assert == "Tester"
    change.date.utc.strftime('%Y-%m-%d').assert == "2020-01-02"
    change.id.assert =~ /\A[0-9a-f]{40}\z/
    change.files.assert == ["frob.rb"]
  end

  test "a commit with no files is still a change" do
    change = @repo.changes.find{ |c| c.message == "Update the manual." }
    change.files.assert == []
  end

  test "heuristics give a change its type and take the mark off its message" do
    @repo.changes.map{ |c| c.type }.assert == [:default, :default, :doc, :bug, :major, :admin]
  end

  test "the rest of a commit message is its details" do
    change = @repo.changes.find{ |c| c.summary == "Polish the frobnicator." }
    change.details.assert == "* Sand it.\n* Paint it."
  end

  test "an annotated tag has its own message, author and date" do
    tag = @repo.tags.find{ |t| t.name == '0.1.0' }
    tag.message.assert == "The first release."
    tag.author.assert == "Tester <tester@example.com>"
    tag.date.utc.strftime('%Y-%m-%d').assert == "2020-01-02"
    tag.commit.message.assert == "Add the frobnicator. [major]"
  end

  test "a lightweight tag takes them from its commit" do
    tag = @repo.tags.find{ |t| t.name == '0.2.0' }
    tag.message.assert == "Update the manual. [doc]"
    tag.date.utc.strftime('%Y-%m-%d').assert == "2020-01-04"
  end

  test "the current version is the highest tag, not the last by name" do
    @repo.version.assert == "0.10.0"
  end

  test "a release holds the changes up to and including its tagged commit" do
    releases = @repo.releases(@repo.changes)
    listing  = releases.map{ |r| [r.tag.name, r.changes.map{ |c| c.summary }] }
    listing.assert == [
      ['HEAD',   ["Add a second frobnicator."]],
      ['0.10.0', ["Polish the frobnicator."]],
      ['0.2.0',  ["Update the manual.", "Fix the frobnicator."]],
      ['0.1.0',  ["Add the frobnicator.", "Initial commit."]]
    ]
  end

  test "bump parts" do
    @repo.bump_part('major').assert == "1.0.0"
    @repo.bump_part('minor').assert == "0.11.0"
    @repo.bump_part('patch').assert == "0.10.1"
  end

  test "bump is a patch when nothing has changed since the last release" do
    Dir.mktmpdir do |dir|
      env = {'GIT_CONFIG_GLOBAL'=>File::NULL, 'GIT_CONFIG_SYSTEM'=>File::NULL}
      [ %w[init -q -b master], %w[config user.name Tester], %w[config user.email tester@example.com],
        %w[config commit.gpgsign false], %w[config tag.gpgsign false],
        ['commit', '-q', '--allow-empty', '-m', 'Start.'], %w[tag -a -m First 1.2.3]
      ].each do |args|
        system(env, 'git', '-C', dir, *args, :out=>File::NULL, :err=>File::NULL).assert == true
      end
      VCLog::Repo.new(dir, {}).bump.assert == "1.2.4"
    end
  end

end
