@M4
Feature: Ticket Purchase
  The guest buys tickets for events and keeps them in the app

  Background:
    Given the guest is signed in for shopping
    And the event "Friday Night" starting in 2 days for 100 guests offers:
      | type     | price | quota |
      | Standard | 3000  |       |
      | VIP      | 8000  | 2     |

  Scenario: Buying a ticket
    When the guest buys 1 "Standard" ticket for "Friday Night"
    Then the guest has 1 ticket for "Friday Night"
    And 3000 Ft is charged

  Scenario: Buying several tickets
    When the guest buys 2 "VIP" tickets for "Friday Night"
    Then the guest has 2 tickets for "Friday Night"
    And 16000 Ft is charged

  Scenario: A sold-out ticket type
    Given 2 "VIP" tickets for "Friday Night" were sold to other guests
    When the guest buys 1 "VIP" ticket for "Friday Night"
    Then the shop shows "VIP tickets are sold out"
    And nothing is charged

  Scenario: A full event
    Given the event "Small Gig" starting in 3 days for 1 guest offers:
      | type     | price | quota |
      | Standard | 1000  |       |
    And 1 "Standard" ticket for "Small Gig" was sold to other guests
    When the guest buys 1 "Standard" ticket for "Small Gig"
    Then the shop shows "The event is full"

  Scenario: A declined payment issues no ticket
    Given the payment will be declined
    When the guest buys 1 "Standard" ticket for "Friday Night"
    Then the shop shows "The payment was declined"
    And the guest has 0 tickets for "Friday Night"

  Scenario: An event that is over
    Given the event "Last Week" starting 7 days ago for 100 guests offers:
      | type     | price | quota |
      | Standard | 2000  |       |
    When the guest buys 1 "Standard" ticket for "Last Week"
    Then the shop shows "The event is over"
    And nothing is charged

  @K7
  Scenario: The bought ticket opens the door
    When the guest buys 1 "Standard" ticket for "Friday Night"
    Then the code reader recognises the guest's ticket for "Friday Night"
    And the ticket is admitted to "Friday Night" once

  Scenario: My tickets are listed by event date
    Given the event "Opening Party" starting in 1 day for 100 guests offers:
      | type     | price | quota |
      | Standard | 2500  |       |
    When the guest buys 1 "Standard" ticket for "Friday Night"
    And the guest buys 1 "Standard" ticket for "Opening Party"
    Then the guest's tickets are for "Opening Party, Friday Night"
