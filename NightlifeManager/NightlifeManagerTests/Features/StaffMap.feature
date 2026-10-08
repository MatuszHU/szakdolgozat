@L4
Feature: Staff Map
  The administrator sees on the floor plan where the staff are, with their work areas and tasks

  Background:
    Given the staff map venue has the floor "Ground floor" at level 0 with the zones "Bar" and "Entrance"
    And the staff map venue has the floor "Gallery" at level 1 with the zones "Lounge" and "Balcony"
    And tonight's shifts are:
      | name  | work area | task            |
      | Anna  | Bar       | Restock the bar |
      | Béla  | Entrance  | Check tickets   |
      | Csaba | Lounge    | Guard the VIPs  |

  @K16
  Scenario: Staff appear in their latest checked-in zone
    Given "Anna" checked in to the "Entrance" zone at 20:00
    And "Anna" checked in to the "Bar" zone at 20:30
    When the administrator opens the staff map
    Then the "Bar" zone shows "Anna"
    And the "Entrance" zone shows nobody

  @L3
  Scenario: Selecting a worker shows their work area, position and task
    Given "Béla" checked in to the "Bar" zone at 21:00
    When the administrator opens the staff map
    And the administrator selects "Béla"
    Then the details show the work area "Entrance", the position "Bar" and the task "Check tickets"

  Scenario: Staff without a check-in are listed
    Given "Béla" checked in to the "Entrance" zone at 21:00
    When the administrator opens the staff map
    Then "Anna, Csaba" are listed as not checked in

  Scenario: Switching floors
    Given "Csaba" checked in to the "Lounge" zone at 21:00
    When the administrator opens the staff map
    And the administrator switches to the floor "Gallery"
    Then the "Lounge" zone shows "Csaba"
