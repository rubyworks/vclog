#require_relative 'featurettes/repo_creation'
#require_relative 'featurettes/shellout'

Feature "Git Release History Support" do
  As "Git users"
  We "want to generate nicely formatted release histories"

  Scenario "Git Release History" do
    Given "a suitable Git repository"
    When  "I run `vclog r`"
    Then  "the exit status should be 0"
  end

  Scenario "Git Release History in RDoc" do
    Given "a suitable Git repository"
    When  "I run `vclog r -f rdoc`"
    Then  "the exit status should be 0"
  end

  Scenario "Git Release History in Markdown" do
    Given "a suitable Git repository"
    When  "I run `vclog rel -f markdown`"
    Then  "the exit status should be 0"
  end

  Scenario "Git Release History in HTML" do
    Given "a suitable Git repository"
    When  "I run `vclog rel -f html`"
    Then  "the exit status should be 0"
  end

  Scenario "Git Release History in XML" do
    Given "a suitable Git repository"
    When  "I run `vclog rel -f xml`"
    Then  "the exit status should be 0"
  end

  Scenario "Git Release History in Atom" do
    Given "a suitable Git repository"
    When  "I run `vclog rel -f atom`"
    Then  "the exit status should be 0"
  end

  Scenario "Git Release History in YAML" do
    Given "a suitable Git repository"
    When  "I run `vclog rel -f yaml`"
    Then  "the exit status should be 0"
  end

  Scenario "Git Release History in JSON" do
    Given "a suitable Git repository"
    When  "I run `vclog rel -f json`"
    Then  "the exit status should be 0"
  end

  include RepoCreation
  include Shellout
end
