@L3
Feature: Shift Planning
  The administrator manages the staff, creates shifts, assigns workers and hands out tasks

  Background:
    Given the planning venue has the zones "Bar" and "Entrance"
    And the staff are "Anna", "Béla" and "Csaba"

  Scenario: Adding a worker
    When the administrator adds the worker "Dóra" as "security"
    Then the staff are listed as "Anna, Béla, Csaba, Dóra"

  Scenario: Creating a shift
    When the administrator creates a shift in the "Bar" zone from 20:00 to 02:00 for 2 workers
    Then the "Bar" shift lasts from 20:00 to 02:00 and has 2 free places

  Scenario: Assigning a worker
    Given there is a shift in the "Bar" zone from 20:00 to 02:00 for 2 workers
    When the administrator assigns "Anna" to the "Bar" shift
    Then the "Bar" shift has the workers "Anna"
    And the "Bar" shift has 1 free place

  Scenario: A full shift accepts nobody else
    Given there is a shift in the "Entrance" zone from 20:00 to 02:00 for 1 worker
    And "Béla" is on the "Entrance" shift
    When the administrator assigns "Csaba" to the "Entrance" shift
    Then the planner shows "The shift is full"
    And the "Entrance" shift has the workers "Béla"

  Scenario: Overlapping shifts in different zones
    Given there is a shift in the "Bar" zone from 20:00 to 02:00 for 2 workers
    And there is a shift in the "Entrance" zone from 23:00 to 03:00 for 2 workers
    And "Anna" is on the "Bar" shift
    When the administrator assigns "Anna" to the "Entrance" shift
    Then the planner shows "Anna already has an overlapping shift"

  Scenario: Handing out a task
    Given there is a shift in the "Bar" zone from 20:00 to 02:00 for 2 workers
    And "Anna" is on the "Bar" shift
    When the administrator gives "Anna" the task "Restock the bar" on the "Bar" shift
    Then "Anna" has the task "Restock the bar" on the "Bar" shift

  Scenario: Tasks only for workers on the shift
    Given there is a shift in the "Bar" zone from 20:00 to 02:00 for 2 workers
    When the administrator gives "Anna" the task "Restock the bar" on the "Bar" shift
    Then the planner shows "Anna is not on this shift"

  Scenario: Removing a worker from a shift
    Given there is a shift in the "Bar" zone from 20:00 to 02:00 for 2 workers
    And "Anna" is on the "Bar" shift
    And the administrator gave "Anna" the task "Restock the bar" on the "Bar" shift
    When the administrator removes "Anna" from the "Bar" shift
    Then the "Bar" shift has 2 free places
    And "Anna" has no task on the "Bar" shift
