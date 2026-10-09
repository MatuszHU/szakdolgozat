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
| K3 | Töltőképernyő | C | LoadingScreen | LoadingScreen: 3 forgatókönyv | SharedKit: LoadingTrackerTests | ✅ |
| K4 | Kezdőképernyő | M | Authentication, SignOut | Authentication: Already logged in; SignOut: A sign-in is remembered until signing out | AuthViewModelTests | ✅ |
| K5 | Beosztások | M | Schedule | Schedule: 6 forgatókönyv | SharedKit: WorkerScheduleTests | ⚠️ |
| K6 | Térkép | M | VenueMap | VenueMap: 4 forgatókönyv | SharedKit: MapPositionTests, VenueTests | ⚠️ |
| K7 | Kódolvasó/jegykezelő | M | CodeReader | CodeReader: 6 forgatókönyv | SharedKit: ScannedCodeTests, TicketAdmissionTests | ⚠️ |
| K8 | Pánik mód | M | PanicMode | PanicMode: 5 forgatókönyv | SharedKit: PanicTests | ⚠️ |
| K9 | Beállítások | S | Settings | Settings: 4 forgatókönyv | – | ✅ |
| K10 | Profilkép | C | ProfilePicture | ProfilePicture: 5 forgatókönyv | SharedKit: ProfilePictureTests | ⚠️ |
| K11 | Nyelv | S | Language | Language: 7 forgatókönyv (Scenario Outline-nal) | – | ✅ |
| K12 | Összesítés | S | WorkSummary | WorkSummary: 6 forgatókönyv | SharedKit: WorkerSummaryTests | ⚠️ |
| K13 | Értesítések | S | Notifications | Notifications: 6 forgatókönyv | SharedKit: NotificationInboxTests | ⚠️ |
| K14 | Kijelentkezés | M | SignOut | SignOut: 3 forgatókönyv | AuthViewModelTests, KeychainCredentialStoreTests | ✅ |
| K15 | Dokumentáció és útmutató | C | Guide | Guide: 4 forgatókönyv | – | ✅ |
| K16 | Zóna-bejelentkezés | M | ZoneCheckIn | ZoneCheckIn: 5 forgatókönyv | SharedKit: ZoneTests, WorkerPositionTests | ⚠️ |
| K17 | Készletkérés | S | SupplyRequest | SupplyRequest: 8 forgatókönyv | SharedKit: SupplyRequestTests, InventoryTests | ⚠️ |

## Adminisztrátor

| ID | Név | Prio | User story | Forgatókönyv(ek) | Egységteszt | Állapot |
|----|-----|------|------------|------------------|-------------|---------|
| L1 | Bejelentkezés | M | AdminAccess, AdminManagement | AdminAccess: 7, AdminManagement: Resetting a forgotten password | AdminCore: AdminDirectoryTests, LocalAdminBackendTests; AuthService: AuthServiceTests | ⚠️ |
| L2 | Főképernyő | M | AdminAccess | AdminAccess: Setting up the first owner, Signing in | – | ✅ |
| L3 | Felhasználó- és beosztáskezelő | M | ShiftConflict, ShiftPlanning, AdminManagement | ShiftConflict: 4, ShiftPlanning: 8, AdminManagement: 6 forgatókönyv (Manager) | SharedKit: ShiftTests, ScheduleTests, ShiftPlanTests, AdminDirectoryTests | ✅ |
| L4 | Térkép | M | StaffMap | StaffMap: 4 forgatókönyv (Manager) | SharedKit: StaffMapTests | ⚠️ |
| L5 | Kijelentkezés | M | AdminAccess | AdminAccess: Signing out | – | ✅ |
| L6 | Beállítások | S | AdminAccess, CompanySettings | AdminAccess: The company domain is fixed; CompanySettings: 4 forgatókönyv | SharedKit: AdminDirectoryTests, CompanySettingsTests | ✅ |
| L7 | Helyszíntervező | M | VenueDesigner | VenueDesigner: 18 forgatókönyv (Manager) | SharedKit: PlanGeometryTests, FloorTests, VenueTests, FloorPlanViewGeometryTests | ✅ |
| L8 | Kérelmek | S | RequestLog | RequestLog: 4 forgatókönyv (Manager) | SharedKit: RequestLogTests | ⚠️ |
| L9 | Dokumentáció és útmutató | C | – | – (C prioritás, N8 alapján nem kötelező) | – | ✅ |
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
| M7 | Nyereményjáték | C | Raffle | Raffle: 5 forgatókönyv (vendég) | SharedKit: RaffleEntryTests | ⚠️ |
| M8 | Beállítások | S | GuestSettings | GuestSettings: 3 forgatókönyv (vendég) | – | ✅ |
| M9 | Profilkép | C | GuestProfilePicture | GuestProfilePicture: 3 forgatókönyv (vendég) | SharedKit: ProfilePictureTests | ⚠️ |
| M10 | Nyelv | S | GuestLanguage | GuestLanguage: 11 forgatókönyv (Scenario Outline 8 nyelvvel) | SharedKit: LanguageSettingsTests | ✅ |
| M11 | Útmutató | C | GuestTips | GuestTips: 6 forgatókönyv (vendég) | SharedKit: GuideTipCenterTests | ✅ |

## Összesítés

| | Összes | M | Lefedett (✅) | Részleges (⚠️) |
|---|---|---|---|---|
| Munkavállaló | 17 | 9 | 8 | 9 |
| Adminisztrátor | 11 | 6 | 8 | 3 |
| Vendég | 11 | 5 | 7 | 4 |
| **Összesen** | **39** | **20** | **23** | **16** |

## Nyitott tételek

* **L1:** az adminisztrátori fiókok szabályai (első tulajdonos; felhasználónév a rögzített domainnel; legalább 8 karakteres jelszó; sózott PBKDF2-hash, konstans idejű összehasonlítás; ugyanaz a hibaüzenet hibás jelszóra és ismeretlen felhasználóra; ideiglenes jelszó kötelező cseréje; elfelejtett jelszó visszaállítása; Apple-fiók összekapcsolása e-mail alapján) és a bejelentkező felület kész. A saját hitelesítési szolgáltatás (`AuthService/`, Vapor, Bcrypt, lejáró tokenek) elkészült, a Manager a `Hitelesítés` beállításban kapcsolható rá; cím nélkül helyi módban fut. Hátravan: a valódi Sign in with Apple (fizetős fiók) és a szolgáltatás éles telepítése HTTPS mögé.
* **L3:** kész: munkatársak, műszakok, hozzárendelés, feladatok, valamint adminisztrátorok felvétele és eltávolítása jogosultsági szinttel (adminokat a tulajdonos és a felhasználó-adminisztrátor kezelhet, tulajdonost csak tulajdonos; az utolsó tulajdonos nem törölhető).
* **L6:** kész: vállalati domain (csak tulajdonos), saját jelszó módosítása a jelenlegi jelszó megerősítésével, a munkavállalói nem alapfunkciók (profilkép K10, összesítés K12, útmutató K15, készletkérés K17) központi ki- és bekapcsolása. A munkavállalói app kezdőképernyője (`HomeMenuViewModel`) a kikapcsolt funkciókat nem kínálja fel (készletkérés K17, összesítés K12, profilkép K10 és útmutató K15 a beállításokban is); a beállítások a CloudKit-szinkronnal (N2) jutnak el a telefonra.
* **K1, K2, K4, K14, M1, M2, M3, M6:** a bejelentkezés logikája (`AuthViewModel`, `CredentialStoring`, `KeychainCredentialStore`) a SharedKitben közös a munkavállalói és a vendég app között, külön Keychain-szolgáltatásnévvel. A bejelentkezés a Keychainben megmarad két indítás között, a kijelentkezés törli. A valódi Sign in with Apple folyamat fizetős Apple fejlesztői tagság nélkül nem próbálható ki (manuális teszt, ld. Tesztterv).
* **M4:** a jegyvásárlás logikája (csak meghirdetett jegytípus; a keret és a férőhely nem léphető túl; véget ért eseményre nincs vásárlás; 1–10 jegy egyszerre; elutasított fizetésnél nincs jegy; egyedi sorozatszám; a jegyeim eseménydátum szerint), a jegyek QR-kódja és felülete kész. A megvett jegyet a K7 kódolvasó logikája felismeri és egyszer beengedi (`@K7` forgatókönyv). Hátravan: valódi fizetés (Apple Pay) és Apple Tárca (fizetős fejlesztői tagság), valamint az események CloudKit-szinkronja (N2). Debug buildben tesztfizetés, Release-ben „a fizetés még nem elérhető”.
* **M11:** kész: felugró tippek grafikával (nagy szimbólum, cím, rövid leírás, „Értem” gomb) a kezdőképernyőn, a jegyvásárlásnál, a jegyeimnél, a térképen és a nyereményjátéknál; mindegyik az első látogatáskor, egyszerre egy, a már elolvasott nem jön újra (újraindítás után sem); a beállításokban a „Tippek újra” gombbal újra megjeleníthetők (M8). A tippek mind a nyolc nyelven elérhetők (M10).
* **M10:** kész: a vendég app összes szövege magyarul, angolul, németül, európai portugálul, szlovákul, románul, horvátul és ukránul (`Nightlife/Localizable.xcstrings`); a nyelv a beállításokban választható, a választás megmarad. A nyelvkezelés (`AppLanguage`, `LanguageSettings`, `LanguageView`) a SharedKitben közös a munkavállalói appal, amely csak a saját három nyelvét kínálja (K11). A teljességet egy forgatókönyv ellenőrzi.
* **M8:** kész: a vendég beállításai egy nézetben (profilkép, névjegy a bejelentkezett névvel és a verzióval, kijelentkezés megerősítéssel), a kezdőképernyő fogaskerék gombjával; a kijelentkezés ide költözött (M6).
* **M9:** a profilkép kiválasztása, cseréje és törlése kész, a munkavállalói appal közös SharedKit-kóddal (`ProfilePicture`, `ProfilePictureViewModel`, `ProfilePictureView`); a töltőképernyő (K3) a vendég appban is megjelenik. A feltöltés a CloudKittől (N2) függ.
* **M7:** a nyereményjáték logikája (a még véget nem ért események nyereményjátékai az események sorrendjében; részletek; vendégenként egy jelentkezés; az esemény után nincs jelentkezés) és a felülete kész; a Macen az eseménykezelő mutatja a jelentkezők számát (L11). A nyereményjátékok és a jelentkezések átvitele a CloudKittől (N2) függ.
* **M5:** a vendég térkép logikája (a vendég csak a neki szóló POI-kat látja: bár, mosdó, színpad, bejárat, vészkijárat, ruhatár; az egyéni pontok és a személyzeti zónák rejtettek; a földszinten nyílik; szintváltás; tervrajz nélkül tájékoztató üzenet) és felülete kész. A tervrajz eljuttatása a vendég appba a CloudKittől (N2) függ.
* **K5:** a beosztás logikája (`WorkerSchedule`: csak a saját műszakok időrendben, a kezdés napja szerint csoportosítva; szint és zóna; csak a nekem kiosztott feladatok; az aktuális és a következő műszak; a lezárult műszakok külön, a legfrissebb elöl) és a felülete (`ScheduleView`, kezdőképernyő-link) kész. A műszakterv a Macről CloudKit-szinkronnal (N2) jut el a telefonra; addig a beosztás üres.
* **K9:** kész: a beállítások egy nézetben (profilkép, útmutató, névjegy a bejelentkezett névvel és a verzióval, kijelentkezés megerősítéssel); a kikapcsolt funkciók beállításai nem jelennek meg (L6). A kezdőképernyőről a fogaskerék gombbal érhető el; a kijelentkezés ide költözött (K14).
* **K3:** kész: animált töltőképernyő az app fölött, ha egy betöltés 0,3 másodpercnél tovább tart (rövidebbnél nem villan fel), több egyidejű betöltésnél az utolsó végéig; jelenleg az indításkor és a profilkép betöltésekor és feldolgozásakor. A CloudKit-adatok betöltése (N2) ugyanezt használja majd.
* **K11:** kész: a munkavállalói app összes szövege magyarul, angolul és európai portugálul (`Localizable.xcstrings`); a nyelv a beállításokban választható (alapértelmezés: a telefon nyelve), a választás megmarad; a dátumok és számok is a választott nyelv szerint formázódnak. A teljességet egy forgatókönyv ellenőrzi (a lefordított szövegek kulcsai mindhárom nyelven azonosak). Nem fordul le: a felhasználók által megadott adat (nevek, tételek, zónák) és a pánikjelzés szövegében a munkakör neve.
* **K10:** a profilkép feldolgozása (a kép közepéből legfeljebb 512 × 512 pixeles négyzet, JPEG, a tájolás figyelembevételével; nem kép és 20 MB feletti fájl elutasítva), cseréje, törlése és helyi mentése kész. A kollégák felé való megjelenítés (feltöltés) a CloudKittől (N2) függ.
* **K15:** kész: külön útmutató gomb a kezdőképernyőn (és a beállításokban), funkciónként egy szakasz a kezdőképernyő sorrendjében; a kikapcsolt funkciók nem szerepelnek; az útmutató maga is kikapcsolható (L6).
* **K13:** az értesítések logikája (`NotificationInbox`: rendszer-értesítés az elbírált készletkérésről, felhasználói a nekem szóló pánikjelzésről, adminisztrátori az új műszak-beosztásról; egy listában, legfrissebb elöl; szűrés fajta szerint; olvasatlanok száma, egyenként és egyszerre olvasottra állítás; ugyanaz az esemény egyszer; a függő kérés és a saját riasztás nem értesít) és a felülete (lista, jelvény a kezdőképernyőn) kész. A források (műszakterv, kérések, riasztások) a CloudKittől (N2), a háttérbeli push értesítés fizetős fiókkal érkezik; az olvasottsági állapot jelenleg a memóriában van.
* **K12:** az összesítés logikája (`WorkerSummary`: ledolgozott órák a műszakokból az aktuális és az előző elszámolási időszakban és összesen; heti időszak hétfőtől, havi a naptári hónap, kétheti és egyedi napszámú időszak rögzített kezdőhétfőtől; az időszakhatáron átnyúló műszak megosztva, a folyamatban lévő a mostani időpontig; a lezárult műszakok saját feladatai, legfrissebb elöl) és a felülete kész; az adminisztrátor kikapcsolhatja (L6). A műszakterv a CloudKittől (N2) függ.
* **K17:** a készletkérés logikája (készletlista kategóriánként; tétel, mennyiség, „elfogyott” vagy „hamarosan elfogy”, a munkavállaló zónája, megjegyzés; pozitív mennyiség; tételenként egy nyitott kérés; a saját kérések állapota, legfrissebb elöl; az adminisztrátor kikapcsolhatja, L6) és a felülete kész. A kérés az adminisztrátornál a készletkezelőben (L10) és a kérelemnaplóban (L8) jelenik meg; a telefon és a Mac közötti átvitel a CloudKittől (N2) függ, addig a kérés a telefonon helyben marad.
* **K6:** a térkép logikája (szintválasztás, a munkaterület kiemelése, a munkatársak a legutóbbi zóna-bejelentkezésük zónájában, a be nem jelentkezettek külön listában) és a felülete (`VenueMapView`, a közös `FloorPlanView`-val) készen van; a helyszín és a bejelentkezések valós adatforrása (CloudKit, N2) hátravan, addig a térkép üres állapotot mutat.
* **L4:** a személyzeti térkép logikája (a munkatársak a legutóbbi zóna-bejelentkezésük zónájában; kiválasztáskor az aktív műszakból a munkaterület és a saját feladatok, valamint az aktuális pozíció; a be nem jelentkezettek listája; szintváltás) és a felülete (`StaffMapView`) készen van. A munkatársak, műszakok és bejelentkezések a Macre CloudKit (N2) nélkül nem jutnak el, addig a lista üres. A közös számítás (`StaffMap`) a K6-tal megosztott.
* **L8:** a kérelemnapló (pánikjelzések és készletkérések tételesen, legfrissebb elöl, a munkavállaló nevével; kategóriánkénti csoportosítás és darabszám; csak a nyitottak szűrése) és a felülete kész. A készletkérések a helyi készletből már megjelennek; a pánikjelzések a munkavállalói eszközökről CloudKit-szinkronnal (N2) érkeznek majd.
* **L9:** kész: `adminisztratori_utmutato.md` (az admin app összes funkciója, a jogosultsági szintek és a jelenlegi korlátok), az alkalmazás Súgó menüjéből megnyitható.
* **L10:** kész: készlettételek (egyedi név, nem negatív mennyiség és minimum), a minimum alatti tételek kiemelése és figyelmeztetés, a készletkérések jóváhagyása (levonás a készletből; nagyobb kérés a készletnél nem hagyható jóvá) és elutasítása; helyi JSON-mentés. A kérések a munkavállalói appból (K17) CloudKit-szinkronnal (N2) érkeznek majd; az „elfogyott” kérések pirossal jelöltek, a megjegyzés is látszik.
* **L11:** kész (események címmel, leírással, időponttal, helyszínnel és férőhellyel; jegytípusok árral és opcionális kerettel, a keretek összege nem lépheti túl a férőhelyet; nyereményjáték nyereménnyel; helyi JSON-mentés). Az események eljuttatása a vendég appba (M4, M7) a CloudKittől (N2) függ.
* **L7:** kész (rajzoló szerkesztő a macOS appban: méterben megadott lap pontráccsal, sokszög és fal eszköz, kikapcsolható illesztés a rácshoz, kiterjedéssel rendelkező zónák és POI-k, amelyek fedhetik egymást, kijelölés, mozgatás, sarokpont-áthelyezés, törlés; szintek, nyomtatható zónakódok, helyi JSON-mentés, a korábbi rácsos mentés betöltése). A tervrajz eljuttatása a munkavállalói és vendég appba a CloudKittől (N2) függ.
* **K7:** a kódfelismerés (jegy, zóna, ismeretlen kód), a beléptetés szabálya (csak a mai eseményre, csak egyszer) és a kamerás felület (VisionKit, kamerahasználati engedély, kezdőképernyő-link) készen van; a jegyek és zónák valós adatforrása (CloudKit, N2) és a parkolójegy-érvényesítés (nincs specifikálva) hátravan. A kamerás olvasás eszközön, manuálisan ellenőrizendő. Az M4 beléptetési része (`@M4`) ezzel előkészítve.
* **K8:** a pánikjelzés üzleti logikája (címzettek: a jogosult szerepkörű, műszakban lévő munkatársak a küldő nélkül; üzenet névvel, munkakörrel és utolsó ismert zónával, zóna nélkül is; nyugtázás: csak az első számít, a saját riasztás nem nyugtázható) és az elfogadási forgatókönyvek készen vannak. Hátravan: a `PanicAlertSending` éles (CloudKit + push) megvalósítása, a megkülönböztethető értesítési hang, a felület, valamint az N5 kézbesítési idő manuális mérése.
* **K16:** a zóna-bejelentkezés üzleti logikája (QR-tartalom értelmezése, csak műszak alatt, csak ismert zónába, műszak végén a pozíció törlődik), az elfogadási forgatókönyvek és a kamerás beolvasás (K7) készen vannak; a zónák valós adatforrása és a pozíció CloudKitbe mentése még hátravan.
* **L1:** két forgatókönyv-csoport szükséges (Sign in with Apple és jelszavas bejelentkezés); a BDD-forgatókönyvek a `LocalAdminBackend`-del, memóriabeli tárolóval futnak, a HTTP-réteget az AuthService tesztjei fedik le.
