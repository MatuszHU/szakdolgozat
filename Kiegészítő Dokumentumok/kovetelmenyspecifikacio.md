# Követelményspecifikáció
### Majoros Máté
 ----
## Áttekintés

A program egy szórakozóhely-menedzsment rendszer, amelynek célja, hogy a munka közben felmerülő akadályokat a munkavállalók gyorsan és hatékonyan megoldhassák, a vezetőség számára áttekinthető munkabeosztást és készletkezelést nyújtson, a vendégeknek pedig egyszerű beléptetést és hasznos információkat biztosítson. A rendszer három kliensből áll: Vendég, Munkavállaló és Adminisztrátor. A három alkalmazás közös adatmodellre épül, és összhangban működik egymással.

## Jelenlegi helyzet

Jelenleg nincs a piacon olyan szoftver, amely a szórakoztatóiparban – azon belül is a szórakozóhelyeken – egyszerre szolgálná ki a munkáltatók, a munkavállalók és a vendégek igényeit. Sok szórakozóhelyen előfordul, hogy a személyzetet zaklatják, vagy az est folyamán kifogynak valamilyen eszközből, készletből, miközben a hangos zene és a tömeg megakadályozza a hatékony kommunikációt.

## Vágyálom rendszer

Az alkalmazás jövőbeli verziói nemcsak a szórakoztatóiparban, hanem a vendéglátás egyéb területein is ki tudják szolgálni a vállalkozások igényeit. További tervezett bővítések:

* Az adminisztrátori funkciók webes (React) felületen is elérhetők.
* A helyszíntervezőben meglévő alaprajz (kép) feltölthető, és a lap méretarányához igazítható.
* Beltéri helymeghatározás (pl. Bluetooth-jeladók) a QR-kódos zóna-bejelentkezés kiegészítésére.

## Prioritások

A követelmények prioritása MoSCoW-módszer szerint:

* **M** (Must) – kötelező, nélküle a rendszer nem használható
* **S** (Should) – fontos, de átmenetileg nélkülözhető
* **C** (Could) – kívánatos, ha az idő engedi

A követelmények és a hozzájuk tartozó user storyk, elfogadási forgatókönyvek és tesztek kapcsolatát a Követelmény-lefedettségi mátrix rögzíti.

## Követelménylista - Munkavállaló

| Modul | ID | Név | Prioritás | Kifejtés |
|-------|----|-----|-----------|----------|
| Felület | K1 | Üdvözlőképernyő | M | Bejelentkezés nélküli állapotban az alkalmazás üdvözlőképernyőt jelenít meg az alkalmazás nevével és a bejelentkezés gombbal. |
| Jogosultság | K2 | Bejelentkezés | M | A munkavállaló kizárólag [*Apple Account*](https://support.apple.com/hu-hu/apple-account)tal, a „[*Sign in with Apple*](https://developer.apple.com/documentation/signinwithapple)” protokollal tud bejelentkezni. Az első bejelentkezés egyben regisztráció is. Sikertelen vagy megszakított bejelentkezés esetén az alkalmazás az üdvözlőképernyőn marad. |
| Felület | K3 | Töltőképernyő | C | Hosszabb betöltés vagy nézetváltás közben az alkalmazás animált töltőképernyőt jelenít meg. |
| Felület | K4 | Kezdőképernyő | M | Sikeres bejelentkezés után, illetve bejelentkezett állapotban indítva az alkalmazás a kezdőképernyőre navigál, ahonnan az összes funkció elérhető. |
| Felület | K5 | Beosztások | M | A munkavállaló megtekintheti a saját műszakjait: időpont, szint és zóna, valamint a kiosztott feladatok. |
| Felület | K6 | Térkép | M | A munkavállaló megtekintheti a helyszín tervrajzát (ld. L7) szintenként, rajta a zónákkal, a POI-kkal, a saját munkaterületével és feladatával, valamint a többi munkavállaló hozzávetőleges pozíciójával (utolsó zóna-bejelentkezése, ld. K16). |
| Felület | K7 | Kódolvasó/jegykezelő | M | A munkavállaló egy- és kétdimenziós optikai kódokat olvashat be, amellyel jegyet ellenőriz, parkolójegyet érvényesít, információt jelenít meg a kód birtokosáról, illetve zóna-bejelentkezést végez (K16). |
| Kommunikáció | K8 | Pánik mód | M | A pánik mód aktiválásakor a rendszer push értesítést küld az összes biztonsági munkatársnak (vagy más beállított jogosultsági körnek) a munkavállaló nevéről, munkaköréről, valamint utolsó ismert zónájáról és szintjéről. Az értesítés hangja egyértelműen megkülönböztethető más értesítésektől. A címzett nyugtázhatja az értesítést. |
| Felület | K9 | Beállítások | S | A munkavállaló egy nézetben éri el az összes számára elérhető beállítást. |
| Módosítás | K10 | Profilkép | C | A munkavállaló feltöltheti és módosíthatja a profilképét. |
| Módosítás | K11 | Nyelv | S | A munkavállaló kiválaszthatja a felület nyelvét (magyar, angol, európai portugál). |
| Statisztika | K12 | Összesítés | S | A munkavállaló megtekintheti a ledolgozott óráinak számát és korábbi feladatait. |
| Kommunikáció | K13 | Értesítések | S | A munkavállaló egy listában látja a rendszer-, a felhasználói és az adminisztrátori értesítéseit. |
| Jogosultság | K14 | Kijelentkezés | M | A munkavállaló kijelentkezhet; ezután az alkalmazás az üdvözlőképernyőre tér vissza. |
| Felület | K15 | Dokumentáció és útmutató | C | Egy külön gombbal elérhető útmutató, amely bemutatja az alkalmazás funkcióit. |
| Kommunikáció | K16 | Zóna-bejelentkezés | M | A munkavállaló a kódolvasóval (K7) beolvassa a zónában kihelyezett QR-kódot, ezzel a rendszer rögzíti, melyik zónában és szinten tartózkodik. Ez a hozzávetőleges pozíciója, amíg másik zónába be nem jelentkezik, vagy a műszakja véget nem ér. Érvénytelen kód esetén hibaüzenet jelenik meg, és a pozíció nem változik. |
| Kommunikáció | K17 | Készletkérés | S | A munkavállaló jelezheti, ha valamilyen eszközből vagy készletből (pl. ital, pohár, jég) hiány van vagy várható; a kérés megjelenik az adminisztrátornál (L8, L10). |

## Követelménylista - Adminisztrátor

Az adminisztrátori kliens macOS alkalmazás (SwiftUI). A webes elérés későbbi bővítés (ld. Vágyálom rendszer).

| Modul | ID | Név | Prioritás | Kifejtés |
|-------|----|-----|-----------|----------|
| Jogosultság | L1 | Bejelentkezés | M | Az adminisztrátor kétféleképpen jelentkezhet be: [*Sign in with Apple*](https://developer.apple.com/documentation/signinwithapple) protokollal, vagy hagyományos módon felhasználónévvel és jelszóval. Hagyományos bejelentkezéskor a felhasználó csak az e-mail-címe helyi részét adja meg (a @ előtti részt), a vállalati domain rögzített (ld. L6). Adminisztrátori fiókot csak meglévő, megfelelő jogosultságú adminisztrátor hozhat létre (ld. L3). Elfelejtett jelszó esetén jogosult adminisztrátor állíthat be új, ideiglenes jelszót, amelyet az első bejelentkezéskor meg kell változtatni. |
| Felület | L2 | Főképernyő | M | Bejelentkezés után az adminisztrátor egy központi nézetből éri el az összes adminisztratív funkciót. |
| Felület | L3 | Felhasználó- és beosztáskezelő | M | Az adminisztrátor további adminisztrátorokat vehet fel (jogosultsági szinttel), kezelheti a munkavállalókat, műszakokat hozhat létre és rendelhet hozzájuk (időpont, szint, zóna, létszámkorlát, feladatok). A rendszer nem engedi, hogy egy munkavállalóhoz egymással időben átfedő műszakot rendeljenek, ilyenkor ütközési hibát jelez; az egymást közvetlenül követő műszakok (az egyik vége a másik kezdete) nem ütköznek. Betelt műszakhoz további munkavállaló nem rendelhető. |
| Felület | L4 | Térkép | M | Az adminisztrátor megtekintheti a helyszín tervrajzát (ld. L7) szintenként, rajta a munkavállalók hozzávetőleges pozíciójával (utolsó zóna-bejelentkezés, ld. K16), feladatával és munkaterületével. |
| Jogosultság | L5 | Kijelentkezés | M | Az adminisztrátor kijelentkezhet; ezután az alkalmazás a bejelentkező képernyőre tér vissza. |
| Felület | L6 | Beállítások | S | Az adminisztrátor beállíthatja a saját beállításait, valamint központilag engedélyezheti vagy tilthatja a munkavállalók számára elérhető nem alapfunkciókat. Megfelelő jogosultsággal itt állítható be a hagyományos bejelentkezéshez használt vállalati domain (ld. L1). |
| Felület | L7 | Helyszíntervező | M | Az adminisztrátor egy egyszerű rajzoló szerkesztőben készítheti el a helyszín (épület, rendezvényhelyszín) tájékozódást segítő tervrajzát. Minden szint egy méterben megadott méretű lap pontráccsal; a sokszög eszközzel tetszőleges alakú zónákat (munkaterületeket) és POI-kat (bár, mosdó, színpad, bejárat, vészkijárat stb., saját kiterjedéssel) rajzolhat, a fal eszközzel falakat húzhat. A pontok a rácshoz illeszkednek, ez kikapcsolható. Az alakzatok kijelölhetők, mozgathatók, a sarokpontjaik áthelyezhetők, és törölhetők. Egy helyszín több szintből állhat, mindegyiknek saját tervrajza van. A rendszer minden zónához egyedi, nyomtatható QR-kódot generál (ld. K16). Az elkészült tervrajz jelenik meg a K6, L4 és M5 nézetekben. |
| Statisztika | L8 | Kérelmek | S | A munkavállalók által leadott kérések és jelzések (pánikjelzések, készletkérések) tételesen, csoportosítva és kategorizálva megtekinthetők. |
| Felület | L9 | Dokumentáció és útmutató | C | Külső dokumentáció és útmutató az adminisztrátori funkciók használatához. |
| Felület | L10 | Készletkezelés | S | Az adminisztrátor nyilvántarthatja a készletet (megnevezés, kategória, mennyiség, mértékegység, minimális mennyiség), a minimum alá csökkenő tételekről értesítést kap, és a munkavállalók készletkéréseit (K17) jóváhagyhatja vagy elutasíthatja. |
| Felület | L11 | Eseménykezelés | M | Az adminisztrátor eseményeket hozhat létre (cím, leírás, időpont, helyszín, férőhely), meghatározhatja a jegytípusokat és árakat (ld. M4), valamint nyereményjátékot hirdethet (ld. M7). |

## Követelménylista - Vendég

| Modul | ID | Név | Prioritás | Kifejtés |
|-------|----|-----|-----------|----------|
| Felület | M1 | Üdvözlőképernyő | M | Bejelentkezés nélküli állapotban az alkalmazás üdvözlőképernyőt jelenít meg az alkalmazás nevével és a bejelentkezés gombbal. |
| Jogosultság | M2 | Bejelentkezés | M | A vendég kizárólag [*Apple Account*](https://support.apple.com/hu-hu/apple-account)tal, a „[*Sign in with Apple*](https://developer.apple.com/documentation/signinwithapple)” protokollal tud bejelentkezni. Az első bejelentkezés egyben regisztráció is. |
| Felület | M3 | Kezdőképernyő | M | Sikeres bejelentkezés után, illetve bejelentkezett állapotban indítva az alkalmazás a kezdőképernyőre navigál, ahonnan az összes funkció elérhető. |
| Felület | M4 | Jegyvásárlás | M | A vendég jegyet vásárolhat egy eseményre, megtekintheti a megvásárolt jegyeit, és azokat az *Apple Tárcába* (Wallet) helyezheti. A jegy a beléptetéskor a munkavállaló kódolvasójával (K7) ellenőrizhető. |
| Felület | M5 | Térkép | S | A vendég megtekintheti a rendezvényhelyszín tervrajzát (ld. L7) szintenként, a számára releváns POI-kkal (bár, mosdó, színpad, ruhatár, kijáratok). |
| Jogosultság | M6 | Kijelentkezés | M | A vendég kijelentkezhet; ezután az alkalmazás az üdvözlőképernyőre tér vissza. |
| Felület | M7 | Nyereményjáték | C | A vendég megtekintheti az aktuális nyereményjáték részleteit, és regisztrálhat a részvételre. |
| Felület | M8 | Beállítások | S | A vendég egy nézetben éri el az összes számára elérhető beállítást. |
| Módosítás | M9 | Profilkép | C | A vendég feltöltheti és módosíthatja a profilképét. |
| Módosítás | M10 | Nyelv | S | A vendég kiválaszthatja a felület nyelvét (magyar, angol, német, európai portugál, szlovák, román, horvát, ukrán). |
| Felület | M11 | Útmutató | C | Az alkalmazás a releváns helyeken beépített, grafikákkal kísért felugró útmutatót jelenít meg. |

## Nem funkcionális követelmények

| Terület | ID | Név | Prioritás | Kifejtés |
|---------|----|-----|-----------|----------|
| Platform | N1 | Célplatform | M | A munkavállalói és a vendég alkalmazás iOS 27-en vagy újabbon, az adminisztrátori alkalmazás macOS 27-en vagy újabbon fut. |
| Adat | N2 | Adattárolás és szinkronizáció | M | Az adatok a CloudKitben tárolódnak, és a három kliens között szinkronizálódnak; a helyi gyorsítótárazás SwiftData segítségével történik. |
| Biztonság | N3 | Hitelesítés és jogosultság | M | A hitelesítési adatok a kliensen a Keychainben tárolódnak. A hagyományos bejelentkezés jelszavai kizárólag sóval ellátott, erős hash-függvénnyel képzett formában tárolódnak, nyílt szövegként soha. Az adminisztrátori funkciók jogosultsági szintekhez kötöttek (felhasználó-adminisztrátor, üzletvezető, tulajdonos). |
| Adatvédelem | N4 | Pozícióadatok | M | A munkavállaló pozíciója kizárólag zóna szinten és csak műszak alatt kerül rögzítésre; folyamatos helymeghatározás nem történik. |
| Teljesítmény | N5 | Pánikjelzés kézbesítése | M | A pánikjelzés aktív hálózati kapcsolat mellett 5 másodpercen belül megérkezik a címzettekhez. |
| Használhatóság | N6 | Akadálymentesség | S | A felület támogatja a Dynamic Type-ot, a VoiceOvert és a sötét módot. |
| Használhatóság | N7 | Dizájn | S | A felület az Apple Human Interface Guidelines ajánlásait és a Liquid Glass dizájnnyelvet követi. |
| Minőség | N8 | Tesztelhetőség | M | Minden M és S prioritású funkcionális követelményhez tartozik legalább egy Gherkin nyelvű elfogadási forgatókönyv (BDD), az üzleti logikát egységtesztek fedik le (TDD), és a tesztek automatikusan futtathatók. |

## Riport

A program nem csak proof-of-concept, hanem valós problémát kíván megoldani, amellyel sok munkavállaló találkozik.

Mindhárom kliens az Apple által javasolt tervezési irányelveket követi, és a legfrissebb dizájnnyelvet (Liquid Glass) használja, amelyet 2025-ben, az iOS/iPadOS/macOS 26-os verziójával vezettek be.

#### Miért Apple/Swift és miért az Apple keretrendszerei?

Az Apple-ökoszisztéma lehetővé teszi a teljesen egységes működést és megjelenést. Emellett kiemelt figyelmet fordít a felhasználói biztonságra és az adatvédelemre, valamint összhangot teremt a front- és a backend között.

#### Miért kell a programot 3 külön alkalmazásra bontani?

Azért esett a választás három külön alkalmazásra, mert az egyes felhasználói csoportok igényei teljesen különbözőek, és nem fedik egymást. Emellett egy felhasználó valószínűleg nem tagja a másik két csoportnak, így az alkalmazások tárhelyigénye is kisebb. Míg a munkavállalói és a vendég oldalon a kompakt, bárhol használható mobilalkalmazás az optimális, addig az adminisztrátorok számára a nagy képernyős, fix munkaállomás felel meg.

#### Miért különböznek az elérhető nyelvek alkalmazásonként?

Míg a vendégek sok különböző helyről érkezhetnek, addig a munkavállalók többnyire magyarok, és kivételes esetben is feltételezhető, hogy rendelkeznek az alkalmazás használatához szükséges angoltudással.

A vendégeknél a kényelemnek kell prioritást élveznie. Sokkal egyszerűbb és gyorsabb lehet például a beléptetés a rendezvényeken, ha a vendég az anyanyelvén látja az instrukciókat.

#### Felhasználói útmutatás

A vendégek számára az útmutató az alkalmazásba építve, grafikákkal kísérve, a releváns helyeken jelenik meg.

A munkavállalók számára egy külön gombbal érhető el az útmutató, amely leírja az elérhető funkciókat.

Az adminisztrátorok eligazodását külső dokumentáció és útmutató segíti.

## Fogalomtár

A zárójelben szereplő angol kifejezések a user storykban, a forgatókönyvekben és a forráskódban használt megfelelők.

* **POI** (*Point of Interest*) » A tervrajz egy megjelölt területe, amely egy felhasználói kör számára kiemelten fontos lehet (bár, mosdó, színpad stb.); kiterjedése van, a közepén ikon jelzi a típusát.
* **Tervrajz** (*Floor plan*) » A helyszín egy szintjének sematikus, méretarányos rajza (zónák, POI-k, falak), amelyet az adminisztrátor a helyszíntervezőben (L7) készít. Nem földrajzi térkép.
* **Szint** (*Floor*) » A helyszín egy emelete; minden szintnek saját tervrajza van.
* **Zóna** (*Zone*) » A tervrajz sokszöggel kijelölt területe (pl. pult, bejárat, VIP), amelyhez munkavállaló, feladat és QR-kód tartozik.
* **Zóna-bejelentkezés** (*Zone check-in*) » A zóna QR-kódjának beolvasása, amely a munkavállaló hozzávetőleges pozícióját rögzíti.
* **Műszak** (*Shift*) » Egy időintervallum adott zónában, létszámkorláttal és feladatokkal, amelyhez munkavállalók rendelhetők.
* **Beosztás** (*Schedule*) » Egy munkavállaló műszakjainak összessége egy elszámolási időszakban.
* **Műszakütközés** (*Shift conflict*) » Két, ugyanahhoz a munkavállalóhoz rendelt műszak időben átfed. A közvetlenül egymást követő műszakok nem ütköznek.
* **Pánikjelzés** (*Panic alert*) » A pánik mód (K8) által küldött, nyugtázható riasztás.
* **Készletkérés** (*Supply request*) » A munkavállaló jelzése egy eszköz vagy készlet hiányáról.
* **Sign in with Apple** » Az Apple hitelesítési protokollja, amellyel a felhasználó Apple Accountjával jelentkezhet be.
* **Vállalati domain** (*Company domain*) » Az e-mail-címek @ utáni, rögzített része, amelyet az adminisztrátor állít be (L6); hagyományos bejelentkezéskor nem kell megadni.
* **Hagyományos bejelentkezés** (*Password sign-in*) » Felhasználónévvel (az e-mail-cím helyi részével) és jelszóval történő bejelentkezés az adminisztrátori alkalmazásban.
* **Apple Tárca** (*Apple Wallet*) » Az Apple digitális tárcája, amelyben a jegyek tárolhatók.
* **Push értesítés** » A rendszer által a készülékre küldött értesítés, amely az alkalmazás bezárt állapotában is megjelenik.
* **CloudKit** » Az Apple felhőalapú adattárolási és szinkronizációs szolgáltatása (BaaS).
* **Liquid Glass** » Az Apple 2025-ben bevezetett dizájnnyelve.
* **Apple** (*Apple Inc.*) » Amerikai székhelyű hardver- és szoftvergyártó cég.
* **Optikai kód** » Olyan információ, amelyet egy felületen vizuálisan tárolunk; ember számára nem olvasható, de gép számára gyorsan dekódolható (vonalkód, QR-kód, mátrixkód stb.). Ez a formátum viszonylag nagy mennyiségű információ tárolását teszi lehetővé kis területen (ld. [UPC – Univerzális Termékkód](https://en.wikipedia.org/wiki/Universal_Product_Code)).
* **QR-kód** (*Quick Response code*) » Kétdimenziós optikai kód; a rendszerben a zóna-bejelentkezéshez és a jegyekhez használjuk.
