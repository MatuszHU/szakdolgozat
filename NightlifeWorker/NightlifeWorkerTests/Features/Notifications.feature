@K13
Feature: Notifications
  The worker sees the notifications of the system, the colleagues and the administrators in one list

  Background:
    Given the notification venue has the floor "Ground floor" with the zone "Bar"
    And I am "Anna" from "security" and my colleague is "Béla", a "bartender"
    And the day is "2026-10-09"

  Scenario: Everything in one list, newest first
    Given at "20:00" I was assigned to a shift starting at "22:00" in the "Bar" zone
    And at "21:00" my request for "5 kg Ice" was "approved"
    And at "21:30" "Béla" sent a panic alert from the "Bar" zone
    When I open my notifications
    Then my notifications are:
      | kind   | title            | text                   |
      | user   | Panic alert      | Béla (bartender) – Bar |
      | system | Request approved | 5 kg Ice               |
      | admin  | New shift        | Ground floor – Bar     |

  Scenario: Reading notifications
    Given at "20:00" I was assigned to a shift starting at "22:00" in the "Bar" zone
    And at "21:00" my request for "5 kg Ice" was "rejected"
    And at "21:30" "Béla" sent a panic alert from the "Bar" zone
    When I open my notifications
    Then the number of unread notifications is 3
    When I read the "Panic alert" notification
    Then the number of unread notifications is 2
    When I mark all notifications as read
    Then the number of unread notifications is 0

  Scenario: Showing one kind only
    Given at "20:00" I was assigned to a shift starting at "22:00" in the "Bar" zone
    And at "21:00" my request for "5 kg Ice" was "approved"
    When I open my notifications
    And I show only the "admin" notifications
    Then my notifications are:
      | kind  | title     | text               |
      | admin | New shift | Ground floor – Bar |

  Scenario: Nothing is notified twice
    Given at "21:00" my request for "5 kg Ice" was "approved"
    When I open my notifications
    And I open my notifications again
    Then the number of unread notifications is 1

  Scenario: Open requests and my own alerts do not notify
    Given at "21:00" my request for "5 kg Ice" was "pending"
    And at "21:30" "Anna" sent a panic alert from the "Bar" zone
    When I open my notifications
    Then I have no notifications

  @K8
  Scenario: Panic alerts reach only the security staff
    Given my role is "bartender"
    And at "21:30" "Béla" sent a panic alert from the "Bar" zone
    When I open my notifications
    Then I have no notifications
