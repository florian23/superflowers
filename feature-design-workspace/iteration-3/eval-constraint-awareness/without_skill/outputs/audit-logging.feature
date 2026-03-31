@compliance @COMP-002 @QS-COMP-01
Feature: Audit Logging
  As a compliance officer
  I want all write operations to be recorded in an immutable audit log
  So that there is a complete, tamper-proof trail of all payment activities

  Constraint: COMP-002 - Audit Logging (Mandatory)
  Requirement: Immutable audit log for all write operations

  Background:
    Given the Payment Service is running
    And a valid JWT token for user "user-42"

  @QS-COMP-01
  Scenario: Audit log entry is created for payment creation
    When I send a POST request to "/api/payments" with:
      | userId     | 42                   |
      | amount     | 99.99                |
      | currency   | EUR                  |
      | cardNumber | 4111111111111111     |
      | cardHolder | Max Mustermann       |
      | iban       |                      |
    Then the response status should be 200
    And I store the response payment id as "created-payment-id"
    When I query the audit log for payment "created-payment-id"
    Then exactly 1 audit entry should exist
    And the audit entry should contain operation "CREATE"
    And the audit entry should contain the user id "user-42"
    And the audit entry timestamp should be within 1 second of the request time

  @QS-COMP-02
  Scenario: Audit log entry is created for refund
    Given a payment exists with id "1" for user 42 with amount 99.99 and status "COMPLETED"
    When I send a POST request to "/api/payments/1/refund"
    Then the response status should be 200
    When I query the audit log for payment "1"
    Then an audit entry with operation "REFUND" should exist
    And the audit entry should contain the user id "user-42"

  @QS-COMP-03
  Scenario: No PII in audit log entries
    When I send a POST request to "/api/payments" with:
      | userId     | 42                           |
      | amount     | 99.99                        |
      | currency   | EUR                          |
      | cardNumber | 4111111111111111             |
      | cardHolder | Max Mustermann               |
      | iban       | DE89370400440532013000       |
    Then the response status should be 200
    When I scan all audit log entries
    Then no audit entry should match the pattern "\b\d{13,19}\b"
    And no audit entry should match the pattern "\b[A-Z]{2}\d{2}[A-Z0-9]{11,30}\b"
    And no audit entry should contain "Max Mustermann"
    And no audit entry should contain "4111111111111111"
    And no audit entry should contain "DE89370400440532013000"

  @QS-COMP-04
  Scenario: Audit log entries cannot be modified
    Given a payment exists with id "1" for user 42 with amount 99.99 and status "COMPLETED"
    And an audit log entry exists for payment "1"
    When I attempt to UPDATE the audit log entry for payment "1"
    Then the database operation should fail
    And the original audit entry should remain unchanged

  @QS-COMP-04
  Scenario: Audit log entries cannot be deleted
    Given a payment exists with id "1" for user 42 with amount 99.99 and status "COMPLETED"
    And an audit log entry exists for payment "1"
    When I attempt to DELETE the audit log entry for payment "1"
    Then the database operation should fail
    And the audit log should still contain the entry for payment "1"
