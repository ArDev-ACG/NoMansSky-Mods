# Changelog

Formato: [Keep a Changelog](https://keepachangelog.com/). Versionado: SemVer.

Cada entrada de release debe anotar la **versión de NMS** contra la que se probó —
los updates del juego rompen mods y sin ese dato no se puede diagnosticar nada.

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
