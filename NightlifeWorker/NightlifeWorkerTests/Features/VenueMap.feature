@K6
Feature: Venue Map
  The worker sees the floor plan with zones, points of interest and where colleagues are

  Background:
    Given the venue map has the floor "Ground floor" at level 0 with the zones "Bar" and "Entrance"
    And the venue map has the floor "Gallery" at level 1 with the zones "Lounge" and "Balcony"
    And the floor "Ground floor" has a "toilet" named "WC"
    And I am "Anna" and my colleagues are "Béla", "Csaba" and "Dóra"

  Scenario: The map opens on the floor of my work area
    Given my shift is assigned to the "Lounge" zone
    When I open the venue map
    Then the map shows the floor "Gallery"
    And the "Lounge" zone is highlighted as my work area

  Scenario: Zones and points of interest of the floor are shown
    When I open the venue map
    Then the map shows the floor "Ground floor"
    And the map shows the zones "Bar, Entrance"
    And the map shows the point of interest "WC"

  @K16
  Scenario: Colleagues appear in their latest checked-in zone
    Given "Béla" checked in to the "Entrance" zone
    And "Béla" checked in to the "Bar" zone
    And "Csaba" checked in to the "Entrance" zone
    When I open the venue map
    Then the "Bar" zone shows "Béla"
    And the "Entrance" zone shows "Csaba"
    And "Dóra" is listed as not checked in

  Scenario: Switching floors
    Given "Dóra" checked in to the "Balcony" zone
    When I open the venue map
    And I switch to the floor "Gallery"
    Then the map shows the floor "Gallery"
    And the "Balcony" zone shows "Dóra"
