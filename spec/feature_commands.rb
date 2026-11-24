Feature "Version Commands" do
  As "a maintainer"
  We "want to know the current version and the next one"

  Scenario "Current version" do
    Given "a suitable Git repository"
    When  "I run `vclog-version`"
    Then  "the exit status should be 0"
    And   'the output should be "0.10.0"'
  end

  Scenario "Bumped version" do
    Given "a suitable Git repository"
    When  "I run `vclog-bump`"
    Then  "the exit status should be 0"
    And   'the output should be "0.11.0"'
  end

  Scenario "Latest release note" do
    Given "a suitable Git repository"
    When  "I run `vclog-news`"
    Then  "the exit status should be 0"
    And   'the output should be "The second release fixes the frobnicator."'
  end

  Scenario "List of formats" do
    Given "a suitable Git repository"
    When  "I run `vclog-formats`"
    Then  "the exit status should be 0"
    And   'the output should include "markdown"'
  end

  include RepoCreation
  include Shellout
end
