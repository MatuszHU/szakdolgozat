# Loading Screen

**Requirements:** K3
**Feature file:** [`NightlifeWorker/NightlifeWorkerTests/Features/LoadingScreen.feature`](../../../NightlifeWorker/NightlifeWorkerTests/Features/LoadingScreen.feature)

## User Story
As a worker
I want to see an animated loading screen while the app is busy for longer
So that I know the app is working and has not frozen

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* A load that takes longer than 0.3 seconds shows the loading screen until it ends
* A shorter load does not make the loading screen flash
* While several loads run, the loading screen stays until the last one ends
