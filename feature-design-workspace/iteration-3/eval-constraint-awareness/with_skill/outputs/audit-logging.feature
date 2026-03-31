@critical @compliance @constraint-COMP-002
Feature: Audit Logging
  As a compliance officer
  I want all write operations recorded in an immutable audit log
  So that we can trace every change to payment data for regulatory purposes

  @critical @constraint-COMP-002
  Scenario: Payment creation produces an audit log entry
    Given an authenticated merchant
    When the merchant creates a payment
    Then an audit log entry is created for the payment creation
    And the audit entry contains the timestamp, user, action, and payment identifier
    And the audit entry cannot be modified or deleted

  @critical @constraint-COMP-002
  Scenario: Payment refund produces an audit log entry
    Given an authenticated merchant
    And a payment with status "COMPLETED"
    When the merchant refunds the payment
    Then an audit log entry is created for the refund
    And the audit entry contains the timestamp, user, action, and payment identifier
    And the audit entry cannot be modified or deleted

  @critical @constraint-COMP-002
  Scenario: Audit log entries contain no personal data
    Given a payment creation involving card number, cardholder name, and IBAN
    When the audit log entry is created
    Then the audit entry contains no plaintext card numbers
    And the audit entry contains no plaintext cardholder names
    And the audit entry contains no plaintext IBAN values

  @constraint-COMP-002
  Scenario: Data erasure operation produces an audit log entry
    Given a user requests erasure of their personal data
    When the erasure is completed
    Then an audit log entry is created for the data erasure
    And the audit entry records which user's data was erased

  @edge-case @constraint-COMP-002
  Scenario: Audit log count matches write operation count
    Given 10 payment creations and 3 refunds have been processed
    Then the audit log contains exactly 13 entries for those operations
