# Mod 2 — Horrible Terror · Infestación · 4 configuraciones

**El mod completo: contiene al mod 1 y le añade el mundo infestado.** Es el que se instala y
se juega.

Versión **0.9.2**. Changelog propio:
[`../../../docs/CHANGELOG-MOD2.md`](../../../docs/CHANGELOG-MOD2.md)

## La relación entre los dos mods — decidida el 2026-08-09

**El mod 2 contiene al mod 1.** Se instala uno **o** el otro, nunca los dos.

| | Mod 1 · `HorribleTerror_Predators` | Mod 2 · `HorribleTerror_Infestation` |
|---|---|---|
| Versión | 2.1.1 | **0.9.2** |
| Qué es | la conducta sola, como producto aparte | **la conducta + el mundo + (pronto) los modelos** |
| Instalado | **no** | **sí** |
| Rutas | 7 | **12** |

> ⚠️ **Hubo un intento de repartirlos por tipo de cambio (0.4.0, misma tarde) y se
> descartó.** La idea era que mod 1 llevara la conducta y mod 2 solo la colocación, para
> poder instalarlos juntos. Se construyó, se desplegó y se revirtió el mismo día: **lo que
> tiene que diferenciar a los dos mods son los modelos de los monstruos, no el tipo de
> campo.** Queda anotado para no volver a proponerlo.

**Lo que va a diferenciar al mod 2 es el modelado.** Todo lo de conducta lo comparten por
definición; lo propio del mod 2 será: monstruos con nuestras mallas, sus texturas, sus
colores, y dónde aparecen.

## Qué contiene

| Qué | Viene de | Tiers | Estado |
|---|---|---|---|
| Conducta y agresividad de depredadores y Fiends | **mod 1** | los 4, escalado | ⬜ ver `PENDIENTES.md` |
| Brood: llaman a las crías al rugir | **mod 1** | solo Hardcore | ✅ 2026-08-09 |
| Densidad de huevos de Horror | propio | los 4, ×2 / ×5 / ×20 / ×20 | ✅ probado |
| Densidad del gusano de arena | propio | los 4, mismo multiplicador | ✅ probado |
| Huevos dentro de los edificios abandonados | propio | **solo Hardcore** | ❌ **sin medir** → prueba **P1** |
| Modelos propios de monstruo | propio | — | ⬜ **es el trabajo que sigue** |

## Qué va a entrar (el trabajo que sigue)

Este es el mod donde aterriza todo lo de aspecto y modelado. Hoy siguen como mods de prueba
aparte porque **ninguno ha pasado en partida**, y meter algo sin probar en el mod publicado
haría imposible atribuir un crash:

| Mod de prueba | Qué | Entra cuando |
|---|---|---|
| `HT_FiendMarkers_PRUEBA01` | un color por tipo de Horror | pase la prueba **P3** |
| `HorribleTerror_NecroSkin` | textura `.DDS` propia | deje de salir blanca |
| `HT_PredatorParts_PRUEBA01` | quitar piezas del `.DESCRIPTOR` | ya pasó (5.1, 5.3) — falta decidir el reparto de piezas |
| `HorribleTerror_DerelictBugs` | salas de carguero infestadas | ya pasó (3.2) — se puede fusionar |
| Sonda de `ReferencePaths` | ¿el juego resuelve una ruta a un `.SCENE` ajeno? | **sin escribir**, ver abajo |

### 🔓 2026-08-09 — la forma del XML resuelta, la inyección todavía no

**Resuelto:** una lista de strings se serializa **repitiendo el nombre en el hijo**, con
`_index`. El molde salió de `ValidRoomIDs` en `FREIGHTERDUNGEONSTABLE`:

```xml
<Property name="ReferencePaths">
  <Property name="ReferencePaths" value="MODELS\PLANETS\CREATURES\ARTHROPOD\BUGFIEND.SCENE.MBIN" _index="0" />
</Property>
```

**Verificado empíricamente, sin tocar el juego:** se metió a mano en el MXML del descriptor,
MBINCompiler lo compiló (37040 → 37112 bytes) y al descompilar **la ruta volvió intacta**.
La forma es válida y MBINCompiler la entiende; no la descarta.

**Lo que falta:** la regla de AMUMSS que la inyecta **no aterriza**. Está escrita en el
Hardcore con `SPECIAL_KEY_WORDS = {"Name", "_Head_TRex"}` (ancla **única** en el archivo),
`LINE_OFFSET = "1"` y `ADD_OPTION = "REPLACEatLINE"`. El log dice
`Lines 515 - 517 ADDED` y 41 acciones, pero **el MBIN resultante sale idéntico a vanilla
(37040 bytes, sin la cadena `BUGFIEND`)**.

La pista está en el número: `_Head_TRex` está en la línea **515** y `ReferencePaths` en la
**516**. O sea que el `LINE_OFFSET` no se aplicó como se esperaba y el bloque reemplazó la
línea del propio `Name`, dejando el nodo sin nombre — y de ahí que el resultado se descarte.

**Siguiente intento:** anclar directamente sobre la línea de `ReferencePaths` en vez de
desplazarse desde `Name`. `ADD` **no cuenta como CHANGE** en el `REPORT` (igual que
`REMOVE`), así que el conteo de 40 no sirve de verificación: **hay que descompilar el MBIN y
buscar la cadena.**

⚠️ **Conflicto a tener en cuenta cuando aterrice:** `HT_PredatorParts_PRUEBA01` escribe el
**mismo** `TREX.DESCRIPTOR.MBIN`, y los dos son MBIN completos: el que cargue después gana en
silencio. Mientras se pruebe la sonda hay que sacar `HT_PredatorParts_PRUEBA01` de
`GAMEDATA\MODS`, o no se sabrá cuál de los dos manda.

### ⬜ Contexto: por qué esta sonda importa

Es la prueba que decide si hace falta Blender: si el juego resuelve una ruta puesta en el
campo `ReferencePaths` de un descriptor, se pueden mover mallas vanilla entre rigs sin
exportar nada. Ver [`ASSETS.md`](../../../docs/ASSETS.md) §3 y §4.3.

**Lo que falta para escribirla:** en `TREX.DESCRIPTOR` el campo está **vacío en los 172**
descriptores, y en EXML se serializa como `<Property name="ReferencePaths" />` — una
propiedad sin valor. `VALUE_CHANGE_TABLE` no puede escribir ahí: hace falta `ADD` con
`ADD_OPTION = "REPLACEatLINE"` **inyectando XML**, y para eso hay que ver primero cómo
serializa una lista `ReferencePaths` **no vacía**. No hay ejemplo vanilla en este archivo.

Inventar el XML a ciegas y meterlo en el mod publicado es la forma de conseguir un crash que
no se puede atribuir. **El paso previo es extraer un descriptor y buscar un ejemplo real.**

## Conteo esperado por build

Si `REPORT` no da estos números, **no se despliega**.

| Config | Total | Desglose (gen + predtables + globals + nidos + uiglobals + árbol + datatable + eggs + infest) |
|---|---:|---|
| 1 Fácil | **20** | 4 + 2+2 + 2 + — + — + — + — + 4 + 6 |
| 2 Normal | **58** ⬆️ `0.9.2` | 5 + 2+2 + 35 + — + — + 1 + 3 + 4 + 6 |
| 3 Difícil | **64** ⬆️ `0.9.2` | 5 + 2+2 + 36 + — + — + 2 + 7 + 4 + 6 |
| 4 Hardcore | **83** | 5 + 2+2 + 39 + 2+2+1 + 1 + 2 + 17 + 4 + 6 |

**Verificado el 2026-09-10** contra NMS **178763 (7.0 Cosmos)**: Fácil 20, Normal **58** y Difícil
**64**, los tres con **0 errores y 0 warnings**. Normal y Difícil suben de 45 y 50 porque la
`0.9.2` les baja, escaladas, las palancas que sólo tenía el Hardcore: +11 en `globals` y +2 / +3
en el `datatable` de cada uno.

> ⚠️ **El Hardcore dio 82, no 83, en esa misma vuelta, y no es del mod.** El MBINCompiler
> instalado es el **7.0.0.1**, que **no descompila `GCUIGLOBALS.GLOBAL`** —`MbinException:
> Non-negative number required`— y ese archivo sólo lo toca el Hardcore. Se construye con
> **7.00.0-pre1** cuando haya que rehacerlo. No afecta a la `0.9.2`: el Hardcore no se resube.

> La tabla anterior decía 23 / 45 / 50 / 101 y estaba desfasada: contaba un L-System ×3 que el
> script no declara desde la 0.4.0, y para Fácil 5 en `gen` y 4 en `globals` cuando ese `.lua`
> pide 4 y 2. Normal y Difícil no se movieron ni con el cambio de versión del juego.

**Estos totales son idénticos a los de 0.3.3**, y eso es la verificación: 0.5.0 no cambia ni
un valor respecto a 0.3.3, solo reordena de dónde sale cada bloque. Si un tier no da su
número, la composición perdió o duplicó algo.

**Cómo se compone.** Los bloques de conducta son **los mismos** que los del mod 1: mod 2 se
arma como *bloques del mod 1 + bloques de mundo*. Cuando se cambie un valor de conducta hay
que tocarlo en el tier del mod 1 y volver a componer aquí, o los dos mods se separan sin que
nadie se dé cuenta. **El conteo es lo que lo delata:** mod 2 tiene que dar siempre
mod 1 + 10 (y + 40 en Hardcore, que además lleva los edificios).

| Tier | Mod 1 | Mundo | Mod 2 |
|---|---:|---:|---:|
| Fácil | 13 | 10 | **23** |
| Normal | 35 | 10 | **45** |
| Difícil | 40 | 10 | **50** |
| Hardcore | 61 | 40 | **101** |

### Histórico

| Versión | Fácil | Normal | Difícil | Hardcore |
|---|---:|---:|---:|---:|
| 0.1.0 | 23 | 27 | 27 | 28 |
| 0.2.0 | 23 | 33 | 37 | 41 |
| 0.3.0 | 23 | 45 | 50 | 54 |
| 0.3.1 | 23 | 45 | 50 | 60 |
| 0.3.2 | 23 | 45 | 50 | 97 |
| 0.3.3 | 23 | 45 | 50 | 101 |
| ~~0.4.0~~ (reparto, revertido el mismo día) | ~~10~~ | ~~10~~ | ~~10~~ | ~~40~~ |
| **0.5.0** | **23** | **45** | **50** | **101** |

0.5.0 vuelve a los números de 0.3.3 porque vuelve a contener al mod 1. **0.4.0 no se
considera una versión jugada:** se construyó, se desplegó y se retiró sin partida.

> ⚠️ **Esta cuenta se dejó de llevar en la 0.5.0.** De la `0.6.0` a la `0.9.0` el recuento por
> tier no se ha vuelto a hacer, y **la lista viva de campos vive en
> [`../../../docs/MODIFICACIONES.md`](../../../docs/MODIFICACIONES.md)**, que sí está al día.
> Para dar un número de aquí hay que volver a contarlo contra el `.lua`, no estimarlo.

## Rutas que toca — 12

```
METADATA\SIMULATION\ECOSYSTEM\CREATUREGENERATIONDATA.MBIN
METADATA\SIMULATION\ECOSYSTEM\GROUND\GROUNDTABLEPLAYERPREDATOR{MED,LARGE}.MBIN
METADATA\SIMULATION\ECOSYSTEM\CREATUREDATATABLE.MBIN
METADATA\SIMULATION\ECOSYSTEM\CREATUREBEHAVIOURTREES.MBIN
GLOBALS\GCCREATUREGLOBALS.MBIN
GLOBALS\GCUIGLOBALS.GLOBAL.MBIN
MODELS\...\INFESTATION\{LARGEPILLARSLIME,MEDIUMHANGSLIME}\ENTITIES\*.ENTITY.MBIN
METADATA\SIMULATION\SOLARSYSTEM\BIOMES\OBJECTS\RARE\FIENDEGGS.MBIN
METADATA\SIMULATION\SOLARSYSTEM\BIOMES\OBJECTS\RARE\INFESTATION.MBIN
MODELS\PLANETS\BIOMES\COMMON\BUILDINGS\ABANDONED\ABANDONDED{SCIENTIFIC,TRADER,WARRIOR}.LSYSTEM.MBIN
```

Las siete primeras son las del mod 1 — **por eso no se instalan los dos**. Las tres
`LSYSTEM` solo las toca Hardcore. Fácil toca 5.

⚠️ **`GCCREATUREGLOBALS.MBIN` y `GCUIGLOBALS.GLOBAL.MBIN` salen de `ModBackups` en la raíz de
la carpeta, no en `GLOBALS\`.** Copiados tal cual, el juego no los lee y se pierden en
silencio la mitad de los cambios. **Al desplegar hay que moverlos a `GLOBALS\`.**

De los 87 mods de terceros, la única ruta disputada es `GCUIGLOBALS`, contra
`Small Cursor 6.6`.

## Las trampas que hay que respetar al editar

**1 · Los dos bloques de densidad.** Cada objeto de `FIENDEGGS` / `INFESTATION` lleva
`QualityVariants` (los valores reales) y `QualityVariantData` (`Coverage 0.2` /
`FlatDensity 0.5`, **idéntico en los cinco objetos** — struct por defecto). Multiplicar
`FlatDensity` a secas tocaría los dos: de ahí el `VALUE_MATCH` con el valor vanilla exacto.

`Coverage` **no se toca**: los valores reales son 0.1, 1.0 y 2.0 y no se conoce el rango
válido — ×20 sobre 2.0 podría salirse.

**2 · La trampa de orden.** Las reglas de un mismo archivo se aplican **en secuencia**, así
que un valor ya escrito puede encajar en el `VALUE_MATCH` de una regla posterior. En Normal
(×5) pasó: la regla de huevos subía `0.005 → 0.025` y la del gusano (`VALUE_MATCH 0.025`)
los volvía a multiplicar. `FlatDensity` acabó en ×25 y solo un conteo por tier lo delató.

**El arreglo, y sigue vigente: en `INFESTATION` el gusano va primero y los huevos últimos.**

**3 · El locator del edificio.** La regla del modelo casa por `VALUE_MATCH` con la ruta de
`INTERIOR_TENTACLEPLANT.SCENE.MBIN` — con **barras normales**, no invertidas, que es como
está en el MXML. La de probabilidad va anclada por `{"LocatorType", "TENTACLE_"}`.

⚠️ **`EGG_PROB = 100` es la primera palanca a bajar** si el interior resulta injugable: 30-50
antes de tocar nada más.

## Valores vanilla verificados

NMS 170671, MBINCompiler 6.45.0.1.

**`FIENDEGGS.MBIN`** — 2 objetos, los dos `FIENDEGG.SCENE`:

| Objeto | Placement | FlatDensity | SlopeDensity | Coverage |
|---|---|---|---|---|
| `Objects[0]` | `FLORACLUMP` | 0.005 | 0.005 | 0.1 |
| `DetailObjects[0]` | `RAREX` | 0.005 | 0.005 | 2.0 |

**`INFESTATION.MBIN`** — 3 objetos:

| Objeto | Modelo | Placement | FlatDensity | SlopeDensity | Coverage |
|---|---|---|---|---|---|
| `WORMSPAWNER` | `GROUNDWORMSPAWNER` | `WORDSTONE` | 0.025 | 0.030 | 1.0 |
| `FIENDEGGS` | `FIENDEGG` | `FLORACLUMP` | 0.005 | 0.005 | 0.1 |
| (sin nombre) | `FIENDEGG` | `RAREX` | 0.005 | 0.005 | 2.0 |

## Cómo construir

```
tools\Build-Tiers.ps1 -Carpeta infestacion
```

Construye los 4 de una pasada y archiva cada salida en `build\infestacion_<fecha>\` con su
log y su `REPORT`. Comprobar los totales **en las cuatro**: el bug de cascada de 0.1.0 solo
aparecía en una.

Desplegar copiando los `.MBIN` de `tools\AMUMSS\ModBackups\<nombre>\` a
`GAMEDATA\MODS\<nombre>\`. **El EXML de `CreatedMODS` es un informe, no despliega nada.**
NMS solo carga mods **al arrancar**.

## Aplazado

- **`GcAntagonistComponentData` en el huevo salvaje** — para que los Fiend salgan sin romper
  el huevo, a ~5 m. Hay molde vanilla (el huevo construible, percepción `HIVE_MIND` de
  `Range 6.0`), pero exige **añadir un componente** a un `.ENTITY.MBIN`, no cambiar un valor.
  Ver [`COMPORTAMIENTO.md`](../../../docs/COMPORTAMIENTO.md) §8.
- **`Chance > 0` en un descriptor** — los 172 valen 0.0 en vanilla; no hay ejemplo del que
  copiar la escala.
