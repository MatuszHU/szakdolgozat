# Követelmény-lefedettségi mátrix
### Majoros Máté
 ----
A mátrix a követelményspecifikáció funkcionális követelményeit köti össze a user storykkal, az elfogadási forgatókönyvekkel és az egységtesztekkel (ld. Tesztterv).

A kódban a megvalósító deklarációk ugyanezekkel az azonosítókkal annotáltak (pl. `@K7`), így a mátrix minden sora a kódig követhető: `grep -rn "@K7" --include=*.swift`.

**Állapot:** ✅ sikeres · ⚠️ részleges / javítandó · ❌ sikertelen · – még nincs

## Munkavállaló

| ID | Név | Prio | User story | Forgatókönyv(ek) | Egységteszt | Állapot |
|----|-----|------|------------|------------------|-------------|---------|
| K1 | Üdvözlőképernyő | M | Authentication | Authentication: Successful login, Failed login | – | ✅ |
| K2 | Bejelentkezés | M | Authentication | Authentication: Successful login, Failed login | – | ✅ |
| K3 | Töltőképernyő | C | – | – | – | – |
| K4 | Kezdőképernyő | M | Authentication, SignOut | Authentication: Already logged in; SignOut: A sign-in is remembered until signing out | AuthViewModelTests | ✅ |
| K5 | Beosztások | M | – | – | – | – |
| K6 | Térkép | M | VenueMap | VenueMap: 4 forgatókönyv | SharedKit: MapPositionTests, VenueTests | ⚠️ |
| K7 | Kódolvasó/jegykezelő | M | CodeReader | CodeReader: 6 forgatókönyv | SharedKit: ScannedCodeTests, TicketAdmissionTests | ⚠️ |
| K8 | Pánik mód | M | PanicMode | PanicMode: 5 forgatókönyv | SharedKit: PanicTests | ⚠️ |
| K9 | Beállítások | S | – | – | – | – |
| K10 | Profilkép | C | – | – | – | – |
| K11 | Nyelv | S | – | – | – | – |
| K12 | Összesítés | S | – | – | – | – |
| K13 | Értesítések | S | – | – | – | – |
| K14 | Kijelentkezés | M | SignOut | SignOut: 3 forgatókönyv | AuthViewModelTests, KeychainCredentialStoreTests | ✅ |
| K15 | Dokumentáció és útmutató | C | – | – | – | – |
| K16 | Zóna-bejelentkezés | M | ZoneCheckIn | ZoneCheckIn: 5 forgatókönyv | SharedKit: ZoneTests, WorkerPositionTests | ⚠️ |
| K17 | Készletkérés | S | – | – | – | – |

## Adminisztrátor

| ID | Név | Prio | User story | Forgatókönyv(ek) | Egységteszt | Állapot |
|----|-----|------|------------|------------------|-------------|---------|
| L1 | Bejelentkezés | M | – | – | – | – |
| L2 | Főképernyő | M | – | – | – | – |
| L3 | Felhasználó- és beosztáskezelő | M | ShiftConflict, ShiftPlanning | ShiftConflict: 4, ShiftPlanning: 8 forgatókönyv (Manager) | SharedKit: ShiftTests, ScheduleTests, ShiftPlanTests | ⚠️ |
| L4 | Térkép | M | StaffMap | StaffMap: 4 forgatókönyv (Manager) | SharedKit: StaffMapTests | ⚠️ |
| L5 | Kijelentkezés | M | – | – | – | – |
| L6 | Beállítások | S | – | – | – | – |
| L7 | Helyszíntervező | M | VenueDesigner | VenueDesigner: 8 forgatókönyv (Manager) | SharedKit: FloorTests, VenueTests, FloorPlanGeometryTests | ✅ |
| L8 | Kérelmek | S | – | – | – | – |
| L9 | Dokumentáció és útmutató | C | – | – | – | – |
| L10 | Készletkezelés | S | – | – | – | – |
| L11 | Eseménykezelés | M | EventManagement | EventManagement: 9 forgatókönyv (Manager) | SharedKit: EventCatalogTests | ✅ |

## Vendég

| ID | Név | Prio | User story | Forgatókönyv(ek) | Egységteszt | Állapot |
|----|-----|------|------------|------------------|-------------|---------|
| M1 | Üdvözlőképernyő | M | GuestAuthentication | GuestAuthentication: First launch shows the welcome screen | AuthenticationTests | ✅ |
| M2 | Bejelentkezés | M | GuestAuthentication | GuestAuthentication: Signing in, Cancelling the sign-in | AuthenticationTests | ✅ |
| M3 | Kezdőképernyő | M | GuestAuthentication | GuestAuthentication: Signing in, A remembered sign-in | AuthenticationTests | ✅ |
| M4 | Jegyvásárlás | M | – | – | – | – |
| M5 | Térkép | S | VenueGuide | VenueGuide: 5 forgatókönyv (vendég) | SharedKit: GuestVenueTests | ⚠️ |
| M6 | Kijelentkezés | M | GuestAuthentication | GuestAuthentication: 2 kijelentkezési forgatókönyv | AuthenticationTests | ✅ |
| M7 | Nyereményjáték | C | – | – | – | – |
| M8 | Beállítások | S | – | – | – | – |
| M9 | Profilkép | C | – | – | – | – |
| M10 | Nyelv | S | – | – | – | – |
| M11 | Útmutató | C | – | – | – | – |

## Összesítés

| | Összes | M | Lefedett (✅) | Részleges (⚠️) |
|---|---|---|---|---|
| Munkavállaló | 17 | 9 | 4 | 4 |
| Adminisztrátor | 11 | 6 | 2 | 2 |
| Vendég | 11 | 5 | 4 | 1 |
| **Összesen** | **39** | **20** | **10** | **7** |

## Nyitott tételek

* **L3:** a munkatársak felvétele, a műszakok létrehozása (idő, zóna, létszám), a hozzárendelés (betelt műszak, ütközés, ismételt hozzárendelés elutasítása), az eltávolítás és a feladatkiosztás kész (BDD + TDD + felület a Manager appban, helyi JSON-mentés). Az ütközési forgatókönyvek átkerültek a Manager tesztcéljába. Hátravan: **további adminisztrátorok felvétele jogosultsági szinttel** — ez az L1-gyel (jelszavas belépés, Vapor) együtt készül.
* **K1, K2, K4, K14, M1, M2, M3, M6:** a bejelentkezés logikája (`AuthViewModel`, `CredentialStoring`, `KeychainCredentialStore`) a SharedKitben közös a munkavállalói és a vendég app között, külön Keychain-szolgáltatásnévvel. A bejelentkezés a Keychainben megmarad két indítás között, a kijelentkezés törli. A valódi Sign in with Apple folyamat fizetős Apple fejlesztői tagság nélkül nem próbálható ki (manuális teszt, ld. Tesztterv).
* **M5:** a vendég térkép logikája (a vendég csak a neki szóló POI-kat látja: bár, mosdó, színpad, bejárat, vészkijárat, ruhatár; az egyéni pontok és a személyzeti zónák rejtettek; a földszinten nyílik; szintváltás; tervrajz nélkül tájékoztató üzenet) és felülete kész. A tervrajz eljuttatása a vendég appba a CloudKittől (N2) függ.
* **K6:** a térkép logikája (szintválasztás, a munkaterület kiemelése, a munkatársak a legutóbbi zóna-bejelentkezésük zónájában, a be nem jelentkezettek külön listában) és a felülete (`VenueMapView`, a közös `FloorPlanView`-val) készen van; a helyszín és a bejelentkezések valós adatforrása (CloudKit, N2) hátravan, addig a térkép üres állapotot mutat.
* **L4:** a személyzeti térkép logikája (a munkatársak a legutóbbi zóna-bejelentkezésük zónájában; kiválasztáskor az aktív műszakból a munkaterület és a saját feladatok, valamint az aktuális pozíció; a be nem jelentkezettek listája; szintváltás) és a felülete (`StaffMapView`) készen van. A munkatársak, műszakok és bejelentkezések a Macre CloudKit (N2) nélkül nem jutnak el, addig a lista üres. A közös számítás (`StaffMap`) a K6-tal megosztott.
* **L11:** kész (események címmel, leírással, időponttal, helyszínnel és férőhellyel; jegytípusok árral és opcionális kerettel, a keretek összege nem lépheti túl a férőhelyet; nyereményjáték nyereménnyel; helyi JSON-mentés). Az események eljuttatása a vendég appba (M4, M7) a CloudKittől (N2) függ.
* **L7:** kész (rácsszerkesztő a macOS appban, zónák, POI-k, szintek, nyomtatható zónakódok, helyi JSON-mentés). A tervrajz eljuttatása a munkavállalói és vendég appba a CloudKittől (N2) függ.
* **K7:** a kódfelismerés (jegy, zóna, ismeretlen kód), a beléptetés szabálya (csak a mai eseményre, csak egyszer) és a kamerás felület (VisionKit, kamerahasználati engedély, kezdőképernyő-link) készen van; a jegyek és zónák valós adatforrása (CloudKit, N2) és a parkolójegy-érvényesítés (nincs specifikálva) hátravan. A kamerás olvasás eszközön, manuálisan ellenőrizendő. Az M4 beléptetési része (`@M4`) ezzel előkészítve.
* **K8:** a pánikjelzés üzleti logikája (címzettek: a jogosult szerepkörű, műszakban lévő munkatársak a küldő nélkül; üzenet névvel, munkakörrel és utolsó ismert zónával, zóna nélkül is; nyugtázás: csak az első számít, a saját riasztás nem nyugtázható) és az elfogadási forgatókönyvek készen vannak. Hátravan: a `PanicAlertSending` éles (CloudKit + push) megvalósítása, a megkülönböztethető értesítési hang, a felület, valamint az N5 kézbesítési idő manuális mérése.
* **K16:** a zóna-bejelentkezés üzleti logikája (QR-tartalom értelmezése, csak műszak alatt, csak ismert zónába, műszak végén a pozíció törlődik), az elfogadási forgatókönyvek és a kamerás beolvasás (K7) készen vannak; a zónák valós adatforrása és a pozíció CloudKitbe mentése még hátravan.
* **L1:** két forgatókönyv-csoport szükséges (Sign in with Apple és jelszavas bejelentkezés); a jelszavas ág a hitelesítési szolgáltatás tesztpéldányával fut.
