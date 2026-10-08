# Event Management

**Requirements:** L11, M4, M7
**Feature file:** [`NightlifeManager/NightlifeManagerTests/Features/EventManagement.feature`](../../../NightlifeManager/NightlifeManagerTests/Features/EventManagement.feature)

## User Story
As an administrator
I want to create events with ticket types, prices and an optional raffle
So that guests can buy tickets and take part in the raffle

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* An event has a title, a time, a location and a capacity
* An event needs a title, must end after it starts and needs at least one place
* Ticket types are offered with a price and an optional quota
* A ticket type is offered only once per event, its price cannot be negative
* The ticket quotas together cannot exceed the capacity of the event
* A raffle with a prize can be announced for an event
* Events are listed in time order
