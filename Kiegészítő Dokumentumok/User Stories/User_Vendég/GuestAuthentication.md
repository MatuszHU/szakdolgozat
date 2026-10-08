# Guest Authentication

**Requirements:** M1, M2, M3, M6
**Feature file:** [`Nightlife/NightlifeTests/Features/GuestAuthentication.feature`](../../../Nightlife/NightlifeTests/Features/GuestAuthentication.feature)

## User Story
As a guest
I want to sign in with my Apple Account, stay signed in and be able to sign out
So that I can use the app without creating a separate account

## Acceptance criteria
The acceptance criteria are the scenarios of the feature file above (single source of truth):

* On first launch the welcome screen with the sign-in button is shown (M1)
* Signing in with Apple opens the home screen (M2, M3)
* Cancelling the sign-in keeps the welcome screen (M2)
* A remembered sign-in opens the home screen at launch (M3)
* Signing out returns to the welcome screen and is remembered at the next launch (M6)

## Manual verification
The real Sign in with Apple flow needs a paid Apple Developer membership; until then Debug builds offer a test sign-in button (see Tesztterv).
