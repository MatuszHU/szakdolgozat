# Követelményspecifikáció - Munkaválaló

## Jelenlegi helyzet
Jelenleg nincs a piacon olyan szoftver ami segítene a szórakozó iparban azon belül is a szórakozó helyeken, ami egyaránt a munkáltató, munkáltatott és a vendégekre is. Nagyon sok szórakozó helyen előfordul, hogy a személyzetet zaklatják, vagy az este közben kifogynak valamilyen felszerelésből, és a hangos zene, a tömeg megakadályozza a hatékony kommunikációt.

## Vágyálomrendszer
A jövőbeli verziói az alkalmazásnak képesek lesznek a nem csak a szórakozó iparban dolgozók, hanem a vendéglátás egyéb területein is kiszolgálni a vállalkozások igényeit.

## Követelménylista

| Modul | ID | Név | Verzió | Kifejtés |
|-------|----|-----|--------|----------|
| Felület | K1 | Üdvözlőképernyő | v1 | Az első alkalmazás megnyitásakor és kijelentkezéskor megejelnő grafika és bejelentkező gomb. |
| Jogosultág | K2 | Bejelentkezés | v1 | Bejelentkezés és regisztrációs kép. Kizárólag Apple Account-al való bejelntkezés lesz támogatott, a "*Sign in with Apple*" gyártóspecifikus protokollal, így a bejelentkezés egyben regisztációs folyamat |
| Felület | K3 | Töltőképernyő | v1 | Ideigelenes nézetközti váltáskor elheleyzett animált nézet |
| Felület | K4 | Kezdőképernyő | v1 | Bejelentkezés után, és bejelentkezett állapot esetén ide lesz irányítva a felhasználó. Egyféle hubként funkcionál, és elérhető az összes funkciója az alkalmazásnak |
| Felület | K5 | Beosztások | v1 | Az alkalmazott itt tudja megtekinteni a beosztását, kiosztott feladatát, helyszínét |
| Felület | K6 | Térkép | v1 | A munkaterületről készült térkép itt megtalálható, képes megejeleníteni a a többi munkavállaló helyzetét, hozzávetőleges pozícióját, a hozzárendelt feladatot és kijelölt munkaterületet. |
| Felület | K7 | Kódolvasó/jegykezelő | v1 | A felhasználó itt képes lesz beolvasni 1 és 2 dimenziós géppel olvasható optikai kódokat, amely igény szerint jegyet olvas, parkolójegyet érvényesít, információt jelez ki a kódot birtoklóról |
| Kommunikáció | K8 | Pánikmód | v1 | A felhasználó a pánikmód aktivitálás esetén az összes biztonsági személyzetnek (vagy egyéb beállított jogosultsági kör) minden elérhető csatornán értesítést küld a felhasználó pozíciójáról, nevéről, funkciójáról |
| Felület | K9 | Beállítások | v1 | Az a nézet ahol az összes eléhető beállítás megjelenik |
| Módosítás | K10 | Profilkép | v1 | A felhasználó szabadon tud feltöltetni és módosítani profilképet |
| Módosítás | K11 | Nyelv | v1 | A felhasználó ki tudja választani a felület nyelvét (Magyar, Angol,Európai Portugál) |
| Statisztika | K12 | Összesítés | v1 | A felhasználó meg tudja tekinteni a ledolgozott óraszámát, előző feladatat |
| Kommunikáció | K13 | Értesítések | v1 | A felhasználó itt látja a rendszer-, más felhasználói-, és adminisztrátori értesítései. |
| Jogosultság | K14 | Kijelentkezés | v1 | A felhasználó ki tudj jelentkezni a profiljából és az appból |