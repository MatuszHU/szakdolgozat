@L7
Feature: Venue Designer
  The administrator draws the floor plan of the venue freely on a sheet sized in metres,
  with zones, points of interest and walls. Points are written as "x,y" in metres from the top left corner.

  Background:
    Given a venue "Club Neon" with the floor "Ground floor" at level 0 of 20 by 12 metres

  Scenario: Drawing a zone with the polygon tool
    Given the administrator uses the "polygon" tool
    When the administrator clicks "1,1 5,1 5,4 1,4 1,1"
    And the administrator saves the shape as the zone "Bar"
    Then the zone "Bar" has the corners "1,1 5,1 5,4 1,4"
    And the zone "Bar" has an area of 12 square metres

  Scenario: Zones can have any shape
    Given the administrator uses the "polygon" tool
    When the administrator clicks "0,0 6,0 6,2 2,2 2,5 0,5 0,0"
    And the administrator saves the shape as the zone "Dance floor"
    Then the zone "Dance floor" has an area of 18 square metres

  Scenario: Points snap to the dot grid
    Given the administrator uses the "polygon" tool
    When the administrator clicks "1.2,0.9 4.8,1.1 4.9,3.7 1.1,4.2 0.8,1.3"
    And the administrator saves the shape as the zone "Bar"
    Then the zone "Bar" has the corners "1,1 5,1 5,4 1,4"

  Scenario: Drawing freely without snapping
    Given the administrator uses the "polygon" tool
    And snapping to the grid is turned off
    When the administrator clicks "1.2,0.9 4.8,1.1 4.9,3.7 1.2,0.9"
    And the administrator saves the shape as the zone "Corner"
    Then the zone "Corner" has the corners "1.2,0.9 4.8,1.1 4.9,3.7"

  Scenario: A point of interest is an area
    Given the administrator uses the "polygon" tool
    When the administrator clicks "8,0 10,0 10,2 8,2 8,0"
    And the administrator saves the shape as a "toilet" named "WC"
    Then the point of interest "WC" is a "toilet" of 4 square metres centred at "9,1"

  Scenario: Shapes may overlap
    Given the administrator drew the zone "Bar" through "1,1 5,1 5,4 1,4"
    And the administrator drew a "bar" named "Main bar" through "2,2 4,2 4,3 2,3"
    When the administrator draws the zone "VIP" through "4,3 8,3 8,6 4,6"
    Then the designer shows no error
    And the floor "Ground floor" has the zones "Bar, VIP"

  Scenario: A shape needs at least three points
    Given the administrator uses the "polygon" tool
    When the administrator clicks "1,1 5,1"
    And the administrator finishes the drawing
    Then the designer shows "A shape needs at least three points"

  Scenario: Drawing a wall
    Given the administrator uses the "wall" tool
    When the administrator clicks "0,6 12,6 12,12"
    And the administrator finishes the drawing
    Then the floor "Ground floor" has a wall through "0,6 12,6 12,12"

  Scenario: Cancelling a drawing
    Given the administrator uses the "polygon" tool
    When the administrator clicks "1,1 5,1 5,4"
    And the administrator cancels the drawing
    Then nothing is being drawn
    And the floor "Ground floor" has no shapes

  Scenario: Selecting the topmost shape
    Given the administrator drew the zone "Bar" through "1,1 5,1 5,4 1,4"
    And the administrator drew a "bar" named "Main bar" through "2,2 4,2 4,3 2,3"
    And the administrator uses the "select" tool
    When the administrator clicks "3,2.5"
    Then the selection is "Main bar"
    When the administrator clicks "1.5,3.5"
    Then the selection is "Bar"

  Scenario: Moving a shape
    Given the administrator drew the zone "Bar" through "1,1 5,1 5,4 1,4"
    And the administrator selected "Bar"
    When the administrator moves the selection by "2,1"
    Then the zone "Bar" has the corners "3,2 7,2 7,5 3,5"

  Scenario: Shapes stay on the sheet
    Given the administrator drew the zone "Bar" through "1,1 5,1 5,4 1,4"
    And the administrator selected "Bar"
    When the administrator moves the selection by "18,0"
    Then the designer shows "The shape is outside the sheet"
    And the zone "Bar" has the corners "1,1 5,1 5,4 1,4"

  Scenario: Reshaping a shape by dragging a point
    Given the administrator drew the zone "Bar" through "1,1 5,1 5,4 1,4"
    And the administrator selected "Bar"
    When the administrator drags the point "5,4" to "7,6"
    Then the zone "Bar" has the corners "1,1 5,1 7,6 1,4"

  Scenario: Deleting a shape
    Given the administrator drew the zone "Bar" through "1,1 5,1 5,4 1,4"
    And the administrator selected "Bar"
    When the administrator deletes the selection
    Then the floor "Ground floor" has no shapes

  Scenario: Zone names are unique on a floor
    Given the administrator drew the zone "Bar" through "1,1 2,1 2,2"
    When the administrator draws the zone "Bar" through "5,5 6,5 6,6"
    Then the designer shows "A zone named Bar already exists"

  Scenario: Adding floors
    When the administrator adds the floor "Gallery" at level 1 of 20 by 12 metres
    Then the venue's floors are "Ground floor, Gallery"

  Scenario: Floor levels are unique
    When the administrator adds the floor "Basement" at level 0 of 20 by 12 metres
    Then the designer shows "Level 0 already exists"
    And the venue's floors are "Ground floor"

  @K16
  Scenario: Printing the zone codes
    Given the administrator drew the zone "Bar" through "1,1 5,1 5,4 1,4"
    And the administrator drew the zone "Entrance" through "0,10 2,10 2,12 0,12"
    When the administrator prints the zone codes
    Then the code sheet lists "Ground floor – Bar" and "Ground floor – Entrance"
    And every code on the sheet opens its own zone
