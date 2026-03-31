Feature: Cancel Payment
  As a user
  I want to cancel a pending payment
  So that the payment is not processed

  Background:
    Given a payment exists with id 1 and status "pending" and amount 99.99

  @critical
  Scenario: Successfully cancel a pending payment
    When the payment with id 1 is cancelled
    Then the cancellation is successful
    And the response contains the payment id 1
    And the payment status is "cancelled"
    And the response contains the cancellation timestamp
    And the response contains the payment amount 99.99

  @critical
  Scenario: Cancelling a non-pending payment is rejected
    Given a payment exists with id 2 and status "completed" and amount 50.00
    When the payment with id 2 is cancelled
    Then the cancellation is rejected with a conflict error
    And the error message indicates that only pending payments can be cancelled

  @edge-case
  Scenario Outline: Cancelling a payment in non-pending status is rejected
    Given a payment exists with id 3 and status "<status>" and amount 25.00
    When the payment with id 3 is cancelled
    Then the cancellation is rejected with a conflict error

    Examples:
      | status   |
      | failed   |
      | refunded |
      | cancelled|

  @critical
  Scenario: Cancelling a non-existent payment returns not found
    When the payment with id 999 is cancelled
    Then the payment is not found

  @critical
  Scenario: Cancellation is persisted
    When the payment with id 1 is cancelled
    And the payment with id 1 is retrieved
    Then the payment status is "cancelled"

  @critical @constraint-SEC-002
  Scenario: Unauthenticated cancellation request is denied
    Given the user is not authenticated
    When the payment with id 1 is cancelled
    Then access is denied

  @critical @constraint-COMP-002
  Scenario: Cancellation is recorded in the audit log
    When the payment with id 1 is cancelled
    Then the cancellation event is recorded in the audit log
