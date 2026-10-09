@M9
Feature: Guest Profile Picture
  The guest uploads and changes their profile picture

  Scenario: Choosing a photo
    When the guest chooses a photo of 2000 by 1500 pixels as profile picture
    Then the guest's profile picture is 512 by 512 pixels
    And the guest's profile picture comes from the middle of the photo

  Scenario: Replacing and removing the picture
    Given the guest chose a "red" photo as profile picture
    When the guest chooses a "blue" photo as profile picture
    Then the guest's profile picture is "blue"
    When the guest removes the profile picture
    Then the guest has no profile picture

  Scenario: Something that is not an image is refused
    Given the guest chose a "red" photo as profile picture
    When the guest chooses a file that is not an image as profile picture
    Then the profile picture screen tells the guest "The file is not an image"
    And the guest's profile picture is "red"
