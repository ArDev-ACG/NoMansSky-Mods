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

> 🔴 **SIN VERIFICAR, Y HAY QUE VERIFICARLO: los zips publicados llevan `.EXML` delta, no
> `.MBIN`.** Visto el 2026-09-05 al empaquetar los mods nuevos. Abierto
> `releases\2.1.0\HorribleTerror_Predators_4-Hardcore_v2.1.0.zip`: **cero `.MBIN`**, sólo los
> `.EXML` de `CreatedMODS`, y el de `GCCREATUREGLOBALS` trae **34 marcas `!# CHANGED`** al
> final de línea. Esta misma documentación llama a eso un **informe** —§«Las cuatro trampas»
> de [`README.md`](README.md), y `C5` en [`ACUERDOS.md`](ACUERDOS.md)—, y en esta máquina lo
> que corre son `.MBIN`.
>
> **Lo que NO está probado, y por eso esto no dice «roto»:** que NMS rechace ese delta. El
> `.EXML` a secas sí es un formato válido —**55 de los 88 mods instalados son sólo `.EXML`** y
> funcionan—, pero los suyos van **limpios, sin una sola marca** (comprobado contra *Asteroid
> Ribbons*). La duda es el delta anotado, no el `.EXML`.
>
> **Cómo se cierra, y es media hora:** extraer el zip publicado tal cual en `GAMEDATA\MODS`,
> con la carpeta de mods limpia, arrancar por Steam y mirar si los valores llegan. Si no
> llegan, `Package-Release.ps1` tiene que empaquetar desde `ModBackups` como hace
> [`Package-SinFuente.ps1`](../tools/Package-SinFuente.ps1) —incluido el arreglo de los
> `GLOBALS` que caen en la raíz— y volver a subir los cuatro archivos.
>
> Los ocho zips de la tanda del 05/09 (modelos e Infestation) **no tienen este problema**:
> llevan `.MBIN` y cero `.EXML`. Ver [`NEXUS-BETA.md`](NEXUS-BETA.md).

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
horribleTerrorPredatorsHard_v1.2.0.zip
├── horribleTerrorPredatorsHard\          <- esto es lo que se instala
│   ├── GLOBALS\GCCREATUREGLOBALS.EXML
│   └── METADATA\SIMULATION\ECOSYSTEM\...
├── horribleTerrorPredatorsHard.pak
├── Source\
│   └── horribleTerrorPredatorsHard.lua   <- solo el de ESTA configuración
└── README.txt
```

`tools\Package-Release.ps1` lo hace y de paso quita el `.lua` fuente, el txt de
versión de AMUMSS y los logs, que al jugador no le aportan nada.

---

## Convención de nombres de release

**Los nombres de release van en camelCase y en inglés**, sin guion bajo y sin el
ordinal del tier:

| Carpeta que crea AMUMSS | Nombre de release |
|---|---|
| `HorribleTerror_Predators_1-Facil` | `horribleTerrorPredatorsEasy` |
| `HorribleTerror_Predators_2-Normal` | `horribleTerrorPredatorsNormal` |
| `HorribleTerror_Predators_3-Dificil` | `horribleTerrorPredatorsHard` |
| `HorribleTerror_Predators_4-Hardcore` | `horribleTerrorPredatorsHardcore` |
| `HorribleTerror_Infestation_1-Facil` | `horribleTerrorInfestationEasy` |
| `HorribleTerror_DerelictBugs` | `horribleTerrorDerelictBugs` |

Ese mismo nombre se usa en las cuatro cosas: la carpeta instalable, el `.pak`, el
`.lua` de `Source\` y el zip. Un solo nombre, cero ambigüedad.

**La traducción ocurre solo al empaquetar.** Los `.lua` de `work\scripts` y su
`MOD_FILENAME` siguen en español con ordinal, porque ese nombre es el de la carpeta
desplegada en `GAMEDATA\MODS\` durante el desarrollo: cambiarlo obligaría a borrar y
redesplegar cada mod en pruebas. `Package-Release.ps1` traduce con
`Convert-ToReleaseName` (diccionario español→inglés + camelCase). Si un mod nuevo
sale mal traducido, se fuerza el nombre sin tocar el fuente:

```powershell
.\Package-Release.ps1 -Version 1.2.0 -Nombres @{ "MOD3_MapaGalactico_PRUEBA01" = "horribleTerrorGalacticMap" }
```

### Reglas del zip

- **Un `.lua` por zip**, el de esa configuración y ninguno más. Hasta 1.1.0 iban los
  cuatro tiers en cada zip: invita a que el jugador construya el que no instaló.
- **Nada de basura de AMUMSS** dentro de la carpeta instalable: `AMUMSS_v*.txt`,
  `*.lua`, `*.log`, `_REPORT_*`, `*.bak`, `Thumbs.db`, `desktop.ini`. El script los
  borra del stage antes de comprimir.
- **Los `.lua` se publican sin comentarios.** `Package-Release.ps1` los revisa antes de
  empaquetar nada y aborta si encuentra alguno, con archivo y línea. La explicación de
  un mod vive en `docs\`, no en el fuente. Escape: `-PermitirComentarios`.

`1.0.0` y `1.1.0` se quedan como están: ya están subidos a Nexus con esos nombres. La
convención arranca en el siguiente release **de un mod que no se haya publicado todavía**
— ver la excepción de abajo.

### Excepción — un mod ya publicado no renombra su carpeta

**El mod 1 conserva `HorribleTerror_Predators_<tier>` para siempre.** Está en Nexus desde
1.0.0 y los jugadores lo tienen extraído en `GAMEDATA\MODS\` con ese nombre.

Renombrar la carpeta no da error: da algo peor. Quien actualice extrayendo el zip nuevo se
queda con **las dos carpetas** —la vieja no se borra sola— y las dos escriben los mismos
archivos (`GCCREATUREGLOBALS` + las tablas de ecosistema). NMS carga una y descarta la otra
**sin avisar**, así que el jugador puede seguir jugando los valores de 1.1.0 creyendo que
actualizó. En Vortex sale como un mod distinto y salta el conflicto de archivos. Justo el
fallo que el `README.txt` lleva avisando desde 1.0.0 para el caso de instalar dos tiers.

Con el nombre intacto, extraer encima **sobrescribe** y la actualización queda limpia sin
que el jugador tenga que borrar nada.

**El título de la página sí se puede cambiar** — Nexus lo trata como metadato, no toca lo
instalado. En 2.1.0 pasó a `More Aggressive Predators` sin tocar ni una carpeta.

Se empaqueta forzando los nombres con `-Nombres`:

```powershell
.\Package-Release.ps1 -Version 2.1.0 `
  -Origen "...uild\dificultad_2026-08-18" -Fuentes "...\work\scripts\dificultad" `
  -TituloMod "More Aggressive Predators" `
  -Nombres @{
    "HorribleTerror_Predators_1-Facil"    = "HorribleTerror_Predators_1-Facil"
    "HorribleTerror_Predators_2-Normal"   = "HorribleTerror_Predators_2-Normal"
    "HorribleTerror_Predators_3-Dificil"  = "HorribleTerror_Predators_3-Dificil"
    "HorribleTerror_Predators_4-Hardcore" = "HorribleTerror_Predators_4-Hardcore"
  }
```

El camelCase sigue en pie para lo que **aún no se ha publicado**: Infestation,
DerelictBugs y el mapa galáctico. Esos nacen con el nombre bueno y no arrastran nada.

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
| Main File — 1. Easy | `HorribleTerror_Predators_1-Facil_v2.1.0.zip` |
| Main File — 2. Normal | `HorribleTerror_Predators_2-Normal_v2.1.0.zip` |
| Main File — 3. Hard | `HorribleTerror_Predators_3-Dificil_v2.1.0.zip` |
| Main File — 4. Hardcore | `HorribleTerror_Predators_4-Hardcore_v2.1.0.zip` |

**Desde 1.1.0 los `.lua` fuente sí se suben**, en `Source\`. Es el patrón de muchos
mods de NMS (Asteroid Ribbons, Better Scan Rewards, 10x Industrial Waste). Ver la
sección de permisos al final: cambia la decisión de 1.0.0.

1.1.0 metió los cuatro tiers en cada zip. **Desde 2.1.0 va solo el `.lua` de esa
configuración** — ver la convención de nombres más arriba.

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
More Aggressive Predators
```

**Cambiado en 2.1.0.** Antes era `Horrible Terror - Aggressive Predators`.

⚠️ **El título es lo único que cambia. La carpeta instalable sigue llamándose
`HorribleTerror_Predators_<tier>`** — ver la excepción en la convención de nombres.

## RESUMEN (summary corto)

```
Predators hunt you in packs, spot you from further away, and never flee. Four
difficulty presets, from a light nudge to hardcore. No new assets - it only
retunes values the game already has.
```

## DESCRIPCIÓN (BBCode para Nexus)

> **Corta a propósito.** Lo que explica *por qué* un valor es el que es va al changelog o a
> [`MODIFICACIONES.md`](MODIFICACIONES.md), no aquí. Esta página tiene que leerse en un minuto.

```bbcode
[size=5]What it does[/size]

The predators that hunt [i]you[/i] spawn [b]one at a time[/b] in vanilla, and give up
as soon as they are wounded. This mod sends them in packs, lets them spot you sooner
and keeps them coming. Four presets, from a light nudge to hardcore.

[b]No new assets.[/b] It only retunes numbers the game already ships.

[size=5]How the game builds a hostile planet[/size]

Two steps, and the mod only turns those two dials:

[list=1]
[*][b]The planet rolls an archetype.[/b] One of them is DANGEROUS, and on a DANGEROUS
planet [i]every[/i] ground species is drawn from the two player-predator tables — there
is no peaceful species left to roll. Vanilla gives that archetype roughly a [b]9%[/b]
share of planets.
[*][b]The spawn tables place the creatures.[/b] In the player-hunting tables vanilla
sets minimum and maximum group size to [b]1[/b]. They arrive alone by design, and no
amount of creature density changes that.
[/list]

[size=5]What gets more aggressive[/size]

[list]
[*][b]Ground predators[/b] — the medium and large ones that hunt you. Packs, longer
sight, less retreating, and they lose interest later.
[*][b]Biological Horrors and their brood[/b] — Normal and up. They see further, hold
aggro longer, hatch closer together and hit harder.
[*][b]Sand worms[/b] — Normal and up. They hold until you are almost on top of them,
then erupt.
[*][b]Freighter and derelict nests[/b] — Hardcore only. They react to your torch and
to gunfire.
[*][b]Everything else on the ground[/b] — in numbers only: more fauna per km² and a
higher live-creature cap. Peaceful species stay peaceful.
[/list]

Untouched: flying creatures, water creatures, Sentinels and anything in space.

[size=5]Pick ONE difficulty[/size]

[b]Install a single file.[/b] All four edit the same game files — installing two means
one silently overrides the other.

[code]
Parameter                 Vanilla  1 Easy  2 Normal  3 Hard  4 Hardcore
---------------------------------------------------------------------
Ground fauna density        x1       x2       x3      x20      x20
Hostile-planet chance       9%       9%      27%      99%      99%
Pack size                  1/1      1/2      1/2      3/5      5/7
Detection range (m)         40       45       50       60       80
Flees at % health           40       40       25        0        0
Predators targeting you    50%      50%      60%     100%     100%
Max creatures loaded        40       45       50       60       70
Loses interest at (m)       80       80       80       80      150
[/code]

[b]1. Easy[/b] — vanilla with a nudge. It does [b]not[/b] change which planets are
hostile. More fauna, predators in twos, spotted a little sooner, and they still back
off when wounded.
[b]2. Normal[/b] — about one planet in four is hostile, and the Biological Horrors
start pulling their weight.
[b]3. Hard[/b] — almost every planet, packs of 3-5, and they never run.
[b]4. Hardcore[/b] — packs of 5-7, spotted at 80 m, chased to 150 m, and the nests
smell you coming.

[size=5]Too much? Say so[/size]

[b]2.1.0 tones down Easy and Normal.[/b] Easy no longer changes which planets are
hostile, so the planet your save sits on will not turn on you. Normal goes from half
the galaxy down to about one planet in four. Hard and Hardcore are untouched — if you
picked those, you asked for it.

Balance is the hard part of a mod like this and I only get to play my own save.
[b]If a preset feels overwhelming or plain unfair, post it in the Posts tab[/b]: which
preset, and what happened. That is exactly how 2.1.0 came about.

[size=5]What is in the download[/size]

[code]
HorribleTerror_Predators_<tier>\   <- the mod. This is what you install.
HorribleTerror_Predators_<tier>.pak   legacy single-file build (not needed on 6.x)
Source\                               the .lua build script for THIS preset
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

Every download ships a [code]Source\[/code] folder with the [b].lua build script for the
preset you downloaded[/b] — the other three ship theirs in their own zip. If you want to
see exactly which values change, or build your own numbers, drop the script into AMUMSS's
[code]ModScript\[/code] folder and run [code]BUILDMOD.bat[/code] in FULL mode.

[size=5]Compatibility[/size]

Shipped as partial EXML patches: it claims only the properties it changes, not the
whole file. Which files depends on the preset.

[code]
Easy touches 4:
  METADATA\SIMULATION\ECOSYSTEM\CREATUREGENERATIONDATA.MBIN
  METADATA\SIMULATION\ECOSYSTEM\GROUND\GROUNDTABLEPLAYERPREDATORMED.MBIN
  METADATA\SIMULATION\ECOSYSTEM\GROUND\GROUNDTABLEPLAYERPREDATORLARGE.MBIN
  GLOBALS\GCCREATUREGLOBALS.MBIN

Normal and Hard add 2:
  METADATA\SIMULATION\ECOSYSTEM\CREATUREDATATABLE.MBIN
  METADATA\SIMULATION\ECOSYSTEM\CREATUREBEHAVIOURTREES.MBIN

Hardcore adds 3 more:
  GLOBALS\GCUIGLOBALS.GLOBAL.MBIN
  MODELS\...\INFESTATION\LARGEPILLARSLIME\ENTITIES\LARGEPILLARSLIME.ENTITY.MBIN
  MODELS\...\INFESTATION\MEDIUMHANGSLIME\ENTITIES\MEDIUMHANGSLIME.ENTITY.MBIN
[/code]

Any mod touching a different part of those files should coexist. Incompatible with
anything else that edits creature spawn density, archetype weights or predator globals.

[size=5]Performance[/size]

The only setting with a real cost is the creature cap (40 → 45/50/60/70). If your frame
rate drops, that is the one — step down a tier.

[size=5]Notes[/size]

[list]
[*]Only planets with [b]full[/b] life have ground fauna. That is vanilla, not the mod —
barren planets stay barren.
[*]Planets you have already visited may keep the archetype they were given. Warp
somewhere new to see the change.
[*][b]Vortex users:[/b] install one file through Vortex as usual. Remove any other tier
in Vortex first, or it will warn you about the file conflict.
[*]Built with AMUMSS and MBINCompiler.
[/list]
```

## CHANGELOG de Nexus — 2.1.0

Para el campo *Changelog* de la página. **Aquí sí cabe el detalle**: es donde va a mirar
quien se quejó, y donde se justifica cada número.

```bbcode
[b]2.1.0 — Easy and Normal toned down[/b]

[b]The page is now called More Aggressive Predators.[/b] Same mod, same files, clearer
name. [b]Nothing to do on your side:[/b] the folder inside the zip is still
HorribleTerror_Predators_<tier>, so extract it over your old install and let it
overwrite. Do NOT keep both — a leftover old folder silently overrides the new one.

Answering this, from the Posts tab:
[quote]I really would play with this mod, but for me even on easy, nearly every single
species on the Planet where I last saved the game turn hostile now. That's a little too
much for me.[/quote]

That was not a bug, and it was not the creature count. It was the archetype roll.

[b]Why "every species" turned hostile[/b]
A planet's archetype does not decide [i]how many[/i] hostile creatures it gets. It
decides whether the [b]whole planet[/b] is a predator world. On a DANGEROUS planet the
game draws every ground species from GROUNDTABLEPLAYERPREDATORMED and
GROUNDTABLEPLAYERPREDATORLARGE — the two tables that contain nothing but things which
hunt you. No peaceful species is left in the pool. Vanilla hands that archetype about a
[b]9%[/b] share of planets. Easy pushed it to [b]23%[/b], so roughly one save in four
woke up on a planet that had just been re-rolled into a predator world. Nothing else in
the mod could have produced that sentence.

[b]What changed[/b]
[code]
Setting                        Vanilla   Easy            Normal
--------------------------------------------------------------------
DANGEROUS archetype weight        1      3 -> not set    10 -> 4
  = hostile-planet chance        9%      23% -> 9%       50% -> 27%
Predators targeting you         50%      60% -> 50%      75% -> 60%
Flees at % health                40      30  -> 40       15  -> 25
Ground fauna density             x1      x2  (same)      x5  -> x3
Pack size (min/max)             1/1      1/2 (same)      2/3 -> 1/2
[/code]

Where a preset now matches vanilla the mod [b]stops writing that property at all[/b]
instead of writing the vanilla value — one less thing to collide with other mods. Easy's
patch went from 13 changed properties down to 10.

[b]What Easy is now[/b]
Easy no longer touches planet generation, and no longer touches the
hunt-you/hunt-fauna split. All it does is add fauna, send player-hunting predators in
twos instead of alone, raise detection from 40 to 45 m and lift the live-creature cap
from 40 to 45. The planet your save sits on will not turn on you.

[b]What Normal is now[/b]
About one planet in four is hostile instead of one in two, predators come in twos
instead of trios, there is less extra fauna, and they break off at 25% health instead of
15%. The Biological Horror side of Normal is unchanged.

[b]Hard and Hardcore are untouched.[/b] The same numbers as 2.0.0 — 40 and 61 changed
properties, verified against the build.

[b]If you are on an existing save[/b]
Planets you have already visited may keep the archetype they were given, so a world that
turned hostile under an older version can stay hostile. Warping somewhere new is the
quickest way to see the new odds.

[b]Keep the reports coming.[/b] Which preset, and what happened. That is the whole reason
this version exists.

[b]2.0.0[/b]
[list]
[*]The mod now covers the behaviour of [b]everything that hunts[/b], not just ground
predators: Biological Horrors, their brood, sand worm spawners and — on Hardcore — the
freighter and derelict nests.
[*]Preset descriptions rewritten to talk about behaviour instead of just "predators".
[/list]

[b]1.1.0[/b]
[list]
[*]Added [b]Source\[/b] to every download: the .lua build scripts for all four
configurations, so you can see exactly what is changed or build your own numbers.
[*]Added a README.txt with install notes.
[*]Added the AMUMSS .pak build for reference. You do [b]not[/b] need it — NMS 6.x loads
the unpacked folder, which is what you install.
[*]Cleaned up the install instructions.
[/list]

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
