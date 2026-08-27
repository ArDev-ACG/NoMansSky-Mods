# Changelog — Mod 3: Mapa Galáctico a Pie

Formato: [Keep a Changelog](https://keepachangelog.com/). Versionado: SemVer.

Este mod se versiona **aparte** de los mods 1 y 2, y arranca en `0.1.0`. No comparte
ningún archivo con ellos: los mods 1 y 2 tocan fauna y ecosistema, éste toca UI,
interacciones y construcción de bases. **Se pueden llevar los tres a la vez.**

- Mod 1 (Predators) y proyecto: [`CHANGELOG.md`](CHANGELOG.md)
- Mod 2 (Infestation): [`CHANGELOG-MOD2.md`](CHANGELOG-MOD2.md)

> **Nombre provisional.** `HorribleTerror_*` es la marca de los mods de monstruos y esto
> no tiene nada que ver con horror. Pendiente de decidir antes de la primera build.

---

## [No publicado] — investigación del 2026-08-04

Investigado contra NMS **170671** (rama Public), MBINCompiler 6.45.0.1.
**No hay nada construido ni desplegado todavía.** Esta entrada solo registra lo que se
ha leído de los archivos del juego y qué rutas quedan abiertas.

### Objetivo

Poder abrir el mapa galáctico **estando a pie en un planeta**, sin nave y sin carguero.
Solo para **navegar y mirar**: ver sistemas, leer economías, marcar destino. **No** para
saltar ni viajar desde ahí.

Dos rutas planteadas, en este orden:

- **A.** Que se abra desde el menú, como una opción más.
- **B.** Si A no sale, un **objeto construible** que haga de terminal, copiando el mapa
  galáctico del puente del carguero.

### Cómo se extrajo lo de abajo

Los `.pak` de `PCBANKS` se desempaquetaron con `hgpaktool.exe` y los `.MBIN` se
decompilaron con `MBINCompiler.exe`. Los dos `.pak` que importan aquí:

| pak | MB | qué tiene |
|---|---:|---|
| `NMSARC.Precache.pak` | 5,5 | las tablas de construcción y **todos** los `.ENTITY.MBIN` |
| `NMSARC.globals.pak` | 0,6 | `GCUIGLOBALS.GLOBAL.MBIN` |

> El filtro `-f` de `hgpaktool` sigue sin funcionar (ya pasó en el mod 2). Hay que
> desempaquetar el pak entero. `Precache` es pequeño, no duele.
>
> Ojo: este MBINCompiler escribe **`.MXML`**, no `.EXML`.

### Ruta A — abrirlo desde el menú rápido · **BLOQUEADA** (mal cerrada, ver [RUTA E](#no-publicado--ruta-e-2026-08-04))

**No se puede con AMUMSS.** No existe ningún `.MBIN` que liste las entradas del menú
rápido. Lo que hay:

| Archivo | Qué contiene de verdad |
|---|---|
| `GLOBALS\GCUIGLOBALS.GLOBAL.MBIN` | Solo **medidas y tiempos**: `QuickMenuCentrePos`, `QuickMenuAlpha`, `QuickMenuScreenWidth`, `QuickMenuCloseTime`, colores del ítem seleccionado… **Ni una sola entrada de menú.** |
| `UI\HUD\HUDQUICKMENUSLOT.MBIN` | `cGcNGuiLayerData`, 3821 líneas. Es el **aspecto de una casilla** del menú, no la lista de casillas. |
| `UI\HUD\HANDCONTROLS\QUICKMENULAUNCHER.MBIN` | Ídem, `cGcNGuiLayerData`, 7502 líneas. Layout. |

Qué entradas aparecen y **en qué contexto** aparecen se decide en el ejecutable. No hay
dónde escribir.

**Detalle que confirma el diagnóstico:** existe la textura
`TEXTURES\UI\FRONTEND\ICONS\QUICKMENU\GALAXYMAP.DDS`. O sea, el juego **ya tiene** una
entrada de mapa galáctico en el menú rápido — la usa en su contexto (nave / carguero).
El icono está hecho y listo. Lo que no se puede tocar desde datos es la condición que
decide cuándo se enseña. Modificar eso pide parchear el binario, que está fuera del
alcance de este proyecto.

**Conclusión: la ruta A se cierra.** No se descarta por difícil, se descarta porque no
hay archivo de datos que editar. La ruta B pasa a ser la principal, no el plan B.

### Ruta B — objeto construible · **VIABLE EN PAPEL**

Aquí sí hay dónde escribir, y las tres piezas necesarias existen y están localizadas.

**Pieza 1 — la interacción ya existe como valor de enum.**

`MODELS\COMMON\SPACECRAFT\COMMONPARTS\HANGARINTERIORPARTS\BRIDGETERMINAL\ENTITIES\GALAXYMAPTERMINAL.ENTITY.MBIN`
es el terminal del puente del carguero, justo el que pidió copiar. Dentro:

```xml
<Property name="Components" value="GcInteractionComponentData">
    <Property name="InteractionAction" value="PressButton" />
    <Property name="InteractionType" value="GcInteractionType">
        <Property name="InteractionType" value="FreighterGalacticMap" />   <-- LA CLAVE
    </Property>
    <Property name="UseIntermediateUI" value="false" />
    ...
    <Property name="InteractDistance" value="5.000000" />
    <Property name="InteractAngle" value="360.000000" />
    <Property name="UseInteractCamera" value="true" />
```

`FreighterGalacticMap` es un valor válido de `GcInteractionType`. El mismo valor aparece
en `...\HANGARPARTS\BRIDGE\BRIDGE\ENTITIES\FREIGHTERGALAXYMAP.ENTITY.MBIN`. **Dos usos
independientes**, así que no es un valor huérfano.

**Pieza 2 — las piezas construibles se declaran en datos, con su modelo.**

`METADATA\REALITY\TABLES\BASEBUILDINGPARTSTABLE.MBIN` — cada `GcBaseBuildingPart` mapea
un ID a un `.SCENE.MBIN`:

```xml
<Property name="Parts" value="GcBaseBuildingPart" _id="_NOISEBOX">
    <Property name="ID" value="_NOISEBOX" />
    ...
    <Property name="Filename" value="MODELS/.../BUILDABLEPARTS/TECH/NOISEBOX.SCENE.MBIN" />
```

**Pieza 3 — dónde se puede construir cada cosa es un booleano.**

`METADATA\REALITY\TABLES\BASEBUILDINGOBJECTSTABLE.MBIN` — **1997 entradas**
`GcBaseBuildingEntry`. Cada una lleva:

```xml
<Property name="Objects" value="GcBaseBuildingEntry" _id="FRE_ROOM_FLEET">
    <Property name="ID" value="FRE_ROOM_FLEET" />
    <Property name="PlacementScene">  <Property name="Filename" value=".../ROOM_FLEET_PLACEMENT.SCENE.MBIN" />
    <Property name="BuildableOnPlanetBase"    value="false" />   <-- aquí se decide
    <Property name="BuildableOnSpaceBase"     value="false" />
    <Property name="BuildableOnFreighter"     value="true"  />
    <Property name="BuildableInShipStructural" value="false" />
    <Property name="ShowInBuildMenu"          value="true"  />
    <Property name="Groups"> ... <Property name="Group" value="FREIGHTER_TECH" />
```

Es decir: **qué se puede plantar en una base planetaria es un campo editable**, exactamente
del tipo que los mods 1 y 2 ya saben tocar. `IsFromModFolder` incluso sugiere que Hello
Games contempla entradas metidas por mods.

### Lo que NO está confirmado

Todo lo de arriba es leer archivos. Lo que **no** se sabe:

- **Si `FreighterGalacticMap` funciona fuera del carguero.** El juego puede exigir
  contexto de carguero para abrir ese mapa. Hay indicios de acoplamiento: `GCUIGLOBALS`
  tiene `DelayBeforeHidingHangarAfterGalaxyMap` y `DelayBeforeShowingHangarIntoGalaxyMap`
  — el mapa del puente **esconde el hangar** al abrirse. En un planeta no hay hangar que
  esconder. Puede no pasar nada, puede abrir con la cámara rota, puede colgarse.
  **Ésta es la incógnita que decide si el mod existe o no.**
- **Si el mapa deja saltar.** El objetivo es solo navegación. A pie no hay nave, así que
  lo más probable es que el "warp" ni se ofrezca y quede en marcar destino — que es justo
  lo pedido. Pero si el juego intenta warpear sin nave, puede quedarse colgado. **Hay que
  probarlo con el save de pruebas, no con la partida buena.**
- **Si hace falta un modelo nuevo.** Puede que no: se puede apuntar a una `.SCENE` que ya
  existe. Un modelo propio es trabajo aparte y solo tiene sentido cuando la interacción
  esté probada.

### Precedente que se buscó y **no** apareció

Se comprobó si alguna pieza construible en planeta usa ya una interacción de carguero,
que sería la prueba de que el juego no las bloquea por contexto:

| Entrada | Interacción | `BuildableOnPlanetBase` |
|---|---|---|
| `NPCFRIGTERM` (terminal del capitán de fragatas) | `FleetCommandPost` | `false` |
| `FRE_ROOM_FLEET` (sala de mando de flota) | — sala completa | `false` |

Las dos son **exclusivas de carguero**. No hay precedente. Eso no dice que sea imposible;
dice que **nadie lo ha hecho por nosotros** y que la primera prueba es de verdad una prueba.

### Plan

El orden importa: cada paso es barato y responde una pregunta que decide el siguiente.

1. **Prueba de fuego, sin assets nuevos.** Coger una pieza que ya se construye en un
   planeta y que tenga componente de interacción, y cambiarle el `InteractionType` a
   `FreighterGalacticMap`. Un solo campo, un solo archivo. Construir, plantar, pulsar.
   - Responde la única pregunta que importa: **¿se abre el mapa a pie o no?**
   - Candidato de sacrificio: el módulo de mensajes (`MESSAGEMODULE`, interacción
     `MessageModule`) — se pierde una baliza en el save de pruebas y no pasa nada.
   - Si no se abre: el mod se para aquí y se anota el resultado. Sin dar vueltas.
2. **Si se abre:** ver qué se puede hacer dentro. ¿Marca destino? ¿Ofrece saltar? ¿La
   cámara vuelve bien al salir? Aquí se decide si hace falta capar algo.
3. **Pieza propia.** Entrada nueva en `BASEBUILDINGOBJECTSTABLE` con
   `BuildableOnPlanetBase = true`, su `GcBaseBuildingPart`, y coste en
   `BASEBUILDINGCOSTSTABLE`. Ya sin tocar piezas existentes.
4. **Modelo.** Reusar la `.SCENE` del terminal del puente si el juego la carga fuera del
   carguero; si no, apuntar a una `.SCENE` de decoración que ya exista en planeta.
   Un modelo hecho a mano es lo último, no lo primero.
5. **Tiers.** Los mods 1 y 2 tienen cuatro configuraciones. Aquí probablemente **no hace
   falta**: esto se tiene o no se tiene. Decisión abierta.

### Rutas del juego que tocaría este mod

Ninguna coincide con las 8 del mod 2. **Cero conflicto con los mods 1 y 2.**

```
METADATA\REALITY\TABLES\BASEBUILDINGOBJECTSTABLE.MBIN
METADATA\REALITY\TABLES\BASEBUILDINGPARTSTABLE.MBIN
METADATA\REALITY\TABLES\BASEBUILDINGCOSTSTABLE.MBIN
MODELS\...\BUILDABLEPARTS\<pieza>\ENTITIES\<pieza>.ENTITY.MBIN
```

**Sin escanear todavía** contra los 87 mods de terceros instalados. Las tablas de
construcción son terreno **muy** disputado — mucho más que el ecosistema. Hay que escanear
antes de la primera build, no después.

### PRUEBA 01 — construida y desplegada · **NO LLEGÓ A PROBARSE**

Script: [`../work/scripts/mapa/MOD3_MapaGalactico_PRUEBA01.lua`](../work/scripts/mapa/MOD3_MapaGalactico_PRUEBA01.lua)

Es el paso 1 del plan. **No es un mod publicable**, es un experimento de un campo.
Le cambia la interacción al **Módulo de Mensajes** —pieza que se construye en cualquier
base planetaria, `IsPlaceable = true` y `BuildableOnPlanetBase = true` en
`BASEBUILDINGOBJECTSTABLE`— para que abra el mapa galáctico:

```
MODELS\...\BUILDABLEPARTS\TECH\MESSAGEMODULE\ENTITIES\MESSAGEMODULE.ENTITY.MBIN
    InteractionType   MessageModule -> FreighterGalacticMap
```

**Trampa resuelta: dos propiedades se llaman igual.** Dentro del bloque de interacción,
`InteractionType` está anidada — la de fuera es el envoltorio y su valor es el nombre del
tipo (`GcInteractionType`), la de dentro lleva el valor real. Y `SecondaryInteractionType`
repite la pareja con valor `None`. Anclar con `PRECEDING_KEY_WORDS` o `SPECIAL_KEY_WORDS`
habría dejado el cursor justo antes del **envoltorio**, y escribirle `FreighterGalacticMap`
rompe el tipo del nodo. Se resolvió con `VALUE_MATCH = "MessageModule"`, el mismo idioma
que ya se usaba en el mod 2 para los bloques de densidad.

Build: **1 CHANGE, 0 errores.** Desplegado y verificado leyendo el EXML de `GAMEDATA\MODS`:

```xml
<Property name="InteractionType" value="GcInteractionType">
  <Property name="InteractionType" value="FreighterGalacticMap" /> !# CHANGED
</Property>
```

El envoltorio **sin** marca de cambio, `SecondaryInteractionType` intacta. Es exactamente
el delta que se buscaba.

Convive con `HorribleTerror_Infestation_4-Hardcore`, que sigue desplegado: rutas distintas.

> **Incidencia de tooling.** `Build-Tiers.ps1` solo borra de `ModScript\` los `.lua` cuyo
> nombre coincide con los de la carpeta que se está construyendo. El
> `HorribleTerror_Infestation_4-Hardcore.lua` de la sesión anterior seguía ahí y AMUMSS lo
> construyó también, así que el conteo agregado del script salió mezclado (`1 + 5 + 2 + …`).
> El mod 3 en sí salió limpio — se verificó leyendo su EXML, no el conteo. `ModScript\`
> quedó limpio. **El filtro debería borrar todos los `.lua`, no solo los que coinciden.**

### Lo que se observó in-game con la PRUEBA 01

El Módulo de Mensajes se construye, pero **no aparece ningún botón que pulsar**.

Primera lectura, que resultó equivocada: «la edición llegó y el juego no ofrece
`FreighterGalacticMap` a pie». Falsa, porque la edición **nunca llegó al juego**. Ver abajo.

### Lo que estaba mal: el despliegue no desplegaba nada

Al preparar la PRUEBA 02 se miró qué había de verdad en `GAMEDATA\MODS` y apareció esto:

```
GAMEDATA\MODS\MOD3_MapaGalactico_PRUEBA01\
    MODELS\...\MESSAGEMODULE.ENTITY.EXML      566 bytes
```

566 bytes. El ENTITY vanilla son 2820 bytes de MBIN. Lo que se estaba copiando al juego
era el **EXML delta que AMUMSS escribe en `CreatedMODS\`**, que no es un archivo de juego:
es un informe. Solo lleva las propiedades que cambiaron, con marcas `!# CHANGED` dentro:

```xml
<Data template="cTkAttachmentData">
  <Property name="Components">
    <Property name="Components" value="GcInteractionComponentData">
      <Property name="GcInteractionComponentData">
        <Property name="InteractionType" value="FreighterGalacticMap" /> !# CHANGED
```

Ningún esquema de carga puede consumir eso. **No hay ni un solo `.pak` en todo
`GAMEDATA\MODS`**, y nuestros mods no dejaron ahí ni un `.MBIN`.

Dónde están los artefactos de verdad, que es lo que no se sabía:

| Carpeta de AMUMSS | Qué tiene | ¿Sirve? |
|---|---|---|
| `CreatedMODS\<mod>\` | EXML **delta**, legible, para revisar el cambio | **No.** Es el informe |
| `ModBackups\<mod>\` | los `.MBIN` completos y parcheados | **Sí** |
| `ModBackups\________________BuildHistory\<mod>.pak` | el `.pak` | **Sí** |

El paso 4 del README (*«copiar el resultado a GAMEDATA\MODS»*) apuntaba a `CreatedMODS`.
De ahí sale el EXML delta. **Hay que copiar desde `ModBackups\<mod>\`, o el `.pak`.**

**Consecuencia para la PRUEBA 01: no es un resultado negativo, es un no-resultado.** La
ruta B no queda descartada; queda *sin probar*. La pregunta de si `FreighterGalacticMap`
funciona fuera del carguero sigue abierta y es barata de repetir ahora que el despliegue
está resuelto.

**Consecuencia fuera del mod 3:** `HorribleTerror_Infestation_4-Hardcore` está desplegado
igual — 8 EXML, 0 MBIN. Casi con seguridad tampoco estaba activo. Habría que redesplegarlo
desde `ModBackups\` y volver a mirar lo que se dio por verificado.

> El EXML delta sigue siendo la herramienta buena para **verificar** un cambio antes de
> desplegar. Lo que no es, es el archivo que se copia. Son dos cosas distintas y se
> estaban usando como si fueran una.

---

## [No publicado] — RUTA C, 2026-08-04

### Por qué hay una ruta C

Con la ruta A cerrada (no hay dónde escribir) y la B sin probar, se buscó una tercera vía
por si la interacción resultaba estar cerrada de verdad. Apareció algo mejor que las dos.

En `libMBIN` 6.45 existe esta clase de recompensa:

```xml
<Property name="Reward" value="GcRewardForceOpenGalaxyMap">
  <Property name="GcRewardForceOpenGalaxyMap">
    <Property name="BlockWarp" value="false" />
  </Property>
</Property>
```

Verificada compilando y descompilando: **existe, es autorable y tiene un solo campo,
`BlockWarp`**. Es literalmente «abre el mapa galáctico y opcionalmente no dejes saltar»
— el objetivo del mod 3 escrito por Hello Games. **No la usa nadie** en el `REWARDTABLE`
vanilla.

### Cómo se dispara desde una pieza plantada en el suelo

```
pieza construible
  -> StartMissionOnUse          (campo de GcInteractionComponentData)
  -> misión de un solo stage    (GcMissionSequenceReward)
  -> GcRewardForceOpenGalaxyMap, BlockWarp = true
```

Las tres piezas están verificadas en datos vanilla:

| Pieza | Prueba |
|---|---|
| `StartMissionOnUse` funciona **a pie y en planeta** | `CRASHEDFREIGHTER_DISTRESSSIGNAL` → `FREIGHTER_DIG`, `CRYOCHAMBERPOD` → `DROPPDOD_GUIDE`, `ROBOTBASE\TERMINAL` → `ROBOT_CAMP`. No es un campo de carguero ni de nave |
| `GcMissionSequenceReward` | stage de misión que entrega una recompensa. Plantilla: `SPECIALS_REWARD` en `DEBUGMISSIONTABLE` |
| `STARTEDONUSEMISSIONTABLE.MBIN` | la tabla donde viven las misiones que arrancan con `StartMissionOnUse` |

**No hace falta tocar `REWARDTABLE`.** Una `GcGenericMissionSequence` lleva su propio
bloque `Rewards` con entradas `GcGenericRewardTableEntry` dentro, así que la recompensa
vive **dentro** de la misión. Eso saca del mod el archivo más disputado que había en el
plan. Ruta C se queda en **dos archivos**, ninguno terreno caliente.

También apareció `MODMISSIONTABLE.MBIN`, vacía en vanilla (168 bytes,
`<Property name="Missions" />`): el hueco que Hello Games dejó para misiones de mods. No se
usa aquí porque `STARTEDONUSEMISSIONTABLE` es la que está **probada** para este disparador,
y esto es un experimento: no toca gastar el ciclo en averiguar si la otra vale.

### PRUEBA 02 — construida, desplegada y verificada · **NEGATIVA in-game**

Script: [`../work/scripts/mapa/MOD3_MapaGalactico_PRUEBA02.lua`](../work/scripts/mapa/MOD3_MapaGalactico_PRUEBA02.lua)

```
MODELS\...\MESSAGEMODULE\ENTITIES\MESSAGEMODULE.ENTITY.MBIN
    StartMissionOnUse    ""  ->  "MOD3_GALMAP"
    InteractionType      SIN TOCAR (MessageModule) -- el botón tiene que existir

METADATA\SIMULATION\MISSIONS\TABLES\STARTEDONUSEMISSIONTABLE.MBIN
    + misión MOD3_GALMAP, un stage GcMissionSequenceReward
    + recompensa interna R_MOD3_GALMAP = GcRewardForceOpenGalaxyMap, BlockWarp = true
```

**Validado antes de construir.** El bloque de misión se inyectó a mano en una copia de
`STARTEDONUSEMISSIONTABLE.MXML` y se pasó por MBINCompiler: MXML → MBIN compila, y el
round-trip MBIN → MXML sale limpio (10 misiones: 9 vanilla + 1, `BlockWarp = true` intacto,
IDs sin truncar). O sea que el XML era estructuralmente válido *antes* de que AMUMSS lo
tocara — si la build fallaba, el problema era el anclaje, no el bloque.

**Anclaje.** `ADD_OPTION = "ADDbeforeSECTION"` sobre `SPECIAL_KEY_WORDS
{"MissionID","SENTINEL_CRASH"}` — par que aparece una sola vez en el archivo (verificado).
Mete la misión como primer hijo de `<Property name="Missions">` sin contar líneas a mano,
que es justo como se rompen estas cosas.

Build: **1 CHANGE + 1 ADD (líneas 5–536), 0 errores.** El resumen de AMUMSS dice
«1 CHANGE(s)» porque los `ADD` los cuenta aparte; el REPORT muestra las dos acciones.

**Desplegado como MBIN, no como EXML**, y verificado leyendo de vuelta desde
`GAMEDATA\MODS\MOD3_MapaGalactico_PRUEBA02\`:

```xml
<Property name="InteractionType" value="MessageModule" />     <- intacto, el botón sigue
<Property name="StartMissionOnUse" value="MOD3_GALMAP" />
<Property name="BlockWarp" value="true" />
```

El pak de la PRUEBA 01 se movió a `build\_desplegados_inertes_2026-08-04\`.

**Limitación conocida:** `RestartOnCompletion = false`. La misión se completa al entregar
la recompensa, así que es probable que el módulo funcione **solo la primera vez**. Es a
propósito: poner `true` en una misión que se autocompleta puede dejar el mapa abriéndose en
bucle. Si la primera pulsación abre el mapa, la pregunta está respondida y lo repetible se
arregla después.

**Qué mirar al probar:**

- ¿Aparece el botón? (Esta prueba no toca la interacción, así que debería.)
- ¿Se abre el mapa galáctico?
- ¿La cámara queda bien? ¿Se recupera el control al salir?
- ¿Deja marcar destino?
- ¿Ofrece SALTAR? Con `BlockWarp = true` no debería. Si lo ofrece, **no pulsarlo**: anotarlo.

Sin escanear contra los 87 mods de terceros. La tabla de misiones es más disputada que un
ENTITY suelto, así que para el mod de verdad hay que escanear.

### Lo que se observó in-game con la PRUEBA 02

El botón **sí** aparece —la interacción no se tocó— pero al pulsarlo abre lo de siempre:
el teclado para escribir el mensaje de la baliza. Ni mapa ni ninguna interacción nueva.

Esta vez el despliegue **no** es la causa. Se leyeron los dos `.MBIN` de `GAMEDATA\MODS`
descompilándolos de vuelta, y los dos llevan el cambio:

```xml
<Property name="InteractionType" value="MessageModule" />        <- intacto
<Property name="StartMissionOnUse" value="MOD3_GALMAP" />        <- línea 332
```
```xml
<Property name="MissionID" value="MOD3_GALMAP" />                <- línea 6, antes de SENTINEL_CRASH
```

Quedan dos sospechosos, y la PRUEBA 02 **no los distingue**:

- **A.** `MessageModule` no ejecuta `StartMissionOnUse`. La interacción está
  especializada en el ejecutable (abre el teclado) y no pasa por el camino genérico que
  arranca misiones.
- **B.** La misión arranca, pero la recompensa no abre el mapa a pie.

### Corrección: el precedente de `StartMissionOnUse` era más flojo de lo anotado

Al preparar la PRUEBA 03 se descompilaron las cuatro entidades vanilla que se habían
citado como prueba de que `StartMissionOnUse` funciona a pie. Tres de ellas **no lo
llevan en el componente de interacción**:

| Entidad | Componente que arranca la misión |
|---|---|
| `CRASHEDFREIGHTER_DISTRESSSIGNAL` | `GcInteractionComponentData` (tipo `CrashedFreighter`) |
| `CRYOCHAMBERPOD` | `GcMaintenanceComponentData` |
| `KORVAX_TERMINAL\BUTTON` | `GcMaintenanceComponentData`, y además por `StartMissionOnCompletion` |
| `ROBOTBASE\TERMINAL` | ninguno: el ID `ROBOT_CAMP` que aparece dentro es texto de UI |

`GcMaintenanceComponentData` es otro componente, con sus propios
`StartMissionOnUse` / `StartMissionOnCompletion` / `GiveRewardOnCompletion`. O sea que
**el único precedente real de la ruta C es uno solo**, y ninguna pieza construible
arranca misiones desde su interacción en vanilla. No invalida la prueba, pero explica
por qué no había red debajo.

---

## [No publicado] — RUTA D, 2026-08-04

### El campo que hace de recompensa sin misión

`GcInteractionComponentData` lleva esto:

```xml
<Property name="StoryUtilityOverrideData" value="GcStoryUtilityOverride">
    <Property name="NoInteractionUnlessOverriden" value="false" />
    <Property name="Name" value="UI_BP_ANALYSTER_TITLE" />
    <Property name="Reward" value="JUNK" />              <-- ID de REWARDTABLE
    <Property name="SpecificRewardOverrideTable" />
</Property>
```

Se descompilaron las **1317 entidades** de `BUILDABLEPARTS`. De las 67 con componente de
interacción, **11 usan `StoryUtility`** y todas rellenan ese `Reward`, cada una con un
valor distinto:

| Pieza | `Reward` |
|---|---|
| `BLUEPRINTANALYSER` | `JUNK` |
| `BLUEPRINTANALYSER_BUILD` | `R_S9_TREE_PART` |
| `BLUEPRINTANALYSER_EXO` | `R_S9_TREE_EXO` |
| `BLUEPRINTANALYSER_SHIP` | `R_S9_TREE_SHIP` |
| … SCI, WEAP, FARM y las variantes `_AM` | … |

**Que el valor cambie de una variante a otra es la prueba de que el dato manda.** Es ese
campo el que decide qué entrega el analizador, y no hay misión de por medio: es
interacción → recompensa, un solo salto en vez de dos.

El Analizador de Planos además es el portador ideal:

```
BP_ANALYSER (BASEBUILDINGOBJECTSTABLE)     BLUEPRINTANALYSER.ENTITY
    IsPlaceable           = true               ActivationCost.Cost      = 0
    BuildableOnPlanetBase = true               RepeatInteraction        = true
    ShowInBuildMenu       = true               ReseedAfterRewardSuccess = true
    Group                 = PLANET_TECH
```

Gratis y repetible, así que de paso se cae la limitación de un solo uso que tenía la
PRUEBA 02.

`JUNK` vive en la sección **`InteractionTable`** de `REWARDTABLE.MBIN`, no en
`GenericTable`. Ahí es donde va la nuestra.

### PRUEBA 03 — construida, desplegada y verificada · **pendiente de probar in-game**

Script: [`../work/scripts/mapa/MOD3_MapaGalactico_PRUEBA03.lua`](../work/scripts/mapa/MOD3_MapaGalactico_PRUEBA03.lua)

```
METADATA\REALITY\TABLES\REWARDTABLE.MBIN
    + R_MOD3_GALMAP en InteractionTable, justo antes de JUNK
        [0] GcRewardForceOpenGalaxyMap, BlockWarp = true
        [1] GcRewardMoney, 1234 unidades exactas

MODELS\...\TECH\BLUEPRINTANALYSER\ENTITIES\BLUEPRINTANALYSER.ENTITY.MBIN
    StoryUtilityOverrideData.Reward    JUNK -> R_MOD3_GALMAP
```

**Las 1234 unidades no son un premio, son un testigo.** Sin él, un «no pasa nada» no se
puede leer: es exactamente lo que dejó la PRUEBA 02, dos sospechosos y ningún dato para
separarlos. Con él la prueba tiene tres salidas y cada una dice algo distinto:

| Lo que pasa al pulsar | Qué significa |
|---|---|
| Se abre el mapa | Ruta D buena. Problema resuelto |
| Llegan 1234 unidades, **sin** mapa | La recompensa se entrega; lo que no funciona es `ForceOpenGalaxyMap` a pie. El mod 3 no sale por datos |
| Ni mapa ni unidades | El override de `StoryUtility` no se aplica; el fallo está antes, en el enganche |

**Validado antes de construir.** La entrada se inyectó a mano en una copia de
`REWARDTABLE.MXML` y se pasó por MBINCompiler: MXML → MBIN compila (1 159 816 → 1 159 976
bytes) y el round-trip MBIN → MXML sale limpio — 2677 entradas (2676 + 1), `BlockWarp` y
`AmountMin = 1234` intactos, colocada justo antes de `JUNK`.

Build: **1 ADD (líneas 27998–28031) + 1 CHANGE (línea 185), 0 errores.** Las líneas del
ADD son exactamente las del injerto validado a mano.

**Desplegado como MBIN desde `ModBackups\`** y verificado descompilando de vuelta desde
`GAMEDATA\MODS\MOD3_MapaGalactico_PRUEBA03\`:

```xml
<Property name="Reward" value="R_MOD3_GALMAP" />          <- dentro de StoryUtilityOverrideData
<Property name="BlockWarp" value="true" />
<Property name="AmountMin" value="1234" />
```

**La PRUEBA 02 se deja desplegada a propósito.** No comparte ni un archivo con ésta y da
información gratis: si el Analizador abre el mapa y el Módulo de Mensajes sigue sin hacer
nada, queda demostrado el sospechoso **A** —que `MessageModule` no ejecuta
`StartMissionOnUse`— sin gastar otra build.

**Lo que se rompe:** el Analizador de Planos deja de dar lo suyo mientras esto esté
puesto. Es una pieza útil, así que esto va al save de pruebas y a ningún otro.

Save respaldado antes de la prueba: `NMS_saves_2026-08-04_2123_antes-prueba03-mapa`.

**Cómo probarlo:** save de pruebas, base propia en un planeta, nada de carguero.
Construir un Analizador de Planos (Tecnología del planeta), pulsarlo, y mirar la esquina
de las unidades.

Sin escanear contra los 87 mods de terceros. `REWARDTABLE` es de los archivos más
disputados que hay: para un mod publicable hay que escanear antes; para un experimento en
el save de pruebas, no.

### Decisiones pendientes

- Nombre del mod y de la pieza.
- ¿Cuatro configuraciones o una sola?
- ¿Pieza gratis o con coste de materiales?
- Repetir la PRUEBA 01 bien desplegada, para cerrar la ruta B con dato en vez de con
  suposición.

---

## [No publicado] — resultado de la PRUEBA 03 y cierre de la ruta D, 2026-08-04

### Lo que se observó in-game: **llegan las 1234 unidades, no se abre el mapa**

Es la segunda fila de la tabla de tres salidas que se escribió antes de probar, así que se
lee sin ambigüedad:

- El enganche funciona. `StoryUtilityOverrideData.Reward` **sí** se aplica en una pieza
  construida en un planeta, y la recompensa se entrega estando a pie.
- Lo que no hace nada es `GcRewardForceOpenGalaxyMap`. Con `GiveAll` los dos ítems de la
  lista se procesan; el dinero llega, el mapa no.

**Ruta D cerrada.** El testigo hizo su trabajo: separó los dos sospechosos que la PRUEBA 02
dejó empatados. Y de paso da un dato que la 02 no podía dar: la vía
interacción → recompensa está viva, es solo *esa* recompensa la que está muerta a pie.

### La PRUEBA 02 sigue sin distinguir sus dos sospechosos

`MessageModule` + `StartMissionOnUse` no hizo nada. Ahora sabemos que la recompensa del
final de esa cadena tampoco habría abierto el mapa, así que el resultado de la 02 es
compatible con las dos explicaciones y **no hace falta volver sobre ella**: la pregunta que
respondía ya la responde la 03.

### Inventario cerrado: qué queda en datos que pueda abrir el mapa

Se buscó a fondo, no por encima. Tres cosas y ninguna más:

| Vía | Estado |
|---|---|
| `GcInteractionType = FreighterGalacticMap` | **Viva y sin probar de verdad** |
| `GcRewardForceOpenGalaxyMap` | Muerta a pie — PRUEBA 03 |
| `GcRewardOpenPage` con una página de mapa | **No existe esa página** |

Cómo se comprobó cada una:

- **El enum de interacciones tiene una sola entrada de mapa.** Se validaron candidatos
  compilando el ENTITY con MBINCompiler, que rechaza un valor de enum inexistente:
  `MessageModule` ✔, `FreighterGalacticMap` ✔, `GalacticMap` ✘, `Ship_GalacticMap` ✘.
  `Ship_GalacticMap` **sí** existe dentro de `libMBIN`, pero como acción de input (vive
  junto a `GalacticMap_Up`, `Quick_Up`), no como tipo de interacción. Las teclas se
  resuelven en el ejecutable: mismo callejón que la ruta A.
- **`GcRewardOpenPage` no sirve.** Los 24 valores de `PageToOpen` que usa el juego son
  tiendas y paneles (`BuyShip`, `TraderInventory`, `FleetManagement`, `NexusTechShop`,
  `ExpeditionSelect`…). Además, en toda la tabla de cadenas de `libMBIN` **no existe** la
  cadena `GalaxyMap` ni `GalacticMap` sueltas — solo compuestas
  (`GcRewardForceOpenGalaxyMap`, `DelayBeforeHidingHangarAfterGalaxyMap`,
  `ShowUniverseAddressOnGalaxyMap`). Si no hay cadena, no hay valor de enum.

**Queda una sola bala: la interacción.** Y es justo la que nunca se llegó a disparar.

### La PRUEBA 01 no fue un no-resultado limpio — hay que releerla

Lo anotado fue: «el Módulo de Mensajes se construye, pero **no aparece ningún botón**».
Eso **no es el comportamiento vanilla** — un módulo de mensajes vanilla ofrece su botón de
escribir. O sea que algo cambió, y hay dos lecturas:

- **A.** El EXML delta sí llegó a aplicarse en parte, el juego aceptó
  `FreighterGalacticMap` y a pie no tiene nada que ofrecer → **ruta B negativa**.
- **B.** El EXML rompió el nodo y el juego descartó el componente entero → sin dato.

La PRUEBA 02 devolvió el botón, pero no distingue nada porque no tocaba la interacción.
La PRUEBA 04 lo resuelve.

### Corrección: el EXML **sí** es un formato de mod, con una condición

`README-How MBIN and EXML coexist.txt` de AMUMSS lo dice explícitamente: en
`GAMEDATA\MODS`, un MBIN reemplaza el archivo entero y el último en cargar gana, mientras
que **un EXML parchea líneas sueltas** y dos mods pueden convivir sobre el mismo MBIN. Y
`AddLSnPG v5.63`, instalado aquí, se distribuye **solo** como
`METADATA\REALITY\TABLES\UNLOCKABLEITEMTREES.EXML` — 446 líneas, sin ningún `.pak`.

Lo que no vale es el delta de `CreatedMODS\` **tal cual**, porque lleva las marcas
`!# CHANGED` sueltas dentro del XML. AMUMSS tiene la opción para quitarlas:
`-IncludeTagsInEXML_MXML N`.

No cambia la práctica —seguimos desplegando `.MBIN` desde `ModBackups\`, que es lo que
está demostrado que carga (las 1234 unidades lo prueban)— pero sí cambia el diagnóstico de
la PRUEBA 01: el EXML pudo haberse aplicado.

### PRUEBA 04 — construida, desplegada y verificada · **pendiente de probar in-game**

Script: [`../work/scripts/mapa/MOD3_MapaGalactico_PRUEBA04.lua`](../work/scripts/mapa/MOD3_MapaGalactico_PRUEBA04.lua)

Es la PRUEBA 01 repetida bien: **un campo, un archivo**, desplegada como MBIN.

```
MODELS\...\MESSAGEMODULE\ENTITIES\MESSAGEMODULE.ENTITY.MBIN
    InteractionType   MessageModule -> FreighterGalacticMap
```

Mismo anclaje que la 01 (`VALUE_MATCH = "MessageModule"`, que esquiva el envoltorio
`GcInteractionType` y la pareja `SecondaryInteractionType`). Esperado: **1 CHANGE, 0 errores**.

**Antes de probar hay que quitar las PRUEBAS 02 y 03 del juego:**

- la 02 escribe **el mismo** `MESSAGEMODULE.ENTITY.MBIN` — con dos MBIN del mismo archivo
  gana el último en cargar y el resultado no se puede leer;
- la 03 tiene secuestrado el Analizador de Planos, que conviene recuperar.

Tres salidas y qué significa cada una:

| Al pulsar el módulo | Lectura |
|---|---|
| Se abre el mapa galáctico | **Ruta B viva.** El mod 3 existe; se pasa al módulo propio |
| Hay botón pero no pasa nada | La interacción se acepta y el juego no la sirve a pie |
| No hay botón | Confirma la lectura A de la PRUEBA 01: sin contexto de carguero no hay UI |

Con cualquiera de las dos salidas negativas, **el mod 3 no sale por datos** y hay que
anotarlo y parar: no queda ninguna otra vía en el inventario de arriba.

#### Build y despliegue del 2026-08-04, 22:03

Build: **1 CHANGE, 0 errores, 0 warnings, 0 notices.** El delta de `CreatedMODS\` es
exactamente el buscado — el envoltorio `GcInteractionType` sin marca y
`SecondaryInteractionType` intacta:

```xml
<Property name="InteractionType" value="GcInteractionType">
  <Property name="InteractionType" value="FreighterGalacticMap" /> !# CHANGED
</Property>
```

Desplegado como **MBIN desde `ModBackups\`** (2820 bytes, el tamaño del ENTITY vanilla) y
verificado descompilando de vuelta **desde `GAMEDATA\MODS\`**:

```xml
línea 176   InteractionType     = FreighterGalacticMap
línea 291   SecondaryInteraction= None            <- intacta
línea 332   StartMissionOnUse   = ""              <- la PRUEBA 02 ya no está
```

**Retiradas del juego** a `build\_desplegados_inertes_2026-08-04\`: la PRUEBA 02 (escribía
el mismo ENTITY) y la PRUEBA 03 (**el Analizador de Planos vuelve a ser el de vanilla**).
En `GAMEDATA\MODS` solo queda `MOD3_MapaGalactico_PRUEBA04`, con un único archivo.

Save respaldado antes de la prueba: `NMS_saves_2026-08-04_2201_antes-prueba04-mapa`.

**Escaneo de conflictos, esta vez sí hecho:** ningún otro de los 87 mods instalados toca
`MESSAGEMODULE.ENTITY`. La prueba está sola en su archivo.

> Dato para cuando toque el árbol del Nexo: `UNLOCKABLEITEMTREES` **ya lo tocan dos mods
> instalados** (`AddLSnPG v5.63` y `FF_ScrapyardTechnology_620`) y `REWARDTABLE` otros tres,
> todos **como EXML**. Si nosotros metemos un MBIN entero de esos archivos, sus EXML se
> aplican encima y ganan línea a línea; si metemos EXML, conviven. Cuando llegue el momento,
> **nuestro nodo de árbol va como EXML**, no como MBIN.

#### Checklist de la prueba in-game

Save de pruebas, base propia en un planeta, **a pie y sin carguero cerca**.

| # | Qué hacer | Qué anotar |
|---|---|---|
| 1 | Cargar el save de pruebas | Que **no** sea la partida buena |
| 2 | Ir a un Módulo de Mensajes ya plantado, o construir uno (Tecnología → base) | Si ya había uno puesto, sirve: el cambio es del ENTITY, no de la pieza guardada |
| 3 | Acercarse a menos de 5 m y mirarlo | **¿Sale el cartel de interacción?** Y el texto exacto que pone |
| 4 | Pulsar | Lo que pasa, literal |
| 5 | Si se abre el mapa | ¿La cámara queda bien? ¿Se ve la galaxia o una pantalla rota? |
| 6 | Dentro del mapa: moverse entre sistemas | ¿Deja **marcar destino**? |
| 7 | Dentro del mapa: buscar la opción de saltar | **Si la ofrece, NO pulsarla.** Anotarlo y salir |
| 8 | Salir del mapa | ¿Vuelve el control del personaje? ¿La cámara vuelve a su sitio? |
| 9 | Volver a pulsar el módulo | ¿Funciona la segunda vez? (`RepeatInteraction = false` en vanilla) |
| 10 | Si el juego se cuelga | Cerrar, decirlo, y **no** volver a entrar hasta retirar el mod |

Lo que **ya no** se puede hacer con este mod puesto: escribir mensajes en la baliza. Es lo
esperado, la interacción está sustituida.

Para revertir: borrar `GAMEDATA\MODS\MOD3_MapaGalactico_PRUEBA04\`. No hace falta nada más;
no toca el save.

---

## [No publicado] — el módulo propio: anatomía verificada, 2026-08-04

Esto es lo que hace falta para tener **pieza propia** en vez de secuestrar la de mensajes.
Todo verificado leyendo los archivos, nada construido todavía. **Solo tiene sentido
construirlo si la PRUEBA 04 sale positiva.**

### Son tres cosas distintas, y conviene no mezclarlas

1. **Que exista la pieza** (ID propio, coste, nombre, sin pisar el módulo de mensajes).
2. **Que abra el mapa** — es la PRUEBA 04, y no depende de lo anterior.
3. **Que se desbloquee en el Nexo** — es una línea en un árbol, y va la última.

### 1 · La pieza — cinco archivos, ninguno compartido con los mods 1 y 2

| Archivo | Qué aporta | Cómo se toca |
|---|---|---|
| `MODELS\...\TECH\MESSAGEMODULE.SCENE.MBIN` | el modelo. Su línea 1860 apunta al ENTITY | **clonar** a ruta nueva y repuntar esa línea |
| `MODELS\...\MESSAGEMODULE\ENTITIES\MESSAGEMODULE.ENTITY.MBIN` | la interacción | **clonar** y cambiarle el `InteractionType` |
| `METADATA\REALITY\TABLES\BASEBUILDINGPARTSTABLE.MBIN` | ID → `.SCENE` | `ADD` de un `GcBaseBuildingPart` |
| `METADATA\REALITY\TABLES\BASEBUILDINGOBJECTSTABLE.MBIN` | dónde se puede plantar, grupo del menú, color | `ADD` de un `GcBaseBuildingEntry` |
| `METADATA\REALITY\TABLES\NMS_BASEPARTPRODUCTS.MBIN` | nombre, icono, color y **coste de materiales** | `ADD` de un `GcProductData` |

Dos avisos de lo que **no** es:

- `BASEBUILDINGCOSTSTABLE.MBIN` **no** es el coste de materiales. Sus campos son
  `Active0AverageFrameTimeCost`, `ActiveTotalNodes`, `ActivePhysicsComponents`: es el
  presupuesto de **rendimiento** de la pieza. El coste real vive en `Requirements` del
  producto (el módulo de mensajes son 1 `CASING` + 1 `NANOTUBES`).
- La geometría **no se clona**. La `.SCENE` referencia
  `...\MESSAGEMODULE.GEOMETRY.MBIN` por ruta absoluta y esa se comparte sin tocarla.

**La herramienta para clonar es la sintaxis alternativa #3 de `MBIN_FILE_SOURCE`**, no
`ADD_FILES` (lo dice la propia doc de AMUMSS: para MBIN que además hay que modificar, mejor
la #3). Se le pasa `{ ruta_original, ruta_nueva, "REMOVE" }`: crea la copia y, con `REMOVE`,
**el original ni siquiera entra en el mod**. Luego se abre una segunda sección de
`MBIN_CHANGE_TABLE` apuntando ya a la ruta nueva para editarla. Es exactamente lo que hace
falta para «no pisar el de mensajes».

Queda por resolver el **nombre visible**: el producto apunta a claves de idioma
(`BLD_MESSAGEMODULE_NAME`, `_SUBTITLE`, `_DESCRIPTION`). O se reutilizan las del módulo de
mensajes —sale con el nombre de éste— o hay que añadir claves a los `LANGUAGE\*.MBIN`, que
son ocho archivos por idioma. **Para la primera versión, reutilizar.**

### 2 · El rojo — no hay campo de «color de burbuja»

Se leyó el `GcInteractionComponentData` entero del módulo de mensajes: **ni un campo de
color**. Lo que hay en `GCUIGLOBALS` (`InteractionLabelCostColour`,
`InteractionLabelPickupColour`, `InteractionLabelPickupFillColour`) es **global**: pintarlo
de rojo repinta las etiquetas de todo el juego. No sirve para «esta pieza en rojo».

Lo que sí es por pieza:

| Palanca | Dónde | Qué pinta |
|---|---|---|
| `Colour` del producto | `NMS_BASEPARTPRODUCTS` | color del ítem en UI. El de mensajes es azul verdoso (`0.17 / 0.49 / 0.62`) → rojo es `1.0 / 0.1 / 0.1` |
| `DefaultColourPaletteId` | `BASEBUILDINGOBJECTSTABLE` | pintura del **modelo**. El de mensajes usa el grupo `LEGACY` con `CanChangeColour = true`; hay 16 entradas `LEGACY*` y falta averiguar **cuál es la roja** (la tabla de paletas de base no está en `Precache`) |

O sea: rojo garantizado en el icono/UI, y rojo en el modelo en cuanto se localice la paleta.
Si lo que se quiere es el holograma del mensaje en rojo, eso es material del modelo
(`MESSAGEMODULEMSG.SCENE`) y es trabajo de texturas, no de tabla.

### 3 · Los árboles del Nexo — **confirmado**

`METADATA\REALITY\TABLES\UNLOCKABLEITEMTREES.MBIN` es el archivo, y **es el único sitio**
donde una pieza se ofrece para desbloquear. Tiene 15 grupos, y cada uno lo abre una
recompensa `GcRewardOpenUnlockTree` desde la terminal correspondiente:

| Recompensa | Grupo que abre |
|---|---|
| `TREE_BASICS` / `TREE_TECHBASICS` | `BasicBaseParts` / `BasicTechParts` |
| `TREE_BASE` | `BaseParts` ← **el nuestro** |
| `TREE_SPEC_BASE`, `TREE_SUIT`, `TREE_SHIP`, `TREE_WEAP`, `TREE_EXO`, `TREE_CRAFT`, `TREE_FRIGATE` | `SpecialBaseParts`, `SuitTech`, … , `FreighterTech` |
| `R_S9_TREE_PART` / `_EXO` / `_SHIP` | `S9BaseParts`, `S9ExoTech`, `S9ShipTech` |
| `R_BIGGS_TREE` | `CorvetteParts` |

**Y aquí se cierra el círculo con la ruta D:** esas recompensas `TREE_*` son exactamente los
valores de `StoryUtilityOverrideData.Reward` de los Analizadores de Planos que se listaron
al abrir la ruta D. La terminal del Nexo es una pieza con interacción cuya recompensa abre
un árbol. Es el mismo mecanismo que se usó en la PRUEBA 03 — y **funciona**, lo prueban las
1234 unidades.

Dónde va nuestro nodo: en `BaseParts`, subárbol `UI_BASETECH_TREE`, moneda `SALVAGE` (datos
recuperados). La cadena vanilla es `BUILDBEACON → … → BUILDSIGNAL → MESSAGEMODULE → MESSAGE`.
El sitio natural es colgar la pieza **de `MESSAGEMODULE`**, como hermana de `MESSAGE`.

> El mismo `MESSAGEMODULE` aparece también en el grupo `S9BaseParts`. Si se quiere que
> aparezca en las dos, son dos nodos.

Antes del Nexo **no hay dónde ofrecerla**: no existe otro archivo con árboles de desbloqueo.
La confirmación que pedías es esa.

### Cómo lo hace `AddLSnPG v5.63` — el mod que se pidió revisar

Es el precedente exacto de lo que queremos, y la técnica es más sencilla de lo que parecía:

- Toca **un solo archivo**: `UNLOCKABLEITEMTREES`, y solo el grupo `FreighterTech`.
- **No crea un árbol nuevo.** Injerta nodos en el que ya existe: pasa de 52 desbloqueables
  a 93. Los ~41 nuevos son IDs que **ya existían en el juego** y que no colgaban de ningún
  árbol, así que no había forma de comprarlos: las piezas legacy (`C_WALL`, `C_FLOOR`,
  `C_ARCH`, `C_ROOF*`, `CORRIDOR*_SPACE`, `CUBEROOM*_SPACE`) y los *glitches* de planeta
  (`BASE_BEAMSTONE`, `BASE_BONEGARDEN`, `BASE_HYDROPOD`, `BASE_SHARD`, `BASE_WEIRDCUBE`…).
- Se distribuye como **EXML parcial** — 446 líneas, solo su grupo, sin marcas `!#` y sin
  `.pak`.

La lección para nosotros: **desbloquear algo nuevo es añadir un `GcUnlockableItemTreeNode`
a un árbol existente**, nada más. Lo que no hace AddLSnPG —y nosotros sí necesitamos— es
crear la pieza; él solo saca a la venta piezas que Hello Games ya tenía hechas.

### Orden de trabajo propuesto

1. **PRUEBA 04.** Decide si el mod existe. Todo lo demás depende de esto.
2. Si sale bien: pieza propia clonada (`SCENE` + `ENTITY` + las tres tablas), reutilizando
   los textos del módulo de mensajes y con el producto en rojo.
3. Nodo en `BaseParts / UI_BASETECH_TREE` colgando de `MESSAGEMODULE`. **Va en el mismo
   paso que el 2, no después**: un ID nuevo no está en los planos conocidos de la partida y
   no hay ninguna lista de «desbloqueado de serie» en los globals — se buscó. Sin nodo de
   árbol (o sin una recompensa `GcRewardSpecificProductRecipe` que lo regale) la pieza
   existe en las tablas pero no hay forma de aprenderla. Es justo lo que demuestra AddLSnPG:
   las piezas legacy llevaban años en los datos y eran inalcanzables **por no estar en
   ningún árbol**.
4. Escaneo contra los 87 mods de terceros — `UNLOCKABLEITEMTREES` lo toca AddLSnPG, aunque
   sea en otro grupo, y las tablas de construcción son terreno disputado.
5. Nombre propio en `LANGUAGE\*`, si para entonces sigue mereciendo la pena.

### Lo que sigue sin saberse

- Si al abrirse el mapa a pie ofrece **saltar**. `BlockWarp` solo existe en la recompensa
  que no funciona; la vía interacción **no tiene ese campo**. Si el mapa se abre y ofrece
  warp, no hay palanca de datos conocida para caparlo: habría que probar qué hace al
  intentarlo sin nave.
- Cuál de las 16 paletas `LEGACY` es la roja.
- Si el juego carga una `.SCENE` clonada a una ruta que no existe en ningún `.pak`
  (debería: es lo que hace cualquier mod que añade piezas, pero no lo hemos hecho nunca).

---

## [No publicado] — RUTA E, 2026-08-04

### Resultado de la PRUEBA 04: **no hay botón**

Es la tercera fila de la tabla que se escribió antes de probar. El Módulo de Mensajes con
`InteractionType = FreighterGalacticMap` ni siquiera enseña el cartel de interacción: el
juego descarta la interacción **antes** de decidir si la dibuja. Y esta vez el despliegue
estaba verificado leyendo el MBIN de `GAMEDATA\MODS`, así que el dato es bueno.

**Ruta B cerrada.** Con la D ya cerrada por la PRUEBA 03, el inventario de «qué queda en
datos que pueda abrir el mapa» se quedaba a cero.

### La ruta A estaba mal cerrada: el menú rápido **sí** es dato

El cierre de la ruta A decía «no existe ningún `.MBIN` que liste las entradas del menú
rápido». Eso es cierto y sigue siéndolo — pero la pregunta estaba mal hecha. No hace falta
**añadir** una entrada: la entrada de mapa galáctico **ya existe** en el menú rápido (lo
delataba su textura, `QUICKMENU\GALAXYMAP.DDS`). Lo único que hace falta es la palanca que
decide cuándo se enseña. Y esa palanca sí está en datos.

Se buscó barriendo la tabla de cadenas de `libMBIN.dll` entera —30 250 identificadores— en
vez de abrir archivos a mano. Aparecieron cuatro nombres que nadie había mirado:

| Identificador | Dónde vive | Valor vanilla |
|---|---|---|
| `DebugGalaxyMapInQuickMenu` | `GLOBALS\GCDEBUGOPTIONS.GLOBAL.MBIN`, línea 26 | `false` |
| `ForceNexusInQuickMenu` | `GCDEBUGOPTIONS`, línea 159 | `false` |
| `DisableGalaxyMapInQuickMenu` | `GLOBALS\GCGAMEPLAYGLOBALS.GLOBAL.MBIN`, línea 436 | `false` |
| `DisableNexusInQuickMenu` | `GCGAMEPLAYGLOBALS`, línea 437 | `false` |

**El patrón es la prueba.** El Nexo tiene la pareja completa: un `Disable*` en los globals
de juego y un `Force*` en los de depuración. El mapa galáctico tiene la misma pareja, solo
que el «force» se llama `Debug*`. O sea que `DebugGalaxyMapInQuickMenu` es, por simetría,
**el interruptor que mete el mapa galáctico en el menú rápido pase lo que pase** — que es
literalmente lo pedido: la vista que sale en el espacio, disponible a pie.

Dos apoyos más, del mismo barrido:

- `DebugGalaxyMapInQuickMenu` está pegado a `MapWarpCheckIgnoreFuel` y
  `MapWarpCheckIgnoreDrive`. Es el racimo de depuración del warp desde el mapa: las
  herramientas que usa Hello Games para abrir el mapa y saltar **sin las condiciones
  normales**. Es el sitio exacto donde estaría lo que buscamos.
- Existe el campo `GalaxyMapMessageNotSpace`, distinto de `GalaxyMapMessage`. El juego
  tiene un mensaje específico para el mapa galáctico **fuera del espacio**. No se abre un
  camino que no existe.

`DisableGalaxyMapInQuickMenu` ya está en `false`, así que **no** es lo que nos bloqueaba.
Se anota para no volver a mirarlo.

### Escaneo de conflictos

- **`GCDEBUGOPTIONS`: ninguno de los 87 mods instalados lo toca.** Terreno libre.
- `GCGAMEPLAYGLOBALS` lo tocan cuatro (`bMore Freighter and Space Battles`,
  `Enhanced First Person Camera`, `HonestHUDSpeed`, `Larger Upgrade Stacks`), todos como
  EXML. No lo tocamos, pero el dato vale: **los globals son archivos vivos que el juego
  lee y que los mods parchean todos los días.**

### PRUEBA 05 — construida, desplegada y verificada · **pendiente de probar in-game**

Script: [`../work/scripts/mapa/MOD3_MapaGalactico_PRUEBA05.lua`](../work/scripts/mapa/MOD3_MapaGalactico_PRUEBA05.lua)

```
GLOBALS\GCDEBUGOPTIONS.GLOBAL.MBIN
    DebugGalaxyMapInQuickMenu   false -> true     <- lo que se prueba
    ForceNexusInQuickMenu       false -> true     <- control
```

**El Nexo es el testigo de esta prueba**, el equivalente a las 1234 unidades de la 03. Sin
él, un «no pasa nada» vuelve a dejar dos sospechosos empatados. Con él son tres salidas y
cada una dice algo distinto:

| Lo que sale en el menú rápido a pie | Qué significa |
|---|---|
| Mapa galáctico (con o sin Nexo) | **Ruta E buena.** El mod 3 existe |
| Nexo sí, mapa no | El juego **sí** lee `GCDEBUGOPTIONS`; lo que está capado en la versión de release es ese interruptor concreto. Mod 3 muerto por datos, pero con diagnóstico |
| Ni Nexo ni mapa | El ejecutable de release ignora `GCDEBUGOPTIONS` entero. Mod 3 muerto por datos |

`MapWarpCheckIgnoreFuel` y `MapWarpCheckIgnoreDrive` se dejan en `false` a propósito: el
objetivo es mirar, no saltar. Si el mapa se abre y ofrece warp, se anota y no se pulsa.

Build: **2 CHANGE, 0 errores, 0 warnings, 0 notices.** Las dos líneas exactas (26 y 159).
Delta de `CreatedMODS`:

```xml
<Data template="cGcDebugOptions">
  <Property name="DebugGalaxyMapInQuickMenu" value="true" /> !# CHANGED
  <Property name="ForceNexusInQuickMenu" value="true" /> !# CHANGED
</Data>
```

**Desplegado como MBIN desde `ModBackups\`** y verificado descompilando de vuelta desde
`GAMEDATA\MODS\MOD3_MapaGalactico_PRUEBA05\GLOBALS\`: 9718 bytes (el tamaño vanilla), 618
propiedades, las dos en `true` y los dos `MapWarpCheckIgnore*` intactos en `false`.

> **Ojo con la ruta al desplegar.** `ModBackups\` dejó el MBIN **suelto en la raíz** de la
> carpeta del mod, sin el `GLOBALS\` delante — al contrario que en la PRUEBA 04, donde sí
> reprodujo el árbol `MODELS\...`. Hay que crear el `GLOBALS\` a mano al copiarlo o el
> juego no lo encuentra.

**Retirada del juego** a `build\_desplegados_inertes_2026-08-04\`: la PRUEBA 04 (el Módulo
de Mensajes vuelve a ser el de vanilla y recupera su botón de escribir). En `GAMEDATA\MODS`
solo queda `MOD3_MapaGalactico_PRUEBA05`, con un único archivo.

Save respaldado antes de la prueba: `NMS_saves_2026-08-04_2318_antes-prueba05-mapa`.

#### Checklist de la prueba in-game

Save de pruebas, **a pie, en un planeta y sin carguero cerca**. No hace falta construir
nada: esto no es una pieza, es un interruptor global.

| # | Qué hacer | Qué anotar |
|---|---|---|
| 1 | Cargar el save de pruebas | Que **no** sea la partida buena |
| 2 | Estando a pie, abrir el menú rápido | **¿Aparece el icono del mapa galáctico?** ¿Y el del Nexo? |
| 3 | Si aparece el mapa: pulsarlo | Lo que pasa, literal |
| 4 | Si se abre | ¿Se ve la galaxia o una pantalla rota? ¿La cámara queda bien? |
| 5 | Moverse entre sistemas | ¿Deja **marcar destino**? |
| 6 | Buscar la opción de saltar | **Si la ofrece, NO pulsarla.** Anotarlo y salir |
| 7 | Salir del mapa | ¿Vuelve el control del personaje? |
| 8 | Si no aparece el mapa | **Mirar si aparece el Nexo.** Es el dato que decide el diagnóstico |

Para revertir: borrar `GAMEDATA\MODS\MOD3_MapaGalactico_PRUEBA05\`. No toca el save.

### Si la PRUEBA 05 sale negativa

Se para el mod 3 y se anota como fracaso. El inventario de vías queda así, todas cerradas
con dato in-game y no por suposición:

| Vía | Cómo se cerró |
|---|---|
| A · entrada nueva en el menú rápido | No hay archivo que liste entradas |
| B · `GcInteractionType = FreighterGalacticMap` | PRUEBA 04: ni botón sale |
| C · misión + `StartMissionOnUse` | PRUEBA 02, y la 03 explicó por qué |
| D · `GcRewardForceOpenGalaxyMap` | PRUEBA 03: llega el dinero, no llega el mapa |
| E · interruptor del menú rápido | PRUEBA 05 |

Lo que quedaría **no es modding de datos**: parchear el ejecutable. Fuera del alcance del
proyecto.

---

## [No publicado] — resultado de la PRUEBA 05, 2026-08-05

### Lo que se observó in-game: **ni mapa ni Nexo**

En el menú rápido a pie no apareció ninguno de los dos iconos.

### El despliegue estaba bien — se volvió a comprobar entero

Antes de leer nada, se verificó que el fallo no fuera de despliegue, que es lo que arruinó
la PRUEBA 01. Todo correcto:

| Comprobación | Resultado |
|---|---|
| Ruta desplegada | `MODS\MOD3_MapaGalactico_PRUEBA05\GLOBALS\GCDEBUGOPTIONS.GLOBAL.MBIN` — el `GLOBALS\` que había que crear a mano estaba puesto |
| Tamaño | 9718 bytes, el del vanilla |
| `DebugGalaxyMapInQuickMenu` | `true`, línea 26 — descompilando el MBIN **de `GAMEDATA\MODS`** |
| `ForceNexusInQuickMenu` | `true`, línea 159 |
| `DISABLEMODS.TXT` en `PCBANKS` | no existe |
| Otro mod tocando `GCDEBUGOPTIONS` | ninguno de los 87 |
| Otro mod tocando `QuickMenu` en cualquier EXML/MXML | ninguno |

El dato in-game es bueno. Lo que no vale es la conclusión que se iba a sacar de él.

### El control estaba contaminado: `ForceNexusInQuickMenu` no distinguía nada

La tabla de tres salidas de la PRUEBA 05 daba por hecho que el Nexo en el menú rápido sería
señal de que el juego lee `GCDEBUGOPTIONS`. **No lo es: el icono de invocar la Anomalía ya
sale a pie en vanilla.** Si hubiera aparecido, no habría probado nada — sería el
comportamiento normal. Y como no apareció, tampoco separa los dos sospechosos, porque un
`Force*` que no fuerza nada es indistinguible de un `Force*` que el ejecutable no lee.

Mismo error de diseño que la PRUEBA 02, y con la lección de las 1234 unidades de la 03 ya
aprendida: **un control solo sirve si su efecto es imposible de confundir con vanilla.**

### PRUEBA 06 — construida, desplegada y verificada · **pendiente de probar in-game**

Script: [`../work/scripts/mapa/MOD3_MapaGalactico_PRUEBA06.lua`](../work/scripts/mapa/MOD3_MapaGalactico_PRUEBA06.lua)

**No toca el mapa galáctico.** Es control puro, y responde una sola pregunta: *¿lee el
ejecutable de release `GCDEBUGOPTIONS`?*

```
GLOBALS\GCDEBUGOPTIONS.GLOBAL.MBIN
    RenderHud          true  -> false     <- linea 169
    InfiniteStamina    false -> true      <- linea 32
```

Por qué estas dos y no otras:

- **`RenderHud = false` es lo más ruidoso que hay en el archivo.** Desaparece el HUD entero.
  Ningún mod instalado puede producir eso por accidente (`HonestHUDSpeed` solo cambia el
  indicador de velocidad). Es un sí/no que no admite interpretación.
- **`InfiniteStamina = true` es el segundo control, independiente del primero.** Si el HUD
  sigue ahí pero el sprint no se acaba, la respuesta también es sí. Dos flags sube la
  probabilidad de que al menos una esté viva en release: puede que el archivo se lea y que
  el `#if DEBUG` esté en el sitio donde se *usa* el valor, no donde se lee.

Se descartaron `EverythingIsFree`, `DisableHazards`, `GodMode` y `TakeNoDamage`: hay mods
instalados que tocan construcción y peligros ambientales (`_Beyond Base Building`,
`DD-BuildItHere`, `Hazard Protection Overhaul`, `MOD_DUD_WeatherHazards`) y contaminarían
la lectura igual que el Nexo.

Build: **2 CHANGE, 0 errores, 0 warnings, 0 notices.** Líneas 169 y 32, las esperadas.
Delta de `CreatedMODS`:

```xml
<Data template="cGcDebugOptions">
  <Property name="InfiniteStamina" value="true" /> !# CHANGED
  <Property name="RenderHud" value="false" /> !# CHANGED
</Data>
```

**Desplegado como MBIN desde `ModBackups\`** —creando el `GLOBALS\` a mano, igual que en la
05— y verificado descompilando de vuelta desde `GAMEDATA\MODS\`: 9718 bytes, 618
propiedades, las dos cambiadas y **los dos flags del menú rápido de vuelta en `false`**,
que es lo que hace de ésta una prueba limpia.

**Retirada del juego** a `build\_desplegados_inertes_2026-08-04\`: la PRUEBA 05. En
`GAMEDATA\MODS` solo queda `MOD3_MapaGalactico_PRUEBA06`, con un único archivo.

Save respaldado antes de la prueba: `NMS_saves_2026-08-05_0007_antes-prueba06-mapa`.

#### Checklist de la prueba in-game

Save de pruebas. No hace falta ni estar en un planeta concreto ni construir nada.

| # | Qué hacer | Qué anotar |
|---|---|---|
| 1 | Cargar el save de pruebas | Que **no** sea la partida buena |
| 2 | Mirar la pantalla nada más cargar | **¿Está el HUD?** Vida, escudo, brújula, retícula |
| 3 | Si el HUD sigue: correr en línea recta hasta pasarse de largo | **¿Se acaba el aguante o no?** |

Tres salidas:

| Lo que pasa | Qué significa |
|---|---|
| Sin HUD, o aguante infinito | **El juego sí lee `GCDEBUGOPTIONS` en release.** Entonces lo que está capado es `DebugGalaxyMapInQuickMenu` en concreto, y la ruta E se cierra con diagnóstico bueno |
| HUD normal y el aguante se acaba | El ejecutable de release **ignora el archivo entero**. Ruta E cerrada, y de paso queda descartado todo `GLOBALS\GCDEBUGOPTIONS` para cualquier mod futuro |

Con cualquiera de las dos, **el mod 3 no sale por datos** y se anota el fracaso con las
cinco vías cerradas por dato in-game. La diferencia entre una y otra no salva el mod 3,
pero sí decide si `GCDEBUGOPTIONS` vale para algo en el resto del proyecto.

Para revertir: borrar `GAMEDATA\MODS\MOD3_MapaGalactico_PRUEBA06\`. No toca el save.

---

## [Cerrado] — el mod 3 no sale por datos, 2026-08-05

### Resultado de la PRUEBA 06: **HUD normal y el aguante se acaba**

Es la segunda fila de la tabla de dos salidas. Los dos controles fallaron a la vez, y eran
independientes entre sí:

| Control | Esperado si el archivo se lee | Observado |
|---|---|---|
| `RenderHud = false` | pantalla sin vida, escudo, brújula ni retícula | HUD completo, normal |
| `InfiniteStamina = true` | correr sin que se acabe el sprint | el aguante se acaba |

**El ejecutable de release ignora `GLOBALS\GCDEBUGOPTIONS.GLOBAL.MBIN` entero.** No es que
`DebugGalaxyMapInQuickMenu` esté capado en concreto: el archivo no se consume. Por eso la
PRUEBA 05 no enseñó el mapa, y por eso tampoco habría enseñado nada que se le pidiera.

El despliegue estaba verificado antes de probar —9718 bytes, 618 propiedades, las dos líneas
cambiadas leídas descompilando el MBIN **de `GAMEDATA\MODS`**— así que el dato es bueno.

**Ruta E cerrada.**

### Consecuencia fuera del mod 3

`GCDEBUGOPTIONS` queda **descartado para todo el proyecto**. Sus 618 propiedades
(`GodMode`, `EverythingIsFree`, `DisableHazards`, `MapWarpCheckIgnoreFuel`…) leen como una
mina de palancas y no lo son: es un archivo que se compila con el juego y que la build
pública no mira. No volver a gastar un ciclo ahí.

Lo que **sí** se lee son los globals de juego: `GCGAMEPLAYGLOBALS`, `GCUIGLOBALS` y
compañía — cuatro de los 87 mods instalados los parchean y funcionan. La distinción es
`Debug*` contra el resto, no «globals» en bloque.

### Las cinco vías, todas cerradas con dato in-game

Ninguna se descartó por difícil ni por suposición:

| Vía | Qué se intentó | Cómo se cerró |
|---|---|---|
| **A** · entrada nueva en el menú rápido | añadir la opción al menú | No existe archivo que liste las entradas. El icono `QUICKMENU\GALAXYMAP.DDS` existe, pero la condición que lo enseña está en el ejecutable |
| **B** · `GcInteractionType = FreighterGalacticMap` | Módulo de Mensajes con la interacción del terminal del puente | PRUEBA 04: **ni sale el cartel**. El juego descarta la interacción antes de dibujarla |
| **C** · misión disparada por la pieza | `StartMissionOnUse` → misión de un stage → recompensa | PRUEBA 02: no pasa nada. La 03 explicó por qué sin repetirla |
| **D** · `GcRewardForceOpenGalaxyMap` | recompensa en el Analizador de Planos | PRUEBA 03: **llegan las 1234 unidades, no llega el mapa**. La recompensa se entrega; esa recompensa concreta no hace nada a pie |
| **E** · interruptor del menú rápido | `DebugGalaxyMapInQuickMenu = true` | PRUEBA 05 negativa, y la PRUEBA 06 la explicó: el archivo no se lee |

El inventario de «qué queda en datos que pueda abrir el mapa galáctico» está a cero. Se
comprobó a fondo: el enum de interacciones tiene **una sola** entrada de mapa
(`FreighterGalacticMap`), `GcRewardOpenPage` no tiene página de mapa entre sus 24 valores, y
en la tabla de cadenas de `libMBIN` no existe `GalaxyMap` ni `GalacticMap` sueltas.

Lo que quedaría es parchear el binario. **Fuera del alcance del proyecto.**

### Lo que se lleva puesto el cierre

- **El nombre provisional no llega a decidirse.** No hay mod que nombrar.
- No hay pieza propia, ni nodo en el árbol del Nexo, ni tiers. Nada de eso se llegó a
  construir: dependía de la PRUEBA 04, que salió negativa.
- Los seis scripts se quedan en `work/scripts/mapa/` como registro. No son mods publicables
  y ninguno debe desplegarse.

### Lo que se salva y sirve para otros mods

Seis pruebas dejaron cosas verificadas que no dependen del mapa galáctico:

| Hallazgo | Prueba | Para qué sirve |
|---|---|---|
| **`StoryUtilityOverrideData.Reward` funciona en una pieza plantada en un planeta, estando a pie** | PRUEBA 03, las 1234 unidades | Vía interacción → recompensa **viva**. Una pieza construible puede dar lo que se quiera, sin misión de por medio |
| **El despliegue va desde `ModBackups\`, no desde `CreatedMODS\`** | PRUEBA 01 | Costó una prueba entera. Ya corregido en el [`README`](README.md), pasos 4 y 5 |
| **El EXML sí es formato de mod**, si se le quitan las marcas `!#` (`-IncludeTagsInEXML_MXML N`) | lectura de `README-How MBIN and EXML coexist.txt` + `AddLSnPG v5.63` | Dos mods pueden convivir sobre el mismo MBIN. Un MBIN entero, no |
| **Anatomía completa de una pieza construible propia** | investigación, sin construir | Cinco archivos, `MBIN_FILE_SOURCE` sintaxis #3 para clonar con `REMOVE`. Todo verificado leyendo datos |
| **`UNLOCKABLEITEMTREES` es el único sitio donde se desbloquea una pieza** | investigación + `AddLSnPG` | Un `GcUnlockableItemTreeNode` en un árbol existente. Sin nodo, la pieza existe y es inalcanzable |
| **`BASEBUILDINGCOSTSTABLE` no es el coste de materiales** | lectura | Es presupuesto de rendimiento. El coste vive en `Requirements` del producto |

### La lección de método, que es la que más costó

Tres pruebas se diseñaron con un control que no distinguía nada:

- **PRUEBA 01:** sin verificar el despliegue. Lo que se leyó como resultado negativo era un
  no-resultado — no había llegado nada al juego.
- **PRUEBA 02:** dos sospechosos empatados y ningún dato para separarlos.
- **PRUEBA 05:** el Nexo como testigo, cuando **el icono de la Anomalía ya sale a pie en
  vanilla**. Si hubiera aparecido no habría probado nada.

Las que sí sirvieron llevaban un testigo imposible de confundir con el comportamiento
normal: **las 1234 unidades** de la 03 y **el HUD apagado** de la 06. Las dos cerraron su
ruta a la primera.

> **Un control solo vale si su efecto es imposible de confundir con vanilla.** Antes de
> construir, escribir la tabla de salidas y comprobar que cada fila dice algo distinto. Si
> dos filas significan lo mismo, la prueba no está lista.

### Estado

**Mod 3 cerrado como fracaso.** `MOD3_MapaGalactico_PRUEBA06` retirado del juego a
`build\_desplegados_inertes_2026-08-04\`. En `GAMEDATA\MODS` no queda ningún archivo del
mod 3.

Los mods 1 y 2 no se ven afectados: ni un solo archivo compartido en ninguna de las seis
pruebas.

---

## [Reabierto] — RUTA F, 2026-08-08

### Por qué se reabre un mod que estaba cerrado

Por un mod de terceros que ya estaba instalado en el juego: **`PSI_Terminus` v1.0**, de
Astra Syndulla. Hace lo que aquí se dio por imposible —una interacción de contexto cerrado,
disponible a pie y en cualquier sitio— y lo hace con **un solo archivo** que ninguna de las
seis pruebas llegó a abrir:

```
METADATA\UI\EMOTEMENU.MBIN
```

### Qué hace, exactamente

Añade una entrada al menú de emotes que es un **clon de `EMOTE_HOLO_SYS`** (el holograma del
sistema solar) con cuatro campos cambiados:

| Campo | `EMOTE_HOLO_SYS` vanilla | `PSI_TERMINUS` |
|---|---|---|
| `PropData.Model` | `...ACCESSORIES\HOLOSOLARSYSTEM.SCENE.MBIN` | `MODELS\PLANETS\BIOMES\COMMON\BUILDINGS\PARTS\COMMONPARTS\TELEPORTER_STATION.SCENE.MBIN` |
| `PropData.Scale` | 1.0 | 0.01 |
| `PropData.IsHologram` | true | false |
| `LinkedSpecialID` | `SPEC_EMOTE15` | *(vacío)* |

Todo lo demás idéntico: misma animación `1H_IDLE_HOLO_01`, mismo icono `HOLOSYSTEM.DDS`,
mismo `ScanEffect`, mismo `LoopAnimUntilMove = EMOTE_HOLO`.

**El mecanismo es el modelo.** El emote invoca una `.SCENE` en la mano, y esa `.SCENE`
arrastra su entidad con el componente de interacción dentro:

```
TELEPORTER_STATION.SCENE.MBIN
    -> TELEPORTER_STATION\ENTITIES\TELEPORTERSTATIONINTERACTION.ENTITY.MBIN
```

No es una pieza construible, no es una misión, no es una recompensa. Es un prop de emote que
trae su propia interacción puesta.

`LinkedSpecialID` vacío es el otro detalle que importa: el emote **no necesita desbloqueo**.
El vanilla `EMOTE_HOLO_SYS` sí lo lleva (`SPEC_EMOTE15`).

### La ruta A estaba mal cerrada por segunda vez

El cierre decía «no existe ningún `.MBIN` que liste las entradas del menú rápido». Sigue
siendo verdad, y sigue sin ser la pregunta. **`METADATA\UI\EMOTEMENU.MBIN` lista las entradas
del menú de emotes**, que cuelga del menú rápido — un nivel más abajo. El barrido de la ruta
A no bajó ahí, y el de la ruta E, que sí barrió los 30 250 identificadores de `libMBIN`,
buscaba palancas de mapa galáctico, no listas de menú.

### Ruta F — el objetivo traducido a este mecanismo

```
EMOTEMENU: entrada nueva
  PropData.Model -> MODELS\COMMON\SPACECRAFT\COMMONPARTS\HANGARINTERIORPARTS\BRIDGETERMINAL.SCENE.MBIN
```

**El paralelismo estructural está verificado, no supuesto.** La entidad del mapa galáctico
vive en la carpeta hermana de su `.SCENE`, exactamente igual que la del teleportador:

| | `.SCENE` | entidad hermana | `InteractionType` |
|---|---|---|---|
| Teleportador (PSI) | `...\COMMONPARTS\TELEPORTER_STATION.SCENE.MBIN` | `TELEPORTER_STATION\ENTITIES\TELEPORTERSTATIONINTERACTION.ENTITY.MBIN` | `Teleporter` |
| Terminal del puente (nuestro) | `...\HANGARINTERIORPARTS\BRIDGETERMINAL.SCENE.MBIN` | `BRIDGETERMINAL\ENTITIES\GALAXYMAPTERMINAL.ENTITY.MBIN` | `FreighterGalacticMap` |

La entidad se descompiló para confirmarlo: `FreighterGalacticMap`, `InteractDistance = 5.0`,
`UseInteractCamera = true`.

### Lo que la ruta F NO promete

**PSI_Terminus no demuestra que se salte ninguna condición de contexto.** `Teleporter` ya
funciona a pie en vanilla; lo que el mod consigue es *llevarlo encima*, no *desbloquearlo*.
`FreighterGalacticMap` es otra cosa: la PRUEBA 04 demostró que en una pieza plantada en un
planeta el juego la descarta antes de dibujar el cartel.

Si esa puerta se cierra por **tipo de interacción**, la ruta F muere igual que la B. Si se
cierra por **contexto de la pieza**, pasa. No hay dato que lo decida, y por eso hay prueba.
Lo que sí ha cambiado es el precio: un archivo, una entrada.

### PRUEBA 07 — construida, desplegada y verificada · **pendiente de probar in-game**

Script: [`../work/scripts/mapa/MOD3_MapaGalactico_PRUEBA07.lua`](../work/scripts/mapa/MOD3_MapaGalactico_PRUEBA07.lua)

```
METADATA\UI\EMOTEMENU.MBIN
    + MOD3_GALMAP     BRIDGETERMINAL.SCENE.MBIN      Scale 0.10
    + MOD3_GALMAP_S   BRIDGETERMINAL.SCENE.MBIN      Scale 0.01
    + MOD3_TELEPORT   TELEPORTER_STATION.SCENE.MBIN  Scale 0.01
```

Los tres son clones del `EMOTE_HOLO_SYS` vanilla con `IsHologram = false` y
`LinkedSpecialID = ""`. Nada más se toca: 32 emotes vanilla intactos.

**Por qué tres entradas y no una.**

- **`MOD3_TELEPORT` es el control**, y replica los parámetros exactos de PSI_Terminus. Su
  trabajo no es teletransportar: es demostrar que **nuestro `ADD` produce un emote que
  funciona**. Sin él, un «no pasa nada» vuelve a dejar sospechosos empatados, que es el
  error que ya costó las PRUEBAS 02 y 05.
- **Las dos escalas matan el confundido de tamaño.** `TELEPORTER_STATION` es una sala entera
  (~20 m) y a 0.01 queda en ~0.2 m en la mano. `BRIDGETERMINAL` es una consola (~2 m): a la
  misma escala quedaría en ~2 cm, y si el juego calcula el alcance de interacción en espacio
  de modelo, eso solo podría leerse como «la interacción está capada» cuando en realidad
  sería «el prop es demasiado pequeño». `MOD3_GALMAP` a 0.10 iguala el tamaño final de PSI;
  `MOD3_GALMAP_S` iguala la escala. Una de las dos cubre cada hipótesis.

**Validado antes de construir.** El bloque generado por el propio script (ejecutado con el
`lua.exe` de AMUMSS, no reescrito a mano) se injertó en una copia del `EMOTEMENU.MXML`
vanilla y se pasó por MBINCompiler: MXML → MBIN compila, y el round-trip MBIN → MXML sale
limpio — **35 emotes (32 + 3)**, modelos y escalas intactos. O sea que el XML era válido
*antes* de que AMUMSS lo tocara.

**Anclaje.** `ADD_OPTION = "ADDbeforeSECTION"` sobre `SPECIAL_KEY_WORDS
{"EmoteID","EMOTE_WAVE"}` — par que aparece **una sola vez** en el archivo (línea 9,
verificado). `EMOTE_WAVE` es el primer emote de la lista vanilla, así que los tres entran
como primeros hijos de `<Property name="Emotes">`.

Build: **1 ADD (líneas 5–175), 0 errores, 0 warnings, 0 notices.** 171 líneas = 3 × 57, el
bloque exacto.

**Desplegado como MBIN desde `ModBackups\`** —que esta vez sí reprodujo el árbol
`METADATA\UI\`— y verificado descompilando de vuelta desde
`GAMEDATA\MODS\MOD3_MapaGalactico_PRUEBA07\`: **19 053 bytes, los mismos que el MBIN
validado a mano**, 35 emotes, las tres entradas con `LinkedSpecialID` vacío.

Save respaldado antes de la prueba: `NMS_saves_2026-08-08_1304_antes-prueba07-mapa`.

### Escaneo de conflictos

- **Ningún `.pak` instalado toca `EMOTEMENU`** — de hecho no hay ni un `.pak` en
  `GAMEDATA\MODS`: los 87 mods de terceros están todos como archivos sueltos.
- El único que lo tocaba era **`PSI_Terminus`**, y **se ha retirado** a
  `build\_desplegados_inertes_2026-08-08\`. Dos mods sobre el mismo archivo dejan el
  resultado ilegible, que es la lección de la PRUEBA 04. Nuestro `MOD3_TELEPORT` cubre su
  función mientras dure la prueba.

> **Hay que devolverlo al terminar.** `PSI_Terminus` lo gestiona Vortex (sus archivos son
> hardlinks a la carpeta de staging), así que lo limpio es volver a desplegarlo desde Vortex
> en vez de arrastrar la carpeta de vuelta a mano.

### Tabla de salidas

Cuatro filas, y cada una dice algo distinto:

| Lo que se observa | Qué significa |
|---|---|
| El mapa galáctico se abre con `MOD3_GALMAP` o `MOD3_GALMAP_S` | **Ruta F buena.** El mod 3 existe |
| `MOD3_TELEPORT` abre el teletransporte; ninguno de los dos del mapa da cartel | El mecanismo funciona y `FreighterGalacticMap` está capada a pie. **Mod 3 muerto por datos, con diagnóstico bueno** |
| Salen los tres emotes pero ninguno hace nada | El fallo es nuestro `ADD`, no el juego. Comparar contra el EXML de PSI_Terminus antes de concluir nada |
| No sale ningún emote nuevo | El MBIN no se está cargando, o un ID de emote nuevo no aparece sin desbloqueo pese a `LinkedSpecialID` vacío |

### Checklist de la prueba in-game

Save de pruebas, **a pie, en un planeta y sin carguero cerca**. No hay que construir nada.

| # | Qué hacer | Qué anotar |
|---|---|---|
| 1 | Cargar el save de pruebas | Que **no** sea la partida buena |
| 2 | Abrir el menú rápido → emotes | **¿Salen los tres `MOD3 *`?** Están los primeros de la rueda |
| 3 | Usar **`MOD3 Teleportador`** primero | Es el control. ¿Aparece algo en la mano? ¿Sale cartel de interacción? ¿Abre el teletransporte? |
| 4 | Usar **`MOD3 Mapa Galactico`** (escala 0.10) | ¿Se ve la consola en la mano? ¿Sale cartel? Texto exacto |
| 5 | Usar **`MOD3 Mapa Galactico S`** (escala 0.01) | Lo mismo. Si uno da cartel y el otro no, es dato de escala |
| 6 | Si se abre el mapa | ¿Galaxia o pantalla rota? ¿La cámara queda bien? |
| 7 | Dentro del mapa | ¿Deja **marcar destino**? |
| 8 | Dentro del mapa | **Si ofrece SALTAR, no pulsarlo.** Anotarlo y salir |
| 9 | Salir | ¿Vuelve el control del personaje? El README de PSI avisa de que la cámara se queda en tercera persona tras teletransportar; se sale moviéndose |
| 10 | Si el juego se cuelga | Cerrar, decirlo, y **no** volver a entrar hasta retirar el mod |

Para revertir: borrar `GAMEDATA\MODS\MOD3_MapaGalactico_PRUEBA07\` y redesplegar
`PSI_Terminus` desde Vortex. No toca el save.

### Nota para el mod, si la prueba sale bien

PSI_Terminus manda el **archivo entero**: 33 emotes, los 32 vanilla más el suyo. Dos mods que
hagan eso se pisan, gane el que cargue el último — y su README lo da por compatible con
Meta-Mod, cosa que no se sostiene con una lista completa por cada lado. El precedente bueno
sigue siendo `AddLSnPG v5.63`: **EXML parcial, solo su bloque, sin marcas `!#`**
(`-IncludeTagsInEXML_MXML N`). Si esto llega a mod publicable, va así, no como MBIN entero ni
como lista completa.

---

## PRUEBA 08 — icono propio en el menú de emotes, 2026-08-08

Lo mismo que la 07 con una sola variable movida: **el icono**. Tres emotes idénticos —el
mismo `BRIDGETERMINAL.SCENE.MBIN`, la misma escala 0.100000— que solo se diferencian en el
`.DDS` que enseñan en la rueda. El objetivo no es la interacción, es contestar si un mod
puede meter arte propio en `EMOTEMENU`.

| Emote | Icono | Arte |
|---|---|---|
| `MOD3_GALMAP_A` | `MOD3_MAPA_01.DDS` | Galaxia espiral, fondo azul redondo |
| `MOD3_GALMAP_B` | `MOD3_MAPA_02.DDS` | Sistema con planetas y órbitas |
| `MOD3_GALMAP_C` | `MOD3_MAPA_03.DDS` | Trazo lineal turquesa sobre transparente |

### Cómo salieron los .DDS

El icono vanilla de referencia se sacó del pak con `hgpaktool.exe`, que sí acepta filtro por
ruta y no hace falta abrir el explorador:

```
hgpaktool.exe -U --upper -A -O <salida> -f "TEXTURES/UI/FRONTEND/ICONS/QUICKMENU/EMOTES/*.DDS" <PCBANKS>
```

`HOLOSYSTEM.DDS` resultó ser **BC7_UNORM 256×256 con 2 mips** (82 068 bytes), no 12 mips como
las texturas de criatura. Los tres PNG de `asset/mapa/` (512×512) se convirtieron con
`tools/Make-NMSTexture.py` usando esa cabecera: **82 068 bytes los tres, idéntico al vanilla**.

**Hubo que arreglar el conversor.** Hacía `convert("RGB")` antes de escalar, que en una piel
de criatura da igual —no tiene alfa— pero en un icono de UI aplastaba el fondo transparente a
negro opaco. Ahora entra en `RGBA` de principio a fin. Comprobado decodificando con Pillow:
esquina `(1,1,1,1)` (alfa ≈ 0) y centro `(255,247,143,255)` opaco.

### Los archivos nuevos van por `ADD_FILES`

No hace falta colocar el `.DDS` a mano en la carpeta desplegada: AMUMSS lo copia con la misma
tabla que usa el mod 5 para la piel del Horror Biológico.

```lua
["ADD_FILES"] = { { ["EXTERNAL_FILE_SOURCE"] = ..., ["FILE_DESTINATION"] = [[TEXTURES\UI\...\MOD3_MAPA_01.DDS]] } }
```

Son **archivos nuevos, no reemplazos**: ningún icono vanilla se toca, así que ningún otro mod
puede chocar por ellos.

### Build y despliegue

`3 files ADDed`, líneas 5–175 añadidas al MXML (171 = 3 × 57), **0 errores, 0 warnings**.
Desplegado desde `ModBackups\` y verificado descompilando el MBIN de
`GAMEDATA\MODS\MOD3_MapaGalactico_PRUEBA08\`: 36 emotes (33 vanilla + 3), los tres con
`Scale 0.100000` y su `Filename` apuntando a `MOD3_MAPA_0X.DDS`.

**La PRUEBA 07 se retiró.** Dos mods sobre `EMOTEMENU.MBIN` es la trampa de la PRUEBA 04, y
07 y 08 lo son entre sí. `PSI_Terminus` sigue fuera, en
`build\_desplegados_inertes_2026-08-08\`.

### Qué mirar in-game

| # | Qué hacer | Qué anotar |
|---|---|---|
| 1 | Menú rápido → emotes | ¿Salen las tres entradas `MOD3 Mapa Galactico 1/2/3`? Van las primeras |
| 2 | Mirar los iconos | **La pregunta de esta prueba.** ¿Se ve el arte propio, o el holograma vanilla, o un cuadro negro/rosa? |
| 3 | Si hay fondo negro alrededor del dibujo | El alfa no sobrevivió al BC7 y hay que revisar el conversor, no el mod |
| 4 | Elegir cuál gusta | Es lo que se queda para el mod |
| 5 | De paso, usar uno | Como la 07 pero solo a escala 0.10: ¿aparece la consola en la mano? ¿sale cartel de interacción? |

Para revertir: borrar `GAMEDATA\MODS\MOD3_MapaGalactico_PRUEBA08\`. No toca el save.

### Lo que se observó in-game con la PRUEBA 08

Los tres iconos propios salen bien en la rueda: **arte propio, sin fondo negro ni cuadro
rosa**. Elegido el **icono 1** (galaxia espiral). La pregunta de la prueba queda contestada:
un mod puede meter texturas nuevas en `EMOTEMENU` por `ADD_FILES`, y el conversor con
cabecera BC7 256×256 / 2 mips y alfa preservado da un `.DDS` que el juego lee.

Y de paso, el dato que nadie esperaba de esta prueba: **el prop en la mano sí sirve
interacciones a pie**. Al usar el emote aparecen opciones de carguero —personalizar el
carguero y la de la flota— pero **no** el mapa galáctico.

Eso no es un fallo del emote. Es que `BRIDGETERMINAL.SCENE` no tiene un terminal: tiene tres.

---

## [Reabierto de nuevo] — el nodo del mapa nace apagado, 2026-08-08

### `BRIDGETERMINAL.SCENE` cuelga tres nodos interactivos

Se descompiló la escena y se recorrieron sus `ATTACHMENT`. Tres locators con interacción,
los tres a ~2 m del origen del modelo (o sea, a ~20 cm en la mano a escala 0.10):

| Locator | Entidad | `InteractionType` | ¿Salió in-game? |
|---|---|---|---|
| `FleetTerminal` | `FLEETTERMINAL.ENTITY` | `ManageFleet` | **sí** |
| `FreighterReserachTerminal` | `FREIGHTERRESERACHTERMINAL.ENTITY` | `CustomiseFreighter` | **sí** |
| `GalaxyMapTerminal` | `GALAXYMAPTERMINAL.ENTITY` | `FreighterGalacticMap` | **no** |

`MPMISSIONTERMINAL` e `INTERACT` existen en la carpeta de entidades pero **no están
atadas** a esta escena.

### El diff son dos campos, y el control es perfecto

`FLEETTERMINAL` es el mejor control que ha tenido este mod: mismo prop, misma escena, misma
distancia, y **coincide con el terminal del mapa en todo lo que suele ser sospechoso** —
`InteractDistance 5.0`, `InteractAngle 360`, `RepeatInteraction false`,
`UseIntermediateUI false`, `UseInteractCamera true`. Uno da cartel y el otro no. Lo único
que los separa:

| Campo | `GALAXYMAPTERMINAL` | los dos que sí salen |
|---|---|---|
| `TriggerAction` | **`INACTIVE`** | `INTERACT` |
| `StoryUtilityOverrideData.Name` | **`""`** | `NPC_NAVIGATOR_OPT_A` / `UI_FRIG_TOKEN_TERM` |

**`INACTIVE` no es casualidad.** Se descompilaron todas las entidades de
`HANGARINTERIORPARTS` y ese valor aparece en dos interacciones: `FreighterGalacticMap` y
`AbandonedFreighterEnd` — la del carguero abandonado, que también nace apagada y la
enciende el guion de la misión. Los cuatro terminales que sí dan cartel llevan `INTERACT`.

Y el `Name` vacío es el mismo `StoryUtilityOverrideData` que la **PRUEBA 03 ya demostró
vivo a pie**, con las 1234 unidades.

### No hay un terminal mejor escondido

Se barrieron los 97 `.pak` buscando `FREIGHTERGALAXYMAP`. En todo el juego existen **dos**
entidades con `InteractionType = FreighterGalacticMap`:

| Entidad | `TriggerAction` | `Name` |
|---|---|---|
| `...HANGARINTERIORPARTS\BRIDGETERMINAL\ENTITIES\GALAXYMAPTERMINAL` | `INACTIVE` | `""` |
| `...INDUSTRIAL\ACCESSORIES\HANGARPARTS\BRIDGE\BRIDGE\ENTITIES\FREIGHTERGALAXYMAP` | `INACTIVE` | `""` |

Configuración **idéntica**. No hay una terminal buena que copiar: hay un interruptor apagado.

### Esto reabre la PRUEBA 04

Lo que se anotó en el cierre fue: «PRUEBA 04: ni sale el cartel. El juego descarta la
interacción antes de dibujarla». La lectura era que `FreighterGalacticMap` está capada por
contexto. Nunca se miró que **el nodo nace apagado en el propio vanilla**, así que el
Módulo de Mensajes de la 04 heredó el `TriggerAction` de la pieza, no el del terminal — y el
resultado es compatible con las dos explicaciones. Otra vez el error de método de siempre:
una prueba cuyas salidas no distinguen.

### PRUEBA 09 — construida, desplegada y verificada · **pendiente de probar in-game**

Script: [`../work/scripts/mapa/MOD3_MapaGalactico_PRUEBA09.lua`](../work/scripts/mapa/MOD3_MapaGalactico_PRUEBA09.lua)

```
METADATA\UI\EMOTEMENU.MBIN
    + MOD3_GALMAP    BRIDGETERMINAL.SCENE.MBIN    Scale 0.10    icono MOD3_MAPA_01.DDS

MODELS\...\BRIDGETERMINAL\ENTITIES\GALAXYMAPTERMINAL.ENTITY.MBIN
    TriggerAction                    INACTIVE -> INTERACT
    StoryUtilityOverrideData.Name    ""       -> SHIP_GALACTICMAP
```

Un solo emote, con el icono elegido en la 08. **Los otros dos terminales no se tocan**: se
quedan dentro del mismo prop haciendo de control, así que la prueba trae su propio testigo
sin gastar una entrada extra.

`SHIP_GALACTICMAP` es una clave real: se sacó escaneando los siete
`LANGUAGE\NMS_LOC*_ENGLISH.MBIN` en crudo. De paso apareció `QUICK_MENU_NO_GALMAP` — el
mensaje de «mapa galáctico no disponible» del menú rápido, que confirma que esa condición
vive en el ejecutable y cierra otra vez la ruta A.

**Anclajes, los dos ya probados en este mod.** `VALUE_MATCH = "INACTIVE"` como la PRUEBA 04,
y `PRECEDING_KEY_WORDS = {"StoryUtilityOverrideData"}` como la PRUEBA 03. Los dos tokens
aparecen **una sola vez** en el ENTITY (verificado), igual que `RepeatInteraction` y
`"TriggerAction"`.

Build: **1 ADD (líneas 5–61, las 57 del emote) + 2 CHANGE + 1 file ADDed, 0 errores,
0 warnings, 0 notices.** El delta de `CreatedMODS` son 15 líneas y ni una de más:

```xml
<Property name="TriggerAction" value="INTERACT" /> !# CHANGED
<Property name="StoryUtilityOverrideData" value="GcStoryUtilityOverride">
  <Property name="Name" value="SHIP_GALACTICMAP" /> !# CHANGED
```

**Desplegado como MBIN desde `ModBackups\`** y verificado descompilando de vuelta desde
`GAMEDATA\MODS\MOD3_MapaGalactico_PRUEBA09\`: `TriggerAction = INTERACT`,
`Name = SHIP_GALACTICMAP`, y `InteractionType = FreighterGalacticMap` /
`SecondaryInteractionType = None` / `InteractDistance = 5.0` **intactos**. `EMOTEMENU`:
33 emotes (32 + 1), el nuestro con su `.SCENE`, escala y `.DDS`.

### Conflictos

- **`PSI_Terminus` había vuelto solo.** Vortex lo redesplegó desde staging, y manda
  `METADATA\UI\EMOTEMENU.EXML` — 91 113 bytes, el archivo entero. Dos mods sobre
  `EMOTEMENU` dejan el resultado ilegible. Se retiró **solo ese EXML** a
  `build\_desplegados_inertes_2026-08-08\PSI_Terminus_vortex\`, dejando en pie el resto de
  la carpeta de Vortex. Para devolverlo: purgar y redesplegar desde Vortex, no arrastrar el
  archivo a mano.
- La PRUEBA 08 se retiró entera al mismo sitio: escribía el mismo `EMOTEMENU.MBIN`.
- Comprobado tras desplegar: en `GAMEDATA\MODS` hay **un solo** `EMOTEMENU` y **ningún**
  otro mod toca `GALAXYMAPTERMINAL.ENTITY`.

Save respaldado antes de la prueba: `NMS_saves_2026-08-08_2218_antes-prueba09-mapa`.

### Tabla de salidas

| Lo que se observa al usar el emote | Qué significa |
|---|---|
| Sale una **tercera** opción y **abre el mapa galáctico** | **Ruta F buena. El mod 3 existe.** El nodo solo estaba apagado |
| Sale la tercera opción pero al pulsarla no pasa nada | El tipo se sirve a pie; lo que está capado es la UI del mapa. Diagnóstico bueno, mod muerto |
| Siguen saliendo **solo las dos de siempre** | `FreighterGalacticMap` está capada por contexto de verdad. Ahí sí se cierra, y esta vez con el control dentro del mismo prop |

### Checklist de la prueba in-game

Save de pruebas, **a pie, en un planeta y sin carguero cerca**.

| # | Qué hacer | Qué anotar |
|---|---|---|
| 1 | Cargar el save de pruebas | Que **no** sea la partida buena |
| 2 | Menú rápido → emotes | ¿Sale `MOD3 Mapa Galactico`? Va el primero, con el icono 1 |
| 3 | Usarlo y mirar la consola en la mano | **¿Cuántas opciones salen: dos o tres?** |
| 4 | Si sale una tercera | El texto exacto del cartel. Debería leerse como "mapa galáctico" |
| 5 | Pulsarla | ¿Galaxia o pantalla rota? ¿La cámara queda bien? |
| 6 | Dentro del mapa | ¿Deja **marcar destino**? |
| 7 | Dentro del mapa | **Si ofrece SALTAR, no pulsarlo.** Anotarlo y salir |
| 8 | Salir | ¿Vuelve el control del personaje? |
| 9 | Si el juego se cuelga | Cerrar, decirlo, y **no** volver a entrar hasta retirar el mod |

Para revertir: borrar `GAMEDATA\MODS\MOD3_MapaGalactico_PRUEBA09\` y redesplegar
`PSI_Terminus` desde Vortex. No toca el save.

> **Ojo con el terminal del puente de verdad.** La PRUEBA 09 edita el ENTITY vanilla, no una
> copia, así que el terminal del mapa del carguero también queda con `TriggerAction = INTERACT`
> mientras esto esté puesto. Si el nodo se encendía por guion, ahora está siempre encendido.
> Para el mod publicable habría que **clonar** el ENTITY con la sintaxis #3 de
> `MBIN_FILE_SOURCE` y dejar el vanilla en paz.

### Lo que se observó in-game con la PRUEBA 09: **siguen saliendo dos opciones**

- El emote sale, **el primero de la rueda y con el icono 1**. `ADD_FILES` + `EMOTEMENU` quedan
  confirmados por segunda vez.
- Al usarlo siguen apareciendo **dos** carteles, no tres. Encender el `TriggerAction` del nodo
  del mapa y darle etiqueta **no lo hace aparecer**.

Es la fila 3 de la tabla de salidas, pero **no cierra nada todavía**, y conviene decir por qué
en vez de dar la ruta por muerta como se hizo con la 01 y la 04. Sigue habiendo dos lecturas:

- **A.** `FreighterGalacticMap` está capada por contexto y el juego la descarta antes de
  dibujar el cartel.
- **B.** El nodo `GalaxyMapTerminal` no llega a evaluarse por algo del prop —posición del
  locator dentro del modelo, oclusión, orden de los `ATTACHMENT`— y el tipo de interacción no
  tiene nada que ver.

`TriggerAction` e `InteractDistance` ya no separan A de B: los tres nodos los tienen idénticos
y aun así uno no sale.

> **Cabo suelto en el reporte, ya resuelto.** Los dos carteles se anotaron como «sensor
> planetario» y «busca», que no cuadraba con «personalizar el carguero» y «la de la flota» de
> la PRUEBA 08. Se resolvió al descompilar los `LANGUAGE` (ver la PRUEBA 10): ninguno de esos
> textos pertenece al prop, y el que se estaba leyendo es `UI_SCAN_ROOM_LABEL`, de una sala de
> sondeo cercana.

### Los textos reales de las tres etiquetas

Sacados descompilando los `LANGUAGE\NMS_LOC*_SPANISH.MBIN` con MBINCompiler. **El grep en
crudo sobre el `.MBIN` no vale**: el archivo guarda la clave y un puntero al texto, no el texto
al lado. Hay que descompilar a `.MXML`, donde cada entrada es un bloque con `Id` y un campo por
idioma.

| Clave | Dónde vive | Texto español |
|---|---|---|
| `SHIP_GALACTICMAP` | `GALAXYMAPTERMINAL` | **Mapa galáctico** |
| `NPC_NAVIGATOR_OPT_A` | `FLEETTERMINAL` | **Ver expediciones potenciales** |
| `UI_FRIG_TOKEN_TERM` | `FREIGHTERRESERACHTERMINAL` | **Terminal de investigación de carguero** |

Guardar esto: es la tabla que hacía falta para leer cualquier prueba futura de este mod sin
adivinar a qué nodo corresponde cada cartel.

---

## PRUEBA 10 — las tres terminales son mapa galáctico, 2026-08-08

Script: [`../work/scripts/mapa/MOD3_MapaGalactico_PRUEBA10.lua`](../work/scripts/mapa/MOD3_MapaGalactico_PRUEBA10.lua)

### Por qué esta y no «voltear el modelo»

La idea de girar el prop para alcanzar el tercer nodo **no tiene dónde escribirse**:
`GcPlayerEmotePropData` solo lleva `Model`, `Scale`, `Hand`, `IsHologram`,
`ScanEffectNodeName`, `ScanEffect` y `DelayTime`. No hay rotación ni desplazamiento. Lo único
parecido sería escala negativa —que espeja el modelo y probablemente rompe las normales— o
cambiar `Hand` de `Left` a `Right`. Ninguna de las dos es una prueba limpia: mueven la
geometría *y* el aspecto a la vez.

La otra idea sí lo es, y además **hace innecesaria la primera**. Si el problema pudiera ser la
posición del nodo, la forma de quitarlo de en medio no es mover el prop: es **poner la
interacción del mapa en los nodos que ya está demostrado que dibujan cartel**.

```
MODELS\...\BRIDGETERMINAL\ENTITIES\FLEETTERMINAL.ENTITY.MBIN
    InteractionType    ManageFleet        -> FreighterGalacticMap

MODELS\...\BRIDGETERMINAL\ENTITIES\FREIGHTERRESERACHTERMINAL.ENTITY.MBIN
    InteractionType    CustomiseFreighter -> FreighterGalacticMap

MODELS\...\BRIDGETERMINAL\ENTITIES\GALAXYMAPTERMINAL.ENTITY.MBIN
    TriggerAction                  INACTIVE -> INTERACT      (se mantiene de la 09)
    StoryUtilityOverrideData.Name  ""       -> SHIP_GALACTICMAP

METADATA\UI\EMOTEMENU.MBIN
    + MOD3_GALMAP    BRIDGETERMINAL.SCENE.MBIN    Scale 0.10    icono MOD3_MAPA_01.DDS
```

**Las etiquetas de los dos nodos buenos no se tocan a propósito.** `NPC_NAVIGATOR_OPT_A` y
`UI_FRIG_TOKEN_TERM` se quedan como están para poder reconocer in-game qué cartel es cuál — y
de paso resuelven el cabo suelto de la 09.

### La prueba sí separa A de B

Es lo que la 09 no hacía:

| Lo que se observa al usar el emote | Qué significa |
|---|---|
| Los dos carteles de siempre siguen saliendo y **abren el mapa galáctico** | **Ruta F viva. El mod 3 existe.** El tipo se sirve a pie; lo que fallaba era el nodo `GalaxyMapTerminal`, no la interacción. El mod se construye sobre el nodo de flota, no sobre el del mapa |
| Los dos carteles siguen saliendo pero **no pasa nada** al pulsarlos | El juego acepta y dibuja `FreighterGalacticMap` a pie; lo que está capado es la UI del mapa. Diagnóstico bueno, mod muerto por datos |
| **Los dos carteles desaparecen** | `FreighterGalacticMap` se descarta antes de dibujar el cartel. Lectura **A** confirmada, y explica de paso la 09, la 04 y la 01 de una vez. Mod muerto, sin cabos |
| Sale un tercer cartel | El nodo del mapa sí se evalúa; lo que pasa es que solo se dibuja cuando el tipo se acepta. Dato nuevo |

Las tres primeras filas son excluyentes y ninguna se puede confundir con «no pasa nada», que es
el fallo de método que costó las PRUEBAS 02, 05 y 09.

### Build y despliegue

Anclajes: `VALUE_MATCH = "ManageFleet"` y `VALUE_MATCH = "CustomiseFreighter"`, el mismo idioma
que la PRUEBA 01 usó con `MessageModule` — esquiva el envoltorio `GcInteractionType` y la
pareja `SecondaryInteractionType`.

Build: **1 ADD (líneas 5–61, las 57 del emote) + 2 CHANGE (mapa) + 1 CHANGE (flota) +
1 CHANGE (investigación) + 1 file ADDed. 0 errores, 0 warnings, 0 notices.** El delta de
`CreatedMODS` deja el envoltorio sin marca en los dos ENTITY nuevos:

```xml
<Property name="InteractionType" value="GcInteractionType">
  <Property name="InteractionType" value="FreighterGalacticMap" /> !# CHANGED
</Property>
```

> **Incidencia de tooling, otra vez el requisito 2.** La primera build murió con
> `LoadAndExecuteModScript.lua:14200: attempt to compare nil with number` — el síntoma que el
> docstring de `Build-Tiers.ps1` atribuye a `NoDefaultCurrentDirectoryInExePath`. La variable
> se había quitado en una llamada anterior de PowerShell, pero **el estado del shell no
> persiste entre llamadas**: hay que quitarla y llamar a `BUILDMOD.bat` en la misma. No se
> construyó con `Build-Tiers.ps1` porque construiría los diez `.lua` de la carpeta.

**Desplegado como MBIN desde `ModBackups\`** y verificado descompilando de vuelta desde
`GAMEDATA\MODS\MOD3_MapaGalactico_PRUEBA10\`:

| ENTITY | `InteractionType` | `TriggerAction` | etiqueta |
|---|---|---|---|
| `GALAXYMAPTERMINAL` | `FreighterGalacticMap` | `INTERACT` | `SHIP_GALACTICMAP` |
| `FLEETTERMINAL` | `FreighterGalacticMap` | `INTERACT` | `NPC_NAVIGATOR_OPT_A` |
| `FREIGHTERRESERACHTERMINAL` | `FreighterGalacticMap` | `INTERACT` | `UI_FRIG_TOKEN_TERM` |

`SecondaryInteractionType = None` e `InteractDistance = 5.0` intactos en los tres.
`EMOTEMENU`: 33 emotes (32 + 1), el nuestro con su `.SCENE`, escala e icono.

### Conflictos

- **La PRUEBA 09 se retiró entera** a `build\_desplegados_inertes_2026-08-08\`: escribía el
  mismo `EMOTEMENU.MBIN` y el mismo `GALAXYMAPTERMINAL.ENTITY`.
- `PSI_Terminus` sigue sin su `EMOTEMENU.EXML`, en el mismo sitio. Comprobado tras desplegar:
  en `GAMEDATA\MODS` hay **un solo** `EMOTEMENU` y **ningún** otro mod toca los tres ENTITY.

Save respaldado antes de la prueba: `NMS_saves_2026-08-08_2309_antes-prueba10-mapa`.

### Checklist de la prueba in-game

Save de pruebas, **a pie, en un planeta y sin carguero cerca**.

| # | Qué hacer | Qué anotar |
|---|---|---|
| 1 | Cargar el save de pruebas | Que **no** sea la partida buena |
| 2 | Menú rápido → emotes | ¿Sale `MOD3 Mapa Galactico`? Va el primero, con el icono 1 |
| 3 | Usarlo y contar los carteles | **¿Cuántos salen: cero, dos o tres?** Cero es un resultado, no un fallo |
| 4 | Copiar el texto **exacto** de cada cartel | Resuelve el cabo suelto de la 09 |
| 5 | Pulsar el primero | ¿Se abre el mapa galáctico? ¿Sigue abriendo la flota / el carguero? ¿No pasa nada? |
| 6 | Pulsar el segundo | Lo mismo. Si uno abre el mapa y el otro no, es dato de nodo |
| 7 | Si se abre el mapa | ¿Galaxia o pantalla rota? ¿La cámara queda bien? ¿Deja **marcar destino**? |
| 8 | Dentro del mapa | **Si ofrece SALTAR, no pulsarlo.** Anotarlo y salir |
| 9 | Salir | ¿Vuelve el control del personaje? |
| 10 | Si el juego se cuelga | Cerrar, decirlo, y **no** volver a entrar hasta retirar el mod |

Para revertir: borrar `GAMEDATA\MODS\MOD3_MapaGalactico_PRUEBA10\` y redesplegar `PSI_Terminus`
desde Vortex. No toca el save.

> **Esta prueba rompe más que las anteriores.** Edita los ENTITY vanilla de los tres
> terminales, así que mientras esté puesta **el puente del carguero de verdad pierde la gestión
> de flota y la personalización del carguero**: los tres botones intentan abrir el mapa. Es save
> de pruebas y nada más. Para el mod publicable hay que clonar los ENTITY con la sintaxis #3 de
> `MBIN_FILE_SOURCE`.

### Resultado de la PRUEBA 10: **el prop se queda sin carteles**

Probado con NMS reiniciado, así que es la 10 y no la 09.

- Al usar el emote sale **un solo cartel**, contra los dos de la 09.
- Al pulsarlo **no abre el mapa**: abre otra cosa.
- El texto que se leyó es «activar sonda planetaria».

Ese texto es la clave `UI_SCAN_ROOM_LABEL` (`NMS_LOC7`), y **no aparece en ninguno de los tres
ENTITY del puente** — se comprobó grepeando los tres `.MXML` descompilados desde
`GAMEDATA\MODS`. Es una **sala de sondeo** del entorno, no el prop de la mano.

O sea que el prop no dibujó **ningún** cartel. Es la tercera fila de la tabla de salidas, la
que dice «los dos carteles desaparecen».

### La escena no esconde un cuarto nodo

Se descompiló `BRIDGETERMINAL.SCENE` entera y se listaron sus referencias a `.ENTITY.MBIN`:

| Entidad enganchada | ¿Interacción? |
|---|---|
| `FLEETTERMINAL` | sí |
| `FREIGHTERRESERACHTERMINAL` | sí |
| `GALAXYMAPTERMINAL` | sí |
| `GALAXY`, `MIDDLEEFFECT`, `SPINNYTHINGY` ×2, `STATICPHYSICS`, `TKROTATEVERYSLOW` ×3 | no |

`MPMISSIONTERMINAL` (que sí lleva `MPMissionGiver`) e `INTERACT` **no están enganchadas** a la
escena, como ya se había anotado. Y cada uno de los tres ENTITY tiene **una sola**
`GcInteractionComponentData` — se verificó listando todas las apariciones, no solo la primera.
No hay un cuarto sitio de donde pudiera salir un cartel.

### Ruta F cerrada, y esta vez con el control dentro

Es el resultado que la PRUEBA 09 no podía dar. El experimento controlado es limpio:

| Nodo | Interacción en la 09 | ¿Cartel? | Interacción en la 10 | ¿Cartel? |
|---|---|---|---|---|
| `FLEETTERMINAL` | `ManageFleet` | **sí** | `FreighterGalacticMap` | **no** |
| `FREIGHTERRESERACHTERMINAL` | `CustomiseFreighter` | **sí** | `FreighterGalacticMap` | **no** |
| `GALAXYMAPTERMINAL` | `FreighterGalacticMap` | no | `FreighterGalacticMap` | no |

Mismo prop, misma escena, mismo locator, mismo `TriggerAction = INTERACT`, misma
`InteractDistance = 5.0`. **Lo único que cambió es el valor de `InteractionType`, y el cartel
desapareció.** No es la posición del nodo, no es el `TriggerAction`, no es la escala, no es la
etiqueta: es el tipo de interacción.

**`FreighterGalacticMap` se descarta antes de dibujar el cartel cuando no hay contexto de
carguero.** Y explica de una vez las tres pruebas que habían quedado ambiguas:

- **PRUEBA 01 y 04** (`MessageModule` → `FreighterGalacticMap`, sin botón): mismo mecanismo,
  no era que el EXML rompiera el nodo ni que la pieza fuera la equivocada.
- **PRUEBA 09** (encender el `TriggerAction` del nodo del mapa): no podía funcionar. El nodo
  nace apagado *y además* su tipo está capado; encender uno solo no bastaba.

### Inventario final: no queda nada en datos

Con esto se agotan las tres vías del inventario que se cerró tras la PRUEBA 03:

| Vía | Estado |
|---|---|
| `GcInteractionType = FreighterGalacticMap` | **Muerta a pie — PRUEBA 10** |
| `GcRewardForceOpenGalaxyMap` | Muerta a pie — PRUEBA 03 |
| `GcRewardOpenPage` con página de mapa | No existe esa página |

Y las rutas A y E ya estaban cerradas porque la condición vive en el ejecutable — lo confirmó
de paso la cadena `QUICK_MENU_NO_GALMAP` encontrada al preparar la 09.

**El mod 3 no sale por datos.** Abrir el mapa galáctico a pie pide parchear el binario, que
está fuera del alcance de este proyecto. Diez pruebas, y el cierre es con dato y con control,
no con suposición.

### Qué se queda como resultado aprovechable

Aunque el mod no salga, tres cosas de aquí sirven para otros mods:

- **Un mod puede meter emotes nuevos en `EMOTEMENU`** con `ADD_OPTION = "ADDbeforeSECTION"` y
  `SPECIAL_KEY_WORDS {"EmoteID","EMOTE_WAVE"}`, y salen los primeros de la rueda.
- **Un mod puede meter texturas propias de UI** por `ADD_FILES`: BC7 256×256 con 2 mips y alfa
  preservado, generadas con `tools/Make-NMSTexture.py`.
- **El prop de un emote sirve interacciones a pie** — las de flota y carguero salieron. Lo que
  está capado es *esa* interacción, no el mecanismo. Cualquier `GcInteractionType` que no exija
  contexto de carguero debería funcionar desde un emote.

Ese último punto es la puerta que queda abierta, y no para el mapa galáctico.

### Limpieza pendiente

- Retirar `GAMEDATA\MODS\MOD3_MapaGalactico_PRUEBA10\` — mientras esté puesta, el puente del
  carguero de verdad no gestiona flota ni personaliza el carguero.
- Redesplegar `PSI_Terminus` desde Vortex (purgar y desplegar, no arrastrar el `EMOTEMENU.EXML`
  de vuelta a mano).
