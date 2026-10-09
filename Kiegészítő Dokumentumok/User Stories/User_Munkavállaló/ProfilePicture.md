# Profile Picture

**Requirements:** K10, L6
**Feature file:** [`NightlifeWorker/NightlifeWorkerTests/Features/ProfilePicture.feature`](../../../NightlifeWorker/NightlifeWorkerTests/Features/ProfilePicture.feature)

## User Story
As a worker
I want to upload and change my profile picture
So that my colleagues recognise me

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* A chosen photo becomes a square profile picture of at most 512 × 512 pixels (cropped from the middle)
* The picture can be replaced and removed, and it is kept after restarting the app
* A file that is not an image is refused, and the picture does not change
