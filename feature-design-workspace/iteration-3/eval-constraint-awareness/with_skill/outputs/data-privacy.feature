@critical @security @constraint-SEC-001
Feature: Data Privacy and PII Protection
  As a data protection officer
  I want personal data protected at all times
  So that we comply with encryption and data protection requirements

  @critical @constraint-SEC-001
  Scenario: Card number is masked in payment responses
    Given an authenticated merchant
    And a payment exists with a stored card number
    When the merchant retrieves the payment details
    Then the card number is masked showing only the last 4 digits
    And the full card number never appears in the response

  @critical @constraint-SEC-001
  Scenario: No personal data appears in application logs
    Given a payment request containing personal data
    When the payment is processed
    Then the application logs contain no plaintext card numbers
    And the application logs contain no plaintext cardholder names
    And the application logs contain no plaintext IBAN values

  @constraint-SEC-001
  Scenario: Encryption keys are managed in a key management service
    Given the payment service configuration
    Then encryption key references point to the key management service
    And no encryption keys are hardcoded in source or configuration files

  @constraint-SEC-001
  Scenario: Persisted payment data is encrypted at rest
    Given the payment database
    Then transparent data encryption is active with AES-256
    And raw database storage contains no plaintext personal data
