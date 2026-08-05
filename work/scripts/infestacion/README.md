# Mod 2 — Infestación (Horrores Biológicos)

Mod nuevo, versionado aparte, en **0.2.0**. No es una actualización del mod 1: es otro
mod que reutiliza su calibración.

| | Mod 1 | Mod 2 |
|---|---|---|
| Nombre | `HorribleTerror_Predators` | `HorribleTerror_Infestation` |
| Versión | 1.1.0 | 0.2.0 |
| Qué hace | dificultad de depredadores | lo del mod 1 **+** los Fiends |
| Página de Nexus | la suya | la suya |

**El mod 2 contiene al mod 1.** Escriben los mismos archivos, así que instalar los
dos hace que uno pise al otro en silencio. En Nexus hay que decirlo en la primera
línea de las dos páginas.

Changelog propio: [`../../../docs/CHANGELOG-MOD2.md`](../../../docs/CHANGELOG-MOD2.md)

---

## Las cuatro configuraciones

Se instala **una sola**.

| Parámetro | Vanilla | 1 Fácil | 2 Normal | 3 Difícil | 4 Hardcore |
|---|---|---|---|---|---|
| **Heredado del mod 1** ||||||
| Densidad terrestre | ×1 | ×2 | ×5 | ×20 | ×20 |
| Peso `DANGEROUS` | 1 | 3 | 10 | 1000 | 1000 |
| Manada min/max | 1/1 | 1/2 | 2/3 | 3/5 | 5/7 |
| Percepción depredador (m) | 40 | 45 | 50 | 60 | 80 |
| Huye al % de vida | 40 | 30 | 15 | 0 | 0 |
| % depredadores hostiles | 0.5 | 0.6 | 0.75 | 1.0 | 1.0 |
| Tope criaturas a la vez | 40 | 45 | 50 | 60 | 70 |
| Distancia de aburrimiento | 80 | 80 | 80 | 80 | 150 |
| **Fiends: cantidad (0.1.0, retocado en 0.3.1)** ||||||
| Densidad de huevos | ×1 | ×2 | ×5 | ×20 | ×20 |
| `FiendMaxAttackers` | 2 | 2 | 3 | 4 | **8** |
| `FiendMaxEngaged` | 6 | 6 | 8 | 10 | **16** |
| `MaxFiendsToSpawn` | 6 | 6 | 8 | 10 | **16** |
| `FiendAggroTime` (s) | 45 | 45 | 60 | 90 | **600** |
| **Fiends: conducta (0.2.0)** ||||||
| Marcador de UI del Fiend | sí | sí | sí | **NO** | **NO** |
| `FiendPerceptionDistance` (m) | 60 | 60 | 65 | 70 | **120** |
| Eclosión min/max (s) | 0.25/3.0 | 0.25/3.0 | 0.2/2.0 | 0.15/1.0 | 0.1/0.5 |
| `AvoidCreaturesWeight` | 6 | 6 | 8 | 10 | 10 |
| Radio activación gusano (m) | 100 | 100 | 50 | 20 | 10 |
| Golpes por racha | 2/4 | 2/4 | 2/4 | 3/5 | 3/6 |
| Cadencia del salto (s) | 2.0 | 2.0 | 1.8 | 1.5 | 1.2 |
| Velocidad de ataque | 1.0 | 1.0 | 1.0 | 1.1 | 1.2 |
| Se multiplican | no | no | no | no | **SÍ** |
| **Movimiento: sin acechar (0.3.0)** ||||||
| `PredatorNoticePauseTime` (s) | 1.5 | 1.5 | 0.8 | 0.3 | **0.0** |
| `PredatorApproachTime` (s) | 4.0 | 4.0 | 2.0 | 0.5 | **0.0** |
| `PredatorChargeDist` (m) | 7 | 7 | 12 | 25 | **40** |
| `PredatorEnergyUseChasing` | -0.1 | -0.1 | -0.05 | **0.0** | **0.0** |
| **Movimiento: derechos (0.3.0)** ||||||
| `SteeringUpdateRate` (s) | 0.25 | 0.25 | 0.20 | 0.15 | **0.10** |
| `MaxTurnRadius` (m) | 5.0 | 5.0 | 4.0 | 3.0 | **2.0** |
| **Movimiento: horda (0.3.0)** ||||||
| `FollowLeaderCohereWeight` | 0.1 | 0.1 | 0.4 | 0.8 | **1.2** |
| `FollowLeaderAlignWeight` | 1.0 | 1.0 | 1.5 | 2.5 | **3.5** |
| `SpherePusherWeight` S/M | 10 | 10 | 9 | 7 | **5** |
| `SpherePusherWeight` L | 5 | 5 | 4.5 | 4 | **3** |
| **Árbol `MELEE` (0.3.0)** ||||||
| `BehaviourMoveSpeed` | Normal | Normal | Normal | **Fast** | **Fast** |
| `DynamicMoveSlowdownDistMul` | 4.0 | 4.0 | 3.0 | 2.0 | **1.0** |
| **Sin marcador y sin soltar presa (0.3.1)** ||||||
| `ShowOnscreenPredatorMarkers` | sí | sí | sí | sí | **NO** |
| `FiendAggroDecreasePerSpawn` | 0.1 | 0.1 | 0.1 | 0.1 | **0.0** |
| `FiendAggroIncrease` Damage/DestroyEgg | 1.0 | 1.0 | 1.0 | 1.0 | **3.0** |
| `FiendBeingShotMemoryTime` (s) | 10 | 10 | 10 | 10 | **60** |
| `FiendDespawnDistance` (m) | 150 | 150 | 150 | 150 | **300** |

**0.3.1 es solo Hardcore.** Los otros tres tiers no cambian ni un campo: sus deltas
salen idénticos a los de 0.3.0 (23 / 45 / 50, verificado en la build del 05/08).

**Fácil no cambia en 0.2.0.** No coge ninguno de los ocho cambios de conducta: sus
valores coincidirían con vanilla y escribirlos ensuciaría el EXML delta sin cambiar
nada. Verificado tras la build: **sus 6 EXML son byte a byte idénticos a los de
0.1.0.** Quien tenga Fácil instalado no necesita actualizar.

**El zigzag ya no está en la tabla.** Estuvo en la primera build de 0.2.0 y se retiró
sin llegar a probarlo — ver la sesión del 2026-08-04 más abajo. Se quita la regla entera
en vez de escribir 0, porque escribir el propio valor vanilla ensucia el EXML delta sin
cambiar nada, que es el mismo criterio de Fácil.

---

## Conteo de cambios esperado por tier

Si `REPORT` no da estos números, algo no encajó y **no se despliega**.

| Tier | Total | Desglose (gen + med + large + globals + datatable + eggs + infest + árbol + **uiglobals**) |
|---|---|---|
| 1 Fácil | **23** | 5 + 2 + 2 + 4 + — + 4 + 6 + — + — |
| 2 Normal | **45** | 5 + 2 + 2 + 24 + 1 + 4 + 6 + 1 + — |
| 3 Difícil | **50** | 5 + 2 + 2 + 25 + 4 + 4 + 6 + 2 + — |
| 4 Hardcore | **60** | 5 + 2 + 2 + 31 + 7 + 4 + 6 + 2 + **1** |

Hardcore lleva seis globals más que Difícil: `PlayerPredatorBoredomDistance` (único tier
que lo toca) y los cinco de tenacidad de 0.3.1. Y tres cambios más de `datatable` por el
brood. El de `uiglobals` es el marcador de depredador, también solo Hardcore. Normal lleva
una regla menos del árbol: no escribe `BehaviourMoveSpeed`, que ya es `Normal`.

**Construidos y verificados el 2026-08-04** contra NMS 170671 / MBINCompiler 6.45.0.1:
los cuatro dan **23 / 45 / 50 / 54** con **0 errores**, y los deltas se comprobaron
propiedad por propiedad.

**Desplegado el 2026-08-04:** `HorribleTerror_Infestation_4-Hardcore`, con los 54 cambios
confirmados leyendo el EXML de `GAMEDATA\MODS`. Desglose de cada campo en
[`../../../docs/MODIFICACIONES.md`](../../../docs/MODIFICACIONES.md).

### Histórico

| Versión | Fácil | Normal | Difícil | Hardcore |
|---|---:|---:|---:|---:|
| 0.1.0 | 23 | 27 | 27 | 28 |
| 0.2.0 (1ª build, con zigzag) | 23 | 33 | 39 | 43 |
| 0.2.0 (final) | 23 | 33 | 37 | 41 |
| 0.3.0 | 23 | 45 | 50 | 54 |
| **0.3.1** | **23** | **45** | **50** | **60** |

---

## Rutas que toca — 9

```
METADATA\SIMULATION\ECOSYSTEM\CREATUREGENERATIONDATA.MBIN
METADATA\SIMULATION\ECOSYSTEM\GROUND\GROUNDTABLEPLAYERPREDATORMED.MBIN
METADATA\SIMULATION\ECOSYSTEM\GROUND\GROUNDTABLEPLAYERPREDATORLARGE.MBIN
METADATA\SIMULATION\ECOSYSTEM\CREATUREDATATABLE.MBIN          <-- nuevo en 0.2.0
METADATA\SIMULATION\ECOSYSTEM\CREATUREBEHAVIOURTREES.MBIN     <-- nuevo en 0.3.0
GLOBALS\GCCREATUREGLOBALS.MBIN
GLOBALS\GCUIGLOBALS.GLOBAL.MBIN                               <-- nuevo en 0.3.1
METADATA\SIMULATION\SOLARSYSTEM\BIOMES\OBJECTS\RARE\FIENDEGGS.MBIN
METADATA\SIMULATION\SOLARSYSTEM\BIOMES\OBJECTS\RARE\INFESTATION.MBIN
```

Fácil solo toca 6: no necesita `CREATUREDATATABLE`, `CREATUREBEHAVIOURTREES` ni
`GCUIGLOBALS`. La novena ruta es **solo de Hardcore**.

Escaneo del **2026-08-03**: las 8 primeras rutas están **libres** de mods de terceros
(`CREATUREBEHAVIOURTREES` entró en esa misma pasada). La única disputada es
`GCCREATUREGLOBALS`, y solo contra nuestro propio mod 1.

### ⚠️ `GCUIGLOBALS` sí está disputada — escaneo del 2026-08-05

De los 87 mods instalados hay **uno** que la toca: `Small Cursor 6.6`, y con un EXML de
cuatro líneas:

```xml
<Data template="GcUIGlobals">
  <Property name="FrontendCursorSize" value="14" />
  <Property name="FrontendCursorWidth" value="7" />
</Data>
```

No hay solape de campos con `ShowOnscreenPredatorMarkers`, pero **sí de archivo**, y es la
primera vez que enviamos un MBIN completo sobre un archivo que otro mod parchea por EXML.
Según `README-How MBIN and EXML coexist.txt` de AMUMSS los dos conviven: nuestro MBIN
reemplaza el archivo y su EXML parchea líneas encima, así que el cursor pequeño debería
seguir funcionando. **Es lo que hay que mirar de refilón al probar** — si el cursor del
menú vuelve al tamaño normal, la regla de convivencia no es como la leímos y habría que
enviar el nuestro también como EXML.

---

## ⚠️ La trampa del árbol de comportamiento (nueva en 0.3.0)

`CREATUREBEHAVIOURTREES` tiene 8 árboles y **tres comparten los campos que tocamos**:

| Campo | Está en | Vanilla |
|---|---|---|
| `DynamicMoveSlowdownDistMul` | `MELEE`, `RANGED_SPIT`, `RANGED_FIRE` | 4.0 |
| `BehaviourMoveSpeed` | `MELEE`, `RANGED_SPIT` · `RANGED_FIRE` ya usa `Fast` | `Normal` |
| `AvoidCreaturesStrength` | `MELEE`, `RANGED_SPIT`, `RANGED_FIRE` (0.0) · `FLYING`, `CRASHY` (1.0) | 0.0 |

Y `0.000000` aparece por todo el archivo. Por eso las reglas van ancladas:

```lua
["SPECIAL_KEY_WORDS"] = {"Id", "MELEE"},
["REPLACE_TYPE"]      = "ONCE",
```

`MELEE` es además el **primer** árbol del archivo, así que `ONCE` refuerza el ancla.

**Verificado tras la build:** el delta contiene un solo `_id="MELEE"` y un solo nodo
`GcBehaviourMoveToTargetData` con los dos campos. `RANGED_SPIT` y `RANGED_FIRE` intactos.

**`AvoidCreaturesStrength` se deja en 0.0 a propósito.** `COMPORTAMIENTO.md` §7 lo
proponía subir a 0.5 para separar la manada durante la carga; va justo en contra de que el
movimiento sea **en horda**, que es el objetivo de 0.3.0.

---

## ⚠️ La trampa de los diez bloques de ataque (nueva en 0.2.0)

Lo más fácil de romper de esta versión.

`CREATUREDATATABLE` no tiene **un** bloque `GcCreatureFiendAttackData`, tiene **diez**:

| Dueño | Nota |
|---|---|
| `FIEND` | el que queremos |
| `BUGFIEND` | |
| `BUGQUEEN` | jefe, calibrado aparte |
| `SCUTTLER` | |
| **`SCUTTLER_PET`** | ⚠️ **la mascota del jugador** |
| `SLUG` | |
| `MINIFIEND` | |
| `MINIDRONE` | |
| `JELLYBOSS_BROOD`, `LAND_SQUID` | `GcCreatureSpookFiendAttackData`, otra estructura |

Un `REPLACE_TYPE = "ALL"` sobre `MinFlurryHits` los tocaría los diez — incluida la
mascota domesticada del jugador. Por eso **cada regla del archivo va anclada**:

```lua
["SPECIAL_KEY_WORDS"] = {"Id", "FIEND"},
["REPLACE_TYPE"]      = "ONCE",
```

Es el mismo patrón que ya se usaba para el peso de `DANGEROUS`.

**Verificado tras la build:** el delta de `CREATUREDATATABLE` de los tres tiers que lo
tocan contiene una sola entrada, `_id="FIEND"`. Ni `SCUTTLER_PET` ni `BUGQUEEN`
aparecen.

---

## La trampa de los dos bloques de densidad

Cada objeto de `FIENDEGGS` / `INFESTATION` lleva **dos** bloques de densidad:

- `QualityVariants` → los valores reales, distintos por objeto.
- `QualityVariantData` → `Coverage 0.2` / `FlatDensity 0.5`, **idéntico en los cinco
  objetos de los dos archivos**. Tiene pinta de struct por defecto, no de dato real.

Multiplicar `FlatDensity` a secas tocaría los dos. Por eso los scripts usan
`VALUE_MATCH`: solo se multiplican las ocurrencias cuyo valor actual es el de vanilla
del bloque bueno.

`Coverage` **no se toca**. Los valores reales son 0.1, 1.0 y 2.0, y no sabemos el
rango válido del campo — ×20 sobre 2.0 podría salirse.

---

## La trampa de orden (0.1.0, sigue vigente)

Las reglas de un mismo archivo se aplican **en secuencia** sobre el MXML, así que un
valor ya escrito puede encajar en el `VALUE_MATCH` de una regla posterior.

En Normal (`EGG_MULT = 5`) pasó exactamente eso: la regla de huevos subía
`0.005 → 0.025`, y la del gusano (`VALUE_MATCH 0.025`) los volvía a multiplicar.
`FlatDensity` acabó en **0.125 = ×25** en vez de ×5, y el `REPORT` dio **29** en vez
de 27. Fácil (×2) y Difícil/Hardcore (×20) no colisionaban: **el bug solo aparecía en
Normal**, y solo un conteo por tier lo delató.

**El arreglo:** en `INFESTATION` el gusano va **primero** y los huevos **últimos**.

---

## Tipos: enteros, floats y booleanos

| Enteros (sin decimales) | Booleanos (minúsculas) |
|---|---|
| `FiendMaxAttackers`, `FiendMaxEngaged`, `MaxFiendsToSpawn`, `MaxEcosystemCreaturesNormal`, `MinFlurryHits`, `MaxFlurryHits` | `FiendOnscreenMarkers`, `AllowSpawnBrood` |

Todo lo demás es float con 6 decimales. `SpawnBroodID` es una cadena (`BUGFIENDS`).

---

## Sesión del 2026-08-04 — la prueba midió 0.1.0, no 0.2.0

⚠️ **0.2.0 se construyó el 04/08 y nunca se copió a `GAMEDATA\MODS`.** La prueba in-game
de esa tarde se jugó contra **0.1.0**. Comprobado leyendo el EXML desplegado:

```
GAMEDATA\MODS\HorribleTerror_Infestation_4-Hardcore\
  GLOBALS\GCCREATUREGLOBALS.EXML     <- 9 cambios: los de 0.1.0
  (falta CREATUREDATATABLE.EXML)     <- el archivo nuevo de 0.2.0
```

Los 9 son `MaxEcosystemCreaturesNormal`, `PredatorPerceptionDistance`,
`PercentagePlayerPredators`, `PlayerPredatorBoredomDistance`,
`PredatorRunAwayHealthPercent`, `FiendAggroTime`, `FiendMaxEngaged`,
`FiendMaxAttackers` y `MaxFiendsToSpawn`. **Ni `FiendOnscreenMarkers`, ni `FiendZigZag*`,
ni ninguno de los ocho cambios de conducta.**

> **Regla nueva: construir no es desplegar.** Antes de cualquier prueba in-game, leer el
> EXML de `GAMEDATA\MODS` y confirmar que contiene los campos de la versión que se cree
> estar probando. Un `REPORT` con el conteo correcto dice que la build salió; **no** dice
> que esté en el juego.

### Qué queda en pie de esa prueba

| Observación | Veredicto |
|---|---|
| Los Fiend se acercan zigzagueando | **Válida** — y con `FiendZigZagSpeed = 0`. Ver abajo |
| No se multiplicaban | **Nula.** `CREATUREDATATABLE` no estaba en el juego |
| El marcador de UI | **Nula.** `FiendOnscreenMarkers` no estaba desplegado |

### ❌ Zigzag — retirado sin llegar a probarlo

El dato útil es justo el contrario del esperado: **los Fiend zigzaguean con el campo a
0.** Luego `FiendZigZagSpeed`/`Strength` **no es la palanca** que causa lo que se ve en
pantalla, y subirlo a 1.0/1.5 solo habría empujado en la dirección que molesta — el
objetivo es que vengan **derechos**.

Retirado de los dos tiers que lo tenían. **Nunca llegó a estar en el juego.**

### La causa real del zigzag — sin identificar

Sospechosos, por orden de probabilidad:

| Candidato | Vanilla | Por qué encaja |
|---|---:|---|
| `MaxTurnRadius` | 5.0 | Con 5 m de radio de giro no pueden virar cerrado hacia ti: sobrepasan y corrigen, que se ve como zigzag |
| `SpherePusher*` + manadas 5/7 | — | Las manadas que introdujo el mod 1 se empujan entre sí y se salen de su línea. **Esto lo causa nuestro propio mod** |
| `AvoidCreaturesStrength` en `MELEE` | 0.0 | Ver la sección §5 de `COMPORTAMIENTO.md` |

Ninguno probado. `AvoidCreaturesWeight` 6 → 8/10 ya está en 0.2.0 y ataca el segundo
candidato de refilón: la primera prueba real de 0.2.0 ya dirá algo.

### ⚠️ Que se multipliquen — sigue sin probar

`SpawnBroodTimer` baja de 30 a **10** para que llegue a saltar dentro de un combate y se
pueda ver. `SpawnBroodAnim` se queda en `ROAR` — un cambio por intento.

La prueba estará **confundida por el propio mod** si se hace en cualquier sitio: con
`FiendMaxEngaged = 12` y los huevos ×20, una cría de brood es indistinguible de un Fiend
salido de un huevo. **Hace falta un sitio con Fiends pero sin huevos cerca.**

Orden si falla: `BIRTHING` → y si tampoco, revertir el brood entero.

---

## Valores sin referencia vanilla — `[Sin probar]`

- **`AllowSpawnBrood` en Hardcore.** `BUGQUEEN` lo usa en vanilla con
  `SpawnBroodID = BUGFIENDS`, timer 30 y anim `BIRTHING`. Aquí se copia el ID y se baja
  el timer a 10, pero se deja `SpawnBroodAnim` en `ROAR`, que es lo que el `FIEND` ya
  trae: no sabemos si el `FIEND` tiene animación `BIRTHING`.
  **Sigue siendo el primer cambio a revertir si algo falla.**
- **`FiendOnscreenMarkers = false`.** Sin probar: nunca llegó a desplegarse. La duda
  original sigue abierta — ¿quita solo el marcador, o también la detección del escáner y
  las misiones que usan `FIENDCORE` como `ValidMissionSurveyId` del huevo?

---

## Valores vanilla verificados

NMS 170671, MBINCompiler 6.45.0.1.

**`FIENDEGGS.MBIN`** — 2 objetos, los dos `FIENDEGG.SCENE`:

| Objeto | Placement | FlatDensity | SlopeDensity | Coverage |
|---|---|---|---|---|
| `Objects[0]` | `FLORACLUMP` | 0.005 | 0.005 | 0.1 |
| `DetailObjects[0]` | `RAREX` | 0.005 | 0.005 | 2.0 |

**`INFESTATION.MBIN`** — 3 objetos:

| Objeto | Modelo | Placement | FlatDensity | SlopeDensity | Coverage |
|---|---|---|---|---|---|
| `WORMSPAWNER` | `GROUNDWORMSPAWNER` | `WORDSTONE` | 0.025 | 0.030 | 1.0 |
| `FIENDEGGS` | `FIENDEGG` | `FLORACLUMP` | 0.005 | 0.005 | 0.1 |
| (sin nombre) | `FIENDEGG` | `RAREX` | 0.005 | 0.005 | 2.0 |

**`CREATUREDATATABLE.MBIN`, entrada `FIEND`:**

| Campo | Vanilla |
|---|---:|
| `MinFlurryHits` / `MaxFlurryHits` | 2 / 4 |
| `DelayBetweenPounceAttacks` | 2.0 |
| `AnimSpeedModifier` | 1.0 |
| `AllowSpawnBrood` | `false` |
| `SpawnBroodID` / `SpawnBroodTimer` | *(vacío)* / 0.0 |

---

## Cómo construir

```
tools\Build-Tiers.ps1 -Carpeta infestacion
```

Construye los 4 de una pasada, uno a la vez, y archiva cada salida en
`build\infestacion_<fecha>\` con su log y su `REPORT`. Comprobar los totales contra la
tabla de arriba **en las cuatro configuraciones**: el bug de cascada de 0.1.0 solo
aparecía en una.

Para cambiar de configuración en el juego: borrar la carpeta del tier actual de
`GAMEDATA\MODS\` y copiar la nueva. NMS solo carga mods **al arrancar**.

---

## Aplazado

- **`GcAntagonistComponentData` en el huevo salvaje** — para que los Fiend salgan sin
  romper el huevo, a ~5 m. Hay molde vanilla (el huevo construible, percepción
  `HIVE_MIND` de `Range 6.0`), pero exige **añadir un componente** a un `.ENTITY.MBIN`,
  no cambiar un valor. Sesión propia. Ver [`COMPORTAMIENTO.md`](../../../docs/COMPORTAMIENTO.md) §8.
- **`BehaviourMoveSpeed` `Normal` → `Fast`** en el árbol `MELEE`, y
  **`AvoidCreaturesStrength` 0.0 → 0.5** en su nodo `MOVE_CLOSE`. Los dos en
  `CREATUREBEHAVIOURTREES`: sería la primera vez que editamos estructura anidada.
- **`MaxFiendsToSpawnCarnage = 10`** — hay un modo "carnage" y no sabemos qué lo
  dispara.
