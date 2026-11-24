Feature "Git Release History Support" do
  As "Git users"
  We "want to generate nicely formatted release histories"

  Scenario "Git Release History" do
    Given "a suitable Git repository"
    When  "I run `vclog -r`"
    Then  "the exit status should be 0"
    And   'the output should include "Add the frobnicator."'
  end

  Scenario "Git Release History in RDoc" do
    Given "a suitable Git repository"
    When  "I run `vclog -r -f rdoc`"
    Then  "the exit status should be 0"
    And   'the output should include "Add the frobnicator."'
  end

  Scenario "Git Release History in Markdown" do
    Given "a suitable Git repository"
    When  "I run `vclog -r -f markdown`"
    Then  "the exit status should be 0"
    And   'the output should include "Add the frobnicator."'
  end

  Scenario "Git Release History in GNU style" do
    Given "a suitable Git repository"
    When  "I run `vclog -r -f gnu`"
    Then  "the exit status should be 0"
    And   'the output should include "Add the frobnicator."'
  end

  Scenario "Git Release History in HTML" do
    Given "a suitable Git repository"
    When  "I run `vclog -r -f html`"
    Then  "the exit status should be 0"
    And   'the output should include "Add the frobnicator."'
  end

  Scenario "Git Release History in XML" do
    Given "a suitable Git repository"
    When  "I run `vclog -r -f xml`"
    Then  "the exit status should be 0"
    And   'the output should include "Add the frobnicator."'
  end

  Scenario "Git Release History in Atom" do
    Given "a suitable Git repository"
    When  "I run `vclog -r -f atom`"
    Then  "the exit status should be 0"
    And   'the output should include "Add the frobnicator."'
  end

  Scenario "Git Release History in RSS" do
    Given "a suitable Git repository"
    When  "I run `vclog -r -f rss`"
    Then  "the exit status should be 0"
    And   'the output should include "Add the frobnicator."'
  end

  Scenario "Git Release History in YAML" do
    Given "a suitable Git repository"
    When  "I run `vclog -r -f yaml`"
    Then  "the exit status should be 0"
    And   'the output should include "Add the frobnicator."'
  end

  Scenario "Git Release History in JSON" do
    Given "a suitable Git repository"
    When  "I run `vclog -r -f json`"
    Then  "the exit status should be 0"
    And   'the output should include "Add the frobnicator."'
  end

  Scenario "Git Release History names each release" do
    Given "a suitable Git repository"
    When  "I run `vclog -r -f markdown`"
    Then  'the output should include "## 0.1.0 / 2020-01-02"'
    And   'the output should include "## 0.2.0 / 2020-01-04"'
    And   'the output should include "## 0.10.0 / 2020-01-07"'
    And   'the output should include "The first release."'
  end

  include RepoCreation
  include Shellout
end
