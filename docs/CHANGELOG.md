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

<!--
## [0.1.0] - AAAA-MM-DD
Probado contra NMS <version>.

### Added
### Changed
### Fixed
-->
