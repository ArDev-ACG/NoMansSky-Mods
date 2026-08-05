# Modificaciones

Tabla viva de **todo** lo que el mod cambia: qué campo, qué archivo, qué hace en el juego
y **sobre qué criatura actúa**.

> **Mantener actualizado.** Cada vez que se añada, cambie o retire un valor en cualquiera
> de los `.lua`, esta tabla se actualiza en la misma sesión. Si la tabla y los `.lua` no
> coinciden, manda el `.lua`.

- Versión cubierta: **mod 2 Infestation 0.3.1** (incluye lo del mod 1 Predators 1.1.0).
- Referencias: [`CHANGELOG-MOD2.md`](CHANGELOG-MOD2.md) · [`COMPORTAMIENTO.md`](COMPORTAMIENTO.md) · [`../work/scripts/infestacion/README.md`](../work/scripts/infestacion/README.md)
- Última revisión: **2026-08-05**, descompilando los **MBIN** desplegados en `GAMEDATA\MODS`.

---

## Qué está instalado ahora mismo

| | |
|---|---|
| Mod en `GAMEDATA\MODS` | `HorribleTerror_Infestation_4-Hardcore` |
| Versión | **0.3.1** |
| Formato | **9 MBIN** desde `ModBackups\`, con el `GLOBALS\` creado a mano |
| Verificado | descompilando de vuelta desde `GAMEDATA\MODS`, campo por campo |
| Mod 1 | **no instalado** (correcto: se instala uno o el otro) |
| NMS | 170671, rama Public · MBINCompiler 6.45.0.1 |

> **Lo que había antes eran 8 EXML con las marcas `!# CHANGED` dentro** — el delta de
> `CreatedMODS`, que es el informe y no el archivo de juego. 0.3.1 es el primer despliegue
> de Hardcore verificado como MBIN, así que **todo lo probado in-game antes del 05/08 hay
> que tratarlo como no medido**. Ver `CHANGELOG-MOD2.md`, 0.3.1 § Fixed.

---

## Leyenda

- **—** = ese tier **no escribe** el campo a propósito: su valor coincidiría con vanilla
  y ensuciaría el EXML delta sin cambiar nada.
- **`[SIN PROBAR]`** = está en el juego pero nunca se ha confirmado jugando.
- «Fiend» = Horror Biológico, el bicho de los edificios abandonados y de los huevos.
- Los **#** son IDs estables por campo, no un orden. Al añadir campos se numeran al
  final para que las referencias de otros docs no se rompan.

---

## 1 · `METADATA\SIMULATION\ECOSYSTEM\CREATUREGENERATIONDATA.MBIN` — 5 cambios

| # | Campo | Qué hace | En qué monstruo | Vanilla | Fácil | Normal | Difícil | Hardcore |
|---|---|---|---|---:|---:|---:|---:|---:|
| 1 | `GroundGroupsPerKm.Sparse` | Grupos de fauna por km² en planetas pelados | **Toda la fauna terrestre** (no solo hostil) | ×1 | ×2 | ×5 | ×20 | ×20 |
| 2 | `GroundGroupsPerKm.Normal` | Ídem, densidad media | Toda la fauna terrestre | ×1 | ×2 | ×5 | ×20 | ×20 |
| 3 | `GroundGroupsPerKm.Dense` | Ídem, densidad alta | Toda la fauna terrestre | ×1 | ×2 | ×5 | ×20 | ×20 |
| 4 | `GroundGroupsPerKm.VeryDense` | Ídem, densidad máxima | Toda la fauna terrestre | ×1 | ×2 | ×5 | ×20 | ×20 |
| 5 | `Generic → Ground → DANGEROUS → "Weight "` | Peso del arquetipo de planeta hostil. Sube el % de planetas infestados de depredadores | **Depredadores** (`PLAYERPREDATOR`), vía selección de planeta | 1 | 3 | 10 | 1000 | 1000 |

> `"Weight "` lleva **espacio al final**: typo de Hello Games. La regla va anclada con
> `SPECIAL_KEY_WORDS` encadenado, nunca `WHERE_IN_SECTION` — eso puso a 1000 los 22 pesos.

---

## 2 · `GROUND\GROUNDTABLEPLAYERPREDATORMED.MBIN` y `...LARGE.MBIN` — 2+2 cambios

| # | Campo | Qué hace | En qué monstruo | Vanilla | Fácil | Normal | Difícil | Hardcore |
|---|---|---|---|---:|---:|---:|---:|---:|
| 6 | `MinGroupSize` | Tamaño mínimo de manada | **Depredadores medianos y grandes que cazan al jugador** | 1 | 1 | 2 | 3 | 5 |
| 7 | `MaxGroupSize` | Tamaño máximo de manada | Ídem | 1 | 2 | 3 | 5 | 7 |

Son 4 cambios: los dos campos × los dos archivos (MED y LARGE).

> En vanilla `Min = Max = 1`: los depredadores que van a por ti salen **solos** por diseño.
> Ésta es la palanca que los convierte en jauría. **Sospechosa nº2 del zigzag**: manadas de
> 5-7 se empujan entre sí (`SpherePusher*`).

---

## 3 · `GLOBALS\GCCREATUREGLOBALS.MBIN` — hasta 31 cambios

### 3a · Heredado del mod 1 — depredadores

| # | Campo | Qué hace | En qué monstruo | Vanilla | Fácil | Normal | Difícil | Hardcore |
|---|---|---|---|---:|---:|---:|---:|---:|
| 8 | `PredatorPerceptionDistance` | A cuántos metros te detecta | **Depredadores** | 40 | 45 | 50 | 60 | 80 |
| 9 | `PredatorRunAwayHealthPercent` | % de vida al que huye. 0 = pelea hasta morir | Depredadores | 40 | 30 | 15 | **0** | **0** |
| 10 | `PercentagePlayerPredators` | Fracción de depredadores que atacan al jugador en vez de cazar fauna | Depredadores | 0.5 | 0.6 | 0.75 | **1.0** | **1.0** |
| 11 | `MaxEcosystemCreaturesNormal` | Tope duro de criaturas vivas a la vez. Entero | **Todas las criaturas** | 40 | 45 | 50 | 60 | 70 |
| 12 | `PlayerPredatorBoredomDistance` | A qué distancia se aburren y te sueltan | Depredadores | 80 | — | — | — | **150** |

> Interacción: con percepción 80 y aburrimiento 150 el margen para escapar es de 70 m. Si
> escapar se vuelve imposible, la corrección es subir el aburrimiento, **no** bajar la
> percepción. Fácil/Normal/Difícil no lo escriben porque 80 ya es el valor vanilla.

### 3b · Fiends — cantidad (0.1.0)

| # | Campo | Qué hace | En qué monstruo | Vanilla | Fácil | Normal | Difícil | Hardcore |
|---|---|---|---|---:|---:|---:|---:|---:|
| 13 | `FiendMaxAttackers` | Cuántos te pegan **a la vez**. Entero | **Fiend** | 2 | — | 3 | 4 | **8** |
| 14 | `FiendMaxEngaged` | Cuántos están en combate contigo. Entero | Fiend | 6 | — | 8 | 10 | **16** |
| 15 | `MaxFiendsToSpawn` | Tope de Fiends generados por un evento. Entero | Fiend | 6 | — | 8 | 10 | **16** |
| 16 | `FiendAggroTime` | Segundos que te persiguen tras perderte de vista | Fiend | 45 | — | 60 | 90 | **600** |

> Hardcore sube estos cuatro en **0.3.1**. `MaxFiendsToSpawn` tiene que ir a la par de
> `FiendMaxEngaged`: si caben 16 comprometidos pero solo nacen 12, el cupo extra no lo
> llena nadie. Ojo con el nombre — `MaxFiendsToSpawnCarnage` **no se toca**, y no se toca
> porque AMUMSS empareja el nombre **exacto**; verificado en el delta.

### 3c · Fiends — conducta (0.2.0)

| # | Campo | Qué hace | En qué monstruo | Vanilla | Fácil | Normal | Difícil | Hardcore |
|---|---|---|---|---:|---:|---:|---:|---:|
| 17 | `FiendOnscreenMarkers` | Icono de UI sobre cada Fiend. `false` = sin aviso | **Fiend** (solo UI, no dificultad) | `true` | — | — | **`false`** | **`false`** `[SIN PROBAR]` |
| 18 | `FiendPerceptionDistance` | A cuántos metros te detecta. **Campo aparte** del de depredador | Fiend | 60 | — | 65 | 70 | **120** |
| 19 | `FiendMinSpawnTime` | Retardo mínimo entre Fiends que salen del huevo | Fiend, al eclosionar | 0.25 | — | 0.2 | 0.15 | 0.1 |
| 20 | `FiendMaxSpawnTime` | Retardo máximo. Bajarlo = salen **de golpe**, no escalonados | Fiend, al eclosionar | 3.0 | — | 2.0 | 1.0 | 0.5 |
| 21 | `AvoidCreaturesWeight` | Peso de la separación entre bichos. Contra el amontonamiento de las manadas | **Todas las criaturas** | 6 | — | 8 | 10 | 10 |
| 22 | `GroundWormSpawnerActivateRadius` | Radio (m) al que el spawner de gusano se dispara por proximidad | **Gusano de arena** (`GROUNDWORMSPAWNER`) | 100 | — | 50 | 20 | 10 |

> Hasta 0.2.0 el Fiend de Hardcore te veía **más tarde** (60 m) que un depredador normal
> (80 m), porque `FiendPerceptionDistance` no se tocaba. Corregido.
> El radio del gusano es la única mecánica de «sale cuando te acercas» que existe hoy sin
> romper nada — ver [`COMPORTAMIENTO.md`](COMPORTAMIENTO.md) §8.

### 3d · Movimiento — sin acechar, derechos y en horda (0.3.0)

Vanilla extraído de `NMSARC.globals.pak` el 2026-08-04, **no** de los backups de AMUMSS.

**A · Sin acechar.** La secuencia vanilla es: te ve → **pausa 1.5 s** → se acerca →
**acecha 4 s** → carga solo a 7 m. Estos cuatro campos la desmontan.

| # | Campo | Qué hace | En qué monstruo | Vanilla | Fácil | Normal | Difícil | Hardcore |
|---|---|---|---|---:|---:|---:|---:|---:|
| 40 | `PredatorNoticePauseTime` | Pausa dramática al detectarte, antes de moverse | **Depredadores** | 1.5 | — | 0.8 | 0.3 | **0.0** |
| 41 | `PredatorApproachTime` | Segundos **acechando** antes de lanzarse | Depredadores | 4.0 | — | 2.0 | 0.5 | **0.0** |
| 42 | `PredatorChargeDist` | Distancia a la que arranca la carga. Subirlo = carga desde lejos en vez de acercarse primero | Depredadores | 7.0 | — | 12 | 25 | **40** |
| 43 | `PredatorEnergyUseChasing` | Energía que gasta persiguiendo (negativo = drena). 0 = **no se cansa** | Depredadores | -0.1 | — | -0.05 | **0.0** | **0.0** |

**B · Que vengan derechos.** Los sospechosos reales del zigzag. Ninguno se llama
`FiendZigZag*` — ese campo ya estaba a 0 y aun así zigzagueaban.

| # | Campo | Qué hace | En qué monstruo | Vanilla | Fácil | Normal | Difícil | Hardcore |
|---|---|---|---|---:|---:|---:|---:|---:|
| 44 | `SteeringUpdateRate` | Cada cuántos segundos **recalcula el rumbo**. 0.25 = 4 veces/s: contra un jugador que se mueve, garantiza sobrepasar y corregir | **Todas las criaturas** | 0.25 | — | 0.20 | 0.15 | **0.10** |
| 45 | `MaxTurnRadius` | Radio de giro máximo (m). Con 5 m no pueden virar cerrado hacia ti | Todas las criaturas | 5.0 | — | 4.0 | 3.0 | **2.0** |

**C · En horda.** La manada se mueve como un bloque, no como 7 bichos sueltos.

| # | Campo | Qué hace | En qué monstruo | Vanilla | Fácil | Normal | Difícil | Hardcore |
|---|---|---|---|---:|---:|---:|---:|---:|
| 46 | `FollowLeaderCohereWeight` | Cuánto se **mantiene junta** la manada | **Criaturas en manada** | 0.1 | — | 0.4 | 0.8 | **1.2** |
| 47 | `FollowLeaderAlignWeight` | Cuánto **alinean su dirección** entre sí | Criaturas en manada | 1.0 | — | 1.5 | 2.5 | **3.5** |
| 48 | `SpherePusherWeight.Small` | Cuánto se empujan físicamente los pequeños. Bajarlo = no se sacan unos a otros de su línea de carga | Criaturas pequeñas | 10 | — | 9 | 7 | **5** |
| 49 | `SpherePusherWeight.Medium` | Ídem, medianas (**los Fiend caen aquí**) | Criaturas medianas | 10 | — | 9 | 7 | **5** |
| 50 | `SpherePusherWeight.Large` | Ídem, grandes | Criaturas grandes | 5 | — | 4.5 | 4 | **3** |

### 3e · Fiends — que no suelten la presa (0.3.1)

Solo Hardcore. Estos cinco campos son el diagnóstico de «unos vienen y otros se van».

| # | Campo | Qué hace | En qué monstruo | Vanilla | Fácil | Normal | Difícil | Hardcore |
|---|---|---|---|---:|---:|---:|---:|---:|
| 53 | `FiendAggroDecreasePerSpawn` | **Cuánto aggro gasta cada Fiend al nacer.** Ésta es la causa de fondo: romper un huevo suma +1.0, pero cada bicho que sale resta 0.1, así que una oleada de 12 vacía el medidor ella sola | **Fiend** | 0.1 | — | — | — | **0.0** |
| 54 | `FiendAggroIncreaseDamageEgg` | Aggro que suma **rozar** un huevo | Fiend | 1.0 | — | — | — | **3.0** |
| 55 | `FiendAggroIncreaseDestroyEgg` | Aggro que suma **romperlo** | Fiend | 1.0 | — | — | — | **3.0** |
| 56 | `FiendBeingShotMemoryTime` | Segundos que recuerda que le disparaste | Fiend | 10 | — | — | — | **60** |
| 57 | `FiendDespawnDistance` | A cuántos metros se evapora si te alejas | Fiend | 150 | — | — | — | **300** |

> **Por qué unos venían y otros no, en tres frases.** (1) Con huevos ×20 hay nidos que no
> has tocado: sus Fiends nunca te fijaron, y lo que parece «perder el interés» es que
> nunca lo tuvieron — por eso #18 sube a 120 m. (2) El aggro se drena solo con cada
> nacimiento (#53), que es un sistema calibrado para 6 bichos y densidad ×1. (3) Y encima
> caducaba a los 120 s (#16).
>
> **Sin tocar, a propósito:** `FiendDistToConsiderTargetSwtich` (10.0, el typo es de Hello
> Games) y el `MoveRange` = 100 del `FIEND` en `CREATUREDATATABLE`. Los dos podrían ser
> palancas de «a quién persigue» y «hasta dónde se aleja de su nido», pero no sabemos en
> qué dirección empujan y 0.3.1 ya mueve diez campos. Si con esto todavía se sueltan, es
> lo siguiente que se prueba — **de uno en uno**.

> `SpherePusherWeight.Huge` **no se toca**: los bichos enormes ya empujan poco (2) y
> bajarlo más los haría atravesarse.
>
> **Decisión de diseño: `AvoidCreaturesStrength` del árbol `MELEE` se queda en 0.0.**
> `COMPORTAMIENTO.md` §7 lo proponía subir a 0.5 para separar la manada durante la carga.
> Va **en contra** de «que el movimiento sea como en horda», así que se descarta a
> propósito. La cohesión se busca, el apelotonamiento se combate solo por física de
> empuje (#48-50), no separándolos.

---

## 7 · `METADATA\SIMULATION\ECOSYSTEM\CREATUREBEHAVIOURTREES.MBIN` — hasta 2 cambios

**Archivo nuevo en 0.3.0. Octava ruta, y la primera vez que se toca un árbol de
comportamiento.** Las reglas van ancladas a `{"Id", "MELEE"}` con `REPLACE_TYPE = "ONCE"`.

| # | Campo | Qué hace | En qué monstruo | Vanilla | Fácil | Normal | Difícil | Hardcore |
|---|---|---|---|---:|---:|---:|---:|---:|
| 51 | `BehaviourMoveSpeed` | Velocidad con la que cierran distancia. `Fast` es valor válido del enum: `RANGED_FIRE` ya lo usa en vanilla | **Todo el que use el árbol `MELEE`** (Fiends y depredadores cuerpo a cuerpo) | `Normal` | — | — | **`Fast`** | **`Fast`** |
| 52 | `DynamicMoveSlowdownDistMul` | Multiplicador de la distancia a la que **empiezan a frenar** al acercarse. Bajarlo = no decelera contra ti | Ídem | 4.0 | — | 3.0 | 2.0 | **1.0** |

### ⚠️ Los tres árboles con los mismos campos

`BehaviourMoveSpeed = "Normal"` está en `MELEE` y `RANGED_SPIT`.
`DynamicMoveSlowdownDistMul = 4.0` está en `MELEE`, `RANGED_SPIT` y `RANGED_FIRE`.
`AvoidCreaturesStrength = 0.000000` está en los tres, y `0.000000` aparece por todo el
archivo.

Sin ancla se tocarían los tres árboles. `MELEE` es además el **primer** árbol del
archivo, así que `ONCE` refuerza el ancla.

**Verificado tras la build:** el delta contiene un solo `_id="MELEE"`, un solo nodo
`GcBehaviourMoveToTargetData`, y esos dos campos. `RANGED_SPIT` y `RANGED_FIRE` intactos.

---

## 4 · `METADATA\SIMULATION\ECOSYSTEM\CREATUREDATATABLE.MBIN` — hasta 7 cambios

**Archivo nuevo en 0.2.0.** Todas las reglas van ancladas a `{"Id", "FIEND"}` con
`REPLACE_TYPE = "ONCE"`. **Solo tocan al `FIEND`**, a ninguno de los otros nueve dueños.

| # | Campo | Qué hace | En qué monstruo | Vanilla | Fácil | Normal | Difícil | Hardcore |
|---|---|---|---|---:|---:|---:|---:|---:|
| 23 | `MinFlurryHits` | Golpes mínimos por racha de ataque. Entero | **Solo `FIEND`** | 2 | — | — | 3 | 3 |
| 24 | `MaxFlurryHits` | Golpes máximos por racha. Entero | Solo `FIEND` | 4 | — | — | 5 | 6 |
| 25 | `DelayBetweenPounceAttacks` | Segundos entre saltos sobre ti | Solo `FIEND` | 2.0 | — | 1.8 | 1.5 | 1.2 |
| 26 | `AnimSpeedModifier` | Velocidad de la animación de ataque. **No toca el daño** | Solo `FIEND` | 1.0 | — | — | 1.1 | 1.2 |
| 27 | `AllowSpawnBrood` | Activa que el bicho **pare crías mientras luchas** | Solo `FIEND` | `false` | — | — | — | **`true`** `[SIN PROBAR]` |
| 28 | `SpawnBroodID` | Qué grupo pare. Copiado de `BUGQUEEN` vanilla | Solo `FIEND` → pare **`BUGFIENDS`** | *(vacío)* | — | — | — | `BUGFIENDS` `[SIN PROBAR]` |
| 29 | `SpawnBroodTimer` | Segundos entre partos. `BUGQUEEN` usa 30; bajado para que se vea | Solo `FIEND` | 0.0 | — | — | — | 10 `[SIN PROBAR]` |

### ⚠️ Los diez bloques de ataque

`CREATUREDATATABLE` tiene **diez** bloques `GcCreatureFiendAttackData`, no uno:

| Dueño | Nota |
|---|---|
| `FIEND` | **el que queremos** |
| `BUGFIEND` | la cría del brood |
| `BUGQUEEN` | jefe, calibrado aparte |
| `SCUTTLER` | |
| **`SCUTTLER_PET`** | ⚠️ **la mascota domesticada del jugador** |
| `SLUG`, `MINIFIEND`, `MINIDRONE` | |
| `JELLYBOSS_BROOD`, `LAND_SQUID` | `GcCreatureSpookFiendAttackData`, otra estructura |

Un `REPLACE_TYPE = "ALL"` los tocaría **los diez**, incluida la mascota. Verificado tras la
build: el delta contiene **una sola entrada, `_id="FIEND"`**.

---

## 5 · `BIOMES\OBJECTS\RARE\FIENDEGGS.MBIN` — 4 cambios

| # | Objeto | Campo | Qué hace | En qué monstruo | Vanilla | Fácil | Normal | Difícil | Hardcore |
|---|---|---|---|---|---:|---:|---:|---:|---:|
| 30 | `Objects[0]` (`FLORACLUMP`) | `FlatDensity` | Huevos sembrados en llano | **Huevos de Fiend** | 0.005 | ×2 | ×5 | ×20 | ×20 |
| 31 | `Objects[0]` | `SlopeDensity` | Ídem en pendiente | Huevos de Fiend | 0.005 | ×2 | ×5 | ×20 | ×20 |
| 32 | `DetailObjects[0]` (`RAREX`) | `FlatDensity` | Segunda siembra, en llano | Huevos de Fiend | 0.005 | ×2 | ×5 | ×20 | ×20 |
| 33 | `DetailObjects[0]` | `SlopeDensity` | Ídem en pendiente | Huevos de Fiend | 0.005 | ×2 | ×5 | ×20 | ×20 |

---

## 6 · `BIOMES\OBJECTS\RARE\INFESTATION.MBIN` — 6 cambios

**El orden de estas reglas importa.** El gusano va primero y los huevos últimos.

| # | Objeto | Campo | Qué hace | En qué monstruo | Vanilla | Fácil | Normal | Difícil | Hardcore |
|---|---|---|---|---|---:|---:|---:|---:|---:|
| 34 | `WORMSPAWNER` | `FlatDensity` | Cuántos spawners de gusano hay en llano | **Gusano de arena** | 0.025 | ×2 | ×5 | ×20 | ×20 |
| 35 | `WORMSPAWNER` | `SlopeDensity` | Ídem en pendiente | Gusano de arena | 0.030 | ×2 | ×5 | ×20 | ×20 |
| 36 | `FIENDEGGS` | `FlatDensity` | Huevos en llano | Huevos de Fiend | 0.005 | ×2 | ×5 | ×20 | ×20 |
| 37 | `FIENDEGGS` | `SlopeDensity` | Huevos en pendiente | Huevos de Fiend | 0.005 | ×2 | ×5 | ×20 | ×20 |
| 38 | (sin nombre, `RAREX`) | `FlatDensity` | Tercera siembra en llano | Huevos de Fiend | 0.005 | ×2 | ×5 | ×20 | ×20 |
| 39 | (sin nombre, `RAREX`) | `SlopeDensity` | Ídem en pendiente | Huevos de Fiend | 0.005 | ×2 | ×5 | ×20 | ×20 |

> **Trampa de orden:** las reglas de un mismo archivo se aplican **en secuencia**. Con
> `EGG_MULT = 5` los huevos pasaban a 0.025 y la regla del gusano (`VALUE_MATCH 0.025`)
> los volvía a multiplicar → ×25 en vez de ×5. Solo se manifestaba en **Normal**.
>
> **Trampa de los dos bloques:** cada objeto lleva `QualityVariants` (el bueno) y debajo un
> `QualityVariantData` con `Coverage 0.2` / `FlatDensity 0.5` idéntico en los cinco objetos.
> Los scripts usan `VALUE_MATCH` para no tocarlo. **`Coverage` no se toca**: rango
> desconocido.

---

## 8 · `GLOBALS\GCUIGLOBALS.GLOBAL.MBIN` — 1 cambio

**Archivo nuevo en 0.3.1. Novena ruta, y la primera fuera del ecosistema.** Solo Hardcore.

| # | Campo | Qué hace | En qué monstruo | Vanilla | Fácil | Normal | Difícil | Hardcore |
|---|---|---|---|---:|---:|---:|---:|---:|
| 58 | `ShowOnscreenPredatorMarkers` | Icono de UI sobre el depredador que te está cazando. `false` = te cae encima sin aviso | **Depredadores** (solo UI, no dificultad) | `true` | — | — | — | **`false`** |

**Dónde estaba y por qué costó encontrarlo.** No está en `GCCREATUREGLOBALS`, que es donde
viven los otros ~40 campos de depredador y donde se buscó primero. Está en `GCUIGLOBALS`,
línea 2572 — el archivo del HUD. Es el gemelo de `FiendOnscreenMarkers` (#17), que sí vive
con las criaturas: **la misma función, en dos archivos distintos.**

Se encontró barriendo la tabla de cadenas de `libMBIN.dll` por `Marker` — 230
identificadores, y `ShowOnscreenPredatorMarkers` es el único que pega. Es el mismo método
que destapó `DebugGalaxyMapInQuickMenu` en el mod 3, y aquí sí sirvió de algo.

⚠️ **Es una ruta disputada.** `Small Cursor 6.6` la toca con un EXML de cuatro líneas
(`FrontendCursorSize`, `FrontendCursorWidth`). No hay solape de campos, pero sí de archivo.
Ver el README de `infestacion` — el cursor del menú es el testigo al probar.

---

## Resumen por monstruo — «qué le hicimos a quién»

| Monstruo / entidad | Qué cambia | Filas |
|---|---|---|
| **Depredadores** (`PLAYERPREDATORMED` / `LARGE`) | Salen en manada en vez de solos, en muchos más planetas, te ven más lejos, no huyen heridos, todos son hostiles, tardan más en aburrirse, **desde 0.3.0 no te acechan: te ven y cargan desde 40 m sin cansarse**, y **desde 0.3.1 sin marcador de UI que te avise** | 5-12, 40-43, 58 |
| **Fiend** (Horror Biológico) | Muchos más huevos, más Fiends encima a la vez, más rato persiguiendo, te ven más lejos, salen del huevo en oleada, sin marcador de UI, pegan más golpes por racha, saltan más seguido, animan más rápido, en Hardcore **paren crías mientras luchas** y **desde 0.3.1 no se les agota el aggro** | 13-33, 53-57 |
| **`BUGFIEND`** | Es lo que pare el brood del Fiend en Hardcore. **No se le edita ningún campo**, solo se le invoca | 28 |
| **Gusano de arena** (`GROUNDWORMSPAWNER`) | Muchos más spawners y salta cuando ya lo tienes encima (100 m → 10 m) | 22, 34-35 |
| **Todo el que use el árbol `MELEE`** (Fiends + depredadores cuerpo a cuerpo) | Cierran distancia en `Fast` y **no frenan** al llegar encima | 51-52 |
| **Criaturas en manada** | Se mantienen juntas, alinean su dirección y se empujan menos entre sí — **movimiento de horda** | 46-50 |
| **Toda la fauna terrestre** | ×2/×5/×20 de densidad, tope de criaturas vivas más alto, más separación entre bichos, **rumbo recalculado el doble de seguido y giro más cerrado** | 1-4, 11, 21, 44-45 |
| **`SCUTTLER_PET`** (mascota del jugador) | **Nada** en `CREATUREDATATABLE`: protegida por el anclaje `_id="FIEND"`. Sí le llegan los cambios **globales** de movimiento (#44-50), como a toda criatura | — |
| **`BUGQUEEN`, `SCUTTLER`, `SLUG`, `MINIFIEND`, `MINIDRONE`** | **Nada** por especie. Mismo motivo | — |

---

## Conteo por tier — si el `REPORT` no da esto, no se despliega

| Tier | gen | med | large | globals | datatable | eggs | infest | árbol | **uiglobals** | **Total** |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 Fácil | 5 | 2 | 2 | 4 | — | 4 | 6 | — | — | **23** |
| 2 Normal | 5 | 2 | 2 | 24 | 1 | 4 | 6 | 1 | — | **45** |
| 3 Difícil | 5 | 2 | 2 | 25 | 4 | 4 | 6 | 2 | — | **50** |
| 4 Hardcore | 5 | 2 | 2 | 31 | 7 | 4 | 6 | 2 | **1** | **60** |

**Construidos y verificados el 2026-08-05:** los cuatro dan estos totales con 0 errores.
Fácil sigue sin cambiar desde 0.1.0, y Normal y Difícil desde 0.3.0.

Comprobar el total en **las cuatro** configuraciones: el bug de cascada de 0.1.0 solo
aparecía en una.

### Histórico de conteos

| Versión | Fácil | Normal | Difícil | Hardcore |
|---|---:|---:|---:|---:|
| 0.1.0 | 23 | 27 | 27 | 28 |
| 0.2.0 (1ª build, con zigzag) | 23 | 33 | 39 | 43 |
| 0.2.0 (final) | 23 | 33 | 37 | 41 |
| 0.3.0 | 23 | 45 | 50 | 54 |
| **0.3.1** | **23** | **45** | **50** | **60** |

---

## Tipos — cómo se escribe cada cosa

| Enteros (sin decimales) | Booleanos (minúsculas) | Cadenas |
|---|---|---|
| `FiendMaxAttackers`, `FiendMaxEngaged`, `MaxFiendsToSpawn`, `MaxEcosystemCreaturesNormal`, `MinFlurryHits`, `MaxFlurryHits` | `FiendOnscreenMarkers`, `ShowOnscreenPredatorMarkers`, `AllowSpawnBrood` | `SpawnBroodID`, `BehaviourMoveSpeed` (enum: `Normal` / `Fast`) |

Todo lo demás es float con **6 decimales**. Ojo con `PredatorEnergyUseChasing`: vanilla es
**negativo** (`-0.100000`).

**AMUMSS empareja el nombre de propiedad exacto, no por prefijo.** Verificado en el delta
de 0.3.1: `MaxFiendsToSpawn` **no** tocó `MaxFiendsToSpawnCarnage`. (El `{"Weight ", ...}`
con espacio final que hay en los scripts es para anclar dentro de un struct, no por esto.)

---

## Retirado — no está en el juego

| Campo | Tier | Por qué se retiró |
|---|---|---|
| `FiendZigZagSpeed` | Difícil 1.0 / Hardcore 1.5 | Los Fiend **ya zigzaguean con el campo a 0**, luego no es la palanca; subirlo empujaría justo en la dirección que molesta. Nunca llegó a desplegarse |
| `FiendZigZagStrength` | Difícil 0.10 / Hardcore 0.15 | Ídem |

Causa real del zigzag **sin identificar**. Sospechosos por orden: `MaxTurnRadius = 5.0`,
el empuje entre bichos de las manadas 5/7 (`SpherePusher*`, lo causa **nuestro** mod), y
`AvoidCreaturesStrength = 0` en el árbol `MELEE`.

---

## Confianza de cada cambio de 0.3.0

Ninguno se ha jugado. Esto es lo bien fundado que está cada uno **antes** de probarlo.

| Filas | Confianza | Por qué |
|---|---|---|
| 40-42 acecho | **Alta** | Nombres inequívocos y la secuencia vanilla (1.5 s pausa → 4 s acecho → carga a 7 m) coincide con lo que se ve jugando |
| 51-52 árbol `MELEE` | **Alta** | `Fast` está verificado como valor válido porque `RANGED_FIRE` lo usa en vanilla, y el delta salió exacto |
| 43 energía de persecución | Media | El signo negativo dice que drena; qué pasa al agotarse es inferencia |
| 44 `SteeringUpdateRate` | Media | **Sospechoso nº1 del zigzag.** 4 recálculos/s contra un blanco móvil explican bien el sobrepasar-y-corregir, pero no está confirmado |
| 45 `MaxTurnRadius` | Media | Sospechoso nº2, ya estaba en la lista de `COMPORTAMIENTO.md` §5b |
| 46-50 horda | Media | Los nombres son claros; las magnitudes no tienen referencia vanilla de comparación |

## Pendiente de verificar in-game

| Qué | Tier | Cómo probarlo |
|---|---|---|
| **Zigzag: ¿desaparece?** | Hardcore | **La prueba que separa las causas: mirar primero un Fiend SOLO.** Si uno suelto ya viene derecho, la causa era el steering/giro (#44-45). Si sigue haciendo eses solo, ninguno de los dos era y hay que ir a `PathOverestimate` o `FlowFieldWeight` |
| **¿Vienen sin acechar?** | Hardcore | Dejarte ver a ~35 m en campo abierto. Debe arrancar **sin pausa** y llegar sin pararse a mitad |
| **¿Se mueven como horda?** | Hardcore | Manada de 5-7 depredadores: deben llegar como un bloque, no en fila india ni desperdigados |
| Rendimiento con `SteeringUpdateRate` 0.10 | Hardcore | 70 criaturas recalculando rumbo 10 veces/s en vez de 4. **Si hay caída de FPS, éste es el primero a revertir** |
| `AllowSpawnBrood` — que se multipliquen | Hardcore | **Hace falta un sitio con Fiends pero sin huevos cerca**: con `FiendMaxEngaged = 12` y huevos ×20, una cría es indistinguible de un Fiend recién eclosionado. Si falla: probar `SpawnBroodAnim = BIRTHING`, y si tampoco, revertir el brood entero |
| `FiendOnscreenMarkers = false` | Difícil, Hardcore | Comprobar que no rompe el escáner ni las misiones que usan `FIENDCORE` como `ValidMissionSurveyId` del huevo |
| El resto de 0.2.0 | los 4 | **Nunca se ha jugado 0.2.0**: la prueba del 04/08 midió 0.1.0. Sus 8 cambios se estrenan junto a los 13 de 0.3.0 |

## Orden para revertir si algo va mal

1. `SteeringUpdateRate` (#44) — si caen los FPS.
2. `MaxTurnRadius` (#45) — si las criaturas se atascan en el terreno o giran raro.
3. Las dos filas del árbol (#51-52) — si la IA de ataque hace algo extraño.
4. `AllowSpawnBrood` (#27-29) — sigue siendo el cambio con menos respaldo vanilla.
