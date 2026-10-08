@L10
Feature: Stock Management
  The administrator keeps track of the stock and decides on supply requests

  Background:
    Given the stock has:
      | item | category | quantity | unit  | minimum |
      | Ice  | Bar      | 20       | kg    | 10      |
      | Cups | Bar      | 500      | piece | 100     |

  Scenario: Adding a stock item
    When the administrator adds "Lemons" in "Bar" with 30 "piece" and a minimum of 10
    Then the stock lists "Cups, Ice, Lemons"

  Scenario: Item names are unique
    When the administrator adds "Ice" in "Bar" with 5 "kg" and a minimum of 1
    Then the stock screen shows "Ice is already in the stock"

  Scenario: Items below the minimum are flagged
    When the quantity of "Ice" is set to 5
    Then the low stock items are "Ice"
    And the administrator is warned that "Ice" is running low

  @K17
  Scenario: Approving a supply request takes it from the stock
    Given a worker requested 4 of "Ice"
    When the administrator approves the request
    Then the stock of "Ice" is 16
    And the request is "approved"

  @K17
  Scenario: Approving warns when the item falls below the minimum
    Given a worker requested 15 of "Ice"
    When the administrator approves the request
    Then the administrator is warned that "Ice" is running low

  @K17
  Scenario: A request larger than the stock cannot be approved
    Given a worker requested 25 of "Ice"
    When the administrator approves the request
    Then the stock screen shows "Not enough Ice in stock"
    And the request is "pending"

  @K17
  Scenario: Rejecting a request
    Given a worker requested 4 of "Ice"
    When the administrator rejects the request
    Then the request is "rejected"
    And the stock of "Ice" is 20
