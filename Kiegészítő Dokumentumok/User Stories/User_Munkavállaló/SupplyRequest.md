# Supply Request

**Requirements:** K17, L10, L8, L6
**Feature file:** [`NightlifeWorker/NightlifeWorkerTests/Features/SupplyRequest.feature`](../../../NightlifeWorker/NightlifeWorkerTests/Features/SupplyRequest.feature)

## User Story
As a worker
I want to report when something (ice, glasses, drinks…) has run out or is running low
So that the manager can restock it in time

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* The stock list is offered by category
* A request has an item, a quantity, whether it has already run out or is only running low, and the zone of the worker
* The quantity must be greater than zero
* A worker can have only one open request for the same item; after the decision a new one can be sent
* The worker follows the status of their requests (open, approved, rejected), newest first
* The request appears in the administrator's stock management (L10) and request log (L8)
* The administrator can turn supply requests off (L6); then the home screen does not offer them
