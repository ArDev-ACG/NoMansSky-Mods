# Changelog — proyecto y mod 1

Formato: [Keep a Changelog](https://keepachangelog.com/). Versionado: SemVer.

> 📘 **El mod 2 (Infestation) tiene su propio changelog:**
> [`CHANGELOG-MOD2.md`](CHANGELOG-MOD2.md). Se versiona aparte del mod 1 y arrancó en
> 0.1.0. Lo que quede aquí de mod 2 es histórico, hasta la separación del 2026-08-04.

Cada entrada de release debe anotar la **versión de NMS** contra la que se probó —
los updates del juego rompen mods y sin ese dato no se puede diagnosticar nada.

## [2.1.0] — 2026-08-18 · mod 1

**Fácil y Normal dejan de ser abrumadores.** Corrige la queja de Nexus: *«even on easy,
nearly every single species on the Planet where I last saved the game turn hostile now»*.

### Changed — solo Fácil y Normal

| Campo | Vanilla | Fácil | Normal |
|---|---:|---|---|
| `Generic → Ground → DANGEROUS → "Weight "` | 1 | 3 → **no se escribe** | 10 → **4** |
| → % de planetas hostiles | 9,1 % | 23,1 % → **9,1 %** | 50,0 % → **26,7 %** |
| `PercentagePlayerPredators` | 0.5 | 0.6 → **no se escribe** | 0.75 → **0.6** |
| `PredatorRunAwayHealthPercent` | 40 | 30 → **no se escribe** | 15 → **25** |
| `GroundGroupsPerKm` (los 4) | ×1 | ×2 *(igual)* | ×5 → **×3** |
| `MinGroupSize` / `MaxGroupSize` | 1/1 | 1/2 *(igual)* | 2/3 → **1/2** |

**Difícil y Hardcore no se tocan.** Quien elige esos tiers quiere justo lo que dan, y sus
conteos lo demuestran: 40 y 61, idénticos a los de la 2.0.0.

### Changed — el mod pasa a llamarse **More Aggressive Predators**

Título de la página de Nexus, antes `Horrible Terror - Aggressive Predators`.

**La carpeta instalable NO se renombra: sigue siendo `HorribleTerror_Predators_<tier>`.**
Está publicada con ese nombre desde 1.0.0. Renombrarla no da error — da algo peor: quien
actualiza extrayendo el zip se queda con **dos** carpetas, la vieja no se borra sola, las
dos escriben los mismos archivos y NMS carga una y descarta la otra **sin avisar**. El
jugador seguiría con los valores de 1.1.0 creyendo que actualizó, que es exactamente la
queja que esta versión viene a arreglar. Con el nombre intacto, extraer encima sobrescribe.

El zip, el `.pak` y el `.lua` de `Source\` llevan también el nombre viejo, por la misma
razón: un solo nombre para todo, cero ambigüedad. El detalle y el comando de empaquetado,
en [`NEXUS.md`](NEXUS.md) § *Excepción — un mod ya publicado no renombra su carpeta*.

### Por qué era el peso de `DANGEROUS` y no otra cosa

El peso **no** decide cuántos bichos hostiles hay en un planeta: decide **si el planeta
entero** cae en ese arquetipo. Y un planeta `DANGEROUS` saca toda su fauna terrestre de
`GROUNDTABLEPLAYERPREDATORMED` y `...LARGE` — allí no hay ni una especie pacífica. Con Fácil
en 23 % un jugador tenía **casi 1 de 4** de que el planeta donde tenía la partida guardada se
re-rodara a hostil de golpe. Eso es literalmente lo que describe la queja.

Fácil vuelve a la selección de planeta del juego base y se queda con su identidad real:
**más fauna, manadas de dos y detección un poco más larga**, sin infestar mundos.

### Verificación

Construido contra NMS **170671**, MBINCompiler 6.45.0.1, AMUMSS 5.6.2.0w — 0 errores, 0
warnings, 0 notices. Conteos de `!# CHANGED` en el EXML delta: **10 / 35 / 40 / 61**.

- Fácil baja de 13 a **10**: los tres campos que ahora coinciden con vanilla dejan de
  escribirse, no se escriben con su valor vanilla. Sigue tocando **3 rutas**.
- Normal se queda en **35**: cambian los valores, no el número de campos.
- Difícil **40** y Hardcore **61**, sin tocar.

Los cuatro tiers del mod 2 se reconstruyeron el mismo día para no separarlos: **20 / 45 /
50 / 71**, o sea **+10 exactos** sobre el mod 1 en los cuatro. Detalle en
[`CHANGELOG-MOD2.md`](CHANGELOG-MOD2.md).

**Construido, no desplegado** — este mod no se instala en la máquina de desarrollo.

### Release

Reconstruido y empaquetado el 2026-08-18 con `Build-Tiers.ps1` + `Package-Release.ps1`:
`releases.1.0\`, cuatro zips, **un solo `.lua` por zip** (1.1.0 metía los cuatro).

| Zip | Carpeta instalable | EXML |
|---|---|---:|
| `HorribleTerror_Predators_1-Facil_v2.1.0.zip` | `HorribleTerror_Predators_1-Facil` | 4 |
| `HorribleTerror_Predators_2-Normal_v2.1.0.zip` | `HorribleTerror_Predators_2-Normal` | 6 |
| `HorribleTerror_Predators_3-Dificil_v2.1.0.zip` | `HorribleTerror_Predators_3-Dificil` | 6 |
| `HorribleTerror_Predators_4-Hardcore_v2.1.0.zip` | `HorribleTerror_Predators_4-Hardcore` | 9 |

`Package-Release.ps1` aprendió a sacar el tier del nombre español de la carpeta: con
`-Nombres` forzando los nombres viejos, el `README.txt` decía *configuration installed:
single* en los cuatro zips. Ahora dice Easy / Normal / Hard / Hardcore.

**Sin subir a Nexus todavía.**

## [2.0.0] — 2026-08-09 · mod 1

**Cambio mayor: el mod 1 pasa a ser el mod de conducta de todo lo que caza.** Absorbe toda
la conducta de los Horrores Biológicos que estaba en Infestation 0.3.3.

### Added — se muda desde el mod 2

- `GCCREATUREGLOBALS`: presión de Fiends, percepción, eclosión en oleada, separación y radio
  del gusano, sin-acecho, steering y giro, horda, tenacidad del aggro, distancias de carguero.
- `CREATUREDATATABLE`: ataque de `FIEND` y de `BUGFIEND`, y el brood (`BUGFIENDS`, timer 10,
  `ROAR`).
- `CREATUREBEHAVIOURTREES`: árbol `MELEE`.
- `GCUIGLOBALS`: `ShowOnscreenPredatorMarkers`.
- Los dos `*SLIME.ENTITY` de nido de carguero: `AgroTorch` y `GunfireAgro`.

De 4 rutas a **7**. Fácil sigue tocando 3: no coge ni un campo de Fiend.

### Changed

- Descripciones de los cuatro tiers reescritas: ya no dicen «depredadores», dicen conducta.

### ⚠️ Corrección del mismo día — sigue sin poder instalarse junto al mod 2

La primera versión de esta entrada decía que los dos mods ya se podían instalar a la vez. **Se
revirtió esa tarde:** el mod 2 vuelve a **contener** a este mod, así que siguen escribiendo los
mismos 7 archivos y se instala uno **o** el otro.

**Lo que diferencia a los dos mods son los modelos de los monstruos, no el tipo de campo.** La
conducta la comparten por definición: este es el producto de entrada (solo dificultad) y el mod
2 es el completo.

**Este mod NO está instalado en la máquina de desarrollo** — lo que se juega y se prueba es el
mod 2. Este existe como producto aparte para Nexus.

⚠️ **Es el archivo fuente de la conducta.** El mod 2 se compone como *bloques de este mod +
bloques de mundo*. Cambiar un valor aquí sin recomponer el mod 2 los separa en silencio; el
conteo lo delata (mod 2 = este + 10, y + 40 en Hardcore).

### Verificación

Construido contra NMS **170671**, MBINCompiler 6.45.0.1. Conteos **13 / 35 / 40 / 61**, 0
errores. Sumados a los del mod 2 (10 / 10 / 10 / 40) dan **23 / 45 / 50 / 101**, idénticos a
los de Infestation 0.3.3 — prueba de que la mudanza no perdió ni duplicó un campo.

**Construido, no desplegado.**

## [Unreleased]

### Added
- Estructura de proyecto, `.gitignore`, repo git local + remoto en GitHub.
- Doc de diseño revisado: fases 1↔2 invertidas, unpack masivo descartado,
  alcance real de retextura documentado (§5b).
- Estado del sistema verificado: NMS instalado, carga de mods habilitada.

### Fase 0 — progreso
- .NET Desktop Runtime x64 ya presente (6.0.36 / 8.0.29 / 9.0.18).
- 7-Zip 26.02 instalado.
- Backup de saves de NMS (75 archivos, 14 MB) fuera de git.
- AMUMSS v5.6.2.0W descargado, sha256 verificado contra la release de GitHub.
- AMUMSS extraído: 714/714 archivos, sin interferencia del antivirus.
- Detectado que el AV activo es McAfee, no Defender (Defender tiene la protección
  en tiempo real desactivada). La exclusión va en McAfee.
- Documentado que los `.bat` de AMUMSS son interactivos y dependen del directorio
  de trabajo — `BUILDMOD.bat` se corre a mano.
- **Fase 0 cerrada.** `BUILDMOD.bat` en modo FULL: 0 errores, 0 warnings.
  MBINCompiler 6.45.0.1. McAfee no interfirió — la exclusión no hizo falta.
- Entorno: NMS rama Experimental, versión 170671.
- Corregida la ubicación de mods: es `GAMEDATA\MODS\` con carpetas descomprimidas,
  no `PCBANKS\MODS` con `.pak`. NMS 6.x cambió el formato.
- Escaneo de conflictos sobre los 87 mods instalados: ninguno toca fauna.
- Rama del juego confirmada por el manifest de Steam: **Public** (buildid 24039799),
  no Experimental. El riesgo de publicación anotado antes queda descartado.

### Fase 1 — en curso
- Indexado el contenido de los 97 `.pak` vanilla con `hgpaktool -L`.
- Localizado `CREATUREGENERATIONDATA.MBIN` en `NMSARC.Precache.pak`, junto con
  el resto del ecosistema de fauna. Extraído y decompilado.
- Documentados los valores vanilla de densidad, roles y rareza.
- Descubierto que MBINCompiler 6.45 genera `.MXML`, no `.EXML`.
- Descubiertos los arquetipos `DANGEROUS` / `WRDROLLPRED` — el juego ya trae
  depredadores que cazan al jugador, no hay que crear comportamiento hostil.
- Escrito `work/scripts/HorribleTerror_GroundDensity.lua` (x3 densidad terrestre)
  como prueba de pipeline.
- Añadido `tools/Backup-NMSSave.ps1`: backup etiquetado de partidas con rotación
  y aviso si el juego está abierto. Se corre antes de cada prueba.
- Añadido `docs/FAUNA_REFERENCE.md`: referencia detallada de fauna, arquetipos,
  roles, tablas de spawn, edificios, ruinas, naves y NPCs. Todo verificado contra
  la instalación local.
- Verificado que `ROLEDESCRIPTIONTABLES/` no existe en ningún pak: las 9 entradas
  de `CREATUREROLEDESCRIPTIONTABLE` son referencias muertas.
- Documentada la distinción `PLAYERPREDATOR` (ataca al jugador) vs `PREDATOR`
  (caza otras criaturas) — determinante para un mod de terror.
- **Primera build real del mod.** `BUILDMOD.bat` sobre
  `HorribleTerror_GroundDensity.lua`: 4 cambios aplicados, 0 errores, 0 warnings,
  4 segundos. Desplegado a `GAMEDATA\MODS\HorribleTerror_GroundDensity\`.
- Descubierto que AMUMSS despliega un **EXML delta** (solo las propiedades tocadas,
  496 B) en vez del MBIN completo. Verificado contra los mods instalados: formato
  válido en NMS 6.x, y reduce mucho la superficie de conflicto. Ver §10f.
- Backup de saves previo a la prueba: `backups\NMS_saves_2026-07-29_0130_antes-densidad-x3\`.
- `DENSITY_MULT` subido de 3 a **20** (500/1000/2000/4000). Valor de prueba
  deliberadamente exagerado para que el cambio sea inequívoco; no es el de release.

### Fase 2 — desbloqueada

- **Resuelta la cadena de color de la fauna** (§5d), en tres saltos:
  `.TEXTURE.MBIN` declara un nombre de paleta (`TkPaletteTexture`) → el nombre se
  resuelve contra el `*COLOURPALETTES.MBIN` del bioma → el juego elige color por
  semilla. Descartados por comprobación directa `.MATERIAL.MBIN`, `.DESCRIPTOR.MBIN`
  y `CREATUREDATATABLE`: ninguno referencia paletas.
- Medido qué paletas usa la fauna decompilando los 432 `.TEXTURE.MBIN` de criatura:
  Scale 1318, Underbelly 512, Fur 470, Rock 402, Feather 128, Paint 113.
  `Rock` y `Paint` quedan fuera por estar compartidas con terreno y naves.
- Verificado que los 47 archivos de paletas de bioma contienen las 5 paletas de piel.
- Detectada la colisión de subcadena `Underbelly` / `BioShip_Underbelly`, y
  descartada tras la build: `PRECEDING_KEY_WORDS` empareja por nombre exacto de
  sección, no por subcadena. Las naves vivientes no se ven afectadas.
- Escrito `work/scripts/HorribleTerror_RedFauna.lua`: rojo carne en las 5 paletas
  × 47 archivos, como prueba de validación visual de la ruta de paletas.
- Build de los dos mods: 0 errores, 0 warnings, 51 s. Desplegados como mods
  individuales. `RedFauna` genera 47 EXML delta, 960 líneas cambiadas cada uno
  (5 paletas × 64 colores × 3 canales) — el conteo cuadra exacto.

### HITO — pipeline confirmado in-game (2026-07-29)

- **Ambos cambios verificados jugando**: más fauna terrestre y roja.
  La cadena `.lua → AMUMSS → MBINCompiler → EXML delta → GAMEDATA\MODS → juego`
  funciona de punta a punta. Fase 1 cumple su meta; Fase 2 valida su ruta barata
  (paletas, sin Blender ni DDS).
- `RedFauna` retirado del juego tras validarlo y archivado en
  `build\HorribleTerror_RedFauna_VERIFICADO_2026-07-29\`; su `.lua` movido a
  `ModScript\Disabled scripts and paks\`. Se sigue solo con densidad para poder
  leer sin ruido el efecto de los cambios de rol.
- Aclarado que `GroundGroupsPerKm` es densidad **total** de fauna terrestre, sin
  distinción de rol. La proporción de depredadores se controla aparte, en
  `RoleFrequencyModifiers` y en `CREATUREGENERATIONARCHETYPES`.

### Fase 1 — infestación (siguiente prueba)

- Mapeada la selección de arquetipo por planeta (§5c-bis): la lista que decide es
  `Generic → Ground`. Verificado que las listas `Ground` de `BiomeSpecific` están
  vacías para todos los biomas normales, así que los planetas corrientes caen
  todos en `Generic`. Solo Weird y los sistemas púrpura traen listas propias.
- Documentados los pesos vanilla: `DANGEROUS` es 1.00 de una suma de 11 = 9.1%
  de los planetas. `DEFAULT` viene con peso 0, desactivado por Hello Games.
- **Trampa encontrada:** la propiedad es `"Weight "`, con espacio final. Typo en
  los datos del juego, igual que `"BiomeSpecific "`.
- Escrito `work/scripts/HorribleTerror_PredatorWorlds.lua`: sube `DANGEROUS` a
  1000 → 99% de planetas infestados. Se sube un peso en vez de bajar los otros
  diez: mismo efecto, un solo cambio, menos que romper en updates y menos choque
  con otros mods.
- **Bug corregido antes de llegar al juego** (§10h): la primera versión usaba
  `WHERE_IN_SECTION` y puso a 1000 los 22 pesos de `Generic`, no solo el de
  `DANGEROUS`. `WIS` filtra secciones enteras, no localiza sub-secciones. La
  versión buena usa `SPECIAL_KEY_WORDS` con dos pares encadenados: 1 cambio.
- Documentado que `0 [ERROR] detected` no prueba nada sobre la corrección del mod
  (§8c). El bug de arriba reportó 0 errores y 0 warnings. Lo que sí prueba es leer
  el EXML delta, que al ser parche parcial lista exactamente lo que se tocó.
- Añadida al doc la guía de respuestas a los prompts de `BUILDMOD.bat` (§8b), con
  la regla del prompt de copiar: `N` si algún script cambió, `A` si ya se verificó.
- Desplegados `HorribleTerror_PredatorWorlds` y `HorribleTerror_GroundDensity`
  tras verificar el delta de ambos.
- **Confirmado in-game:** la densidad se ve, hay más depredadores y atacan.

### Fase 1 — colisión de mods y unificación

- **Bug: planetas sin fauna.** Causa: los dos mods escribían la misma ruta
  `CREATUREGENERATIONDATA.EXML`, justo lo que AMUMSS avisa en el prompt de
  COMBINED/INDIVIDUAL. Corregida la regla del §8b: `INDIVIDUAL` solo vale si los
  scripts tocan archivos distintos (§10i).
- Fusionados los dos scripts en `work/scripts/HorribleTerror_Ecosystem.lua`.
  Los antiguos pasan a `Disabled scripts and paks/`.
- Verificado que en vanilla **solo los planetas de vida `Full` tienen fauna
  terrestre**: `LifeChance` es `Dead 0 / Low 0 / Mid 0 / Full 1`, y las 21 tablas
  de spawn terrestre exigen `LifeLevel = Full` salvo `groundtablealien` (`Mid`).
  Los planetas pelados que se veían antes del mod eran normales.

### Investigación — mapa de spawn (docs/IDEAS.md)

- **Descubierto un segundo camino de spawn**: `GcEnvironmentSpawnData.Creatures`
  dentro de las listas de objetos de bioma. Permite criaturas fijas ligadas a la
  colocación de objetos, en paralelo al ecosistema procedural. Ejemplo vanilla
  funcional en `biomes/rocky/rockobjectsfull`.
- **Identificados los monstruos de edificios: `FIEND`.** Usan el `SPIDERRIG`. No
  salen del ecosistema sino de objetos de bioma:
  `BIOMES/OBJECTS/RARE/FIENDEGGS.MBIN` e `INFESTATION.MBIN`.
  `GROUNDTABLEFIEND` está en `DEPRECATE/`, es vía muerta.
- Mapeados los cuatro sistemas de manada: tamaño de grupo en las tablas de spawn,
  `HerdCreaturePenalty` global, `GcCreatureFlockMovementData` (24 campos) y
  `GcCreatureSwarmData` (57), y los 8 árboles de `CREATUREBEHAVIOURTREES`.
- **Hallazgo accionable:** `PLAYERPREDATORMED`/`LARGE` tienen
  `MinGroupSize = MaxGroupSize = 1`. Los depredadores que cazan al jugador salen
  solos por diseño. Es la razón de que se sientan poca cosa pese al x20.
- Documentado `GcCreatureFiendAttackData` (39 campos), con `AllowSpawnBrood`
  implementado pero apagado en vanilla.
- Creado `docs/IDEAS.md` con el mapa completo y la cola de trabajo priorizada.

<!--
## [0.1.0] - AAAA-MM-DD
Probado contra NMS <version>.

### Added
### Changed
### Fixed
-->

### Fase 1 — manadas y sensores

- Escrito `work/scripts/HorribleTerror_PredatorPacks.lua`: `MinGroupSize`/
  `MaxGroupSize` de 1/1 a 3/5 en `GROUNDTABLEPLAYERPREDATOR{MED,LARGE}`.
  Script aparte porque toca archivos distintos de `CREATUREGENERATIONDATA`.
- **Verificado que no hay fuego amigo**: el nodo de daño del árbol `MELEE` es
  `GcBehaviourApplyDamageData` con `PlayerDamageType = FIEND_DMG` y radio 1.0, es
  decir daño al jugador, no un área que alcance a otras criaturas. Subir el tamaño
  de manada es seguro.
- Riesgo anotado, no corregido: el nodo `MOVE_CLOSE` del `MELEE` pisa la evitación
  global con `AvoidCreaturesStrength = 0`, así que mientras cargan no se esquivan.
  Puede haber amontonamiento con manadas de 5. Se decide tras verlo in-game.
- **Descubierto `GLOBALS/GCCREATUREGLOBALS.MBIN`**, donde vive todo lo de percepción
  y agro: `PredatorPerceptionDistance` 40, `PlayerPredatorBoredomDistance` 80,
  `PredatorRunAwayHealthPercent` 40, `PercentagePlayerPredators` 0.5,
  `PredatorStealthDist` 11, `AlertDistance` 50.
- **Tope duro encontrado:** `MaxEcosystemCreaturesNormal = 40`. Explica por qué el
  x20 de densidad no revienta el juego, y que subirla más ya no aporta nada.
- **`SpawnsAvoidBaseMultiplier = 3`**: las criaturas evitan las bases del jugador a
  propósito. Es la palanca para spawn cerca de asentamientos.
- Confirmado que las criaturas **no atacan estructuras** en ningún caso: el árbol
  `MELEE` solo persigue `TARGET`, que es el jugador o una presa. No hay que
  desactivar nada para conseguirlo.
- Anotadas como features las fragatas abandonadas (los archivos las llaman
  "dungeon") y los Fiends de interiores.
- Escrito `work/scripts/HorribleTerror_PredatorSenses.lua` sobre
  `GLOBALS/GCCREATUREGLOBALS.MBIN`: `PredatorPerceptionDistance` 40→60,
  `PredatorRunAwayHealthPercent` 40→0 (pelean hasta morir),
  `PercentagePlayerPredators` 0.5→1.0 (todos hostiles),
  `MaxEcosystemCreaturesNormal` 40→60.
- `PlayerPredatorBoredomDistance` se deja sin tocar: ya vale 80 en vanilla, así
  que escribirlo sería un cambio nulo que solo ensucia el EXML delta.
- Anotada la interacción percepción/aburrimiento: con 60 y 80, el margen para
  escapar baja de 40 m a 20 m. Si escapar resulta imposible, la corrección es subir
  `BoredomDistance`, no bajar la percepción.
- **Trampa:** `MaxEcosystemCreaturesNormal` es entero (`40`, sin decimales) mientras
  que los otros cuatro son floats. Hay que escribir `60`, no `60.000000`.
- `SpawnsAvoidBaseMultiplier` aplazado a propósito como feature de evento/horda:
  depredadores permanentes sobre la base propia cansan y generan quejas.
- Verificado que los tres mods activos tocan cuatro rutas distintas — sin solapes,
  `INDIVIDUAL` es seguro.
- Build de los tres mods: 0 errores. Conteos correctos (4 / 4 / 5) y deltas
  verificados propiedad por propiedad antes de desplegar. El entero
  `MaxEcosystemCreaturesNormal` se mantuvo sin decimales en el EXML generado.
- **Corregido el diagnóstico de los planetas vacíos** (§10i). Un escaneo encontró
  11 colisiones de ruta ya existentes entre los 87 mods de terceros instalados, y
  conviven sin romper nada: una colisión hace que un cambio se pierda en silencio,
  no que el juego falle. Sumado a que en vanilla solo los planetas `Full` tienen
  fauna terrestre, lo más probable es que no hubiera bug — era comportamiento
  normal. La regla de no solapar rutas se mantiene, pero por otro motivo: un
  cambio perdido sin aviso es peor que un fallo ruidoso cuando se afina por
  prueba y error.

### Reestructuración — mod de dificultad con 4 configuraciones

- Los tres mods (`Ecosystem`, `PredatorPacks`, `PredatorSenses`) se funden en **un
  solo mod de dificultad** con cuatro variantes en `work/scripts/dificultad/`:
  Fácil, Normal, Difícil y Hardcore. Se instala una sola.
- La configuración **Difícil** equivale exactamente a lo que había: densidad ×20,
  `DANGEROUS` 1000, manadas 3-5, percepción 60, sin huida, 100% hostiles, tope 60.
- **Hardcore** añade manadas 5-7, percepción 80, tope 70 y sube
  `PlayerPredatorBoredomDistance` de 80 a 150 — el único tier que lo toca, para que
  escapar cueste de verdad.
- **Fácil** y **Normal** rebajan todos los ejes de forma proporcional: ×2/×5 de
  densidad, 23%/50% de planetas hostiles, manadas 1-2 y 2-3, y conservan la huida
  por vida baja (30%/15%) que Difícil y Hardcore eliminan.
- Verificado que AMUMSS **no** genera variantes desde un solo script: no existe
  `AUTO_OPTIONS`, y `MOD_BATCHNAME` sirve para combinar, no para variar. De ahí que
  sean cuatro `.lua` independientes, que además es el patrón habitual en Nexus.
- Retirados del árbol de trabajo los scripts superados (`GroundDensity`,
  `PredatorWorlds`, `Ecosystem`, `PredatorPacks`, `PredatorSenses`); quedan en el
  historial de git. `RedFauna` se conserva como feature aparte.
- Añadido `work/scripts/dificultad/README.md` con la tabla comparativa, el
  procedimiento para cambiar de configuración, el conteo de cambios esperado por
  tier y el orden recomendado para aflojar la dificultad.

### Preparación de release

- **Verificado el formato de distribución para NMS 6.x:** se distribuye la carpeta,
  no un `.pak`. Los paks vanilla son `HGPAK`, los que AMUMSS deja en
  `ModBackups\BuildHistory\` son `PSAR` (PSARC, formato antiguo), y los 87 mods
  instalados son carpetas sin un solo `.pak`. Los paks de AMUMSS son residuo legacy.
- Añadido `tools/Package-Release.ps1`: genera un zip por configuración desde
  `CreatedMODS\`, con la carpeta del mod dentro para que se extraiga directamente en
  `GAMEDATA\MODS\`. Excluye el `.lua` fuente y el txt de versión de AMUMSS.
- Añadido `docs/NEXUS.md`: guía de publicación con la checklist previa, la
  estructura de página (un mod con 4 Main Files, no 4 mods), los pasos de subida y
  los textos de título, resumen y descripción en BBCode listos para pegar.
- **Verificada la compatibilidad con Vortex** sobre los 79 zips de Nexus descargados:
  ninguno usa FOMOD y el layout dominante es una sola carpeta raíz con el nombre del
  mod. Vortex copia el contenido del zip tal cual al staging y lo despliega a
  `GAMEDATA\MODS\`, así que el formato que ya genera `Package-Release.ps1` funciona
  sin añadir nada. El único error posible sería dejar los EXML en la raíz del zip.
- Decidido publicar **cerrado**: los `.lua` fuente no se suben (`Package-Release.ps1`
  ya los excluye salvo `-IncluirLua`) y los permisos de Nexus van todos en "No". Los
  EXML son texto plano y siguen siendo editables por quien los descargue — lo que se
  protege es la lógica de los scripts y el derecho a republicar, no los números.

### Mod 2 — Infestación 0.1.0 (en curso)

- **Decisión de producto:** el mod de monstruos es un **mod aparte** con su propia
  página y su propio versionado, empezando en **0.1.0**. No es un 1.1 del mod de
  depredadores: son dos mods distintos. El mod 2 **contiene** al mod 1 (mismos
  archivos, misma calibración por tier), así que se instala uno o el otro, nunca los
  dos.
- El motivo técnico de fundirlos en vez de publicarlos como mods compatibles: los
  globales de Fiend (`FiendMaxAttackers`, `FiendMaxEngaged`, `MaxFiendsToSpawn`,
  `FiendAggroTime`) viven en `GLOBALS\GCCREATUREGLOBALS.MBIN`, que el mod 1 ya
  escribe. Dos mods sobre la misma ruta = un cambio perdido en silencio.
- **Escaneo de conflictos** sobre los 87 mods de terceros instalados: `FIENDEGGS`,
  `INFESTATION` y `CREATUREDATATABLE` están libres. `GCCREATUREGLOBALS` solo lo
  disputa nuestro propio mod 1.
- **Descartado "que las manadas se acerquen a los edificios abandonados".** No existe
  la palanca: el árbol de comportamiento persigue `TARGET`, que es el jugador o una
  presa, nunca una estructura, y los edificios se colocan por otro sistema. La vía
  real para el mismo efecto es sembrar huevos de Fiend por el terreno (§2).
- Añadido `work/scripts/infestacion/` con los 4 tiers y su `README.md`.
- Palancas nuevas por tier: densidad de huevos ×2/×5/×20/×20, `FiendMaxAttackers`
  2/3/4/6, `FiendMaxEngaged` 6/8/10/12, `MaxFiendsToSpawn` 6/8/10/12 y
  `FiendAggroTime` 45/60/90/120. Fácil no escribe ningún global de Fiend a propósito:
  coinciden con vanilla y ensuciarían el EXML delta.
- **Trampa nueva documentada:** cada objeto de `FIENDEGGS`/`INFESTATION` lleva dos
  bloques de densidad. El bueno es `QualityVariants`; debajo hay un
  `QualityVariantData` con `Coverage 0.2`/`FlatDensity 0.5` idéntico en los cinco
  objetos de los dos archivos. Los scripts usan `VALUE_MATCH` para no tocarlo.
  `Coverage` se deja intacto: rango válido desconocido.
- Aplazado a 0.2.0: `CREATUREDATATABLE` (`MinFlurryHits`, `DelayBetweenPounceAttacks`)
  y `AllowSpawnBrood`, que sigue sin verificar qué acepta `SpawnBroodID`.
- Lint con `selene`: 0 errores en los 4 scripts. Los warnings son los mismos que
  produce el mod 1 (variables globales y rutas con `\`), convención de AMUMSS.
- **Sin construir ni probar todavía.** Falta correr `BUILDMOD.bat` por tier.

### Mod 2 — build de los 4 tiers (2026-08-01)

- **Los cuatro tiers construidos.** 0 errores, 0 warnings, 0 notices. Conteos
  23 / 27 / 27 / 28, exactamente los previstos. Deltas verificados propiedad por
  propiedad: densidades, pesos, manadas, globales de depredador y los 4 globales de
  Fiend, con los enteros (`FiendMaxAttackers`, `FiendMaxEngaged`, `MaxFiendsToSpawn`,
  `MaxEcosystemCreaturesNormal`) escritos sin decimales.
- **Bug encontrado y corregido: cascada de reglas** (§10j). Las reglas de un mismo
  archivo se aplican en secuencia, así que en `INFESTATION` la regla de huevos subía
  `0.005 → 0.025` y la del gusano (`VALUE_MATCH "0.025000"`) los volvía a multiplicar.
  `FlatDensity` de los huevos quedaba en 0.125 = **×25** en vez de ×5, y el `REPORT`
  daba 29 cambios en vez de 27.
  - **Solo se manifestaba en Normal.** Con ×2 (0.010) y ×20 (0.100) no había colisión:
    Fácil, Difícil y Hardcore daban el conteo correcto con el mismo script defectuoso.
    Queda como regla que el conteo se comprueba en las cuatro configuraciones.
  - Arreglado invirtiendo el orden: el gusano va primero y los huevos últimos. La
    salida del gusano (`0.025·M` / `0.030·M`) no puede valer 0.005 para ningún M ≥ 1.
- **`BUILDMOD.bat` sí es automatizable** (§10c corregido). Acepta cada prompt como
  flag, así que los 4 tiers se construyen en bucle. Tres requisitos que costaron
  encontrar: `chcp 850` (con 65001 aborta por "Bad Active Code Page"), borrar
  `NoDefaultCurrentDirectoryInExePath` del entorno (si está, `cmd.exe` no resuelve
  ejecutables por nombre desnudo y la build muere con un `[BUG]` de Lua que no apunta
  a la causa), y que ningún proceso tenga el cwd dentro de `CreatedMODS`.
- Anotado que **AMUMSS vacía `CreatedMODS` en cada build**: construir los 4 seguidos
  deja solo el último, hay que archivar cada salida.
- `MODBUILDER\MBINCompiler.exe` y `libMBIN.dll` habían desaparecido; restaurados
  copiando las variantes `.public`. Versión sin cambios: 6.45.0.1.
- Re-escaneo de conflictos sobre los mods instalados: `FIENDEGGS`, `INFESTATION` y
  `CREATUREDATATABLE` siguen libres. `NoDerelictMiniHorrors`, pese al nombre, solo
  toca modelos de slime de fragatas derelictas — sin solape. El único choque sigue
  siendo el mod 1, ahora instalado en su tier Hardcore.
- Añadido `tools/Build-Tiers.ps1`: construye las 4 configuraciones de un mod en una
  pasada, una a la vez, y archiva cada salida en `build\<carpeta>_<fecha>\` con su log
  y su `REPORT`. Imprime el conteo por archivo y el total de cada tier para comparar
  contra la tabla del README. Lleva dentro los tres requisitos de entorno.
  - Resuelve además un hueco de `Package-Release.ps1`: lee de `CreatedMODS`, que
    AMUMSS vacía en cada build, así que con builds tier a tier nunca había más de una
    configuración empaquetable.
- **Desplegado `HorribleTerror_Infestation_4-Hardcore`** para la prueba: 6 EXML delta,
  sin `.lua` ni txt de AMUMSS. El mod 1 se retiró a
  `backups\retirado_2026-08-01_HorribleTerror_Predators_4-Hardcore\` (está empaquetado
  en `releases/1.0.0`, así que volver atrás es copiar y reiniciar).
  Backup de partidas previo: `NMS_saves_2026-08-01_1704_antes-mod2-infestacion-hardcore`.
- **Pendiente: prueba in-game.** Es lo único que falta para cerrar 0.1.0.

### Mod 1 — 1.1.0, repaquetado (2026-08-03)

- El zip de cada configuración pasa a llevar cuatro cosas: la **carpeta del mod**, el
  **`.pak`** de AMUMSS, una carpeta **`Source\` con los 4 `.lua`** y un **`README.txt`**
  generado. Sin cambios de gameplay: los EXML son idénticos a los de 1.0.0.
- `tools/Package-Release.ps1` reescrito. Parámetros nuevos: `-Origen` (permite
  empaquetar desde un archivado de `build\`, no solo desde `CreatedMODS`, que AMUMSS
  vacía), `-Fuentes`, `-Paks`, `-SinPak` y `-TituloMod`. Desaparece `-IncluirLua`: el
  fuente ahora va siempre, pero en `Source\` y no dentro de la carpeta instalable.
- El `README.txt` se escribe en **ASCII a propósito**: `Set-Content -Encoding utf8` de
  PowerShell 5.1 mete BOM, que en un `.txt` se ve como basura en algunos editores.
- **Confirmado por magic bytes que el `.pak` de AMUMSS no es el formato del juego:**
  `50 53 41 52` (`PSAR`, PSARC) frente a `48 47 50 41` (`HGPA`) de los paks vanilla de
  NMS 6.45. Se incluye igualmente por decisión de producto; el `README.txt` y la
  descripción de Nexus dicen que lo que se instala es la carpeta. Para omitirlo:
  `-SinPak`.
- **Eliminadas todas las referencias a `DISABLEMODS.TXT`**: el paso de instalación de
  la descripción de Nexus y la fila de la tabla de verificación de entorno de
  `proyecto_mod_nms_zombies.md` (sustituida por «Carga de mods ✅ habilitada»).
- `docs/NEXUS.md` actualizado: contenido del zip, pasos de instalación sin
  `DISABLEMODS.TXT`, sección nueva de código fuente incluido, y la decisión de
  permisos revisada — 1.0.0 se publicó cerrado, 1.1.0 incluye los `.lua`, así que la
  única protección que queda es la que Nexus hace cumplir.

### Investigación — eclosión por proximidad (2026-08-03)

- Pregunta: que los Fiend salgan del huevo **sin romperlo**, a ~5 m. **En vanilla no
  existe.** El huevo salvaje eclosiona solo al destruirse: la eclosión *es* la
  destrucción (`GcDestructableComponentData.Explosion = FIENDHATCH`).
- El huevo salvaje (`RARERESOURCE\GROUND\FIENDEGG.ENTITY`) tiene 4 componentes:
  scannable, shootable, destructable y física estática. **Ni animación, ni disparador,
  ni percepción.** No hay radio de proximidad que tocar.
- **Encontrado el molde:** el huevo **construible** (`BUILDABLEPARTS\SPACEBASE\FIENDEGG`)
  tiene 7 componentes, incluidos `TkAnimationComponentData` con la animación
  **`IDLENEAR`** — el estado «el jugador está cerca» existe y está animado — y
  `GcAntagonistComponentData` con una percepción `HIVE_MIND` de **`Range 6.0`,
  `XFOV 360`, `Raycast false`**, que es la forma exacta de una proximidad pura.
  `Enemies.Player.Perceptions` está **vacío**: ese es el hueco donde engancharía.
- **Ruta barata que sí funciona hoy:** `GroundWormSpawnerActivateRadius = 100` es un
  spawner activado por cercanía sin romper nada, y el `WORMSPAWNER` ya lo coloca
  `INFESTATION.MBIN`, o sea que ya está dentro del mod 2. Bajarlo a 5-10 da la mecánica
  pedida, con gusano en vez de Fiend. Añadido como punto 5b de la cola de 0.2.0.
- Copiar el componente antagonista al huevo salvaje queda como sesión propia: sería el
  primer `.ENTITY.MBIN` que tocamos y el primer componente que **añadimos** en vez de
  editar un valor, con dos incógnitas (si percibir dispara la eclosión, y que sin
  componente de animación no habría animación de apertura).
- Todo en `docs/COMPORTAMIENTO.md` §8.

### Investigación — comportamiento de las criaturas (2026-08-03)

- Añadido `docs/COMPORTAMIENTO.md`: mapa profundo de las palancas de conducta —
  percepción, acecho, ataques, cadencia y separación entre criaturas. Cubre los 4
  archivos que la gobiernan, los 8 árboles de comportamiento nodo a nodo y una cola
  de trabajo priorizada para 0.2.0.
- **Trampa nueva: los backups de AMUMSS no son vanilla.**
  `tools\AMUMSS\ModBackups\<mod>\*.MBIN` guarda el archivo **ya modificado**. Se
  detectó al leer allí `PredatorPerceptionDistance = 80`, que es nuestro Hardcore.
  Los valores vanilla hay que sacarlos del `.pak` con `hgpaktool`.
  `GCCREATUREGLOBALS` vive en `NMSARC.globals.pak`, no en `NMSARC.Precache.pak`.
- **Dos errores corregidos en `IDEAS.md`:**
  - `AlertTable` no es un sensor hacia el jugador. Sus 4 entradas son
    criatura↔criatura (`Prey←Predator`, `Prey←Drone`…) y ninguna menciona al jugador.
  - Los dueños de `GcCreatureFiendAttackData` no son los que decía. Son `FIEND`,
    `BUGFIEND`, `BUGQUEEN`, `SCUTTLER`, **`SCUTTLER_PET`**, `SLUG`, `MINIFIEND` y
    `MINIDRONE`. No hay ningún bloque de pez. `SCUTTLER_PET` es la mascota del
    jugador: un `REPLACE_TYPE = "ALL"` la tocaría.
- **Resuelta una pregunta abierta: `SpawnBroodID` acepta un ID de grupo.** `BUGQUEEN`
  lo usa en vanilla con `BUGFIENDS` / timer 30 / anim `BIRTHING`. Deja de ser
  especulación y pasa a ser copiar un patrón que el juego ya ejecuta.
- Hallazgos accionables nuevos, todos en `GCCREATUREGLOBALS`: `FiendOnscreenMarkers`
  (marcador de UI sobre el bicho), `FiendPerceptionDistance` 60 (campo aparte del de
  depredador — hoy en Hardcore el Fiend te ve más tarde), `FiendZigZagSpeed`/
  `Strength` a 0 con el Scuttler como referencia funcional, y
  `FiendMinSpawnTime`/`MaxSpawnTime` 0.25/3.0 como ritmo de eclosión.
- Causa del amontonamiento de manadas localizada: `AvoidCreaturesStrength = 0.0` en
  el nodo `MOVE_CLOSE` de los árboles terrestres. Los voladores lo tienen a 1.0, así
  que es deliberado de HG y solo se nota desde que subimos el tamaño de grupo.
- Re-escaneo de conflictos: `CREATUREBEHAVIOURTREES`, `CREATUREDATATABLE`,
  `GCCREATUREGLOBALS` y `CREATUREGENERATIONDATA` siguen sin tocarlas ningún mod de
  terceros.

### Mod 2 — verificación in-game, 0.1.0 cerrada (2026-08-02)

- **Tier Hardcore probado a mano.** Los 13 cambios confirmados jugando:
  - Los 5 nuevos de Fiend: densidad de huevos ×20, densidad del `WORMSPAWNER` ×20,
    `FiendMaxAttackers` 6, `FiendMaxEngaged`/`MaxFiendsToSpawn` 12 y
    `FiendAggroTime` 120 s.
  - Los 8 heredados del mod 1 siguen funcionando dentro del mod 2: densidad ×20,
    `DANGEROUS` 1000, manadas 5-7, percepción 80, sin huida, 100% hostiles, tope 70
    y aburrimiento a 150 m.
- Con esto **0.1.0 queda cerrada por el lado técnico**. Falta solo el material de
  publicación (capturas propias del mod 2 y su página de Nexus).
- Sin regresiones observadas al convivir con los 87 mods de terceros reinstalados.

### Verificación in-game — 2026-07-30

- **Las 4 configuraciones probadas a mano, una por una**, con la carpeta de mods
  **limpia** de los otros 87. Funcionan.
- Versión de NMS de la prueba: **170671** (`Binaries\NMS.exe`), rama Public.
- Con esto queda cerrada la checklist previa de `docs/NEXUS.md` salvo las capturas,
  que es lo único que falta antes de subir.

### Empaquetado — convención de nombres de release (2026-08-07)

- **Los nombres de release pasan a camelCase e inglés**, sin guion bajo y sin el
  ordinal del tier: `HorribleTerror_Predators_3-Dificil` → `horribleTerrorPredatorsHard`.
  El mismo nombre en las cuatro cosas: carpeta instalable, `.pak`, `.lua` de `Source\`
  y zip.
- **La traducción ocurre solo al empaquetar.** Los `.lua` de `work\scripts` y su
  `MOD_FILENAME` se quedan en español con ordinal: ese nombre es el de la carpeta
  desplegada en `GAMEDATA\MODS\` durante el desarrollo, y cambiarlo obligaría a borrar
  y redesplegar cada mod en pruebas.
- `Package-Release.ps1`: función `Convert-ToReleaseName` (corta por `_` y `-`, tira el
  ordinal, traduce por diccionario español→inglés, respeta el CamelCase que ya venga
  bien, pega junto con la inicial en minúscula). Parámetro `-Nombres` para forzar el
  nombre de un mod concreto cuando la traducción no acierte.
- **Un `.lua` por zip**, el de esa configuración. Hasta 1.1.0 iban los cuatro tiers en
  cada zip: invita a que el jugador construya el que no instaló.
- **Revisión de comentarios antes de empaquetar.** El script mira los `.lua` que irían
  a `Source\` y aborta con archivo y línea si alguno trae comentarios — vacía las
  cadenas antes de buscar `--`, para no marcar un guion doble que viva dentro de un
  valor de AMUMSS. Escape: `-PermitirComentarios`.
- Limpieza de la carpeta instalable ampliada: además de `*.lua` y `AMUMSS_v*.txt`,
  ahora también `*.log`, `REPORT*.txt`, `_REPORT_*`, `*.bak`, `Thumbs.db` y
  `desktop.ini`.
- `README.txt`: el bloque «WHAT IS IN THIS ZIP» pasa a descripción en línea aparte
  (con nombres largos la columna alineada se rompía), el bloque del `.pak` desaparece
  cuando se usa `-SinPak`, y la frase de incompatibilidad y la build de NMS salen a los
  parámetros `-Incompatibilidad` y `-VersionNMS` en vez de estar fijas al mod 1.
- Borrada `releases\1.1.0 - copia`, que era el ejemplo a mano de la convención.
- `releases\1.0.0` y `releases\1.1.0` se quedan como están: ya están subidos a Nexus
  con esos nombres. La convención arranca en el siguiente release.
- Verificado sobre `build\infestacion_2026-08-06` y `build\derelict_2026-08-06`: los 4
  tiers y el mod de una sola configuración salen con el nombre correcto, un solo `.lua`
  y sin basura de AMUMSS dentro.
