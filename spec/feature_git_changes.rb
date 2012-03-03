#require_relative 'featurettes/repo_creation'
#require_relative 'featurettes/shellout'

Feature "Git Change Log Support" do
  As "Git users"
  We "want to generate nicely formatted change logs"

  Scenario "Git Changelog" do
    Given "a suitable Git repository"
    When  "I run `vclog`"
    Then  "the exit status should be 0"
  end

  Scenario "Git Changelog in RDoc" do
    Given "a suitable Git repository"
    When  "I run `vclog -f rdoc`"
    Then  "the exit status should be 0"
  end

  Scenario "Git Changelog in Markdown" do
    Given "a suitable Git repository"
    When  "I run `vclog -f markdown`"
    Then  "the exit status should be 0"
  end

  Scenario "Git Changelog in HTML" do
    Given "a suitable Git repository"
    When  "I run `vclog -f html`"
    Then  "the exit status should be 0"
  end

  Scenario "Git Changelog in XML" do
    Given "a suitable Git repository"
    When  "I run `vclog -f xml`"
    Then  "the exit status should be 0"
  end

  Scenario "Git Changelog in Atom" do
    Given "a suitable Git repository"
    When  "I run `vclog -f atom`"
    Then  "the exit status should be 0"
  end

  Scenario "Git Changelog in YAML" do
    Given "a suitable Git repository"
    When  "I run `vclog -f yaml`"
    Then  "the exit status should be 0"
  end

  Scenario "Git Changelog in JSON" do
    Given "a suitable Git repository"
    When  "I run `vclog -f json`"
    Then  "the exit status should be 0"
  end

  include RepoCreation
  include Shellout
end
