# Changelog — Mod 2: Horrible Terror · Infestation

Formato: [Keep a Changelog](https://keepachangelog.com/). Versionado: SemVer.

Este mod se versiona **aparte del mod 1**. No es una actualización de
`HorribleTerror_Predators`: es otro mod que **contiene** al mod 1 y añade los Horrores
Biológicos. Se instala uno o el otro, nunca los dos.

- Changelog del mod 1 y del proyecto: [`CHANGELOG.md`](CHANGELOG.md)
- Referencia de conducta: [`COMPORTAMIENTO.md`](COMPORTAMIENTO.md)
- **Tabla viva de todos los campos: [`MODIFICACIONES.md`](MODIFICACIONES.md)**
- Tabla de configuraciones: [`../work/scripts/infestacion/README.md`](../work/scripts/infestacion/README.md)

Cada entrada anota la **versión de NMS** contra la que se probó.

---

## [0.3.2] — 2026-08-07

Construido contra NMS **170671**, MBINCompiler 6.45.0.1. **Solo cambia Hardcore**: Fácil,
Normal y Difícil salen idénticos (23 / 45 / 50). Hardcore pasa de **60 a 97** cambios,
0 errores. Es la primera versión que toca **geometría del mundo** en vez de solo números.

### Added — los Horrores anidan dentro de los edificios abandonados

**Décima ruta, y la primera fuera de `METADATA` y `GLOBALS`:**

```
MODELS\PLANETS\BIOMES\COMMON\BUILDINGS\ABANDONED\ABANDONDEDSCIENTIFIC.LSYSTEM.MBIN
                                                \ABANDONDEDTRADER.LSYSTEM.MBIN
                                                \ABANDONDEDWARRIOR.LSYSTEM.MBIN
```

(el typo `ABANDONDED` es de Hello Games). Los edificios abandonados **no son modelos
fijos**: son L-systems que cuelgan props de *locators* con una probabilidad. Los tres
traen un locator **`TENTACLE_`** —hueco de bicho orgánico colgado— con
`INTERIOR_TENTACLEPLANT` al 30 %, cinco veces por edificio.

Ese modelo pasa a ser `RARERESOURCE\GROUND\FIENDEGG.SCENE.MBIN` y la probabilidad sube a
100. Resultado: **hasta 5 huevos por edificio abandonado, siempre.**

**Por qué esto funciona sin escribir nada de spawn:** el huevo **no invoca criaturas**. Su
entidad solo declara `Explosion = FIENDHATCH` e `IncreaseFiendCrime = EggDestroyed`; quién
sale, cuántos y cuándo lo decide el sistema global de `GCCREATUREGLOBALS`. Es decir, el
spawn de Horrores es **global, no local**, y un huevo puesto en cualquier sitio hereda
gratis los diez campos que 0.3.1 ya subió. Detalle en [`ASSETS.md`](ASSETS.md) §5.4.

### Added — los nidos del carguero reaccionan a la linterna y a los disparos

**Undécima ruta:** `…\SPACEBASE\INFESTATION\{LARGEPILLARSLIME,MEDIUMHANGSLIME}\ENTITIES\*.ENTITY.MBIN`.

Los nidos de los cargueros abandonados llevan un componente que no habíamos visto nunca,
**`GcAlienPodComponentData`**, con la mecánica de «el nido te huele»:

| Campo | Vanilla | 0.3.2 | Qué hace |
|---|---:|---:|---|
| `AgroMovement` / `Range` | 11.0 / 8.5 | — | te detecta por moverte cerca |
| **`AgroTorch`** | **0.0** | **12.0** | apuntar con la linterna lo despierta |
| **`GunfireAgro`** | **0.0** | **8.0** | disparar cerca lo despierta |

Los dos que subimos estaban **a cero: interruptores implementados y apagados por Hello
Games**, igual que `AllowSpawnBrood`. `AgroThreshold` (15) y `AgroRate` (−5) se dejan
quietos, así que la escala de los valores nuevos es **inferencia sin confirmar**.

### Added — los Horrores de interior salen antes y aguantan más

En `GCCREATUREGLOBALS`, tres campos que el mod nunca había tocado:

| Campo | Vanilla | 0.3.2 |
|---|---:|---:|
| `FreighterSpawnDist` | 30 | **60** |
| `FreighterDespawnDist` | 50 | **150** |
| `FiendSpawnDistance` | 70 | **120** |

Los dos primeros son **específicos de interiores de carguero** y viven pegados al bloque
`Indoor*`, no al de Fiend — por eso no aparecieron en los barridos anteriores.

### Conteo

| Tier | gen | med | large | globals | uigl | árbol | datatable | eggs | infest | **lsystem** | **nidos** | Total |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 4 Hardcore | 5 | 2 | 2 | **34** | 1 | 2 | 7 | 4 | 6 | **30** | **4** | **97** |

Verificado descompilando desde `GAMEDATA\MODS`: 5 huevos por L-system, los otros cinco
`Probability = 30` del archivo **sin tocar**, y `AgroMovement`/`AgroThreshold` intactos.

### ⚠️ Conflicto conocido

**`NoDerelictMiniHorrors` (Lenni) escribe los mismos dos `.ENTITY.MBIN`** de los nidos. Hay
que desactivarlo en Vortex antes de probar cargueros, o no se mide nada: ese mod les quita
el `GcAlienPodComponentData` entero y el `DestroyedModel` que suelta los MiniFiends.

### Sin probar

Todo. Save respaldado: `NMS_saves_2026-08-07_0019_antes-032-huevos-en-edificios-y-skin`.
Plan de prueba: [`CHECKLIST-0.3.2.md`](CHECKLIST-0.3.2.md). Sigue pendiente **toda** la
0.3.1: [`CHECKLIST-0.3.1.md`](CHECKLIST-0.3.1.md).

---

## [0.3.1] — 2026-08-05

Construido contra NMS **170671** (rama Public), MBINCompiler 6.45.0.1.
**Solo cambia Hardcore.** Fácil, Normal y Difícil salen idénticos a 0.3.0 — mismo conteo
(23 / 45 / 50) y mismos deltas.

### Added

- **Se le quita el marcador de UI a los depredadores**, no solo a los Horrores.
  El campo **no está en `GCCREATUREGLOBALS`**, que es donde se buscó primero: vive en
  `GLOBALS\GCUIGLOBALS.GLOBAL.MBIN`, línea 2572, y se llama
  **`ShowOnscreenPredatorMarkers`** (`true` en vanilla). Es una **novena ruta** para el mod
  y la primera fuera del ecosistema.
  - Cómo se encontró: barriendo la tabla de cadenas de `libMBIN.dll` por `Marker` — el
    mismo método que destapó `DebugGalaxyMapInQuickMenu` en el mod 3. Devuelve 230
    identificadores y `ShowOnscreenPredatorMarkers` es el único que pega. Buscar campo por
    archivo no lo habría encontrado nunca: nadie iba a abrir `GCUIGLOBALS` buscando
    depredadores.
  - Es un booleano, único en el archivo, sin colisión de prefijo.

### Changed — los Horrores no sueltan la presa

El diagnóstico de por qué unos vienen y otros se van. Son **tres causas distintas**, y
solo la tercera es la que suena a «pierden el interés»:

| Causa | Campo | Qué pasaba |
|---|---|---|
| **Nunca te vieron** | `FiendPerceptionDistance` = 80 | Con huevos ×20 hay nidos por todas partes. Un Horror que sale de un nido que no has tocado y a más de 80 m **no llega a fijarte**: no pierde el interés, es que nunca lo tuvo. Ése es el que «se aleja» — está haciendo su ronda |
| **El aggro se drena solo** | `FiendAggroDecreasePerSpawn` = 0.1 | Es la causa de fondo. Romper un huevo sube el aggro +1.0; **cada Horror que nace lo baja 0.1**. Con 12 saliendo en oleada el medidor se vacía él solo en un combate, sin que tú hagas nada. Es un sistema pensado para 6 bichos y densidad ×1 |
| **Caducaba** | `FiendAggroTime` = 120 s | Dos minutos y a casa |

Además, `FiendMaxEngaged` = 12 con `MaxFiendsToSpawn` = 12 dejaba el cupo justo: cualquier
Horror de más se queda mirando en vez de entrar.

Valores nuevos, todos solo en Hardcore:

| Campo | 0.3.0 | 0.3.1 | Qué hace |
|---|---:|---:|---|
| `FiendAggroDecreasePerSpawn` | 0.1 | **0.0** | nacer ya no gasta aggro |
| `FiendAggroIncreaseDamageEgg` | 1.0 | **3.0** | rozar un huevo llena el medidor a fondo |
| `FiendAggroIncreaseDestroyEgg` | 1.0 | **3.0** | ídem al romperlo |
| `FiendAggroTime` | 120 | **600** | diez minutos de rencor |
| `FiendPerceptionDistance` | 80 | **120** | te fijan desde el doble de lejos que en vanilla |
| `FiendMaxEngaged` | 12 | **16** | cuántos te tienen fichado |
| `FiendMaxAttackers` | 6 | **8** | cuántos pegan a la vez |
| `MaxFiendsToSpawn` | 12 | **16** | si sube el cupo de comprometidos, el de vivos tiene que dar |
| `FiendBeingShotMemoryTime` | 10 | **60** | dispararle a uno lo deja pegado a ti un minuto |
| `FiendDespawnDistance` | 150 | **300** | correr 150 m ya no los evapora |

Conteo Hardcore: **54 → 60** (31 globals + 1 uiglobals). 0 errores. Delta verificado
propiedad por propiedad, y `MaxFiendsToSpawnCarnage` **sin tocar** pese a que
`MaxFiendsToSpawn` es prefijo suyo — AMUMSS empareja el nombre exacto, no por prefijo.

### Fixed — el mod no estaba desplegado, otra vez

Lo que había en `GAMEDATA\MODS\HorribleTerror_Infestation_4-Hardcore\` eran **8 EXML y 0
MBIN**, y los EXML eran el delta de `CreatedMODS` **con sus 26 marcas `!# CHANGED` dentro
del XML**. Es exactamente lo que hundió la PRUEBA 01 del mod 3, y es la tercera vez que
esta trampa muerde a este proyecto (ver también la sesión del 04/08 en el README de
`infestacion`, donde la prueba midió 0.1.0 creyendo medir 0.2.0).

**Consecuencia:** las observaciones in-game de 0.3.0 —incluida «unos Horrores vienen y
otros se van»— se hicieron contra un mod que **probablemente no estaba activo**. El
diagnóstico de arriba se sostiene igual, porque sale de leer los campos vanilla y no de lo
que se vio en pantalla; pero **0.3.1 es el primer despliegue de Hardcore que está
verificado como MBIN**, y por tanto la primera medición que va a valer.

Desplegado desde `ModBackups\` creando el `GLOBALS\` a mano —AMUMSS deja los dos MBIN de
globals sueltos en la raíz, mismo detalle que en la PRUEBA 05 del mod 3— y verificado
descompilando de vuelta desde `GAMEDATA\MODS`. La carpeta vieja se retiró a
`build\_retirado_2026-08-05_infestacion-0.3.0-EXML\`.

### Tooling

`Build-Tiers.ps1` borraba de `ModScript\` solo los `.lua` cuyo nombre coincidía con los de
la carpeta que se construía, así que un script olvidado de otra sesión se construía también
y contaminaba el conteo agregado. Ahora los borra **todos**. Lo destapó el mod 3 y aquí
habría vuelto a pasar: `MOD3_MapaGalactico_PRUEBA06.lua` seguía en la carpeta.

### Sin probar

- Todo lo de esta versión. Save respaldado: `NMS_saves_2026-08-05_0111_antes-infestacion-031`.
- **Mirar el cursor del menú.** Es el testigo gratis de si nuestro MBIN de `GCUIGLOBALS`
  convive con el EXML de `Small Cursor 6.6`. Ver el README de `infestacion`.
- `FiendDistToConsiderTargetSwtich` (10.0, el typo es de Hello Games) y el `MoveRange` =
  100 del `FIEND` en `CREATUREDATATABLE` se dejan quietos: los dos podrían ser palancas de
  «a quién persigue» y «hasta dónde», pero no sabemos en qué dirección empujan y esta
  versión ya cambia diez campos. Quedan para la siguiente si con esto todavía se sueltan.

---

## [0.3.0] — 2026-08-04

Construido contra NMS **170671** (rama Public), MBINCompiler 6.45.0.1.
**Hardcore desplegado y verificado en `GAMEDATA\MODS`: 54 cambios en 8 EXML.**
Sin probar in-game todavía.

0.1.0 subió la **cantidad** de Fiends. 0.2.0 cambió su **conducta de ataque**.
0.3.0 cambia **cómo se te acercan**: sin acechar, derechos y en horda.

### Added

- **Archivo nuevo: `METADATA\SIMULATION\ECOSYSTEM\CREATUREBEHAVIOURTREES.MBIN`.** Octava
  ruta del mod y **la primera vez que se toca un árbol de comportamiento**, no solo
  valores sueltos.
  - `BehaviourMoveSpeed` `Normal` → **`Fast`** en el nodo `MoveToTarget` de `MELEE`
    (Difícil y Hardcore). `Fast` está verificado como valor válido del enum porque
    `RANGED_FIRE` ya lo usa en vanilla.
  - `DynamicMoveSlowdownDistMul` 4.0 → 3.0/2.0/1.0. Los bichos **frenaban** al acercarse;
    ahora llegan encima sin decelerar.
  - Las dos reglas van ancladas con `SPECIAL_KEY_WORDS = {"Id", "MELEE"}` y
    `REPLACE_TYPE = "ONCE"`. **Verificado en el delta:** un solo `_id="MELEE"`, un solo
    nodo `GcBehaviourMoveToTargetData`. `RANGED_SPIT` y `RANGED_FIRE` intactos.
- **Se acabó el acecho** — cuatro campos de `GCCREATUREGLOBALS` que nunca se habían
  tocado. La secuencia vanilla era: te ve → **pausa 1.5 s** → se acerca → **acecha 4 s** →
  carga solo a 7 m.
  - `PredatorNoticePauseTime` 1.5 → 0.8/0.3/**0.0**
  - `PredatorApproachTime` 4.0 → 2.0/0.5/**0.0**
  - `PredatorChargeDist` 7.0 → 12/25/**40**: carga desde lejos en vez de acercarse primero.
  - `PredatorEnergyUseChasing` -0.1 → -0.05/**0.0**. **Hallazgo nuevo:** perseguir gastaba
    energía. A 0 no se cansan a mitad de la persecución.
- **Que vengan derechos** — los sospechosos reales del zigzag:
  - **`SteeringUpdateRate` 0.25 → 0.20/0.15/0.10. Hallazgo nuevo y sospechoso nº1.** El
    rumbo se recalculaba solo **4 veces por segundo**; contra un jugador que se mueve, eso
    garantiza sobrepasar y corregir, que es exactamente lo que se ve como zigzag.
  - `MaxTurnRadius` 5.0 → 4.0/3.0/**2.0**. Ya estaba en la lista de sospechosos de
    `COMPORTAMIENTO.md` §5b y por fin entra.
- **Movimiento de horda** — la manada se mueve como un bloque:
  - `FollowLeaderCohereWeight` 0.1 → 0.4/0.8/**1.2**. **Hallazgo nuevo.** Vanilla lo tenía
    casi apagado.
  - `FollowLeaderAlignWeight` 1.0 → 1.5/2.5/**3.5**: alinean su dirección entre sí.
  - `SpherePusherWeight` Small/Medium 10 → 9/7/**5** y Large 5 → 4.5/4/**3**. Menos empujón
    mutuo = no se sacan unos a otros de su línea de carga. Ataca a la vez el
    amontonamiento y el sospechoso (b) del zigzag. `Huge` **no se toca**.

### Changed

- **Fácil sigue sin cambiar**, tercera versión consecutiva. Ninguno de los 13 cambios de
  0.3.0 entra en ese tier. Sus EXML son idénticos a los de 0.1.0.
- Conteo esperado por tier: **23 / 45 / 50 / 54** (antes 23 / 33 / 37 / 41).
- El mod pasa de 7 rutas a **8**.

### Decisiones de diseño

- **`AvoidCreaturesStrength` del árbol `MELEE` se queda en 0.0, a propósito.**
  `COMPORTAMIENTO.md` §7 lo tenía como punto 11 — subirlo a 0.5 para que los atacantes no
  se amontonen durante la carga. **Va justo en contra de «que el movimiento sea como en
  horda»**, que es lo pedido. El apelotonamiento se combate por física de empuje
  (`SpherePusherWeight`), no separando la manada. Queda descartado mientras el objetivo
  sea la horda.
- **`PathOverestimate` (6.0) se deja fuera** pese a ser candidato del zigzag: no se sabe si
  es margen de seguridad del pathfinding, y bajarlo podría hacer que se claven en el
  terreno. Es el siguiente a probar si #44 y #45 no bastan.

### Trampas nuevas documentadas

- **Los backups de AMUMSS siguen sin servir como vanilla.** Los valores de esta versión se
  sacaron desempaquetando `NMSARC.globals.pak` con `hgpaktool` y decompilando con
  MBINCompiler. `hgpaktool -f <filtro>` **no filtró nada** con ningún patrón probado; hubo
  que desempaquetar el pak entero (41 archivos, es pequeño) y buscar dentro.
- **`PredatorEnergyUseChasing` es negativo en vanilla** (`-0.100000`). Es el primer campo
  del mod cuyo valor vanilla lleva signo.
- **`BehaviourMoveSpeed` es un enum, no un número:** se escribe `Fast` / `Normal` sin
  comillas en el MXML.
- **En un árbol de comportamiento, `0.000000` aparece por todas partes.** Cualquier regla
  sobre `CREATUREBEHAVIOURTREES` necesita ancla; sin ella, `MELEE`, `RANGED_SPIT` y
  `RANGED_FIRE` comparten `DynamicMoveSlowdownDistMul = 4.0` y `AvoidCreaturesStrength = 0`.

### Build y despliegue — 2026-08-04

- Los cuatro tiers, **0 errores**. Conteos **23 / 45 / 50 / 54**, exactamente los previstos:

  | Tier | gen | med | large | globals | datatable | eggs | infest | árbol | Total |
  |---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
  | 1 Fácil | 5 | 2 | 2 | 4 | — | 4 | 6 | — | **23** |
  | 2 Normal | 5 | 2 | 2 | 24 | 1 | 4 | 6 | 1 | **45** |
  | 3 Difícil | 5 | 2 | 2 | 25 | 4 | 4 | 6 | 2 | **50** |
  | 4 Hardcore | 5 | 2 | 2 | 26 | 7 | 4 | 6 | 2 | **54** |

- ✅ **Desplegado a `GAMEDATA\MODS` y verificado leyendo el EXML**, que es el paso que
  faltó en 0.2.0: 54 `!# CHANGED` repartidos 26+2+7+5+2+2+4+6 en 8 archivos.
- ✅ El delta de `SpherePusherWeight` toca `Small`, `Medium` y `Large`, y **no `Huge`**.
- Backup previo: `NMS_saves_2026-08-04_1240_antes-mod2-0.3.0-movimiento`.

### Pendiente

- [ ] **Prueba in-game.** Empezar por **un Fiend solo**: es lo que separa las causas del
      zigzag. Si uno suelto ya viene derecho, era el steering/giro; si sigue haciendo eses
      solo, ninguno de los dos era.
- [ ] Comprobar que arrancan **sin pausa** al verte y llegan sin pararse a mitad.
- [ ] Comprobar que la manada de 5-7 llega **como un bloque**.
- [ ] **Vigilar los FPS.** 70 criaturas recalculando rumbo 10 veces/s en vez de 4.
      `SteeringUpdateRate` es el primero a revertir si hay caída.
- [ ] Todo lo que 0.2.0 dejó sin medir: brood, marcador de UI, eclosión en oleada.

---

## [0.2.0] — en curso

Probado contra NMS **170671** (rama Public), MBINCompiler 6.45.0.1.

0.1.0 subía la **cantidad** de Fiends. 0.2.0 cambia su **conducta**.

### Added

- **Archivo nuevo: `METADATA\SIMULATION\ECOSYSTEM\CREATUREDATATABLE.MBIN`.** Es la
  séptima ruta del mod y la primera vez que se tocan datos de ataque por especie.
- **Sin marcador de UI** (`FiendOnscreenMarkers` `true` → `false`). El juego dibujaba
  un icono sobre cada Fiend. Quitarlo no cambia ningún número de dificultad, solo te
  quita el aviso. Difícil y Hardcore.
- **Percepción propia del Fiend** (`FiendPerceptionDistance` 60 → 65/70/80). Es un
  campo **independiente** de `PredatorPerceptionDistance`; hasta ahora no se tocaba, y
  eso dejaba a los Fiend de Hardcore viéndote *más tarde* (60) que a un depredador
  normal (80). Corregido.
- **Eclosión en oleada** (`FiendMinSpawnTime`/`MaxSpawnTime` 0.25/3.0 → hasta 0.1/0.5).
  Los Fiend salían del huevo escalonados a lo largo de 3 segundos; ahora salen de golpe.
- **Menos amontonamiento** (`AvoidCreaturesWeight` 6 → 8/10). Primer intento barato
  contra el apelotonamiento de las manadas de 5-7 que introdujo el mod 1.
- **Gusano por cercanía** (`GroundWormSpawnerActivateRadius` 100 → 50/20/10). El
  `WORMSPAWNER` de `INFESTATION.MBIN` es un spawner **activado por proximidad, sin
  romper nada**, y ya estaba en el mod desde 0.1.0 sin que lo aprovecháramos. Bajar el
  radio hace que salte cuando ya lo tienes encima.
- **Más golpes por racha** (`MinFlurryHits`/`MaxFlurryHits` 2/4 → 3/5 y 3/6). Difícil
  y Hardcore.
- **Salto más seguido** (`DelayBetweenPounceAttacks` 2.0 → 1.8/1.5/1.2).
- **Ataques más rápidos** (`AnimSpeedModifier` 1.0 → 1.1/1.2), sin tocar el daño.
- **Los Fiend se multiplican mientras luchas** (`AllowSpawnBrood` `false` → `true`,
  `SpawnBroodID` → `BUGFIENDS`, `SpawnBroodTimer` → 10). **Solo Hardcore.**
  Sigue `[Sin probar]` — ver la prueba in-game más abajo.

### Changed

- **Fácil no cambia en 0.2.0**, a propósito. Ninguno de los ocho cambios entra en ese
  tier: sus valores coincidirían con vanilla y escribirlos ensuciaría el EXML delta sin
  cambiar nada, que es el mismo criterio que ya seguía en 0.1.0. **Su EXML es idéntico
  al de 0.1.0** — quien tenga Fácil instalado no necesita actualizar.
- Conteo de cambios esperado por tier: **23 / 33 / 37 / 41** (antes 23 / 27 / 27 / 28).

### Removed

- **Aproximación en zigzag** (`FiendZigZagSpeed`/`Strength`). Entró en la primera build
  de 0.2.0 con 1.0/0.10 en Difícil y 1.5/0.15 en Hardcore, y **se retira tras probarla
  in-game**. Ver abajo. Se quita la regla entera en vez de escribir 0: escribir el
  propio valor vanilla ensucia el EXML delta sin cambiar nada.

### Trampas nuevas documentadas

- **`CREATUREDATATABLE` tiene diez bloques de `GcCreatureFiendAttackData`, no uno.**
  Los dueños son `FIEND`, `BUGFIEND`, `BUGQUEEN`, `SCUTTLER`, **`SCUTTLER_PET`**,
  `SLUG`, `MINIFIEND` y `MINIDRONE`, más 2 de `GcCreatureSpookFiendAttackData`
  (`JELLYBOSS_BROOD`, `LAND_SQUID`).
  - `SCUTTLER_PET` **es la mascota del jugador** y `BUGQUEEN` es un jefe calibrado
    aparte. Un `REPLACE_TYPE = "ALL"` los tocaría a los diez.
  - Por eso cada regla del archivo va anclada con
    `SPECIAL_KEY_WORDS = {"Id", "FIEND"}` y `REPLACE_TYPE = "ONCE"`, el mismo patrón
    que ya se usaba para el peso de `DANGEROUS`.
- `MinFlurryHits` y `MaxFlurryHits` son **enteros** en el MXML, como
  `FiendMaxAttackers` y `MaxEcosystemCreaturesNormal`. Se escriben `3`, no `3.000000`.
- `FiendOnscreenMarkers` y `AllowSpawnBrood` son **booleanos**: `false` / `true` en
  minúsculas.

### ⚠️ Sesión del 2026-08-04 — la prueba in-game midió 0.1.0, no 0.2.0

**0.2.0 se construyó el 04/08 y nunca se copió a `GAMEDATA\MODS`.** La prueba de esa
tarde se jugó contra 0.1.0. Comprobado leyendo el EXML desplegado: 9 cambios en
`GCCREATUREGLOBALS` — los de 0.1.0 — y **ningún `CREATUREDATATABLE.EXML`**, que es el
archivo que estrena esta versión. Ni `FiendOnscreenMarkers` ni `FiendZigZag*` estaban
puestos.

> **Regla nueva: construir no es desplegar.** Antes de cualquier prueba in-game, leer el
> EXML de `GAMEDATA\MODS` y confirmar que contiene los campos de la versión que se cree
> estar probando. Un `REPORT` con el conteo correcto dice que la build salió; **no** dice
> que esté en el juego. Los conteos 23/33/39/43 de la build del 04/08 eran correctos y
> aun así se jugó contra la versión anterior.

Qué queda en pie de esa prueba:

| Observación | Veredicto |
|---|---|
| Los Fiend se acercan zigzagueando, no vienen derechos | **Válida** — y con `FiendZigZagSpeed` a 0 |
| No se multiplicaban | **Nula.** El archivo no estaba en el juego |
| El marcador de UI | **Nula.** El cambio no estaba desplegado |

**El zigzag se retira igualmente**, por lo que sí demuestra la observación válida: los
Fiend zigzaguean **con el campo a 0**, luego `FiendZigZagSpeed` no es la palanca que lo
causa, y subirlo solo habría empujado en la dirección que molesta. Nunca llegó a estar
en el juego.

**La causa real del zigzag sigue sin identificar.** Sospechosos: `MaxTurnRadius = 5.0`
(no pueden girar cerrado hacia ti, sobrepasan y corrigen), el empuje entre bichos de las
manadas 5/7 que introdujo el mod 1 (`SpherePusher*`), y `AvoidCreaturesStrength = 0` en
el árbol `MELEE`. Ninguno probado.

### Sin verificar — revertir primero si algo falla

- **`AllowSpawnBrood` en Hardcore.** `BUGQUEEN` lo usa en vanilla con
  `SpawnBroodID = BUGFIENDS`, timer 30 y anim `BIRTHING`. Aquí se copia el ID, se baja el
  timer a 10 y se deja `SpawnBroodAnim` en `ROAR`, que es lo que el `FIEND` ya trae: no
  sabemos si el `FIEND` tiene animación `BIRTHING`. **Sigue siendo el primer cambio a
  revertir.**
- **`FiendOnscreenMarkers = false`.** Sin probar: nunca llegó a desplegarse. Sigue
  abierta la duda de si quita solo el marcador o también la detección del escáner y las
  misiones que usan `FIENDCORE` como `ValidMissionSurveyId` del huevo.

### Build — 2026-08-04 (primera, con zigzag)

- **Los cuatro tiers construidos, 0 errores.** Conteos **23 / 33 / 39 / 43**,
  exactamente los previstos, con el desglose por archivo cuadrando también:

  | Tier | gen | med | large | globals | datatable | eggs | infest | Total |
  |---|---:|---:|---:|---:|---:|---:|---:|---:|
  | 1 Fácil | 5 | 2 | 2 | 4 | — | 4 | 6 | **23** |
  | 2 Normal | 5 | 2 | 2 | 13 | 1 | 4 | 6 | **33** |
  | 3 Difícil | 5 | 2 | 2 | 16 | 4 | 4 | 6 | **39** |
  | 4 Hardcore | 5 | 2 | 2 | 17 | 7 | 4 | 6 | **43** |

- ✅ **El anclaje a `FIEND` funciona.** El delta de `CREATUREDATATABLE` de los tres
  tiers que lo tocan contiene **una sola entrada, `_id="FIEND"`**. Ni `SCUTTLER_PET`
  ni `BUGQUEEN` ni ninguno de los otros seis bloques aparece. Era la comprobación más
  importante de esta versión.
- ✅ Tipos correctos en el EXML: `MinFlurryHits` `3` y `MaxFlurryHits` `6` sin
  decimales, `MaxEcosystemCreaturesNormal` `70`, `FiendMaxAttackers` `6`,
  `FiendOnscreenMarkers` `false` y `AllowSpawnBrood` `true` en minúsculas, y
  `SpawnBroodID` como cadena `BUGFIENDS`.
- ✅ **Fácil confirmado sin cambios:** sus 6 EXML son byte a byte idénticos a los de
  0.1.0, como estaba previsto por diseño.
- Salida archivada en `build\infestacion_2026-08-04\`.

### Pendiente

- [x] ~~Confirmar el zigzag.~~ **Retirado** sin probarlo: no es la palanca.
- [x] ~~Rebuild con el zigzag fuera y el timer de brood en 10.~~ 2026-08-04,
      conteos **23 / 33 / 37 / 41**, 0 errores, `_id="FIEND"` único en el delta.
- [ ] **Desplegar 0.2.0 a `GAMEDATA\MODS` y verificar el EXML desplegado** antes de
      volver a probar. Este es el paso que faltó.
- [ ] Prueba in-game real de los 4 tiers. Empezar por Hardcore.
- [ ] **Confirmar que los Fiend se multiplican** (`AllowSpawnBrood`), **lejos de los
      huevos** para que la prueba mida algo.
- [ ] Comprobar que quitar el marcador de UI no rompe el escáner ni las misiones que
      usan `FIENDCORE` como `ValidMissionSurveyId` del huevo.
- [ ] **Identificar qué causa el zigzag real.** Empezar por `MaxTurnRadius` y por si
      `AvoidCreaturesWeight` (ya en 0.2.0) lo mejora de refilón.
- [ ] Capturas propias del mod 2 y su página de Nexus.

---

## [0.1.0] — 2026-08-02

Probado contra NMS **170671** (rama Public), MBINCompiler 6.45.0.1.
Verificado in-game a mano, tier Hardcore.

### Added

- **Mod nuevo, versionado aparte del mod 1**, empezando en 0.1.0. Contiene al mod 1
  (mismos archivos, misma calibración por tier) y añade los Horrores Biológicos.
- Cuatro configuraciones: Fácil, Normal, Difícil y Hardcore. Se instala una sola.
- **Densidad de huevos de Fiend ×2/×5/×20/×20** sobre `FIENDEGGS.MBIN` e
  `INFESTATION.MBIN`, incluido el `GROUNDWORMSPAWNER`.
- **Presión de combate:** `FiendMaxAttackers` 2/3/4/6, `FiendMaxEngaged` 6/8/10/12,
  `MaxFiendsToSpawn` 6/8/10/12 y `FiendAggroTime` 45/60/90/120.
- Fácil no escribe ningún global de Fiend: sus valores coinciden con vanilla.
- Conteo de cambios por tier: **23 / 27 / 27 / 28**, verificado.

### Fixed

- **Bug de cascada de reglas.** Las reglas de un mismo archivo se aplican en secuencia,
  así que en `INFESTATION` la regla de huevos subía `0.005 → 0.025` y la del gusano
  (`VALUE_MATCH "0.025000"`) los volvía a multiplicar: `FlatDensity` acababa en 0.125
  = **×25** en vez de ×5, y el REPORT daba 29 en vez de 27.
  - **Solo se manifestaba en Normal.** Con ×2 y ×20 no había colisión, así que tres de
    las cuatro configuraciones daban el conteo correcto con el mismo script defectuoso.
    De ahí la regla de comprobar el conteo en las cuatro.
  - Arreglado invirtiendo el orden: el gusano va primero y los huevos últimos.

### Trampas documentadas

- Cada objeto de `FIENDEGGS`/`INFESTATION` lleva **dos** bloques de densidad. El bueno
  es `QualityVariants`; debajo hay un `QualityVariantData` con `Coverage 0.2` /
  `FlatDensity 0.5` idéntico en los cinco objetos de los dos archivos. Los scripts usan
  `VALUE_MATCH` para no tocarlo.
- `Coverage` se deja intacto: rango válido desconocido.
- `FiendMaxAttackers`, `FiendMaxEngaged` y `MaxFiendsToSpawn` son enteros.

### Verificado in-game (Hardcore)

Los 13 cambios confirmados jugando: los 5 de Fiend (densidad de huevos ×20, densidad
del `WORMSPAWNER` ×20, `FiendMaxAttackers` 6, `FiendMaxEngaged`/`MaxFiendsToSpawn` 12,
`FiendAggroTime` 120) y los 8 heredados del mod 1.
