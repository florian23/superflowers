@critical @compliance @constraint-COMP-001
Feature: GDPR Data Retention and Right to Erasure
  As a data subject
  I want my personal data deleted when no longer needed or upon my request
  So that my privacy rights under GDPR are respected

  @critical @constraint-COMP-001
  Scenario: Automated deletion of payment data older than 36 months
    Given payment records that are older than 36 months
    When the automated data retention job runs
    Then all payment records older than 36 months are deleted
    And no personal data from those records remains in the system
    And the deletion is recorded in the audit log

  @critical @constraint-COMP-001
  Scenario: Payment data within retention period is preserved
    Given payment records that are less than 36 months old
    When the automated data retention job runs
    Then those payment records remain unchanged

  @critical @constraint-COMP-001
  Scenario: Right to erasure deletes all personal data for a user
    Given a user with 5 stored payments containing personal data
    When the user requests erasure of their personal data
    Then all card numbers for that user are deleted or anonymized
    And all cardholder names for that user are deleted or anonymized
    And all IBAN values for that user are deleted or anonymized
    And the erasure is recorded in the audit log

  @edge-case @constraint-COMP-001
  Scenario: Right to erasure for a user with no data
    Given a user with no stored payments
    When the user requests erasure of their personal data
    Then the request completes successfully
    And no error is returned

  @constraint-COMP-001
  Scenario: Deleted data is not recoverable through any endpoint
    Given a user whose personal data has been erased
    When someone requests payment details for that user
    Then no personal data is returned
    And payment records appear anonymized
