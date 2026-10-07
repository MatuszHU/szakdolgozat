Feature: Shift Conflict Detection
  A rendszer jelzi, ha egy worker beosztása ütközik egy meglévő műszakkal

  Scenario: Ütköző műszak hozzárendelése
    Given a workernek van egy műszakja 20:00-tól 02:00-ig
    When hozzárendelik 21:00-tól 23:00-ig
    Then ütközési hiba jelenik meg

  Scenario: Nem ütköző műszak hozzárendelése
    Given a workernek van egy műszakja 20:00-tól 22:00-ig
    When hozzárendelik 23:00-tól 01:00-ig
    Then a műszak sikeresen hozzárendelve

  Scenario: Pontosan egymás után következő műszakok
    Given a workernek van egy műszakja 20:00-tól 22:00-ig
    When hozzárendelik 22:00-tól 00:00-ig
    Then a műszak sikeresen hozzárendelve
