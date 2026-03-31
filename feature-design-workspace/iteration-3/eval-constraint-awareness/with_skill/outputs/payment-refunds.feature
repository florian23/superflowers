@critical
Feature: Payment Refunds
  As a merchant
  I want to refund payments
  So that I can return funds to customers when needed

  Background:
    Given an authenticated merchant

  @smoke
  Scenario: Refund a completed payment
    Given a payment with status "COMPLETED"
    When the merchant requests a refund for the payment
    Then the payment status changes to "REFUNDED"

  @critical @constraint-SEC-001
  Scenario: Double refund is rejected
    Given a payment with status "REFUNDED"
    When the merchant requests a refund for the payment
    Then the refund is rejected
    And the payment status remains "REFUNDED"
    And no duplicate credit is issued

  @edge-case
  Scenario: Refund of a non-existent payment is rejected
    Given a payment identifier that does not exist
    When the merchant requests a refund for the payment
    Then the refund is rejected with a not-found error

  @critical
  Scenario: Refund succeeds after transient downstream failure
    Given a payment with status "COMPLETED"
    And the downstream payment gateway is temporarily unavailable
    When the merchant requests a refund for the payment
    Then the system retries the refund operation
    And the refund completes within 3 attempts
    And exactly one refund is processed
