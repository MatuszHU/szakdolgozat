@M10
Feature: Guest Language
  The guest chooses the language of the app from eight languages

  Scenario: The language of the phone is used by default
    When the guest opens the language settings
    Then the guest's chosen language is "system"

  Scenario Outline: Choosing a language
    When the guest chooses "<language>" as the language
    Then the home screen item "Jegyvásárlás" reads "<buy>"
    And the raffle confirmation reads "<registered>"

    Examples:
      | language | buy              | registered                              |
      | hu       | Jegyvásárlás     | Sikeresen jelentkeztél. Sok szerencsét! |
      | en       | Buy tickets      | You are registered. Good luck!          |
      | de       | Tickets kaufen   | Du nimmst teil. Viel Glück!             |
      | pt-PT    | Comprar bilhetes | Estás inscrito. Boa sorte!              |
      | sk       | Kúpiť vstupenky  | Si prihlásený. Veľa šťastia!            |
      | ro       | Cumpără bilete   | Te-ai înscris. Mult noroc!              |
      | hr       | Kupnja ulaznica  | Prijavljeni ste. Sretno!                |
      | uk       | Купити квитки    | Вас зареєстровано. Успіху!              |

  Scenario: The choice is kept after a restart
    Given the guest chose "de" as the language
    When the guest's language settings are opened again
    Then the guest's chosen language is "de"

  Scenario: Every text is translated
    Then every text of the guest app has a version in all eight languages
