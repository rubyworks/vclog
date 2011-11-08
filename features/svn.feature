Feature: Subversion Support
  As a Subversion user
  I want to generate a nicely formatted Changelog
  And I want to generate a nicely formatted Release History

  Scenario: Subversion Changelog
    Given a suitable Subversion repository
    When I run `vclog`
    Then the exit status should be 0

  Scenario: Subversion Changelog in RDoc
    Given a suitable Subversion repository
    When I run `vclog -f rdoc`
    Then the exit status should be 0

  Scenario: Subversion Changelog in Markdown
    Given a suitable Subversion repository
    When I run `vclog -f markdown`
    Then the exit status should be 0

  Scenario: Subversion Changelog in HTML
    Given a suitable Subversion repository
    When I run `vclog -f html`
    Then the exit status should be 0

  Scenario: Subversion Changelog in XML
    Given a suitable Subversion repository
    When I run `vclog -f xml`
    Then the exit status should be 0

  Scenario: Subversion Changelog in Atom
    Given a suitable Subversion repository
    When I run `vclog -f atom`
    Then the exit status should be 0

  Scenario: Subversion Changelog in YAML
    Given a suitable Subversion repository
    When I run `vclog -f yaml`
    Then the exit status should be 0

  Scenario: Subversion Changelog in JSON
    Given a suitable Subversion repository
    When I run `vclog -f json`
    Then the exit status should be 0


  Scenario: Subversion Release History
    Given a suitable Subversion repository
    When I run `vclog rel`
    Then the exit status should be 0

  Scenario: Subversion Release History in RDoc
    Given a suitable Subversion repository
    When I run `vclog rel -f rdoc`
    Then the exit status should be 0

  Scenario: Subversion Release History in Markdown
    Given a suitable Subversion repository
    When I run `vclog rel -f markdown`
    Then the exit status should be 0

  Scenario: Subversion Release History in HTML
    Given a suitable Subversion repository
    When I run `vclog rel -f html`
    Then the exit status should be 0

  Scenario: Subversion Release History in XML
    Given a suitable Subversion repository
    When I run `vclog rel -f xml`
    Then the exit status should be 0

  Scenario: Subversion Release History in Atom
    Given a suitable Subversion repository
    When I run `vclog rel -f atom`
    Then the exit status should be 0

  Scenario: Subversion Release History in YAML
    Given a suitable Subversion repository
    When I run `vclog rel -f yaml`
    Then the exit status should be 0

  Scenario: Subversion Release History in JSON
    Given a suitable Subversion repository
    When I run `vclog rel -f json`
    Then the exit status should be 0

