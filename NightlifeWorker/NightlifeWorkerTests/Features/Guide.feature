@K15
Feature: Guide
  A guide behind its own button shows what the app can do

  Scenario: A section for every feature
    When I open the guide
    Then the guide has the sections "Schedule, Notifications, Code reader, Map, Supply request, Summary, Settings"

  @L6
  Scenario: Turned off features are not described
    Given the administrator turned off "supply requests"
    And the administrator turned off "statistics"
    When I open the guide
    Then the guide has the sections "Schedule, Notifications, Code reader, Map, Settings"

  Scenario: The guide has its own button
    When I open the home screen
    Then the home screen has a guide button

  @L6
  Scenario: The guide can be turned off
    Given the administrator turned off "guide"
    When I open the home screen
    Then the home screen has no guide button
