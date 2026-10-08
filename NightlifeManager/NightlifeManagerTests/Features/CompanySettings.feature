@L6
Feature: Company Settings
  Administrators manage their own settings and the workers' optional features

  Background:
    Given the owner "Kiss Anna" exists with the username "anna" and the password "Secret-123"
    And "anna" signs in with the password "Secret-123"

  Scenario: Optional worker features are on by default
    Then the worker features "profile picture, statistics, guide, supply requests" are on

  @K17
  Scenario: Switching a worker feature off and on
    When the administrator switches the worker feature "supply requests" off
    Then the worker features "profile picture, statistics, guide" are on
    When the administrator switches the worker feature "supply requests" on
    Then the worker features "profile picture, statistics, guide, supply requests" are on

  @L1
  Scenario: Changing my own password
    When the administrator changes the password from "Secret-123" to "Better-456"
    Then "anna" can sign in with the password "Better-456"

  @L1
  Scenario: A wrong current password is rejected
    When the administrator changes the password from "wrong-pass" to "Better-456"
    Then the main screen shows "The current password is wrong"
    And "anna" can sign in with the password "Secret-123"
