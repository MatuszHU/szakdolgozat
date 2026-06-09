Feature: Employee welcome screen

  As a user
  I want to see a welcome screen
  So that I can log in to my employee account

  Scenario: Welcome screen is shown
    Given the application is launched
    Then I should see the title "Üdvözöljük"
    And I should see the message "A folytatáshoz kérjük jelentkezzen be munkavállalói fiókjába"
    And I should see a "Bejelentkezés" button

  Scenario: User starts login from welcome screen
    Given the welcome screen is visible
    When I tap the "Bejelentkezés" button
    Then I should be navigated to the login screen
