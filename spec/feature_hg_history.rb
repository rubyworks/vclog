#require_relative 'featurettes/repo_creation'
#require_relative 'featurettes/shellout'

Feature "Mercurial Release History Support" do
  As "Mercurial users"
  We "want to generate nicely formatted Release Histories"

  Scenario "Mercurial Release History" do
    Given "a suitable Mercurial repository"
    When  "I run `vclog rel`"
    Then  "the exit status should be 0"
  end

  Scenario "Mercurial Release History in RDoc" do
    Given "a suitable Mercurial repository"
    When  "I run `vclog rel -f rdoc`"
    Then  "the exit status should be 0"
  end

  Scenario "Mercurial Release History in Markdown" do
    Given "a suitable Mercurial repository"
    When  "I run `vclog rel -f markdown`"
    Then  "the exit status should be 0"
  end

  Scenario "Mercurial Release History in HTML" do
    Given "a suitable Mercurial repository"
    When  "I run `vclog rel -f html`"
    Then  "the exit status should be 0"
  end

  Scenario "Mercurial Release History in XML" do
    Given "a suitable Mercurial repository"
    When  "I run `vclog rel -f xml`"
    Then  "the exit status should be 0"
  end

  Scenario "Mercurial Release History in Atom" do
    Given "a suitable Mercurial repository"
    When  "I run `vclog rel -f atom`"
    Then  "the exit status should be 0"
  end

  Scenario "Mercurial Release History in YAML" do
    Given "a suitable Mercurial repository"
    When  "I run `vclog rel -f yaml`"
    Then  "the exit status should be 0"
  end

  Scenario "Mercurial Release History in JSON" do
    Given "a suitable Mercurial repository"
    When  "I run `vclog rel -f json`"
    Then  "the exit status should be 0"
  end

  include RepoCreation
  include Shellout
end
