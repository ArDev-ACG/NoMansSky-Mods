# Modelos

Una ficha por malla que hemos metido al juego: **qué es**, **a quién sustituye**,
**cómo se hizo** y **qué salió mal**. La receta general —los once pasos y por qué
cada uno— vive en [`../RECETA-PIEL.md`](../RECETA-PIEL.md); aquí sólo va lo que
cambia de un modelo a otro.

Los parámetros de verdad están en `tools/Export-NMSMesh.py` (`MODELOS`) y en
`tools/Weight-NMSMesh.py`. Si una ficha y el `.py` no coinciden, **manda el `.py`**.

## Los que están publicados — `releases/models-0.1.2`

| Ficha | Sustituye a | Rig | Dónde sale en el juego |
|---|---|---|---|
| [skullCrawler](skullCrawler.md) | `FREIGHTERFIEND` | `SPIDERRIG` | el horror de los cargueros abandonados |
| [cryWolf](cryWolf.md) | `FIEND` | `SPIDERRIG` | el horror grande que sale del huevo en planetas infestados |
| [warriorBug](warriorBug.md) | `BUGFIEND` | `ARTHROPOD` | las crías que el horror grande escupe en combate |
| [markerEgg](markerEgg.md) | `FIENDEGG` | — (estático) | los huevos del suelo infestado |
| [facehuggerEgg](facehuggerEgg.md) | `FIENDEGG` | — (estático) | los mismos huevos. **Releva al markerEgg: los dos escriben el mismo archivo y no se instalan a la vez** |

## 0.1.2 — entra el facehuggerEgg, y `ModBackups` casi lo estropea

**Los cuatro modelos de la `0.1.1` no cambian ni un byte.** Lo único nuevo es el
quinto, el [facehuggerEgg](facehuggerEgg.md), y la versión sube para que la tanda
vaya junta.

**De dónde salen los binarios, que aquí estuvo el peligro.** Empaquetar desde
`tools/AMUMSS/ModBackups/` —que es lo que dice el guión por defecto— habría
deshecho el arreglo de la `0.1.1`: ahí los `.GEOMETRY` siguen en el **formato de
vértice viejo**, stride 20, porque el repack del 18/09 se aplicó al zip y a
`GAMEDATA\MODS` y no a `ModBackups`. Medido en el cryWolf: 513 252 B contra los
468 852 B del zip, **4 bytes por vértice** de diferencia.

Y había una segunda: `ModBackups\HT_CryWolf_PRUEBA07` contenía también el
`BUGFIEND` y el `FREIGHTERFIEND` de los otros dos mods, que el guión habría
empaquetado dentro del cry wolf.

**Cómo se hizo entonces.** Origen limpio montado aparte y pasado con `-Origen`:
los cuatro de la `0.1.1` salen **de sus propios zips**, verificados por md5, y el
facehuggerEgg sale de `GAMEDATA\MODS`, que es lo único suyo probado en partida
—también verificado por md5, los seis archivos—. Las dos trampas quedan escritas
en [`../NEXUS-SUBIDA.md`](../NEXUS-SUBIDA.md) §1.5 y §1.6.

## 0.1.1 — la reconstrucción del `.SCENE` por 7.0

**Los cuatro `.SCENE.MBIN` de la `0.1.0` estaban construidos contra 6.45 y NMS 7.0
cambió esa plantilla.** `TkSceneNodeData` ganó un campo, `InstanceTransforms`, entre
`Attributes` y `Children`: **16 bytes por nodo** que el archivo viejo no trae. El juego
lee `Children` donde ahora vive `InstanceTransforms`, se va a leer punteros de basura y
**cierra sin decir nada**.

Lo reportó un jugador el 2026-09-17: el cry wolf, el warrior bug y el skull crawler
cierran el juego **al empezar partida nueva, poco después de la pantalla de estrellas**.

Cuanto más profundo el árbol de nodos, más lejos se va la lectura — y por eso el
markerEgg, que son **3 nodos**, aguantaba y los bichos no:

| Mod | Nodos | `.SCENE` 6.45 | `.SCENE` 7.02 |
|---|---:|---:|---:|
| infestedMarkerEgg | 3 | 1 711 B | 1 759 B |
| infestedCryWolf | 53 | 11 208 B | 12 056 B |
| infestedWarriorBug | 61 | 11 196 B | 12 172 B |
| infestedSkullCrawler | 120 | 21 897 B | 23 817 B |

**Sólo cambia el `.SCENE`.** Se comprobó fichero a fichero: `.GEOMETRY`,
`.GEOMETRY.DATA`, `.MATERIAL`, `.DESCRIPTOR`, `.TEXTURE` y `.ENTITY` conservan el mismo
`TemplateGUID` **y el mismo hash de plantilla** entre 6.45 y 7.02, y `MBINCompiler 7.02`
los descompila sin una queja. Ni un vértice, ni un peso, ni una textura se han tocado.

**Cómo se arregló.** Recompilando el `.SCENE.MXML` que ya estaba en `work/models/` con
`MBINCompiler 7.02`, que escribe el `InstanceTransforms` vacío —que es exactamente lo
que trae el vanilla de 7.0—. La ida y vuelta se verificó: el XML del `.MBIN` nuevo es
idéntico al de partida salvo ese campo. Los cuatro pasan
[`../../tools/Check-NMSGraft.py`](../../tools/Check-NMSGraft.py).

> 🔎 **Cómo se ve sin entrar al juego.** El byte `0x18` de un `.MBIN` es el major de NMS
> y el `0x19` el minor (`06 2d` = 6.45, `07 02` = 7.02), y los bytes `0x10..0x17` son el
> hash de la plantilla. Para `TkSceneNodeData` ese hash pasó de `42a57794f683f216` a
> `ad96a863591f02d8` **en 7.00**. Más rápido todavía: si `MBINCompiler` de la versión del
> juego dice *«File not recognized»*, ese archivo no lo puede leer el juego tampoco.

## 0.1.1, segunda vuelta — el formato de vértice de 7.x

**El `.SCENE` no era todo.** Con la reconstrucción de arriba el juego dejó de cerrarse,
pero el 2026-09-17 los cuatro modelos salieron **traslúcidos**: se veía la silueta y se
veía a través de ellos. Medido en partida: *«Ninguno de los 4 modelos se ve»*, y después
*«aparecen invisibles o transparentes»*.

**La causa no era el material ni la textura** —los dos se comprobaron y estaban bien—.
NMS 7.x **cambió el stream de vértices**:

| | Antes (6.45) | Ahora (7.x) |
|---|---|---|
| con piel | stride **20** · `sem2` normal, `sem3` tangente, `sem5` hueso, `sem6` peso | stride **16** · `sem5` hueso, `sem6` peso, `sem11` normal+tangente |
| estático | stride **8** · `sem2`, `sem3` | stride **8** · `sem4` color de vértice, `sem11` |

Las cuatro mallas vanilla miradas el 18/09 —`bugfiend`, `freighterfiend`, `fiendegg` y
`rockspider`— llevan `sem11` y ninguna lleva `sem2` ni `sem3`.

**Cómo se descifró `sem11`.** El repo guardaba el `fiend` vanilla extraído en agosto
(formato viejo) y el mismo `fiend` sale del `.pak` de hoy (formato nuevo): misma malla,
20 509 vértices, mismo orden, o sea correspondencia vértice a vértice.

- **bits 0-19 — la normal.** Octaédrica, dos campos de 10 bits **sin signo** centrados en
  512. **Verificado:** producto escalar contra la normal vieja = `1.00000` de media y
  `1.0000` en el peor de los 20 509 vértices.
- **bits 20-31 — el tangente. NO descifrado.** Se probaron octaédrica 6+6 y ángulo de 12
  bits sobre base de Frisvad con cuatro desfases; ninguno pasa de `|dot| 0.66`, que es
  casi azar. Se escribe el menos malo. **Esto afecta al relieve del normal map, no a la
  opacidad**: si un bicho sale sólido pero con el relieve raro, el culpable son esos 12
  bits.

Los índices, las posiciones y las UV **no se tocan**: viven en otros streams que el parche
no cambió. La herramienta es
[`../../tools/Repack-NMSVertex.py`](../../tools/Repack-NMSVertex.py).

**Y los `.MATERIAL` sí estaban caducados**, al contrario de lo que decía la vuelta
anterior. `TkMaterialData` pasó de `2420d614c64ab698` a `2cedccfc38e5f1a9`, y el
`.TEXTURE` del skull crawler de `37b59638b4a71db1` a `2548c70c5de57f08`. No se
reconvierten: se parte del vanilla de 7.02 y se le ponen encima **sólo nuestras rutas
`Map`**. El único valor que cambia con la versión es `gDynamicFlags`, de **1539 a 3075**.

> ⚠️ **El `.DESCRIPTOR` del warrior bug sigue con sello `6.45.0.1` y eso está bien.** Su
> plantilla (`96ff0e9418d14814`) **no cambió** en 7.02 y `MBINCompiler.latest` lo lee sin
> una queja. **El sello no decide; la plantilla sí.**

**Lo que se entregó en `releases/models-0.1.1`** (2026-09-18, reempaquetado sobre la misma
versión):

| Mod | Stride nuevo | Canales | Los zips son |
|---|---:|---|---|
| infestedCryWolf | 16 | `[5, 6, 11]` | **byte a byte lo que corre en el juego** (md5) |
| infestedWarriorBug | 16 | `[5, 6, 11]` | **byte a byte lo que corre en el juego** (md5) |
| infestedSkullCrawler | 16 | `[5, 6, 11]` | **byte a byte lo que corre en el juego** (md5) |
| infestedMarkerEgg | 8 | `[4, 11]` | reconstruido aparte, **sin jugar** |

El markerEgg va aparte porque **no está desplegado**: lo relevó el facehugger, que escribe
los mismos archivos. Su geometría se repacó igual (1708 vértices) y su material se levantó
del que corre en el facehugger cambiándole las dos rutas `Map` a `MARKER.BASE.DDS` y
`MARKER.BASE.NORMAL.DDS` —los dos materiales sólo se diferencian en eso—. Pasa
[`../../tools/Check-NMSGraft.py`](../../tools/Check-NMSGraft.py), pero **nadie lo ha visto
en partida**.

Los binarios viejos, antes del repacado, quedan en
`backups/GEOMETRY_6.45_pre-7.02_2026-09-18/`, y los zips de antes en
`backups/models-0.1.1_zips_pre-repack_2026-09-18/`.

## El que está en el juego pero sin probar

| Ficha | Sustituye a | Estado |
|---|---|---|
| [facehuggerEgg](facehuggerEgg.md) | `FIENDEGG` — **releva al markerEgg** | construido, desplegado y verificado por MBIN el **2026-09-13**. **Falta jugarlo**: ancho, giro en Y y apoyo sin comprobar |

## Los retirados — sirvieron para aprender, no se publicaron

| Ficha | Ocupaba | Por qué se retiró |
|---|---|---|
| [necromorph](necromorph.md) | `FIEND` | bípedo sobre rig de araña; lo sustituyó el cry wolf, que es cuadrúpedo |
| [zombie](zombie.md) | `BUGFIEND` | lo mismo; lo sustituyó el warrior bug |

## Lo siguiente

| Modelo | Entra como | Estado |
|---|---|---|
| `alien-xenodog` | `FIEND` — **alternativa** al cry wolf, no relevo | **pendiente**, con spec escrito. Escaneo de **1 623 582 triángulos sin rig**: entra por `.glb`, hay que **decimar 54:1** y lleva piel, o sea los once pasos enteros |
| `xeno-raven`, `monster-eggs`, `alien-egg`, `xenomorph-egg` | sin asignar | en `asset/Modelos 3D` |

## Las capturas

`img/*.png`, rendereadas con `BLENDER_WORKBENCH` desde el `.blend` final de cada
modelo. **Son el estado del `.blend` el 2026-09-13, no necesariamente el del MBIN
publicado**: varios `.blend` se guardaron en una prueba intermedia y la altura que
miden no es la de `alto` en `Export-NMSMesh.py`. Para la geometría que corre de
verdad hay que descompilar el MBIN de `GAMEDATA\MODS`.
