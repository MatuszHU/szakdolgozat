@K9
Feature: Settings
  The worker reaches every setting available to them in one view

  Background:
    Given the worker "Anna" is signed in

  Scenario: All settings in one view
    When I open the settings
    Then the settings offer "Profile picture, Guide, About, Sign out"

  @L6
  Scenario: Settings of turned off features are hidden
    Given the administrator turned off "profile picture"
    And the administrator turned off "guide"
    When I open the settings
    Then the settings offer "About, Sign out"

  Scenario: About the app
    When I open the settings
    Then the about section says I am signed in as "Anna"
    And the about section shows the version of the app

  @K14
  Scenario: Signing out from the settings
    When I open the settings
    And I sign out in the settings
    Then the app returns to the welcome screen
