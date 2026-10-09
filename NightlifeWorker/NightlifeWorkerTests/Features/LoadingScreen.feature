@K3
Feature: Loading Screen
  An animated loading screen is shown while the app is busy for longer

  Scenario: A long load shows the loading screen
    Given a load starts at 0 ms
    When it is 500 ms
    Then the loading screen is shown
    When the load started at 0 ms ends at 2000 ms
    Then the loading screen is not shown

  Scenario: A short load does not flash the loading screen
    Given a load starts at 0 ms
    When it is 250 ms
    Then the loading screen is not shown
    When the load started at 0 ms ends at 280 ms
    Then the loading screen has not been shown at all

  Scenario: The loading screen stays until every load has ended
    Given a load starts at 0 ms
    And a load starts at 200 ms
    When the load started at 0 ms ends at 1000 ms
    Then the loading screen is shown
    When the load started at 200 ms ends at 1500 ms
    Then the loading screen is not shown
