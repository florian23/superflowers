# Gherkin Quick Reference

## Keywords

| Keyword | Purpose |
|---------|---------|
| `Feature:` | Top-level description of a capability |
| `Scenario:` | A concrete example of behavior |
| `Given` | Precondition / initial context |
| `When` | Action or event |
| `Then` | Expected outcome |
| `And` / `But` | Additional steps (same type as preceding) |
| `Background:` | Shared Given steps for all scenarios in a feature |
| `Scenario Outline:` | Template with placeholder variables |
| `Examples:` | Data table for Scenario Outline |
| `Rule:` | Group scenarios under a business rule |

## Syntax Examples

### Basic Scenario

```gherkin
Feature: User Authentication
  Users can log in with email and password

  Scenario: Successful login
    Given a registered user with email "user@example.com"
    When the user logs in with the correct password
    Then they are redirected to the dashboard
    And a welcome message is displayed
```

### Background

```gherkin
Feature: Shopping Cart
  Background:
    Given a logged-in customer
    And an empty shopping cart

  Scenario: Add item to cart
    When the customer adds "Blue T-Shirt" to the cart
    Then the cart contains 1 item

  Scenario: Remove item from cart
    Given the cart contains "Blue T-Shirt"
    When the customer removes "Blue T-Shirt"
    Then the cart is empty
```

### Scenario Outline with Examples

```gherkin
Scenario Outline: Login validation
  Given a user with email "<email>" and password "<password>"
  When the user attempts to log in
  Then the result is "<outcome>"

  Examples:
    | email            | password  | outcome         |
    | valid@test.com   | correct   | success         |
    | valid@test.com   | wrong     | invalid password|
    | unknown@test.com | any       | user not found  |
    |                  | any       | email required  |
```

### Data Tables

```gherkin
Scenario: Bulk order creation
  Given the following products exist:
    | name         | price | stock |
    | Blue T-Shirt | 29.99 | 100   |
    | Red Hat      | 19.99 | 50    |
  When the customer orders:
    | product      | quantity |
    | Blue T-Shirt | 2        |
    | Red Hat      | 1        |
  Then the order total is 79.97
```

### Doc Strings

```gherkin
Scenario: API error response
  Given the API is unavailable
  When the client sends a request
  Then the response body is:
    """json
    {
      "error": "service_unavailable",
      "message": "Please try again later"
    }
    """
```

### Rules

```gherkin
Feature: Account Lockout

  Rule: Account is locked after 3 failed attempts

    Scenario: First failed attempt
      Given 0 previous failed attempts
      When the user enters wrong credentials
      Then the account is not locked
      And the failed attempt count is 1

    Scenario: Third failed attempt locks account
      Given 2 previous failed attempts
      When the user enters wrong credentials
      Then the account is locked
      And a notification email is sent
```

## Tags

```gherkin
@smoke @critical
Feature: Payment Processing

  @happy-path
  Scenario: Successful payment
    ...

  @edge-case
  Scenario: Payment with expired card
    ...

  @wip
  Scenario: Refund processing
    ...
```

Common tag conventions:
- `@smoke` — quick verification tests
- `@critical` — must-pass for release
- `@wip` — work in progress, may be incomplete
- `@edge-case` — boundary and error conditions
- `@slow` — long-running scenarios
- `@manual` — requires manual verification

## Anti-Patterns

### Incidental Details (BAD)
```gherkin
# BAD — too coupled to implementation
Scenario: Login
  Given I am on the page "/login"
  When I fill in "#email" with "user@test.com"
  And I fill in "#password" with "secret"
  And I click the button "Submit"
  And I wait 2 seconds
  Then I should see the text "Welcome"
```

### Declarative Style (GOOD)
```gherkin
# GOOD — describes behavior, not UI interaction
Scenario: Successful login
  Given a registered user
  When the user logs in with valid credentials
  Then they see their dashboard
```

### Too Many Steps (BAD)
If a scenario has more than 7 steps, it's testing too much. Split into multiple scenarios.

### Conjunctive Scenarios (BAD)
```gherkin
# BAD — tests two behaviors
Scenario: Add and remove item
  When I add an item
  Then the cart has 1 item
  When I remove the item
  Then the cart is empty
```

Split into two separate scenarios.

### Testing Implementation (BAD)
```gherkin
# BAD — describes implementation, not behavior
Scenario: Save to database
  When the user submits the form
  Then a row is inserted into the users table
  And the password is hashed with bcrypt
```

### Testing Behavior (GOOD)
```gherkin
# GOOD — describes observable behavior
Scenario: User registration
  When a new user registers
  Then their account is created
  And they can log in with their credentials
```
