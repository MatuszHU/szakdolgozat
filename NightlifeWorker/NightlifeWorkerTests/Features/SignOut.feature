@K14
Feature: Sign Out
  The worker can sign out, after which the app returns to the welcome screen

  Scenario: Signing out returns to the welcome screen
    Given the worker signed in with Apple
    When the worker signs out
    Then the welcome screen is shown

  Scenario: Signing out is remembered at the next launch
    Given the worker signed in with Apple
    When the worker signs out
    And the app is restarted
    Then the welcome screen is shown

  @K4
  Scenario: A sign-in is remembered until signing out
    Given the worker signed in with Apple
    When the app is restarted
    Then the home screen is shown
