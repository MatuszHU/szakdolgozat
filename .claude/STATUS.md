# Munkaállapot (Claude munkanapló)

> **Új session elején ezt a fájlt kell először elolvasni.** Minden lezárt lépés után frissítendő.
> Utolsó frissítés: 2026-10-08

## 1. Hol tartunk most

**Aktív ág:** `k7-code-reader` (a `k8-panic-mode`-ra épül, az a `k16-zone-checkin`-re, az a `master`-re).

**Folyamatban: K7 – Kódolvasó/jegykezelő** (nincs commitolva, munkafában van)
- ✅ Story: `Kiegészítő Dokumentumok/User Stories/User_Munkavállaló/CodeReader.md`
- ✅ Feature: `NightlifeWorker/NightlifeWorkerTests/Features/CodeReader.feature` (6 forgatókönyv, `@K7`, egyes `@M4`/`@K16`)
- ✅ Lépések: `NightlifeWorkerTests/CodeReaderSteps.swift` (+ `InMemoryTicketRepository` fake)
- ✅ SharedKit (TDD, előbb piros): `ScannedCode.swift`, `Ticket` bővítés (`qrPrefix`, `qrPayload`, `admit(toEvent:)`, `TicketType.displayName`), tesztek: `TicketTests.swift` → SharedKit 39/39 zöld
- ✅ Worker: `CodeReaderViewModel.swift` + `TicketRepository` protokoll → BDD zöld volt
- ⚠️ **NYITOTT KÉRDÉS a felhasználónak:** a `CodeReader.feature` 24. sora jelenleg
  `Then the code reader shows "Admitted: Nagy Éva – Standard"` — ezt NEM Claude írta (mutációs ellenőrzés közben változott meg, valószínűleg a felhasználó). Az eredeti: `Then the code reader shows "Ticket already used"`. **Engedély nélkül nem szabad visszaírni** — rá kell kérdezni.
- ⏳ Hátravan a K7-ből:
  1. a 24. sor tisztázása / visszaállítása, majd teljes tesztfuttatás
  2. kamerás felület: `CodeReaderView` (VisionKit `DataScannerViewController`), `NSCameraUsageDescription` a `NightlifeWorker/Info.plist`-be, bekötés a `HomeView`-ba (szimulátoron a szkenner nem elérhető → tájékoztató szöveg)
  3. dokumentáció: mátrix (K7 ⚠️: parkolójegy nincs specifikálva, CloudKit-tároló hiányzik), tesztjegyzőkönyv, Rendszerterv (`ScannedCode`, `TicketRepository`)
  4. helyi commit a `k7-code-reader` ágra
- Kimaradt szándékosan: parkolójegy-érvényesítés (nincs adatmodell/formátum) → nyitott kérdés a felhasználónak.

## 2. Git / push állapot

- `master` = `origin/master` = `b86a7bc`.
- **Nincs pusholva** (a felhasználó kérésére helyben maradunk, vonaton van): `54d5fcc` K16, `cf6d168` Cucumber-próba docs, `10a67d0` Cucumber expression átírás, `68f08b2` K8.
- **A push 403-mal elutasítva:** a `gh` fine-grained tokenből (github_pat_…) hiányzik a repóra a *Contents: write* és *Workflows: write* jog. A felhasználónak kell rendeznie (token jogosultság, vagy `gh auth login -w -s workflow` + `gh auth setup-git`). `gh` elérési út: `/opt/homebrew/bin/gh` (a shell PATH-jában nincs).
- Merge módja: zöld CI után fast-forward a `master`-be. Ágak követelményenként (`kNN-…`).
- Az origin-on van egy `web` ág (Svelte webes felület, „log in page”) — nem Claude-é, nem nyúlni hozzá.

## 3. CI

- `.github/workflows/ios.yml`: SharedKit job (kötelező, zöld); Worker job `continue-on-error: true`, mert a GitHub runner legújabb Xcode-ja 26.6, iOS 27 SDK nincs (naplóból megerősítve: „Unable to find a destination”). Ha a runner Xcode 27-et kap, a sor törlendő.

## 4. Tesztek (utolsó ismert állapot)

- SharedKit: `cd SharedKit && swift test` → 39/39 (K7-tel)
- Worker BDD: `xcodebuild test -workspace NightLifeApps.xcworkspace -scheme NightlifeWorker -testPlan NightlifeWorker -only-testing:NightlifeWorkerTests -destination 'platform=iOS Simulator,name=iPhone 17 Pro'` → K8 után 75/75; K7-tel 6 forgatókönyv került hozzá
- Címkeszűrés: `TEST_RUNNER_CUCUMBER_TAGS=K7 xcodebuild test …` (több címke vesszővel, VAGY)
- UI tesztek: 2/2 (lassú, ~45 s)

## 5. Követelmények állapota (lefedettségi mátrix szerint)

- ✅ K1, K2, K4 (Authentication)
- ⚠️ L3 (csak műszakütközés), K16 (zóna-bejelentkezés logika; kamera + CloudKit hiányzik), K8 (pánik logika; CloudKit/push, hang, UI hiányzik), K7 (folyamatban)
- Következő jelöltek: K6 Térkép + L7 Helyszíntervező (Floor, rács, POI adatmodell); K5 Beosztások; K14 Kijelentkezés.

## 6. Módszertan (Tesztterv szerint)

1. Követelmény (MoSCoW: előbb M) → user story (`User Stories/…`, angol) → `.feature` (angol, `@ID` címke) → lépésdefiníciók → **piros**
2. TDD: üzleti szabály a SharedKitbe, Swift Testing, előbb **piros**, majd zöld, refaktor
3. Vékony ViewModel a Worker appban; külső függőség protokoll mögött (`PanicAlertSending`, `TicketRepository`), tesztben fake
4. BDD zöld → **mutációs ellenőrzés** (egy elvárt érték ideiglenes elrontása, el kell buknia, visszaállítás)
5. Dokumentáció: mátrix, tesztjegyzőkönyv (`tesztterv.md`), Rendszerterv adatmodell → commit
- DoD és részletek: `Kiegészítő Dokumentumok/tesztterv.md`

## 7. CucumberSwift tudnivalók (próbával ellenőrizve)

- Csak **Cucumber expression** (`{int}`, `{string}`) vagy regex literál; szöveges regex részlegesen illeszkedik, és az utoljára regisztrált definíció nyer.
- `{ _, _ in }` closure esetén a szöveg Cucumber expressionként értelmeződik (a `^…$` szó szerinti).
- Egy lépésszöveg csak egyszer definiálható; közös lépések és állapot: `CommonSteps.swift` / `World`.
- Új feature lépésfüggvénye: `setupXxxSteps()` külön fájlban, meghívva a `StepDefinitions.swift` `setupSteps()`-éből.
- Sikertelen lépés utáni lépések nem futnak, de „passed”-nek látszanak; nem definiált lépést csak a `testGherkin` jelez.
- Forgatókönyvek fájlsorrendben, lépések a javított forkkal helyes sorrendben (`LocalPackages/CucumberSwiftPatched`, patch: `LocalPackages/CucumberSwiftPatched.patch`).

## 8. Döntések és szabályok (felhasználói)

- Dokumentáció: teljes autonómia. Kód: a felhasználó kifejezetten kérte, hogy Claude végezze (ebben a sessionben).
- `munkaterv.md` leadott, nem módosítható. A szakdolgozat szövegével csak az appok után foglalkozunk. PDF-export kb. 9 hónapig nem lesz — nem kell emlékeztetni.
- Admin: SwiftUI macOS app (React webes elérés később). Jelszavas admin belépéshez saját Vapor-szolgáltatás (B).
- Storyk és `.feature` angolul, dokumentumok magyarul. Platform: iOS/macOS 27.
- L7: rácsalapú helyszíntervező, több szint; pozíció = QR-os zóna-bejelentkezés.
- Commit üzenet vége: `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` (+ a rendszer által adott `Claude-Session:` sor, ha van).

## 9. Felvetett, még nem döntött ötletek

- NFC: a Wallet NFC-jegyhez Apple-engedély kell (szervezeti fiók, telepített olvasók) → szakdolgozathoz nem reális, a Vágyálomba kerülhet. **Core NFC-s zónamatrica** (K16 alternatíva) és iBeacon engedély nélkül megvalósítható — a felhasználó még nem döntött, hogy bekerüljön-e a követelmények közé.
