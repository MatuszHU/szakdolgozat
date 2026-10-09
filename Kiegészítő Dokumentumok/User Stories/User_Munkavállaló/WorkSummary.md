# Work Summary

**Requirements:** K12, L6
**Feature file:** [`NightlifeWorker/NightlifeWorkerTests/Features/WorkSummary.feature`](../../../NightlifeWorker/NightlifeWorkerTests/Features/WorkSummary.feature)

## User Story
As a worker
I want to see how many hours I have worked and what tasks I had before
So that I can check my pay and look back on my work

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* The hours are counted from my shifts in the current and in the previous pay period, and in total
* A weekly pay period starts on Monday, a monthly one on the first day of the month
* A shift across the start of a pay period is split between the two periods
* The shift in progress counts until now; upcoming shifts do not count
* My past tasks (only mine, from finished shifts) are listed newest first, showing whether they were done
* The administrator can turn the summary off (L6)
