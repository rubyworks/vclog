Feature: Subversion Support
  As a SCM user
  I want to generate a nicely formatted Release History

  Scenario: Subversion Changelog
    Given a suitable Subversion repository
    When I run "vclog"
    Then the exit status should be 0

  Scenario: Subversion Changelog in YAML
    Given a suitable Subversion repository
    When I run "vclog -f yaml"
    Then the exit status should be 0

  Scenario: Subversion Changelog in JSON
    Given a suitable Subversion repository
    When I run "vclog -f json"
    Then the exit status should be 0

  Scenario: Subversion Changelog in HTML
    Given a suitable Subversion repository
    When I run "vclog -f html"
    Then the exit status should be 0

  Scenario: Subversion Changelog in XML
    Given a suitable Subversion repository
    When I run "vclog -f xml"
    Then the exit status should be 0

  Scenario: Subversion Changelog in JSON
    Given a suitable Subversion repository
    When I run "vclog -f rdoc"
    Then the exit status should be 0

  Scenario: Subversion Changelog in JSON
    Given a suitable Subversion repository
    When I run "vclog -f markdown"
    Then the exit status should be 0


  Scenario: Subversion Release History
    Given a suitable Subversion repository
    When I run "vclog -r"
    Then the exit status should be 0

  Scenario: Subversion Release History in YAML
    Given a suitable Subversion repository
    When I run "vclog -r -f yaml"
    Then the exit status should be 0

  Scenario: Subversion Release History in JSON
    Given a suitable Subversion repository
    When I run "vclog -r -f json"
    Then the exit status should be 0

  Scenario: Subversion Release History in HTML
    Given a suitable Subversion repository
    When I run "vclog -r -f html"
    Then the exit status should be 0

  Scenario: Subversion Release History in XML
    Given a suitable Subversion repository
    When I run "vclog -r -f xml"
    Then the exit status should be 0

  Scenario: Subversion Release History in JSON
    Given a suitable Subversion repository
    When I run "vclog -r -f rdoc"
    Then the exit status should be 0

  Scenario: Subversion Release History in JSON
    Given a suitable Subversion repository
    When I run "vclog -r -f markdown"
    Then the exit status should be 0

