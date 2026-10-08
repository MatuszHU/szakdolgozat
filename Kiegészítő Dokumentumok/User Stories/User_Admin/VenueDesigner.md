# Venue Designer

**Requirements:** L7, K16
**Feature file:** [`NightlifeManager/NightlifeManagerTests/Features/VenueDesigner.feature`](../../../NightlifeManager/NightlifeManagerTests/Features/VenueDesigner.feature)

## User Story
As an administrator
I want to draw the floor plan of the venue on a grid, with zones and points of interest on every floor
So that workers and guests can find their way and workers can check in to zones

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* A zone is drawn as a rectangle of grid cells
* Zones cannot overlap (a zone code must identify exactly one place)
* Zones must stay inside the grid
* Zone names are unique on a floor
* A point of interest can be placed on a cell
* A venue can have several floors, ordered by level; levels are unique
* The zone codes can be printed: every zone gets its own QR code, labelled with floor and zone name
