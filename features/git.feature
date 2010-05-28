Feature: Git Support
  As a SCM user
  I want to generate a nicely formatted Release History

  Scenario: Git Changelog
    Given a suitable Git repository
    When I run "vclog"
    Then the exit status should be 0

  Scenario: Git Changelog in YAML
    Given a suitable Git repository
    When I run "vclog -f yaml"
    Then the exit status should be 0

  Scenario: Git Changelog in JSON
    Given a suitable Git repository
    When I run "vclog -f json"
    Then the exit status should be 0

  Scenario: Git Changelog in HTML
    Given a suitable Git repository
    When I run "vclog -f html"
    Then the exit status should be 0

  Scenario: Git Changelog in XML
    Given a suitable Git repository
    When I run "vclog -f xml"
    Then the exit status should be 0

  Scenario: Git Changelog in JSON
    Given a suitable Git repository
    When I run "vclog -f rdoc"
    Then the exit status should be 0

  Scenario: Git Changelog in JSON
    Given a suitable Git repository
    When I run "vclog -f markdown"
    Then the exit status should be 0


  Scenario: Git Release History
    Given a suitable Git repository
    When I run "vclog -r"
    Then the exit status should be 0

  Scenario: Git Release History in YAML
    Given a suitable Git repository
    When I run "vclog -r -f yaml"
    Then the exit status should be 0

  Scenario: Git Release History in JSON
    Given a suitable Git repository
    When I run "vclog -r -f json"
    Then the exit status should be 0

  Scenario: Git Release History in HTML
    Given a suitable Git repository
    When I run "vclog -r -f html"
    Then the exit status should be 0

  Scenario: Git Release History in XML
    Given a suitable Git repository
    When I run "vclog -r -f xml"
    Then the exit status should be 0

  Scenario: Git Release History in JSON
    Given a suitable Git repository
    When I run "vclog -r -f rdoc"
    Then the exit status should be 0

  Scenario: Git Release History in JSON
    Given a suitable Git repository
    When I run "vclog -r -f markdown"
    Then the exit status should be 0

