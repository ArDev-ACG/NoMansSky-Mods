# Publicar en Nexus Mods — guía y textos

Todo lo necesario para subir el mod. Los textos de abajo están listos para copiar y
pegar en la página de Nexus.

---

## ⚠️ Antes de publicar nada

Lista de comprobación. **Cada punto se ha roto al menos una vez en este proyecto.**

- [ ] **Probado in-game.** No "construido sin errores" — jugado. `0 [ERROR] detected`
      no prueba que el mod haga lo correcto; ya nos pasó (§8c del doc de proyecto).
- [ ] **Cada configuración probada por separado**, o al menos Fácil y Hardcore, que
      son los extremos.
- [ ] Anotada la **versión exacta de NMS** contra la que se probó. Sin ese dato no se
      puede diagnosticar nada cuando el juego se actualice.
- [ ] Probado con la carpeta de mods **limpia** de los otros 87, para descartar que
      algo funcione por accidente gracias a otro mod.
- [ ] Capturas hechas. Nexus sin imágenes no lo descarga nadie.

---

## Formato de distribución — VERIFICADO

**Se distribuye la carpeta, no un `.pak`.**

| | Formato |
|---|---|
| Paks vanilla (`PCBANKS\*.pak`) | `HGPAK` |
| `.pak` que genera AMUMSS en `ModBackups\BuildHistory\` | `PSAR` (PSARC, **antiguo**) |
| Los 87 mods instalados en `GAMEDATA\MODS\` | **carpetas. Cero `.pak`.** |

Los `.pak` de AMUMSS son un residuo del flujo pre-6.x. No sirven.

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

## Estructura de la página: 4 archivos, no 4 mods

Un solo mod con **cuatro Main Files**. No cuatro páginas.

| Nexus File | Archivo |
|---|---|
| Main File — 1. Fácil | `HorribleTerror_Predators_1-Facil_v1.0.0.zip` |
| Main File — 2. Normal | `HorribleTerror_Predators_2-Normal_v1.0.0.zip` |
| Main File — 3. Difícil | `HorribleTerror_Predators_3-Dificil_v1.0.0.zip` |
| Main File — 4. Hardcore | `HorribleTerror_Predators_4-Hardcore_v1.0.0.zip` |
| Optional — Scripts AMUMSS | los 4 `.lua`, para otros modders |

En la descripción de cada archivo, poner en la **primera línea** que solo se instala
uno. Es el error de instalación más probable.

`[Inferencia]` Nexus tiene instaladores FOMOD para elegir variante, pero están
pensados para Bethesda y no está claro que funcionen con NMS. Cuatro Main Files es lo
que hacen los mods de NMS con variantes, así que es el camino seguro.

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

[size=5]Installation[/size]

[list=1]
[*]Extract [b]one[/b] zip into [code]No Man's Sky\GAMEDATA\MODS\[/code]
[*]You should end up with [code]GAMEDATA\MODS\HorribleTerror_Predators_<tier>\[/code]
[*]Make sure [code]GAMEDATA\DISABLEMODS.TXT[/code] does not exist
[*]Restart the game — mods only load on startup
[/list]

To switch difficulty, [b]delete the old folder first[/b], then extract the new one.

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
[*]Made with AMUMSS. The source .lua scripts are in the optional files — take them
apart, they're heavily commented.
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

**Permisos a conceder:** conviene ser permisivo. Sugerencia: permitir uso en otros
mods y traducciones con crédito. Es un mod de valores numéricos, no de arte —
bloquearlo no protege nada y solo molesta.

---

## Después de publicar

- [ ] Anotar la versión publicada en `docs/CHANGELOG.md` con la versión de NMS probada.
- [ ] Etiquetar el commit: `git tag v1.0.0`
- [ ] Vigilar los comentarios los primeros días. El fallo más probable que reporten:
      instalar dos configuraciones a la vez.
- [ ] Cuando NMS se actualice, re-buildear y comprobar antes de que lo reporten.
