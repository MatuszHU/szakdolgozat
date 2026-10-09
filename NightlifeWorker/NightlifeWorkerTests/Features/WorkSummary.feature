@K12
Feature: Work Summary
  The worker sees the hours worked in the pay period and the tasks they had before

  Background:
    Given I am "Anna" on the schedule and my colleague is "Béla"
    And the time is "2026-10-09 18:00"

  Scenario: Hours in this and the previous week
    Given my pay period is "weekly"
    And the shift plan has:
      | worker | start            | end              | zone |
      | Anna   | 2026-10-05 20:00 | 2026-10-06 02:00 |      |
      | Anna   | 2026-10-07 20:00 | 2026-10-08 00:00 |      |
      | Anna   | 2026-10-02 20:00 | 2026-10-03 04:00 |      |
      | Anna   | 2026-10-10 20:00 | 2026-10-11 04:00 |      |
      | Béla   | 2026-10-06 20:00 | 2026-10-07 04:00 |      |
    When I open my work summary
    Then I worked "10" hours in this pay period
    And I worked "8" hours in the previous pay period
    And I worked "18" hours in total

  Scenario: A shift across the start of the week is split
    Given my pay period is "weekly"
    And the shift plan has:
      | worker | start            | end              | zone |
      | Anna   | 2026-10-04 22:00 | 2026-10-05 04:00 |      |
    When I open my work summary
    Then I worked "4" hours in this pay period
    And I worked "2" hours in the previous pay period

  Scenario: The shift in progress counts until now
    Given my pay period is "weekly"
    And the time is "2026-10-09 21:30"
    And the shift plan has:
      | worker | start            | end              | zone |
      | Anna   | 2026-10-09 20:00 | 2026-10-10 02:00 |      |
    When I open my work summary
    Then I worked "1.5" hours in this pay period

  Scenario: Monthly pay period
    Given my pay period is "monthly"
    And the shift plan has:
      | worker | start            | end              | zone |
      | Anna   | 2026-10-01 20:00 | 2026-10-02 02:00 |      |
      | Anna   | 2026-09-30 18:00 | 2026-09-30 23:00 |      |
    When I open my work summary
    Then I worked "6" hours in this pay period
    And I worked "5" hours in the previous pay period

  Scenario: My past tasks
    Given my pay period is "weekly"
    And the shift plan has:
      | worker     | start            | end              | zone |
      | Anna, Béla | 2026-10-05 20:00 | 2026-10-06 02:00 |      |
      | Anna       | 2026-10-07 20:00 | 2026-10-08 00:00 |      |
      | Anna       | 2026-10-10 20:00 | 2026-10-11 04:00 |      |
    And the shifts have the tasks:
      | shift starts | task           | worker | done |
      | 2026-10-05   | Restock        | Anna   | yes  |
      | 2026-10-05   | Clean          | Béla   | yes  |
      | 2026-10-07   | Open the till  | Anna   | no   |
      | 2026-10-10   | Count the cash | Anna   | no   |
    When I open my work summary
    Then my past tasks are:
      | task          | day        | done |
      | Open the till | 2026-10-07 | no   |
      | Restock       | 2026-10-05 | yes  |

  @L6
  Scenario: Turned off by the administrator
    Given the administrator turned off "statistics"
    When I open the home screen
    Then the home screen does not offer "Summary"
    And the home screen offers "Schedule"
