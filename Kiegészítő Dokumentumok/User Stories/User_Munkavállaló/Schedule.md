# Schedule

**Requirements:** K5, L3
**Feature file:** [`NightlifeWorker/NightlifeWorkerTests/Features/Schedule.feature`](../../../NightlifeWorker/NightlifeWorkerTests/Features/Schedule.feature)

## User Story
As a worker
I want to see my own shifts with their time, floor, zone and the tasks given to me
So that I know when and where I have to work and what I have to do

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* Only my own shifts are shown, in time order, grouped by the day they start on (a shift over midnight stays on its first day)
* Every shift shows its time, its floor and zone ("Ground floor – Bar"), or that it has no zone
* Only the tasks given to me are shown, not those of colleagues on the same shift
* The shift I am on right now is shown separately, together with the next one
* Finished shifts are listed separately, the most recent first
* Without shifts the schedule says that I have no upcoming shifts
