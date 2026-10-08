@L7
Feature: Venue Designer
  The administrator draws the floor plan of the venue on a grid, with zones and points of interest

  Background:
    Given a venue "Club Neon" with the floor "Ground floor" at level 0 of 10 by 8 cells

  Scenario: Drawing a zone
    When the administrator draws the zone "Bar" from cell 1,1 to cell 3,2
    Then the floor "Ground floor" has the zone "Bar" with 6 cells

  Scenario: Zones cannot overlap
    Given the administrator drew the zone "Bar" from cell 1,1 to cell 3,2
    When the administrator draws the zone "VIP" from cell 3,2 to cell 5,4
    Then the designer shows "Zone overlaps Bar"
    And the floor "Ground floor" has no zone "VIP"

  Scenario: Zones must stay inside the grid
    When the administrator draws the zone "Terrace" from cell 8,6 to cell 10,7
    Then the designer shows "Zone is outside the grid"
    And the floor "Ground floor" has no zone "Terrace"

  Scenario: Zone names are unique on a floor
    Given the administrator drew the zone "Bar" from cell 1,1 to cell 2,2
    When the administrator draws the zone "Bar" from cell 5,5 to cell 6,6
    Then the designer shows "A zone named Bar already exists"

  Scenario: Placing a point of interest
    When the administrator places a "toilet" named "WC" at cell 0,0
    Then the floor "Ground floor" has the point of interest "WC" at cell 0,0

  Scenario: Adding floors
    When the administrator adds the floor "Gallery" at level 1 of 10 by 8 cells
    Then the venue's floors are "Ground floor, Gallery"

  Scenario: Floor levels are unique
    When the administrator adds the floor "Basement" at level 0 of 10 by 8 cells
    Then the designer shows "Level 0 already exists"
    And the venue's floors are "Ground floor"

  @K16
  Scenario: Printing the zone codes
    Given the administrator drew the zone "Bar" from cell 1,1 to cell 3,2
    And the administrator drew the zone "Entrance" from cell 0,7 to cell 1,7
    When the administrator prints the zone codes
    Then the code sheet lists "Ground floor – Bar" and "Ground floor – Entrance"
    And every code on the sheet opens its own zone
