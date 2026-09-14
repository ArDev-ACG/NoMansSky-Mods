# `M-ANIM` paso 3 — plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Que el SkrullCrawler deje de ir rígido — escribir los canales 5 y 6 en su `.GEOMETRY`, subiendo el stride de 8 a 20 bytes por vértice, y abrir el rango de piel en el `.SCENE`.

**Architecture:** Tres piezas y dos bibliotecas. `Weight-NMSMesh.py` corre en Blender sin interfaz y deja los pesos en un JSON versionado; `Skin-NMSGeometry.py` los mete en el buffer sin tocar Blender; `Check-NMSGraft.py` ampliado dice si algún índice se sale antes de construir nada. La lógica vive en `nmsgeom.py` y `nmsskin.py`, que son los únicos importables — los comandos son envoltorios finos, porque un archivo con guion en el nombre no se puede importar y lo que no se puede importar no se puede testear.

**Tech Stack:** Python 3.10 · numpy 2.0.2 · `unittest` de la stdlib · Blender 5.2 con NMSDK · MBINCompiler de AMUMSS.

El diseño completo, con los porqués: [`../specs/2026-08-14-skin-nmsgeometry-design.md`](../specs/2026-08-14-skin-nmsgeometry-design.md).

## Global Constraints

- **No hay pytest y no se instala.** Los tests son `unittest` de la stdlib, y se corren con `python -m unittest discover -s tools/tests` desde la raíz del repo.
- **Los `.py` de `tools/` van sin acentos**, como los que ya hay (`Patch-NMSGraft.py` escribe «segun», «costo», «vacios»). Docstring de cabecera en el estilo de la casa: qué hace, cómo se llama, y qué fallo real lo hizo existir. **Este plan, el spec y los `.md` sí llevan acentos**: la regla es solo para el código.
- **Los commits no llevan trailer `Co-Authored-By`.**
- **MBINCompiler es `tools/AMUMSS/MODBUILDER/MBINCompiler.exe`.** Convierte según la extensión que le des y escribe al lado.
- **`work/models/scuttlermesh/` no se modifica nunca.** Es la `PRUEBA11`, dada por buena en partida el 2026-08-14. Todo lo nuevo va a `work/models/scuttlermesh_anim/`.
- **Ninguna tarea construye ni despliega el mod.** Eso es la `PRUEBA12` y va después de este plan.
- **Números fijos de esta malla**, para no volver a medirlos: `VertexCount` 11 357 · `IndexCount` 28 776 · stride viejo 8 · stride nuevo 20 · `VertexDataSize` 90 856 → **227 140** · `IndexDataSize` 57 552 · `VertexPositionDataSize` 181 712 · cabecera del `.DATA` 133 · 114 nodos JOINT · 1 nodo MESH (`polySurface6`) · 4 820 vértices en Blender.

---

## Estructura de archivos

| Archivo | De qué responde |
|---|---|
| `tools/nmsgeom.py` | **Crear.** El par `.GEOMETRY`/`.DATA`: MBINCompiler, streams en base64, stride, `VertexLayout`, `StreamMetaDataArray`. No sabe nada de huesos |
| `tools/nmsskin.py` | **Crear.** La piel: leer `pesos.json`, construir la paleta, casar vértices por posición, empaquetar los canales 5 y 6. No abre archivos del juego |
| `tools/Weight-NMSMesh.py` | **Crear.** Blender sin interfaz: importa el vanilla con huesos, alinea, transfiere pesos, escribe `pesos.json` |
| `tools/Skin-NMSGeometry.py` | **Crear.** Envoltorio de línea de comandos: copia la carpeta y aplica `nmsgeom` + `nmsskin` |
| `tools/Check-NMSGraft.py` | **Modificar.** Cinco comprobaciones nuevas sobre el binario |
| `tools/tests/test_nmsgeom.py` | **Crear.** Tareas 1 y 2 |
| `tools/tests/test_pesos.py` | **Crear.** Tarea 3: invariantes de `pesos.json` |
| `tools/tests/test_nmsskin.py` | **Crear.** Tarea 4 |

---

## Task 1: `nmsgeom.py` — el `.DATA` va y vuelve sin perder un byte

Antes de cambiar nada hay que demostrar que el conducto no rompe. El viaje `.DATA` → MXML → `.DATA` **no** da un archivo idéntico: cambian 19 bytes de cabecera —el `magic` pasa de `CCCC…` a `DDDD…` y cambian los rellenos de las listas—, pero **la carga útil vuelve exacta y los offsets no se mueven**. El `magic` `DD` ya está en partida: lo lleva el `FREIGHTERFIEND.GEOMETRY.MBIN.PC` de la `PRUEBA11`.

**Files:**
- Create: `tools/nmsgeom.py`
- Create: `tools/tests/test_nmsgeom.py`

**Interfaces:**
- Consumes: nada.
- Produces:
  - `MBINCOMPILER: Path`
  - `class Streams` con `id_string: str`, `hash: int`, `vertices: bytes`, `indices: bytes`, `posiciones: bytes`
  - `descompilar(mbin: Path) -> Path` — devuelve la ruta del `.MXML`
  - `compilar(mxml: Path) -> Path` — devuelve la ruta del `.MBIN.PC`
  - `leer_streams(data_mxml: Path) -> Streams`
  - `escribir_streams(data_mxml: Path, s: Streams) -> None`
  - `cabecera(data_mbin: Path, s: Streams) -> int`

- [ ] **Step 1: Escribir el test que falla**

Crear `tools/tests/test_nmsgeom.py`:

```python
"""Tests de tools/nmsgeom.py. Se corren desde la raiz del repo:

    python -m unittest discover -s tools/tests
"""

import shutil
import os
import sys
import tempfile
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(RAIZ / "tools"))

import nmsgeom  # noqa: E402

CONGELADA = RAIZ / "work" / "models" / "scuttlermesh"
DATA = CONGELADA / "FREIGHTERFIEND.GEOMETRY.DATA.MBIN.PC"


def _copiar(destino: Path, origen: Path) -> Path:
    copia = destino / origen.name
    shutil.copy(origen, copia)
    return copia


class TestIdaYVuelta(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp(prefix="nmsgeom-"))
        self.data = _copiar(self.tmp, DATA)

    def tearDown(self):
        shutil.rmtree(self.tmp, ignore_errors=True)

    def test_los_streams_tienen_el_tamano_declarado(self):
        s = nmsgeom.leer_streams(nmsgeom.descompilar(self.data))
        self.assertEqual(s.id_string, "POLYSURFACE6")
        self.assertEqual(s.hash, 2509576410)
        self.assertEqual(len(s.vertices), 90856)
        self.assertEqual(len(s.indices), 57552)
        self.assertEqual(len(s.posiciones), 181712)

    def test_la_cabecera_mide_133(self):
        s = nmsgeom.leer_streams(nmsgeom.descompilar(self.data))
        self.assertEqual(nmsgeom.cabecera(self.data, s), 133)

    def test_la_carga_util_vuelve_identica(self):
        original = self.data.read_bytes()
        mxml = nmsgeom.descompilar(self.data)
        nmsgeom.escribir_streams(mxml, nmsgeom.leer_streams(mxml))
        vuelta = nmsgeom.compilar(mxml).read_bytes()

        self.assertEqual(len(vuelta), len(original))
        # Los 19 bytes que cambian son de cabecera: el magic pasa de CC a DD
        # y cambian los rellenos de las listas. La carga util es sagrada.
        self.assertEqual(vuelta[133:], original[133:])
        self.assertEqual(vuelta[:8], b"\xdd" * 8)


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: Correrlo y ver que falla**

```
python -m unittest discover -s tools/tests
```

Esperado: `ModuleNotFoundError: No module named 'nmsgeom'`.

- [ ] **Step 3: Escribir `tools/nmsgeom.py`**

```python
"""El par .GEOMETRY / .GEOMETRY.DATA de NMS, abierto y vuelto a cerrar.

Biblioteca, no comando: la usan tools/Skin-NMSGeometry.py y
tools/Check-NMSGraft.py. Vive aparte porque un archivo con guion en el
nombre no se puede importar, y lo que no se puede importar no se puede
testear.

Lo que hay que saber del .DATA, medido y no supuesto:

  - es cTkGeometryStreamData -> TkMeshData, con los buffers en base64 y
    SIN offsets: MBINCompiler los recalcula al recompilar.
  - MeshDataStream lleva los vertices y los indices PEGADOS, en ese
    orden. MeshPositionDataStream lleva las posiciones, aparte.
  - la ida y vuelta cambia 19 bytes de cabecera -el magic pasa de CCCC a
    DDDD, cambian los rellenos de las listas- y NADA de la carga util.
    El magic DD ya esta en partida: lo lleva el .GEOMETRY de la PRUEBA11.

Los offsets del .GEOMETRY siguen la convencion del vanilla, que no es la
que parece: VertexDataOffset y VertexPositionDataOffset son ABSOLUTOS en
el archivo, e IndexDataOffset es RELATIVO al principio de los vertices
-o sea, vale lo mismo que VertexDataSize-.
"""

import base64
import subprocess
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from pathlib import Path

MBINCOMPILER = (Path(__file__).resolve().parent / "AMUMSS" / "MODBUILDER"
                / "MBINCompiler.exe")

# El contrato del vanilla, de freighterfiend.geometry.MXML: ElementCount 4,
# Stride 20. El indice de hueso es UNSIGNED_BYTE x4 y el peso HALF_FLOAT x4.
CANALES_PIEL = [
    {"Type": "5121", "SemanticID": "5", "Normalise": "0", "Size": "4",
     "Offset": "8", "Instancing": "PerVertex"},
    {"Type": "5131", "SemanticID": "6", "Normalise": "0", "Size": "4",
     "Offset": "12", "Instancing": "PerVertex"},
]


@dataclass
class Streams:
    id_string: str
    hash: int
    vertices: bytes
    indices: bytes
    posiciones: bytes


def _correr(ruta: Path, salida: Path) -> Path:
    if salida.exists():
        salida.unlink()
    r = subprocess.run([str(MBINCOMPILER), ruta.name], cwd=str(ruta.parent),
                       capture_output=True, text=True)
    if not salida.exists():
        raise RuntimeError(f"MBINCompiler no escribio {salida}:\n"
                           f"{r.stdout}\n{r.returncode}")
    return salida


def descompilar(mbin: Path) -> Path:
    """FREIGHTERFIEND.GEOMETRY.DATA.MBIN.PC -> ...DATA.MXML"""
    mbin = Path(mbin)
    nombre = mbin.name
    for sufijo in (".MBIN.PC", ".MBIN"):
        if nombre.upper().endswith(sufijo):
            nombre = nombre[: -len(sufijo)]
            break
    return _correr(mbin, mbin.with_name(nombre + ".MXML"))


def compilar(mxml: Path) -> Path:
    """...DATA.MXML -> ...DATA.MBIN.PC, o .SCENE.MXML -> .SCENE.MBIN"""
    mxml = Path(mxml)
    tallo = mxml.name[: -len(".MXML")]
    sufijo = ".MBIN.PC" if ".GEOMETRY" in tallo.upper() else ".MBIN"
    return _correr(mxml, mxml.with_name(tallo + sufijo))


def _malla(mxml: Path):
    arbol = ET.parse(mxml)
    nodo = arbol.getroot().find(".//Property[@value='TkMeshData']")
    if nodo is None:
        raise KeyError(f"{mxml} no lleva ningun TkMeshData")
    return arbol, nodo


def _campo(nodo, nombre):
    p = nodo.find(f"Property[@name='{nombre}']")
    if p is None:
        raise KeyError(nombre)
    return p


def leer_streams(data_mxml: Path) -> Streams:
    _, malla = _malla(Path(data_mxml))
    tam_v = int(_campo(malla, "VertexDataSize").get("value"))
    mezcla = base64.b64decode(_campo(malla, "MeshDataStream").get("value"))
    return Streams(
        id_string=_campo(malla, "IdString").get("value"),
        hash=int(_campo(malla, "Hash").get("value")),
        vertices=mezcla[:tam_v],
        indices=mezcla[tam_v:],
        posiciones=base64.b64decode(
            _campo(malla, "MeshPositionDataStream").get("value")),
    )


def escribir_streams(data_mxml: Path, s: Streams) -> None:
    data_mxml = Path(data_mxml)
    arbol, malla = _malla(data_mxml)
    _campo(malla, "VertexDataSize").set("value", str(len(s.vertices)))
    _campo(malla, "IndexDataSize").set("value", str(len(s.indices)))
    _campo(malla, "VertexPositionDataSize").set(
        "value", str(len(s.posiciones)))
    _campo(malla, "MeshDataStream").set(
        "value", base64.b64encode(s.vertices + s.indices).decode("ascii"))
    _campo(malla, "MeshPositionDataStream").set(
        "value", base64.b64encode(s.posiciones).decode("ascii"))
    arbol.write(data_mxml, encoding="utf-8", xml_declaration=True)


def cabecera(data_mbin: Path, s: Streams) -> int:
    """Los bytes de cabecera del .DATA: lo que hay antes de los streams."""
    return (Path(data_mbin).stat().st_size
            - len(s.vertices) - len(s.indices) - len(s.posiciones))
```

- [ ] **Step 4: Correr los tests y ver que pasan**

```
python -m unittest discover -s tools/tests
```

Esperado: `Ran 3 tests` · `OK`.

- [ ] **Step 5: Commit**

```bash
git add tools/nmsgeom.py tools/tests/test_nmsgeom.py
git commit -m "feat: nmsgeom, abrir y cerrar el .GEOMETRY.DATA sin perder un byte"
```

---

## Task 2: `nmsgeom.py` — subir el stride de 8 a 20 y cuadrar el `.GEOMETRY`

Todavía sin pesos: los 12 bytes nuevos van a cero. Lo que se demuestra aquí es que el buffer crece bien, que el `VertexLayout` queda declarando lo que hay, y que los tres offsets del `.GEOMETRY` cuadran con el `.DATA` recompilado.

**Files:**
- Modify: `tools/nmsgeom.py`
- Modify: `tools/tests/test_nmsgeom.py`

**Interfaces:**
- Consumes: `Streams`, `leer_streams`, `escribir_streams`, `compilar`, `descompilar`, `cabecera` de la Task 1.
- Produces:
  - `ampliar_stride(vertices: bytes, viejo: int, nuevo: int) -> bytearray`
  - `parchear_layout(geo_mxml: Path) -> None`
  - `parchear_metadata(geo_mxml: Path, data_mbin: Path, s: Streams) -> None`
  - `layout(geo_mxml: Path) -> dict` — `{"stride": int, "elementos": {semantic_id: offset}}`

- [ ] **Step 1: Escribir los tests que fallan**

Añadir a `tools/tests/test_nmsgeom.py`, antes del `if __name__`:

```python
GEO = CONGELADA / "FREIGHTERFIEND.GEOMETRY.MBIN.PC"


class TestStride(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp(prefix="nmsgeom-"))

    def tearDown(self):
        shutil.rmtree(self.tmp, ignore_errors=True)

    def test_crece_a_20_y_conserva_los_8_primeros(self):
        viejo = bytes(range(8)) + bytes(range(100, 108))
        nuevo = nmsgeom.ampliar_stride(viejo, 8, 20)

        self.assertEqual(len(nuevo), 40)
        self.assertEqual(nuevo[0:8], bytes(range(8)))
        self.assertEqual(nuevo[8:20], b"\x00" * 12)
        self.assertEqual(nuevo[20:28], bytes(range(100, 108)))
        self.assertEqual(nuevo[28:40], b"\x00" * 12)

    def test_el_buffer_real_pasa_de_90856_a_227140(self):
        s = nmsgeom.leer_streams(nmsgeom.descompilar(_copiar(self.tmp, DATA)))
        self.assertEqual(len(nmsgeom.ampliar_stride(s.vertices, 8, 20)),
                         227140)

    def test_un_buffer_que_no_es_multiplo_del_stride_revienta(self):
        with self.assertRaises(ValueError):
            nmsgeom.ampliar_stride(b"\x00" * 9, 8, 20)


class TestLayout(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp(prefix="nmsgeom-"))
        self.geo = nmsgeom.descompilar(_copiar(self.tmp, GEO))
        self.data = _copiar(self.tmp, DATA)

    def tearDown(self):
        shutil.rmtree(self.tmp, ignore_errors=True)

    def test_hoy_declara_stride_8_con_normal_y_tangente(self):
        d = nmsgeom.layout(self.geo)
        self.assertEqual(d["stride"], 8)
        self.assertEqual(d["elementos"], {2: 0, 3: 4})

    def test_parcheado_declara_stride_20_con_los_cuatro_canales(self):
        nmsgeom.parchear_layout(self.geo)
        d = nmsgeom.layout(self.geo)
        self.assertEqual(d["stride"], 20)
        self.assertEqual(d["elementos"], {2: 0, 3: 4, 5: 8, 6: 12})

    def test_parchear_dos_veces_no_duplica_canales(self):
        nmsgeom.parchear_layout(self.geo)
        nmsgeom.parchear_layout(self.geo)
        self.assertEqual(len(nmsgeom.layout(self.geo)["elementos"]), 4)

    def test_los_offsets_salen_de_la_convencion_del_vanilla(self):
        mxml = nmsgeom.descompilar(self.data)
        s = nmsgeom.leer_streams(mxml)
        s.vertices = bytes(nmsgeom.ampliar_stride(s.vertices, 8, 20))
        nmsgeom.escribir_streams(mxml, s)
        data = nmsgeom.compilar(mxml)

        nmsgeom.parchear_metadata(self.geo, data, s)
        meta = ET.parse(self.geo).getroot().find(
            ".//Property[@value='TkMeshMetaData']")

        def leer(nombre):
            return int(meta.find(f"Property[@name='{nombre}']").get("value"))

        # VertexDataOffset y VertexPositionDataOffset son absolutos;
        # IndexDataOffset es relativo y vale lo mismo que VertexDataSize.
        self.assertEqual(leer("VertexDataSize"), 227140)
        self.assertEqual(leer("VertexDataOffset"), 133)
        self.assertEqual(leer("IndexDataOffset"), 227140)
        self.assertEqual(leer("VertexPositionDataOffset"), 133 + 227140 + 57552)
```

- [ ] **Step 2: Correrlos y ver que fallan**

```
python -m unittest discover -s tools/tests
```

Esperado: `AttributeError: module 'nmsgeom' has no attribute 'ampliar_stride'`.

- [ ] **Step 3: Implementar, al final de `tools/nmsgeom.py`**

```python
def ampliar_stride(vertices: bytes, viejo: int, nuevo: int) -> bytearray:
    """Recoloca cada vertice en un hueco mas ancho. El relleno va a cero."""
    if len(vertices) % viejo:
        raise ValueError(f"{len(vertices)} bytes no es multiplo de {viejo}")
    n = len(vertices) // viejo
    salida = bytearray(n * nuevo)
    for i in range(n):
        salida[i * nuevo: i * nuevo + viejo] = vertices[i * viejo:
                                                        (i + 1) * viejo]
    return salida


def layout(geo_mxml: Path) -> dict:
    raiz = ET.parse(Path(geo_mxml)).getroot()
    vl = raiz.find(".//Property[@name='VertexLayout']")
    elementos = {}
    for e in vl.find("Property[@name='VertexElements']"):
        clave = int(_campo(e, "SemanticID").get("value"))
        elementos[clave] = int(_campo(e, "Offset").get("value"))
    return {"stride": int(_campo(vl, "Stride").get("value")),
            "elementos": elementos}


def parchear_layout(geo_mxml: Path) -> None:
    """ElementCount 2 -> 4, Stride 8 -> 20, y los dos canales de piel."""
    geo_mxml = Path(geo_mxml)
    arbol = ET.parse(geo_mxml)
    vl = arbol.getroot().find(".//Property[@name='VertexLayout']")
    elementos = vl.find("Property[@name='VertexElements']")

    presentes = {_campo(e, "SemanticID").get("value") for e in elementos}
    for canal in CANALES_PIEL:
        if canal["SemanticID"] in presentes:
            continue
        e = ET.SubElement(elementos, "Property",
                          {"name": "VertexElements",
                           "value": "TkVertexElement",
                           "_index": str(len(elementos))})
        for clave, valor in canal.items():
            ET.SubElement(e, "Property", {"name": clave, "value": valor})

    _campo(vl, "ElementCount").set("value", str(len(elementos)))
    _campo(vl, "Stride").set("value", "20")
    arbol.write(geo_mxml, encoding="utf-8", xml_declaration=True)


def parchear_metadata(geo_mxml: Path, data_mbin: Path, s: Streams) -> None:
    """Los offsets, en la convencion del vanilla: los dos de datos son
    absolutos en el archivo y el de indices es relativo a los vertices."""
    geo_mxml = Path(geo_mxml)
    arbol = ET.parse(geo_mxml)
    meta = arbol.getroot().find(".//Property[@value='TkMeshMetaData']")
    inicio = cabecera(data_mbin, s)
    for clave, valor in (
            ("VertexDataSize", len(s.vertices)),
            ("VertexDataOffset", inicio),
            ("IndexDataSize", len(s.indices)),
            ("IndexDataOffset", len(s.vertices)),
            ("VertexPositionDataSize", len(s.posiciones)),
            ("VertexPositionDataOffset",
             inicio + len(s.vertices) + len(s.indices))):
        _campo(meta, clave).set("value", str(valor))
    arbol.write(geo_mxml, encoding="utf-8", xml_declaration=True)
```

- [ ] **Step 4: Correr los tests**

```
python -m unittest discover -s tools/tests
```

Esperado: `Ran 10 tests` · `OK`.

- [ ] **Step 5: Commit**

```bash
git add tools/nmsgeom.py tools/tests/test_nmsgeom.py
git commit -m "feat: nmsgeom, stride 8 -> 20 y los offsets del .GEOMETRY"
```

---

## Task 3: `Weight-NMSMesh.py` — rehacer los pesos y dejarlos escritos

`scuttler.blend` tiene `polySurface6` con 4 820 vértices y **0 grupos de vértices**: los pesos de la sesión del 13/08 no existen en disco. Esta tarea los rehace y esta vez los deja versionados.

**Files:**
- Create: `tools/Weight-NMSMesh.py`
- Create: `tools/tests/test_pesos.py`
- Modify (los produce el script): `BLENDER/proyectos/scuttler.blend`, `work/models/scuttlermesh/pesos.json`

**Interfaces:**
- Consumes: nada del código anterior. `bpy` solo existe dentro de Blender, así que este archivo **no se importa nunca** desde los tests.
- Produces: `work/models/scuttlermesh/pesos.json` — una lista de 4 820 entradas, cada una `[x, y, z, [[nombre_grupo, peso], ...]]`, con `x/y/z` en coordenadas **locales** del objeto y los pesos ordenados de mayor a menor.

- [ ] **Step 1: Escribir el test de invariantes, que se salta porque no hay JSON**

Crear `tools/tests/test_pesos.py`:

```python
"""Invariantes de work/models/scuttlermesh/pesos.json.

No testea el script de Blender -bpy no existe fuera de Blender-: testea
lo que el script deja escrito, que es lo unico que consume el splice.
"""

import json
import unittest
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[2]
PESOS = RAIZ / "work" / "models" / "scuttlermesh" / "pesos.json"

# Los cinco grupos que se quedan a cero son conocidos y NO son fallo: la
# espalda no doblara -el cuerpo se movera en bloque con RootJNT- y nuestro
# bicho no tiene pinzas.
VACIOS = {"NewBack1JNT", "NewBack2JNT", "NewBack3JNT",
          "LPincer1JNT", "RPincer1JNT"}


class TestPesos(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        if not PESOS.exists():
            raise unittest.SkipTest(f"falta {PESOS}: corre Weight-NMSMesh.py")
        cls.pesos = json.loads(PESOS.read_text(encoding="utf-8"))

    def test_hay_4820_vertices_y_todos_llevan_peso(self):
        self.assertEqual(len(self.pesos), 4820)
        self.assertTrue(all(entrada[3] for entrada in self.pesos))

    def test_ningun_vertice_cuelga_de_mas_de_dos_huesos(self):
        self.assertLessEqual(max(len(e[3]) for e in self.pesos), 2)

    def test_los_pesos_de_cada_vertice_suman_uno(self):
        for i, e in enumerate(self.pesos):
            with self.subTest(vertice=i):
                self.assertAlmostEqual(sum(p for _, p in e[3]), 1.0, places=4)

    def test_los_pesos_bajan_de_mayor_a_menor(self):
        for i, e in enumerate(self.pesos):
            pesos = [p for _, p in e[3]]
            with self.subTest(vertice=i):
                self.assertEqual(pesos, sorted(pesos, reverse=True))

    def test_catorce_grupos_reciben_peso(self):
        usados = {g for e in self.pesos for g, _ in e[3]}
        self.assertEqual(len(usados), 14)
        self.assertEqual(usados & VACIOS, set())

    def test_la_cabeza_cae_en_mas_y(self):
        # El criterio que decidio GIRO_Z 180. Puntuar por "cuantos grupos
        # reciben vertices" elige mal y deja el craneo mirando hacia atras.
        ys = [e[1] for e in self.pesos
              if any(g == "NewHeadJNT" and p > 0.5 for g, p in e[3])]
        self.assertTrue(ys, "ningun vertice cuelga de NewHeadJNT")
        self.assertGreater(sum(ys) / len(ys), 0)


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: Correrlo y ver que se salta**

```
python -m unittest discover -s tools/tests
```

Esperado: los de `nmsgeom` en `OK` y los de pesos en `skipped ('falta ...pesos.json: corre Weight-NMSMesh.py')`.

- [ ] **Step 3: Escribir `tools/Weight-NMSMesh.py`**

```python
"""Pesa nuestra malla contra el esqueleto vanilla, sin tocar el interfaz.

    blender.exe --background --python tools/Weight-NMSMesh.py

Deja dos cosas, y las dos se versionan: el .blend con los grupos puestos
y work/models/scuttlermesh/pesos.json, que es lo que consume el splice.

Existe porque los pesos de la primera sesion NO se guardaron: scuttler.blend
tenia polySurface6 con 4820 vertices y cero grupos de vertices. Los numeros
estaban anotados y los datos no estaban en ninguna parte.

Tres cosas que costaron la sesion anterior:

  1. NMSDK IMPORTA pesos -crea un grupo por hueso y reparte blendWeight-
     pero NO los EXPORTA: escribe JointBindings, MeshBaseSkinMat y
     SkinMatrixLayout vacios. El muro es solo de salida.
  2. El importador exige que la carpeta repita la ruta interna de la
     escena (import_scene.py:220, base_path). Por eso el vanilla esta
     extraido en work/models/vanilla_freighterfiend/models/planets/...
  3. Las dos mallas no estan en el mismo espacio: el vanilla viene Z
     arriba y la nuestra Y arriba. Sin girar, RFourthLeg* y LFourthLeg*
     se quedan con 0 vertices y RFirstLeg3JNT se traga 1630.

Y el giro de 180 en Z no se decide contando grupos con vertices -eso da
GIRO_Z 0, que pone nuestro craneo mirando hacia atras-. Se decide por
donde cae la cabeza: la del vanilla esta en +Y.
"""

import json
import math
from pathlib import Path

import bpy

RAIZ = Path(os.path.expanduser(r"~\MODS\NMS_MOD_ZOMBIES"))
BLEND = RAIZ / "BLENDER" / "proyectos" / "scuttler.blend"
VANILLA = (RAIZ / "work" / "models" / "vanilla_freighterfiend" / "models" /
           "planets" / "creatures" / "spiderrig" / "freighterfiend.scene.mbin")
SALIDA = RAIZ / "work" / "models" / "scuttlermesh" / "pesos.json"

NUESTRA = "polySurface6"
GIRO_Z = 180
VACIOS_ESPERADOS = {"NewBack1JNT", "NewBack2JNT", "NewBack3JNT",
                    "LPincer1JNT", "RPincer1JNT"}


def caja(ob):
    co = [ob.matrix_world @ v.co for v in ob.data.vertices]
    lo = [min(c[i] for c in co) for i in range(3)]
    hi = [max(c[i] for c in co) for i in range(3)]
    return lo, hi


bpy.ops.wm.open_mainfile(filepath=str(BLEND))
nuestra = bpy.data.objects[NUESTRA]

bpy.ops.nmsdk.import_scene(path=str(VANILLA), clear_scene=False,
                           import_bones=True, import_collisions=False,
                           import_recursively=False)

vanilla = next(o for o in bpy.data.objects
               if o.type == "MESH" and o.vertex_groups and o is not nuestra)
armature = next(o for o in bpy.data.objects if o.type == "ARMATURE")
print(f"vanilla {vanilla.name}: {len(vanilla.data.vertices)} vertices, "
      f"{len(vanilla.vertex_groups)} grupos, {len(armature.data.bones)} huesos")

# 1. Alinear: el vanilla viene Z arriba, el nuestro Y arriba.
bpy.ops.object.select_all(action="DESELECT")
vanilla.select_set(True)
bpy.context.view_layer.objects.active = vanilla
vanilla.rotation_euler[0] += math.radians(90)
vanilla.rotation_euler[2] += math.radians(GIRO_Z)
bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)

# 2. Encajar la caja envolvente del vanilla en la nuestra.
lo_v, hi_v = caja(vanilla)
lo_n, hi_n = caja(nuestra)
escala = min((hi_n[i] - lo_n[i]) / (hi_v[i] - lo_v[i]) for i in range(3))
vanilla.scale = (escala, escala, escala)
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
lo_v, hi_v = caja(vanilla)
vanilla.location = [(lo_n[i] + hi_n[i]) / 2 - (lo_v[i] + hi_v[i]) / 2
                    for i in range(3)]
bpy.ops.object.transform_apply(location=True, rotation=False, scale=False)

# 3. Transferir los grupos, por superficie mas cercana.
bpy.ops.object.select_all(action="DESELECT")
vanilla.select_set(True)
nuestra.select_set(True)
bpy.context.view_layer.objects.active = nuestra
bpy.ops.object.data_transfer(
    use_reverse_transfer=True, data_type="VGROUP_WEIGHTS",
    vert_mapping="POLYINTERP_NEAREST", layers_select_src="ALL",
    layers_select_dst="NAME")

# 4. Limitar a 4 influencias y normalizar.
bpy.ops.object.vertex_group_limit_total(group_select_mode="ALL", limit=4)
bpy.ops.object.vertex_group_normalize_all(group_select_mode="ALL",
                                          lock_active=False)

grupos = {g.index: g.name for g in nuestra.vertex_groups}
salida = []
for v in nuestra.data.vertices:
    pares = sorted(((grupos[g.group], round(g.weight, 6))
                    for g in v.groups if g.weight > 0),
                   key=lambda p: -p[1])
    salida.append([round(v.co.x, 6), round(v.co.y, 6), round(v.co.z, 6),
                   pares])

# --- lo que puede fallar, y falla aqui y no en el juego ---
sin_peso = [i for i, e in enumerate(salida) if not e[3]]
assert not sin_peso, f"{len(sin_peso)} vertices sin peso: {sin_peso[:10]}"

asignaciones = sum(len(e[3]) for e in salida)
maximo = max(len(e[3]) for e in salida)
usados = {g for e in salida for g, _ in e[3]}
vacios = {g.name for g in nuestra.vertex_groups} - usados

print(f"vertices con peso: {len(salida)} de {len(nuestra.data.vertices)}")
print(f"asignaciones: {asignaciones}  "
      f"({asignaciones / len(salida):.2f} por vertice)")
print(f"maximo de huesos por vertice: {maximo}")
print(f"grupos creados: {len(nuestra.vertex_groups)}, con peso: {len(usados)}")
print(f"grupos a cero: {sorted(vacios)}")

assert len(salida) == 4820, len(salida)
assert maximo <= 2, f"algun vertice cuelga de {maximo} huesos"
assert vacios == VACIOS_ESPERADOS, f"grupos a cero inesperados: {vacios}"
for i, e in enumerate(salida):
    total = sum(p for _, p in e[3])
    assert abs(total - 1.0) < 1e-4, f"vertice {i} suma {total}"

cabezas = [e[1] for e in salida
           if any(g == "NewHeadJNT" and p > 0.5 for g, p in e[3])]
assert cabezas, "ningun vertice cuelga de NewHeadJNT"
centro = sum(cabezas) / len(cabezas)
print(f"centroide de la cabeza en Y: {centro:+.3f}")
assert centro > 0, (f"la cabeza cae en {centro:+.3f}: con GIRO_Z {GIRO_Z} el "
                    f"craneo mira hacia atras")

SALIDA.write_text(json.dumps(salida), encoding="utf-8")
print(f"escrito {SALIDA}")

bpy.data.objects.remove(vanilla, do_unlink=True)
bpy.data.objects.remove(armature, do_unlink=True)
bpy.ops.wm.save_as_mainfile(filepath=str(BLEND))
print(f"guardado {BLEND}")
```

- [ ] **Step 4: Correrlo**

```
"C:\Program Files\Blender Foundation\Blender 5.2\blender.exe" --background --python tools/Weight-NMSMesh.py
```

Esperado, y **si un assert salta hay que arreglarlo antes de seguir**:

```
vertices con peso: 4820 de 4820
asignaciones: 5137  (1.07 por vertice)
maximo de huesos por vertice: 2
grupos creados: 19, con peso: 14
grupos a cero: ['LPincer1JNT', 'NewBack1JNT', 'NewBack2JNT', 'NewBack3JNT', 'RPincer1JNT']
centroide de la cabeza en Y: +0.xxx
```

Las asignaciones pueden bailar un poco respecto a 5 137 —depende del `vert_mapping`—; lo que **no** puede bailar es 4 820 de 4 820, el máximo de 2, los cinco grupos vacíos y el signo del centroide. Si los nombres de los grupos vacíos salen distintos, hay que mirar la alineación antes de tocar `VACIOS_ESPERADOS`: es el síntoma exacto del giro mal puesto.

- [ ] **Step 5: Correr los tests, que ya no se saltan**

```
python -m unittest discover -s tools/tests
```

Esperado: `Ran 16 tests` · `OK`.

- [ ] **Step 6: Commit**

```bash
git add tools/Weight-NMSMesh.py tools/tests/test_pesos.py work/models/scuttlermesh/pesos.json BLENDER/proyectos/scuttler.blend
git commit -m "feat: Weight-NMSMesh, los pesos del SkrullCrawler escritos y versionados"
```

---

## Task 4: `nmsskin.py` — paleta, casado por posición y los canales 5 y 6

Aquí está el fallo que cerró el juego en la `PRUEBA05`: **el byte del canal 5 no es el número de hueso, es la posición dentro de la paleta**. Y aquí está el otro riesgo: el export parte 4 820 vértices en 11 357, así que el casado va por posición.

**Files:**
- Create: `tools/nmsskin.py`
- Create: `tools/tests/test_nmsskin.py`

**Interfaces:**
- Consumes: `nmsgeom.leer_streams`, `nmsgeom.descompilar`.
- Produces:
  - `leer_pesos(ruta: Path) -> list`
  - `leer_joints(scene_mxml: Path) -> dict[str, int]` — nombre → `JOINTINDEX`
  - `paleta(pesos: list, joints: dict) -> list[int]` — `JOINTINDEX` ascendente
  - `posiciones(streams) -> numpy.ndarray` de `(n, 3)` float32
  - `casar(destino: ndarray, pesos: list) -> ndarray` de `(n,)` int32
  - `canales(pesos, palet, joints, mapa) -> tuple[ndarray, ndarray]` — `(n,4) uint8` y `(n,4) float16`
  - `tejer(vertices: bytearray, idx, w, stride=20) -> bytearray`

- [ ] **Step 1: Escribir los tests que fallan**

Crear `tools/tests/test_nmsskin.py`:

```python
"""Tests de tools/nmsskin.py."""

import shutil
import sys
import tempfile
import unittest
from pathlib import Path

import numpy as np

RAIZ = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(RAIZ / "tools"))

import nmsgeom  # noqa: E402
import nmsskin  # noqa: E402

CONGELADA = RAIZ / "work" / "models" / "scuttlermesh"
ESCENA = CONGELADA / "FREIGHTERFIEND.SCENE.MBIN"
DATA = CONGELADA / "FREIGHTERFIEND.GEOMETRY.DATA.MBIN.PC"

# Tres vertices de juguete: dos cuelgan de un hueso y uno reparte.
PESOS_JUGUETE = [
    [0.0, 0.0, 0.0, [["RootJNT", 1.0]]],
    [1.0, 0.0, 0.0, [["NewHeadJNT", 1.0]]],
    [0.5, 0.0, 0.0, [["NewHeadJNT", 0.75], ["RootJNT", 0.25]]],
]
JOINTS_JUGUETE = {"RootJNT": 2, "NewHeadJNT": 40, "LPincer1JNT": 7}
TODOS = np.array([0, 1, 2])


class TestPaleta(unittest.TestCase):
    def test_solo_entran_los_grupos_con_peso_y_van_ascendentes(self):
        # LPincer1JNT existe en el esqueleto pero no recibe peso: fuera.
        self.assertEqual(nmsskin.paleta(PESOS_JUGUETE, JOINTS_JUGUETE), [2, 40])

    def test_un_grupo_que_no_es_hueso_revienta(self):
        with self.assertRaises(ValueError):
            nmsskin.paleta([[0, 0, 0, [["NoExisteJNT", 1.0]]]], JOINTS_JUGUETE)

    def test_el_byte_es_la_posicion_en_la_paleta_no_el_hueso(self):
        p = nmsskin.paleta(PESOS_JUGUETE, JOINTS_JUGUETE)
        idx, _ = nmsskin.canales(PESOS_JUGUETE, p, JOINTS_JUGUETE, TODOS)
        # NewHeadJNT es el JOINTINDEX 40, pero en la paleta ocupa el 1.
        self.assertEqual(list(idx[0]), [0, 0, 0, 0])
        self.assertEqual(list(idx[1]), [1, 0, 0, 0])
        self.assertEqual(list(idx[2]), [1, 0, 0, 0])
        self.assertEqual(idx.dtype, np.uint8)
        self.assertLess(int(idx.max()), len(p))

    def test_los_pesos_van_en_half_y_suman_uno(self):
        p = nmsskin.paleta(PESOS_JUGUETE, JOINTS_JUGUETE)
        _, w = nmsskin.canales(PESOS_JUGUETE, p, JOINTS_JUGUETE, TODOS)
        self.assertEqual(w.dtype, np.float16)
        self.assertEqual(w.shape, (3, 4))
        np.testing.assert_allclose(w.sum(axis=1).astype(np.float32),
                                   [1.0, 1.0, 1.0], atol=1e-3)
        self.assertAlmostEqual(float(w[2][0]), 0.75, places=3)


class TestCasado(unittest.TestCase):
    def test_los_partidos_caen_en_el_mismo_vertice_de_origen(self):
        # Dos vertices exportados en la misma posicion -partidos por
        # costura de UV- tienen que casar los dos con el mismo origen.
        destino = np.array([[1.0, 0.0, 0.0], [0.0, 0.0, 0.0],
                            [1.0, 0.0, 0.0]], dtype=np.float32)
        self.assertEqual(list(nmsskin.casar(destino, PESOS_JUGUETE)), [1, 0, 1])

    def test_una_posicion_que_no_existe_revienta(self):
        destino = np.array([[9.0, 9.0, 9.0]], dtype=np.float32)
        with self.assertRaises(ValueError):
            nmsskin.casar(destino, PESOS_JUGUETE)


class TestTejer(unittest.TestCase):
    def test_normal_y_tangente_quedan_intactas(self):
        vertices = bytearray(bytes(range(8)) + b"\x00" * 12)
        idx = np.array([[3, 0, 0, 0]], dtype=np.uint8)
        w = np.array([[1.0, 0, 0, 0]], dtype=np.float16)
        salida = nmsskin.tejer(vertices, idx, w)

        self.assertEqual(salida[0:8], bytes(range(8)))
        self.assertEqual(salida[8], 3)
        self.assertEqual(np.frombuffer(bytes(salida[12:20]),
                                       dtype="<f2")[0], np.float16(1.0))

    def test_un_buffer_con_otro_numero_de_vertices_revienta(self):
        with self.assertRaises(ValueError):
            nmsskin.tejer(bytearray(40), np.zeros((1, 4), dtype=np.uint8),
                          np.zeros((1, 4), dtype=np.float16))


class TestSobreLaMallaReal(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp(prefix="nmsskin-"))

    def tearDown(self):
        shutil.rmtree(self.tmp, ignore_errors=True)

    def _copia(self, origen):
        destino = self.tmp / origen.name
        shutil.copy(origen, destino)
        return destino

    def test_el_scene_da_114_joints_empezando_en_1(self):
        joints = nmsskin.leer_joints(
            nmsgeom.descompilar(self._copia(ESCENA)))
        self.assertEqual(len(joints), 114)
        self.assertEqual(min(joints.values()), 1)
        self.assertEqual(max(joints.values()), 114)
        self.assertEqual(joints["RootJNT"], 2)

    def test_el_stream_de_posiciones_da_11357_puntos(self):
        s = nmsgeom.leer_streams(nmsgeom.descompilar(self._copia(DATA)))
        self.assertEqual(nmsskin.posiciones(s).shape, (11357, 3))


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: Correrlos y ver que fallan**

```
python -m unittest discover -s tools/tests
```

Esperado: `ModuleNotFoundError: No module named 'nmsskin'`.

- [ ] **Step 3: Escribir `tools/nmsskin.py`**

```python
"""La piel: de pesos por vertice de Blender a los canales 5 y 6 del buffer.

Biblioteca, no comando. No abre archivos del juego: recibe los streams
que le da nmsgeom y devuelve arrays.

EL DETALLE QUE CIERRA EL JUEGO, de import_scene.py:1085-1098:

    skin_mats = SkinMatrixLayout[FIRSTSKINMAT : LASTSKINMAT]
    por cada skin_mat -> un grupo de vertices, en ese orden
    blend_indices[j] indexa DIRECTAMENTE esa lista de grupos

El byte del canal 5 NO es el numero de hueso: es la posicion dentro del
tramo FIRSTSKINMAT->LASTSKINMAT. Los valores de SkinMatrixLayout si son
JOINTINDEX, y JOINTINDEX empieza en 1: RootJNT es el 2. Confundir las dos
cosas es el "indices fuera de rango" que cerro el juego en la PRUEBA05.

Y el casado va POR POSICION, no por indice: el exportador parte nuestros
4820 vertices en 11357 -uno por combinacion de normal y UV- y los
partidos comparten posicion. Se casa por la posicion redondeada a half,
que es la precision a la que el buffer las guarda.
"""

import json
import xml.etree.ElementTree as ET
from pathlib import Path

import numpy as np

RANURAS = 4  # cuatro huecos de hueso por vertice, del contrato del vanilla


def leer_pesos(ruta: Path) -> list:
    return json.loads(Path(ruta).read_text(encoding="utf-8"))


def leer_joints(scene_mxml: Path) -> dict:
    """Nombre de hueso -> JOINTINDEX, leidos del .SCENE."""
    raiz = ET.parse(Path(scene_mxml)).getroot()
    salida = {}
    for nodo in raiz.iter():
        if nodo.get("value") != "TkSceneNodeData":
            continue
        campos = {p.get("name"): p for p in nodo}
        tipo = campos.get("Type")
        if tipo is None or tipo.get("value") != "JOINT":
            continue
        nombre = campos["Name"].get("value")
        for attr in campos["Attributes"]:
            claves = {p.get("name"): p.get("value") for p in attr}
            if claves.get("Name") == "JOINTINDEX":
                salida[nombre] = int(claves["Value"])
    return salida


def paleta(pesos: list, joints: dict) -> list:
    """Los JOINTINDEX de los grupos que reciben peso, ascendentes.

    Ascendentes porque asi lo trae el vanilla -su SkinMatrixLayout empieza
    en 2, que es RootJNT- y porque hace la salida reproducible.
    """
    usados = {g for entrada in pesos for g, p in entrada[3] if p > 0}
    faltan = usados - set(joints)
    if faltan:
        raise ValueError(f"grupos que no son huesos del .SCENE: "
                         f"{sorted(faltan)}")
    return sorted(joints[g] for g in usados)


def _clave(xyz) -> bytes:
    h = np.asarray(xyz, dtype="<f2")
    h = np.where(h == 0, np.float16(0), h)  # -0.0 y 0.0 son la misma posicion
    return h.tobytes()


def posiciones(streams) -> np.ndarray:
    """Las posiciones del buffer. Stride 16: 4 half de posicion y 4 de UV."""
    crudo = np.frombuffer(streams.posiciones, dtype="<f2").reshape(-1, 8)
    return crudo[:, :3].astype(np.float32)


def casar(destino: np.ndarray, pesos: list) -> np.ndarray:
    """Para cada vertice exportado, en que entrada de pesos nacio."""
    tabla = {}
    for i, entrada in enumerate(pesos):
        tabla.setdefault(_clave(entrada[:3]), i)

    salida = np.full(len(destino), -1, dtype=np.int32)
    perdidos = []
    for i, xyz in enumerate(destino):
        j = tabla.get(_clave(xyz))
        if j is None:
            perdidos.append(i)
        else:
            salida[i] = j

    if perdidos:
        origen = np.array([e[:3] for e in pesos], dtype=np.float32)
        raise ValueError(
            f"{len(perdidos)} de {len(destino)} vertices exportados no casan "
            f"con ninguna posicion de pesos.json (primeros: {perdidos[:5]}).\n"
            f"  caja del buffer: {destino.min(axis=0)} .. "
            f"{destino.max(axis=0)}\n"
            f"  caja de pesos:   {origen.min(axis=0)} .. "
            f"{origen.max(axis=0)}\n"
            f"Si las cajas no coinciden, pesos.json salio de otra malla.")
    return salida


def canales(pesos: list, palet: list, joints: dict,
            mapa: np.ndarray) -> tuple:
    """Los canales 5 y 6, uno por vertice exportado."""
    posicion_en_paleta = {j: k for k, j in enumerate(palet)}
    idx = np.zeros((len(mapa), RANURAS), dtype=np.uint8)
    w = np.zeros((len(mapa), RANURAS), dtype=np.float16)

    for i, origen in enumerate(mapa):
        for r, (grupo, peso) in enumerate(pesos[origen][3][:RANURAS]):
            idx[i][r] = posicion_en_paleta[joints[grupo]]
            w[i][r] = peso

    if len(mapa) and int(idx.max()) >= len(palet):
        raise ValueError(f"indice {int(idx.max())} para una paleta de "
                         f"{len(palet)}: el juego cerraria sin avisar")
    return idx, w


def tejer(vertices: bytearray, idx: np.ndarray, w: np.ndarray,
          stride: int = 20) -> bytearray:
    """Mete los dos canales en su hueco, sin tocar normal ni tangente."""
    v = np.frombuffer(bytes(vertices), dtype=np.uint8).reshape(-1, stride)
    v = v.copy()
    if len(v) != len(idx):
        raise ValueError(f"{len(v)} vertices en el buffer y {len(idx)} pesados")
    v[:, 8:12] = idx
    v[:, 12:20] = w.view(np.uint8).reshape(-1, 8)
    return bytearray(v.tobytes())
```

- [ ] **Step 4: Correr los tests**

```
python -m unittest discover -s tools/tests
```

Esperado: `Ran 26 tests` · `OK`.

- [ ] **Step 5: Commit**

```bash
git add tools/nmsskin.py tools/tests/test_nmsskin.py
git commit -m "feat: nmsskin, la paleta y los canales 5 y 6"
```

---

## Task 5: `Skin-NMSGeometry.py` — el comando que junta todo

**Files:**
- Create: `tools/Skin-NMSGeometry.py`

**Interfaces:**
- Consumes: todo `nmsgeom` y todo `nmsskin`.
- Produces: la carpeta destino con los tres `.MBIN` reescritos y sus `.MXML` al lado. `FIRSTSKINMAT` 0 y `LASTSKINMAT` = tamaño de la paleta en el nodo MESH del `.SCENE`.

- [ ] **Step 1: Escribir `tools/Skin-NMSGeometry.py`**

```python
"""Pone la piel en el .GEOMETRY: sube el stride de 8 a 20 y llena los
canales 5 y 6 con los pesos de pesos.json.

    python tools/Skin-NMSGeometry.py <carpeta origen> <carpeta destino>

Copia el la carpeta entera y trabaja solo sobre la copia: la de origen no
se toca nunca, y asi no hay un paso manual que se pueda olvidar. El
sidecar sale de <origen>/pesos.json. Si el destino ya existe, aborta.

Reescribe tres archivos y recompila los tres, porque lo que reparte el
.lua son los .MBIN:

    .GEOMETRY.DATA.MBIN.PC   el bloque de vertices, de stride 8 a 20
    .GEOMETRY.MBIN.PC        VertexLayout, StreamMetaDataArray,
                             SkinMatrixLayout y MeshBaseSkinMat
    .SCENE.MBIN              FIRSTSKINMAT / LASTSKINMAT del nodo de malla

NO toca FFIENDMAT: el flag _F02_SKINNED va el ultimo y va en el .lua.
Con el flag puesto y los pesos mal, el bicho se estira sin forma; con los
indices fuera de rango, el juego cierra sin avisar. Por eso detras de esto
va tools/Check-NMSGraft.py, antes de construir nada.
"""

import shutil
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import nmsgeom
import nmsskin

STRIDE_VIEJO = 8
STRIDE_NUEVO = 20


def _lista(raiz, nombre, valores):
    cont = next(p for p in raiz.iter()
                if p.get("name") == nombre and p.get("value") is None)
    for hijo in list(cont):
        cont.remove(hijo)
    for i, v in enumerate(valores):
        ET.SubElement(cont, "Property",
                      {"name": nombre, "value": str(v), "_index": str(i)})


def _nodos_malla(raiz):
    salida = []
    for n in raiz.iter():
        if n.get("value") != "TkSceneNodeData":
            continue
        if any(p.get("name") == "Type" and p.get("value") == "MESH" for p in n):
            salida.append(n)
    return salida


def _poner_attr(nodo, clave, valor):
    cont = next(p for p in nodo if p.get("name") == "Attributes")
    for attr in cont:
        campos = {p.get("name"): p for p in attr}
        if campos["Name"].get("value") == clave:
            campos["Value"].set("value", str(valor))
            return
    raise KeyError(clave)


def coser(origen: Path, destino: Path) -> None:
    if destino.exists():
        sys.exit(f"{destino} ya existe: borra o elige otra")
    shutil.copytree(origen, destino)
    print(f"  copiado    {origen} -> {destino}")

    pesos = nmsskin.leer_pesos(origen / "pesos.json")
    data = next(destino.glob("*.GEOMETRY.DATA.MBIN.PC"))
    geo = next(destino.glob("*.GEOMETRY.MBIN.PC"))
    escena = next(destino.glob("*.SCENE.MBIN"))

    data_mxml = nmsgeom.descompilar(data)
    geo_mxml = nmsgeom.descompilar(geo)
    escena_mxml = nmsgeom.descompilar(escena)

    joints = nmsskin.leer_joints(escena_mxml)
    palet = nmsskin.paleta(pesos, joints)
    print(f"  paleta     {len(palet)} huesos de {len(joints)}: {palet}")

    s = nmsgeom.leer_streams(data_mxml)
    mapa = nmsskin.casar(nmsskin.posiciones(s), pesos)
    print(f"  casado     {len(mapa)} vertices exportados sobre "
          f"{len(pesos)} de Blender")

    idx, w = nmsskin.canales(pesos, palet, joints, mapa)
    ancho = nmsgeom.ampliar_stride(s.vertices, STRIDE_VIEJO, STRIDE_NUEVO)
    s.vertices = bytes(nmsskin.tejer(ancho, idx, w, STRIDE_NUEVO))
    print(f"  vertices   {len(s.vertices)} bytes a stride {STRIDE_NUEVO}")

    nmsgeom.escribir_streams(data_mxml, s)
    data = nmsgeom.compilar(data_mxml)

    nmsgeom.parchear_layout(geo_mxml)
    nmsgeom.parchear_metadata(geo_mxml, data, s)

    arbol = ET.parse(geo_mxml)
    raiz = arbol.getroot()
    _lista(raiz, "SkinMatrixLayout", palet)
    _lista(raiz, "MeshBaseSkinMat", [0])
    arbol.write(geo_mxml, encoding="utf-8", xml_declaration=True)
    nmsgeom.compilar(geo_mxml)

    arbol = ET.parse(escena_mxml)
    mallas = _nodos_malla(arbol.getroot())
    if len(mallas) != 1:
        sys.exit(f"{len(mallas)} nodos MESH: este tool asume uno")
    _poner_attr(mallas[0], "FIRSTSKINMAT", 0)
    _poner_attr(mallas[0], "LASTSKINMAT", len(palet))
    arbol.write(escena_mxml, encoding="utf-8", xml_declaration=True)
    nmsgeom.compilar(escena_mxml)

    print(f"  .SCENE     FIRSTSKINMAT 0 -> LASTSKINMAT {len(palet)}")
    print(f"\n  Ahora: python tools/Check-NMSGraft.py {destino}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    print()
    coser(Path(sys.argv[1]), Path(sys.argv[2]))
    print()
```

- [ ] **Step 2: Correrlo sobre la malla real**

```
python tools/Skin-NMSGeometry.py work/models/scuttlermesh work/models/scuttlermesh_anim
```

Esperado:

```
  copiado    work\models\scuttlermesh -> work\models\scuttlermesh_anim
  paleta     14 huesos de 114: [...]
  casado     11357 vertices exportados sobre 4820 de Blender
  vertices   227140 bytes a stride 20
  .SCENE     FIRSTSKINMAT 0 -> LASTSKINMAT 14
```

**Si el casado revienta**, el mensaje trae las dos cajas envolventes. Cajas distintas = `pesos.json` salió de otra malla o de otra escala; hay que volver a la Task 3.

- [ ] **Step 3: Comprobar a mano que el buffer creció**

```
python -c "import sys; sys.path.insert(0,'tools'); import nmsgeom; from pathlib import Path; s=nmsgeom.leer_streams(Path('work/models/scuttlermesh_anim/FREIGHTERFIEND.GEOMETRY.DATA.MXML')); print(len(s.vertices), len(s.indices), len(s.posiciones))"
```

Esperado: `227140 57552 181712`.

- [ ] **Step 4: Commit**

```bash
git add tools/Skin-NMSGeometry.py work/models/scuttlermesh_anim
git commit -m "feat: Skin-NMSGeometry, los canales de piel en el buffer"
```

---

## Task 6: `Check-NMSGraft.py` — cinco comprobaciones que pueden fallar

Una verificación que no puede fallar no es una verificación: por eso el paso 5 corrompe la carpeta a propósito y exige que el check la cace.

**Files:**
- Modify: `tools/Check-NMSGraft.py`

**Interfaces:**
- Consumes: `nmsgeom.leer_streams`, `nmsgeom.layout`, `nmsgeom.cabecera`, `nmsskin.leer_joints`.
- Produces: nada nuevo. Sigue siendo `python tools/Check-NMSGraft.py <carpeta>`, con salida 1 si algo se sale.

- [ ] **Step 1: Enganchar las bibliotecas**

En `tools/Check-NMSGraft.py`, tras los `import` de cabecera:

```python
import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))

import nmsgeom
import nmsskin
```

Y en `revisar()`, justo antes de `return fallos`:

```python
    fallos += _revisar_piel(carpeta, geo, mallas)
```

- [ ] **Step 2: Escribir `_revisar_piel()`, antes de `revisar()`**

```python
def _revisar_piel(carpeta, geo, mallas):
    """Lo que vive en el binario y el XML solo no ve.

    Existe porque con el flag _F02_SKINNED puesto y los indices de hueso
    fuera de rango el juego CIERRA SIN AVISAR. Eso paso en la PRUEBA05 y
    costo una sesion de juego entera.
    """
    fallos = []
    data_mxml = next(carpeta.glob("*.GEOMETRY.DATA.MXML"), None)
    if data_mxml is None:
        return ["no hay .GEOMETRY.DATA.MXML: descompila el .DATA primero"]

    geo_mxml = next(carpeta.glob("*.GEOMETRY.MXML"))
    s = nmsgeom.leer_streams(data_mxml)
    d = nmsgeom.layout(geo_mxml)
    stride = d["stride"]
    vertices = int(geo.get("VertexCount", 0))

    if stride * vertices != len(s.vertices):
        fallos.append(f"stride {stride} x {vertices} vertices = "
                      f"{stride * vertices}, pero el buffer trae "
                      f"{len(s.vertices)} bytes")

    data_mbin = next(carpeta.glob("*.GEOMETRY.DATA.MBIN.PC"), None)
    if data_mbin is not None:
        inicio = nmsgeom.cabecera(data_mbin, s)
        meta = ET.parse(geo_mxml).getroot().find(
            ".//Property[@value='TkMeshMetaData']")
        espera = {"VertexDataSize": len(s.vertices),
                  "VertexDataOffset": inicio,
                  "IndexDataSize": len(s.indices),
                  "IndexDataOffset": len(s.vertices),
                  "VertexPositionDataSize": len(s.posiciones),
                  "VertexPositionDataOffset":
                      inicio + len(s.vertices) + len(s.indices)}
        for clave, valor in espera.items():
            dice = int(meta.find(f"Property[@name='{clave}']").get("value"))
            if dice != valor:
                fallos.append(f"{clave} dice {dice}, pero el .DATA da {valor}")

    crudo = geo.get("SkinMatrixLayout")
    palet = ([int(p.get("value")) for p in crudo]
             if isinstance(crudo, list) else [])
    joints = nmsskin.leer_joints(next(carpeta.glob("*.SCENE.MXML")))
    fuera = [v for v in palet if v not in set(joints.values())]
    if fuera:
        fallos.append(f"SkinMatrixLayout apunta a JOINTINDEX que no existen: "
                      f"{fuera[:8]} (los del .SCENE van de 1 a {len(joints)})")

    for nodo in mallas:
        attr = atributos(nodo)
        primero = int(attr.get("FIRSTSKINMAT", 0))
        ultimo = int(attr.get("LASTSKINMAT", 0))
        if ultimo == primero:
            continue  # malla rigida a proposito: no hay piel que revisar

        if 5 not in d["elementos"] or 6 not in d["elementos"]:
            fallos.append(f"{nombre_de(nodo)} pide piel, pero el VertexLayout "
                          f"no declara los canales 5 y 6")
            continue

        v = np.frombuffer(s.vertices, dtype=np.uint8).reshape(-1, stride)
        idx = v[:, d["elementos"][5]: d["elementos"][5] + 4]
        w = v[:, d["elementos"][6]: d["elementos"][6] + 8].copy().view("<f2")

        tope = ultimo - primero
        peor = int(idx.max())
        if peor >= tope:
            culpables = int((idx.max(axis=1) >= tope).sum())
            fallos.append(f"{nombre_de(nodo)}: indice de hueso {peor} con un "
                          f"rango de {tope} ({culpables} vertices). "
                          f"EL JUEGO CIERRA SIN AVISAR")

        suma = w.astype("float32").sum(axis=1)
        malos = int((abs(suma - 1.0) > 0.01).sum())
        if malos:
            i = int(abs(suma - 1.0).argmax())
            fallos.append(f"{nombre_de(nodo)}: {malos} vertices con pesos que "
                          f"no suman 1 (el peor, el {i}, suma {suma[i]:.3f})")

    return fallos
```

- [ ] **Step 3: Correrlo sobre la carpeta nueva**

```
python tools/Check-NMSGraft.py work/models/scuttlermesh_anim
```

Esperado: `todos los indices del .SCENE caen dentro del .GEOMETRY`, salida 0.

- [ ] **Step 4: Correrlo sobre la carpeta congelada, que sigue rígida**

```
python tools/Check-NMSGraft.py work/models/scuttlermesh
```

Esperado: también pasa. `LASTSKINMAT` 0 = `FIRSTSKINMAT` 0, así que las comprobaciones de piel se saltan; las de stride y offsets sí corren, con stride 8. Si el `.GEOMETRY.DATA.MXML` no está descompilado en esa carpeta, el check lo dice y no revienta.

- [ ] **Step 5: Romperlo a propósito y exigir que lo cace**

```
python - <<'EOF'
import shutil, sys
import numpy as np
from pathlib import Path
sys.path.insert(0, "tools")
import nmsgeom
roto = Path("work/models/scuttlermesh_roto")
shutil.rmtree(roto, ignore_errors=True)
shutil.copytree("work/models/scuttlermesh_anim", roto)
mxml = roto / "FREIGHTERFIEND.GEOMETRY.DATA.MXML"
s = nmsgeom.leer_streams(mxml)
v = np.frombuffer(s.vertices, dtype=np.uint8).reshape(-1, 20).copy()
v[7][8] = 250                       # un indice de hueso disparatado
s.vertices = v.tobytes()
nmsgeom.escribir_streams(mxml, s)
print("corrompido el vertice 7")
EOF
python tools/Check-NMSGraft.py work/models/scuttlermesh_roto
```

Esperado: salida **1**, con `indice de hueso 250 con un rango de 14 (1 vertices). EL JUEGO CIERRA SIN AVISAR`.

Después, borrar la carpeta rota:

```
python -c "import shutil; shutil.rmtree('work/models/scuttlermesh_roto')"
```

- [ ] **Step 6: Commit**

```bash
git add tools/Check-NMSGraft.py
git commit -m "feat: Check-NMSGraft caza los indices de hueso fuera de rango"
```

---

## Task 7: la pasada completa, de cero

Que los tres comandos corran seguidos sobre una carpeta que no existe todavía, para saber que el conducto entero funciona sin restos de las pruebas anteriores.

**Files:**
- Modify: `docs/PENDIENTES.md`
- Modify: `work/scripts/malla/README.md`

- [ ] **Step 1: Borrar la salida y rehacerla entera**

```
python -c "import shutil; shutil.rmtree('work/models/scuttlermesh_anim', ignore_errors=True)"
python tools/Skin-NMSGeometry.py work/models/scuttlermesh work/models/scuttlermesh_anim
python tools/Check-NMSGraft.py work/models/scuttlermesh_anim
python -m unittest discover -s tools/tests
```

Esperado: los tres en verde, `Check` con salida 0 y `OK` en los tests.

- [ ] **Step 2: Anotar en `docs/PENDIENTES.md`**

En §2.1, marcar los pasos 3 y 4 del bloque de la ruta como `[HECHO]`, igual que los dos primeros, y añadir debajo:

```markdown
> **Pasos 3 y 4 hechos, sin entrar al juego.** `work/models/scuttlermesh_anim/` lleva el
> buffer a stride 20 con los canales 5 y 6, `SkinMatrixLayout` de 14 huesos y el nodo de
> malla con `FIRSTSKINMAT` 0 → `LASTSKINMAT` 14. `Check-NMSGraft` pasa. Falta el paso 5
> —`_F02_SKINNED`— que va en el `.lua` de la `PRUEBA12` junto a `M-TEX`. El diseño y el plan,
> en [`superpowers/specs/2026-08-14-skin-nmsgeometry-design.md`](superpowers/specs/2026-08-14-skin-nmsgeometry-design.md).
```

- [ ] **Step 3: Anotar en `work/scripts/malla/README.md`**

Añadir a la tabla de pruebas, después de la fila de la `PRUEBA11`:

```markdown
| `PRUEBA12` | **Piel + normal propio.** El buffer a stride 20 con los canales 5 y 6, `_F02_SKINNED` de vuelta en `FFIENDMAT` y el `gNormalMap` propio | ⬜ el `.GEOMETRY` está hecho y pasa el `Check`; falta escribir el `.lua` |
```

Y debajo de la tabla:

> **Las dos cosas van en el MISMO `.lua` y las mide una sola entrada al juego.** Si sale mal,
> el `.GEOMETRY` dice cuál de las dos falló sin volver a entrar: el bicho estirado sin forma
> es la piel, el bicho bien plantado y con la textura rara es el normal.

- [ ] **Step 4: Commit**

```bash
git add docs/PENDIENTES.md work/scripts/malla/README.md
git commit -m "docs: pasos 3 y 4 de M-ANIM hechos, queda el flag"
```
