@critical
Feature: Resilience and Recoverability
  As a system operator
  I want the payment service to handle failures gracefully
  So that no payment data is lost and the service recovers automatically

  @critical
  Scenario: No orphaned payment state on database failure during creation
    Given a payment creation is in progress
    When the database connection drops before the transaction commits
    Then the transaction is rolled back
    And no partial or incomplete payment record is persisted
    And the client receives an error response

  @critical
  Scenario: Pending payments resume after application restart
    Given 10 payments are in pending status
    When the application crashes and restarts
    Then all pending payments are resolved within 5 minutes
    And each payment reaches a terminal status of completed or failed
    And no payments remain stuck in pending status

  Scenario: Service recovers automatically after database outage
    Given the database becomes unreachable
    When the database becomes available again
    Then the service recovers automatically without manual restart
    And the health status returns to healthy within 60 seconds

  Scenario: Service reports unhealthy during database outage
    Given the database becomes unreachable
    When a client checks the health status
    Then the service reports an unhealthy status

  @edge-case
  Scenario: Concurrent requests during partial failure
    Given the database is intermittently available
    When multiple payment requests are submitted
    Then successful requests produce valid payment records
    And failed requests return error responses
    And no data corruption occurs
