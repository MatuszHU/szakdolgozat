# Code Reader

**Requirements:** K7, K16, M4
**Feature file:** [`NightlifeWorker/NightlifeWorkerTests/Features/CodeReader.feature`](../../../NightlifeWorker/NightlifeWorkerTests/Features/CodeReader.feature)

## User Story
As a worker
I want to scan guests' tickets and the zone codes with one code reader
So that I can admit guests quickly and keep my position up to date

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* A valid ticket for tonight's event admits the guest, shows the guest's name and ticket type, and marks the ticket as used
* An already used ticket is rejected
* A ticket for another event is rejected and stays unused
* An unknown ticket is rejected
* A zone code checks the worker in to the zone (K16)
* A code that is neither a ticket nor a zone code is reported as unknown

## Out of scope for now
* Parking ticket validation (K7): the data model and code format are not yet specified.

## Manual verification
Camera scanning of real 1D/2D codes is verified manually on a device (see Tesztterv).
