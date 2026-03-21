Feature: "App megnyitva"
        Meg kell nézni, hogy az app állapota megnyitott-e, hogy authentikáció megkezdődhessen
    Scenario: "Az app nincs megnyitva"
        Given az app csak a háttérben van megnyitva
        When megpróbálok authentikálni
        Then ne lehessen
