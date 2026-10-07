@L3
Feature: Shift Conflict Detection
  The system reports an error when a worker's new shift overlaps an existing one

  Scenario: Assigning an overlapping shift
    Given the worker has a shift from 20:00 to 02:00
    When a shift from 21:00 to 23:00 is assigned
    Then a shift conflict error is shown

  Scenario: Assigning a non-overlapping shift
    Given the worker has a shift from 20:00 to 22:00
    When a shift from 23:00 to 01:00 is assigned
    Then the shift is assigned successfully

  Scenario: Back-to-back shifts
    Given the worker has a shift from 20:00 to 22:00
    When a shift from 22:00 to 00:00 is assigned
    Then the shift is assigned successfully

  Scenario: Overlap by minutes
    Given the worker has a shift from 20:00 to 22:30
    When a shift from 22:15 to 23:00 is assigned
    Then a shift conflict error is shown
