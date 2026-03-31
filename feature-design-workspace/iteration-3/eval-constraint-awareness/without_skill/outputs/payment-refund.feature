@domain @payment-refund
Feature: Payment Refund
  As an authenticated client
  I want to refund completed payments
  So that customers can receive their money back when needed

  Background:
    Given the Payment Service is running
    And a valid JWT token for user "user-42"

  Scenario: Successfully refund a completed payment
    Given a payment exists with id "1" for user 42 with amount 99.99 and status "COMPLETED"
    When I send a POST request to "/api/payments/1/refund"
    Then the response status should be 200
    And the response status field should be "REFUNDED"
    And the response amount should be 99.99

  @reliability @QS-REL-02
  Scenario: Reject refund on a pending payment
    Given a payment exists with id "2" for user 42 with amount 50.00 and status "PENDING"
    When I send a POST request to "/api/payments/2/refund"
    Then the response status should be 409
    And the payment with id "2" should still have status "PENDING"

  @reliability @QS-REL-02
  Scenario: Reject refund on an already refunded payment
    Given a payment exists with id "3" for user 42 with amount 75.00 and status "REFUNDED"
    When I send a POST request to "/api/payments/3/refund"
    Then the response status should be 409
    And the payment with id "3" should still have status "REFUNDED"

  Scenario: Return 404 when refunding a non-existent payment
    When I send a POST request to "/api/payments/999999/refund"
    Then the response status should be 404

  @reliability @QS-REL-04
  Scenario: Graceful degradation when external payment provider is unavailable
    Given a payment exists with id "4" for user 42 with amount 100.00 and status "COMPLETED"
    And the external payment provider is unavailable
    When I send a POST request to "/api/payments/4/refund"
    Then the response status should be 503
    And the response should contain an error message indicating provider unavailability
    And the response time should be less than 5 seconds
    And the payment with id "4" should still have status "COMPLETED"
