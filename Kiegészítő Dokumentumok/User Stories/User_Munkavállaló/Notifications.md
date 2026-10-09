# Notifications

**Requirements:** K13, K8, K17, L3
**Feature file:** [`NightlifeWorker/NightlifeWorkerTests/Features/Notifications.feature`](../../../NightlifeWorker/NightlifeWorkerTests/Features/Notifications.feature)

## User Story
As a worker
I want to see the notifications of the system, my colleagues and the administrators in one list
So that I do not miss anything that concerns me

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* System notifications: my supply request was approved or rejected (K17)
* Notifications from colleagues: a panic alert that was sent to me (K8)
* Notifications from the administrators: I was assigned to a new shift (L3)
* All of them are in one list, newest first; the list can be filtered by kind
* New notifications are unread; one or all of them can be marked as read
* The same event never notifies twice; open requests and my own alerts do not notify
