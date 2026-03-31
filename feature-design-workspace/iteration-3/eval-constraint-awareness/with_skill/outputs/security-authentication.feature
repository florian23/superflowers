@critical @security @constraint-SEC-002
Feature: API Authentication and Rate Limiting
  As the system operator
  I want all payment endpoints protected by authentication and rate limiting
  So that only authorized users can access payment data and abuse is prevented

  @smoke
  Scenario: Unauthenticated request to payment endpoint is rejected
    Given a client without valid credentials
    When the client requests payment details
    Then the request is rejected as unauthorized
    And no payment data is included in the response

  Scenario: Authenticated request to payment endpoint succeeds
    Given a client with valid credentials
    When the client requests payment details
    Then the payment details are returned

  Scenario: Health endpoint is accessible without authentication
    Given a client without valid credentials
    When the client requests the health status
    Then the health status is returned successfully

  @critical @constraint-SEC-002
  Scenario Outline: Rate limiting enforced per user
    Given an authenticated user
    When the user sends <request_count> requests within 60 seconds
    Then the first 100 requests are accepted
    And requests beyond 100 are rejected as rate-limited

    Examples:
      | request_count |
      | 101           |
      | 200           |

  @security @constraint-SEC-002
  Scenario: Expired credentials are rejected
    Given a client with expired credentials
    When the client requests payment details
    Then the request is rejected as unauthorized

  @critical @security
  Scenario: SQL injection attempt on payment creation is blocked
    Given an authenticated merchant
    When the merchant submits a payment with malicious input in the cardholder name
    Then the request is rejected with a validation error
    And the payment database remains unaffected
