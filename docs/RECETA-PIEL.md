# Receta: poner piel a una malla propia

**Para qué sirve:** para que una malla nuestra deje de ir rígida y se mueva con el esqueleto
del bicho vanilla al que sustituye. No se anima nada: el esqueleto y sus animaciones ya están
en el juego. Lo que falta es **pegar nuestra malla a esos huesos**.

Esta receta salió de hacerlo entero con el **SkrullCrawler** el 2026-08-15. Está escrita para
repetirla con los otros tres modelos sin volver a investigar nada.

Actualizado: **2026-08-15**.

---

## 0 · Qué cambia por modelo y qué no

Casi todo está automatizado. Lo que hay que decidir en cada modelo nuevo son **cuatro cosas**:

| Qué | Dónde se pone | Cómo se decide |
|---|---|---|
| El `.blend` y el nombre del objeto | `BLEND` y `NUESTRA` en `tools/Weight-NMSMesh.py` | Se saben |
| El bicho vanilla al que sustituye | `VANILLA` en el mismo archivo | El que ya usa el mod |
| **`GIRO_Z`** | Igual | §3. **No se adivina, se mide** |
| **Los grupos que se quedan vacíos** | `VACIOS_ESPERADOS` | §3. Salen de la corrida, pero hay que mirarlos |

Todo lo demás —el stride, los offsets, la paleta, el casado, la comprobación— no lo toca nadie.

---

## 1 · El problema, en una frase

Cada vértice de nuestra malla ocupa **8 bytes**: normal y tangente. No hay sitio para «de qué
hueso cuelgo y cuánto». El vanilla ocupa **20**: los mismos 8, más 4 de índice de hueso
(canal 5) y 8 de peso (canal 6).

| SemanticID | Qué es | `Type` | Bytes | `Offset` |
|---:|---|---:|---:|---:|
| 2 | normal | 36255 (`INT_2_10_10_10_REV`) | 4 | 0 |
| 3 | tangente | 36255 | 4 | 4 |
| **5** | **índice de hueso** | **5121 (`UNSIGNED_BYTE`)** | **4** | **8** |
| **6** | **peso de hueso** | **5131 (`HALF_FLOAT`)** | **8** | **12** |

O sea: abrir 12 bytes por vértice y llenarlos.

---

## 2 · Los cinco pasos

```
1. Extraer el vanilla del .pak                          una vez por bicho
2. tools/Weight-NMSMesh.py       -> pesos.json          Blender, sin interfaz
3. tools/Skin-NMSGeometry.py     -> carpeta _anim       sin Blender
4. tools/Check-NMSGraft.py       -> pasa o no pasa      ANTES de construir
5. _F02_SKINNED en el .MATERIAL  -> va en el .lua       el ultimo, siempre
```

### Paso 1 — extraer el vanilla

```
tools/AMUMSS/MODBUILDER/hgpaktool.exe -U -f "*NOMBREDELBICHO*"
```

De `NMSARC.EntitySceneMBIN.pak`, `MeshPlanetCREATURES`, `MetadataEtc` y `AnimMBIN`.

> **La carpeta tiene que repetir la ruta interna de la escena.** El importador de NMSDK lo
> exige (`import_scene.py:220`, `base_path`). Por eso el FreighterFiend está en
> `work/models/vanilla_freighterfiend/models/planets/creatures/spiderrig/`.

### Paso 2 — los pesos

```
"C:\Program Files\Blender Foundation\Blender 5.2\blender.exe" --background --python tools/Weight-NMSMesh.py
```

Deja `pesos.json` al lado de la malla: una entrada por vértice, `[x, y, z, [[hueso, peso], …]]`.

**Lo que tiene que salir, y si no sale hay que parar:**

```
vertices con peso: N de N          <- N de N o hay un fallo de alineacion
maximo de huesos por vertice: 2    <- caben 4; con 2 va sobrado
grupos a cero: [...]               <- MIRARLOS, ver §3
centroide de la cabeza en Y: +...  <- POSITIVO, ver §3
```

> El importador de NMSDK escupe un error de material (`realize_path` con una textura `None`).
> Es **ruidoso pero inofensivo**: la malla y los huesos entran igual.

### Paso 3 — coser

```
python tools/Skin-NMSGeometry.py work/models/<malla> work/models/<malla>_anim
```

No toca la carpeta de origen: copia y trabaja sobre la copia. Aborta solo si la malla no
viene a stride 8 o si ya está cosida, y dice exactamente qué pasa.

### Paso 4 — comprobar

```
python tools/Check-NMSGraft.py work/models/<malla>_anim
```

**Nada de construir ni desplegar hasta que esto pase.** Ver §4.

### Paso 5 — el flag

`_F02_SKINNED` de vuelta en el `.MATERIAL`, y eso va en el `.lua`, no aquí. **El último
siempre**, porque es el que convierte un error de datos en un cierre del juego.

---

## 3 · Las tres trampas que costaron una sesión cada una

### La orientación: el vanilla viene Z arriba y lo nuestro Y arriba

Son 90° de diferencia. Sin corregirlo, las patas cuartas se quedan **con 0 vértices** y una
pata delantera se traga un tercio de la malla. El script ya gira +90° en X y encaja las cajas.

### El giro de 180°: **puntuar por «cuántos grupos reciben vértices» elige mal**

Ese criterio da `GIRO_Z 0`, que deja el cráneo **mirando hacia atrás**. Lo que sí decide es
**dónde cae la cabeza**: en el FreighterFiend está en **+Y**. El script lo comprueba solo con
un assert sobre el centroide de `NewHeadJNT`, y revienta si sale negativo.

> Para un bicho nuevo, mirar primero dónde tiene la cabeza **el vanilla** y ajustar el assert
> a eso. Es el único sitio donde hay que pensar.

### El casado va por **vecino más cercano**, nunca por posición exacta

El exportador parte los vértices —4 820 se convirtieron en 11 357, uno por combinación de
normal y UV—, así que hay que casar por posición. Pero **el buffer guarda en `half` y
`pesos.json` en float**, y el mismo vértice sale movido hasta **1,4 ULP**: `1.829884` en el
JSON contra `1.8291016` en el buffer. Casar por clave exacta falla en **10 014 de 11 357**.

Está resuelto en `nmsskin.casar`, con la tolerancia medida entre dos límites:

| | |
|---|---:|
| vértice peor casado | 0,001355 |
| segundo vecino más cercano de toda la malla | 0,005036 |
| tolerancia | **0,003** |

Si en un modelo nuevo esto salta, el mensaje trae las dos cajas envolventes. **Cajas
distintas = `pesos.json` salió de otra malla o de otra escala**, y hay que volver al paso 2.

---

## 4 · Lo que cierra el juego, y por qué el `Check` va antes

Dos fallos conocidos, los dos vividos:

| Síntoma | Causa |
|---|---|
| El bicho **se estira sin forma** (`PRUEBA01`) | El flag puesto y los pesos mal |
| El juego **cierra sin avisar** (`PRUEBA05`) | El flag puesto y los índices fuera de rango |

Y el detalle que separa las dos cosas, leído en `import_scene.py:1085-1098`:

```
skin_mats = SkinMatrixLayout[FIRSTSKINMAT : LASTSKINMAT]
por cada skin_mat -> un grupo de vertices, en ese orden
blend_indices[j] indexa DIRECTAMENTE esa lista de grupos
```

> **El byte del canal 5 NO es el número de hueso: es la posición dentro de la paleta.** Los
> valores de `SkinMatrixLayout` sí son `JOINTINDEX`, y `JOINTINDEX` empieza en 1. Confundir
> las dos cosas es exactamente el cierre de la `PRUEBA05`.

Con una paleta de 14 huesos, los bytes del canal 5 van de **0 a 13**. Si aparece un 40 porque
alguien metió el `JOINTINDEX` en vez de la posición, el juego se cierra.

---

## 5 · Lo que salió con el SkrullCrawler, para comparar

| | |
|---|---:|
| Huesos del esqueleto vanilla | 113 |
| Grupos que reciben peso | **14** |
| Vértices en Blender | 4 820 |
| Vértices exportados | 11 357 |
| Asignaciones | 4 895 (1,02 por vértice) |
| Máximo de huesos por vértice | 2 |
| Buffer | 90 856 → **227 140** bytes |
| `FIRSTSKINMAT` → `LASTSKINMAT` | 0 → 14 |

> **El bicho vanilla es casi rígido**: 1,05 huesos por vértice. Eso rebaja mucho el listón —no
> hace falta un pesado fino, basta con el hueso más cercano—. Si en un modelo nuevo sale muy
> por encima de 2 huesos por vértice, sospechar de la alineación antes que del pesado.

---

## 6 · Qué se versiona y qué no

| | |
|---|---|
| ✅ Los `.py` de `tools/` | Fuente propia |
| ✅ `pesos.json` | 285 KB de texto, y es lo que consume el paso 3. **Se perdió una vez por no versionarlo** |
| ✅ El `.blend` | Decisión del 15/08, aun pesando 20,9 MB |
| ⛔ **Las carpetas `_anim`** | Son `.MBIN` de Hello Games. Se rehacen con una orden |

Las excepciones del `.gitignore` tienen truco: **git no puede re-incluir nada dentro de un
directorio excluido**. Por eso la regla es `work/models/*` y no `work/models/`, y hay que
abrir todos los directorios padre. Con `*.blend` no hace falta, que es patrón de archivo.

---

## 7 · Dónde está cada cosa

| | |
|---|---|
| Diseño, con los porqués | [`superpowers/specs/2026-08-14-skin-nmsgeometry-design.md`](superpowers/specs/2026-08-14-skin-nmsgeometry-design.md) |
| Plan de implementación | [`superpowers/plans/2026-08-14-skin-nmsgeometry.md`](superpowers/plans/2026-08-14-skin-nmsgeometry.md) |
| Estado y cola | [`PENDIENTES.md`](PENDIENTES.md) §2.1 |
| Tests | `python -m unittest discover -s tools/tests` desde la raíz — `unittest`, **no pytest** |
