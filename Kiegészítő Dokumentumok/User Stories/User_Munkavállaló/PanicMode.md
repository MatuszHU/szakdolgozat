# Panic Mode

**Requirements:** K8, K16, N4
**Feature file:** [`NightlifeWorker/NightlifeWorkerTests/Features/PanicMode.feature`](../../../NightlifeWorker/NightlifeWorkerTests/Features/PanicMode.feature)

## User Story
As a worker
I want to alert the security staff with one action when I am in danger
So that help arrives quickly to where I am

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* The alert reaches every security staff member on shift, with the worker's name, role and last known zone
* The alert is sent even if the worker has not checked in to any zone yet
* A security staff member raising the alert is not notified of their own alert
* A recipient can acknowledge the alert
* Only the first acknowledgement counts

## Manual verification
The distinguishable notification sound and the delivery time (N5) are verified manually on devices (see Tesztterv).
