# Admin Access

**Requirements:** L1, L2, L5, L6
**Feature file:** [`NightlifeManager/NightlifeManagerTests/Features/AdminAccess.feature`](../../../NightlifeManager/NightlifeManagerTests/Features/AdminAccess.feature)

## User Story
As an administrator
I want to sign in with my username and password (or with Apple) and sign out
So that only authorised staff can manage the venue

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* The first owner is set up when there is no administrator yet
* An administrator signs in with the local part of the e-mail address and a password; the company domain is fixed
* A wrong password is rejected with the same message as an unknown username
* A temporary password must be replaced at the first sign-in
* After signing in the main screen is shown (L2); signing out returns to the sign-in screen (L5)
