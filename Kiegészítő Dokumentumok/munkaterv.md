# Munkaterv

A program 3 főmodulra osztható. 2 mobil alkalmazás (Munkavállaló, Vendég) és 1 webapp (adminisztrátor).
A mobil alkalmazások Swift nyelvben a(z) Apple sajátfejlesztésű keretrendszereivel fog megvalósulni.
A webapp React könyvtár segítségével fog elkészülni.
Az adatok kezeléséhez CloudKit, Swift Data és Core Data lesz hasznosítva.

* A TDD XCTest (Apple Framework) segítségével valósul meg.
* A BDD Cucumberish (Cucumber for Swift/Obj-C) segítségével valósul meg.

_A TDD elvei alacson, egység szinten lesznek alkalmazva, míg BDD elveit integrációs szinten alkalmazom._

* Kliensek: iOS alkalmazás - Vendég, iOS alkalmazás - Munkavállaló, Webapp - Adminisztrátor
* Szerver: CloudKit - Adatok tárolása, Cross-platform backend, BaaS

### Folyamat:

1. Hónap:
Felület terv elkészítése, rendszerterv elkészítése minden modulhoz.
Adminisztrátor modul elkészítése, szükséges API-k elkészítése.

2. Hónap:
Mobil appok frontendjének elkészítése.

3. Hónap:
Minend modulhoz a térképfunkcionalitás elkészítése.

4. Hónap:
Kommunikációs modulok elkészítése (ld. követelmény specifikáció)

5. Hónap:
További backend elemek elkészítése.

6. Hónap:
Design megtervezése, UX fejlesztése

7. Hónap:
Dokumentáció finalizálás, refaktorálás, segédanyagok elkészítése

Ezen túl fenn maradó maradék időt hibajavításra és tesztelésre lesz fordítva.
