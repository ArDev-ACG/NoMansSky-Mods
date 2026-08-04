# Publicar en Nexus Mods — guía y textos

Todo lo necesario para subir el mod. Los textos de abajo están listos para copiar y
pegar en la página de Nexus.

---

## ⚠️ Antes de publicar nada

Lista de comprobación. **Cada punto se ha roto al menos una vez en este proyecto.**

- [x] **Probado in-game.** No "construido sin errores" — jugado. `0 [ERROR] detected`
      no prueba que el mod haga lo correcto; ya nos pasó (§8c del doc de proyecto).
- [x] **Cada configuración probada por separado.** Las cuatro, no solo los extremos.
- [x] Anotada la **versión exacta de NMS** contra la que se probó: **170671**
      (leída de `Binaries\NMS.exe`), rama Public. Sin ese dato no se puede
      diagnosticar nada cuando el juego se actualice.
- [x] Probado con la carpeta de mods **limpia** de los otros 87, para descartar que
      algo funcione por accidente gracias a otro mod.
- [x] Capturas hechas. Nexus sin imágenes no lo descarga nadie.
      3 en `Capturas Mod 1\` (fuera de git: `.gitignore` excluye `*.png`).

**Estado (2026-08-03):** las 4 configuraciones verificadas a mano, en limpio, sobre
NMS 170671. Capturas hechas y zips verificados. **Listo para subir.**

### Las capturas que hay

| Archivo | Resolución | Qué demuestra |
|---|---|---|
| `Cap1.png` | 1786×1109 | Densidad y planetas hostiles: ~14 iconos de pata roja de golpe |
| `Cap2.png` | 1920×1200 | Varias especies a la vez con la nave de referencia de escala |
| `Cap3.png` | 1920×1200 | Manada: iconos apilados en columna y un depredador cargando |

Las tres valen y sirven para publicar. Limitaciones anotadas para una tanda futura:
mismo planeta (Xoust) y misma paleta naranja en las tres, ninguna en combate real,
y el HUD del manipulador de terreno metido en la esquina. `Cap1` va a 1786 px de
ancho, así que **no** se usa de imagen principal: esa debe ir a 1920×1080.

---

## Formato de distribución — VERIFICADO

**Se distribuye la carpeta, no un `.pak`.**

| | Formato |
|---|---|
| Paks vanilla (`PCBANKS\*.pak`) | `HGPAK` |
| `.pak` que genera AMUMSS en `ModBackups\BuildHistory\` | `PSAR` (PSARC, **antiguo**) |
| Los 87 mods instalados en `GAMEDATA\MODS\` | **carpetas. Cero `.pak`.** |

Los `.pak` de AMUMSS son un residuo del flujo pre-6.x. **No los carga NMS 6.45.**

Comprobado por magic bytes el 2026-08-03:

| Archivo | Primeros 4 bytes | Formato |
|---|---|---|
| `NMSARC.globals.pak` (vanilla) | `48 47 50 41` | **HGPA** |
| `HorribleTerror_Predators_4-Hardcore.pak` (AMUMSS) | `50 53 41 52` | **PSAR** (PSARC) |

Son formatos distintos, no dos variantes del mismo.

**Aun así, desde 1.1.0 el `.pak` se incluye en el zip** por decisión de producto. Va
suelto en la raíz, junto a la carpeta, y tanto el `README.txt` como la descripción de
Nexus dicen que lo que se instala es **la carpeta**. Riesgo residual asumido: que
alguien meta el `.pak` en `PCBANKS\MODS`, no vea ningún efecto y lo reporte como que el
mod no funciona. Para quitarlo: `Package-Release.ps1 -SinPak`.

El zip debe contener la **carpeta del mod con su nombre dentro**, para que el usuario
extraiga en `GAMEDATA\MODS\` y quede colocada sola:

```
HorribleTerror_Predators_3-Dificil_v1.0.0.zip
└── HorribleTerror_Predators_3-Dificil\
    ├── GLOBALS\GCCREATUREGLOBALS.EXML
    └── METADATA\SIMULATION\ECOSYSTEM\...
```

`tools\Package-Release.ps1` lo hace y de paso quita el `.lua` fuente y el txt de
versión de AMUMSS, que al jugador no le aportan nada.

---

## Compatibilidad con Vortex — VERIFICADO

**No hay que hacer nada.** El layout de arriba ya es el que Vortex espera.

Comprobado sobre los 79 zips de Nexus descargados en
`%APPDATA%\Vortex\downloads\nomanssky\`:

| Comprobación | Resultado |
|---|---|
| Zips que usan instalador FOMOD | **0 de 79** |
| Zips con `.pak` dentro | 2 de 79, ambos de 2019 (flujo viejo) |
| Layout dominante | **una sola carpeta raíz = la carpeta del mod** |

Y en `%APPDATA%\Vortex\nomanssky\mods\` se ve qué hace Vortex con ellos: copia el
contenido del zip **tal cual** al staging y lo despliega a `GAMEDATA\MODS\`. De ahí
salen los `__folder_managed_by_vortex` que hay en la carpeta del juego (§10d del doc
de proyecto).

O sea: si el zip lleva la carpeta del mod en la raíz, Vortex acierta solo. No hace
falta ni `fomod\ModuleConfig.xml`, ni `Vortex.deployment.json`, ni nada. Un zip que
funciona a mano funciona en Vortex.

Lo único a no hacer: **poner los EXML en la raíz del zip** sin carpeta que los
envuelva. Ahí Vortex desplegaría `GAMEDATA\MODS\GLOBALS\…` y NMS no lo carga.

`[Inferencia]` El botón "Mod Manager Download" sale automáticamente porque NMS es un
juego soportado por Vortex; no parece haber forma de desactivarlo desde la página. No
importa — con este layout funciona.

---

## Estructura de la página: 4 archivos, no 4 mods

Un solo mod con **cuatro Main Files**. No cuatro páginas, y sin optional files.

| Nexus File | Archivo |
|---|---|
| Main File — 1. Fácil | `HorribleTerror_Predators_1-Facil_v1.1.0.zip` |
| Main File — 2. Normal | `HorribleTerror_Predators_2-Normal_v1.1.0.zip` |
| Main File — 3. Difícil | `HorribleTerror_Predators_3-Dificil_v1.1.0.zip` |
| Main File — 4. Hardcore | `HorribleTerror_Predators_4-Hardcore_v1.1.0.zip` |

**Desde 1.1.0 los `.lua` fuente sí se suben**, en `Source\`, y los cuatro en cada zip.
Es el patrón de muchos mods de NMS (Asteroid Ribbons, Better Scan Rewards, 10x
Industrial Waste). Ver la sección de permisos al final: cambia la decisión de 1.0.0.

En la descripción de cada archivo, poner en la **primera línea** que solo se instala
uno. Es el error de instalación más probable.

FOMOD descartado: **ningún** mod de NMS de los 79 revisados lo usa. Cuatro Main Files
es la convención del juego, así que es el camino seguro.

---

## Pasos de subida

1. Cuenta en nexusmods.com, sección **No Man's Sky**.
2. *Upload a mod* → categoría **Gameplay** (no Creatures: no cambia criaturas, cambia
   su comportamiento y frecuencia). `[Inferencia]` — revisar qué categoría usan mods
   parecidos antes de decidir.
3. Rellenar título, resumen y descripción con los textos de abajo.
4. Subir los 4 zips como Main Files, con nombres de fila claros (`1. Fácil`, etc).
5. Marcar la versión de NMS probada en el campo de versión o en la descripción.
6. Subir capturas.
7. Permisos: ver sección al final.
8. Publicar.

---

## TÍTULO

```
Horrible Terror - Aggressive Predators
```

## RESUMEN (summary corto)

```
Predators hunt you in packs, spot you from further away, and never flee. Four
difficulty presets, from a light nudge to hardcore. No new assets - it only
retunes values the game already has.
```

## DESCRIPCIÓN (BBCode para Nexus)

```bbcode
[size=5]What it does[/size]

In vanilla, the predators that hunt [i]you[/i] spawn [b]one at a time[/b] — that is
literally how the spawn tables are written. You can crank creature density all you
like and the things that actually attack you still arrive alone.

This mod fixes that, and turns several other dials that all point the same way:

[list]
[*][b]Packs.[/b] Player-hunting predators arrive in groups instead of solo.
[*][b]More hostile worlds.[/b] The game's own DANGEROUS archetype gets a bigger share
of planets. Nothing new is invented — the hostile behaviour already exists, it was
just rare.
[*][b]Sharper senses.[/b] They notice you from further away.
[*][b]No retreat.[/b] Vanilla predators flee at 40% health. Here they don't.
[*][b]All predators target you.[/b] Vanilla splits them between hunting you and
hunting other creatures.
[/list]

[size=5]Pick ONE difficulty[/size]

[b]Install a single file.[/b] All four edit the same game files — installing two means
one silently overrides the other.

[code]
Parameter                 Vanilla  1 Easy  2 Normal  3 Hard  4 Hardcore
---------------------------------------------------------------------
Ground fauna density        x1       x2       x5      x20      x20
Hostile-planet chance       9%      23%      50%      99%      99%
Pack size                  1/1      1/2      2/3      3/5      5/7
Detection range (m)         40       45       50       60       80
Flees at % health           40       30       15        0        0
Predators targeting you    50%      60%      75%     100%     100%
Max creatures loaded        40       45       50       60       70
Loses interest at (m)       80       80       80       80      150
[/code]

[b]1. Easy[/b] — vanilla with a nudge. They still retreat when wounded.
[b]2. Normal[/b] — half the planets are hostile, pairs and trios.
[b]3. Hard[/b] — almost every planet, packs of 3-5, and they never run.
[b]4. Hardcore[/b] — packs of 5-7, spotted at 80 m, chased to 150 m.

[size=5]What is in the download[/size]

[code]
HorribleTerror_Predators_<tier>\   <- the mod. This is what you install.
HorribleTerror_Predators_<tier>.pak   legacy single-file build (not needed on 6.x)
Source\                               the .lua build scripts for all four tiers
README.txt                            install notes
[/code]

[size=5]Installation[/size]

[list=1]
[*]Open [b]one[/b] zip and take the folder [code]HorribleTerror_Predators_<tier>\[/code]
[*]Drop it into [code]No Man's Sky\GAMEDATA\MODS\[/code]
[*]You should end up with [code]GAMEDATA\MODS\HorribleTerror_Predators_<tier>\GLOBALS\[/code]
[*]Restart the game — mods only load on startup
[/list]

To switch difficulty, [b]delete the old folder first[/b], then extract the new one.

[size=5]Source included[/size]

Every download now ships a [code]Source\[/code] folder with the [b].lua build script
for all four configurations[/b]. If you want to see exactly which values are changed,
or build your own numbers, drop one script into AMUMSS's [code]ModScript\[/code]
folder and run [code]BUILDMOD.bat[/code] in FULL mode.

[size=5]Compatibility[/size]

Only touches four files:
[code]
METADATA\SIMULATION\ECOSYSTEM\CREATUREGENERATIONDATA.MBIN
METADATA\SIMULATION\ECOSYSTEM\GROUND\GROUNDTABLEPLAYERPREDATORMED.MBIN
METADATA\SIMULATION\ECOSYSTEM\GROUND\GROUNDTABLEPLAYERPREDATORLARGE.MBIN
GLOBALS\GCCREATUREGLOBALS.MBIN
[/code]

Shipped as partial EXML patches, so it only claims the specific properties it
changes rather than the whole file. Any mod touching a different part of those files
should coexist.

Incompatible with anything else that edits creature spawn density, archetype weights,
or predator globals.

[size=5]Performance[/size]

The only setting with a real cost is the creature cap (40 → 45/50/60/70). If your
frame rate drops, that's the one — step down a tier.

[size=5]Notes[/size]

[list]
[*]Only planets with [b]full[/b] life have ground fauna. That's vanilla, not the
mod — barren planets stay barren.
[*]Existing planets you've already visited may keep their assigned archetype. Warp
somewhere new to see the change.
[*][b]Vortex users:[/b] install one file through Vortex as usual. If you already have
another tier installed, remove it in Vortex first — Vortex will warn you about the
file conflict otherwise.
[*]Built with AMUMSS and MBINCompiler.
[/list]
```

## CHANGELOG de Nexus — 1.1.0

Para el campo *Changelog* de la página. Packaging only, sin cambios de gameplay.

```bbcode
[b]1.1.0[/b]
[list]
[*]Added [b]Source\[/b] to every download: the .lua build scripts for all four
configurations, so you can see exactly what is changed or build your own numbers.
[*]Added a README.txt with install notes.
[*]Added the AMUMSS .pak build for reference. You do [b]not[/b] need it — NMS 6.x
loads the unpacked folder, which is what you install.
[*]Cleaned up the install instructions.
[/list]
[i]No gameplay changes. The mod files are identical to 1.0.0 — you only need to update
if you want the source scripts.[/i]

[b]1.0.0[/b]
[list]
[*]Initial release. Four difficulty configurations, tested in-game on NMS 170671.
[/list]
```

---

## Permisos y créditos

**Assets:** ninguno. El mod no redistribuye contenido de Hello Games — son parches
EXML parciales que solo contienen los valores modificados. Es la práctica estándar de
toda la comunidad de NMS (los 87 mods instalados localmente funcionan así).

**Herramientas a acreditar:**
- AMUMSS — HolterPhylo
- MBINCompiler — monkeyman192

### Decisión: código incluido, permisos restrictivos (cambiado en 1.1.0)

**1.0.0 se publicó cerrado.** Desde **1.1.0 los `.lua` van dentro del zip** en
`Source\`. Los permisos siguen restrictivos: publicar el código no es lo mismo que
autorizar a republicarlo o derivarlo.

Consecuencia honesta del cambio: la protección que quedaba en 1.0.0 —«los `.lua` son
el trabajo de verdad y no se regalan»— **ya no aplica**. Lo único que queda es la
parte que Nexus hace cumplir: si alguien sube un fork, se reporta y lo bajan.

En el formulario de permisos de Nexus (sección *Permissions and credits* de la página
del mod), poner:

| Campo de Nexus | Valor |
|---|---|
| Others can upload this file to other sites | **No** |
| Others can convert this file to work on other games | **No** |
| Others can modify my files and release bug fixes / improvements | **No** |
| Others can use assets from this file without permission | **No** |
| Others can use assets in files that are being sold | **No** |
| Others can earn Donation Points from this file | **No** |

**Límite honesto de esto.** Los EXML son texto plano y ahora los `.lua` también van
dentro. Cualquiera puede abrirlos y cambiar los números en treinta segundos. No se
puede impedir, y ningún formato de NMS lo impediría.

Lo único que consigue la tabla de arriba es dejar por escrito que **no hay permiso para
republicar ni derivar**. Esa parte sí la hace cumplir Nexus.

O sea: "no editable" = no reutilizable ni republicable, no "imposible de tocar".

---

## Después de publicar

- [ ] Anotar la versión publicada en `docs/CHANGELOG.md` con la versión de NMS probada.
- [ ] Etiquetar el commit: `git tag v1.0.0`
- [ ] Vigilar los comentarios los primeros días. El fallo más probable que reporten:
      instalar dos configuraciones a la vez.
- [ ] Cuando NMS se actualice, re-buildear y comprobar antes de que lo reporten.
