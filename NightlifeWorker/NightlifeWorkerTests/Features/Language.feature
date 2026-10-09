@K11
Feature: Language
  The worker chooses the language of the app: Hungarian, English or European Portuguese

  Scenario: The language of the phone is used by default
    When I open the language settings
    Then the chosen language is "system"

  Scenario Outline: Choosing a language
    When I choose "<language>" as the language
    Then the home screen item "Schedule" reads "<schedule>"
    And the home screen item "Notifications" reads "<notifications>"
    And the supply request confirmation reads "<sent>"

    Examples:
      | language | schedule | notifications | sent           |
      | hu       | Beosztás | Értesítések   | Kérés elküldve |
      | en       | Schedule | Notifications | Request sent   |
      | pt-PT    | Horário  | Notificações  | Pedido enviado |

  Scenario: The choice is kept after a restart
    Given I chose "en" as the language
    When the language settings are opened again
    Then the chosen language is "en"

  Scenario: Back to the language of the phone
    Given I chose "pt-PT" as the language
    When I choose "system" as the language
    Then the chosen language is "system"

  Scenario: Every text is translated
    Then every text of the app has a Hungarian, an English and a Portuguese version
