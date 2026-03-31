@compliance @COMP-001 @gdpr
Feature: GDPR Data Retention
  As a data protection officer
  I want payment data to be automatically deleted after 36 months
  And I want users to be able to request deletion of their data
  So that the Payment Service complies with GDPR requirements

  Constraint: COMP-001 - GDPR Data Retention (Mandatory)
  Requirement: Max. 36 months storage, Right to Erasure

  Background:
    Given the Payment Service is running
    And a valid JWT token for user "user-42"

  @QS-COMP-05
  Scenario: Automatic deletion of payment data older than 36 months
    Given the following payments exist in the database:
      | id | userId | amount | status    | createdAt                |
      | 1  | 42     | 99.99  | COMPLETED | 2022-01-15T10:00:00Z     |
      | 2  | 42     | 50.00  | COMPLETED | 2022-06-20T14:30:00Z     |
      | 3  | 42     | 75.00  | COMPLETED | 2024-12-01T09:00:00Z     |
    When the data retention cleanup job runs
    Then the database should not contain payments with id 1
    And the database should not contain payments with id 2
    And the database should still contain the payment with id 3

  @QS-COMP-05
  Scenario: No payments older than 36 months exist after cleanup
    Given payments exist with creation dates older than 36 months
    When the data retention cleanup job runs
    Then the query "SELECT COUNT(*) FROM payments WHERE created_at < NOW() - INTERVAL '36 months'" should return 0

  @QS-COMP-06
  Scenario: Right to Erasure - delete all PII for a user
    Given the following payments exist for user 42:
      | id | amount | cardNumber       | cardHolder     | iban                     |
      | 1  | 99.99  | 4111111111111111 | Max Mustermann | DE89370400440532013000   |
      | 2  | 50.00  | 4222222222222222 | Max Mustermann |                          |
    When I send a DELETE request to "/api/payments/user/42"
    Then the response status should be 204
    When I query the database for payments of user 42
    Then all card_number fields should be NULL or anonymized
    And all card_holder fields should be NULL or anonymized
    And all iban fields should be NULL or anonymized

  @QS-COMP-06
  Scenario: Right to Erasure generates an audit log entry
    Given a payment exists for user 42
    When I send a DELETE request to "/api/payments/user/42"
    Then the response status should be 204
    When I query the audit log
    Then an audit entry with operation "ERASURE" should exist for user "user-42"
    And the audit entry should not contain any PII

  Scenario: Right to Erasure for non-existent user returns 204
    When I send a DELETE request to "/api/payments/user/99999"
    Then the response status should be 204
