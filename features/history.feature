Feature: Release History
  As a SCM user
  I want to generate a nicely formatted Release History

  Scenario: SVN History
    Given a SVN repository
    When I generate a History
    Then it should include all tags
    And the list of releases should be in order from newest to oldest

  Scenario: Git History
    Given a Git repository
    When I generate a History
    Then it should include all tags
    And the list of releases should be in order from newest to oldest

