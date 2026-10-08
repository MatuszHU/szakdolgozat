@L8
Feature: Request Log
  The administrator sees every request and alert raised by the workers

  Background:
    Given the workers "Anna" and "Béla" are on the staff
    And the stock has:
      | item | category | quantity | unit | minimum |
      | Ice  | Bar      | 20       | kg   | 5       |
    And "Béla" requested 4 of "Ice" at 21:00
    And "Anna" requested 2 of "Ice" at 21:30
    And the request of "Anna" was approved
    And "Anna" raised a panic alert at 22:10

  Scenario: Every request is listed, newest first
    When the administrator opens the request log
    Then the log lists:
      | time  | category       | worker | details  | state  |
      | 22:10 | Panic alert    | Anna   |          | open   |
      | 21:30 | Supply request | Anna   | 2 kg Ice | closed |
      | 21:00 | Supply request | Béla   | 4 kg Ice | open   |

  Scenario: Requests are grouped by category
    When the administrator opens the request log
    Then the categories are "Panic alert: 1, Supply request: 2"

  Scenario: Only open requests
    When the administrator opens the request log
    And the administrator shows only open requests
    Then the log lists:
      | time  | category       | worker | details  | state |
      | 22:10 | Panic alert    | Anna   |          | open  |
      | 21:00 | Supply request | Béla   | 4 kg Ice | open  |

  @K8
  Scenario: An acknowledged panic alert is closed
    Given the panic alert of "Anna" was acknowledged by "Béla"
    When the administrator opens the request log
    And the administrator shows only open requests
    Then the categories are "Panic alert: 0, Supply request: 1"
