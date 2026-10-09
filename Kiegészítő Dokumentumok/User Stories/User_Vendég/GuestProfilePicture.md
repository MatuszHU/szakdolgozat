# Guest Profile Picture

**Requirements:** M9
**Feature file:** [`Nightlife/NightlifeTests/Features/GuestProfilePicture.feature`](../../../Nightlife/NightlifeTests/Features/GuestProfilePicture.feature)

## User Story
As a guest
I want to upload and change my profile picture
So that my profile is recognisable

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* A chosen photo becomes a square profile picture of at most 512 × 512 pixels, cut from the middle
* The picture can be replaced and removed
* A file that is not an image is refused, and the picture does not change
