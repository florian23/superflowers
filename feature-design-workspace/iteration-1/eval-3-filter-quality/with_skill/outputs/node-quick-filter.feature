@critical
Feature: Node Quick Filter
  Users can filter nodes by label using a text field in the toolbar.
  Non-matching nodes are greyed out while matching nodes remain fully visible.

  Background:
    Given a graph with the following nodes:
      | label          |
      | User Service   |
      | User Database  |
      | Order Service  |
      | Order Database |
      | Payment Gateway|

  Rule: Typing in the filter greys out non-matching nodes

    @smoke
    Scenario: Filter matches a subset of nodes
      When the user types "User" in the quick filter
      Then the nodes with "User" in their label are displayed normally
      And the nodes without "User" in their label are greyed out

    Scenario: Filter matches all nodes
      When the user types "e" in the quick filter
      Then all nodes are displayed normally
      And no nodes are greyed out

    @edge-case
    Scenario: Filter matches no nodes
      When the user types "Nonexistent" in the quick filter
      Then all nodes are greyed out

  Rule: Clearing the filter restores all nodes

    @smoke
    Scenario: Emptying the filter restores normal display
      Given the user has typed "User" in the quick filter
      And some nodes are greyed out
      When the user clears the quick filter
      Then all nodes are displayed normally
      And no nodes are greyed out

    Scenario: Filter is empty on initial load
      When the graph is displayed
      Then the quick filter field is empty
      And all nodes are displayed normally

  Rule: Filtering is case-insensitive

    Scenario Outline: Filter ignores case when matching labels
      When the user types "<filter_text>" in the quick filter
      Then the nodes with "User" in their label are displayed normally
      And the nodes without "User" in their label are greyed out

      Examples:
        | filter_text |
        | user        |
        | USER        |
        | uSeR        |

  Rule: Filtering happens as the user types

    Scenario: Partial input filters immediately
      When the user types "Or" in the quick filter
      Then the nodes with "Or" in their label are displayed normally
      And the nodes without "Or" in their label are greyed out

    Scenario: Extending the filter narrows the results further
      Given the user has typed "O" in the quick filter
      When the user extends the filter to "Order"
      Then the nodes with "Order" in their label are displayed normally
      And the nodes without "Order" in their label are greyed out

  Rule: Filter is located in the toolbar

    Scenario: Quick filter field is present in the toolbar
      When the user views the toolbar
      Then a quick filter text field is visible in the toolbar

  Rule: Partial matches are supported

    @edge-case
    Scenario: Filter matches partial label text
      When the user types "Data" in the quick filter
      Then the nodes with "Data" in their label are displayed normally
      And the nodes without "Data" in their label are greyed out

    @edge-case
    Scenario: Filter with only whitespace behaves like empty filter
      When the user types "   " in the quick filter
      Then all nodes are displayed normally
      And no nodes are greyed out

    @edge-case
    Scenario: Filter with special characters matches literally
      When the user types "(" in the quick filter
      Then all nodes are greyed out
