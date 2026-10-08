@K7
Feature: Code Reader
  The worker scans optical codes to admit guests and to check in to zones

  Background:
    Given the venue has the zones "Bar" and "Entrance"
    And tonight's event is "Friday Night"
    And the following tickets exist:
      | serial | guest        | event        | type     | used |
      | T-001  | Kovács Péter | Friday Night | vip      | no   |
      | T-002  | Nagy Éva     | Friday Night | standard | yes  |
      | T-003  | Szabó Ádám   | Saturday Jam | standard | no   |
    And the code reader is open for a worker on shift

  @M4
  Scenario: A valid ticket admits the guest
    When the code reader scans the ticket "T-001"
    Then the code reader shows "Admitted: Kovács Péter – VIP"
    And the ticket "T-001" is marked as used

  @M4
  Scenario: An already used ticket is rejected
    When the code reader scans the ticket "T-002"
    Then the code reader shows "Ticket already used"

  @M4
  Scenario: A ticket for another event is rejected
    When the code reader scans the ticket "T-003"
    Then the code reader shows "Ticket is for another event"
    And the ticket "T-003" is not marked as used

  @M4
  Scenario: An unknown ticket is rejected
    When the code reader scans the ticket "T-999"
    Then the code reader shows "Unknown ticket"

  @K16
  Scenario: A zone code checks the worker in
    When the code reader scans the "Bar" zone code
    Then the code reader shows "Checked in: Bar"

  Scenario: An unrecognised code is reported
    When the code reader scans "https://example.com/menu"
    Then the code reader shows "Unknown code"
