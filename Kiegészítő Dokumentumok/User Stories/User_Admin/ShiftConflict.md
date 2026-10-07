# Shift Conflict

**Requirements:** L3
**Feature file:** [`NightlifeWorker/NightlifeWorkerTests/Features/ShiftConflict.feature`](../../../NightlifeWorker/NightlifeWorkerTests/Features/ShiftConflict.feature)

## User Story
As an administrator
I want the system to reject overlapping shift assignments for the same worker
So that no worker is scheduled to two places at the same time

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* Assigning an overlapping shift is rejected with a conflict error
* Assigning a non-overlapping shift succeeds
* Back-to-back shifts (one ends exactly when the other starts) do not conflict
* An overlap of only a few minutes is still a conflict
