@K10
Feature: Profile Picture
  The worker uploads and changes their profile picture

  Scenario: Choosing a photo
    When I choose a photo of 2000 by 1500 pixels as my profile picture
    Then my profile picture is 512 by 512 pixels
    And my profile picture comes from the middle of the photo

  Scenario: A small photo is not enlarged
    When I choose a photo of 300 by 400 pixels as my profile picture
    Then my profile picture is 300 by 300 pixels

  Scenario: Replacing and removing the picture
    Given I chose a "red" photo as my profile picture
    When I choose a "blue" photo as my profile picture
    Then my profile picture is "blue"
    When I remove my profile picture
    Then I have no profile picture

  Scenario: The picture is kept after a restart
    Given I chose a "red" photo as my profile picture
    When the profile picture screen is opened again
    Then my profile picture is "red"

  Scenario: Something that is not an image is refused
    Given I chose a "red" photo as my profile picture
    When I choose a file that is not an image as my profile picture
    Then the profile picture screen says "The file is not an image"
    And my profile picture is "red"
