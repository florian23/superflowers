@security @SEC-001 @QS-SEC-02
Feature: Encryption at Rest
  As a security auditor
  I want all PII data to be AES-256 encrypted in the database
  So that sensitive payment data is protected even if the database is compromised

  Constraint: SEC-001 - Encryption at Rest (Mandatory)
  Requirement: All persisted data must be AES-256 encrypted

  Background:
    Given the Payment Service is running
    And a valid JWT token for user "user-42"

  @QS-SEC-02
  Scenario: PII fields are encrypted in the database
    When I send a POST request to "/api/payments" with:
      | userId     | 42                           |
      | amount     | 99.99                        |
      | currency   | EUR                          |
      | cardNumber | 4111111111111111             |
      | cardHolder | Max Mustermann               |
      | iban       | DE89370400440532013000       |
    Then the response status should be 200
    When I query the database directly for the created payment
    Then the card_number column should not match the pattern "^\d{13,19}$"
    And the card_holder column should not contain "Max Mustermann"
    And the iban column should not match the pattern "^[A-Z]{2}\d{2}[A-Z0-9]{11,30}$"

  @QS-SEC-03
  Scenario: No PII in plaintext in application logs
    When I send a POST request to "/api/payments" with:
      | userId     | 42                           |
      | amount     | 99.99                        |
      | currency   | EUR                          |
      | cardNumber | 4111111111111111             |
      | cardHolder | Max Mustermann               |
      | iban       | DE89370400440532013000       |
    Then the response status should be 200
    When I scan the application logs
    Then no log entry should match the pattern "\b\d{13,19}\b"
    And no log entry should match the pattern "\b[A-Z]{2}\d{2}[A-Z0-9]{11,30}\b"
    And no log entry should contain "Max Mustermann"

  @QS-SEC-04
  Scenario: Encryption keys are not hardcoded in the codebase
    When I scan all source code and configuration files
    Then no file should contain a Base64-encoded key of 32 bytes or more
    And no configuration file should contain a plaintext password for encryption
    And encryption key references should point to an external KMS
