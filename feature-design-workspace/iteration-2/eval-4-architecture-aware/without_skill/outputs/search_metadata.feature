Feature: Search Across All Metadata Fields
  As a user
  I want the search to cover all metadata fields of every node
  So that I can find nodes by any attribute, not just the label

  Background:
    Given the following nodes exist:
      | id | label          | metadata                                                        |
      | 1  | Web Frontend   | {"env": "production", "version": "2.4.1", "owner": "alice"}     |
      | 2  | Batch Worker   | {"env": "staging", "version": "1.0.0", "owner": "bob"}          |
      | 3  | Notification   | {"env": "production", "version": "2.4.1", "owner": "charlie"}   |

  Scenario: Search matches a metadata key
    When the user enters the search term "version"
    Then the search results should contain all 3 nodes

  Scenario: Search matches a metadata value
    When the user enters the search term "alice"
    Then the search results should contain the node "Web Frontend"
    And the search results should contain exactly 1 result

  Scenario: Search matches a specific version string
    When the user enters the search term "2.4.1"
    Then the search results should contain the node "Web Frontend"
    And the search results should contain the node "Notification"
    And the search results should contain exactly 2 results

  Scenario: Search matches environment metadata
    When the user enters the search term "staging"
    Then the search results should contain the node "Batch Worker"
    And the search results should contain exactly 1 result

  Scenario: Search spans nested metadata fields
    Given a node "Config Service" exists with metadata:
      """
      {
        "env": "production",
        "deployment": {
          "strategy": "blue-green",
          "region": "eu-west-1"
        }
      }
      """
    When the user enters the search term "blue-green"
    Then the search results should contain the node "Config Service"

  Scenario: Search matches partial metadata values
    When the user enters the search term "prod"
    Then the search results should contain the node "Web Frontend"
    And the search results should contain the node "Notification"
