Feature: Instant Search Results
  As a user
  I want search results to appear immediately as I type
  So that I can find information without waiting

  # Architecture constraint: API responses must be < 200ms at p95.
  # This means the search endpoint must return results well within that budget.

  Scenario: Results appear as the user types
    Given nodes with labels "Performance Monitor" and "Permission Service" exist
    When the user types "Perm" into the search field
    Then search results should be displayed before the user submits the form
    And the results should contain the node "Permission Service"

  Scenario: Results update on each keystroke
    Given nodes with labels "Logger" and "Load Balancer" exist
    When the user types "Lo" into the search field
    Then the results should contain the node "Logger"
    And the results should contain the node "Load Balancer"
    When the user continues typing "Log"
    Then the results should contain the node "Logger"
    And the results should not contain the node "Load Balancer"

  Scenario: Search responds within the performance budget
    Given 1000 nodes exist in the system
    When the user enters the search term "test"
    Then the search API should respond in less than 200 milliseconds at p95

  Scenario: Input debouncing avoids excessive requests
    When the user types "search" rapidly into the search field
    Then the number of API requests should be fewer than the number of keystrokes
