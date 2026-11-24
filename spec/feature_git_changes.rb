Feature "Git Change Log Support" do
  As "Git users"
  We "want to generate nicely formatted change logs"

  Scenario "Git Changelog" do
    Given "a suitable Git repository"
    When  "I run `vclog`"
    Then  "the exit status should be 0"
    And   'the output should include "Add the frobnicator."'
  end

  Scenario "Git Changelog in RDoc" do
    Given "a suitable Git repository"
    When  "I run `vclog -f rdoc`"
    Then  "the exit status should be 0"
    And   'the output should include "Add the frobnicator."'
  end

  Scenario "Git Changelog in Markdown" do
    Given "a suitable Git repository"
    When  "I run `vclog -f markdown`"
    Then  "the exit status should be 0"
    And   'the output should include "Add the frobnicator."'
  end

  Scenario "Git Changelog in GNU style" do
    Given "a suitable Git repository"
    When  "I run `vclog -f gnu`"
    Then  "the exit status should be 0"
    And   'the output should include "Add the frobnicator."'
  end

  Scenario "Git Changelog in HTML" do
    Given "a suitable Git repository"
    When  "I run `vclog -f html`"
    Then  "the exit status should be 0"
    And   'the output should include "Add the frobnicator."'
  end

  Scenario "Git Changelog in XML" do
    Given "a suitable Git repository"
    When  "I run `vclog -f xml`"
    Then  "the exit status should be 0"
    And   'the output should include "Add the frobnicator."'
  end

  Scenario "Git Changelog in Atom" do
    Given "a suitable Git repository"
    When  "I run `vclog -f atom`"
    Then  "the exit status should be 0"
    And   'the output should include "Add the frobnicator."'
  end

  Scenario "Git Changelog in RSS" do
    Given "a suitable Git repository"
    When  "I run `vclog -f rss`"
    Then  "the exit status should be 0"
    And   'the output should include "Add the frobnicator."'
  end

  Scenario "Git Changelog in YAML" do
    Given "a suitable Git repository"
    When  "I run `vclog -f yaml`"
    Then  "the exit status should be 0"
    And   'the output should include "Add the frobnicator."'
  end

  Scenario "Git Changelog in JSON" do
    Given "a suitable Git repository"
    When  "I run `vclog -f json`"
    Then  "the exit status should be 0"
    And   'the output should include "Add the frobnicator."'
  end

  Scenario "Git Changelog leaves out changes below the level asked for" do
    Given "a suitable Git repository"
    When  "I run `vclog -f gnu`"
    Then  'the output should not include "Update the manual."'
  end

  Scenario "Git Changelog at a lower level" do
    Given "a suitable Git repository"
    When  "I run `vclog -f gnu -l -5`"
    Then  'the output should include "Update the manual."'
    And   'the output should include "Initial commit."'
  end

  include RepoCreation
  include Shellout
end
