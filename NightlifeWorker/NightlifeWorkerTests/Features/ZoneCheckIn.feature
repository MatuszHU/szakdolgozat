@K16 @K7
Feature: Zone Check-in
  The worker records their approximate position by scanning the QR code placed in a zone

  Background:
    Given the venue has the zones "Bar" and "Entrance"

  Scenario: Successful check-in
    Given the worker is on shift
    When the worker scans the QR code of the "Bar" zone
    Then the worker's position is the "Bar" zone

  Scenario: Changing zones
    Given the worker is on shift
    And the worker is checked in to the "Bar" zone
    When the worker scans the QR code of the "Entrance" zone
    Then the worker's position is the "Entrance" zone

  Scenario: Invalid code
    Given the worker is on shift
    And the worker is checked in to the "Bar" zone
    When the worker scans a QR code that does not belong to a zone
    Then an invalid code error is shown
    And the worker's position is the "Bar" zone

  @N4
  Scenario: Check-in outside a shift
    Given the worker is not on shift
    When the worker scans the QR code of the "Bar" zone
    Then a not on shift error is shown
    And the worker has no position

  @N4
  Scenario: Shift ends
    Given the worker is on shift
    And the worker is checked in to the "Bar" zone
    When the worker's shift ends
    Then the worker has no position
