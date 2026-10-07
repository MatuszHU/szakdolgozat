# Követelmény-lefedettségi mátrix
### Majoros Máté
 ----
A mátrix a követelményspecifikáció funkcionális követelményeit köti össze a user storykkal, az elfogadási forgatókönyvekkel és az egységtesztekkel (ld. Tesztterv).

**Állapot:** ✅ sikeres · ⚠️ részleges / javítandó · ❌ sikertelen · – még nincs

## Munkavállaló

| ID | Név | Prio | User story | Forgatókönyv(ek) | Egységteszt | Állapot |
|----|-----|------|------------|------------------|-------------|---------|
| K1 | Üdvözlőképernyő | M | Authentication | Authentication: Successful login, Failed login | – | ✅ |
| K2 | Bejelentkezés | M | Authentication | Authentication: Successful login, Failed login | – | ✅ |
| K3 | Töltőképernyő | C | – | – | – | – |
| K4 | Kezdőképernyő | M | Authentication | Authentication: Already logged in | – | ✅ |
| K5 | Beosztások | M | – | – | – | – |
| K6 | Térkép | M | – | – | – | – |
| K7 | Kódolvasó/jegykezelő | M | – | – | – | – |
| K8 | Pánik mód | M | – | – | – | – |
| K9 | Beállítások | S | – | – | – | – |
| K10 | Profilkép | C | – | – | – | – |
| K11 | Nyelv | S | – | – | – | – |
| K12 | Összesítés | S | – | – | – | – |
| K13 | Értesítések | S | – | – | – | – |
| K14 | Kijelentkezés | M | – | – | – | – |
| K15 | Dokumentáció és útmutató | C | – | – | – | – |
| K16 | Zóna-bejelentkezés | M | – | – | – | – |
| K17 | Készletkérés | S | – | – | – | – |

## Adminisztrátor

| ID | Név | Prio | User story | Forgatókönyv(ek) | Egységteszt | Állapot |
|----|-----|------|------------|------------------|-------------|---------|
| L1 | Bejelentkezés | M | – | – | – | – |
| L2 | Főképernyő | M | – | – | – | – |
| L3 | Felhasználó- és beosztáskezelő | M | ShiftConflict | ShiftConflict: 4 forgatókönyv (csak az ütközés-ellenőrzés) | SharedKit: ShiftTests, ScheduleTests | ⚠️ |
| L4 | Térkép | M | – | – | – | – |
| L5 | Kijelentkezés | M | – | – | – | – |
| L6 | Beállítások | S | – | – | – | – |
| L7 | Helyszíntervező | M | – | – | – | – |
| L8 | Kérelmek | S | – | – | – | – |
| L9 | Dokumentáció és útmutató | C | – | – | – | – |
| L10 | Készletkezelés | S | – | – | – | – |
| L11 | Eseménykezelés | M | – | – | – | – |

## Vendég

| ID | Név | Prio | User story | Forgatókönyv(ek) | Egységteszt | Állapot |
|----|-----|------|------------|------------------|-------------|---------|
| M1 | Üdvözlőképernyő | M | – | – | – | – |
| M2 | Bejelentkezés | M | – | – | – | – |
| M3 | Kezdőképernyő | M | – | – | – | – |
| M4 | Jegyvásárlás | M | – | – | – | – |
| M5 | Térkép | S | – | – | – | – |
| M6 | Kijelentkezés | M | – | – | – | – |
| M7 | Nyereményjáték | C | – | – | – | – |
| M8 | Beállítások | S | – | – | – | – |
| M9 | Profilkép | C | – | – | – | – |
| M10 | Nyelv | S | – | – | – | – |
| M11 | Útmutató | C | – | – | – | – |

## Összesítés

| | Összes | M | Lefedett (✅) | Részleges (⚠️) |
|---|---|---|---|---|
| Munkavállaló | 17 | 9 | 3 | 0 |
| Adminisztrátor | 11 | 6 | 0 | 1 |
| Vendég | 11 | 5 | 0 | 0 |
| **Összesen** | **39** | **20** | **3** | **1** |

## Nyitott tételek

* **L3:** az ütközés-ellenőrzés kész (BDD + TDD), de a követelmény többi része (adminisztrátorok felvétele, műszak létrehozása, létszámkorlát a felületen, feladatkiosztás) még nincs megvalósítva; a forgatókönyvek jelenleg a munkavállalói alkalmazás tesztcéljában futnak, az adminisztrátori alkalmazás elkészültével oda kerülnek át.
* **L1:** két forgatókönyv-csoport szükséges (Sign in with Apple és jelszavas bejelentkezés); a jelszavas ág a hitelesítési szolgáltatás tesztpéldányával fut.
