"""Invariantes de work/models/scuttlermesh/pesos.json.

No testea el script de Blender -bpy no existe fuera de Blender-: testea
lo que el script deja escrito, que es lo unico que consume el splice.
"""

import json
import unittest
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[2]
PESOS = RAIZ / "work" / "models" / "scuttlermesh" / "pesos.json"

# Lo que se probo en partida el 15/08 y salio mal: las puntas de las dos
# patas delanteras se llevaban el 82% de la malla y RootJNT tenia 17
# vertices, o sea que el cuerpo colgaba de las patas. Al caminar, las patas
# se llevaban el torso. Estos numeros son la frontera entre aquello y un
# reparto sano; salen del comentario de tools/Weight-NMSMesh.py.
#
# Recalibrados el 26/08 contra el VANILLA, que es la referencia que faltaba:
#
#   TOPE_REPARTO  el FreighterFiend pone el 45,9% de su propia malla en
#                 RootJNT. El tope de 0,35 rechazaba pesados buenos por algo
#                 que el juego hace de serie.
#   TOPE_PUNTA    ahora se mide CONTRA EL TRONCO, no contra la malla entera.
#                 La fraccion de vertices no es comparable entre las dos
#                 mallas -el vanilla amontona el 73% de los suyos en el
#                 cuerpo y la nuestra, decimada, los reparte parejos-. El
#                 fallo del 15/08 era 43,2% de punta con el tronco al 0,4%:
#                 la punta CIEN VECES el tronco.
TOPE_REPARTO = 0.50
MINIMO_TRONCO = 0.30
TOPE_PUNTA = 0.50
PUNTAS = ("Leg3", "Leg4", "END")


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

    def _reparto(self):
        cuenta = {}
        for e in self.pesos:
            g = max(e[3], key=lambda t: t[1])[0]
            cuenta[g] = cuenta.get(g, 0) + 1
        return cuenta

    def test_ningun_hueso_se_lleva_media_malla(self):
        peor, n = max(self._reparto().items(), key=lambda t: t[1])
        self.assertLess(n / len(self.pesos), TOPE_REPARTO,
                        f"{peor} domina {n} de {len(self.pesos)} vertices")

    def test_el_cuerpo_cuelga_de_la_columna(self):
        # El 15/08 RootJNT tenia 17 vertices de 4820 y el cuerpo colgaba de
        # las puntas de las patas delanteras.
        tronco = sum(n for g, n in self._reparto().items()
                     if "Root" in g or "Back" in g)
        self.assertGreaterEqual(tronco / len(self.pesos), MINIMO_TRONCO)

    def test_ninguna_punta_de_miembro_domina(self):
        reparto = self._reparto()
        tronco = sum(n for g, n in reparto.items()
                     if "Root" in g or "Back" in g) / len(self.pesos)
        for g, n in reparto.items():
            if any(t in g for t in PUNTAS):
                with self.subTest(hueso=g):
                    self.assertLess(n / len(self.pesos), tronco * TOPE_PUNTA)


if __name__ == "__main__":
    unittest.main()
