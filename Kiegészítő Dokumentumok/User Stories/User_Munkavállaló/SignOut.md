# Sign Out

**Requirements:** K14, K4
**Feature file:** [`NightlifeWorker/NightlifeWorkerTests/Features/SignOut.feature`](../../../NightlifeWorker/NightlifeWorkerTests/Features/SignOut.feature)
**Related:** [Authentication](Authentication.md)

## User Story
As a worker
I want to sign out of the app
So that nobody else can use my account on this device

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* Signing out returns to the welcome screen
* After signing out, the next launch starts on the welcome screen (the stored sign-in is forgotten)
* A sign-in is remembered between launches until the worker signs out (K4)
