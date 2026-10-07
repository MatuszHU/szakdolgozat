Feature: Authentication

  @K1 @K2 @K4
  Scenario: Successful login
    Given the app is launched for the first time
    When the user taps "Sign in with Apple"
    Then the user is taken to the home screen

  @K4
  Scenario: Already logged in
    Given the user is already authenticated
    When the app launches
    Then the user is taken directly to the home screen

  @K1 @K2
  Scenario: Failed login
    Given the app is launched
    When the user cancels the Sign in with Apple flow
    Then the user remains on the welcome screen
