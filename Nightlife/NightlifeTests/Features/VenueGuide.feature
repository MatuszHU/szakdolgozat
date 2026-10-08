@M5
Feature: Venue Guide
  The guest sees the floor plan with the places meant for guests

  Background:
    Given the guest venue has the floor "Gallery" at level 1 with these places:
      | name       | kind           |
      | Cloakroom  | cloakroom      |
      | Fire exit  | emergency exit |
    And the guest venue has the floor "Ground floor" at level 0 with these places:
      | name      | kind      |
      | Main bar  | bar       |
      | WC        | toilet    |
      | Stage     | stage     |
      | Storage   | storage   |
    And the floor "Ground floor" has the staff zone "Staff room"

  Scenario: The map opens on the ground floor
    When the guest opens the venue guide
    Then the guide shows the floor "Ground floor"

  Scenario: Guests see the places meant for them
    When the guest opens the venue guide
    Then the guide lists "Main bar, Stage, WC"

  Scenario: Staff-only places are hidden
    When the guest opens the venue guide
    Then the guide does not show "Storage"
    And the guide shows no staff zones

  Scenario: Switching floors
    When the guest opens the venue guide
    And the guest switches to the floor "Gallery"
    Then the guide lists "Cloakroom, Fire exit"

  Scenario: No floor plan yet
    Given the venue has no floor plan yet
    When the guest opens the venue guide
    Then the guest is told that the map is not available yet
