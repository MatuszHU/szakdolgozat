# Language

**Requirements:** K11, K9
**Feature file:** [`NightlifeWorker/NightlifeWorkerTests/Features/Language.feature`](../../../NightlifeWorker/NightlifeWorkerTests/Features/Language.feature)

## User Story
As a worker
I want to choose the language of the app (Hungarian, English or European Portuguese)
So that I can use it in the language I understand best

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* By default the app follows the language of the phone
* Hungarian, English and European Portuguese can be chosen in the settings (K9), and the texts of the app change to that language
* The choice is kept after restarting the app, and the phone's language can be chosen again
* Every text of the app has a Hungarian, an English and a Portuguese version
* Names, items and other data entered by people are not translated
