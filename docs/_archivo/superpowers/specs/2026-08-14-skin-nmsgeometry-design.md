# `M-ANIM` paso 3 — pesar nuestra malla contra el esqueleto vanilla

Diseño cerrado el **2026-08-14**. Cubre los pasos 3 y 4 de la ruta de
[`../../PENDIENTES.md`](../../PENDIENTES.md) §2.1: escribir los canales 5 y 6 en el
`.GEOMETRY` y abrir el rango de piel en el `.SCENE`. El paso 5 —devolver `_F02_SKINNED` a
`FFIENDMAT`— **no entra aquí**: va en el `.lua` de la `PRUEBA12`, el último, junto a `M-TEX`.

---

## 1 · El problema, medido

Hoy el SkrullCrawler va **rígido**: se desliza en vez de andar. Le faltan los dos canales de
piel en el buffer de vértices, y el nodo de malla pide un rango vacío.

**Lo primero que hay que saber, porque cambia el plan: los pesos del paso 2 no existen en
disco.** `BLENDER/proyectos/scuttler.blend` (13/08 23:55) tiene `polySurface6` con 4 820
vértices y **0 grupos de vértices**; el Armature vanilla tampoco está. Los números de §2.1 se
midieron en una sesión headless que no guardó nada. El paso 2 se rehace, y esta vez deja
rastro versionado.

**Lo segundo: el export parte vértices.** 4 820 en Blender → **11 357** en el buffer
(`IndexCount` 28 776 = 9 592 triángulos × 3 ✓). Cualquier tabla de pesos que salga de Blender
**no casa por índice**: casa por posición.

### El `.GEOMETRY.DATA`, leído

MBINCompiler **sí** lo abre. Es `cTkGeometryStreamData` → `TkMeshData`, con los buffers en
**base64** y **sin offsets**: los recalcula él al recompilar.

| Campo | Valor |
|---|---:|
| `IdString` | `POLYSURFACE6` |
| `Hash` | 2509576410 |
| `VertexDataSize` | 90 856 |
| `VertexPositionDataSize` | 181 712 |
| `IndexDataSize` | 57 552 |
| `MeshDataStream` | **148 408 B** = vértices (90 856) + índices (57 552) |
| `MeshPositionDataStream` | **181 712 B** — no se toca |

Eso **quita el trozo caro del trabajo**: no hay que escribir cabecera binaria a mano. Los
offsets sí viven una segunda vez en `StreamMetaDataArray` del `.GEOMETRY`, y esos los ponemos
nosotros —leyéndolos del `.DATA` ya recompilado, no calculándolos con una fórmula—.

### El contrato del stride

`VertexLayout` nuestro hoy: ElementCount 2, **Stride 8**. El vanilla: ElementCount 4,
**Stride 20**.

| SemanticID | Qué es | `Type` | Bytes | `Offset` |
|---:|---|---:|---:|---:|
| 2 | normal | 36255 (`INT_2_10_10_10_REV`) | 4 | 0 |
| 3 | tangente | 36255 | 4 | 4 |
| **5** | **índice de hueso** | **5121 (`UNSIGNED_BYTE`)** | **4** | **8** |
| **6** | **peso de hueso** | **5131 (`HALF_FLOAT`)** | **8** | **12** |

11 357 × 20 = **227 140** bytes de bloque de vértices, contra 90 856 hoy.

`PositionVertexLayout` (Stride 16, posición y UV en half4) **no cambia**.

### El `.SCENE` nuestro

114 nodos JOINT y **un solo** nodo MESH, `polySurface6`, hoy con `FIRSTSKINMAT` 0 y
`LASTSKINMAT` 0 —un rango vacío, que es lo que no lee nada—.

### El detalle que decide si el juego cierra

De `ModelImporter/import_scene.py:1085-1098`:

```
skin_mats = SkinMatrixLayout[FIRSTSKINMAT : LASTSKINMAT]
por cada skin_mat -> un grupo de vértices, en ese orden
blend_indices[j] indexa DIRECTAMENTE esa lista de grupos
```

**El byte del canal 5 no es el número de hueso: es la posición dentro del tramo
`FIRSTSKINMAT`→`LASTSKINMAT`.** Los valores de `SkinMatrixLayout` sí son `JOINTINDEX` de
nodos JOINT del `.SCENE`. Confundir las dos cosas es el «índices fuera de rango» que cerró el
juego en la `PRUEBA05`.

Y `JOINTINDEX` **empieza en 1**, no en 0: los 114 nodos van del 1 al 114, `RootJNT` es el 2.
El vanilla lo confirma —su `SkinMatrixLayout` de 23 arranca en `2`, que es `RootJNT`— y trae
`MeshBaseSkinMat` `[0, 0, 0, 19]`: la malla del cuerpo usa las 19 primeras entradas de la
paleta y la del ojo arranca en la 19.

---

## 2 · Las piezas

Dos herramientas nuevas y una ampliada, en el patrón de la casa (`Verbo-NMSCosa.py`).

### 2.1 · `tools/Weight-NMSMesh.py` — Blender headless

Rehace los pasos 1 y 2 **y deja rastro**.

```
blender.exe --background --python tools/Weight-NMSMesh.py
```

1. Abre `BLENDER/proyectos/scuttler.blend`.
2. Importa el vanilla con `import_bones=True` desde
   `work/models/vanilla_freighterfiend/models/planets/creatures/spiderrig/`. Ese árbol existe
   justo porque `import_scene.py:220` exige que la carpeta repita la ruta interna de la
   escena.
3. Alinea: **+90° en X** —el vanilla viene Z arriba y el nuestro Y arriba— y **`GIRO_Z 180`**,
   después encaja la caja envolvente en la del vanilla.
4. Data Transfer de `Vertex Group Data`, por superficie más cercana.
5. Limita a 4 influencias y normaliza.

Salidas, las dos versionadas:

| Qué | Dónde |
|---|---|
| el `.blend` con los grupos puestos | `BLENDER/proyectos/scuttler.blend` |
| la tabla de pesos | `work/models/scuttlermesh/pesos.json` |

`pesos.json` lleva 4 820 entradas `[x, y, z, [[grupo, peso], …]]`. La posición va en
**coordenadas locales**, que es exactamente lo que escribe el exportador
(`addon_script.py`: `data.vertices[vi].co`, sin la escala del objeto).

**Asserts que pueden fallar**, contra la tabla de `PENDIENTES.md` §2.1:

- 4 820 de 4 820 vértices con peso, y 5 137 asignaciones —1,07 huesos por vértice—;
- máximo **2** huesos por vértice;
- **19 grupos creados y 14 con peso.** Los cinco que se quedan a cero son conocidos y **no
  son fallo**: `NewBack1JNT`, `NewBack2JNT`, `NewBack3JNT` —la espalda no doblará, el cuerpo
  se moverá en bloque con `RootJNT`— y los dos `Pincer1JNT`, que nuestro bicho no tiene. El
  assert exige **esos cinco y no otros**;
- suma de pesos = 1 en todos;
- **la cabeza en +Y** — el centroide de los vértices con peso > 0,5 en `NewHeadJNT`. Es el
  criterio que decidió `GIRO_Z 180`; puntuar por «cuántos grupos reciben vértices» elige mal
  y deja el cráneo mirando hacia atrás.

### 2.2 · `tools/Skin-NMSGeometry.py` — el splice, sin Blender

```
python tools/Skin-NMSGeometry.py <carpeta origen> <carpeta destino>
```

**Copia él la carpeta entera** de origen a destino y trabaja solo sobre la copia: la de
origen no se toca nunca, y así no hay un paso manual que se pueda olvidar. El sidecar sale
de `<origen>/pesos.json`. Si el destino ya existe, aborta.

De los archivos copiados reescribe **tres**, y recompila los tres con MBINCompiler, porque lo
que reparte el `.lua` son los `.MBIN`:

| Archivo | Qué le cambia |
|---|---|
| `FREIGHTERFIEND.GEOMETRY.DATA.MBIN.PC` | el bloque de vértices, de stride 8 a 20 |
| `FREIGHTERFIEND.GEOMETRY.MBIN.PC` | `VertexLayout`, `StreamMetaDataArray`, `SkinMatrixLayout`, `MeshBaseSkinMat` |
| `FREIGHTERFIEND.SCENE.MBIN` | `FIRSTSKINMAT` / `LASTSKINMAT` del nodo `polySurface6` |

```
a. MBINCompiler descompila el .DATA -> .DATA.MXML
b. base64 -> MeshDataStream = vértices(90 856) + índices(57 552)
c. MeshPositionDataStream -> 11 357 posiciones half4
d. casa 11 357 exportados con 4 820 del sidecar POR POSICIÓN
e. paleta = grupos con peso -> SkinMatrixLayout = sus JOINTINDEX
f. por vértice: 4 bytes de posición-en-paleta + 4 half de peso
g. bloque nuevo a stride 20: [normal 4][tangente 4][índice 4][peso 8]
h. recodifica, VertexDataSize 227 140, recompila el .DATA
i. lee del .DATA YA RECOMPILADO sus offsets -> StreamMetaDataArray
j. .SCENE: FIRSTSKINMAT / LASTSKINMAT del nodo polySurface6
```

Los **8 primeros bytes de cada vértice se copian tal cual**: normal y tangente no se
recalculan. El bloque de índices y el de posiciones tampoco se tocan.

**El paso `d` es el que puede morder.** El export parte 4 820 en 11 357, pero los partidos
comparten posición: se redondea el `co` del sidecar a half y se casa por clave exacta. Si
algún vértice no casa, **aborta diciendo cuántos**. No hay vecino más cercano silencioso.

**El paso `f` es el que cerró el juego en la `PRUEBA05`**: el byte es la posición dentro de
la paleta, no el número de hueso. Los huecos sobrantes van a `(0, 0.0)`.

Escribe también, en el `.GEOMETRY.MXML`:

- `VertexLayout`: ElementCount 2 → **4**, Stride 8 → **20**, y los dos `TkVertexElement`
  nuevos con el `Type`, `Size` y `Offset` de la tabla de §1;
- `StreamMetaDataArray`: `VertexDataSize`, `VertexDataOffset`, `IndexDataOffset`,
  `VertexPositionDataOffset`;
- `SkinMatrixLayout` y `MeshBaseSkinMat`.

### 2.3 · `tools/Check-NMSGraft.py` ampliado

Deja de ser un tool de XML puro: abre el `.DATA` y decodifica base64. Cinco comprobaciones
nuevas, **todas capaces de fallar**:

| Comprobación | Qué caza |
|---|---|
| `Stride × VertexCount == VertexDataSize` | el bloque a medio reescribir |
| offsets del `.GEOMETRY` == offsets del `.DATA` | las dos copias descuadradas |
| todo índice del canal 5 `< LASTSKINMAT − FIRSTSKINMAT` | **el cierre sin aviso de la `PRUEBA05`** |
| pesos de cada vértice suman 1 | un vértice sin peso o mal normalizado |
| `SkinMatrixLayout` solo trae `JOINTINDEX` de 1 a 114 | una paleta que apunta fuera del esqueleto, o que confundió 0-based con 1-based |

Las comprobaciones que ya tiene —arrays por hueso, arrays por malla, rangos de lote y de
vértice— se quedan como están.

---

## 3 · El orden, y qué se comprueba sin entrar al juego

| | Paso | Se comprueba con |
|---|---|---|
| 1 | `Weight-NMSMesh` → `pesos.json` + `.blend` | sus asserts contra la tabla de §2.1 |
| 2 | `Skin-NMSGeometry` → `work/models/scuttlermesh_anim/` | aborta si el casado por posición falla |
| 3 | `Check-NMSGraft` | tiene que pasar antes de construir nada |
| 4 | `.lua` de la `PRUEBA12`: `_F02_SKINNED` + `M-TEX` | **el juego, una sola entrada** |

**Lo que ningún check caza** es el fallo de la `PRUEBA01` —el bicho estirado sin forma, con el
flag puesto y los pesos mal—. Contra eso solo juega que los pesos salen del vanilla por
transferencia y con el mismo número de influencias que el original: 1,07 huesos por vértice
contra 1,05 del vanilla.

---

## 4 · Decisiones tomadas

| # | Decisión | Por qué |
|---|---|---|
| **D1** | **Paleta propia, no la del vanilla.** `SkinMatrixLayout` lleva solo los grupos **con peso** —14, si sale lo mismo que en la sesión del 13/08—; `FIRSTSKINMAT` 0 → `LASTSKINMAT` = tamaño de la paleta; `MeshBaseSkinMat` `[0]` | Las 23 entradas del vanilla describen sus cuatro mallas, no la nuestra. Nuestro `.SCENE` tiene **un** nodo MESH. El tamaño lo pone la herramienta, no una constante escrita a mano |
| **D2** | **Carpeta nueva `work/models/scuttlermesh_anim/`** | `scuttlermesh/` es la `PRUEBA11` congelada, dada por buena en partida el 14/08. De ahí no se retrocede |
| **D3** | **El sidecar en JSON, versionado en git** | ~400 KB legibles y diffables. Es lo que evita que el paso 2 se vuelva a evaporar por segunda vez |
| **D4** | **El splice no toca `FFIENDMAT`** | El flag `_F02_SKINNED` va el último y va en el `.lua`, junto a `M-TEX`. Una sola entrada al juego mide las dos cosas |

---

## 5 · Fuera de alcance

- `M-TEX` —el normal propio— comparte `.lua` con esto, pero es trabajo aparte.
- `M3`, la segunda malla propia, y el `zombie-monster-slasher` rigged.
- Tocar el exportador de NMSDK para que escriba piel. Se descartó: es un addon de terceros y
  el conducto de export estático ya está cerrado y automatizado en `Export-NMSMesh.py`.
