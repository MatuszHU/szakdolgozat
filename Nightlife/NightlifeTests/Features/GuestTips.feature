@M11
Feature: Guest Tips
  Pop-up tips with pictures explain the app where the guest needs them

  Scenario: The first visit shows a tip
    When the guest opens the "ticket shop"
    Then a tip with a picture explains "Buying tickets"

  Scenario: A read tip is not shown again
    Given the guest opened the "ticket shop" and read the tip
    When the guest opens the "ticket shop"
    Then no tip is shown

  Scenario: Every place has its own tip
    Given the guest opened the "ticket shop" and read the tip
    When the guest opens the "map"
    Then a tip with a picture explains "Finding your way"

  Scenario: Only one tip at a time
    When the guest opens the "home screen"
    And the guest opens the "raffles"
    Then a tip with a picture explains "Welcome to Nightlife"

  Scenario: Read tips are remembered after a restart
    Given the guest opened the "my tickets" and read the tip
    When the guest app is started again
    And the guest opens the "my tickets"
    Then no tip is shown

  @M8
  Scenario: Showing the tips again
    Given the guest opened the "ticket shop" and read the tip
    When the guest asks for the tips again in the settings
    And the guest opens the "ticket shop"
    Then a tip with a picture explains "Buying tickets"
