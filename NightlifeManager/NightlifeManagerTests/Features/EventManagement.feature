@L11
Feature: Event Management
  The administrator creates events with ticket types, prices and raffles

  Scenario: Creating an event
    When the administrator creates the event "Friday Night" at "Club Neon" on October 16 from 22:00 to 04:00 for 300 guests
    Then the events are "Friday Night"
    And "Friday Night" lasts from 22:00 to 04:00 at "Club Neon" with 300 places

  Scenario: An event needs a title
    When the administrator creates the event "" at "Club Neon" on October 16 from 22:00 to 04:00 for 300 guests
    Then the event manager shows "A title is required"
    And there are no events

  Scenario: An event needs at least one place
    When the administrator creates the event "Friday Night" at "Club Neon" on October 16 from 22:00 to 04:00 for 0 guests
    Then the event manager shows "An event needs at least one place"

  Scenario: Events are listed in time order
    Given the event "Saturday Jam" on October 17 for 200 guests
    And the event "Friday Night" on October 16 for 300 guests
    Then the events are "Friday Night, Saturday Jam"

  @M4
  Scenario: Offering ticket types with prices
    Given the event "Friday Night" on October 16 for 300 guests
    When the administrator offers "Standard" tickets for "Friday Night" at 3000 Ft
    And the administrator offers "VIP" tickets for "Friday Night" at 8000 Ft limited to 50
    Then "Friday Night" offers "Standard for 3000 Ft, VIP for 8000 Ft (50 places)"

  @M4
  Scenario: A ticket type is offered only once
    Given the event "Friday Night" on October 16 for 300 guests
    And "Standard" tickets are offered for "Friday Night" at 3000 Ft
    When the administrator offers "Standard" tickets for "Friday Night" at 2500 Ft
    Then the event manager shows "Standard tickets are already offered"
    And "Friday Night" offers "Standard for 3000 Ft"

  @M4
  Scenario: A price cannot be negative
    Given the event "Friday Night" on October 16 for 300 guests
    When the administrator offers "Standard" tickets for "Friday Night" at -100 Ft
    Then the event manager shows "The price cannot be negative"

  @M4
  Scenario: Ticket quotas cannot exceed the capacity
    Given the event "Friday Night" on October 16 for 300 guests
    And "VIP" tickets are offered for "Friday Night" at 8000 Ft limited to 250
    When the administrator offers "Backstage" tickets for "Friday Night" at 15000 Ft limited to 100
    Then the event manager shows "Ticket quotas exceed the capacity of 300"

  @M7
  Scenario: Announcing a raffle
    Given the event "Friday Night" on October 16 for 300 guests
    When the administrator announces the raffle "Win a bottle" with the prize "Champagne" for "Friday Night"
    Then "Friday Night" has the raffle "Win a bottle" with the prize "Champagne"
