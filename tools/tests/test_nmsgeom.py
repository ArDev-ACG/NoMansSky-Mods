"""Tests de tools/nmsgeom.py. Se corren desde la raiz del repo:

    python -m unittest discover -s tools/tests
"""

import shutil
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

    def test_el_geometry_parcheado_vuelve_a_compilar(self):
        # Que el MXML parcheado se pueda volver a PARSEAR no demuestra que
        # MBINCompiler lo acepte. Y si no lo acepta, no se sabria hasta
        # construir el mod.
        nmsgeom.parchear_layout(self.geo)
        vuelta = nmsgeom.descompilar(nmsgeom.compilar(self.geo))
        self.assertEqual(nmsgeom.layout(vuelta),
                         {"stride": 20, "elementos": {2: 0, 3: 4, 5: 8, 6: 12}})


if __name__ == "__main__":
    unittest.main()
