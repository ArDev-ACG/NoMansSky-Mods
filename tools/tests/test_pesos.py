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
