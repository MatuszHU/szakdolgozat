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
| L1 | Bejelentkezés | M | AdminAccess, AdminManagement | AdminAccess: 7, AdminManagement: Resetting a forgotten password | SharedKit: AdminDirectoryTests | ⚠️ |
| L2 | Főképernyő | M | AdminAccess | AdminAccess: Setting up the first owner, Signing in | – | ✅ |
| L3 | Felhasználó- és beosztáskezelő | M | ShiftConflict, ShiftPlanning, AdminManagement | ShiftConflict: 4, ShiftPlanning: 8, AdminManagement: 6 forgatókönyv (Manager) | SharedKit: ShiftTests, ScheduleTests, ShiftPlanTests, AdminDirectoryTests | ✅ |
| L4 | Térkép | M | StaffMap | StaffMap: 4 forgatókönyv (Manager) | SharedKit: StaffMapTests | ⚠️ |
| L5 | Kijelentkezés | M | AdminAccess | AdminAccess: Signing out | – | ✅ |
| L6 | Beállítások | S | AdminAccess, CompanySettings | AdminAccess: The company domain is fixed; CompanySettings: 4 forgatókönyv | SharedKit: AdminDirectoryTests, CompanySettingsTests | ✅ |
| L7 | Helyszíntervező | M | VenueDesigner | VenueDesigner: 8 forgatókönyv (Manager) | SharedKit: FloorTests, VenueTests, FloorPlanGeometryTests | ✅ |
| L8 | Kérelmek | S | – | – | – | – |
| L9 | Dokumentáció és útmutató | C | – | – | – | – |
| L10 | Készletkezelés | S | StockManagement | StockManagement: 7 forgatókönyv (Manager) | SharedKit: InventoryTests | ✅ |
| L11 | Eseménykezelés | M | EventManagement | EventManagement: 9 forgatókönyv (Manager) | SharedKit: EventCatalogTests | ✅ |

## Vendég

| ID | Név | Prio | User story | Forgatókönyv(ek) | Egységteszt | Állapot |
|----|-----|------|------------|------------------|-------------|---------|
| M1 | Üdvözlőképernyő | M | GuestAuthentication | GuestAuthentication: First launch shows the welcome screen | AuthenticationTests | ✅ |
| M2 | Bejelentkezés | M | GuestAuthentication | GuestAuthentication: Signing in, Cancelling the sign-in | AuthenticationTests | ✅ |
| M3 | Kezdőképernyő | M | GuestAuthentication | GuestAuthentication: Signing in, A remembered sign-in | AuthenticationTests | ✅ |
| M4 | Jegyvásárlás | M | TicketPurchase | TicketPurchase: 8 forgatókönyv (vendég) | SharedKit: TicketSalesTests; TicketShopViewModelTests | ⚠️ |
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
| Adminisztrátor | 11 | 6 | 7 | 2 |
| Vendég | 11 | 5 | 4 | 2 |
| **Összesen** | **39** | **20** | **15** | **8** |

## Nyitott tételek

* **L1:** az adminisztrátori fiókok szabályai (első tulajdonos; felhasználónév a rögzített domainnel; legalább 8 karakteres jelszó; sózott PBKDF2-hash, konstans idejű összehasonlítás; ugyanaz a hibaüzenet hibás jelszóra és ismeretlen felhasználóra; ideiglenes jelszó kötelező cseréje; elfelejtett jelszó visszaállítása; Apple-fiók összekapcsolása e-mail alapján) és a bejelentkező felület kész. Hátravan: a saját hitelesítési szolgáltatás (Vapor; addig a fiókok a Mac helyi `admins.json` fájljában, hash-elve), valamint a valódi Sign in with Apple (fizetős fiók).
* **L3:** kész: munkatársak, műszakok, hozzárendelés, feladatok, valamint adminisztrátorok felvétele és eltávolítása jogosultsági szinttel (adminokat a tulajdonos és a felhasználó-adminisztrátor kezelhet, tulajdonost csak tulajdonos; az utolsó tulajdonos nem törölhető).
* **L6:** kész: vállalati domain (csak tulajdonos), saját jelszó módosítása a jelenlegi jelszó megerősítésével, a munkavállalói nem alapfunkciók (profilkép K10, összesítés K12, útmutató K15, készletkérés K17) központi ki- és bekapcsolása. A kapcsolók érvényesítése a munkavállalói appban a funkciók elkészültével és a CloudKit-szinkronnal (N2) történik.
* **K1, K2, K4, K14, M1, M2, M3, M6:** a bejelentkezés logikája (`AuthViewModel`, `CredentialStoring`, `KeychainCredentialStore`) a SharedKitben közös a munkavállalói és a vendég app között, külön Keychain-szolgáltatásnévvel. A bejelentkezés a Keychainben megmarad két indítás között, a kijelentkezés törli. A valódi Sign in with Apple folyamat fizetős Apple fejlesztői tagság nélkül nem próbálható ki (manuális teszt, ld. Tesztterv).
* **M4:** a jegyvásárlás logikája (csak meghirdetett jegytípus; a keret és a férőhely nem léphető túl; véget ért eseményre nincs vásárlás; 1–10 jegy egyszerre; elutasított fizetésnél nincs jegy; egyedi sorozatszám; a jegyeim eseménydátum szerint), a jegyek QR-kódja és felülete kész. A megvett jegyet a K7 kódolvasó logikája felismeri és egyszer beengedi (`@K7` forgatókönyv). Hátravan: valódi fizetés (Apple Pay) és Apple Tárca (fizetős fejlesztői tagság), valamint az események CloudKit-szinkronja (N2). Debug buildben tesztfizetés, Release-ben „a fizetés még nem elérhető”.
* **M5:** a vendég térkép logikája (a vendég csak a neki szóló POI-kat látja: bár, mosdó, színpad, bejárat, vészkijárat, ruhatár; az egyéni pontok és a személyzeti zónák rejtettek; a földszinten nyílik; szintváltás; tervrajz nélkül tájékoztató üzenet) és felülete kész. A tervrajz eljuttatása a vendég appba a CloudKittől (N2) függ.
* **K6:** a térkép logikája (szintválasztás, a munkaterület kiemelése, a munkatársak a legutóbbi zóna-bejelentkezésük zónájában, a be nem jelentkezettek külön listában) és a felülete (`VenueMapView`, a közös `FloorPlanView`-val) készen van; a helyszín és a bejelentkezések valós adatforrása (CloudKit, N2) hátravan, addig a térkép üres állapotot mutat.
* **L4:** a személyzeti térkép logikája (a munkatársak a legutóbbi zóna-bejelentkezésük zónájában; kiválasztáskor az aktív műszakból a munkaterület és a saját feladatok, valamint az aktuális pozíció; a be nem jelentkezettek listája; szintváltás) és a felülete (`StaffMapView`) készen van. A munkatársak, műszakok és bejelentkezések a Macre CloudKit (N2) nélkül nem jutnak el, addig a lista üres. A közös számítás (`StaffMap`) a K6-tal megosztott.
* **L10:** kész: készlettételek (egyedi név, nem negatív mennyiség és minimum), a minimum alatti tételek kiemelése és figyelmeztetés, a készletkérések jóváhagyása (levonás a készletből; nagyobb kérés a készletnél nem hagyható jóvá) és elutasítása; helyi JSON-mentés. A kérések a munkavállalói appból (K17) CloudKit-szinkronnal (N2) érkeznek majd.
* **L11:** kész (események címmel, leírással, időponttal, helyszínnel és férőhellyel; jegytípusok árral és opcionális kerettel, a keretek összege nem lépheti túl a férőhelyet; nyereményjáték nyereménnyel; helyi JSON-mentés). Az események eljuttatása a vendég appba (M4, M7) a CloudKittől (N2) függ.
* **L7:** kész (rácsszerkesztő a macOS appban, zónák, POI-k, szintek, nyomtatható zónakódok, helyi JSON-mentés). A tervrajz eljuttatása a munkavállalói és vendég appba a CloudKittől (N2) függ.
* **K7:** a kódfelismerés (jegy, zóna, ismeretlen kód), a beléptetés szabálya (csak a mai eseményre, csak egyszer) és a kamerás felület (VisionKit, kamerahasználati engedély, kezdőképernyő-link) készen van; a jegyek és zónák valós adatforrása (CloudKit, N2) és a parkolójegy-érvényesítés (nincs specifikálva) hátravan. A kamerás olvasás eszközön, manuálisan ellenőrizendő. Az M4 beléptetési része (`@M4`) ezzel előkészítve.
* **K8:** a pánikjelzés üzleti logikája (címzettek: a jogosult szerepkörű, műszakban lévő munkatársak a küldő nélkül; üzenet névvel, munkakörrel és utolsó ismert zónával, zóna nélkül is; nyugtázás: csak az első számít, a saját riasztás nem nyugtázható) és az elfogadási forgatókönyvek készen vannak. Hátravan: a `PanicAlertSending` éles (CloudKit + push) megvalósítása, a megkülönböztethető értesítési hang, a felület, valamint az N5 kézbesítési idő manuális mérése.
* **K16:** a zóna-bejelentkezés üzleti logikája (QR-tartalom értelmezése, csak műszak alatt, csak ismert zónába, műszak végén a pozíció törlődik), az elfogadási forgatókönyvek és a kamerás beolvasás (K7) készen vannak; a zónák valós adatforrása és a pozíció CloudKitbe mentése még hátravan.
* **L1:** két forgatókönyv-csoport szükséges (Sign in with Apple és jelszavas bejelentkezés); a jelszavas ág a hitelesítési szolgáltatás tesztpéldányával fut.
