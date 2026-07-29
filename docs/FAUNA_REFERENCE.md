# Referencia de fauna, arquetipos y roles — NMS 6.45

Todo lo de aquí está **verificado** contra la instalación local:
NMS build 24039799 (rama Public), MBINCompiler 6.45.0.1, decompilado el 2026-07-29.

Documento de trabajo: sirve para saber **qué archivo tocar** antes de escribir un script.

---

## 1. Dónde vive cada cosa

| Sistema | Ruta base | Pak |
|---|---|---|
| Fauna | `METADATA\SIMULATION\ECOSYSTEM\` | `NMSARC.Precache.pak` |
| Edificios procedurales | `METADATA\SIMULATION\SOLARSYSTEM\WFCBUILDINGS\` | `NMSARC.Precache.pak` |
| Biomas / planetas | `METADATA\SIMULATION\SOLARSYSTEM\BIOMES\` | `NMSARC.Precache.pak` |
| Bases de fragata | `METADATA\SIMULATION\FREIGHTERBASES\` | `NMSARC.Precache.pak` |
| Bases de nave | `METADATA\SIMULATION\SHIPBASES\` | `NMSARC.Precache.pak` |
| NPCs | `METADATA\SIMULATION\NPCS\` | `NMSARC.Precache.pak` |

Recuento en `metadata/`: 1051 archivos. De ellos, 573 en `solarsystem`, 142 en `ecosystem`.

Cómo se reconstruye este índice si el juego se actualiza:

```powershell
$h = "tools\AMUMSS\MODBUILDER\hgpaktool.exe"
$paks = (Get-ChildItem "<NMS>\GAMEDATA\PCBANKS" -Filter *.pak).FullName
& $h -L -O <salida> @paks          # solo lee la tabla de contenidos, no descomprime
```

Extraer un archivo concreto:

```powershell
& $h -U -f "*ecosystem/creature*" -O unpacked\ "<NMS>\GAMEDATA\PCBANKS\NMSARC.Precache.pak"
& tools\AMUMSS\MODBUILDER\MBINCompiler.exe unpacked\...\archivo.mbin   # genera .MXML
```

---

## 2. Archivos del ecosistema (raíz)

| Archivo | Tamaño | Contenido |
|---|---|---|
| `CREATUREDATATABLE.MBIN` | 255 KB | el grueso de los datos de fauna |
| `CREATUREGENERATIONARCHETYPES.MBIN` | 17.5 KB | **arquetipos de spawn** → §4 |
| `CREATUREFILENAMETABLE.MBIN` | 9.4 KB | rutas de modelos por criatura |
| `CREATUREPETBEHAVIOURTABLE.MBIN` | 5.6 KB | comportamiento de mascotas |
| `CREATUREGENERATIONDATA.MBIN` | 5.2 KB | **densidad y probabilidades** → §3 |
| `CREATUREROLEDESCRIPTIONTABLE.MBIN` | 4.9 KB | roles → §6 ⚠️ ver advertencia |
| `CREATUREBEHAVIOURTREES.MBIN` | 4.5 KB | árboles de comportamiento |
| `CREATUREAUDIOTABLE.MBIN` | 448 B | **sonidos** — clave para gruñidos zombie |
| `ROBOTDATATABLE.MBIN` | — | sentinelas / robots |

Subcarpetas: `ground\` (51), `underwater\` (24), `air\` (7), `cave\` (1),
`deprecate\` (46 — **ignorar**, son legacy).

---

## 3. CREATUREGENERATIONDATA — parámetros globales

Los valores vanilla, como línea base. Sin esto no hay forma de saber si un cambio hizo algo.

```
GroundGroupsPerKm         Sparse  25    Normal  50    Dense  100   VeryDense 200
WaterGroupsPerKm          Sparse  30    Normal  60    Dense   80   VeryDense 100
AirGroupsPerKm            Sparse  10    Normal  20    Dense   30   VeryDense  40
CaveGroupsPerKm           Sparse  50    Normal 100    Dense  200   VeryDense 300
DensityModifiers          Sparse 0.5    Normal   1    Dense    2   VeryDense   4
RoleFrequencyModifiers    Never    0    Low    0.2    Normal   1   High        5
RarityFrequencyModifiers  Common  10    Uncommon 3    Rare   1.2   SuperRare 0.9
LifeChance                Dead     0    Low      0    Mid      0   Full        1
LifeLevelDensityModifiers Dead     0    Low    0.4    Mid    0.7   Full      1.2
HerdCreaturePenalty       0.5
```

`SandwormPresenceChance` por bioma:

```
Lush 0.10  Toxic 0.25  Scorched 0.25  Radioactive 0.25  Frozen 0.05
Barren 0.25  Dead 0.30  Weird 0.00  Red/Green/Blue 0.50  Test 0.00
Swamp 0.40  Lava 0.25  Waterworld 0.00  GasGiant 0.00  All 0.00
```

### Secciones de primer nivel del archivo

| Línea | Sección | Qué controla |
|---|---|---|
| 4 | `BiomeSpecific` | overrides por bioma — **vacío en vanilla** |
| 185 | `SubBiomeSpecific` | overrides por sub-bioma — vacío |
| 570 | `AbandonedSystemSpecific` | sistemas abandonados |
| 580 | `EmptySystemSpecific` | sistemas vacíos |
| 595 | `PurpleSystemSpecific` | sistemas púrpura |
| 631 | `Generic` | **el fallback real** — aquí actúa casi todo |
| 729+ | parámetros globales | los de la tabla de arriba |

Que `BiomeSpecific` esté vacío es una oportunidad: **rellenarlo permite infestar
biomas concretos sin tocar el resto del universo.** Es la vía para "planeta infestado"
en lugar de "universo infestado".

### ⚠️ Trampa: claves repetidas

`Sparse` / `Normal` / `Dense` / `VeryDense` aparecen **idénticas** en cinco secciones
(`GroundGroupsPerKm`, `WaterGroupsPerKm`, `AirGroupsPerKm`, `CaveGroupsPerKm`,
`DensityModifiers`). Lo mismo `Dead`/`Low`/`Mid`/`Full` en `LifeChance` y
`LifeLevelDensityModifiers`.

**Siempre usar `PRECEDING_KEY_WORDS` con el nombre de la sección.** Sin eso el cambio
se aplica a todas y el resultado es incontrolable.

---

## 4. Arquetipos de spawn (CREATUREGENERATIONARCHETYPES)

Un arquetipo es un conjunto de tablas de criaturas con pesos. Define **qué mezcla de
bichos** aparece. Cada uno tiene un `_id`.

### GroundArchetypes — terrestres

**Hostiles (lo que interesa al mod):**

| `_id` | Apunta a | Nota |
|---|---|---|
| `DANGEROUS` | `GROUNDTABLEPLAYERPREDATORMED`, `GROUNDTABLEPLAYERPREDATORLARGE` | ⭐ **atacan al jugador** |
| `HERD` | incluye `GROUNDTABLEPREDATORLARGE` | manadas con depredador |
| `HUNTEDHERD` | presa + cazador | dinámica de caza |
| `WRDROLLPRED` | `GROUNDTABLEWEIRDROLLPREDATOR` | depredador bioma Weird |
| `WRDCRYSTALPRED` | `GROUNDTABLEWEIRDCRYSTALPREDATOR` | depredador bioma Weird |

**Neutros / ambientales:**

`DEFAULT`, `SPARSE`, `BUSY`, `PARADISE`, `GIANT`, `ALIEN`, `BONE`, `ROBOT`,
`BUTTERFLY`, `PURPLEWEIRD`, `GLOWSTRIDERS`, `BEETLEWORLD`, `PLANTCATWORLD`,
`WRDFLOAT`, `WRDROLL`, `WRDCRYSTAL`, `WRDBUTTERFLY`

**Prefijo `T_` = variantes de test/plantilla:**

`T_HERMITCRAB`, `T_PLANTCAT`, `T_ARTHROPOD`, `T_WALKBUILD`, `T_PETS`, `T_ROBEETLE`,
`T_BUTTERFLOCK`, `T_MOLE`, `T_SMALLBIRD`, `T_BUTTERFLY`, `T_BEETLE`, `T_DIGGERS`,
`T_DRILL`, `T_PLOUGH`, `T_PROTOFLYER`, `T_PROTOROLLER`, `T_PROTODIGGER`,
`T_PURPLEWEIRD`, `T_BONECOWS`

### AirArchetypes — voladores

`DEFAULT`, `ONLYAIR`, `BIGBIRDS`, `FLYINGSNAKE`, `FLYINGLIZARD`, `ONLYSNAKE`,
`ONLYLIZARD`, `BUSY`

### WaterArchetypes — acuáticos

`DEFAULT`, `WATERWORLD`, `WATERGLOW`, `CRABS`, `T_JUSTFISH`, `T_FISH`, `T_JELLYFISH`,
`T_FLOCKSHARK`, `T_FLOCK`, `T_FLOCK2`, `T_FLOCK3`, `T_DEEPFLOCK`, `T_FLOCKMANTA`,
`T_FLOCKSEAHORSE`, `T_SHARKSNAKE`, `T_SQUID`, `T_FLOCKPRAWN`, `T_ALLNEWFISH`

### CaveArchetypes

`DEFAULT`

---

## 5. Tablas de spawn terrestre (`ecosystem\ground\`)

**La distinción más importante del documento:**

- `PLAYERPREDATOR*` → **agresivos con el jugador**. Te atacan.
- `PREDATOR*` (sin `player`) → depredadores del ecosistema. Cazan otras criaturas,
  no a ti.

Para un mod de terror, `PLAYERPREDATOR` es lo que da miedo. `PREDATOR` solo da ambiente.

### Producción

| Archivo | Rol |
|---|---|
| `GROUNDTABLEPLAYERPREDATORLARGE` | ⭐ hostil grande contra el jugador |
| `GROUNDTABLEPLAYERPREDATORMED` | ⭐ hostil medio contra el jugador |
| `GROUNDTABLEPREDATORLARGE` | depredador grande (ecosistema) |
| `GROUNDTABLEPREDATORMED` | depredador medio (ecosistema) |
| `GROUNDTABLEARTHROPODPRED` | artrópodo depredador |
| `GROUNDTABLEPLANTCATPRED` | planta-gato depredador |
| `GROUNDTABLEHERBIVOREGIANT/LARGE/MED/SMALL` | herbívoros por tamaño |
| `GROUNDTABLEHERDMED` | manada mediana |
| `GROUNDTABLEBONE` | criaturas óseas — **estética útil para zombie** |
| `GROUNDTABLEALIEN` | alienígenas |
| `GROUNDTABLEROBOT` | robots |
| `GROUNDTABLEWALKINGBUILDING` | edificios andantes |
| `GROUNDTABLEBUTTERFLY`, `GROUNDTABLEMAYBEBUTTERFLY` | mariposas |
| `GROUNDTABLEARTHROPODHERB`, `...WORLD` | artrópodos |
| `GROUNDTABLEPLANTCATHERB`, `...WORLD` | planta-gato |

### Bioma Weird (`ground\weird\`)

`GROUNDTABLEWEIRDROLLPREDATOR`, `GROUNDTABLEWEIRDCRYSTALPREDATOR`,
`GROUNDTABLEWEIRDBUTTERFLY`, `GROUNDTABLEWEIRDCRYSTAL`, `GROUNDTABLEWEIRDFLOAT`,
`GROUNDTABLEWEIRDGLOWSTRIDERS`, `GROUNDTABLEWEIRDPURPLE`, `GROUNDTABLEWEIRDPURPLEBONES`,
`GROUNDTABLEWEIRDROLL`

### `ground\test\` — 21 archivos

Plantillas de desarrollo. **No usar como base**: pueden no estar referenciadas por
nada y cambiarlas no tendría efecto.

### Aire y cueva

```
air\AIRTABLEBIGBIRD, AIRTABLEBUSY, AIRTABLECOMMON, AIRTABLECOMMONLIZARD,
    AIRTABLECOMMONSNAKE, AIRTABLEFLYINGLIZARDONLY, AIRTABLEFLYINGSNAKESONLY
cave\CAVETABLECOMMON
```

---

## 6. Roles (CREATUREROLEDESCRIPTIONTABLE)

Estructura: `BiomeFiles` con una entrada por bioma (Lush, Toxic, Scorched, Radioactive,
Frozen, Barren, Dead, Weird, Red, Green, Blue, Test, Swamp, Lava, Waterworld, GasGiant,
All), más `UnderwaterFiles`, `UnderwaterFilesExtra`, `CaveFiles`, `AirFiles`.

**Todos los biomas individuales están vacíos.** Solo `All` tiene contenido — 9 entradas:

| # | Archivo referenciado | `BiomeProbability` Full |
|---|---|---|
| 0 | `GROUNDTABLESPARSE` | 1.0 |
| 1 | `GROUNDTABLEDEAD` | 1.0 |
| 2 | `GROUNDTABLECOMMON` | **0.0** ← desactivado |
| 3 | `GROUNDTABLEBUSY` | 1.0 |
| 4 | `GROUNDTABLEGIANT` | 1.0 |
| 5 | `GROUNDTABLEPREDATORS` | 1.0 |
| 6 | `GROUNDTABLESMALLPREDATORS` | 1.0 |
| 7 | `GROUNDTABLEPREYBLOBS` | 1.0 |
| 8 | `GROUNDTABLEPREHISTORIC` | 1.0 |

`BiomeProbability` tiene claves `Dead/Low/Mid/Full`, que **no son biomas**: son
niveles de vida del planeta. En la práctica solo `Full` está activo.

### ⚠️⚠️ Advertencia importante

Esas 9 entradas apuntan a
`METADATA/SIMULATION/ECOSYSTEM/ROLEDESCRIPTIONTABLES/GROUND/*.MBIN`.

**Esa carpeta no existe en ningún `.pak`.** Verificado: 0 coincidencias sobre el
índice completo de los 97 paks.

Son referencias muertas. Consecuencia práctica: **no perder tiempo intentando editar
esos archivos** — no están. Si se quiere tocar roles, hay que trabajar sobre los
arquetipos (§4) y las tablas de `ecosystem\ground\` (§5), que sí existen.

---

## 7. Edificios, naves y estructuras — cómo distinguirlos

Lo que **no** es fauna, para no confundirse al buscar.

### Edificios procedurales — `SOLARSYSTEM\WFCBUILDINGS\` (94 archivos)

WFC = Wave Function Collapse, el algoritmo que los ensambla. Organizados **por material**:

```
stone\      (31)  piedra
fibreglass\ (15)  fibra de vidrio
wood\       (14)  madera
builders\   (20)  genéricos / plantillas
cuboid3\    (11)  bases modulares del jugador
freighter\   (2)  fragata
```

Tipos de edificio, repetidos en cada material:

| Archivo | Qué es |
|---|---|
| `bar.wfc` | bar |
| `market.wfc` | mercado |
| `factory.wfc` | fábrica |
| `farm.wfc` | granja |
| `sheriffsoffice.wfc` | oficina del sheriff |
| `monument.wfc` | monumento |
| `tower.wfc` | torre |
| `landingzone.wfc` | zona de aterrizaje |
| `smallindustrial.wfc` | industrial pequeño |
| `small0/medium0/large0.wfc` | genéricos por tamaño |
| `chev_shop.wfc` | tienda |
| `clump.wfc` | agrupación |
| `double.wfc` | doble |
| `npcbase.wfc` | base de NPC |
| `fishpond.wfc` | estanque (solo stone) |
| `roboarm.wfc` | brazo robótico (solo builders) |

Sufijos: `*moduleset.mbin` = piezas disponibles · `*decorationset.mbin` = decoración.

`settlementcolourtable.mbin` = paleta de asentamientos.

### Ruinas por bioma — `SOLARSYSTEM\BIOMES\<bioma>\`

```
barrenruinsbiome / barrenruinsobjects / barrenruinscolourpalettes
frozenruinsbiome / frozenruinsobjects
lushruinsbiome / lushruinsobjects / lushruinscolourpalettes
radioactiveruinsbiome / radioactiveruinsobjects
scorchedruinsbiome / scorchedruinsobjects
toxicruinsbiome / toxicruinsobjects
```

⭐ **Vía directa para la Ruta B.** Las ruinas ya son estructuras derruidas
distribuidas por el planeta. Retexturizarlas u oscurecerlas da atmósfera de
catástrofe sin modelar nada.

También: `biomes\objects\rock\buildingdressing.mbin` y `buildingdressingglow.mbin`.

### Naves y fragatas

```
SHIPBASES\        defaultshipbase, emergencyshipbase                    (2)
FREIGHTERBASES\   23 archivos: abandonedfreighterbase[a/b/c/s],
                  defaultfreighterbase, longfreighterbase, weapfreighterbase,
                  loungefreighterbase, biolinefreighterbase, terraium,
                  fishparadise, simpleexterior, simpletech, smallstandard...
```

⭐ `abandonedfreighterbase*` — fragatas abandonadas. Interiores derruidos ya
existentes en vanilla. Lo más cercano a Dead Space que trae el juego de fábrica.

### NPCs — `SIMULATION\NPCS\` (10 archivos)

`npcspawntable`, `npcanimations`, `npccolourtable`, `npcreactions`,
`npcinteractionsdatatable`, `npcproptable`, `npcsettlementbehaviours`,
`npcpresetcustomisationsdata`, `npcwordreactions`, `librarymainterminalwordreactions`

---

## 8. Recetas para el mod

Ordenadas de menor a mayor riesgo.

### A — Subir densidad de fauna (hecho, Fase 1)

`CREATUREGENERATIONDATA` → `GroundGroupsPerKm` × N.
Efecto global e inmediato. Sirve de prueba de pipeline.

### B — Hacer el universo hostil

`CREATUREGENERATIONDATA` → `RoleFrequencyModifiers`:
subir `Normal` (1) y `Low` (0.2) acerca todo a `High` (5).
Más depredadores en la mezcla global.

### C — Infestar biomas concretos ⭐ el objetivo real

`CREATUREGENERATIONDATA` → `BiomeSpecific`, hoy vacío.
Rellenar el bioma `Dead` (o `Barren`) con el arquetipo `DANGEROUS` y
`OverrideAllDomains = true`.

Resultado: planetas muertos infestados de hostiles, resto del universo intacto.
Esto es "planeta infestado" de verdad, no "universo infestado".

### D — Look zombie sin Blender

Paletas y materiales. Empezar por `GROUNDTABLEBONE` (criaturas óseas, ya cerca de
la estética) antes de repintar DDS de rig. Ver §5b del doc de diseño: la retextura
es **por rig**, afecta a toda la fauna que lo comparta.

### E — Sonido

`CREATUREAUDIOTABLE.MBIN` — solo 448 bytes. Archivo pequeño, alto impacto.
El audio hace más por el terror que la textura.

### F — Ambiente (Ruta B)

Ruinas por bioma + `abandonedfreighterbase*`. Ya existen; retexturizar es más
barato que importar modelos.

---

## 9. Qué revisar cuando NMS se actualice

1. Regenerar el índice de paks (§1).
2. Confirmar que `CREATUREGENERATIONDATA` sigue en `NMSARC.Precache.pak`.
3. Re-decompilar y comparar valores contra §3 — Hello Games los cambia entre versiones.
4. Confirmar que los `_id` de arquetipos de §4 siguen existiendo.
5. Re-buildear con AMUMSS y probar en save de pruebas.
