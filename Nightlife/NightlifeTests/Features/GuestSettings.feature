@M8
Feature: Guest Settings
  The guest reaches every setting available to them in one view

  Background:
    Given the guest "Kata" is signed in to the settings

  Scenario: All settings in one view
    When the guest opens the settings
    Then the guest settings offer "Profile picture, Language, Tips, About, Sign out"

  Scenario: About the app
    When the guest opens the settings
    Then the about section says the guest is signed in as "Kata"
    And the about section shows the version of the guest app

  @M6
  Scenario: Signing out from the settings
    When the guest opens the settings
    And the guest signs out in the settings
    Then the guest app returns to the welcome screen
