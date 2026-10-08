# Company Settings

**Requirements:** L6, K10, K12, K15, K17
**Feature file:** [`NightlifeManager/NightlifeManagerTests/Features/CompanySettings.feature`](../../../NightlifeManager/NightlifeManagerTests/Features/CompanySettings.feature)
**Related:** [AdminAccess](AdminAccess.md) (company domain)

## User Story
As an administrator
I want to manage my own settings and switch the workers' optional features on or off centrally
So that the workers' app fits how the venue works

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* Every optional worker feature (profile picture, statistics, guide, supply requests) is on by default
* An administrator can switch an optional worker feature off and on again
* An administrator can change their own password after confirming the current one
* A wrong current password is rejected
