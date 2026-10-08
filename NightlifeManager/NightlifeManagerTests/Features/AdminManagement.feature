@L3
Feature: Admin Management
  Owners and user administrators manage the administrators

  Background:
    Given the owner "Kiss Anna" exists with the username "anna" and the password "Secret-123"
    And "anna" signs in with the password "Secret-123"

  Scenario: Adding an administrator
    When "anna" adds "Nagy Béla" as "bela" with the role "business manager" and the temporary password "Temp-1234"
    Then the administrators are "Kiss Anna (owner), Nagy Béla (business manager)"

  Scenario: Usernames are unique
    When "anna" adds "Kiss Andrea" as "anna" with the role "user admin" and the temporary password "Temp-1234"
    Then the main screen shows "The username anna is already taken"

  @N3
  Scenario: A business manager cannot manage administrators
    Given "anna" added "Nagy Béla" as "bela" with the role "business manager" and the temporary password "Temp-1234"
    And "bela" has chosen the password "Bela-5678"
    When "bela" adds "Tóth Cili" as "cili" with the role "user admin" and the temporary password "Temp-1234"
    Then the main screen shows "You are not allowed to manage administrators"

  @L1
  Scenario: Resetting a forgotten password
    Given "anna" added "Nagy Béla" as "bela" with the role "business manager" and the temporary password "Temp-1234"
    And "bela" has chosen the password "Bela-5678"
    When "anna" resets the password of "bela" to "Temp-9999"
    And "bela" signs in with the password "Temp-9999"
    Then a new password must be chosen

  Scenario: The last owner cannot be removed
    When "anna" removes "anna"
    Then the main screen shows "The last owner cannot be removed"

  Scenario: Removing an administrator
    Given "anna" added "Nagy Béla" as "bela" with the role "business manager" and the temporary password "Temp-1234"
    When "anna" removes "bela"
    Then the administrators are "Kiss Anna (owner)"
