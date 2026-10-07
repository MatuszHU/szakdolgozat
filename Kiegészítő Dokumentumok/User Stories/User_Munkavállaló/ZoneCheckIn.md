# Zone Check-in

**Requirements:** K16, K7, N4
**Feature file:** [`NightlifeWorker/NightlifeWorkerTests/Features/ZoneCheckIn.feature`](../../../NightlifeWorker/NightlifeWorkerTests/Features/ZoneCheckIn.feature)

## User Story
As a worker
I want to check in to a zone by scanning its QR code
So that my colleagues and the security staff know approximately where I am

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* Scanning a zone's QR code while on shift sets the worker's position to that zone
* Scanning another zone's QR code moves the worker to that zone
* Scanning a code that does not belong to a zone shows an error and keeps the position
* Checking in outside a shift is rejected (N4: position is only recorded during a shift)
* When the shift ends, the worker no longer has a position
