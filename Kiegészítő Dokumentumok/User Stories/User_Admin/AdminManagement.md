# Admin Management

**Requirements:** L3, L1, N3
**Feature file:** [`NightlifeManager/NightlifeManagerTests/Features/AdminManagement.feature`](../../../NightlifeManager/NightlifeManagerTests/Features/AdminManagement.feature)

## User Story
As an owner or user administrator
I want to add and remove administrators with a permission level and reset forgotten passwords
So that the right people can manage the venue

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* An administrator is added with a name, username, permission level and temporary password
* Usernames are unique
* Only owners and user administrators can manage administrators
* A forgotten password is reset to a temporary one that must be changed at the next sign-in
* The last owner cannot be removed
