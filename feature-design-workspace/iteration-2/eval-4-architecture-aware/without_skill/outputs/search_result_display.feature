Feature: Search Result Display
  As a user
  I want search results to clearly show why each node matched
  So that I can evaluate results quickly

  Background:
    Given the following nodes exist:
      | id | label         | metadata                                          |
      | 1  | API Gateway   | {"env": "production", "team": "platform"}         |
      | 2  | Auth Service  | {"env": "production", "team": "security"}         |

  Scenario: Results display the node label
    When the user enters the search term "API"
    Then each result should display the node label
    And the first result should show the label "API Gateway"

  Scenario: Matching text is highlighted in results
    When the user enters the search term "platform"
    Then the result for "API Gateway" should highlight "platform" in the metadata

  Scenario: Results show which field matched
    When the user enters the search term "security"
    Then the result for "Auth Service" should indicate the match was in the "team" metadata field

  Scenario: Results are ordered by relevance
    Given a node "Production Dashboard" exists with metadata '{"env": "staging"}'
    When the user enters the search term "production"
    Then the node "Production Dashboard" should appear before "API Gateway"
    Because a label match ranks higher than a metadata match

  Scenario: Result count is displayed
    When the user enters the search term "production"
    Then the result count should be displayed as "3 results"
