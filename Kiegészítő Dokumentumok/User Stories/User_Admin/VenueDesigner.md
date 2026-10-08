# Venue Designer

**Requirements:** L7, K16
**Feature file:** [`NightlifeManager/NightlifeManagerTests/Features/VenueDesigner.feature`](../../../NightlifeManager/NightlifeManagerTests/Features/VenueDesigner.feature)

## User Story
As an administrator
I want to draw the floor plan of the venue freely on a sheet, with zones, points of interest and walls on every floor
So that workers and guests can find their way and workers can check in to zones

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* Every floor is a sheet with a real size in metres and a dot grid (one dot per metre)
* Zones and points of interest (bar, toilet, stage, …) are areas drawn with the polygon tool, point by point; the shape is closed by clicking its first point again
* The points snap to the dot grid; snapping can be turned off for free drawing
* Walls are lines drawn point by point with the wall tool
* Shapes may overlap (a bar can be inside a zone, zones can overlap each other)
* A shape needs at least three points, a wall at least two, and everything must stay on the sheet
* With the selection tool the topmost shape under the pointer is selected; it can be moved, reshaped by dragging one of its points, and deleted
* Zone names are unique on a floor
* A venue can have several floors, ordered by level; levels are unique
* The zone codes can be printed: every zone gets its own QR code, labelled with floor and zone name
