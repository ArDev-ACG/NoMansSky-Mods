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
PESOS = CONGELADA / "pesos.json"

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

    def test_casa_aunque_la_posicion_no_sea_exacta(self):
        # El caso real: el buffer guarda en half y pesos.json en float, asi
        # que el mismo vertice sale movido un ULP. Casar por clave exacta
        # fallaba aqui, y fallaba en 10014 de los 11357 de la malla buena.
        destino = np.array([[1.0008, 0.0, 0.0]], dtype=np.float32)
        self.assertEqual(list(nmsskin.casar(destino, PESOS_JUGUETE)), [1])

    def test_por_encima_de_la_tolerancia_no_casa(self):
        destino = np.array([[1.0 + 2 * nmsskin.TOLERANCIA, 0.0, 0.0]],
                           dtype=np.float32)
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

    def test_los_11357_casan_y_ningun_indice_se_sale_de_la_paleta(self):
        # La prueba de verdad, la que los tests de juguete no hacen: pesos.json
        # contra el buffer real. Aqui se vio que el casado exacto no valia.
        pesos = nmsskin.leer_pesos(PESOS)
        joints = nmsskin.leer_joints(nmsgeom.descompilar(self._copia(ESCENA)))
        s = nmsgeom.leer_streams(nmsgeom.descompilar(self._copia(DATA)))

        palet = nmsskin.paleta(pesos, joints)
        # Cuantos huesos hay depende de como se pese, y ya cambio una vez:
        # eran 14 con el reparto que fallo en partida el 15/08 y son 41
        # pesando por hueso mas cercano. Lo que NO puede cambiar es que
        # quepan en un byte, que vayan ascendentes y que existan todos.
        self.assertLessEqual(len(palet), 256)
        self.assertEqual(palet, sorted(palet))
        self.assertEqual(len(set(palet)), len(palet))
        self.assertTrue(set(palet) <= set(joints.values()))
        self.assertIn(joints["RootJNT"], palet)

        mapa = nmsskin.casar(nmsskin.posiciones(s), pesos)
        self.assertEqual(len(mapa), 11357)
        # Los 4820 origenes se alcanzan todos: es el reparto 4820 -> 11357.
        self.assertEqual(len(set(mapa.tolist())), 4820)

        idx, w = nmsskin.canales(pesos, palet, joints, mapa)
        self.assertLess(int(idx.max()), len(palet))
        np.testing.assert_allclose(w.sum(axis=1).astype(np.float32),
                                   np.ones(11357), atol=1e-3)


if __name__ == "__main__":
    unittest.main()
