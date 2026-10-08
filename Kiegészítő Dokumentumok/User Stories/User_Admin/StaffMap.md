# Staff Map

**Requirements:** L4, K16, L3, L7
**Feature file:** [`NightlifeManager/NightlifeManagerTests/Features/StaffMap.feature`](../../../NightlifeManager/NightlifeManagerTests/Features/StaffMap.feature)

## User Story
As an administrator
I want to see on the floor plan where the staff are, together with their work areas and tasks
So that I can coordinate the evening and send help where it is needed

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* Staff appear in the zone of their latest check-in
* Selecting a worker shows their work area and task from tonight's shift, and their current position
* Staff without a check-in are listed separately
* The administrator can switch between floors
