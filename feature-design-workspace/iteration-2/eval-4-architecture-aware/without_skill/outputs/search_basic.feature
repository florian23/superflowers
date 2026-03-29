Feature: Basic Search
  As a user
  I want to enter a search term and find matching nodes
  So that I can quickly locate relevant information in the system

  Background:
    Given the following nodes exist:
      | id | label            | metadata                              |
      | 1  | Database Server  | {"env": "production", "team": "infra"} |
      | 2  | API Gateway      | {"env": "staging", "team": "platform"} |
      | 3  | Auth Service     | {"env": "production", "team": "security"} |
      | 4  | Cache Layer      | {"env": "production", "team": "infra"} |

  Scenario: Search by node label
    When the user enters the search term "Gateway"
    Then the search results should contain the node "API Gateway"
    And the search results should not contain the node "Database Server"

  Scenario: Search by metadata value
    When the user enters the search term "security"
    Then the search results should contain the node "Auth Service"
    And the search results should contain exactly 1 result

  Scenario: Search matches across labels and metadata
    When the user enters the search term "infra"
    Then the search results should contain the node "Database Server"
    And the search results should contain the node "Cache Layer"
    And the search results should contain exactly 2 results

  Scenario: Search is case-insensitive
    When the user enters the search term "database"
    Then the search results should contain the node "Database Server"

  Scenario: Search with no matches
    When the user enters the search term "nonexistent"
    Then the search results should be empty
    And a message "No results found" should be displayed

  Scenario: Empty search term
    When the user enters an empty search term
    Then no search is performed
    And no results are displayed
