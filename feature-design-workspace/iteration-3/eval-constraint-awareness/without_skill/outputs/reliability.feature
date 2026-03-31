@reliability
Feature: Service Reliability
  As the system operator
  I want the Payment Service to be reliable and resilient
  So that financial transactions are processed correctly even under adverse conditions

  Background:
    Given the Payment Service is running
    And a valid JWT token for user "user-42"

  @QS-REL-01
  Scenario: Idempotent payment creation prevents duplicate charges
    Given I set the header "Idempotency-Key" to "idem-key-001"
    When I send a POST request to "/api/payments" with:
      | userId     | 42                   |
      | amount     | 99.99                |
      | currency   | EUR                  |
      | cardNumber | 4111111111111111     |
      | cardHolder | Max Mustermann       |
      | iban       |                      |
    Then the response status should be 200
    And I store the response payment id as "first-id"
    When I send the same POST request with header "Idempotency-Key" set to "idem-key-001"
    Then the response status should be 200
    And the response payment id should equal "first-id"
    When I query "SELECT COUNT(*) FROM payments WHERE idempotency_key = 'idem-key-001'"
    Then the result should be 1

  @QS-REL-02
  Scenario Outline: Only COMPLETED payments can be refunded
    Given a payment exists with status "<status>"
    When I send a POST request to refund that payment
    Then the response status should be <expectedStatus>
    And the payment status in the database should be "<expectedDbStatus>"

    Examples:
      | status    | expectedStatus | expectedDbStatus |
      | COMPLETED | 200            | REFUNDED         |
      | PENDING   | 409            | PENDING          |
      | REFUNDED  | 409            | REFUNDED         |
      | FAILED    | 409            | FAILED           |

  @QS-REL-03
  Scenario: Health endpoint is available
    When I send a GET request to "/health"
    Then the response status should be 200
    And the response should contain status "UP"

  @QS-REL-04
  Scenario: Graceful degradation when payment provider is down
    Given the external payment provider is unavailable
    When I send a POST request to "/api/payments" with:
      | userId     | 42                   |
      | amount     | 99.99                |
      | currency   | EUR                  |
      | cardNumber | 4111111111111111     |
      | cardHolder | Max Mustermann       |
      | iban       |                      |
    Then the response status should be 503
    And the response should contain a meaningful error message
    And the response time should be less than 5 seconds
    And no payment with status "COMPLETED" should exist in the database

  @QS-REL-04
  Scenario: Service recovers after payment provider comes back online
    Given the external payment provider is unavailable
    When I send a POST request to "/api/payments" with valid data
    Then the response status should be 503
    When the external payment provider becomes available again
    And I send a POST request to "/api/payments" with valid data
    Then the response status should be 200
    And the response status field should be "PENDING"
