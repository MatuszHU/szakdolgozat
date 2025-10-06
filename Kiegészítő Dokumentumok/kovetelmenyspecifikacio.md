    # Követelményspecifikáció
    ### Majoros Máté
    ----
    ## Áttekintés


    A program egy szórakozóhely manager, aminek célja hogy a munka közben felmerülő akadályokat gyorsan és hatékonyan megoldja munkavállalói oldalról, a vezetőségnek áttekinthető munkabeosztást, készletvezetést nyújtson, a vendégeknek egyszerű beléptetést és hasznos információkkal szolgáljon. Ez program 3 részből fog állni: Vendég, Munkavállaló, és Adminisztrátor. A 3 app összhangban lesz egymással, egymásra építve.


    ## Jelenlegi helyzet
    Jelenleg nincs a piacon olyan szoftver ami segítene a szórakozó iparban azon belül is a szórakozóhelyeken, ami egyaránt a munkáltató, munkáltatott és a vendégekre is. Nagyon sok szórakozó helyen előfordul, hogy a személyzetet zaklatják, vagy az este közben kifogynak valamilyen felszerelésből, és a hangos zene, a tömeg megakadályozza a hatékony kommunikációt.


    ## Vágyálom Rendszer
    A jövőbeli verziói az alkalmazásnak képesek lesznek a nem csak a szórakozó iparban dolgozók, hanem a vendéglátás egyéb területein is kiszolgálni a vállalkozások igényeit.


    ## Követelménylista - Munkavállaló


    | Modul | ID | Név | Verzió | Kifejtés |
    |-------|----|-----|--------|----------|
    | Felület | K1 | Üdvözlőképernyő | v1 | Az első alkalmazás megnyitásakor és bejelentkezéskor megjelenő grafika és bejelentkező gomb. |
    | Jogosultság | K2 | Bejelentkezés | v1 | Bejelentkezés és regisztrációs kép. Kizárólag [*Apple Account*](https://support.apple.com/hu-hu/apple-account)al való bejelntkezés lesz támogatott, a "[*Sign in with Apple*](https://developer.apple.com/documentation/signinwithapple)" gyártóspecifikus protokollal, így a bejelentkezés egyben regisztációs folyamat |
    | Felület | K3 | Töltőképernyő | v1 | Ideigelenes nézetközti váltáskor elheleyzett animált nézet |
    | Felület | K4 | Kezdőképernyő | v1 | Bejelentkezés után, és bejelentkezett állapot esetén ide lesz irányítva a felhasználó. Egyféle hubként funkcionál, és elérhető az összes funkciója az alkalmazásnak |
    | Felület | K5 | Beosztások | v1 | Az alkalmazott itt tudja megtekinteni a beosztását, kiosztott feladatát, helyszínét |
    | Felület | K6 | Térkép | v1 | A munkaterületről készült térkép itt megtalálható, képes megjeleníteni a többi munkavállaló helyzetét, hozzávetőleges pozícióját, a hozzárendelt feladatot és kijelölt munkaterületet. |
    | Felület | K7 | Kódolvasó/jegykezelő | v1 | A felhasználó itt képes lesz beolvasni 1 és 2 dimenziós géppel olvasható optikai kódokat, amely igény szerint jegyet olvas, parkolójegyet érvényesít, információt jelez ki a kódot birtoklásról |
    | Kommunikáció | K8 | Pánik Mód | v1 | A felhasználó a pánik mód aktiválás esetén az összes biztonsági személyzetnek (vagy egyéb beállított jogosultsági kör) minden elérhető csatornán push értesítést küld a felhasználó pozíciójáról, nevéről, funkciójáról. Az értesítése könnyen megkülönböztethető más alkalmazások és egyéb rendszer értesítések hangjától. Az értesítésre lehetősége van a munkavállalónak nyugtázni. |
    | Felület | K9 | Beállítások | v1 | Az a nézet ahol az összes elérhető beállítás megjelenik |
    | Módosítás | K10 | Profilkép | v1 | A felhasználó szabadon tud feltölteni és módosítani profilképet |
    | Módosítás | K11 | Nyelv | v1 | A felhasználó ki tudja választani a felület nyelvét (Magyar, Angol,Európai Portugál) |
    | Statisztika | K12 | Összesítés | v1 | A felhasználó meg tudja tekinteni a ledolgozott óraszámát, előző feladatat |
    | Kommunikáció | K13 | Értesítések | v1 | A felhasználó itt látja a rendszer-, más felhasználói-, és adminisztrátori értesítései. |
    | Jogosultság | K14 | Kijelentkezés | v1 | A felhasználó ki tudj jelentkezni a profiljából és az appból |
    | Felület | K15 | Dokumentáció és Útmutató | v1 | Egy külön dokumentum ahol az összes dokumentum és útmutató elérhető lesz, ami szükséges lehet.


    ## Követelménylista - Adminisztrátor


    | Modul | ID | Név | Verzió | Kifejtés |
    |-------|----|-----|--------|----------|
    | Jogosultság | L1 | Bejelentkezés | v1 | Bejelentkezés és regisztrációs kép. Bejelentkezni vállalati emailel lehetséges. |
    | Felület | L2 | Főképernyő | v1 | Központi lap, ahol el lehet érni az összes adminisztratív funkciót. |
    | Felület | L3 | Felhasználó kezelő | v1 | Az a lap, ahol az adminisztrátor képes felvenni további adminisztrátor felhasználókat, és képes kezelni a munkavállaló beosztását|
    | Felület | L4| Térkép | v1 | A munkaterületről készült térkép itt megtalálható, képes megjeleníteni a többi munkavállaló helyzetét, hozzávetőleges pozícióját, a hozzárendelt feladatot és kijelölt munkaterületet. A saját helyzete nem fog látszódni. |
    | Jogosultság | L5 | Kijelentkezés | v1 | A felhasználó ki tudj jelentkezni a profiljából és a weboldalról. |
    | Felület | L6 | Beállítások | v1 | A felhasználó itt tudja a saját beállításait állítani és központilag állítani a munkavállalók számára elérhető nem alapfunkciókat. |
    | Felület | L7 | Térképbeállítások | v1 | Abban az esetben ha nem műholdas vagy standard térképet szeretne használni a felhasználó, lehetősége van saját térképet, grafikát letölteni és azt kalibrálni, valósághoz illeszteni. |
    | Statisztika | L8 | Kérelmek | v1 | Minden munkavállaló által leadott kérelem, hívás itt tételesen, csoportosítva és kategorizálva megjeleníthető. |
    | Felület | L9 | Dokumentáció és Útmutató | v1 | Egy külön dokumentum ahol az összes dokumentum és útmutató elérhető lesz, ami szükséges lehet. |


    ## Követelménylista - Vendég


    | Modul | ID | Név | Verzió | Kifejtés |
    |-------|----|-----|--------|----------|
    | Felület | M1 | Üdvözlőképernyő | v1 | Az első alkalmazás megnyitásakor és bejelentkezéskor megjelenő grafika és bejelentkező gomb. |
    | Jogosultság | M2 | Bejelentkezés | v1 | Bejelentkezés és regisztrációs kép. Kizárólag [*Apple Account*](https://support.apple.com/hu-hu/apple-account)al való bejelntkezés lesz támogatott, a "[*Sign in with Apple*](https://developer.apple.com/documentation/signinwithapple)" gyártóspecifikus protokollal, így a bejelentkezés egyben regisztációs folyamat |
    | Felület | M3 | Kezdőképernyő | v1 | Bejelentkezés után, és bejelentkezett állapot esetén ide lesz irányítva a felhasználó. Egyféle hubként funkcionál, és elérhető az összes funkciója az alkalmazásnak |
    | Felület | M4 | Jegyvásárlás | v1 | A vendég innen tud az adott eseményre jegyet venni, vagy a már megvásárolt jegyét megtekinteni és *Apple Tárca* jegy kezelőjébe helyezni. |
    | Felület | M5 | Térkép | v1 | Esemény térképe, ahol a POI-k megjelennek|
    | Jogosultság | M6 | Kijelentkezés | v1 | A felhasználó ki tudj jelentkezni a profiljából és az appból |
    | Felület | M7 | Nyereményjáték | v1 | Az aktuális nyereményjáték részletei, és részvételre regisztráció |
    | Felület | M8 | Beállítások | v1 | Az a nézet ahol az összes elérhető beállítás megjelenik |
    | Módosítás | M9 | Profilkép | v1 | A felhasználó szabadon tud feltölteni és módosítani profilképet |
    | Módosítás | M10 | Nyelv | v1 | A felhasználó ki tudja választani a felület nyelvét (Magyar, Angol, Német,Európai Portugál, Szlovák, Román, Horvát, Ukrán) |
    | Felület | M11 | Útmutató | v1 | Egy beépített prompt/pop-up ami grafikák és szöveges leírás segítségével útmutatást ad a felhasználónak. |


    ## Riport


    Az program nem csak proof-of-concept-ként működik, hanem tényleges problémát kíván megoldani amivel sok munkavállaló találkozhat.


    Mind az alkalmazás, mind a webapp követi az Apple által javasolt Design Best Practices, azaz a jelenlegi legfrissebb design nyelvet használja (Liquid Glass), amit 2025-ben az iOS/iPadOS/MacOS 26-os verzióval vezettek be.


    #### Miért Apple/Swift és miért az Apple keretrendszerei?


    Apple ökoszisztéma elősegíti és lehetővé teszi a teljesen egységes funkcionalitást, kinézetet. Emelett kiemelkedő fókuszt helyez a felhasználói biztonságra és adatvédelemre. Összhangot teremt a front- és backend közt.


    #### Miért kell a programot 3 külön alkalmazásra szedni?


    Azért esett a választás 3 különböző programra, mert minden felhasználó csoport igénye teljesen különböző és nem fedi egymást. Emelett mivel egy felhasználó csoport nem valószínű hogy tagja a másik 2 csoportnak, így a tárhely igénye az appnak is kisebb. Míg a munkavállalói és vendég oldalról a kompakt, bárhol használható app az optimális, úgy az adminisztrátori körnek egy fix munkaállomás, nagy képernyővel felel meg.


    #### Miért különbözik az elérhető nyelvek alkalmazásonként?


    Míg a vendégek sok különböző helyről érkezhetnek, addig a munkavállalók többnyire magyarok, kivételes esetben is feltételezhető, hogy rendelkeznek megfelelő angol tudással, hogy használják az alkalmazást.


    A vendégekneknél prioritást kell a kényelemnek élveznie. Sokkal egyszerűbb és gyorsabb lehet például a beléptetési folyamat a rendezvényeken, ha a vendég anyanyelvén látja az instrukciókat


    #### Felhasználói útmutatás


    A vendégek számára az útmutató alkalmazásba építve, grafikákkal egybeépítve a releváns helyeken lesz elhelyezve.


    A munkavállalók számára egy külön gomb segítségével lesz elérhető egy útmutató ami leírja az elérhető funkciókat.


    Az adminisztrátornak egy külső dokumentáció és útmutató fogja segíteni az eligazodást.


    ## Fogalomtár


    * POI - Points of interest » Olyan pontok amik egy felhasználói körnek kiemelten fontos lehet (Bár, Mosdó, Színpad, stb...)
    * Liquid Glass » Apple 2025-ben bevezetett dizájn nyelve
    * Apple - Apple Inc » Hardware- és szoftvergyártó amerikai központú cég.
