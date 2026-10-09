# Raffle

**Requirements:** M7, L11
**Feature file:** [`Nightlife/NightlifeTests/Features/Raffle.feature`](../../../Nightlife/NightlifeTests/Features/Raffle.feature)

## User Story
As a guest
I want to see the current raffles and register for them
So that I can win the prizes of the events

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* The raffles of events that have not ended yet are listed in the order of the events
* A raffle shows its event, title, prize and details
* The guest registers once per raffle; a second registration is refused
* After the event has ended, registration is no longer possible
* The administrator sees how many guests registered (L11)
