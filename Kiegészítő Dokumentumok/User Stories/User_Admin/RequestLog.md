# Request Log

**Requirements:** L8, K8, K17
**Feature file:** [`NightlifeManager/NightlifeManagerTests/Features/RequestLog.feature`](../../../NightlifeManager/NightlifeManagerTests/Features/RequestLog.feature)

## User Story
As an administrator
I want to see every request and alert raised by the workers, itemised, grouped and categorised
So that nothing gets lost during a busy night

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* All requests are listed one by one, newest first, with the worker's name
* Requests are grouped by category (panic alerts, supply requests) with their counts
* Open requests can be shown on their own (unacknowledged panic alerts, pending supply requests)
