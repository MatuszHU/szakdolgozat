# Settings

**Requirements:** K9, K14, L6
**Feature file:** [`NightlifeWorker/NightlifeWorkerTests/Features/Settings.feature`](../../../NightlifeWorker/NightlifeWorkerTests/Features/Settings.feature)

## User Story
As a worker
I want to reach every setting available to me in one view
So that I do not have to look for them

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* The settings offer the profile picture, the guide, the about section and signing out
* Settings of features the administrator turned off are not offered (L6)
* The about section shows who is signed in and the version of the app
* Signing out from the settings returns to the welcome screen (K14)
