@K8
Feature: Panic Mode
  A worker in danger alerts the security staff with their last known location

  Background:
    Given the venue has the zones "Bar" and "Entrance"
    And the staff on shift:
      | name  | role      |
      | Anna  | bartender |
      | Béla  | security  |
      | Csaba | security  |
      | Dóra  | bartender |

  @K16
  Scenario: The alert reaches the security staff
    Given "Anna" is checked in to the "Bar" zone
    When "Anna" activates panic mode
    Then a panic alert is sent to "Béla" and "Csaba"
    And the alert says "Anna (bartender) – Bar"

  Scenario: Alert without a known position
    Given "Anna" has not checked in to any zone
    When "Anna" activates panic mode
    Then a panic alert is sent to "Béla" and "Csaba"
    And the alert says "Anna (bartender) – unknown location"

  Scenario: A security staff member raises the alert
    Given "Béla" is checked in to the "Entrance" zone
    When "Béla" activates panic mode
    Then a panic alert is sent only to "Csaba"

  Scenario: Acknowledging the alert
    Given "Anna" activated panic mode in the "Bar" zone
    When "Béla" acknowledges the alert
    Then the alert is acknowledged by "Béla"

  Scenario: Only the first acknowledgement counts
    Given "Anna" activated panic mode in the "Bar" zone
    And "Béla" acknowledged the alert
    When "Csaba" acknowledges the alert
    Then the alert is acknowledged by "Béla"
