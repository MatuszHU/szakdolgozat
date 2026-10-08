# Ticket Purchase

**Requirements:** M4, L11, K7
**Feature file:** [`Nightlife/NightlifeTests/Features/TicketPurchase.feature`](../../../Nightlife/NightlifeTests/Features/TicketPurchase.feature)

## User Story
As a guest
I want to buy tickets for an event and keep them in the app
So that I can get in quickly at the entrance

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* A ticket of an offered type can be bought; the price is charged and the ticket appears among my tickets
* Several tickets can be bought at once
* A ticket type with an exhausted quota cannot be bought
* A full event cannot be bought
* A declined payment issues no ticket
* A ticket for an event that is over cannot be bought
* The bought ticket is recognised and admitted by the worker's code reader (K7)
* My tickets are listed by event date

## Not yet covered
* Real payment (Apple Pay) and adding the ticket to Apple Wallet need a paid Apple Developer membership; until then Debug builds use a test payment.
