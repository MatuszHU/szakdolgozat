@L3
Feature: Shift Conflict Detection
  The system rejects assigning a worker to a shift that overlaps one of their existing shifts

  Background:
    Given the staff are "Anna", "Béla" and "Csaba"

  Scenario: Assigning an overlapping shift
    Given "Anna" works a shift from 20:00 to 02:00
    When "Anna" is assigned a shift from 21:00 to 23:00
    Then the planner shows "Anna already has an overlapping shift"
    And "Anna" works 1 shift

  Scenario: Assigning a non-overlapping shift
    Given "Anna" works a shift from 20:00 to 22:00
    When "Anna" is assigned a shift from 23:00 to 01:00
    Then the planner shows no error
    And "Anna" works 2 shifts

  Scenario: Back-to-back shifts
    Given "Anna" works a shift from 20:00 to 22:00
    When "Anna" is assigned a shift from 22:00 to 00:00
    Then the planner shows no error
    And "Anna" works 2 shifts

  Scenario: Overlap by minutes
    Given "Anna" works a shift from 20:00 to 22:30
    When "Anna" is assigned a shift from 22:15 to 23:00
    Then the planner shows "Anna already has an overlapping shift"
