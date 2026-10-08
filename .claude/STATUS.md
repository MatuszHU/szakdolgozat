# Munkaállapot (Claude munkanapló)

> **Új session elején ezt a fájlt kell először elolvasni.** Minden lezárt lépés után frissítendő.
> Utolsó frissítés: 2026-10-08 (L7 logika kész)

## 1. Hol tartunk most

**Aktív ág:** `k6-l7-venue-map` (a `master` @ `64ced58`-ról). **Folyamatban: K6 + L7** (térkép és helyszíntervező).
- ✅ Manager BDD-környezet: CucumberSwift a `NightlifeManagerTests`-ben, `NightlifeManagerTests/Info.plist` (`FeaturesPath`), megosztott séma `NightlifeManager.xcscheme` (párhuzamosítás ki). Futtatás: `xcodebuild test -workspace NightLifeApps.xcworkspace -scheme NightlifeManager -only-testing:NightlifeManagerTests -destination 'platform=macOS'`
- ✅ L7 logika: story `User_Admin/VenueDesigner.md`, `VenueDesigner.feature` (8 forgatókönyv), `VenueDesignerSteps.swift`; SharedKit `Venue.swift` (Venue, Floor, POI, POIKind, ZoneCode; 17 új teszt → 56/56); Manager `VenueDesignerViewModel` + `VenueStoring` protokoll → Manager BDD 33/33, mutációs ellenőrzés OK.
- ⏳ Hátravan: L7 felület (rácsszerkesztő a macOS appban, helyi fájlos `VenueStoring`, kódlap nézet); K6 Worker térkép (story, feature, `VenueMapViewModel`, nézet); dokumentáció; CI a Manager sémára; push, merge.

## 2. Git / push állapot

- 2026-10-08: a push-jog rendben (a felhasználó javította a tokent). Pusholva: `k16-zone-checkin`, `k8-panic-mode`, `k7-code-reader` (ez utóbbin csak a STATUS commit). A `master` fast-forward → `04fdd15` (K16 + Cucumber-próba + Cucumber expression + K8 + STATUS), pusholva.
- A workflow csak `master` / `bdd-setup` pushra és `master`-re nyitott PR-ra fut, a feature-ágakra nem → a CI a `master`-en ellenőriz.
- 2026-10-08: K7 (`64ced58`) a `k7-code-reader` ágon zöld CI után (run 37799064412) fast-forwarddal a `master`-be került. `master` = `64ced58`.
- `gh` elérési út: `/opt/homebrew/bin/gh` (a shell PATH-jában nincs).
- Merge módja: zöld CI után fast-forward a `master`-be. Ágak követelményenként (`kNN-…`).
- Az origin-on van egy `web` ág (Svelte webes felület, „log in page”) — nem Claude-é, nem nyúlni hozzá.

## 3. CI

- `.github/workflows/ios.yml`: SharedKit job (kötelező, zöld); Worker job `continue-on-error: true`, mert a GitHub runner legújabb Xcode-ja 26.6, iOS 27 SDK nincs (naplóból megerősítve: „Unable to find a destination”). Ha a runner Xcode 27-et kap, a sor törlendő.
- Utolsó futás: 2026-10-08, `master` @ `04fdd15`, run 37648508478 → **sikeres** (SharedKit zöld, Worker a várt módon nem futtatható).

## 4. Tesztek (utolsó ismert állapot)

- SharedKit: `cd SharedKit && swift test` → 39/39
- Worker BDD: `xcodebuild test -workspace NightLifeApps.xcworkspace -scheme NightlifeWorker -testPlan NightlifeWorker -only-testing:NightlifeWorkerTests -destination 'platform=iOS Simulator,name=iPhone 17 Pro'` → 113/113 (K7 után)
- Címkeszűrés: `TEST_RUNNER_CUCUMBER_TAGS=K7 xcodebuild test …` (több címke vesszővel, VAGY)
- UI tesztek: 2/2 (lassú, ~45 s)

## 5. Követelmények állapota (lefedettségi mátrix szerint)

- ✅ K1, K2, K4 (Authentication)
- ⚠️ L3 (csak műszakütközés), K16 (logika + kamera kész; CloudKit hiányzik), K8 (pánik logika; CloudKit/push, hang, UI hiányzik), K7 (logika + kamera kész; CloudKit, parkolójegy hiányzik)
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

## 8/b. Korlát: nincs fizetős Apple fejlesztői fiók (2026-10-08)

- Nem érhető el: CloudKit (N2), push értesítés (K8 tényleges kézbesítése), valódi Sign in with Apple (K2), Wallet-jegy aláírás (M4).
- Ezért: fiókfüggetlen munka előnyben (SharedKit-logika, felületek, helyi adat, tesztek); a fiókfüggő szolgáltatások protokoll mögött maradnak (`PanicAlertSending`, `TicketRepository`), később köthetők be.
- Az admin→worker adatáramlás (helyszín, jegyek, műszakok) CloudKit nélkül nem működik a készülékek között → a következő munka az admin oldali funkciók logikája és felülete (pl. L7).

## 9. Felvetett, még nem döntött ötletek

- NFC: a Wallet NFC-jegyhez Apple-engedély kell (szervezeti fiók, telepített olvasók) → szakdolgozathoz nem reális, a Vágyálomba kerülhet. **Core NFC-s zónamatrica** (K16 alternatíva) és iBeacon engedély nélkül megvalósítható — a felhasználó még nem döntött, hogy bekerüljön-e a követelmények közé.
