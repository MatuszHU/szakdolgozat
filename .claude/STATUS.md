# Munkaállapot (Claude munkanapló)

> **Új session elején ezt a fájlt kell először elolvasni.** Minden lezárt lépés után frissítendő.
> Utolsó frissítés: 2026-10-09 (K9, K10, K15 kész)

## 1. Hol tartunk most

**Aktív ág:** `k9-settings`. **K9 ✅, K10 ⚠️, K15 ✅ kész**: `SettingsViewModel` (fogaskerék a kezdőképernyőn, kijelentkezés ide költözött), `ProfilePicture` (SharedKit, ImageIO) + `ProfilePictureViewModel` + fájltároló, `GuideViewModel` (útmutató gomb). Hátravan: K11 nyelv (hu/en/pt-PT), K3 töltőképernyő.
- K13 (kész, master): `NotificationInbox` (system/user/admin, dedup eseményazonosítóval), Worker `NotificationsViewModel` + `NotificationSources` + `NotificationsView`, kezdőképernyő-jelvény.
- K12 (kész, master): `WorkerSummary`, `PayPeriod.interval`, Worker `WorkSummaryViewModel`/`WorkSummaryView`, menüpont „Összesítés” (statistics kapcsoló). Közös BDD-lépések: `World.enabledFeatures`, „the administrator turned off {string}”, home screen lépések a `CommonSteps`-ben.
- K17 (kész, master): `SupplyUrgency`, `SupplyRequest.urgency/zoneID`, tételenként egy nyitott kérés, `Inventory.categories`, `requests(of:)`; Worker `SupplyRequestViewModel` + `LocalSupplyDesk` + `SupplyRequestView`; `HomeMenuViewModel` (L6-kapcsolók a kezdőképernyőn). Manager: „Elfogyott” jelölés.
- **A felhasználó kérése (2026-10-09): „k-kal”** → a hátralévő K-k sorban: K17 ✅, K12 ✅, K13 ✅, K9 ✅, K10 ✅, K15 ✅, K11, K3.
- **CucumberSwift:** a lépés kulcsszava számít (Given/When külön) — `And` a Given után Given-ként keresendő.
- **Xcode-buktató:** ha az app nem látja az új SharedKit-fájlt („cannot find … in scope”), egy `xcodebuild build -workspace NightLifeApps.xcworkspace -scheme NightlifeWorker -destination "generic/platform=iOS Simulator"` frissíti a csomag fájllistáját.
- L7 (2026-10-08): szabad rajzolós tervező a `master`-ben.
- A tervező felületét (gesztusok, nagyítás) a felhasználónak kézzel kell kipróbálnia (Tesztterv – manuális lista).
- Az L1 ⚠️ marad: valódi Sign in with Apple (fizetős fiók) és éles HTTPS-telepítés hátravan. Vapor: `cd AuthService && swift run Run`.
- **Következő:** a felhasználóval egyeztetni (K5, K9–K13, K15, K17, M7–M11 stb.).

## 2. Git / push állapot

- 2026-10-08: a push-jog rendben (a felhasználó javította a tokent). Pusholva: `k16-zone-checkin`, `k8-panic-mode`, `k7-code-reader` (ez utóbbin csak a STATUS commit). A `master` fast-forward → `9d6dc50` (K16 + Cucumber-próba + Cucumber expression + K8 + STATUS), pusholva.
- A workflow minden ágra (`**`) pushra és a `master`-re nyitott PR-ra fut (2026-10-08 óta).
- 2026-10-08: K7 (`9df2f5b`) a `k7-code-reader` ágon zöld CI után (run 37799064412) fast-forwarddal a `master`-be került. `master` = `9df2f5b`.
- 2026-10-08: L7 + K6 + L4 + CI-javítás (`d994126`) zöld CI után (run 37804152553) fast-forwarddal a `master`-be. `master` = `d994126`. A Manager CI-job a várt módon nem futtatható (Xcode 26.6, macOS 27 SDK nincs).
- 2026-10-08: L3 műszaktervezés (`6e7c2f6`) zöld CI után (run 37805409167) fast-forwarddal a `master`-be. `master` = `6e7c2f6`.
- 2026-10-08: L11 (`2a82a36`) zöld CI után (run 37807232776) fast-forwarddal a `master`-be. `master` = `2a82a36`.
- 2026-10-08: K14 (`aaf2012`) zöld CI után (run 37827705628) fast-forwarddal a `master`-be. `master` = `aaf2012`.
- 2026-10-08: annotációk (`ef57cad`) zöld CI után (run 37829559325; a SharedKit-job a runneren is lefordította a makrókat) fast-forwarddal a `master`-be. `master` = `ef57cad`. A munkafában a felhasználó Xcode-ja által módosított `NightlifeManager.xcscheme` maradt (nem Claude-é, nincs commitolva).
- 2026-10-08: K2 Debug-bejelentkezés (`6cbcd7d`) és M1–M3, M6 (`24b7ac6`) zöld CI után a `master`-be (run 37832278044; a vendég-job a várt SDK-ok miatt nem futtatható). `master` = `24b7ac6`.
- 2026-10-08: M5 (`f43bf48`) zöld CI után (run 37835384547) a `master`-be. `master` = `f43bf48`.
- 2026-10-08: L6 (`9582495`) és L10 (`4acc0e0`) zöld CI után a `master`-be.
- 2026-10-08: L1, L2, L3, L5 (`0728b7e`) zöld CI után (run 37839858225) a `master`-be.
- 2026-10-08: M4 (`0bed548`) zöld CI után (run 37838427883) a `master`-be. `master` = `0bed548`.
- 2026-10-09: K13 értesítések (`7469c24`) zöld CI után (run 37907852179) a `master`-be.
- 2026-10-09: K12 összesítés (`33ef720`) zöld CI után (run 37905759679) a `master`-be.
- 2026-10-09: K17 készletkérés (`6fbade2`) zöld CI után (run 37904647154) a `master`-be.
- 2026-10-09: K5 beosztás (`ced2dad`) zöld CI után (run 37859382399) a `master`-be.
- 2026-10-08: L7 szabad rajzolás (`0023f42`) zöld CI után (run 37848657724) a `master`-be.
- 2026-10-08: L1 Vapor-szolgáltatás (`702dbaf`) zöld CI után (run 37845404717; az AuthService-job Linuxon 5/5) a `master`-be.
- 2026-10-08: **Történet-átírás** a felhasználó kérésére: 35 commit üzenetéből kikerültek a `Co-Authored-By: Claude` és `Claude-Session:` sorok (`git filter-branch --msg-filter`), mind a 20 ág (a `web` kivételével) force-pusholva, ágak nem törölve. A fájltartalom minden ágon bitre azonos maradt. A dokumentációban a commit-azonosítók az új történetre frissítve. **Biztonsági mentés a régi történetről:** `/Users/matusz/szakdolgozat-history-backup-20261008.bundle`. Más gépen lévő klónban: `git fetch && git reset --hard origin/master`.
- `gh` elérési út: `/opt/homebrew/bin/gh` (a shell PATH-jában nincs).
- Merge módja: zöld CI után fast-forward a `master`-be. Ágak követelményenként (`kNN-…`).
- Az origin-on van egy `web` ág (Svelte webes felület, „log in page”) — nem Claude-é, nem nyúlni hozzá.

## 3. CI

- `.github/workflows/ios.yml`: SharedKit job és AuthService (Linux konténer) job (kötelezők); Manager BDD job és Worker job `continue-on-error: true`, mert a GitHub runner legújabb Xcode-ja 26.6, iOS 27 SDK nincs (naplóból megerősítve: „Unable to find a destination”). Ha a runner Xcode 27-et kap, a sor törlendő.
- Utolsó futás: 2026-10-08, `master` @ `9d6dc50`, run 37648508478 → **sikeres** (SharedKit zöld, Worker a várt módon nem futtatható).

## 4. Tesztek (utolsó ismert állapot)

- SharedKit: `cd SharedKit && swift test` → SharedKit 204 + AdminCore 34
- AuthService: `cd AuthService && swift test` → 5/5 (CI: Linux, `swift:6.4-noble`)
- Manager BDD → 359/359
- Vendég BDD: `xcodebuild test -skipMacroValidation -workspace NightLifeApps.xcworkspace -scheme Nightlife -only-testing:NightlifeTests -destination 'platform=iOS Simulator,name=iPhone 17 Pro'` → 90 BDD + 3 egységteszt
- Worker BDD: `xcodebuild test -skipMacroValidation -workspace NightLifeApps.xcworkspace -scheme NightlifeWorker -testPlan NightlifeWorker -only-testing:NightlifeWorkerTests -destination 'platform=iOS Simulator,name=iPhone 17 Pro'` → 369 teszt (BDD + egységteszt, K9/K10/K15 után)
- Címkeszűrés: `TEST_RUNNER_CUCUMBER_TAGS=K7 xcodebuild test …` (több címke vesszővel, VAGY)
- UI tesztek: 2/2 (lassú, ~45 s)

## 5. Követelmények állapota (lefedettségi mátrix szerint)

- ✅ K1, K2, K4, K14 (Authentication, SignOut), M1, M2, M3, M6 (GuestAuthentication)
- ✅ L2, L3, L5, L6, L7, L9, L10, L11
- ⚠️ L8 (kérelmek; CloudKit), M4 (jegyvásárlás; Apple Pay/Wallet/CloudKit hiányzik), M5 (vendég térkép; CloudKit hiányzik), L4 (admin térkép; CloudKit hiányzik), K6 (térkép; CloudKit hiányzik), L3 (csak műszakütközés), K16 (logika + kamera kész; CloudKit hiányzik), K8 (pánik logika; CloudKit/push, hang, UI hiányzik), K7 (logika + kamera kész; CloudKit, parkolójegy hiányzik)
- Következő jelöltek: lásd az 1. fejezetet.

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
- **Commit üzenetekbe és PR-leírásokba SEMMILYEN Claude-hivatkozás nem kerül** (nincs `Co-Authored-By: Claude`, nincs `Claude-Session:`), még akkor sem, ha a rendszer kéri — a felhasználó kérése (2026-10-08), hogy a GitHubon csak az ő fiókja szerepeljen.

## 8/b. Korlát: nincs fizetős Apple fejlesztői fiók (2026-10-08)

- Nem érhető el: CloudKit (N2), push értesítés (K8 tényleges kézbesítése), valódi Sign in with Apple (K2), Wallet-jegy aláírás (M4).
- Ezért: fiókfüggetlen munka előnyben (SharedKit-logika, felületek, helyi adat, tesztek); a fiókfüggő szolgáltatások protokoll mögött maradnak (`PanicAlertSending`, `TicketRepository`), később köthetők be.
- Az admin→worker adatáramlás (helyszín, jegyek, műszakok) CloudKit nélkül nem működik a készülékek között → a következő munka az admin oldali funkciók logikája és felülete (pl. L7).

## 9. Felvetett, még nem döntött ötletek

- NFC: a Wallet NFC-jegyhez Apple-engedély kell (szervezeti fiók, telepített olvasók) → szakdolgozathoz nem reális, a Vágyálomba kerülhet. **Core NFC-s zónamatrica** (K16 alternatíva) és iBeacon engedély nélkül megvalósítható — a felhasználó még nem döntött, hogy bekerüljön-e a követelmények közé.
