# Ideas y mapa de spawn — Horrible Terror

Documento de trabajo. Todo lo de aquí está **verificado contra la instalación local**
(NMS 170671, MBINCompiler 6.45.0.1) salvo donde diga `[Inferencia]` o `[Sin probar]`.

Sirve para dos cosas: decidir qué tocar a continuación, y no volver a investigar lo
mismo dentro de un mes.

---

## 0. Estado actual del mod

| Cambio | Dónde | Estado |
|---|---|---|
| Densidad terrestre x20 | `CREATUREGENERATIONDATA` → `GroundGroupsPerKm` | ✅ probado in-game |
| `DANGEROUS` peso 1→1000 | `CREATUREGENERATIONDATA` → `Generic/Ground` | ✅ probado in-game |
| Paletas de piel en rojo | 47 × `*COLOURPALETTES` | ✅ probado, archivado |

Los dos primeros viven ahora en un solo script, `HorribleTerror_Ecosystem.lua`.

**Regla dura aprendida:** dos mods nuestros nunca pueden escribir el mismo archivo.
Escribieron los dos `CREATUREGENERATIONDATA.EXML` y el resultado fue planetas sin
fauna. Todo lo que toque ese archivo va en el script unificado.

---

## 1. LO MÁS IMPORTANTE: hay DOS caminos de spawn, no uno

Hasta ahora solo hemos usado el primero. El segundo es el que abre casi todo lo que
pediste.

### Camino A — Ecosistema procedural (arquetipos)

```
CREATUREGENERATIONDATA
   Generic -> Ground        lista ponderada de arquetipos
        v
CREATUREGENERATIONARCHETYPES
   DANGEROUS -> lista de tablas de spawn
        v
ECOSYSTEM/GROUND/GROUNDTABLE*.MBIN
   roles, tamaños, tamaño de grupo, densidad
        v
   criatura procedural generada por semilla del planeta
```

- **Alcance:** planeta entero, uniforme.
- **Criaturas:** procedurales, distintas en cada planeta.
- **Control de sitio:** ninguno. No puedes decir "aquí sí, allí no".
- **Es lo que ya tocamos.**

### Camino B — Objetos de bioma (colocación directa) ← SIN EXPLORAR

```
BIOMES/<X>/<X>OBJECTS*.MBIN   (y BIOMES/OBJECTS/RARE/*.MBIN)
   cGcExternalObjectList
        v
   GcEnvironmentSpawnData
        +-- Objects        <- rocas, plantas, props
        +-- Creatures      <- CRIATURAS. Aquí está la clave.
        +-- Landmarks
        +-- DistantObjects
```

`GcEnvironmentSpawnData.Creatures` es una lista de `GcCreatureSpawnData`: criaturas
colocadas **junto a la colocación de objetos**, no por el ecosistema.

**Ejemplo real y funcional:** `biomes/rocky/rockobjectsfull.MBIN` coloca pájaros así:

```xml
<Property name="Creatures">
  <Property name="Creatures" value="GcCreatureSpawnData" _index="0">
    <Property name="Filename" value="MODELS/PLANETS/CREATURES/SMALLBIRD/BIRD.SCENE.MBIN" />
    <Property name="CreatureID" value="BIRD" />
    <Property name="CreatureRole" value="Bird" />
    <Property name="CreatureMinGroupSize" value="1" />
    <Property name="CreatureMaxGroupSize" value="10" />
    <Property name="CreatureGroupsPerSquareKm" value="50.000000" />
    <Property name="CreatureSpawnDistance" value="25.000000" />
    <Property name="CreatureDespawnDistance" value="30.000000" />
    <Property name="CreatureActiveInDayChance" value="1.000000" />
    <Property name="CreatureActiveInNightChance" value="1.000000" />
    <Property name="HemiSphere" value="Any" />
    ...
```

**Por qué importa esto para el mod:**

- Permite **criatura concreta**, no procedural. Un bicho fijo, siempre igual.
- Permite **convivir** con el ecosistema: los depredadores del camino A siguen
  saliendo, y encima añades los tuyos.
- Es el camino para "más de una clase por planeta" — que es exactamente lo que
  preguntaste. Los arquetipos te dan UNA lista por planeta; los objetos de bioma se
  suman por encima.
- Es la vía más cercana a "manadas que se acercan a los edificios" (§4).

**Lo que NO sabemos todavía** `[Sin probar]`: si `Creatures` respeta `LifeChance` del
planeta o ignora el ecosistema por completo. Solo un pájaro vanilla lo usa, así que
hay poco precedente del que copiar. Merece una prueba dedicada.

---

## 2. Los monstruos de los edificios: se llaman FIEND

Identificados. En el juego son los "Horrores Biológicos"; en los archivos, **FIEND**.

### Assets

| Qué | Ruta |
|---|---|
| **Rig** | `MODELS/PLANETS/CREATURES/SPIDERRIG/` — reusa el rig de araña |
| Animaciones | `SPIDERRIG/ANIM/FIENDATTACK{,2,3}`, `FIENDBURY`, `FIENDDEATH01`, `FIENDEAT`, `FIENDFASTWALK` |
| **Huevo** | `MODELS/PLANETS/BIOMES/COMMON/RARERESOURCE/GROUND/FIENDEGG.SCENE.MBIN` |
| Anims del huevo | `FIENDEGG_HATCH`, `FIENDEGG_IDLE`, `FIENDEGG_NEARIDLE` |
| Proyectil | `MODELS/COMMON/PROJECTILES/FIENDSPITBALL.SCENE.MBIN` |
| Efectos | `FIENDBLOODSPLAT`, `FIENDDEATH`, `FIENDEXPLODE`, `FIENDDEBRIS` |
| Variantes | `ARTHROPOD/BUGFIEND`, `FISH/FISHFIEND`, `FISH/FISHFIENDSMALL` |

### Spawn — NO usa el ecosistema

Esto es lo importante y es contraintuitivo:

```
METADATA/SIMULATION/SOLARSYSTEM/BIOMES/OBJECTS/RARE/FIENDEGGS.MBIN
METADATA/SIMULATION/SOLARSYSTEM/BIOMES/OBJECTS/RARE/INFESTATION.MBIN
```

Son listas de **objetos de bioma** (camino B), no tablas de fauna. El huevo se coloca
como si fuera una planta y el bicho sale de ahí.

`GROUNDTABLEFIEND.MBIN` existe pero está en `ECOSYSTEM/DEPRECATE/` — vía muerta, no
perder tiempo ahí.

**`INFESTATION.MBIN`** es oro puro para este mod. Coloca:
- `FIENDEGG.SCENE.MBIN` ×2 (dos entradas con densidades distintas)
- `SANDWORMMINI/GROUNDWORMSPAWNER.SCENE.MBIN`

Densidades vanilla en `FIENDEGGS.MBIN`: `Coverage 0.1`, `FlatDensity 0.005`,
`Placement FLORACLUMP`, `MaxScale 1.7`. Son valores **muy bajos** — por eso los
huevos son raros.

#### Inventario completo — verificado 2026-07-30 (NMS 170671, MBINCompiler 6.45.0.1)

Extraídos de `NMSARC.Precache.pak`. Los dos archivos son `cGcExternalObjectList`.

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

#### ⚠️ Trampa: cada objeto lleva DOS bloques de densidad

El bueno es `QualityVariants` — valores reales, distintos por objeto. Debajo hay otro
llamado **`QualityVariantData`** con `Coverage 0.2` / `FlatDensity 0.5`, **idéntico en
los cinco objetos de los dos archivos**. Tiene pinta de struct inicializado por
defecto, no de dato real.

Multiplicar `FlatDensity` a secas toca los dos. La vía correcta es `VALUE_MATCH`, que
acota el cambio a las ocurrencias cuyo valor actual es el de vanilla del bloque bueno.

`Coverage` conviene **no tocarlo**: los valores reales son 0.1, 1.0 y 2.0 y no se
conoce el rango válido del campo — ×20 sobre 2.0 podría salirse.
`FlatDensity`/`SlopeDensity` son la palanca de densidad de verdad.

### Comportamiento — `GcCreatureFiendAttackData`, 39 campos

Los más jugosos:

| Campo | Vanilla | Para qué sirve |
|---|---|---|
| `NearDist` / `FarDist` | 6 / 10 | distancias de decisión de ataque |
| `AllowPounce` | `true` | salto sobre el jugador |
| `DelayBetweenPounceAttacks` | 2.0 | cadencia del salto |
| `AllowSpit` | `true` | escupitajo a distancia |
| `AOESpitAttack` | `false` | escupitajo en área |
| `AllowSpitAlways` | `false` | escupir sin condiciones |
| `DelayBetweenSpitAttacks` | 1.0 | cadencia |
| **`AllowSpawnBrood`** | **`false`** | **el bicho engendra crías** |
| `SpawnBroodID` / `SpawnBroodTimer` | vacío / 0 | qué engendra y cada cuánto |
| `AllowPushBackAttack` | `false` | empujón |
| `PushBackRange` | 5.0 | alcance |
| `MinFlurryHits` / `MaxFlurryHits` | 2 / 4 | golpes por ráfaga |

`AllowSpawnBrood = false` es la línea más interesante del archivo entero. Está
implementado y apagado. Encenderlo daría bichos que se multiplican mientras luchas.
`[Sin probar]` — hay que averiguar qué acepta `SpawnBroodID`.

Existe además `GcCreatureSpookFiendAttackData`, una variante aparte. Sin explorar.

**Ubicación confirmada 2026-07-30:** `GcCreatureFiendAttackData` vive en
`METADATA/SIMULATION/ECOSYSTEM/CREATUREDATATABLE.MBIN`, con **8 bloques** repartidos
entre las entradas `FIEND`, `BUGFIEND`, `MINIFIEND`, `FIENDFISHSMALL` y
`FIENDFISHBIG`, más 2 de `GcCreatureSpookFiendAttackData`. Un `REPLACE_TYPE = "ALL"`
sobre `MinFlurryHits` los tocaría los diez, peces incluidos.

La ruta está **libre** en los 87 mods instalados.

---

## 3. Manadas: qué se puede configurar

No hay "un" sistema de manada. Hay **cuatro**, en capas distintas.

### 3.1 Tamaño de grupo — en las tablas de spawn

`ECOSYSTEM/GROUND/GROUNDTABLE*.MBIN`, dentro de `GcCreatureRoleDescription`:

| Campo | En `PLAYERPREDATORMED` | Qué hace |
|---|---|---|
| `MinGroupSize` / `MaxGroupSize` | **1 / 1** | ← depredadores van SOLOS |
| `Density` | `Normal` | multiplicador dentro de la tabla |
| `MinSize` / `MaxSize` | `Medium` / `Medium` | clase de tamaño |
| `ActiveTime` | `AnyTime` | día / noche / siempre |
| `ProbabilityOfBeingEnabled` | 1.0 | probabilidad de que la entrada exista |
| `IncreasedSpawnDistance` | 1.0 | a qué distancia aparece |
| `CreatureRole` | `PlayerPredator` | rol de comportamiento |
| `LifeLevel` | `Full` | nivel de vida mínimo del planeta |

**`MinGroupSize = MaxGroupSize = 1` es el hallazgo accionable más directo.** Los
depredadores que cazan al jugador salen de uno en uno por diseño. Subir esto a 3-5
convierte cada encuentro en una jauría. Un cambio, efecto enorme.

### 3.2 Freno global de manada

`CREATUREGENERATIONDATA` → `HerdCreaturePenalty = 0.5`. Las criaturas de manada
cuentan doble contra el presupuesto de densidad. Subirlo a 1.0 permite manadas más
grandes sin tocar nada más.

### 3.3 Movimiento en grupo — `CREATUREDATATABLE`

Dos estructuras según el tipo de bicho:

**`GcCreatureFlockMovementData`** (24 campos) — bandadas, aves:

```
MinFlockMembers 7      MaxFlockMembers 12
FlockCohere 3.0        FlockSeperate 7.0      FlockAlign 0.1
FlockSeperateMinDist 2.0    FlockSeperateMaxDist 6.0
FlockAvoidPredators 10.0    MinDist 20.0   MaxDist 40.0
FlockAvoidPredatorsSpeedBoost 0.3
FlockMoveSpeed 0.7     FlockTurnAngle 7.0     FlockHysteresis 0.5
```

**`GcCreatureSwarmData`** (57 campos) — enjambres:

```
MinCount 3   MaxCount 7
SwarmMovementSpeed 1.0   SwarmMovementRadius 40.0   SwarmMovementType Random
Coherence 0.5   Alignment 0.1   SeparateStrength 0.5   Spacing 2.0
Follow 1.0      AlignTime 0.5   AttractedToBait false
```

`AttractedToBait` engancha con el sistema de cebo del jugador. Sin explorar.

Además hay un booleano suelto `Herd` (vanilla `false` en las entradas vistas).

### 3.4 Comportamiento — `CREATUREBEHAVIOURTREES`

**8 árboles:** `MELEE`, `RANGED_SPIT`, `RANGED_FIRE`, `IDLE`, `HERBIVORE`, `FLYING`,
`CRASHY`, `COOLDOWN`.

Son árboles de comportamiento completos, con nodos anidados. El de `MELEE`:

```
CheckDeath -> Appear(GRNDAPPEAR) -> MELEE
   RegisterAttacker(TARGET)
   MOVE_CLOSE: GetTarget -> MoveToTarget
        ArriveDist 1.0   BehaviourMoveSpeed Normal
        DynamicMoveSlowdownDistMul 4.0   SpeedModifier 1.0
        AvoidCreaturesStrength 0.0
   ATTACK: FaceTarget(ArriveAngle 5.0) -> HIT -> ...
```

Editable, pero es la capa más frágil y la más costosa. **No empezar por aquí.**
`AvoidCreaturesStrength = 0` es curioso: los atacantes no se esquivan entre sí, lo
que significa que una jauría se amontonaría. Relevante si subimos el tamaño de grupo.

---

## 4. Tus preguntas, con opciones

### "¿Podemos poner más de una clase por planeta, no solo depredadores?"

**Sí, y hay tres formas.** De menos a más trabajo:

**Opción 1 — Añadir tablas al arquetipo `DANGEROUS`.** Es la más barata. El
arquetipo ya tiene `AdditionalTables` con `MaxTablesToAdd = 1`. Subir ese número y
añadir tablas mete más variedad en el mismo planeta.
*Coste: bajo. Riesgo: bajo. Efecto: variedad, pero sigue siendo procedural.*

**Opción 2 — Crear un arquetipo propio.** En vez de reutilizar `DANGEROUS`, añadir
`HT_INFESTED` con la mezcla exacta que quieras y darle el peso. Más limpio de cara a
Nexus: no pisas un arquetipo vanilla, añades el tuyo.
*Coste: medio. Riesgo: medio (hay que añadir sección entera, no solo cambiar valores).
Efecto: control total del reparto.* ← **mi recomendación**

**Opción 3 — Camino B, criaturas por objeto de bioma.** Criaturas fijas encima del
ecosistema. Es la única que da criaturas *idénticas* en todos los planetas.
*Coste: alto. Riesgo: alto ([Sin probar]). Efecto: el más potente.*

### "¿Que las manadas se acerquen a los edificios?"

Honestamente: **no hay una palanca directa para "ir hacia los edificios".** El árbol
de comportamiento persigue `TARGET`, y `TARGET` es el jugador o una presa, no una
estructura. Hacer que la fauna patrulle POIs querría nodos de comportamiento nuevos,
que es territorio de Ruta C (bloqueado).

Lo que **sí** se puede hacer, y da la misma sensación:

**Opción A — Densidad ligada al objeto.** Camino B: las criaturas de
`GcEnvironmentSpawnData` se colocan con la misma pasada que los objetos de esa lista.
Si metes criaturas en la lista de objetos que acompaña a un tipo de edificio, salen
*cerca* de él. No es que "vayan" — es que nacen ahí.
*Es la aproximación realista, y visualmente indistinguible del resultado que quieres.*

**Opción B — Vía huevos.** Subir la densidad de `FIENDEGGS` / `INFESTATION` y hacer
que aparezcan en más biomas. Los huevos ya generan Fiends al acercarte. Es un
spawner por proximidad **que ya funciona en vanilla**, gratis.
*Coste: bajísimo — son dos números, `Coverage` y `FlatDensity`.* ← **empezar por aquí**

**Opción C — Aceptar que no y compensar.** Densidad global alta + depredadores.
Ya lo tienes. Si hay bichos por todas partes, también los hay junto a los edificios.

### "¿Spawn por bioma o por building?"

- **Por bioma: sí, y de dos maneras.** `BiomeSpecific → <bioma> → Ground` en
  `CREATUREGENERATIONDATA` (hoy vacío para los biomas normales — se puede rellenar), y
  las listas `<X>OBJECTS*.MBIN` de cada bioma.
- **Por edificio: no directamente** `[Inferencia]`. Los edificios se colocan por otro
  sistema. Lo más cercano es la Opción A de arriba: ligar criaturas a la lista de
  objetos del bioma donde aparece ese edificio.

---

## 4-bis. `GCCREATUREGLOBALS.MBIN` — la mina de los sensores

`GLOBALS\GCCREATUREGLOBALS.MBIN`. No lo habíamos mirado y es donde vive casi todo lo
de percepción, agro y combate. **Archivo distinto de todo lo demás → sin riesgo de
colisión.**

### Sensores hacia el jugador

| Parámetro | Vanilla | Qué hace |
|---|---:|---|
| **`PredatorPerceptionDistance`** | **40** | radio al que el depredador te detecta |
| `PredatorFishPerceptionDistance` | 60 | igual, bajo el agua |
| `PredatorStealthDist` | 11 | dentro de esto te ve aunque vayas agachado `[Inferencia]` |
| `PredatorNoticePauseTime` | 1.5 | pausa dramática antes de lanzarse |
| `CreatureSightRange` | 100 | vista genérica |
| `CreatureHearingRange` | 10 | oído genérico |
| `AlertDistance` | 50 | radio de contagio de alerta entre bichos |
| `AlertTable` | — | `HearingRange`/`SightRange`/`SightAngle`/`FleeRange` por par de tipos |

`SightAngle = 60` en las entradas de `AlertTable`: cono de visión, no 360°. Se les
puede escapar por detrás.

### Persistencia de la persecución

| Parámetro | Vanilla | Qué hace |
|---|---:|---|
| `PlayerPredatorBoredomDistance` | 80 | te alejas 80 m y se aburre |
| `PlayerPredatorRegainInterestTime` | 30 | segundos hasta que vuelve a interesarse |
| `PredatorApproachTime` | 4 | tiempo acechando antes de cargar |
| `PredatorChargeDist` | 7 | distancia a la que arranca la carga |

Subir `PerceptionDistance` y `BoredomDistance` a la vez = depredadores que te
detectan de lejos y **no te sueltan**. Probablemente el cambio más "de terror" de
toda la lista, y son dos números.

### Combate y huida

| Parámetro | Vanilla |
|---|---:|
| `PredatorRunAwayHealthPercent` | 40 — huyen al 40% de vida |
| `PredatorRunAwayDist` | 5 |
| `PlayerPredatorHealthModifier` | 1.3 |
| `PredatorSpeedMultiplier` | 1.1 |
| Velocidades Walk/Trot/Run | 1 / 3 / 6 |
| Vida Small/Med/Large/Huge | 400 / 1400 / 3000 / 3500 |
| `PredatorRoarProbAfterHit` / `AfterMiss` | 0.6 / 0.7 |

**`PredatorRunAwayHealthPercent = 40` a 0** = depredadores que pelean hasta morir.
Nada de zombie huye herido.

### Topes duros — leer antes de subir números

| Parámetro | Vanilla | Implicación |
|---|---:|---|
| **`MaxEcosystemCreaturesNormal`** | **40** | tope de criaturas cargadas a la vez |
| `MaxEcosystemCreaturesLow` | 20 | idem en calidad baja |
| `PercentagePlayerPredators` | 0.5 | mitad de los depredadores son PlayerPredator |
| `MaxBirdsProportion` | 0.15 | |
| `FriendlyCreatureLimit` | 4 | |

**El tope de 40 explica por qué el x20 no revienta el juego.** También significa que
subir densidad más allá de cierto punto no hace nada: ya estás tocando techo. Si
quieres más amenaza, `PercentagePlayerPredators` rinde más que la densidad.

### Fiends — parámetros propios

| Parámetro | Vanilla |
|---|---:|
| `FiendsCanAttack` | `true` |
| `FiendAggroTime` | 45 |
| `FiendMaxAttackers` | 2 — solo 2 te atacan a la vez |
| `FiendMaxEngaged` | 6 |
| `MaxFiendsToSpawn` | 6 |
| `MaxFiendsToSpawnCarnage` | 10 ← existe un modo "carnage" |
| `FiendAggroIncreaseDamageEgg` / `DestroyEgg` | 1.0 / 1.0 |
| `GroundWormSpawnMax` | 3 |

`MaxFiendsToSpawnCarnage = 10` sugiere un estado de "matanza" ya implementado.
`[Sin probar]` — averiguar qué lo dispara.

### ⚠️ `SpawnsAvoidBaseMultiplier = 3`

**Las criaturas evitan activamente las bases del jugador.** Multiplicador 3 sobre el
radio de exclusión. Es exactamente el obstáculo para lo que pediste de asentamientos:
bajarlo a 1 (o a 0) es lo que permitiría que la fauna se acerque a tu base.

---

## 4-ter. POIs, edificios y asentamientos — qué se puede hacer

Pediste: bichos **cerca** de los POIs, sin que ataquen las estructuras.

Buena noticia: **no atacar estructuras es el comportamiento por defecto.** El árbol
`MELEE` solo persigue `TARGET`, que es el jugador o una presa. Las criaturas no
tienen ningún nodo que ataque edificios. No hay que desactivar nada.

### Asentamientos y bases del jugador — 🕒 APLAZADO, feature futura

**Palanca directa: `SpawnsAvoidBaseMultiplier`.** De 3 a 1 o 0. Es literalmente el
parámetro que mantiene la fauna lejos de tu base. Un número, un archivo, confirmado
que existe.

**Decisión: no tocarlo todavía.** Tener depredadores permanentemente encima de la
base cansa rápido y es el tipo de cosa que genera quejas en Nexus. Se reserva para
una feature de **evento / horda**: infestación temporal en vez de estado permanente.

`[Sin investigar]` Para que sea un evento y no un valor fijo haría falta un
disparador. Candidatos a explorar: el sistema de tormentas, los ataques de
centinelas, o algún flag de misión. Ninguno confirmado.

Recordar que **no atacarían la estructura** en ningún caso — el árbol `MELEE` solo
persigue `TARGET`, y `TARGET` nunca es un edificio. Rondar cerca sí; destrozar la
base no. Eso ya está garantizado por diseño.

### Estaciones abandonadas y corvetas abandonadas

Anotado como feature. Lo que sé por ahora:

```
METADATA/SIMULATION/FREIGHTERBASES/ABANDONEDFREIGHTERBASE{,A,B,C,S}.MBIN
MODELS/COMMON/SPACECRAFT/COMMONPARTS/ABANDONEDPARTS/DUNGEONENTRANCE...
MODELS/EFFECTS/ABANDONEDFREIGHTER/...
```

El interior de fragata abandonada es un **"dungeon"** — así lo llaman los propios
archivos (`DUNGEONENTRANCE`). Es contenido colocado a mano, no procedural, así que
probablemente los Fiends de ahí se colocan como entidades del layout y no por
ecosistema. `[Sin investigar]` — merece su propia sesión.

Es la ubicación **más prometedora** para el mod: espacio cerrado, oscuro, sin
vehículo al que huir, y ya tiene monstruos de serie. Encaja con Dead Space mejor que
cualquier superficie planetaria.

### POIs de superficie (edificios abandonados, ruinas)

Ya cubierto en §4: no hay forma de que las manadas "vayan hacia" un edificio, pero
sí de que **nazcan cerca** vía camino B, o de sembrar huevos de Fiend con
`FIENDEGGS` / `INFESTATION`.

---

## 5. Cola de trabajo propuesta

Ordenada por relación efecto/coste. Los tres primeros son cambios de un número.

| # | Idea | Archivo | Coste | Efecto |
|---|---|---|---|---|
| ✅1 | `MinGroupSize`/`MaxGroupSize` 1→3/5 en `PLAYERPREDATOR*` | `GROUND/GROUNDTABLEPLAYERPREDATOR{MED,LARGE}` | bajo | **jaurías en vez de bichos sueltos** |
| ✅2 | `PredatorPerceptionDistance` 40→60 | `GCCREATUREGLOBALS` | bajo | te detectan de más lejos |
| ✅3 | `PredatorRunAwayHealthPercent` 40→0 | `GCCREATUREGLOBALS` | bajo | pelean hasta morir |
| ✅4 | `PercentagePlayerPredators` 0.5→1.0 | `GCCREATUREGLOBALS` | bajo | todos los depredadores son hostiles |
| ✅5 | `MaxEcosystemCreaturesNormal` 40→60 | `GCCREATUREGLOBALS` | bajo | +50% de criaturas a la vez |
| 🕒6 | `SpawnsAvoidBaseMultiplier` 3→1 | `GCCREATUREGLOBALS` | bajo | aplazado: feature de evento/horda |
| 7 | Subir `Coverage`/`FlatDensity` de `FIENDEGGS` | `OBJECTS/RARE/FIENDEGGS` | bajo | Horrores Biológicos habituales |
| 8 | `HerdCreaturePenalty` 0.5→1.0 | `CREATUREGENERATIONDATA` | bajo | manadas más grandes |
| 9 | `FiendMaxAttackers` 2→4 | `GCCREATUREGLOBALS` | bajo | más Fiends encima a la vez |
| 10 | `PlayerPredatorBoredomDistance` 80→150 | `GCCREATUREGLOBALS` | bajo | **solo si escapar resulta demasiado fácil** |
| 11 | Meter `INFESTATION` en más biomas | listas `<X>OBJECTS*` | medio | zonas infestadas |
| 12 | `AllowSpawnBrood = true` en Fiends | `CREATUREDATATABLE` | medio | bichos que se multiplican |
| 13 | Arquetipo propio `HT_INFESTED` | `CREATUREGENERATIONARCHETYPES` | medio | control total del reparto |
| 14 | Fragatas abandonadas como escenario | `FREIGHTERBASES/ABANDONED*` | alto | **la feature con más potencial** |
| 15 | Criaturas fijas vía camino B | `<X>OBJECTS*` | alto | criatura firma del mod |
| 16 | `AvoidCreaturesStrength` en `MOVE_CLOSE` | `CREATUREBEHAVIOURTREES` | alto | solo si las jaurías se amontonan |

### Estado: los tres mods se fundieron en UNO con 4 configuraciones

`Ecosystem` + `PredatorPacks` + `PredatorSenses` eran tres mods que había que
instalar juntos para tener la experiencia completa. Ahora son **un solo mod de
dificultad** con cuatro variantes, de las que se instala una:

```
work/scripts/dificultad/
    HorribleTerror_Predators_1-Facil.lua
    HorribleTerror_Predators_2-Normal.lua
    HorribleTerror_Predators_3-Dificil.lua      <- equivale a los 3 mods viejos
    HorribleTerror_Predators_4-Hardcore.lua
```

Cada uno toca las mismas 4 rutas y produce un mod completo. Detalle y tabla
comparativa en [`work/scripts/dificultad/README.md`](../work/scripts/dificultad/README.md).

**Consecuencia para el mod de monstruos:** esta configuración es la base. El mod de
Fiends/monstruos irá **aparte**, tocando rutas distintas
(`OBJECTS/RARE/FIENDEGGS`, `CREATUREDATATABLE`, listas de bioma), para que se pueda
combinar con cualquiera de los cuatro niveles sin colisión.

**⚠️ Estos cambios se multiplican, no se suman.** Si queda injugable, el orden para
aflojar es: `PercentagePlayerPredators` primero, luego el tamaño de manada, y la
densidad **la última** — ya está topada por `MaxEcosystemCreatures` y bajarla hará
menos de lo que parece.

**Nota sobre el orden:** las ideas 2-5 y 8 viven todas en `GCCREATUREGLOBALS`, así
que van juntas en **un solo script** — mismo archivo, mismo mod (§10i). Es el
siguiente bloque natural después de las manadas, y es donde está la mejor relación
efecto/coste de toda la tabla.

**Sobre la 2:** subir percepción y aburrimiento a la vez es probablemente el cambio
que más "terror" añade por línea tocada. Un depredador que te ve a 70 m y te sigue
150 m cambia el juego más que cualquier número de densidad.

**Sobre la densidad:** con `MaxEcosystemCreaturesNormal = 40` ya estamos tocando
techo con x20. Subirla más no hará nada. Para más amenaza, la palanca es la 4
(`PercentagePlayerPredators`), no la densidad.

---

## 6. Preguntas abiertas

- `[Sin investigar]` **Fragatas abandonadas.** Los archivos las llaman "dungeon"
  (`DUNGEONENTRANCE`). ¿Los Fiends de dentro se colocan como entidades del layout o
  por ecosistema? Es el escenario que mejor encaja con Dead Space: cerrado, oscuro,
  sin nave a la que huir, y ya trae monstruos.
- `[Sin probar]` ¿Qué dispara `MaxFiendsToSpawnCarnage = 10`? Hay un modo "carnage"
  implementado.
- `[Sin probar]` ¿`PredatorStealthDist = 11` es "te ve aunque vayas agachado" o al
  revés? El nombre admite las dos lecturas.
- `[Sin probar]` ¿`GcEnvironmentSpawnData.Creatures` respeta `LifeChance` del planeta?
- `[Sin probar]` ¿Qué acepta `SpawnBroodID`? ¿Un `CreatureID`, un archivo, un rol?
- `[Sin probar]` ¿Qué es `GcCreatureSpookFiendAttackData` y quién lo usa?
- `[Sin probar]` ¿`AttractedToBait` funciona con el cebo del jugador?
- `[Inferencia]` ¿Rellenar `BiomeSpecific → Lush → Ground` anula `Generic` para ese
  bioma, o se suman? `OverrideAllDomains = true` sugiere que anula — sin confirmar.
- ¿Hay límite duro de criaturas simultáneas? Relevante antes de subir grupos y
  densidad a la vez.
