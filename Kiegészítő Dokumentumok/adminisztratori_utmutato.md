# Nightlife Manager – Adminisztrátori útmutató
### Majoros Máté
 ----
Ez az útmutató a Nightlife Manager macOS-alkalmazás használatát írja le (L9). Az alkalmazásból a **Súgó → Adminisztrátori útmutató** menüponttal nyitható meg.

## 1. Első indítás: a tulajdonos létrehozása

Ha még nincs adminisztrátor, az alkalmazás a **Tulajdonos létrehozása** képernyővel indul. Add meg a nevedet, a felhasználónevedet és egy legalább 8 karakteres jelszót. A felhasználónév kisbetűkből, számjegyekből, pontból, kötőjelből és aláhúzásból állhat (ez az e-mail-cím @ előtti része). Az így létrehozott fiók **tulajdonosi** jogosultságú.

## 2. Bejelentkezés és kijelentkezés

- **Bejelentkezés:** a felhasználónevet és a jelszót kell megadni. Ha a vállalati domain be van állítva, a mező mellett látszik (pl. `@clubneon.hu`), azt nem kell beírni.
- **Hibás adatok:** hibás jelszó és ismeretlen felhasználónév esetén ugyanaz az üzenet jelenik meg, így kívülről nem derül ki, létezik-e egy felhasználónév.
- **Ideiglenes jelszó:** ha egy másik adminisztrátor hozta létre a fiókodat vagy állította vissza a jelszavadat, az első bejelentkezéskor új jelszót kell választanod.
- **Kijelentkezés:** az oldalsáv alján, a neved alatt.
- **Hitelesítési szolgáltatás:** a bejelentkező képernyő alján látszik, hol vannak a fiókok (**Hitelesítés: helyi fiókok ezen a Macen** vagy a szolgáltatás címe). A **Módosítás** gombbal megadható a cég hitelesítési szolgáltatásának címe (pl. `https://auth.clubneon.hu`); üresen hagyva az alkalmazás helyi módban, a Macen tárolt fiókokkal működik. Váltás után a választott helyen kell bejelentkezni, illetve egy új szolgáltatásnál először tulajdonost létrehozni.

## 3. Jogosultsági szintek

| Szint | Mit tehet |
|-------|-----------|
| Tulajdonos | Minden; tulajdonost csak tulajdonos vehet fel vagy törölhet; a vállalati domaint csak tulajdonos állíthatja. |
| Felhasználó-adminisztrátor | Adminisztrátorokat vehet fel és törölhet (tulajdonost nem), jelszót állíthat vissza. |
| Üzletvezető | A helyszín, a műszakok, az események és a készlet kezelése; adminisztrátorokat nem kezelhet. |

Az utolsó tulajdonos nem törölhető.

## 4. Helyszíntervező (L7)

Minden szint egy lap, a halvány szürke pontok egymástól 1 méterre vannak.

1. **Új szint:** a `+` gombbal adj meg nevet, szintszámot (pl. 0 = földszint, −1 = pince) és a lap méretét méterben. Egy szintszám csak egyszer szerepelhet.
2. **Zóna vagy hely rajzolása:** válaszd a **Sokszög** eszközt, és kattints sorban az alakzat sarokpontjaira. Az alakzat az első pontra kattintva vagy az **Enter** (Kész) gombbal zárul. Ezután válaszd ki a típusát: **Zóna** (munkaterület, saját QR-kóddal), illetve bár, mosdó, színpad, bejárat, vészkijárat, ruhatár vagy egyéb (ezt csak a személyzet látja), és add meg a nevét. A zónanév szintenként egyedi. Rajzolás közben az **Utolsó pont visszavonása** gomb az utolsó pontot törli, az **Esc** (Mégse) az egész rajzot.
3. **Fal rajzolása:** válaszd a **Fal** eszközt, kattints a fal töréspontjaira, majd nyomj **Entert**.
4. **Illesztés:** alapból minden pont a legközelebbi rácsponthoz illeszkedik. A pontrács gombbal ez kikapcsolható, ilyenkor szabadon lehet rajzolni.
5. **Kijelölés és szerkesztés:** a **Kijelölés** eszközzel kattints egy alakzatra (vagy válaszd ki a jobb oldali listában). Húzással mozgatható, a sarokpontjait (kis négyzetek) húzva átformálható. A **Törlés** gomb vagy a Delete billentyű törli. Az alakzatok fedhetik egymást (pl. a bárpult a bár zónáján belül); ilyenkor a legfelső, legutóbb rajzolt alakzat jelölődik ki.
6. **Nagyítás:** a nagyító gombokkal.

Az alakzatoknak a lapon kell maradniuk; a lapról lelógó mozgatást az alkalmazás nem engedi.

## 5. Zónakódok (K16)

A **Zónakódok** menüpont minden zónához QR-kódot mutat „Szint – Zóna” felirattal. A **Nyomtatás** gombbal kinyomtathatók; a kódot az adott zónában kell kihelyezni. A munkavállalók ezt beolvasva jelentkeznek be a zónába.

## 6. Személyzet térképe (L4)

A tervrajzon a munkatársak a legutóbbi zóna-bejelentkezésük helyén jelennek meg. Egy munkatársat kiválasztva látszik a munkaterülete, a pozíciója és a feladatai; a térkép arra a szintre vált, ahol tartózkodik. A be nem jelentkezett munkatársak külön jelölést kapnak.

## 7. Műszakok (L3)

- **Munkatárs felvétele:** a bal oldali lista **Új munkatárs** gombjával (név, munkakör).
- **Új műszak:** a `+` gombbal (kezdés, vég, zóna, létszám).
- **Hozzárendelés:** a műszakot kiválasztva a **Munkatárs hozzáadása** menüből. Betelt műszakhoz és egy munkatárs számára átfedő műszakhoz a rendszer nem enged hozzárendelést (az egymást közvetlenül követő műszakok megengedettek).
- **Feladat:** a **Feladatok** részben, csak a műszakon lévő munkatársnak adható.
- **Eltávolítás:** a munkatárs a műszak feladatairól is lekerül.

## 8. Események és jegyek (L11)

- **Új esemény:** cím, helyszín, kezdés, vég, férőhely.
- **Jegytípusok:** Standard, VIP vagy egyéni néven, árral és opcionális kerettel. Egy jegytípus eseményenként egyszer szerepelhet, az ár nem lehet negatív, a keretek összege nem haladhatja meg a férőhelyet.
- **Nyereményjáték:** megnevezés és nyeremény megadásával hirdethető meg.

## 9. Készlet (L10)

- **Új tétel:** megnevezés, kategória, mennyiség, mértékegység, minimális mennyiség. A megnevezés egyedi.
- **Mennyiség módosítása:** a tétel sorában írd át a mennyiséget, és nyomj Entert.
- **Alacsony készlet:** a minimum alatti tételek narancssárgán, külön listában jelennek meg; ha egy művelet a minimum alá viszi a tételt, figyelmeztetés jelenik meg.
- **Készletkérések:** a munkavállalók a telefonos appból kérnek (K17). A **Függő kérések** részben jóváhagyhatók (a mennyiség levonódik a készletből) vagy elutasíthatók. A készletnél nagyobb kérés nem hagyható jóvá. Az **Elfogyott** jelzésű kérések már hiányt jeleznek, a többi előre szól; a munkavállaló megjegyzése a tétel alatt látszik. Egy munkavállalónak tételenként egy nyitott kérése lehet.

## 10. Kérelmek (L8)

A munkavállalók pánikjelzései és készletkérései kategóriánként, a legfrissebb elöl. A **Csak a nyitottak** kapcsolóval a még el nem intézett tételek szűrhetők (nem nyugtázott pánikjelzés, függő készletkérés).

## 11. Adminisztrátorok és beállítások (L3, L6)

- **Adminisztrátorok:** új adminisztrátor felvétele (név, felhasználónév, jogosultság, bejelentkezési mód; jelszavas módnál ideiglenes jelszóval), jelszó visszaállítása (kulcs ikon), törlés.
- **Beállítások:**
  - **Munkavállalói funkciók:** a profilkép, az összesítés, az útmutató és a készletkérés központilag ki- és bekapcsolható.
  - **Saját jelszó:** a jelenlegi jelszó megadásával módosítható.
  - **Vállalati domain:** csak tulajdonos állíthatja.

## 12. Jelenlegi korlátok

- Az adatok (helyszín, műszakok, események, készlet, adminisztrátorok) jelenleg csak ezen a Macen, helyben tárolódnak. A munkavállalói és a vendég alkalmazással való megosztáshoz CloudKit-szinkron szükséges, ami fizetős Apple fejlesztői tagságot igényel.
- Helyi módban a jelszavak hash-elve, csak ezen a Macen tárolódnak; több Mac (és a későbbi webes elérés) közös fiókjaihoz a hitelesítési szolgáltatást kell használni. A szolgáltatás újraindításakor minden adminisztrátornak újra be kell jelentkeznie.
- A Sign in with Apple fizetős Apple fejlesztői tagság nélkül nem próbálható ki.
