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

# Cuanto se le permite a un vertice exportado separarse de su origen. Los dos
# limites estan MEDIDOS sobre la malla real, no elegidos a ojo:
#
#   por abajo   el vertice peor casado cae a 0,001355 -1,39 ULP de half-,
#               asi que por debajo de eso se rechazarian casados buenos.
#   por arriba  el SEGUNDO vecino mas cercano de toda la malla esta a
#               0,005036, asi que por encima de eso se podria coger el
#               vertice equivocado.
#
# 0,003 queda a 2,2x del peor casado bueno y a 1,7x por debajo del primer
# candidato falso. Si esto salta, mira las cajas antes de subir el numero.
TOLERANCIA = 0.003

# Vertices por bloque al buscar vecinos. 512 x 4820 x 3 float32 son 30 MB,
# que es lo que se evita al no hacer los 11357 de una vez.
BLOQUE = 512


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


def posiciones(streams) -> np.ndarray:
    """Las posiciones del buffer. Stride 16: 4 half de posicion y 4 de UV."""
    crudo = np.frombuffer(streams.posiciones, dtype="<f2").reshape(-1, 8)
    return crudo[:, :3].astype(np.float32)


def casar(destino: np.ndarray, pesos: list,
          tolerancia: float = TOLERANCIA) -> np.ndarray:
    """Para cada vertice exportado, en que entrada de pesos nacio.

    Por VECINO MAS CERCANO, no por posicion exacta. Casar por clave exacta
    NO funciona y se comprobo contra la malla real: falla en 10014 de los
    11357. El buffer guarda las posiciones en half y pesos.json las trae en
    float, asi que el mismo vertice sale movido hasta 1,4 ULP -por ejemplo
    1.829884 en pesos.json contra 1.8291016 en el buffer-.

    A cambio hay que demostrar que el vecino mas cercano es inequivoco, y lo
    es: ver TOLERANCIA.
    """
    origen = np.array([e[:3] for e in pesos], dtype=np.float32)
    salida = np.empty(len(destino), dtype=np.int32)
    peor = 0.0
    for a in range(0, len(destino), BLOQUE):
        trozo = np.asarray(destino[a:a + BLOQUE], dtype=np.float32)
        d = np.linalg.norm(trozo[:, None, :] - origen[None, :, :], axis=2)
        salida[a:a + len(trozo)] = d.argmin(axis=1)
        peor = max(peor, float(d.min(axis=1).max()))

    if peor > tolerancia:
        raise ValueError(
            f"el vertice peor casado de los {len(destino)} exportados cae a "
            f"{peor:.6f} de su vecino mas cercano, y la tolerancia es "
            f"{tolerancia}.\n"
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
