Feature "Commands" do
  As "a maintainer"
  We "want one command line with a command for each task"

  Scenario "Current version" do
    Given "a suitable Git repository"
    When  "I run `vclog version`"
    Then  "the exit status should be 0"
    And   'the output should be "0.10.0"'
  end

  Scenario "Next version" do
    Given "a suitable Git repository"
    When  "I run `vclog bump`"
    Then  "the exit status should be 0"
    And   'the output should be "0.11.0"'
  end

  Scenario "Latest release note" do
    Given "a suitable Git repository"
    When  "I run `vclog news`"
    Then  "the exit status should be 0"
    And   'the output should be "The second release fixes the frobnicator."'
  end

  Scenario "List of formats" do
    Given "a suitable Git repository"
    When  "I run `vclog formats`"
    Then  "the exit status should be 0"
    And   'the output should include "markdown"'
  end

  Scenario "Change log by name" do
    Given "a suitable Git repository"
    When  "I run `vclog log -f gnu`"
    Then  "the exit status should be 0"
    And   'the output should include "CHANGELOG"'
    And   'the output should include "Add the frobnicator."'
  end

  Scenario "Change log is the default" do
    Given "a suitable Git repository"
    When  "I run `vclog -f gnu`"
    Then  "the exit status should be 0"
    And   'the output should include "CHANGELOG"'
  end

  Scenario "Release history by name" do
    Given "a suitable Git repository"
    When  "I run `vclog history -f gnu`"
    Then  "the exit status should be 0"
    And   'the output should include "RELEASE HISTORY"'
    And   'the output should include "0.10.0 / 2020-01-07"'
  end

  Scenario "Release history by option" do
    Given "a suitable Git repository"
    When  "I run `vclog -r -f gnu`"
    Then  "the exit status should be 0"
    And   'the output should include "RELEASE HISTORY"'
  end

  Scenario "List of commands" do
    Given "a suitable Git repository"
    When  "I run `vclog help`"
    Then  "the exit status should be 0"
    And   'the output should include "COMMANDS:"'
    And   'the output should include "autotag"'
  end

  Scenario "Help for a command" do
    Given "a suitable Git repository"
    When  "I run `vclog help bump`"
    Then  "the exit status should be 0"
    And   'the output should include "Usage: vclog bump"'
  end

  Scenario "Unknown command" do
    Given "a suitable Git repository"
    When  "I run `vclog frobnicate`"
    Then  "the exit status should be 255"
    And   'the error output should include "unknown command -- frobnicate"'
  end

  Scenario "Tag the releases in the history file, as a dry run" do
    Given "a suitable Git repository"
    When  "I run `vclog autotag -n -y --debug`"
    Then  "the exit status should be 0"
    And   'the output should not include "0.1.0"'
  end

  include RepoCreation
  include Shellout
end

Feature "Deprecated Commands" do
  As "a maintainer with scripts written for earlier versions"
  We "want the separate executables to go on working"

  Scenario "vclog-version" do
    Given "a suitable Git repository"
    When  "I run `vclog-version`"
    Then  "the exit status should be 0"
    And   'the output should be "0.10.0"'
  end

  Scenario "vclog-bump" do
    Given "a suitable Git repository"
    When  "I run `vclog-bump`"
    Then  "the exit status should be 0"
    And   'the output should be "0.11.0"'
  end

  Scenario "vclog-news" do
    Given "a suitable Git repository"
    When  "I run `vclog-news`"
    Then  "the exit status should be 0"
    And   'the output should be "The second release fixes the frobnicator."'
  end

  Scenario "vclog-formats" do
    Given "a suitable Git repository"
    When  "I run `vclog-formats`"
    Then  "the exit status should be 0"
    And   'the output should include "markdown"'
  end

  Scenario "vclog-autotag" do
    Given "a suitable Git repository"
    When  "I run `vclog-autotag --help`"
    Then  "the exit status should be 0"
    And   'the output should include "Usage: vclog autotag"'
  end

  include RepoCreation
  include Shellout
end
