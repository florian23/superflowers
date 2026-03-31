@security @SEC-002 @QS-SEC-01
Feature: API Authentication
  As the system operator
  I want all business endpoints to require JWT authentication
  So that only authorized clients can access the Payment Service

  Constraint: SEC-002 - API Authentication (Mandatory)
  Requirement: OAuth 2.0 / JWT for all endpoints

  Background:
    Given the Payment Service is running

  Scenario: Health endpoint is accessible without authentication
    When I send a GET request to "/health" without a JWT token
    Then the response status should be 200

  Scenario Outline: Business endpoints reject unauthenticated requests
    When I send a <method> request to "<endpoint>" without a JWT token
    Then the response status should be 401
    And the response should not contain any business data

    Examples:
      | method | endpoint                  |
      | POST   | /api/payments             |
      | GET    | /api/payments/1           |
      | GET    | /api/payments?userId=42   |
      | POST   | /api/payments/1/refund    |

  Scenario: Reject requests with an expired JWT token
    Given a JWT token that expired 1 hour ago
    When I send a GET request to "/api/payments?userId=42" with the expired token
    Then the response status should be 401

  Scenario: Reject requests with an invalid JWT signature
    Given a JWT token signed with an invalid key
    When I send a GET request to "/api/payments?userId=42" with the invalid token
    Then the response status should be 401

  @QS-SEC-05
  Scenario: Rate limiting per user
    Given a valid JWT token for user "user-42"
    When I send 100 POST requests to "/api/payments" within 10 seconds
    Then at least the last requests should return status 429
    And the response should contain a "Retry-After" header
