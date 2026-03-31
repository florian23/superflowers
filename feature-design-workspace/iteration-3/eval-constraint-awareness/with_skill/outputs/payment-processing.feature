@critical
Feature: Payment Processing
  As a merchant
  I want to create and retrieve payments
  So that I can process financial transactions for my customers

  Background:
    Given an authenticated merchant

  @smoke
  Scenario: Create a payment successfully
    Given a valid payment request with amount 99.99 EUR
    When the merchant submits the payment
    Then the payment is created with status "COMPLETED"
    And the payment amount is 99.99 EUR

  Scenario: Retrieve a payment by identifier
    Given a previously created payment
    When the merchant requests the payment details
    Then the payment details are returned
    And the payment amount and status are included

  Scenario: List all payments for a user
    Given 3 previously created payments for a user
    When the merchant requests the payment list for that user
    Then exactly 3 payments are returned

  @critical
  Scenario: Concurrent payment creation produces no duplicates or lost transactions
    Given 50 valid payment requests with unique idempotency keys
    When all 50 payments are submitted simultaneously
    Then exactly 50 payment records exist
    And each payment has the correct amount and status
    And no duplicate idempotency keys exist

  @edge-case
  Scenario: Payment creation with missing required fields is rejected
    Given a payment request without an amount
    When the merchant submits the payment
    Then the payment is rejected with a validation error

  @edge-case
  Scenario: Payment creation with negative amount is rejected
    Given a payment request with amount -50.00 EUR
    When the merchant submits the payment
    Then the payment is rejected with a validation error
