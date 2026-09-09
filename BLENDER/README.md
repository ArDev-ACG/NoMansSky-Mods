# Banco de trabajo de Blender

Qué carpeta es cada cosa, y cuál se abre para **ver el modelo que hoy está en el juego**.
El porqué de la vía y el plan por etapas están en [`../docs/ASSETS.md`](../docs/ASSETS.md) §4.3.

Actualizado: **2026-08-13**, con la Etapa 2 (el marker) ya en partida.

---

## 1 · El mapa

| Carpeta | Qué es | ¿Se guarda algo aquí? |
|---|---|---|
| `BLENDER/proyectos/` | Los `.blend`. Uno por modelo: `marker.blend`, `huevo.blend` | **Sí.** Es la única copia del trabajo de Blender |
| `BLENDER/vista_anim/` | **Renders de las animaciones**, una carpeta por modelo y por prueba (`crywolf`, `crywolf_p06`, `warriorbug`, `zombie_actual`…). Es la evidencia con la que se decide si una pata se mueve o no **antes** de construir | **Sí.** Sin esto, las medidas de `Pose-NMSMesh.py` no tienen con qué contrastarse |
| `BLENDER/vista_ingame/` | **Capturas del juego** numeradas (`03_normal_vanilla.png`, `06_UV_rotas_PRUEBA13.png`…). Lo que se ve en pantalla, para comparar contra lo que dicen los números | **Sí** |
| `BLENDER/CUSTOMMODELS/MODELGROUP/…` | **Buzón de NMSDK.** Aquí escribe el addon al exportar | **No.** Se pisa en cada exportación |
| `work/models/eggmesh/` | Etapa 1 congelada — el huevo vanilla, ida y vuelta sin tocar | Sí, es lo que entrega `HT_EggMesh_PRUEBA01` |
| `work/models/markermesh/` | **Etapa 2 congelada — el marker. Esto es lo que hay en el juego.** Los dos `.GEOMETRY` son los de la malla triangulada; el `.SCENE` es el vanilla del huevo | Sí, es lo que entrega `HT_EggMesh_PRUEBA04` |
| `work/textures/MARKER.BASE*.DDS` | Las texturas del marker ya convertidas a formato NMS | Sí, las entrega `HT_EggMesh_PRUEBA03` |
| `asset/Modelos Descomprimidos/marker-1/` | El modelo de origen: `source/marker_1.fbx` y `textures/*.png` | Sí, pero **no se publica** (arte de terceros) |

> `BLENDER/CUSTOMMODELS/MODELGROUP/` tiene ahora **dos cosas a la vez**: `FIENDEGG.*` en la
> raíz, que es la exportación buena del obelisco del 13/08, y bajo `MODELS/PLANETS/…/GROUND/`
> los del huevo de la Etapa 1, de una exportación anterior. Es un buzón: se pisa en cada
> exportación y no es la fuente de nada. Lo que vale está congelado en `work/models/`.

## 2 · Para ver el obelisco en Blender

**Abrir `BLENDER/proyectos/marker.blend`.** Ya existe y lleva el estado bueno: la malla
triangulada, renombrada `FiendEgg` y colgada de la raíz `NMS_Scene`. Es exactamente con lo
que se construyó `HT_EggMesh_PRUEBA04`.

Las texturas se asignan a mano desde `asset/Modelos Descomprimidos/marker-1/textures/`:
`marker_color2.tga.png` al color base, `marker_nmap.tga.png` al normal (**Non-Color**). Los
`.DDS` de `work/textures/` son la versión para el juego, no para mirar en Blender.

Para rehacerlo desde cero: `tools/Export-NMSMesh.py`, que hace la vuelta entera sin tocar el
interfaz. La cabecera de ese archivo lista las cinco formas en que el export a mano falla.

## 2b · La malla que repartía el mod estaba incompleta

Historia de un fallo que tardó una tarde en salir, porque **ninguna de sus fases dio un
mensaje de error**. Corregido en `HT_EggMesh_PRUEBA04`; queda escrito porque la siguiente
malla propia (`M3`) pasa por el mismo sitio.

Dos muros, uno detrás del otro.

**Primero, la carpeta.** Importar desde `work/models/markermesh/` da:

```
ValueError: MODELS\PLANETS\...\GROUND doesn't stem from ...\work\models\markermesh
```

`ModelImporter/import_scene.py:220` llama a `base_path(local_directory, directory)`, donde
`directory` es el `dirname` del `Name` interno de la escena. **Exige que el archivo esté en
una carpeta cuyo final repita esa ruta del juego**, y en `markermesh/` los tres archivos
están planos. El árbol de `tools/AMUMSS/ModBackups/HT_EggMesh_PRUEBA03/` sí la repite, así
que por ahí el import arranca.

**Segundo, la malla.** Arranca, pero la escena sale vacía: sólo entran la esfera de colisión
(642 vértices) y un nodo raíz de 0. `import_scene.py:464` hace `except MeshError: pass`, y
por eso no avisa de nada. El `MeshError` dice:

| Fuente | Vértices | Índices | Triángulos |
|---|---:|---:|---:|
| Cabecera `TkGeometryData` | 1708 | 4908 (`Indices16Bit=1` → 9816 B) | 1636 |
| `StreamMetaData` → `IndexDataSize` | — | 6592 B → 3296 | 1098 |
| Buffer real del `.GEOMETRY.DATA` | numera hasta el **821** | 3294 + 2 de relleno | **1098** |

Los vértices están completos (13664 B = 1708 × 8; 27328 B = 1708 × 16). **El índice no**:
sólo cubre 1098 triángulos y numera como si hubiera 822 vértices. NMSDK calcula
`IndexDataSize / (BATCHCOUNT/3)` = 4, que no es ni 6 (uint16) ni 12 (uint32), y aborta.

**Confirmado en partida el 13/08: al obelisco le faltan caras.** No es una rareza del
importador — el `.GEOMETRY` que reparte el mod está incompleto.

### La causa, y el arreglo

`ModelExporter/addon_script.py:633`:

```python
if not all([len(x) == 3 for x in poly_indexes]):
    data = ob.to_mesh(preserve_all_data_layers=True)
    tri_indexes = triangulate_mesh(data)      # camino fragil
    tri_indexes.sort(key=lambda x: x[0])
else:
    tri_indexes = poly_indexes                # camino directo
```

El marker tiene **806 quads y 24 tris**, así que entra por el primero. Ese camino saca los
índices del `face_map` que devuelve `bmesh.ops.triangulate` —un mapa de caras nuevas a
originales, no la lista completa de triángulos— y los reordena con un `sort` que el propio
comentario del addon admite como aproximado: *«It won't be perfect... But pretty close!»*.

**Triangular la malla antes de exportar** hace que `all(len(x) == 3)` sea cierto y el
exportador tome la rama `else`, que copia los índices tal cual. Con eso `IndexDataSize` pasa
de 6592 a **9816** = 4908 × 2, y la malla sale entera.

### Y detrás, el tamaño

Entera, el obelisco salió **del tamaño de una montaña**. `ob.scale` valía `0.01`, y el
exportador escribe `data.vertices[vi].co`, que son coordenadas **locales**: en Blender la
malla medía 1,63 m y al juego iba de **163**.

| | Local (lo que se exporta) | Con la escala (lo que se ve en Blender) |
|---|---:|---:|
| Alto | 163,35 | 1,6335 |

**El `.SCENE` ya lo decía**: su AABB va de `0.008757` a `1.642224`, exactamente las locales
divididas por 100. Es el mismo patrón que con los índices — la cabecera describe una malla
que los buffers no contienen.

Arreglo: `transform_apply(scale=True)` antes de exportar. **Sólo la escala**: la rotación se
deja como está, porque es la que deja el eje alto en Y, que es el «arriba» de NMS.

> **Vaciar «Unpacked PCBANKS Directory (Optional)» en las preferencias de NMSDK** si algún
> día se vuelve a importar. `utils/io.py:107` devuelve esa ruta **ignorando el archivo que
> abres**: con ella puesta se lee la geometría de PCBANKS y lo que entra es **el huevo
> vanilla**. Comprobado el 13/08: está vacía, así que ese no era el problema.

## 3 · La vuelta completa, paso a paso

```
1. Modelar en BLENDER/proyectos/<modelo>.blend
2. Exportar con tools/Export-NMSMesh.py  -> BLENDER/CUSTOMMODELS/MODELGROUP/
3. Comprobar IndexDataSize == IndexCount * 2   <- si no, faltan caras
4. Congelar en work/models/<modelo>mesh/
5. El .lua de work/scripts/malla/ los entrega con ADD_FILES
```

**Del `.SCENE` que sale del export no se usa nada.** Lo que se entrega es el `.SCENE` vanilla
del huevo, que conserva el material, la `FIENDEGG.ENTITY` y la colisión; sus `BATCHCOUNT` y
`VERTRENDGRAPHIC` ya describen nuestra malla. Sólo se sustituyen los dos `.GEOMETRY`.

Para que eso funcione, **el objeto de Blender tiene que llamarse como el nodo de malla del
`.SCENE` vanilla** — `FiendEgg`. El `IdString` del `.GEOMETRY` sale de ese nombre y el juego
ata nodo y stream por su hash (`1391952726`). Con el nombre que trae el FBX salía
`LOW_MARKER` y no habría encontrado la geometría.

### El prefijo — sólo si se entrega el `.SCENE` exportado

NMSDK antepone `CUSTOMMODELS\MODELGROUP\` a las rutas internas. Si algún día se entrega un
`.SCENE` propio en vez del vanilla, hay que devolverlas a la ruta real del juego **en tres
sitios**, o el juego no encuentra la geometría:

| Dónde | Valor que escribe NMSDK |
|---|---|
| `Name` del nodo raíz | `CUSTOMMODELS\MODELGROUP\MODELS\…\FIENDEGG` |
| Atributo `GEOMETRY` → `Value` | `CUSTOMMODELS\MODELGROUP\MODELS\…\FIENDEGG.GEOMETRY.MBIN` |
| `Name` del nodo `Collision` | `CUSTOMMODELS\MODELGROUP\MODELS\…\FIENDEGG\|Collision` |

Los atributos `MATERIAL` y `ATTACHMENT` **salen ya bien** y no se tocan. Los dos
`.GEOMETRY` tampoco: son idénticos byte a byte antes y después del arreglo.

Se hace descompilando el `.SCENE.MBIN` a `.MXML` con
`tools/AMUMSS/MODBUILDER/MBINCompiler.exe`, editando el texto y recompilando.

## 4 · Dos cosas que conviene saber antes de exportar

**El `.SCENE` que entregamos es el vanilla con la malla cambiada, no uno nuevo.** Del huevo
se conservan las tres cosas que no son geometría: el material `EGGSHELL_MAT`, la entidad
`FIENDEGG.ENTITY` —donde vive el comportamiento: `FIENDHATCH`, `IncreaseFiendWanted`,
`Health 125`— y la esfera de colisión de radio 0.395. Por eso el mod reparte el obelisco por
el mundo sin escribir ninguna regla nueva.

**Nuestra malla no lleva color de vértice y la vanilla sí.** Comparando los `VertexLayout`:

| | Vanilla | Nuestra exportación |
|---|---|---|
| `VertexLayout` | stride 12 · normal, tangente **y `SemanticID 4`** (color de vértice, `UNSIGNED_BYTE`) | stride 8 · normal y tangente |
| `PositionVertexLayout` | stride 16 · posición + UV, `HALF_FLOAT` | igual |

El material del huevo declara `_F21_VERTEXCUSTOM`, que es la bandera que usa ese canal.
El obelisco se ve bien igualmente, así que de momento **no se toca**; queda anotado por si
al cambiar la textura aparece un tinte raro. Las UV sí están (`SemanticID 1`), que es lo que
hacía falta para poder texturarlo.

## 5 · El banco

| Pieza | Estado |
|---|---|
| Blender **≥ 4.2** | ✅ instalado |
| NMSDK **`0.10.0-alpha13`** (10/06/2026) | ✅ instalado |
| Rutas del addon: PCBANKS y `tools\AMUMSS\MODBUILDER\MBINCompiler.exe` | ✅ configuradas |
| Exportar mallas con **pesos de hueso** | ⛔ NMSDK no puede. Por eso no hay criatura propia — [`../docs/ASSETS.md`](../docs/ASSETS.md) §4.2 |
