# Publicar en Nexus — «Infested - Something Lives Here» (beta)

Una sola página. **Dos Main Files de conducta** —el fuerte sin etiqueta y el Easy— y **cuatro
opcionales de modelo**. La galería, entera de bichos.

Aparte y sin tocar sigue [`NEXUS.md`](NEXUS.md) — el mod 1, *More Aggressive Predators*, que ya
está publicado y **choca** con esta beta.

---

## La idea de la página, en una frase

> **Los modelos son la cara. El Infestation es la columna.**

La página *parece* un mod de criaturas y *funciona* como un mod de juego. El que llega por la
foto del bicho se lleva primero el archivo que hace que ese bicho aparezca.

Por eso los modelos van de opcionales y no al revés: solos son un pack de skins que además
**apenas se ve** —los Horrores son raros en el vanilla—, y quien instale sólo el cry wolf puede
jugar tres horas sin cruzarse uno y dejar un comentario diciendo que no funciona.

### El gancho, para no perderlo de vista al escribir nada

No es «más difícil»: esa categoría está saturada y ahí compites contra veinte mods. Es esto:

> **No Man's Sky ya trae un juego de terror dentro. Casi nadie lo ve.**

Hello Games metió Horrores Biológicos —paren crías mientras pelean, escupen, saltan, anidan en
los cargueros abandonados— y los dejó detrás de una tirada rara. El mod no inventa monstruos:
**coge el terror que ya compraste y lo pone delante.**

Y el momento concreto que se cuenta en un comentario: **el carguero abandonado por fin muerde.**
Ya era el mejor sitio de terror del juego y no pasaba nada; ahora los nidos despiertan con tu
linterna y romper uno te llama a los Horrores encima, en un pasillo, sin sitio donde correr.

---

## Los 8 archivos

| Nexus File | Archivo | Qué es |
|---|---|---|
| **Main File 1** | `infested_v0.9.1.zip` (38 KB) | El fuerte. **Sin etiqueta de nivel** |
| **Main File 2** | `infestedHard_v0.9.2.zip` | El Difícil. **Nuevo en `0.9.2`** |
| **Main File 3** | `infestedNormal_v0.9.2.zip` | El Normal. **Nuevo en `0.9.2`** |
| **Main File 4** | `infestedEasy_v0.9.1.zip` (8 KB) | El Easy. **No se resube**: no cambió |
| Optional 1 | `infestedCryWolf_v0.1.0.zip` (6,1 MB) | Modelo del Horror grande |
| Optional 2 | `infestedWarriorBug_v0.1.0.zip` (6,7 MB) | Modelo de las crías |
| Optional 3 | `infestedSkullCrawler_v0.1.0.zip` (11,4 MB) | Modelo del Horror del carguero |
| Optional 4 | `infestedMarkerEgg_v0.1.0.zip` (3,4 MB) | Modelo de los huevos |

Los **cuatro** de conducta son **excluyentes entre sí**; los cuatro modelos conviven con
cualquiera de ellos y entre ellos. Ninguno de los cuatro convive con *More Aggressive Predators*.

**Sin paquete «todo en uno», y a propósito.** Enviaría los mismos archivos dos veces: quien
instale el combinado y luego un modelo suelto acaba con dos carpetas escribiendo lo mismo y el
juego carga una **en silencio**. Quien quiera todo, descarga lo que quiera — la descripción lo
dice.

**Versión de la página: `0.9.2`**, la de los dos niveles nuevos. El fuerte sigue internamente en
`0.9.1`, el Easy en `0.6.4` y los modelos en `0.1.0`; el campo de versión de Nexus es uno solo.
Es el mismo patrón que el mod 1 en 2.1.0, donde Hard y Hardcore no cambiaron y la página subió
igual. **`infested` e `infestedEasy` no se vuelven a subir**: sus archivos de la `0.9.1` siguen
siendo los buenos.

```powershell
.\tools\Package-SinFuente.ps1 -Grupo infestation -Version 0.9.2 -Solo infestedNormal,infestedHard
.\tools\Package-SinFuente.ps1 -Grupo models      -Version 0.1.0
```

### ⚠️ El nombre de carpeta del fuerte es neutro, y el del Easy no

```
infested        <- el fuerte, SIN nivel en el nombre
infestedEasy    <- el Easy, con su nombre
```

El fuerte es **el techo** y ahí se queda: los dos niveles de la `0.9.2` se metieron *entre* los
dos con carpeta propia —`infestedNormal` e `infestedHard`—, sin tocar las dos carpetas que ya
están extraídas en máquinas ajenas. El Easy es el otro extremo y también es definitivo, por eso
sí lleva nombre propio.

Renombrar una carpeta ya publicada deja **las dos** en `GAMEDATA\MODS` —la vieja no se borra
sola—, escribiendo los mismos archivos, con el juego cargando una sin avisar. Es la excepción que
congeló el nombre del mod 1; ver [`NEXUS.md`](NEXUS.md).

---

## Los dos niveles — qué separa uno del otro

**Comprobado sobre los zips construidos, no sobre el `.lua`:** el Easy toca **6 archivos** y el
fuerte **11**. Los cinco de diferencia son exactamente lo que el Easy promete no tocar.

| Archivo del juego | Easy | Fuerte | Qué se pierde en Easy |
|---|:---:|:---:|---|
| `CREATUREGENERATIONDATA` | ✅ | ✅ | — (densidad; el Easy **no** escribe el peso de planeta hostil) |
| `GROUNDTABLEPLAYERPREDATOR` MED/LARGE | ✅ | ✅ | — (manada) |
| `GCCREATUREGLOBALS` | ✅ | ✅ | El Easy sólo escribe 4 de los ~34 campos |
| `FIENDEGGS` · `INFESTATION` | ✅ | ✅ | — (siembra) |
| `GCUIGLOBALS.GLOBAL` | ❌ | ✅ | **Los marcadores de aviso siguen puestos** |
| `CREATUREDATATABLE` | ❌ | ✅ | **Sin parto en combate, sin rachas de 4-8, sin escupir siempre** |
| `CREATUREBEHAVIOURTREES` | ❌ | ✅ | **No cierran distancia en `Fast` ni dejan de frenar** |
| `*SLIME.ENTITY` ×2 | ❌ | ✅ | **Los nidos del carguero no despiertan con la linterna** |

### Tabla de valores

| | Vanilla | **Easy** | **Fuerte** |
|---|---:|---:|---:|
| Huevos de Horror y nidos de gusano | ×1 | **×2** | **×20** |
| Fauna terrestre por km² | ×1 | **×2** | **×20** |
| **Planetas hostiles** | **9 %** | **9 %** (sin tocar) | **99 %** |
| Manada de depredadores | 1/1 | **1/2** | **5/7** |
| Te detectan a | 40 m | **45 m** | **80 m** |
| Tope de criaturas vivas | 40 | **45** | **70** |
| Horror te detecta a | 60 m | *vanilla* | **120 m** |
| Huye al llegar a % de vida | 40 % | *vanilla* | **0 %** |
| Horrores pegándote a la vez | 2 | *vanilla* | **24** |
| Pare crías mientras pelea | no | *vanilla* | **sí, cada 5 s** |
| Golpes por racha | 2-4 | *vanilla* | **4-8** |
| Alcance del salto | ×1.7 | *vanilla* | **×3.0** |
| Acecho antes de cargar | 4 s | *vanilla* | **0 s** |
| Marcadores de aviso en el HUD | sí | **sí** | **no** |
| El nido del carguero reacciona a la linterna | no | **no** | **sí** |

### 🔴 La razón de que el Easy NO toque el peso de planeta hostil

**Es la lección del mod 1, y costó un release entero.** En 2.1.0 hubo que bajar el Easy porque
llegó esta queja por Nexus:

> «I really would play with this mod, but for me even on easy, nearly every single species on the
> Planet where I last saved the game turn hostile now.»

No era el número de bichos: era el arquetipo. Ese peso **no decide cuántos hostiles hay**, decide
si el **planeta entero** es un mundo de depredadores — toda su fauna terrestre sale de las dos
tablas que te cazan, y no queda ni una especie pacífica en el bombo. Con el Easy del mod 1 en
23 %, casi 1 de cada 4 jugadores cargaba la partida y se encontraba con que el planeta donde
estaba se había re-rodado en contra.

**El Easy de este mod nace ya con esa corrección puesta:** deja el peso en vanilla, o sea 9 %,
el mismo que sin mod. *El mundo en el que ya estás sigue siendo el que dejaste.* Eso va escrito
en su `README.txt` y en la descripción, porque es exactamente la duda que va a tener quien lea la
página.

> ⚠️ **Lo honesto sobre el Easy:** está construido desde el 18/08 y **nunca se ha jugado**. Lo
> que sí está verificado es estructural —qué archivos toca y cuáles no, comprobado sobre el zip—
> y que su build corresponde a su `.lua` (fuente 18/08 21:36, build 21:37). Va dicho en su README
> y en la descripción. Si prefieres no publicar sin medir, se sube sólo el fuerte y el Easy
> espera a una partida.

---

## TÍTULO

```
Infested - Something Lives Here
```

**Elegido el 06/09.** `Infested` es la palabra que la gente escribe en el buscador y la que usan
para esos planetas; `Something Lives Here` es lo que hace que recuerden la página. Insinúa la
criatura sin nombrarla, y mete la página en categoría *criaturas* en vez de *dificultad* — donde
compites contra tres mods y no contra veinte.

> Los nombres de carpeta (`infested…`) **no cambian nunca**, aunque el título sí. Es
> metadato: Nexus lo trata aparte de lo instalado, y ya se cambió una vez en el mod 1 sin
> consecuencias. Los `README.txt` de dentro de los zips sí se alinearon con el título nuevo.

## RESUMEN (summary corto)

```
The horror No Man's Sky already ships, actually showing up. Infested worlds that
are actually infested, abandoned freighters that finally bite back, and four
creatures rebuilt from scratch in Blender. Two gameplay presets - pick one.
Beta: more aggression levels are coming and your reports shape them.
```

## TAGS

Categoría de Nexus: **Creatures** (no *Gameplay*): la página se vende por los bichos y ahí hay
mucha menos competencia. Poner todos los tags que Nexus permita:

```
Creatures · Monsters · Horror · Survival · Gameplay · Immersion
Difficulty · Models · Textures · Fauna · Freighter · Atmosphere
```

## DESCRIPCIÓN (BBCode para Nexus)

```bbcode
[size=5]Something lives here[/size]

No Man's Sky already ships a horror game inside it. Almost nobody sees it.

Biological horrors that spawn brood while they fight you, spit, pounce, and nest inside
abandoned freighters - all of it is in the game already, and all of it is locked behind a roll
you can miss for a hundred hours.

[b]This mod does not invent monsters. It takes the horror you already paid for and puts it in
front of you.[/b]

[size=5]The abandoned freighter finally bites back[/size]

It was always the best horror location in the game - dark corridors, flesh on the walls, that
sound - and nothing ever happened in it.

Now the nests wake to your torch and to your gunfire, and breaking one calls horrors down on
you. In a corridor. With nowhere to run.

[size=5]Two gameplay files. Pick ONE.[/size]

[b]They edit the same game files[/b] - installing both means one silently overrides the other,
and nothing tells you which won. To switch, delete the old folder first.

[b]INFESTED[/b] - the full thing.
Twenty times the horror eggs and the sand worm nests. Predators that hunt in packs, see you from
across the valley and do not stop coming. Horrors that spot you long before you spot them, spawn
brood mid-fight, pounce from far higher ground, spit constantly, and brood that hits as hard as
the parent. Freighter nests that wake up. No warning markers on your HUD. Almost every planet
rolls hostile.

[b]INFESTED - EASY[/b] - the same world, without the teeth.
Twice the eggs, twice the worm nests, twice the ground fauna, predators in twos instead of alone,
and they notice you a little sooner. And that is the whole list: the horrors behave exactly as
vanilla, your HUD markers stay, and the freighter nests stay asleep.

[b]Easy does NOT change which planets are hostile, and that is deliberate.[/b] That is not a
dial for how many dangerous creatures spawn - it decides whether an entire planet is a predator
world. The first release of my predator mod pushed it, and people loaded a save to find the
planet they were standing on had turned against them. Easy leaves it alone. [i]The world you are
already in stays the world you left.[/i]

[b]More aggression levels are coming between these two.[/b] That is part of what this beta is
for - these two are the ends of the range, and what people report here decides where the middle
lands.

[code]
                              Vanilla     Easy      Infested
-------------------------------------------------------------
Horror eggs / worm nests          -      twice    twenty times
Ground fauna                      -      twice    twenty times
Hostile planets                 rare      rare      almost all
Predators hunt in               alone     pairs        packs
They notice you                    -    sooner    much sooner
They give up the chase           yes       yes             no
Horrors spawn brood mid-fight     no   vanilla            yes
Horror reach and flurry            -   vanilla       far more
Stalks before it charges         yes   vanilla    no, it just charges
HUD warning markers              yes       yes             no
Freighter nests wake up           no        no            yes
[/code]

[b]Either file CONTAINS "More Aggressive Predators".[/b] Install one of these or that one, never
both - they write the same files.

[size=5]Four of them get a new face - optional[/size]

Four creatures were rebuilt from scratch in Blender and grafted onto the skeletons the game
already animates. Each is a [b]separate optional download[/b]. Take as many as you like, or none.

[list]
[*][b]Cry Wolf[/b] - the big horror that erupts out of the ground eggs and chases you across the
surface. Now a long-necked quadruped.
[*][b]Warrior Bug[/b] - the smaller brood it spawns while it fights you, the ones that pour out
around it. Now an armoured insect.
[*][b]Skull Crawler[/b] - the one that nests inside abandoned freighters, waiting in the dark
corridors. An original creature.
[*][b]Marker Egg[/b] - the eggs on infested planets, the ones that crack open and bring the
horrors down on you. Now a carved standing monolith.
[/list]

The models change [b]nothing[/b] about behaviour, spawn rates or damage - only how things look.
They stack with each other, with either gameplay file, and with other mods.

[b]They are worth far more with a gameplay file installed.[/b] Horrors are rare in vanilla; the
gameplay file is what puts them in front of you. Models on their own can go a long time unseen.

There is no all-in-one download on purpose: it would ship the same files twice, and a leftover
folder would silently override the new one.

[size=5]This is a BETA - read this part[/size]

[list]
[*][b]Too much? Not enough?[/b] Say which file you took and what you were doing when it went
wrong. That is what decides where the middle levels land.
[*][b]Easy has had far less time in a real save[/b] than the full version. If a number feels
wrong there, that is exactly the report worth making.
[*][b]Horrors still break off and walk away[/b] - and it happens the moment they roar. The roar
is what spawns their brood, so the two are connected. Not solved yet; it is next.
[*][b]Cry Wolf and Warrior Bug have stiff legs.[/b] The lower leg follows the body instead of
planting on the ground. Being worked on.
[*][b]Cry Wolf is taller than what it replaces[/b], so it can clip into low scenery.
[*][b]Warrior Bug's skin reads flat[/b] under some lighting. More texture resolution did not fix
it, so it is a material problem and it is still open.
[*][b]The full file costs frames.[/b] Far more live creatures than vanilla, a lot of them
engaged at once, and brood spawning on top of that. If your frame rate drops, that is where it is
going - Easy costs almost nothing by comparison.
[/list]

[b]Post problems in the Posts tab:[/b] what happened and where you were. Screenshots help more
than anything else.

[size=5]Installation[/size]

[list=1]
[*]Extract the folder inside each zip into [code]No Man's Sky\GAMEDATA\MODS\[/code]
[*]Restart the game - mods only load on startup
[/list]

To uninstall, delete the folder. Never keep two versions of the same file - delete the old folder
first, do not extract alongside it.

[size=5]Credits[/size]

The base models are free to use, including commercially, under their Creative Commons licences.
Each is credited exactly as its licence requires:

[list]
[*]"Cry Wolf Game Character" ([url=https://skfb.ly/6VFUz]link[/url]) by [b]SkinRender[/b],
licensed under [url=http://creativecommons.org/licenses/by/4.0/]CC BY 4.0[/url].
[*]"Warrior bug from 'Starship Troopers'" ([url=https://skfb.ly/o87nr]link[/url]) by
[b]wtf_fox[/b], licensed under [url=http://creativecommons.org/licenses/by/4.0/]CC BY 4.0[/url].
[*]"Marker 1" ([url=https://skfb.ly/6SzLo]link[/url]) by [b]username11420[/b], licensed under
[url=http://creativecommons.org/licenses/by-sa/4.0/]CC BY-SA 4.0[/url]. Because that licence is
ShareAlike, [b]the Marker Egg files stay under CC BY-SA 4.0[/b] - reuse and adapt them as long as
you credit and share alike.
[*]The Skull Crawler is an original model, not derived from anything.
[/list]

All four were remeshed, re-textured and re-rigged for No Man's Sky in Blender.

No Man's Sky (c) Hello Games. Not affiliated with or endorsed by Hello Games, and no Hello Games
assets are redistributed - everything here is a new model, a new texture, or a changed value.

[size=5]Tested on[/size]

No Man's Sky 178763 / 7.0 Cosmos (Public branch). Infested 0.9.1, Easy 0.6.4, models 0.1.0.
```

## CHANGELOG de Nexus

```bbcode
[b]0.9.1 - rebuilt for 7.0 Cosmos[/b]
Rebuilt against NMS 7.0 (build 178763) with MBINCompiler 7.00. No values changed - the 0.9.0
files carried pre-7.0 templates and would not load.

[b]0.9.0 - first public beta[/b]
[list]
[*]Two gameplay files: [b]Infested[/b], tuned at the hard end, and [b]Infested - Easy[/b], which
adds creatures without touching how any of them behave. Install one.
[*]Easy deliberately does not change which planets are hostile - the lesson from the first
release of More Aggressive Predators.
[*]More aggression levels are coming between the two, shaped by what gets reported here.
[*]Four creature models as optional downloads: Cry Wolf, Warrior Bug, Skull Crawler and Marker
Egg. They install side by side with each other and with either gameplay file.
[*]Either gameplay file contains More Aggressive Predators. Do not run both.
[*]Known issues are in the description and in the README inside each zip.
[/list]
```

---

## Galería — 14 capturas, en este orden

En `Capturas Mod 2\`, renombradas y numeradas **por orden de subida**. La `01` es la principal
y **ya está recortada a 1920×1080**. Curado el 06/09: de 26 archivos quedan **14**; las demás
están en `_descartadas\` y `_duplicados\`, por si hace falta volver.

**La tanda del 06/09 cambió la galería entera.** Las seis nuevas son de atardecer, con los
bichos grandes y nítidos en primer plano, y desplazan a casi todas las nocturnas: cinco de las
seis primeras posiciones son de esa tanda.

| # | Archivo | Vende | Qué demuestra |
|---|---|---|---|
| 01 | `01-warriorbug-hero-dusk.jpg` | ⭐ **Principal** | El warrior bug **enorme, a contrapicado**, contra el cielo naranja. La mejor foto del set entero: el bicho ocupa media pantalla y se le ven las bandas. Ya a 1920×1080 |
| 02 | `02-crywolf-pack-charging-dusk.jpg` | ⭐ Cry Wolf + conducta | **Manada de cry wolfs viniendo**, y uno grande y nítido a la derecha. La única que enseña el modelo de cerca **y** que vienen varios |
| 03 | `03-crywolf-full-body-dusk.jpg` | ⭐ Cry Wolf | Silueta completa del cry wolf a plena luz, en carrera, con más bichos al fondo |
| 04 | `04-warriorbug-pack-daylight.jpg` | Warrior Bug + conducta | Día claro, manada. Sigue siendo la de mejor luz de las viejas |
| 05 | `05-warriorbug-profile-dusk.jpg` | Warrior Bug | Perfil limpio, plano medio, carguero al fondo |
| 06 | `06-crywolf-and-warriorbug-dusk.jpg` | los dos | Los dos modelos juntos con la horda detrás. Era la principal; la `01` la superó |
| 07 | `07-crywolf-attacking-player.jpg` | conducta | En combate, con el rojo de daño en pantalla. Vende la agresividad |
| 08 | `08-markeregg-daylight-freighter.jpg` | Marker Egg | **El monolito a plena luz** con un warrior bug al fondo. Es la que faltaba del huevo |
| 09 | `09-markeregg-monolith-closeup.png` | Marker Egg | Monolito de cerca, ya **sin el texto en español** — recortado. Ver la nota de abajo |
| 10 | `10-markeregg-cluster-night-rings.jpg` | Marker Egg | Los monolitos con el planeta anillado detrás. La única con paisaje espacial |
| 11 | `11-freighter-infestation-growth.jpg` | conducta | Carne en el techo del carguero, luz roja. **Es la foto del gancho** |
| 12 | `12-skullcrawler-pair-corridor.jpg` | Skull Crawler | Dos en el pasillo. La mejor del bicho |
| 13 | `13-skullcrawler-corridor-ambush.jpg` | Skull Crawler | Trepando en el pasillo |
| 14 | `14-skullcrawler-nest-wide.jpg` | Skull Crawler | Plano abierto del nido, con la baba verde |

### Lo que queda por hacer antes de subirlas

1. ✅ **La `01` ya está a 1920×1080** — recortados 120 px de abajo, que eran sólo campo de setas.
   El original 16:10 está en `_descartadas-warriorbug-hero-dusk_ORIGINAL-16x10.jpg`.
2. ✅ **La `09` ya no lleva texto en español.** Quedan los iconos del HUD arriba y una franja de
   aberración cromática, que sin texto no molestan. Si se quiere fina del todo, recortar los
   ~40 px superiores.
3. ⚠️ **La `09` es un PNG de 2,9 MB**, doce veces lo que pesa cualquier otra. Pasarla a JPG al
   95 % la deja en ~400 KB sin diferencia visible.
4. Las 13 restantes siguen a **1920×1200 (16:10)**, y eso está bien: Nexus sólo exige 16:9 en la
   principal, las demás se muestran tal cual.

### Qué se descartó, y por qué

**13 archivos a `_descartadas\`** — casi todas nocturnas que las de atardecer dejaron sin
trabajo: las cuatro de relleno (`16-19`), las dos del cry wolf y el warrior bug de noche, dos
skull crawlers redundantes, dos marker eggs oscuros, un carguero repetido y un warrior bug
lejano de la tanda nueva. Más **6 duplicados byte a byte** en `_duplicados\`.

Ninguna se borró. Si en la próxima tanda hace falta una nocturna concreta, sigue ahí.


---

## Permisos — la tabla cambia por juntar modelos y conducta

**No vale la tabla del mod 1**, que va toda a *No*. Aquí se redistribuyen modelos `CC`, la
licencia manda, y **en Nexus los permisos son de la página, no del archivo**: la obligación de
los modelos tiñe también a los archivos de conducta.

| Modelo base      | Licencia            | Qué obliga                                                              |
| ---------------- | ------------------- | ----------------------------------------------------------------------- |
| Cry Wolf         | **CC BY 4.0**       | Crédito + enlace. No deja imponer restricciones extra sobre el original |
| Warrior Bug      | **CC BY 4.0**       | Igual                                                                   |
| Marker 1 (huevo) | **CC BY-SA 4.0**    | Crédito **y** que el derivado salga bajo la misma licencia              |
| Skull Crawler    | propia (AldrichDDD) | Nada                                                                    |

**En el formulario de Nexus:**

| Campo | Valor | Por qué |
|---|---|---|
| Others can upload this file to other sites | **No** | Es el paquete, no el modelo. Nexus lo hace cumplir |
| Others can convert this file to work on other games | **Yes** | Las licencias lo permiten; negarlo sería falso |
| Others can modify my files and release fixes / improvements | **Yes**, con crédito | Obligatorio por el `SA` del huevo |
| Others can use assets from this file without permission | **Yes**, con crédito | Igual |
| Others can use assets in files that are being sold | **Yes** | Las tres permiten uso comercial |
| Others can earn Donation Points from this file | a elección | No lo decide ninguna licencia |

Pegar el bloque de créditos **también** en el campo *Credits*: las atribuciones CC tienen que
estar en la página, no sólo dentro del zip.

**Lo que se cede es poco:** lo que los archivos de conducta «protegían» son valores dentro de un
`.MBIN` que cualquiera lee con MBINCompiler en dos minutos. La protección de verdad ya está
tomada y no depende de esta tabla: **no se publica el `.lua`**.

---

## ⚠️ Los dos peligros que este empaquetado esquiva — y que los releases del mod 1 llevan dentro

Los dos están escritos desde hace tiempo en [`README.md`](README.md) §«Las cuatro trampas», y aun
así se colaron en Nexus. `Package-SinFuente.ps1` los esquiva por construcción.

### 1 · Los `GLOBALS` caen en la raíz

`ModBackups\<mod>\` deja `GCCREATUREGLOBALS.MBIN` y `GCUIGLOBALS.GLOBAL.MBIN` **en la raíz**, no
en `GLOBALS\`. Comprobado el 05/09 contra lo desplegado: **mismo md5, distinta ruta**. Empaquetar
la carpeta tal cual manda los globals a la raíz del mod, el juego no los lee y se pierde **media
conducta sin ningún aviso**. El script los devuelve a `GLOBALS\` y lo dice por consola.

### 2 · El `.EXML` de `CreatedMODS` es un **delta**, no un archivo

Lleva marcas `!# CHANGED` al final de cada línea cambiada. Eso no es XML válido.

| | Qué lleva |
|---|---|
| Release 2.1.0 publicado del mod 1 | **0 `.MBIN`**. Sólo `.EXML`, con **34 marcas `!# CHANGED`** |
| Un mod de tercero que sí carga (*Asteroid Ribbons*) | `.EXML` **limpio, 0 marcas** |
| Lo que corre en esta máquina | `.MBIN` |

Que el `.EXML` valga no está en duda: **55 de los 88 mods instalados son sólo `.EXML`** y
funcionan. Lo que no vale es el **delta anotado**.

> **Hay que comprobarlo en partida antes de tocar la página del mod 1**, y no está hecho: extraer
> el zip publicado en `GAMEDATA\MODS`, arrancar, y ver si los valores llegan.

**En esta tanda no aplica:** los seis zips llevan `.MBIN`, cero `.EXML`.

---

## Comprobado antes de empaquetar — 2026-09-06

- [x] **El zip del archivo fuerte es, ruta por ruta y md5 por md5, lo que el juego está cargando
      ahora.** 11 archivos, contra `GAMEDATA\MODS\HorribleTerror_Infestation_4-Hardcore`. Se
      publica lo que se jugó, no lo que se construyó. Los cuatro de malla, igual, contra sus
      carpetas desplegadas.
- [x] **El Easy toca 6 archivos y el fuerte 11**, comprobado sobre los zips. Los cinco de
      diferencia son exactamente lo que el Easy promete no tocar — UI, `CREATUREDATATABLE`, árbol
      de conducta y los dos nidos del carguero. Es una verificación estructural de lo que dice su
      README, no una promesa.
- [x] **Ni un `.lua`, ni un `.EXML`.** 52 archivos en los seis zips: 46 binarios del juego y 6
      `README.txt`.
- [x] **Sin datos personales.** Barridos los 52 —binarios incluidos— buscando usuario de Windows,
      correo, rutas `C:\Users\…`, nombre del repo, `ModScript`, `PRUEBA` y marcas de herramienta.
      **Cero.**
- [x] **Todo en inglés.** Barrido de `hardcore`, `dificil` y `facil`: cero aciertos.
- [x] Los `README.txt` llevan la cabecera `SOMETHING LIVES HERE`, alineada con el título.
- [x] Capturas: curadas el 06/09 — **14 finales** de 26, la principal ya a 1920×1080 y sin texto en español en ninguna.
- [ ] ⚠️ **El Easy nunca se ha jugado.** Construido el 18/08, fuente del 18/08 21:36 y build
      21:37. Va dicho en su README y en la descripción.

### Lo que NO se publica, y por qué

- **Los `.lua`.** Es la receta: qué archivo del vanilla se injerta, el `--bind`, el reparto de
  peso, y en el archivo fuerte 25 KB de `MOD_DESCRIPTION` con el razonamiento entero.
  **Límite honesto:** los `.GEOMETRY` y `.DDS` que sí viajan **son** los modelos, y cualquiera con
  MBINCompiler y NMSDK los importa. Quitar el `.lua` esconde el método, no la malla.
- ~~**`2-Normal` y `3-Dificil`.**~~ **Se publican desde la `0.9.2`** (2026-09-10), ya no en
  0.6.4 y 0.5.0 sino puestos al día y escalados entre el Easy y el fuerte. Siguen **sin jugarse**;
  a diferencia del Easy, **eso no se dice en su `README.txt` ni en la descripción** — decidido el
  10/09. Sus `KNOWN ISSUES` hablan sólo de dónde cae el nivel y de lo que cuesta en FPS.
- **Los 30 cambios del `LSYSTEM`** (huevos dentro de los edificios abandonados): están escritos y
  **no funcionan**. No se mencionan en la página.

---

## Los niveles intermedios — llegaron en la `0.9.2` (2026-09-10)

1. ✅ Entradas nuevas en `$MODS` de
   [`../tools/Package-SinFuente.ps1`](../tools/Package-SinFuente.ps1), `infestedNormal` e
   `infestedHard`, con nombre propio y **sin tocar** `infested` ni `infestedEasy`: son los dos
   extremos y sus carpetas ya están en manos de la gente.
2. ✅ Reconstruidos contra el `.lua` del momento: se les bajaron, escaladas, las palancas de la
   `0.7.0`, la `0.8.0` y la `0.9.0` que sólo tenía el Hardcore. La tabla de a cuánto queda cada
   una está en [`CHANGELOG-MOD2.md`](CHANGELOG-MOD2.md), entrada `0.9.2`.
3. ❌ **No se han jugado**, ni uno ni otro, y **eso no va en la página**: decidido el 10/09, al
   revés que con el Easy. Lo que reporten los Posts es lo que decide si se mueven.
4. Dónde caen exactamente lo sigue diciendo el hilo de Posts, no el criterio de casa.
