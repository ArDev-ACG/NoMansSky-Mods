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
- Pendiente: exclusión en McAfee y primer `BUILDMOD.bat`.

<!--
## [0.1.0] - AAAA-MM-DD
Probado contra NMS <version>.

### Added
### Changed
### Fixed
-->
