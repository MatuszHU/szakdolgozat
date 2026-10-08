# Shift Planning

**Requirements:** L3
**Feature file:** [`NightlifeManager/NightlifeManagerTests/Features/ShiftPlanning.feature`](../../../NightlifeManager/NightlifeManagerTests/Features/ShiftPlanning.feature)
**Related:** [ShiftConflict](ShiftConflict.md) (overlap rules)

## User Story
As an administrator
I want to manage the staff, create shifts, assign workers and hand out tasks
So that every zone is staffed and everyone knows what to do

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* A worker can be added with a role
* A shift has a time, a zone and a number of places
* A worker can be assigned to a shift; a full shift accepts nobody else
* A worker cannot be on overlapping shifts, even in different zones
* Tasks can be given only to workers on the shift
* Removing a worker from a shift also removes them from its tasks

## Not yet covered
* Adding further administrators with a permission level (L3) — planned together with L1.
