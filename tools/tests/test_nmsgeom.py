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


if __name__ == "__main__":
    unittest.main()
