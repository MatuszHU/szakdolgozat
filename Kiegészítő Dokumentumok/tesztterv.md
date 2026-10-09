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
| Egységteszt (TDD) | A SharedKit modelljeinek üzleti logikája (pl. műszakütközés, létszámkorlát, készletminimum), az app-szintű logika és szolgáltatások (pl. `AuthViewModel`, Keychain-tároló), a hitelesítési szolgáltatás logikája | Swift Testing (`@Test`, `#expect`) | `SharedKit/Tests/SharedKitTests/`, `SharedKit/Tests/AdminCoreTests/`, `AuthService/Tests/AppTests/` (XCTVapor), `<App>Tests/` (az XCTest-alapú BDD mellett, ugyanabban a tesztcélban) |
| Elfogadási teszt (BDD) | A követelmények viselkedése a ViewModell rétegen keresztül, felhasználói nézőpontból megfogalmazva | CucumberSwift + XCTest | `NightlifeWorkerTests/` és `NightlifeManagerTests/` (`Features/*.feature`, lépésdefiníciók) |
| UI teszt | Kritikus folyamatok végigkattintása a valódi felületen (indítás, bejelentkezés, pánik mód) | XCUITest | `<App>UITests/` |
| Manuális teszt | Automatizáltan nem vagy nehezen tesztelhető funkciók valós eszközön | Ellenőrzőlista | Tesztjegyzőkönyv |

Az elfogadási tesztek szándékosan a ViewModell rétegen futnak, nem a felületen: így gyorsak, determinisztikusak és a felület változásától függetlenek. A külső szolgáltatások (Sign in with Apple, CloudKit, hitelesítési szolgáltatás, kamera) protokollok mögött érhetők el, a forgatókönyvek ezek tesztpéldányaival futnak (ld. Rendszerterv – Architektúra). A felület helyes bekötését a UI tesztek ellenőrzik.

### Manuálisan tesztelendő funkciók

* Valódi Sign in with Apple folyamat (K2, M2, L1) — fizetős Apple fejlesztői tagság szükséges. Addig a munkavállalói és a vendég app **Debug** buildjében a bejelentkezés gomb („Belépés (teszt)”) a valódi folyamat nélkül, egy rögzített tesztazonosítóval jelentkeztet be; a Release build a valódi Sign in with Apple gombot tartalmazza.
* Admin app: első tulajdonos létrehozása, bejelentkezés, ideiglenes jelszó cseréje, adminisztrátor felvétele, jelszó visszaállítása, kijelentkezés (L1, L2, L3, L5)
* Kijelentkezés megerősítő kérdéssel, majd újraindítás után az üdvözlőképernyő (K14)
* Jelszavas bejelentkezés a futó hitelesítési szolgáltatással (L1)
* Beosztás megnyitása a kezdőképernyőről, frissítés lehúzással (K5; valós adatokkal a CloudKit után)
* Készletkérés küldése a telefonról, a kérés állapotának követése (K17; a Macen a CloudKit után)
* Összesítés: ledolgozott órák és korábbi feladatok (K12; valós adatokkal a CloudKit után)
* Push értesítések kézbesítése és hangja (K8, N5)
* Kamerás kódolvasás és QR-kódos zóna-bejelentkezés (K7, K16)
* CloudKit-szinkronizáció több eszköz között (N2)
* Apple Tárcába helyezett jegy és valódi fizetés (M4) — fizetős Apple fejlesztői tagság szükséges; addig Debug buildben tesztfizetés
* Jegyvásárlás és a „Jegyeim” QR-kódjának beolvasása a munkavállalói kódolvasóval (M4, K7)
* Helyszíntervező: sokszög rajzolása kattintásokkal és lezárása, fal rajzolása, illesztés ki- és bekapcsolása, kijelölés, mozgatás húzással, sarokpont húzása, törlés (Delete), nagyítás, szintváltás, zónakódok nyomtatása (L7)
* Térkép megjelenítése valós adatokkal (K6, L4, M5; CloudKit után)
* Súgó → Adminisztrátori útmutató: a link megnyitja az útmutatót (L9)
* Készlet: tétel felvétele, mennyiség módosítása, alacsony készlet figyelmeztetés, kérés jóváhagyása és elutasítása (L10)
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
| Hitelesítési szolgáltatás | `cd AuthService && swift test` (macOS és Linux; a `testRemoteClientAgainstARunningServer` egy véletlen porton valódi szervert indít, és a Manager HTTP-kliensét futtatja ellene) |
| CI | GitHub Actions (`.github/workflows/ios.yml`): SharedKit-tesztek és az AuthService Linuxon (`swift:6.4-noble` konténer) kötelezők; a Worker-teszttervet a hosztolt runner iOS 27 SDK hiányában jelenleg nem tudja futtatni, ezért az helyben fut |

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
| `@` jel a lépés szövegében | ⚠️ A lexer címke kezdetének tekinti, a `@` utáni rész elveszik (pl. e-mail-cím). A forgatókönyvekben e-mail-cím helyett a részeit kell megadni. |
| A lépés kulcsszava | ⚠️ A `Given`, `When` és `Then` definíciók külön tartoznak: egy `When`-ként regisztrált szöveg egy `Given` (vagy az utána álló `And`) lépésre nem illeszkedik, hanem nem definiált lépés lesz (2026-10-09, K17). Ha egy lépés előfeltételként és műveletként is szerepel, mindkét kulcsszóval regisztrálni kell. |
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
| 2026-10-07 | 0f96fb6 | NightlifeWorkerTests | 19/19 sikeres | 6 forgatókönyv (Authentication 3, ShiftConflict 3), 18 lépés + CucumberSwift futtató. |
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
| 2026-10-08 | 9d6dc50 | CI (GitHub Actions), `master` | Sikeres | SharedKit zöld; Worker-job iOS 27 SDK hiányában nem futtatható (nem kötelező). |
| 2026-10-08 | – | SharedKitTests | 61/61 sikeres | L7 + K6: Venue, Floor, POI, ZoneCode, térképpozíciók, rácsgeometria (22 új), előbb sikertelenek. |
| 2026-10-08 | – | NightlifeManagerTests | 33/33 sikeres | Első Manager BDD: VenueDesigner, 8 forgatókönyv; mutációs ellenőrzés OK. A Manager UI-teszt az Accessibility-engedély hiánya miatt nem indult. |
| 2026-10-08 | – | NightlifeWorkerTests | 149/149 sikeres | K6: VenueMap, 4 forgatókönyv; mutációs ellenőrzés OK. |
| 2026-10-08 | – | SharedKitTests | 67/67 sikeres | L4: StaffMapTests (6 új), előbb sikertelenek. |
| 2026-10-08 | – | NightlifeManagerTests | 61/61 sikeres | L4: StaffMap, 4 forgatókönyv; mutációs ellenőrzés OK. |
| 2026-10-08 | – | NightlifeWorkerTests | 149/149 sikeres | A K6 ViewModell a közös `StaffMap`-re átállítva; a K6 forgatókönyvei változatlanul sikeresek (regressziós ellenőrzés). |
| 2026-10-08 | d994126 | CI (GitHub Actions), `l4-staff-map` | Sikeres | SharedKit zöld; a Manager- és a Worker-job iOS/macOS 27 SDK hiányában nem futtatható (nem kötelező). A workflow ezután minden ágra fut. |
| 2026-10-08 | – | SharedKitTests | 84/84 sikeres | L3: ShiftPlanTests (17 új), előbb sikertelenek. |
| 2026-10-08 | – | NightlifeManagerTests | 127/127 sikeres | L3: ShiftPlanning (8) és az átköltöztetett ShiftConflict (4) forgatókönyv; mutációs ellenőrzés OK. |
| 2026-10-08 | – | NightlifeWorkerTests | 137/137 sikeres | A ShiftConflict forgatókönyvek és a `ShiftConflictViewModel` átkerültek az admin appba (−12 lépés). |
| 2026-10-08 | 6e7c2f6 | CI (GitHub Actions), `l3-shift-planning` | Sikeres | SharedKit zöld; a Manager- és a Worker-job iOS/macOS 27 SDK hiányában nem futtatható. |
| 2026-10-08 | – | SharedKitTests | 100/100 sikeres | L11: EventCatalogTests (16 új), előbb sikertelenek. |
| 2026-10-08 | – | NightlifeManagerTests | 157/157 sikeres | L11: EventManagement, 9 forgatókönyv; mutációs ellenőrzés OK. |
| 2026-10-08 | 2a82a36 | CI (GitHub Actions), `l11-event-management` | Sikeres | SharedKit zöld; a Manager- és a Worker-job nem futtatható (SDK). |
| 2026-10-08 | – | NightlifeWorkerTests | 147/147 BDD + 7/7 egységteszt sikeres | K14: SignOut, 3 forgatókönyv; AuthViewModel- és Keychain-tesztek (előbb sikertelenek); mutációs ellenőrzés OK. |
| 2026-10-08 | – | Minden tesztcél | SharedKit 100/100, Worker 147/147 BDD + 7/7 egység + UI, Manager 157/157 sikeres | Kommentek eltávolítása (476) és követelmény-annotációk (127) után; a vendég app is lefordul. |
| 2026-10-08 | – | SharedKitTests | 106/106 sikeres | A bejelentkezés logikája a SharedKitbe költözött; AuthenticationTests (6), előbb sikertelenek. |
| 2026-10-08 | – | NightlifeTests (vendég) | 19/19 sikeres | Első vendég BDD: GuestAuthentication, 6 forgatókönyv (M1, M2, M3, M6); mutációs ellenőrzés OK. |
| 2026-10-08 | – | NightlifeWorkerTests | 147/147 BDD + 2/2 Keychain-teszt sikeres | A Worker a közös SharedKit-bejelentkezést használja; a forgatókönyvek változatlanul sikeresek (regresszió OK). |
| 2026-10-08 | – | SharedKitTests | 112/112 sikeres | M5: GuestVenueTests (6 új), előbb sikertelenek. |
| 2026-10-08 | – | NightlifeTests (vendég) | 47/47 sikeres | M5: VenueGuide, 5 forgatókönyv; mutációs ellenőrzés OK. |
| 2026-10-08 | – | SharedKitTests | 123/123 sikeres | M4: TicketSalesTests (10 új) és az `AuthViewModel.userID` tesztje, előbb sikertelenek. |
| 2026-10-08 | – | NightlifeTests (vendég) | 92/92 BDD + UI, 3/3 egységteszt sikeres | M4: TicketPurchase, 8 forgatókönyv; mutációs ellenőrzés a feature fájlban és a kódban (a nem elérhető fizetés) is OK. A 3 egységteszt a ViewModellel egy lépésben készült, ezért utólagos kódmutációval lett ellenőrizve. |
| 2026-10-08 | – | SharedKitTests | 140/140 sikeres | L1, L3: AdminDirectoryTests (17 új, PBKDF2 és jogosultságok), előbb sikertelenek. |
| 2026-10-08 | – | NightlifeManagerTests | 214/214 sikeres | L1, L2, L3, L5, L6: AdminAccess (7), AdminManagement (6). Mutációs ellenőrzés: az első választott mutáció (adminlista) a hibás művelet után is igaz maradt, ezért nem buktatott — a hibaüzenetre irányuló második mutációt a forgatókönyv elkapta. |
| 2026-10-08 | 0728b7e | CI (GitHub Actions), `l1-admin-access` | Sikeres | SharedKit zöld; az app-jobok SDK hiányában nem futtathatók. |
| 2026-10-08 | – | SharedKitTests | 146/146 sikeres | L6: CompanySettingsTests (6 új), köztük a régebbi `admins.json` adatvesztés nélküli betöltése. |
| 2026-10-08 | – | NightlifeManagerTests | sikeres | L6: CompanySettings, 4 forgatókönyv; mutációs ellenőrzés OK. |
| 2026-10-08 | – | SharedKitTests | 156/156 sikeres | L10: InventoryTests (10 új), előbb sikertelenek. |
| 2026-10-08 | – | NightlifeManagerTests | sikeres | L10: StockManagement, 7 forgatókönyv; mutációs ellenőrzés OK. |
| 2026-10-08 | – | SharedKitTests | 161/161 sikeres | L8: RequestLogTests (5 új), előbb sikertelenek. |
| 2026-10-08 | – | NightlifeManagerTests | sikeres | L8: RequestLog, 4 forgatókönyv; az első futás a lépésdefiníció időformázási hibáját mutatta (nem a termékkódét), javítás után zöld; mutációs ellenőrzés OK. |
| 2026-10-08 | – | NightlifeManager (build) | Sikeres | L9: Súgó-menü link; az útmutató URL-jének ellenőrzése közben derült ki, hogy az ékezetes útvonalat a Foundation duplán kódolná (`%2520`) — előkódolt URL-lel javítva, a cél elérhetősége ellenőrizve. |
| 2026-10-08 | – | AdminCoreTests | 34/34 sikeres (SharedKit 142/142) | L1: `LocalAdminBackendTests` (11 új: tokenkiadás, lejárat, ideiglenes jelszó, kijelentkezés, jogosultság), előbb sikertelenek. Az `AdminCore` cél leválasztása után; a `Task` modell `ShiftTask`-ra átnevezve, mert eltakarta a Swift Concurrency `Task` típusát. |
| 2026-10-08 | – | AuthServiceTests | 5/5 sikeres | L1: Vapor-szolgáltatás; a `RemoteAdminBackend` egy véletlen porton futó valódi szerver ellen. Mutációs ellenőrzés: a hibás jelszóra adott 401 400-ra rontva a teszt elbukott (várt). Kézi próba `curl`-lel: `/status`, `/setup`, token nélküli `/directory` → 401. |
| 2026-10-08 | – | NightlifeManagerTests, NightlifeWorkerTests, NightlifeTests | 296/296, 147/147, 92/92 sikeres | A Manager aszinkron `AdminBackend`-re állítva; a `ShiftTask`-átnevezés után mindhárom app regressziómentes. |
| 2026-10-08 | – | SharedKitTests | 162/162 sikeres | L7 átdolgozás (szabad rajzolás): PlanGeometryTests, FloorTests, VenueTests, FloorPlanViewGeometryTests újraírva (sokszög, fal, illesztés, legfelső alakzat, mozgatás, sarokpont, régi rácsos mentés betöltése), előbb sikertelenek (fordítási hiba). Mutációs ellenőrzés: a kijelölés sorrendjének megfordításánál (zóna a POI előtt) a teszt elbukott. |
| 2026-10-08 | – | NightlifeManagerTests | 359/359 sikeres | L7: VenueDesigner, 18 forgatókönyv (a rajzolás a ViewModellen keresztül: kattintások, lezárás, illesztés, fal, kijelölés, mozgatás, sarokpont-húzás, törlés). Mutációs ellenőrzés: kikapcsolt illesztésnél a „Points snap to the dot grid” forgatókönyv elbukott. |
| 2026-10-08 | – | NightlifeWorkerTests, NightlifeTests | 147/147, 92/92 sikeres | A K6 és M5 térkép az új tervrajzmodellel, változatlan forgatókönyvekkel (regresszió OK). |
| 2026-10-09 | – | SharedKitTests | 171/171 sikeres | K5: WorkerScheduleTests (9 új), előbb sikertelenek (fordítási hiba). Mutációs ellenőrzés: a műszak végének határesetét elrontva (`<=` helyett `<`) a teszt elbukott. |
| 2026-10-09 | – | NightlifeWorkerTests | 192/192 sikeres | K5: Schedule, 6 forgatókönyv. Mutációs ellenőrzés: ha a beosztás a kolléga feladatait is mutatja, az „Only my tasks are shown” forgatókönyv elbukott. Az Xcode először nem látta az új SharedKit-fájlt (elavult csomagfájllista a szimulátoros inkrementális buildben); egy `generic/platform=iOS Simulator` build után rendben. |
| 2026-10-09 | – | SharedKitTests | 179/179 sikeres | K17: SupplyRequestTests (8 új: sürgősség, zóna, tételenként egy nyitott kérés, saját kérések, kategóriák, régi mentés betöltése, sürgős jelölés a naplóban), előbb sikertelenek. Mutációs ellenőrzés: a nyitott kérés szabályát kivéve a teszt elbukott. |
| 2026-10-09 | – | NightlifeWorkerTests | 234/234 sikeres | K17: SupplyRequest, 8 forgatókönyv. Az első futásban a `testGherkin` nem definiált lépést jelzett: a `Given` utáni `And` lépés csak `When`-ként volt regisztrálva (ld. A CucumberSwift ellenőrzött viselkedése). Mutációs ellenőrzés: ha a kezdőképernyő a kikapcsolt funkciót is felkínálja, a „Turned off by the administrator” forgatókönyv elbukott. |
| 2026-10-09 | – | NightlifeManagerTests, NightlifeTests | sikeres, 92/92 | A készletkérés új mezői (sürgősség, megjegyzés) a Manager készletkezelőjében és kérelemnaplójában; regresszió OK. |
| 2026-10-09 | – | SharedKitTests | 188/188 sikeres | K12: WorkerSummaryTests (9 új: időszakhatárok, téli időszámítás hete, kettéosztott műszak, folyamatban lévő műszak, korábbi feladatok), előbb sikertelenek. Az első zöld futás előtt egy teszt saját hibáját javítottam: a kétheti blokkok kezdetét másodpercben vártam, ami a nyári időszámítás miatt egy órával eltér, ezért napokban ellenőrzöm. Mutációs ellenőrzés: az időszakra vágás nélkül a megosztott műszak tesztje elbukott. |
| 2026-10-09 | – | NightlifeWorkerTests | 276/276 sikeres | K12: WorkSummary, 6 forgatókönyv; a kezdőképernyő és a funkciókapcsolók lépései a közös `World`-be kerültek. Mutációs ellenőrzés: kapcsoló nélküli összesítő menüpontnál a „Turned off by the administrator” forgatókönyv elbukott. |
| 2026-10-07 | d8ef516 | CI (GitHub Actions) | SharedKit sikeres, Worker nem futtatható | A hosztolt runner legújabb Xcode-ja 26.6, iOS 27 SDK nélkül; a Worker-job ideiglenesen nem kötelező (`continue-on-error`). |
