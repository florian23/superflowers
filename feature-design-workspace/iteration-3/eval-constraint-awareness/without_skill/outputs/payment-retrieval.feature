@domain @payment-retrieval
Feature: Payment Retrieval
  As an authenticated client
  I want to retrieve payment details
  So that I can check the status and details of transactions

  Background:
    Given the Payment Service is running
    And a valid JWT token for user "user-42"
    And a payment exists with id "1" for user 42 with amount 99.99 and status "COMPLETED"

  Scenario: Retrieve a single payment by ID
    When I send a GET request to "/api/payments/1"
    Then the response status should be 200
    And the response should contain a payment with id 1
    And the response amount should be 99.99
    And the response status field should be "COMPLETED"

  Scenario: Return 404 for non-existent payment
    When I send a GET request to "/api/payments/999999"
    Then the response status should be 404

  Scenario: List payments for a user
    Given a payment exists with id "2" for user 42 with amount 50.00 and status "PENDING"
    When I send a GET request to "/api/payments?userId=42"
    Then the response status should be 200
    And the response should contain 2 payments
    And all returned payments should belong to user 42

  Scenario: Return empty list for user with no payments
    When I send a GET request to "/api/payments?userId=99999"
    Then the response status should be 200
    And the response should contain 0 payments
