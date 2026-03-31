@domain @payment-creation
Feature: Payment Creation
  As an authenticated client
  I want to create payments via the REST API
  So that I can process financial transactions

  Background:
    Given the Payment Service is running
    And a valid JWT token for user "user-42"

  Scenario: Successfully create a payment with card details
    When I send a POST request to "/api/payments" with:
      | userId     | 42                   |
      | amount     | 99.99                |
      | currency   | EUR                  |
      | cardNumber | 4111111111111111     |
      | cardHolder | Max Mustermann       |
      | iban       |                      |
    Then the response status should be 200
    And the response should contain a payment id
    And the response status field should be "PENDING"
    And the response amount should be 99.99

  Scenario: Successfully create a payment with IBAN
    When I send a POST request to "/api/payments" with:
      | userId     | 42                           |
      | amount     | 250.00                       |
      | currency   | EUR                          |
      | cardNumber | 4111111111111111             |
      | cardHolder | Max Mustermann               |
      | iban       | DE89370400440532013000       |
    Then the response status should be 200
    And the response should contain a payment id

  Scenario: Reject payment creation with missing required fields
    When I send a POST request to "/api/payments" with:
      | userId   | 42   |
      | currency | EUR  |
    Then the response status should be 400

  @reliability @QS-REL-01
  Scenario: Idempotent payment creation with Idempotency-Key
    Given I set the header "Idempotency-Key" to "unique-key-12345"
    When I send a POST request to "/api/payments" with:
      | userId     | 42                   |
      | amount     | 99.99                |
      | currency   | EUR                  |
      | cardNumber | 4111111111111111     |
      | cardHolder | Max Mustermann       |
      | iban       |                      |
    Then the response status should be 200
    And I store the response payment id as "first-payment-id"
    When I send the same POST request to "/api/payments" with header "Idempotency-Key" set to "unique-key-12345"
    Then the response status should be 200
    And the response payment id should equal "first-payment-id"
    And the database should contain exactly 1 payment with idempotency key "unique-key-12345"
