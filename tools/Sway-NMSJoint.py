"""Dice que huesos del vanilla se MUEVEN, y cuanto, leyendo sus .ANIM.

    python tools/Sway-NMSJoint.py <.SCENE.MXML> <.ANIM.MXML> [...]

Existe por la PRUEBA05 del zombie. Estar en el SkinMatrixLayout dice que el
vanilla le pega piel a ese hueso; NO dice que el hueso tenga una sola clave de
animacion. Los seis `legbase_*` del ARTHROPOD estan en la paleta y estan
QUIETOS en los cuatro clips, y colgar de ellos el 52,2% del zombie lo metio al
juego rigido -sin estirarse, porque no se movia nada-.

COMO SE SABE SI UN HUESO TIENE CLAVES. El .ANIM trae `NodeData` con un
`RotIndex` por hueso y dos bloques de fotogramas. Si `RotIndex` cae por encima
del numero de rotaciones de `AnimFrameData`, el hueso se lee de
`StillFrameData` y no se mueve NUNCA.

Y EL NUMERO QUE DECIDE ES EL GIRO DE MUNDO, no el local: es el que multiplica
la palanca hasta nuestros vertices, que en un bipedo montado en una arana son
metros. Un hueso quieto NO esta congelado en el mundo -hereda a su padre-, asi
que su giro de mundo es el del padre. `legbase_*` da los mismos 4,0 grados que
`spine_C0_0_jnt`, o sea nada propio.

Y EL GIRO NO ES LO UNICO. El .ANIM trae tambien `Translations`, con el
mismo esquema de indice, y una traslacion de hueso NO se multiplica por la
palanca: mueve 1:1 todo lo que cuelgue de el. Por eso sale en su propia
tabla, con la ALTURA DE MUNDO del pivote por clip. Existe por el necromorfo
de la PRUEBA07: al CORRER se le despega el cuerpo del suelo, y un despegue
es traslacion, no giro. Con el 41,7% de nuestra malla colgando de las dos
patas traseras del FIEND, lo que suba ese pivote lo sube la malla entera.

Los .MXML se sacan con MBINCompiler, y los .ANIM del .pak:

    hgpaktool.exe -U -f "*creatures/arthropod/anims/*" -O ./anims NMSARC.AnimMBIN.pak
    MBINCompiler.exe anims/.../arthropodwalk.anim.mbin
"""

import json
import math
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

import numpy as np


def _campos(nodo):
    return {p.get("name"): p for p in nodo}


def leer_scene(ruta: Path) -> dict:
    """Nombre de hueso -> (padre, transform local), en orden de arbol."""
    huesos = {}

    def recorrer(nodo, padre):
        campos = _campos(nodo)
        if "Name" not in campos:
            return
        nombre = campos["Name"].get("value")
        tipo = campos.get("Type")
        if tipo is not None and tipo.get("value") == "JOINT":
            huesos[nombre] = (padre, {
                p.get("name"): float(p.get("value"))
                for p in campos["Transform"]})
            padre = nombre
        for hijo in campos.get("Children", ()):
            recorrer(hijo, padre)

    recorrer(ET.parse(ruta).getroot(), None)
    return huesos


def _quats(propiedad) -> np.ndarray:
    salida = []
    for q in propiedad:
        d = {x.get("name"): float(x.get("value"))
             for x in q if x.get("name") in ("X", "Y", "Z", "W")}
        salida.append([d["X"], d["Y"], d["Z"], d["W"]])
    return np.array(salida, dtype=np.float64).reshape(-1, 4)


def _vec3(propiedad) -> np.ndarray:
    salida = []
    for v in propiedad:
        d = {x.get("name"): float(x.get("value"))
             for x in v if x.get("name") in ("X", "Y", "Z")}
        salida.append([d["X"], d["Y"], d["Z"]])
    return np.array(salida, dtype=np.float64).reshape(-1, 3)


def _pista(arriba, fotogramas, campo, leer, indice):
    """Un canal del .ANIM por hueso y fotograma, mas si tiene clave.

    El esquema es el mismo para `Rotations` y `Translations`: el indice de
    `NodeData` cae primero en los fotogramas de `AnimFrameData` y, si se
    pasa, en el bloque unico de `StillFrameData`, que no se mueve nunca.
    """
    vivos = np.array([leer(_campos(f)[campo]) for f in fotogramas])
    quietos = leer(_campos(arriba["StillFrameData"])[campo])
    n = vivos.shape[1]

    pista, con_clave = {}, {}
    for nodo in arriba["NodeData"]:
        d = {p.get("name"): p.get("value") for p in nodo}
        i = int(d[indice])
        con_clave[d["Node"]] = i < n
        pista[d["Node"]] = (vivos[:, i, :] if i < n
                            else np.repeat(quietos[i - n][None, :],
                                           len(fotogramas), 0))
    return pista, con_clave


def leer_anim(ruta: Path):
    """(giros, traslaciones, nombre -> tiene clave de giro), por fotograma."""
    arriba = _campos(ET.parse(ruta).getroot())
    fotogramas = list(arriba["AnimFrameData"])
    giros, con_clave = _pista(arriba, fotogramas, "Rotations",
                              _quats, "RotIndex")
    trasl, _ = _pista(arriba, fotogramas, "Translations",
                      _vec3, "TransIndex")
    return giros, trasl, con_clave


def _multiplicar(a: np.ndarray, b: np.ndarray) -> np.ndarray:
    x1, y1, z1, w1 = a[..., 0], a[..., 1], a[..., 2], a[..., 3]
    x2, y2, z2, w2 = b[..., 0], b[..., 1], b[..., 2], b[..., 3]
    return np.stack([w1 * x2 + x1 * w2 + y1 * z2 - z1 * y2,
                     w1 * y2 - x1 * z2 + y1 * w2 + z1 * x2,
                     w1 * z2 + x1 * y2 - y1 * x2 + z1 * w2,
                     w1 * w2 - x1 * x2 - y1 * y2 - z1 * z2], axis=-1)


def _por_euler(rx, ry, rz) -> np.ndarray:
    """El transform del .SCENE viene en grados; aqui sale cuaternion."""
    q = np.array([0.0, 0.0, 0.0, 1.0])
    for eje, grados in enumerate((rx, ry, rz)):
        media = math.radians(grados) / 2.0
        v = [0.0, 0.0, 0.0, math.cos(media)]
        v[eje] = math.sin(media)
        q = _multiplicar(np.array(v), q)
    return q


def _rotar(q: np.ndarray, v: np.ndarray) -> np.ndarray:
    """v girado por q, por fotograma. q es (n,4) y v es (n,3) o (3,)."""
    u, w = q[..., :3], q[..., 3:4]
    v = np.broadcast_to(np.asarray(v, dtype=np.float64), u.shape)
    return (v + 2.0 * np.cross(u, np.cross(u, v) + w * v))


def pose_de_mundo(huesos: dict, giros: dict, trasl: dict, n: int) -> dict:
    """nombre -> (giro de mundo por fotograma, pivote de mundo por fotograma).

    La cadena se compone a mano: el pivote de un hueso es el de su padre mas
    su traslacion local YA GIRADA por el padre. La escala se ignora a
    proposito -los rigs de NMS la dejan en 1- y por eso no entra aqui.
    """
    cache = {}

    def mundo(nombre):
        if nombre in cache:
            return cache[nombre]
        padre, tr = huesos[nombre]
        q = giros.get(nombre)
        if q is None:  # el clip ni lo nombra: se queda en su bind
            q = np.repeat(
                _por_euler(tr["RotX"], tr["RotY"], tr["RotZ"])[None, :], n, 0)
        t = trasl.get(nombre)
        if t is None:
            t = np.repeat(np.array([[tr["TransX"], tr["TransY"],
                                     tr["TransZ"]]]), n, 0)
        if padre:
            q_p, p_p = mundo(padre)
            cache[nombre] = (_multiplicar(q_p, q), p_p + _rotar(q_p, t))
        else:
            cache[nombre] = (q, t)
        return cache[nombre]

    return {nombre: mundo(nombre) for nombre in huesos}


def giro_de_mundo(poses: dict) -> dict:
    """Grados que gira cada hueso EN EL MUNDO a lo largo del clip."""
    salida = {}
    for nombre, (q, _) in poses.items():
        # Mismo hemisferio, o q y -q -que son el mismo giro- salen al doble.
        q = q * np.sign(q[:, 3:4] + 1e-12)
        ref = q.mean(axis=0)
        ref /= np.linalg.norm(ref)
        apertura = np.arccos(np.clip(np.abs(q @ ref), 0.0, 1.0)).max()
        salida[nombre] = float(np.degrees(2 * apertura))
    return salida


def alto_de_mundo(poses: dict) -> dict:
    """nombre -> (altura media del pivote, cuanto sube y baja) en el clip.

    La altura media es lo que decide si un clip DESPEGA del suelo lo que
    cuelgue del hueso: una traslacion no se multiplica por la palanca, se
    suma tal cual a cada vertice. El recorrido dice si ademas rebota.
    """
    return {nombre: (float(p[:, 1].mean()),
                     float(p[:, 1].max() - p[:, 1].min()))
            for nombre, (_, p) in poses.items()}


def main(argv) -> int:
    if len(argv) < 3:
        print(__doc__)
        return 2

    volcado = None
    if "--json" in argv:
        i = argv.index("--json")
        volcado, argv = Path(argv[i + 1]), argv[:i] + argv[i + 2:]

    escena, clips = Path(argv[1]), [Path(a) for a in argv[2:]]
    huesos = leer_scene(escena)
    print(f"\n{escena.name}: {len(huesos)} huesos, {len(clips)} clips\n")

    mundo, alto, claves = {}, {}, {}
    for clip in clips:
        giros, trasl, con_clave = leer_anim(clip)
        poses = pose_de_mundo(huesos, giros, trasl,
                              len(next(iter(giros.values()))))
        mundo[clip.stem] = giro_de_mundo(poses)
        alto[clip.stem] = alto_de_mundo(poses)
        for nombre, tiene in con_clave.items():
            claves.setdefault(nombre, set()).add(tiene)

    print(f"{'hueso':24s} {'claves':>8s}"
          + "".join(f"{c[:11]:>12s}" for c in mundo))
    for nombre in huesos:
        estados = claves.get(nombre)
        if estados is None:
            etiqueta = "-"
        elif True not in estados:
            etiqueta = "QUIETO"
        else:
            etiqueta = "SI" if False not in estados else "a veces"
        print(f"{nombre:24s} {etiqueta:>8s}"
              + "".join(f"{mundo[c][nombre]:12.1f}" for c in mundo))

    print()
    print("ALTURA DE MUNDO del pivote, metros: media (recorrido).")
    print("Un clip que sube la media DESPEGA del suelo lo que cuelgue del")
    print("hueso, y eso no lo arregla ningun peso: es traslacion, no giro.")
    print()
    print(f"{'hueso':24s}" + "".join(f"{c[:15]:>16s}" for c in alto))
    for nombre in huesos:
        print(f"{nombre:24s}" + "".join(
            f"{alto[c][nombre][0]:9.2f} ({alto[c][nombre][1]:4.2f})"
            for c in alto))

    if volcado:
        # Lo que consume `Weight-NMSMesh.py` para elegir el AGARRE. Hasta la
        # PRUEBA07 el alfa salia de la PALANCA sola -lo lejos que le queda
        # el pivote a nuestra piel-, y la palanca NO SABE CUANTO GIRA EL
        # HUESO. Por eso la 07 apreto la cabeza del necromorfo, que gira
        # 2,9 grados al andar, y dejo intactas las dos patas traseras, que
        # giran 69,5 y 26,2. Lo que estira es palanca POR giro, y el giro
        # sale de aqui.
        volcado.parent.mkdir(parents=True, exist_ok=True)
        volcado.write_text(json.dumps(
            {n: {c: round(mundo[c][n], 2) for c in mundo} for n in huesos},
            indent=1, sort_keys=True), encoding="utf-8")
        print(f"\ngiros de mundo -> {volcado}")

    # Solo huesos: `NodeData` nombra tambien los nodos de malla -en el
    # ARTHROPOD, los veintitantos `_APod*`- y esos no reciben piel jamas.
    quietos = sorted(n for n, e in claves.items()
                     if True not in e and n in huesos)
    print(f"\nhuesos sin ni una clave en los {len(clips)} clips: {len(quietos)}")
    if quietos:
        print("  candidatos a `sin_claves` de MODELOS, en Weight-NMSMesh.py.")
        print("  Cruzalos con el SkinMatrixLayout: solo importan los de la paleta.")
        print("  " + ", ".join(f'"{n}"' for n in quietos))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
