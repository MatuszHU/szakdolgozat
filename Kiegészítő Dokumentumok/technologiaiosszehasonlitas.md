# Technológiai Összehasonlítás
### Majoros Máté
 ----
## Magas szintű technológiai összehasonlítás

| Szempont | Flutter | React Native | Xcode (Swift, SwiftUI) | Android Studio (Java/Kotlin) |
|----------|---------|--------------|------------------------|------------------------------|
| Célplatform | iOS, Android, Web, Desktop | iOS, Android, Web (elsősorban mobil) | iOS, iPadOS, macOS, watchOS, tvOS (csak Apple) | Android (natív), részben multiplatform (KMP) |
| UI renderelés | Saját renderelőmotor (Skia / Impeller) | JS kód + natív nézetek bridge-en keresztül | Natív UIKit / SwiftUI komponensek, rendszerszintű renderelés | Natív Android View / Compose, rendszerszintű renderelés |
| Nyelv | Dart | JavaScript / TypeScript | Swift, SwiftUI deklaratív DSL | Java, Kotlin |
| Teljesítmény | Közel natív, de extra motorréteggel | Jó, de bridge-overheaddel | Natív, közvetlenül az Apple SDK-kra épül | Natív Android teljesítmény |
| Platform-API-k elérése | Platform channel + natív pluginek | Natív modul + bridge | Közvetlen hozzáférés minden új Apple API-hoz (pl. Sign in with Apple) | Közvetlen hozzáférés az Android API-khoz |
| Dizájnirányelvek követése | Material / saját téma, iOS-en „emulált” felület | Platformos megjelenés változó pontossággal | Human Interface Guidelines, Liquid Glass natívan követhető | Material Design natívan |
| Multiplatform előny | Egy kódbázis több platformra | Egy kódbázis több platformra | Csak Apple-platformok, de mély integráció | Android-központú, KMP-vel megosztható logika |
| Ökoszisztéma, eszközök | flutter CLI, pub.dev, jó CI/CD-integráció | JS/TS, npm, Metro bundler | Xcode, Swift Package Manager, TestFlight, Xcode Instruments | Android Studio, Gradle, Play Console |

## Funkcionális követelmények és technológia

A követelményspecifikáció alapján a rendszer három külön kliensből áll (Vendég, Munkavállaló, Adminisztrátor), amelyek mind az Apple-ökoszisztémán belül működnek. A vendég és a munkavállalói oldalon iOS-alkalmazás, az adminisztrátori oldalon fix munkaállomásra optimalizált macOS-alkalmazás készül; a webes adminisztrátori elérés későbbi bővítés.

## Kulcsfunkciók, amelyeknél a natív Apple-stack kritikus

### Kizárólag Apple Accounttal történő bejelentkezés

* **Swift + SwiftUI:** beépített támogatás (`ASAuthorizationAppleIDProvider`, Sign in with Apple gomb, tokenkezelés, Keychain-integráció).
* **Flutter / React Native:** külön natív plugineket és bridge-kódot igényelne, a rendszerfrissítéseknél a pluginek frissítését is külön kellene kezelni.
* **Android Studio:** az Android klienst támogatná, de a projekt célplatformja nem Android.

### Liquid Glass dizájnnyelv, az Apple legfrissebb dizájnirányelvei

* **Követelmény:** az alkalmazás az Apple által 2025-ben bevezetett Liquid Glass dizájnnyelvet használja.
* **SwiftUI:** natívan követi az aktuális rendszerkomponenseket, animációs modelleket, nagyítási és kontrasztbeállításokat, a Dynamic Type-ot, a sötét módot, valamint a parallax- és elmosási effekteket.
* **Flutter / React Native:** ezeket egyedi komponensekkel kellene újraírni, ami karbantarthatóság, felhasználói élmény és akadálymentesség szempontjából is gyengébb megoldás.

### Push értesítések, pánik mód, pozíció és tervrajz

* **Munkavállalói alkalmazás:** pánik mód push értesítéssel, a munkavállaló utolsó ismert zónájának elküldésével a biztonsági személyzetnek.
* **Minden kliens:** a helyszín méretarányos tervrajza zónákkal, POI-kkal és falakkal; a munkavállalói és az adminisztrátori oldalon a munkavállalók hozzávetőleges pozíciója (QR-kódos zóna-bejelentkezés alapján).
* **Swift:** közvetlen UserNotifications- és CloudKit-támogatás (feliratkozás alapú push), a tervrajz SwiftUI-jal (Canvas) rajzolható, a QR-kódok olvasása a kamerakeretrendszerrel natívan megoldható.
* **Flutter / React Native:** csomagolókönyvtárakra és natív modulokra támaszkodnak, ami a valós idejű és adatvédelmi szempontból kritikus funkcióknál (pánik mód, pozíció) többletkomplexitást jelent.

### Apple Tárca jegykezelés

* **Követelmény:** a vendég a jegyeit az Apple Tárcába helyezheti.
* **Swift:** közvetlen PassKit-integráció, hivatalos Apple-dokumentációra és mintakódra építve.
* **Flutter / React Native:** harmadik féltől származó pluginek, amelyeknél a támogatás és a hosszú távú karbantartás kérdéses lehet.

## Miért nem optimális a Flutter és a React Native?

### Flutter

**Előny:** egy kódbázis iOS-re, Androidra, webre és asztali platformokra, hot reload, gyors felületfejlesztés.

**Hátrány a projekt szempontjából:**

* A multiplatform irány túl nagy súlyt kapna, miközben a specifikáció kizárólag Apple-ökoszisztémát ír elő.
* Az Apple-specifikus API-k (Sign in with Apple, PassKit, Liquid Glass-szerű vizuális elemek) csak plugin szinten érhetők el, ami plusz karbantartást és hibalehetőséget jelent.
* A Flutter által renderelt felület nem egyezik teljesen az iOS aktuális komponenseivel (tipográfia, natív viselkedés, akadálymentesség), így sérülhet az Apple dizájnirányelveinek követése.

### React Native

**Előny:** gyors fejlesztés, ismert JS/TS-stack, sok npm-csomag.

**Hátrány a projekt szempontjából:**

* A bridge miatt nagyobb futásidejű komplexitás, ami a pánik mód, az értesítések és a kódolvasás esetén időzítési és stabilitási kockázatot jelenthet.
* Az iOS-specifikus dizájnnyelv és komponensek hű követése nehezebb, gyakran egyedi natív modulokat igényel, ami a gyakorlatban „félig natív, félig JS” megoldáshoz vezet.
* A projekt fókusza nem a platformfüggetlenség, hanem a mély Apple-integráció, így a cross-platform előny nagy része kihasználatlan maradna.

## Miért nem releváns az Android Studio (Java/Kotlin)?

A specifikáció nem tartalmaz Android-klienst; a teljes célrendszer Apple-platform. A Java/Kotlin és az Android Studio ideális Android-alkalmazásokhoz, de:

* nem ad natív hozzáférést az Apple API-khoz (Sign in with Apple, PassKit, Liquid Glass);
* a Kotlin Multiplatform legfeljebb a megosztott üzleti logikát tudná biztosítani, az Apple-felületet és -integrációkat ekkor is Swiftben kellene megírni;
* a projekt méretéhez és határidejéhez képest felesleges bonyolítás lenne egy további nyelv és eszközkészlet (Gradle, Android build pipeline) bevonása.

## Miért indokolt technikailag a Swift + SwiftUI?

### Közvetlen és naprakész hozzáférés az Apple API-khoz

A Swift az Apple SDK-k elsődleges nyelve: az új rendszerszintű funkciók (Sign in with Apple, Tárca, értesítések, új felületelemek) elsőként és teljes dokumentációval ehhez jelennek meg. A specifikáció több olyan kritikus funkciót tartalmaz (Apple Accountos bejelentkezés, Liquid Glass, Tárca-jegy, pánik mód), amelyeket közvetlenül az Apple keretrendszereivel lehet a legkevesebb kompromisszummal megvalósítani.

### Gyors, deklaratív, mégis natív felület SwiftUI-jal

* A három kliens felülete modulárisan építhető, a közös modellek és az üzleti logika a SharedKit csomagban egyszer készülnek el, és mindhárom kliens (valamint a Swiftben készülő hitelesítési szolgáltatás) felhasználja őket.
* A Liquid Glass dizájnnyelv elemei (anyagok, elmosás, mélység, animációk) SwiftUI-ban natívan, komponálható módon érhetők el, míg Flutter vagy React Native esetén egyedi komponensként kellene elkészíteni őket.

### Biztonság és adatvédelem

Az Apple-ökoszisztéma szigorúan szabályozza az érzékeny adatokhoz (értesítések, kamera, kódolvasási eredmények, pánikjelzések) való hozzáférést, és Swiftben natív eszközök állnak rendelkezésre ezek kezelésére (Keychain, App Transport Security, Secure Enclave). A projekt egyik fókusza a személyzet védelme, ezért a biztonsági és adatvédelmi követelmények elsődlegesek.

### Diagnosztika és tesztelés

Az Xcode Instruments, az XCTest, a Swift Testing, a UI-tesztek és a TestFlight lehetővé teszik a teljesítmény, a memóriahasználat, az energiafogyasztás és a felhasználói élmény célzott mérését natív szinten. Egy valós vállalati használatra szánt rendszernél a stabilitás és a diagnosztika fontosabb, mint a platformfüggetlen kód-újrahasznosítás.

### Saját szakmai háttér

Korábbi Swift- és iOS-fejlesztési tapasztalatom miatt a Swift + SwiftUI használatával elkerülhetők a további absztrakciós rétegek (platform channel, JS bridge, pluginek), így az idő a domain logikára és a felhasználói élményre fordítható.

## Tesztelési eszközök összehasonlítása

A fejlesztés viselkedésvezérelt (BDD) és tesztvezérelt (TDD) módon történik (ld. Tesztterv), ezért az eszközválasztás a tesztelési stackre is kiterjed.

### Egységtesztelés (TDD)

| Szempont | XCTest | Swift Testing |
|----------|--------|---------------|
| Szintaxis | Osztályalapú (`XCTestCase`), `XCTAssert…` függvények | Makróalapú (`@Test`, `#expect`, `#require`) |
| Paraméterezett tesztek | Nem támogatott natívan | Beépített (`arguments:`) |
| Párhuzamos futtatás | Folyamatszinten | Alapértelmezetten párhuzamos, Swift Concurrencyre épül |
| UI-teszt | Igen (XCUITest) | Nem, UI-teszthez XCTest szükséges |
| Szerep a projektben | UI-tesztek, valamint a BDD-futtató alapja | Új egységtesztek (SharedKit, ViewModellek, hitelesítési szolgáltatás) |

### Elfogadási tesztelés (BDD)

| Szempont | Cucumberish | CucumberSwift |
|----------|-------------|---------------|
| Nyelv | Objective-C | Swift |
| Integráció | CocoaPods / manuális | Swift Package Manager |
| Modern Xcode-dal | Telepíthető, de a forgatókönyvek futtatása nem az elvártak szerint működik | Működik, a lépéssorrend javításával (ld. alább) |
| Gherkin-támogatás | Igen | Igen (címkék, háttér, forgatókönyv-vázlat) |

A munkatervben a Cucumberish szerepelt, de mivel a modern Xcode-verziókkal nem működik megfelelően, a CucumberSwift került alkalmazásra. A CucumberSwift a lépéseket dinamikusan generált XCTest-metódusokként futtatja, amelyeket az Xcode tesztterve betűrendben hajt végre; ez a lépéseket Given → Then → When sorrendbe rendezte. A hibát a CucumberSwift helyi, módosított változata javítja, amely a lépés sorszámát a metódusnév elejére illeszti (részletek: Tesztterv).

## Összegzés

A rendszer kizárólag az Apple-ökoszisztémát célozza, és olyan platformspecifikus funkciókat használ, mint a Sign in with Apple, az Apple Tárca-integráció és az Apple által 2025-ben bevezetett Liquid Glass dizájnnyelv. Ezek a követelmények natív Swift + SwiftUI technológiával valósíthatók meg a legkevesebb kompromisszummal, mivel így közvetlen, naprakész hozzáférést kapok az iOS és macOS SDK teljes funkcionalitásához, a Human Interface Guidelines maradéktalan követéséhez, valamint az Apple által biztosított biztonsági és adatvédelmi mechanizmusokhoz. A Flutter és a React Native ugyan erős cross-platform megoldások, de esetükben pluginekre és bridge-ekre támaszkodnék minden kritikus Apple-funkciónál, ami növeli a komplexitást és a hibakockázatot, míg a Java/Kotlin és az Android Studio a projekt Apple-központúsága miatt nem releváns választás.

A fenti érvek ugyan támogatják a kizárólagos Swift-használatot, de nem adnak kizáró indokot más technológiákkal szemben. A technológia kiválasztásában nagy szerepet játszott személyes preferenciám, érdeklődésem és korábbi önálló tanulmányaim is.
