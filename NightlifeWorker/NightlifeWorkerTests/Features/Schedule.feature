@K5
Feature: Schedule
  The worker sees their own shifts with time, floor, zone and the tasks given to them

  Background:
    Given the schedule venue has the floor "Ground floor" at level 0 with the zones "Bar" and "Entrance"
    And the schedule venue has the floor "Gallery" at level 1 with the zones "Lounge" and "Balcony"
    And I am "Anna" on the schedule and my colleague is "Béla"
    And the time is "2026-10-09 18:00"

  Scenario: My upcoming shifts are listed in time order
    Given the shift plan has:
      | worker | start            | end              | zone     |
      | Anna   | 2026-10-10 20:00 | 2026-10-11 04:00 | Lounge   |
      | Anna   | 2026-10-09 20:00 | 2026-10-10 02:00 | Bar      |
      | Béla   | 2026-10-09 19:00 | 2026-10-10 01:00 | Entrance |
    When I open my schedule
    Then my upcoming shifts are:
      | day        | time        | place               |
      | 2026-10-09 | 20:00–02:00 | Ground floor – Bar  |
      | 2026-10-10 | 20:00–04:00 | Gallery – Lounge    |

  Scenario: A shift without a zone
    Given the shift plan has:
      | worker | start            | end              | zone |
      | Anna   | 2026-10-09 20:00 | 2026-10-10 02:00 |      |
    When I open my schedule
    Then my upcoming shifts are:
      | day        | time        | place   |
      | 2026-10-09 | 20:00–02:00 | no zone |

  Scenario: Only my tasks are shown
    Given the shift plan has:
      | worker     | start            | end              | zone |
      | Anna, Béla | 2026-10-09 20:00 | 2026-10-10 02:00 | Bar  |
    And the shift at "Bar" has the tasks:
      | task               | worker |
      | Restock the fridge | Anna   |
      | Clean the counter  | Béla   |
      | Open the till      | Anna   |
    When I open my schedule
    Then my shift at "Bar" shows the tasks "Restock the fridge, Open the till"

  Scenario: The current shift and the next one
    Given the time is "2026-10-09 21:30"
    And the shift plan has:
      | worker | start            | end              | zone   |
      | Anna   | 2026-10-09 20:00 | 2026-10-10 02:00 | Bar    |
      | Anna   | 2026-10-10 20:00 | 2026-10-11 04:00 | Lounge |
    When I open my schedule
    Then my current shift is at "Ground floor – Bar"
    And my next shift is at "Gallery – Lounge"

  Scenario: Finished shifts are listed separately
    Given the shift plan has:
      | worker | start            | end              | zone     |
      | Anna   | 2026-10-07 20:00 | 2026-10-08 02:00 | Entrance |
      | Anna   | 2026-10-08 20:00 | 2026-10-09 02:00 | Balcony  |
      | Anna   | 2026-10-09 20:00 | 2026-10-10 02:00 | Bar      |
    When I open my schedule
    Then my finished shifts are at "Gallery – Balcony, Ground floor – Entrance"
    And my next shift is at "Ground floor – Bar"

  Scenario: No shifts yet
    When I open my schedule
    Then I have no upcoming shifts
