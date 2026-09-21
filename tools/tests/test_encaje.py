"""Que cada hueso tenga su carne AL LADO, y del lado que le toca.

Existe por el 2026-09-20: el xenodog salio en partida con las patas
barriendo arcos de metro y medio y el cuerpo abriendose en esquirlas, y
NINGUNA comprobacion de las que habia lo vio venir.

POR QUE NO LO VIO NADIE. Lo que se miraba era `Pose-NMSMesh.py`, que da
`tension` -cuanto se estira una arista respecto a sus vecinas- y dio
0,11..0,20 m, por debajo del cry wolf. Y es verdad: un trozo RIGIDO que se
va volando por un arco de dos metros no se estira NADA. La tension es
ciega a esto por construccion. `Check-NMSGraft.py` tampoco, porque mira
que los indices caigan dentro del rango, no donde cae la geometria.

LO QUE SE MIDE AQUI. Cada hueco de la paleta tiene dos posiciones: donde
esta el hueso en la pose de bind -de la inversa de su InvBindMatrix- y el
centroide de los vertices que cuelgan de el. Si no coinciden, el hueso
arrastra su trozo desde fuera. En reposo no se nota, porque el bind lo
cancela; al animar, cada grado de giro se multiplica por la distancia.

LO QUE SE MIRA ES EL LADO, NO LA DISTANCIA. Antes hubo aqui un tope de
0,60 m sobre la distancia y se quito el mismo dia: separaba el cry wolf
(patas a 0,13..0,30) del xenodog (1,07..1,47) pero NO por la causa que
importa. Medido: si se centran las dos nubes -o sea se le quita el
desplazamiento global entre malla y esqueleto- las dos medianas quedan en
0,58 el xenodog y 0,50 el cry wolf. La distancia bruta la manda ese
desplazamiento, y el conducto lo acepta A PROPOSITO: `escala_piel=1.0` y
el comentario de `Weight-NMSMesh.py` que dice que el pesado NO puede
escalar el esqueleto para que quepa. Un tope ahi separaba dos modelos por
casualidad, no por causa.

El espejo si es causa, y es binario: o el hueso y su carne estan del mismo
lado de la linea media o no.

LAS CIFRAS, medidas el 20/09 con `nmsskin.encaje`:

    modelo            huecos   espejo
    vanilla               42   ok
    cry wolf               7   4 de 4
    xenodog, antes        10   0 de 4
    xenodog, arreglado    10   4 de 4

El xenodog cruzaba LAS CUATRO. `RFirstLeg1JNT` estaba en x +0,22 y sus
vertices en x -0,50: las patas izquierdas de la malla las movian los
huesos derechos del esqueleto, asi que al andar el bicho se hacia tijera.
La causa, en `Weight-NMSMesh.py`: los cortes leian el lado DESPUES del
giro de overlay `Rz(180) @ Rx(90)`, que existe solo para elegir regiones
con el esqueleto encima de la malla y que EN PARTIDA no se aplica.

EL CORTE, que tampoco se eligio a ojo:

  LATERAL     |x| del bind > 0,10. Separa limpio: las patas van de 0,14 a
              0,23 y los huesos del eje -Root, Back, Tail, Head- no pasan
              de 0,08.

LO QUE ESTE TEST NO MIRA, y conviene saberlo: que la malla este girada
respecto al esqueleto. Se comprobo y NO lo esta -girar las posiciones
90 grados sobre X empeora el encaje de 0,58 a 0,96- pero si algun dia lo
estuviera, el espejo podria seguir saliendo verde.
"""

import shutil
import sys
import tempfile
import unittest
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(RAIZ / "tools"))

import nmsgeom  # noqa: E402
import nmsskin  # noqa: E402

MODELOS = RAIZ / "work" / "models"
VANILLA = (MODELOS / "vanilla_7.0_fiend" / "models" / "planets" / "creatures"
           / "spiderrig")
CRYWOLF = MODELOS / "crywolfmesh_anim7"
XENODOG = MODELOS / "xenodogmesh_anim"

LATERAL = 0.10   # |x| del bind a partir del cual el hueso es de un lado


def _busca(carpeta: Path, sufijo: str):
    """El archivo que acaba en `sufijo`. El vanilla los trae en minusculas."""
    for hijo in sorted(carpeta.iterdir()):
        if hijo.is_file() and hijo.name.upper().endswith(sufijo):
            return hijo
    return None


def _mxml(carpeta: Path, tmp: Path, sufijo_mxml: str, sufijo_mbin: str):
    """El .MXML si esta; si no, descompila una COPIA en `tmp`.

    Copia antes de descompilar porque MBINCompiler escribe al lado del
    original, y `work/models/` es material de trabajo que no se toca.
    """
    ya = _busca(carpeta, sufijo_mxml)
    if ya is not None:
        return ya
    fuente = _busca(carpeta, sufijo_mbin)
    if fuente is None:
        return None
    return nmsgeom.descompilar(Path(shutil.copy(fuente, tmp / fuente.name)))


def _hay(carpeta: Path) -> bool:
    return carpeta.is_dir() and _busca(carpeta, ".GEOMETRY.DATA.MBIN.PC")


class _Encaje(unittest.TestCase):
    """Base: monta el encaje de una carpeta de modelo."""

    CARPETA = None

    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp(prefix="encaje-"))
        self.addCleanup(shutil.rmtree, self.tmp, ignore_errors=True)
        geo = _mxml(self.CARPETA, self.tmp,
                    ".GEOMETRY.MXML", ".GEOMETRY.MBIN.PC")
        data = _mxml(self.CARPETA, self.tmp,
                     ".GEOMETRY.DATA.MXML", ".GEOMETRY.DATA.MBIN.PC")
        escena = _mxml(self.CARPETA, self.tmp, ".SCENE.MXML", ".SCENE.MBIN")
        if not (geo and data and escena):
            self.skipTest(f"faltan los MXML/MBIN de {self.CARPETA}")
        streams = nmsgeom.leer_streams(data)
        stride = len(streams.vertices) // (len(streams.posiciones) // 16)
        self.filas = nmsskin.encaje(geo, streams, stride,
                                    nmsskin.leer_joints(escena))

    @property
    def laterales(self):
        return [f for f in self.filas if abs(f["bind"][0]) > LATERAL]

    def _informe(self, filas):
        return "\n".join(
            f"  {f['nombre']:18s} bind x {f['bind'][0]:+6.2f}  "
            f"carne x {f['centroide'][0]:+6.2f}  "
            f"distancia {f['distancia']:5.2f} m" for f in filas)

    # Los dos devuelven NOMBRES y no las filas enteras: assertEqual imprime
    # lo que le des, y una fila lleva tres arrays de numpy que tapan el
    # informe legible con un volcado de cifras.
    def _cruzan(self):
        return [f["nombre"] for f in self.laterales
                if f["bind"][0] * f["centroide"][0] <= 0]


@unittest.skipUnless(_hay(VANILLA), "sin el FIEND vanilla 7.0 extraido")
class TestVanillaEsLaReferencia(_Encaje):
    """Calibra la medida. Si esto falla, lo roto es `nmsskin.encaje`.

    El vanilla encaja sobre su propio esqueleto por definicion, asi que un
    numero grande aqui es un fallo de lectura -el orden de la matriz, el
    hueco de la paleta- y no del modelo.
    """

    CARPETA = VANILLA

    def test_los_huesos_tienen_su_carne_encima(self):
        distancias = sorted(f["distancia"] for f in self.filas)
        mediana = distancias[len(distancias) // 2]
        self.assertLessEqual(
            mediana, 0.15,
            f"el vanilla deberia encajar sobre si mismo y da {mediana:.2f} m "
            f"de mediana. Sospecha de `_matriz_bind` antes que del modelo.")

    def test_ningun_hueso_lateral_cruza_la_linea_media(self):
        self.assertTrue(self.laterales, "no se hallo ni un hueso lateral")
        self.assertEqual(self._cruzan(), [],
                         "el VANILLA cruza la linea media, o sea que la "
                         "medida esta mal:\n" + self._informe(self.laterales))


@unittest.skipUnless(_hay(CRYWOLF), "sin el cry wolf 7.x")
class TestCryWolf(_Encaje):
    """La referencia de "malla nuestra bien encajada"."""

    CARPETA = CRYWOLF

    def test_ninguna_pata_cruza_la_linea_media(self):
        self.assertEqual(self._cruzan(), [],
                         "\n" + self._informe(self.laterales))


@unittest.skipUnless(_hay(XENODOG), "sin el xenodog cosido")
class TestXenodog(_Encaje):
    """El que esta rojo hoy. Ver el docstring del modulo."""

    CARPETA = XENODOG

    def test_ninguna_pata_cruza_la_linea_media(self):
        cruzan = self._cruzan()
        self.assertEqual(
            cruzan, [],
            f"{len(cruzan)} de {len(self.laterales)} huesos laterales mueven "
            f"la carne del lado contrario:\n" + self._informe(self.laterales))


if __name__ == "__main__":
    unittest.main()
