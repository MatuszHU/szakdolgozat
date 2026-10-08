Feature: Admin Access
  Administrators sign in with their username and password and can sign out

  @L1 @L2
  Scenario: Setting up the first owner
    Given the admin app has no administrators yet
    When the owner is set up as "Kiss Anna" with the username "anna" and the password "Secret-123"
    Then "Kiss Anna" is signed in as owner
    And the main screen is shown

  @L1 @L2
  Scenario: Signing in with username and password
    Given the owner "Kiss Anna" exists with the username "anna" and the password "Secret-123"
    When "anna" signs in with the password "Secret-123"
    Then the main screen is shown

  @L1 @L6
  Scenario: The company domain is fixed
    Given the owner "Kiss Anna" exists with the username "anna" and the password "Secret-123"
    And the company domain is "clubneon.hu"
    Then the e-mail address of "anna" is "anna" at "clubneon.hu"

  @L1
  Scenario: A wrong password is rejected
    Given the owner "Kiss Anna" exists with the username "anna" and the password "Secret-123"
    When "anna" signs in with the password "wrong-password"
    Then the sign-in screen shows "Wrong username or password"

  @L1
  Scenario: An unknown username gets the same answer
    Given the owner "Kiss Anna" exists with the username "anna" and the password "Secret-123"
    When "nobody" signs in with the password "Secret-123"
    Then the sign-in screen shows "Wrong username or password"

  @L1
  Scenario: A temporary password must be changed
    Given the owner "Kiss Anna" exists with the username "anna" and the password "Secret-123"
    And "anna" added "Nagy Béla" as "bela" with the role "business manager" and the temporary password "Temp-1234"
    When "bela" signs in with the password "Temp-1234"
    Then a new password must be chosen
    When the new password "Bela-5678" is chosen
    Then the main screen is shown
    And "bela" can sign in with the password "Bela-5678"

  @L5
  Scenario: Signing out
    Given the owner "Kiss Anna" exists with the username "anna" and the password "Secret-123"
    And "anna" signs in with the password "Secret-123"
    When the administrator signs out
    Then the sign-in screen is shown
