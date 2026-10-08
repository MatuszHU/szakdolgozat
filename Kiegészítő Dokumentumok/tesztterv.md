# Tesztterv
### Majoros Máté
 ----
## Cél és hatókör

A tesztterv a rendszer (Munkavállalói, Vendég és Adminisztrátori alkalmazás, a közös SharedKit csomag, valamint a hitelesítési szolgáltatás) tesztelésének módszertanát, szintjeit, eszközeit és konvencióit rögzíti. A fejlesztés viselkedésvezérelt (BDD) és tesztvezérelt (TDD) módon történik: a követelményspecifikáció minden M és S prioritású követelményéhez elfogadási forgatókönyv tartozik (ld. N8), és az üzleti logika a megvalósítás előtt megírt egységtesztekkel fedett.

## Módszertan

A fejlesztés két egymásba ágyazott ciklusban zajlik:

**BDD – külső ciklus (követelmény szintje)**

1. A követelményspecifikáció egy követelményéhez (pl. K16) user story készül.
2. A story elfogadási feltételei Gherkin nyelvű forgatókönyvként (`.feature` fájl) kerülnek rögzítésre, a követelmény azonosítójával címkézve (pl. `@K16`).
3. A forgatókönyv lépésdefiníciói elkészülnek; a forgatókönyv ekkor még sikertelen (piros).

**TDD – belső ciklus (kód szintje)**

4. A forgatókönyvhöz szükséges üzleti logikára egységteszt készül, amely sikertelen (red).
5. A legegyszerűbb kód elkészül, amely a tesztet sikeressé teszi (green).
6. A kód tisztítása, a tesztek változatlanul sikeresek maradnak (refactor).
7. A 4–6. lépés ismétlődik, amíg a forgatókönyv sikeres nem lesz (zöld).

**Lezárás**

8. A lefedettségi mátrix frissül, a változás a fő ágba kerül.

### Definition of Done

Egy követelmény akkor tekinthető késznek, ha:

* tartozik hozzá user story és legalább egy, az azonosítójával címkézett forgatókönyv;
* minden hozzá tartozó forgatókönyv sikeres;
* az új üzleti logikát egységtesztek fedik le, amelyek a megvalósítás előtt készültek;
* az összes teszt sikeres helyben és a CI-ban is;
* a lefedettségi mátrix frissítve van.

## Tesztszintek

| Szint | Mit tesztel | Eszköz | Hol található |
|-------|-------------|--------|---------------|
| Egységteszt (TDD) | A SharedKit modelljeinek üzleti logikája (pl. műszakütközés, létszámkorlát, készletminimum), az app-szintű logika és szolgáltatások (pl. `AuthViewModel`, Keychain-tároló), a hitelesítési szolgáltatás logikája | Swift Testing (`@Test`, `#expect`) | `SharedKit/Tests/SharedKitTests/`, `<App>Tests/` (az XCTest-alapú BDD mellett, ugyanabban a tesztcélban) |
| Elfogadási teszt (BDD) | A követelmények viselkedése a ViewModell rétegen keresztül, felhasználói nézőpontból megfogalmazva | CucumberSwift + XCTest | `NightlifeWorkerTests/` és `NightlifeManagerTests/` (`Features/*.feature`, lépésdefiníciók) |
| UI teszt | Kritikus folyamatok végigkattintása a valódi felületen (indítás, bejelentkezés, pánik mód) | XCUITest | `<App>UITests/` |
| Manuális teszt | Automatizáltan nem vagy nehezen tesztelhető funkciók valós eszközön | Ellenőrzőlista | Tesztjegyzőkönyv |

Az elfogadási tesztek szándékosan a ViewModell rétegen futnak, nem a felületen: így gyorsak, determinisztikusak és a felület változásától függetlenek. A külső szolgáltatások (Sign in with Apple, CloudKit, hitelesítési szolgáltatás, kamera) protokollok mögött érhetők el, a forgatókönyvek ezek tesztpéldányaival futnak (ld. Rendszerterv – Architektúra). A felület helyes bekötését a UI tesztek ellenőrzik.

### Manuálisan tesztelendő funkciók

* Valódi Sign in with Apple folyamat (K2, M2, L1) — fizetős Apple fejlesztői tagság szükséges. Addig a munkavállalói és a vendég app **Debug** buildjében a bejelentkezés gomb („Belépés (teszt)”) a valódi folyamat nélkül, egy rögzített tesztazonosítóval jelentkeztet be; a Release build a valódi Sign in with Apple gombot tartalmazza.
* Kijelentkezés megerősítő kérdéssel, majd újraindítás után az üdvözlőképernyő (K14)
* Jelszavas bejelentkezés a futó hitelesítési szolgáltatással (L1)
* Push értesítések kézbesítése és hangja (K8, N5)
* Kamerás kódolvasás és QR-kódos zóna-bejelentkezés (K7, K16)
* CloudKit-szinkronizáció több eszköz között (N2)
* Apple Tárcába helyezett jegy és valódi fizetés (M4) — fizetős Apple fejlesztői tagság szükséges; addig Debug buildben tesztfizetés
* Jegyvásárlás és a „Jegyeim” QR-kódjának beolvasása a munkavállalói kódolvasóval (M4, K7)
* Helyszíntervező: zóna rajzolása húzással, POI lerakása, szintváltás, zónakódok nyomtatása (L7)
* Térkép megjelenítése valós adatokkal (K6, L4, M5; CloudKit után)
* Eseménykezelő: esemény létrehozása, jegytípus hozzáadása árral és kerettel, nyereményjáték meghirdetése (L11)
* Műszaktervező: munkatárs felvétele, műszak létrehozása, hozzárendelés, feladat hozzáadása, a személyzeti térképen a munkaterület és a feladat megjelenése (L3, L4)
* A macOS UI-tesztekhez a gépen engedélyezni kell az Xcode számára az akadálymentességi (Accessibility) hozzáférést; enélkül „Not authorized for performing UI testing actions” hibával leállnak

## Eszközök és környezet

| Elem | Érték |
|------|-------|
| Fejlesztőkörnyezet | Xcode, Swift 6 |
| Egységteszt | Swift Testing, XCTest |
| BDD | CucumberSwift (helyi, javított változat: `LocalPackages/CucumberSwiftPatched`) |
| Szimulátor | iPhone 17 Pro, iOS 27 |
| Vendég alkalmazás | iOS 27; BDD: `xcodebuild test -skipMacroValidation -workspace NightLifeApps.xcworkspace -scheme Nightlife -only-testing:NightlifeTests -destination 'platform=iOS Simulator,name=iPhone 17 Pro'` (megosztott séma, párhuzamosítás kikapcsolva) |
| Adminisztrátori alkalmazás | macOS 27; BDD: `xcodebuild test -workspace NightLifeApps.xcworkspace -scheme NightlifeManager -only-testing:NightlifeManagerTests -destination 'platform=macOS'` (megosztott séma, párhuzamosítás kikapcsolva; a feature fájlokat a tesztcél `Info.plist`-jének `FeaturesPath` kulcsa alapján találja meg) |
| Tesztterv (Xcode) | `NightlifeWorker.xctestplan`: betűrendes végrehajtás, párhuzamosítás kikapcsolva |
| CI | GitHub Actions (`.github/workflows/ios.yml`): SharedKit-tesztek kötelezők; a Worker-teszttervet a hosztolt runner iOS 27 SDK hiányában jelenleg nem tudja futtatni, ezért az helyben fut |

### A BDD-eszköz választása

A munkatervben BDD-eszközként a Cucumberish szerepelt. A fejlesztés során kiderült, hogy a Cucumberish a modern Xcode-verziókkal nem működik megfelelően: telepíthető, de a forgatókönyvek futtatása nem az elvártak szerint történik. Ezért a CucumberSwift került alkalmazásra, amely natív Swift könyvtár, és Swift Package Managerrel integrálható.

A CucumberSwift a forgatókönyvek lépéseit dinamikusan generált XCTest-metódusokként futtatja. Az Xcode tesztterve ezeket betűrendben hajtja végre, ami a lépéseket Given → Then → When sorrendbe rendezte. A hiba javítására a CucumberSwift helyi, módosított változata készült, amely a lépés sorszámát a metódusnév elejére illeszti (`step000_…`, `step001_…`), így a betűrend megegyezik a forgatókönyv sorrendjével. A módosítások a `LocalPackages/CucumberSwiftPatched.patch` fájlban, a lépések a `cucumberswift_local_fork_fix.txt` fájlban találhatók.

### A CucumberSwift ellenőrzött viselkedése

A CucumberSwift működését 2026-10-07-én ideiglenes próba-forgatókönyvekkel (pozitív és szándékosan hibás esetekkel) ellenőriztem a projekt saját teszttervén. A próbafájlok a vizsgálat után eltávolításra kerültek.

| Vizsgált funkció | Eredmény |
|------------------|----------|
| Lépéssorrend (14 lépés, a 10-es határon át) | ✅ A javított változatban a lépések a leírt sorrendben futnak (`step009` → `step010`). |
| Forgatókönyvek sorrendje | ✅ A `.feature` fájlbeli sorrendben futnak. |
| Background, Rule saját Backgrounddal | ✅ Minden forgatókönyv előtt lefut; a Rule-é a feature-é után. |
| And / But kulcsszó | ✅ Az előző lépés kulcsszavát örökli. |
| Scenario Outline + Examples | ✅ Minden példasor külön forgatókönyvként fut. |
| Adattábla, doc string | ✅ A lépés `dataTable`, illetve `docString` tulajdonságán keresztül elérhető. |
| Ékezetes karakterek | ✅ A lépésszövegben és a rögzített értékekben is helyesek. |
| BeforeScenario hook | ✅ Minden forgatókönyv előtt lefut. |
| Címkeszűrés (`CUCUMBER_TAGS`) | ✅ A `TEST_RUNNER_CUCUMBER_TAGS` környezeti változóval szűrhető; több címke vesszővel, VAGY-kapcsolatban; a feature-szintű címkét a forgatókönyvek öröklik. |
| Regex literál (`#/…/#`), Cucumber expression (`{int}`) | ✅ Teljes egyezéssel illeszkednek. |
| Szövegként megadott regex, a closure `match` paraméterét használva | ⚠️ **Részleges egyezés**: a regex a lépésszöveg egy részére is illeszkedik, és ha több definíció illeszkedik, **az utoljára regisztrált érvényes**, figyelmeztetés nélkül. |
| Szövegként megadott lépés, a closure paramétereit nem használva (`{ _, _ in }`) | ⚠️ A fordító ilyenkor Cucumber expressionként értelmezi (pontos egyezés), így a `^`, `$` és egyéb regex-jelek szó szerint értendők, és a lépés nem illeszkedik. |
| Sikertelen lépés utáni lépések | ⚠️ Nem futnak le, de az Xcode-riportban **sikeresként** jelennek meg. |
| Nem definiált lépés | ⚠️ A lépés saját tesztmetódusa sikeres, a hibát a `CucumberTest.testGherkin` jelzi (a javasolt lépésdefiníció kódjával). A futás így összességében sikertelen. |

## Konvenciók

* A user storyk és a `.feature` fájlok angol nyelvűek; a magyar–angol fogalmi megfeleltetést a követelményspecifikáció Fogalomtára rögzíti.
* Egy user storyhoz egy `.feature` fájl tartozik, azonos névvel (pl. `Authentication.md` ↔ `Authentication.feature`).
* Minden forgatókönyv a lefedett követelmény(ek) azonosítójával van címkézve (pl. `@K2 @K4`).
* A forgatókönyvek egyetlen forrása a `.feature` fájl; a user story erre hivatkozik, nem másolja le.
* A lépésdefiníciók a tesztelt alkalmazás kódját hívják (`@testable import`), tesztbeli másolatot nem használnak.
* Több feature által használt lépés csak egyszer, a `CommonSteps.swift`-ben definiálható, a közös állapot a `World` objektumban van (a CucumberSwift az azonos szövegű definíciók közül az utolsót használja, figyelmeztetés nélkül).
* Új forgatókönyv elkészülte után mutációs ellenőrzés: egy elvárt érték ideiglenes elrontásával meggyőződni arról, hogy a forgatókönyv valóban elbukik.
* A saját Swift-kódban nincs komment. A követelményhez kötődő deklarációk (típusok, függvények, tulajdonságok, tesztcsomagok, lépésdefiníciós függvények) a követelmény azonosítójával annotáltak, a SharedKit semmit sem generáló makróival (`@K7`, `@L3`, `@M4`, `@N8` …). Az elírt azonosító fordítási hiba; egy követelmény kódja így kereshető: `grep -rn "@K7" --include=*.swift`. Kiterjesztésre (extension) a makró nem tehető, ott a tagjai annotáltak.
* Egységteszt-elnevezés: a vizsgált viselkedést írja le (pl. `adjacentShiftsDoNotConflict`).
* Paraméter nélküli lépés: egyszerű szöveg, regex-jelek nélkül (Cucumber expressionként pontos egyezéssel illeszkedik).
* Paraméteres lépés: Cucumber expression (`{int}`, `{string}`, `{word}`, `{float}`), az értékek a `match.first(\.int)`, illetve `match.allParameters(\.string)` hívással érhetők el; regex literál (`#/…/#`) csak akkor, ha a Cucumber expression nem elég. Szöveges regex-definíció nem készül, mert az részlegesen illeszkedhet (a meglévők 2026-10-07-én átírásra kerültek).
* Sikertelen futásnál elsőként a `testGherkin` eredményét kell megnézni (nem definiált lépés), majd az első sikertelen lépést; az utána következő „sikeres” lépések valójában nem futottak le.

## Futtatás

Xcode-ban: `⌘U` a `NightlifeWorker` sémán.

Parancssorból:

    xcodebuild test -skipMacroValidation -workspace NightLifeApps.xcworkspace -scheme NightlifeWorker \
      -testPlan NightlifeWorker -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

## Hibakezelés

Ha egy hiba nem tesztből derül ki (pl. manuális tesztelés közben), először egy azt reprodukáló, sikertelen forgatókönyv vagy egységteszt készül, és csak ezután a javítás. Így a hiba visszatérését a tesztkészlet jelzi.

## Tesztjegyzőkönyv

| Dátum | Commit | Teszt cél | Eredmény | Megjegyzés |
|-------|--------|-----------|----------|------------|
| 2026-10-04 | – | NightlifeWorkerTests | Megszakítva | A futás megszakadt, teszt nem futott le. |
| 2026-10-07 | a1fa231 | NightlifeWorkerTests | 19/19 sikeres | 6 forgatókönyv (Authentication 3, ShiftConflict 3), 18 lépés + CucumberSwift futtató. |
| 2026-10-07 | – | SharedKitTests | 14/14 sikeres | Első TDD-egységtesztek (Shift, Schedule, PanicAlert, felhasználók); a modellmódosítások előtt sikertelenek voltak (red → green). |
| 2026-10-07 | – | NightlifeWorkerTests, NightlifeWorkerUITests | 22/22 + 2/2 sikeres | 7 forgatókönyv (Authentication 3, ShiftConflict 4, angol nyelvű, címkézett); a lépésdefiníciók `@testable import`-tal az alkalmazás kódját hívják. |
| 2026-10-07 | – | SharedKitTests | 23/23 sikeres | K16: Zone és WorkerPosition egységtesztek (9 új), előbb sikertelenek (red → green). |
| 2026-10-07 | – | NightlifeWorkerTests | 47/47 sikeres | K16: ZoneCheckIn feature, 5 forgatókönyv (Background-dal), előbb sikertelen (fordítási hiba) → zöld. |
| 2026-10-07 | – | NightlifeWorkerTests + próbák | 97/97, címkeszűrve 51/51 és 38/38; negatív próbák: 3 várt hiba | A CucumberSwift viselkedésének ellenőrzése (ld. A CucumberSwift ellenőrzött viselkedése); a próbák eltávolítása után 47/47 sikeres. |
| 2026-10-07 | – | NightlifeWorkerTests | 47/47 sikeres | A szöveges regex-lépésdefiníciók átírva Cucumber expressionre; nincs deprecation-figyelmeztetés, nincs nem definiált lépés. |
| 2026-10-07 | – | SharedKitTests | 32/32 sikeres | K8: PanicTests (9 új), előbb sikertelenek (red → green). |
| 2026-10-07 | – | NightlifeWorkerTests | 75/75 sikeres | K8: PanicMode feature, 5 forgatókönyv; közös lépések a `World`-be szervezve. Mutációs ellenőrzés: az elrontott elvárt üzenetnél a forgatókönyv elbukott (várt). |
| 2026-10-08 | – | SharedKitTests | 39/39 sikeres | K7: ScannedCode és jegybeléptetés tesztjei (7 új), előbb sikertelenek. |
| 2026-10-08 | – | NightlifeWorkerTests, NightlifeWorkerUITests | 113/113 + 2/2 sikeres | K7: CodeReader feature, 6 forgatókönyv; mutációs ellenőrzés: a használt jegyre adott hibás elvárásnál a forgatókönyv elbukott (várt). |
| 2026-10-08 | 04fdd15 | CI (GitHub Actions), `master` | Sikeres | SharedKit zöld; Worker-job iOS 27 SDK hiányában nem futtatható (nem kötelező). |
| 2026-10-08 | – | SharedKitTests | 61/61 sikeres | L7 + K6: Venue, Floor, POI, ZoneCode, térképpozíciók, rácsgeometria (22 új), előbb sikertelenek. |
| 2026-10-08 | – | NightlifeManagerTests | 33/33 sikeres | Első Manager BDD: VenueDesigner, 8 forgatókönyv; mutációs ellenőrzés OK. A Manager UI-teszt az Accessibility-engedély hiánya miatt nem indult. |
| 2026-10-08 | – | NightlifeWorkerTests | 149/149 sikeres | K6: VenueMap, 4 forgatókönyv; mutációs ellenőrzés OK. |
| 2026-10-08 | – | SharedKitTests | 67/67 sikeres | L4: StaffMapTests (6 új), előbb sikertelenek. |
| 2026-10-08 | – | NightlifeManagerTests | 61/61 sikeres | L4: StaffMap, 4 forgatókönyv; mutációs ellenőrzés OK. |
| 2026-10-08 | – | NightlifeWorkerTests | 149/149 sikeres | A K6 ViewModell a közös `StaffMap`-re átállítva; a K6 forgatókönyvei változatlanul sikeresek (regressziós ellenőrzés). |
| 2026-10-08 | 8f27ea8 | CI (GitHub Actions), `l4-staff-map` | Sikeres | SharedKit zöld; a Manager- és a Worker-job iOS/macOS 27 SDK hiányában nem futtatható (nem kötelező). A workflow ezután minden ágra fut. |
| 2026-10-08 | – | SharedKitTests | 84/84 sikeres | L3: ShiftPlanTests (17 új), előbb sikertelenek. |
| 2026-10-08 | – | NightlifeManagerTests | 127/127 sikeres | L3: ShiftPlanning (8) és az átköltöztetett ShiftConflict (4) forgatókönyv; mutációs ellenőrzés OK. |
| 2026-10-08 | – | NightlifeWorkerTests | 137/137 sikeres | A ShiftConflict forgatókönyvek és a `ShiftConflictViewModel` átkerültek az admin appba (−12 lépés). |
| 2026-10-08 | 8b635da | CI (GitHub Actions), `l3-shift-planning` | Sikeres | SharedKit zöld; a Manager- és a Worker-job iOS/macOS 27 SDK hiányában nem futtatható. |
| 2026-10-08 | – | SharedKitTests | 100/100 sikeres | L11: EventCatalogTests (16 új), előbb sikertelenek. |
| 2026-10-08 | – | NightlifeManagerTests | 157/157 sikeres | L11: EventManagement, 9 forgatókönyv; mutációs ellenőrzés OK. |
| 2026-10-08 | 2d1ea83 | CI (GitHub Actions), `l11-event-management` | Sikeres | SharedKit zöld; a Manager- és a Worker-job nem futtatható (SDK). |
| 2026-10-08 | – | NightlifeWorkerTests | 147/147 BDD + 7/7 egységteszt sikeres | K14: SignOut, 3 forgatókönyv; AuthViewModel- és Keychain-tesztek (előbb sikertelenek); mutációs ellenőrzés OK. |
| 2026-10-08 | – | Minden tesztcél | SharedKit 100/100, Worker 147/147 BDD + 7/7 egység + UI, Manager 157/157 sikeres | Kommentek eltávolítása (476) és követelmény-annotációk (127) után; a vendég app is lefordul. |
| 2026-10-08 | – | SharedKitTests | 106/106 sikeres | A bejelentkezés logikája a SharedKitbe költözött; AuthenticationTests (6), előbb sikertelenek. |
| 2026-10-08 | – | NightlifeTests (vendég) | 19/19 sikeres | Első vendég BDD: GuestAuthentication, 6 forgatókönyv (M1, M2, M3, M6); mutációs ellenőrzés OK. |
| 2026-10-08 | – | NightlifeWorkerTests | 147/147 BDD + 2/2 Keychain-teszt sikeres | A Worker a közös SharedKit-bejelentkezést használja; a forgatókönyvek változatlanul sikeresek (regresszió OK). |
| 2026-10-08 | – | SharedKitTests | 112/112 sikeres | M5: GuestVenueTests (6 új), előbb sikertelenek. |
| 2026-10-08 | – | NightlifeTests (vendég) | 47/47 sikeres | M5: VenueGuide, 5 forgatókönyv; mutációs ellenőrzés OK. |
| 2026-10-08 | – | SharedKitTests | 123/123 sikeres | M4: TicketSalesTests (10 új) és az `AuthViewModel.userID` tesztje, előbb sikertelenek. |
| 2026-10-08 | – | NightlifeTests (vendég) | 92/92 BDD + UI, 3/3 egységteszt sikeres | M4: TicketPurchase, 8 forgatókönyv; mutációs ellenőrzés a feature fájlban és a kódban (a nem elérhető fizetés) is OK. A 3 egységteszt a ViewModellel egy lépésben készült, ezért utólagos kódmutációval lett ellenőrizve. |
| 2026-10-07 | b86a7bc | CI (GitHub Actions) | SharedKit sikeres, Worker nem futtatható | A hosztolt runner legújabb Xcode-ja 26.6, iOS 27 SDK nélkül; a Worker-job ideiglenesen nem kötelező (`continue-on-error`). |
