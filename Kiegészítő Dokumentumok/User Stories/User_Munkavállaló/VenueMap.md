# Venue Map

**Requirements:** K6, K16, L7
**Feature file:** [`NightlifeWorker/NightlifeWorkerTests/Features/VenueMap.feature`](../../../NightlifeWorker/NightlifeWorkerTests/Features/VenueMap.feature)

## User Story
As a worker
I want to see the floor plan of the venue with my work area and where my colleagues are
So that I can find my place and get to colleagues quickly

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* The map opens on the floor of my assigned zone and highlights it as my work area
* The zones and points of interest of the shown floor are visible
* Colleagues appear in the zone of their latest check-in; those without a check-in are listed separately
* The worker can switch between floors
