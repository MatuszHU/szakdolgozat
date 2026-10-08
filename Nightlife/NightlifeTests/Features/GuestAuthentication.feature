Feature: Guest Authentication
  The guest signs in with Apple, stays signed in and can sign out

  @M1
  Scenario: First launch shows the welcome screen
    Given the guest app is launched for the first time
    Then the guest sees the welcome screen

  @M2 @M3
  Scenario: Signing in opens the home screen
    Given the guest app is launched for the first time
    When the guest signs in with Apple
    Then the guest sees the home screen

  @M2
  Scenario: Cancelling the sign-in keeps the welcome screen
    Given the guest app is launched for the first time
    When the guest cancels the sign-in
    Then the guest sees the welcome screen

  @M3
  Scenario: A remembered sign-in opens the home screen
    Given the guest signed in earlier
    When the guest app is restarted
    Then the guest sees the home screen

  @M6
  Scenario: Signing out returns to the welcome screen
    Given the guest signed in earlier
    When the guest signs out
    Then the guest sees the welcome screen

  @M6
  Scenario: Signing out is remembered at the next launch
    Given the guest signed in earlier
    When the guest signs out
    And the guest app is restarted
    Then the guest sees the welcome screen
