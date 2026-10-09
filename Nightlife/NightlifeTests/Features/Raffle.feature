@M7
Feature: Raffle
  The guest sees the current raffles and registers for them

  Background:
    Given the guest is signed in for the raffles
    And the raffle events are:
      | event       | starts in days | raffle     | prize               |
      | Retro Party | 8              | Free entry | 2 tickets           |
      | Neon Night  | 1              | VIP table  | Bottle of champagne |
      | Past Party  | -7             | Lucky draw | T-shirt             |
      | Quiet Night | 3              |            |                     |

  Scenario: The current raffles are listed
    When the guest opens the raffles
    Then the raffles are "Neon Night – VIP table, Retro Party – Free entry"

  Scenario: The details of a raffle
    When the guest opens the raffles
    Then the raffle of "Neon Night" offers "Bottle of champagne"

  Scenario: Registering for a raffle
    When the guest registers for the raffle of "Neon Night"
    Then the guest is registered for the raffle of "Neon Night"
    And the raffle of "Neon Night" has 1 participant

  @L11
  Scenario: Registering only once
    Given the guest registered for the raffle of "Neon Night"
    When the guest registers for the raffle of "Neon Night"
    Then the raffle screen shows "You are already registered for this raffle"
    And the raffle of "Neon Night" has 1 participant

  Scenario: No registration after the event
    When the guest registers for the raffle of "Past Party"
    Then the raffle screen shows "The event is over"
    And the raffle of "Past Party" has 0 participants
