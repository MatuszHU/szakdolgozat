@K17
Feature: Supply Request
  The worker reports that something has run out or is running low, and follows what happens to the request

  Background:
    Given the stock list has:
      | item    | category | unit |
      | Ice     | Bar      | kg   |
      | Glasses | Bar      | pcs  |
      | Lime    | Fruit    | kg   |
    And I am "Anna" working in the "Bar" zone

  Scenario: The stock list is offered by category
    When I open the supply request
    Then I can choose from "Bar: Glasses, Ice; Fruit: Lime"

  @L10
  Scenario: Reporting that something ran out
    When I request 5 of "Ice" because it is "out of stock"
    Then the supply request screen says "Request sent"
    And the administrator sees a request from "Anna" for "5 kg Ice" in the "Bar" zone marked "out of stock"

  @L10
  Scenario: Warning before something runs out
    When I request 50 of "Glasses" because it is "running low"
    Then the administrator sees a request from "Anna" for "50 pcs Glasses" in the "Bar" zone marked "running low"

  Scenario: The quantity must be positive
    When I request 0 of "Ice" because it is "out of stock"
    Then the supply request screen says "Enter a quantity greater than zero"
    And the administrator has no supply requests

  Scenario: One open request per item
    Given I requested 5 of "Ice" because it is "out of stock"
    When I request 3 of "Ice" because it is "out of stock"
    Then the supply request screen says "You already have an open request for Ice"

  Scenario: Following my requests
    Given I requested 5 of "Ice" because it is "out of stock"
    And I requested 2 of "Lime" because it is "running low"
    When the administrator approves the request for "Ice"
    And the administrator rejects the request for "Lime"
    Then my requests are:
      | item | amount | status   |
      | Lime | 2 kg   | rejected |
      | Ice  | 5 kg   | approved |

  Scenario: Requesting again after a decision
    Given I requested 5 of "Ice" because it is "out of stock"
    And the administrator approves the request for "Ice"
    When I request 3 of "Ice" because it is "running low"
    Then the supply request screen says "Request sent"

  @L6
  Scenario: Turned off by the administrator
    Given the administrator turned off "supply requests"
    When I open the home screen
    Then the home screen does not offer "Supply request"
    And the home screen offers "Schedule"
