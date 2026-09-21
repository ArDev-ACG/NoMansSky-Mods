"""Acuesta un .GEOMETRY que salio DE PIE, lo encaja en el esqueleto y lo repesa.

    python tools/Reorient-NMSGeometry.py work/models/xenodogmesh_anim

Existe por el 2026-09-20: el xenodog salio en partida hecho una estatua
vertical -cabeza abajo, cola arriba, patas al aire- y el arreglo del espejo
de la misma tarde no cambio NADA en pantalla. Dos causas, y la segunda es
consecuencia de la primera:

1. LA MALLA ESTA DE PIE. `Export-NMSMesh.py` gira en X con
   `transform_apply`, y en `--background` ese operador NO HACE NADA: ni el
   primer giro ni el segundo. El cry wolf y los demas salen bien porque sus
   .blend ya venian en el marco de NMS; el xenodog entra por el .glb de
   Decimate-NMSMesh.py, en el marco de Blender -Z arriba-, y el giro de -90
   que lo acostaba se quedo en el aire. El largo del bicho, de cabeza a
   cola, acabo en la Y de NMS, que es ARRIBA, y `alto=2.850` escalo ese
   largo.

2. LAS PATAS NO PESAN. Con la malla de pie cada hueso quedaba a metro y
   medio de su carne, y el optimizador de Weight-NMSMesh.py -`objetivo`
   sobre la tension- hizo lo unico que podia: bajarles el peso. Medido en el
   .GEOMETRY entregado: las patas pesan 0,06..0,17 como mucho, la cabeza
   0,35 y la punta de la cola 0,02. El resto es RootJNT y NewBack1JNT, o sea
   un solido rigido. Por eso el espejo daba igual.

NADA DE ESTO LO VEIA `Pose-NMSMesh.py`: deforma los vertices de
`pesos.json` y mide tension entre vecinos, y un bloque rigido no se estira.
Lo que lo destapa es deformar el .GEOMETRY ENTREGADO con los clips y
mirarlo en un render.

LO QUE HACE, sobre el par .GEOMETRY(.DATA).MXML ya cosido y repackeado:

  giro      (x, y, z) -> (-x, z, y). Es el Rx(-90) seguido del Ry(180) que
            Export-NMSMesh.py declara y no aplica. Determinante +1: no es
            espejo y el sentido de los triangulos se conserva. La cabeza,
            que estaba en y 0, cae en -Z, donde el FIEND lleva NewHeadJNT.
  encaje    los pies al suelo -y minima 0- y en Z el centro de las patas
            sobre el centro de las cuatro caderas del FIEND.
  regiones  las MISMAS de Weight-NMSMesh.py, leidas en la caja de antes del
            giro, que es donde se midieron. Solo cambia el LADO: sale del
            signo de x en el marco final, donde el FIEND pone los L* en x
            negativa.
  pesos     uno por region y suavizado por las aristas, con las costuras de
            UV soldadas por posicion para que no se abran.
  bind      los JointBindings del FIEND vanilla tal cual: la malla ya esta
            en la pose de reposo de su esqueleto.

No compila: deja los .MXML y el que llama compila. Aborta si la malla ya
esta acostada, para que correrlo dos veces no la tumbe del otro lado.
"""

import sys
import xml.etree.ElementTree as ET
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))

import nmsgeom  # noqa: E402
import nmsskin  # noqa: E402

RAIZ = Path(__file__).resolve().parent.parent
VANILLA = (RAIZ / "work" / "models" / "vanilla_7.0_fiend" / "models"
           / "planets" / "creatures" / "spiderrig")

# Las regiones del xenodog en Weight-NMSMesh.py, en la caja normalizada de la
# malla DE PIE: u = x, v = y cabeza 0 -> cola 1, w = z patas 0 -> lomo 1.
# Gana la primera que case. El lado de las patas lo pone el signo de x final.
#
# LA COLA ENTERA VA A NewTail1JNT, y no repartida en Tail1/3/5 como en
# Weight-NMSMesh.py. Nuestra cola sube en arco por encima del lomo y la del
# FIEND sale recta hacia atras, asi que Tail3 y Tail5 quedan lejos de su
# carne y cada uno tira su trozo hacia un lado: medido el 20/09, la cola
# repartida se rompe en tramos y da p99,9 de 7,68 en la razon de aristas;
# entera en Tail1 da 3,32 -el vanilla con su piel, 3,45- y sigue moviendose
# desde la base. Colgada de RootJNT da 3,25, pero va muerta.
REGIONES = (
    ("NewHeadJNT",  lambda u, v, w: v < 0.16),
    ("FirstLeg1",   lambda u, v, w: (v < 0.46) & (w < 0.40)),
    ("FourthLeg1",  lambda u, v, w: (w < 0.40) & (v <= 0.76)),
    ("NewTail1JNT", lambda u, v, w: (v > 0.74) | ((w > 0.82) & (v > 0.55))),
    ("NewBack1JNT", lambda u, v, w: v < 0.46),
    ("RootJNT",     lambda u, v, w: np.ones_like(u, dtype=bool)),
)

# Pasadas de promedio por aristas. La malla viene decimada a ~2 cm de arista,
# asi que 12 pasadas funden unos 15 cm a cada lado de cada frontera: bastante
# para que la ingle no se rasgue y poco para que la pata no arrastre el
# vientre.
PASADAS = 12
RANURAS = 4


def _normales(u32):
    """sem11 -> normal unitaria. Los 20 bits bajos, octaedral centrada en 512."""
    x = ((u32 & 1023).astype(np.float64) - 512) / 511
    y = (((u32 >> 10) & 1023).astype(np.float64) - 512) / 511
    z = 1 - np.abs(x) - np.abs(y)
    t = np.clip(-z, 0, None)
    x = x + np.where(x >= 0, -t, t)
    y = y + np.where(y >= 0, -t, t)
    n = np.stack([x, y, z], 1)
    return n / np.linalg.norm(n, axis=1, keepdims=True)


def _sem11(n, viejo):
    """Normal -> los 20 bits bajos. Los 12 altos -el tangente, sin descifrar,
    ver Repack-NMSVertex.py- se quedan como venian."""
    n = n / np.abs(n).sum(axis=1, keepdims=True)
    x, y, z = n[:, 0].copy(), n[:, 1].copy(), n[:, 2]
    abajo = z < 0
    sx = np.where(n[:, 0] >= 0, 1.0, -1.0)
    sy = np.where(n[:, 1] >= 0, 1.0, -1.0)
    x[abajo] = (1 - np.abs(n[abajo, 1])) * sx[abajo]
    y[abajo] = (1 - np.abs(n[abajo, 0])) * sy[abajo]
    fx = np.clip(np.round(512 + x * 511), 0, 1023).astype(np.uint32)
    fy = np.clip(np.round(512 + y * 511), 0, 1023).astype(np.uint32)
    return fx | (fy << 10) | (viejo & np.uint32(0xFFF00000))


def _vecinas(tri, soldado, n):
    """Adyacencia por aristas entre vertices SOLDADOS, como matriz dispersa."""
    from scipy.sparse import coo_matrix
    t = soldado[tri]
    a = np.concatenate([t[:, 0], t[:, 1], t[:, 2], t[:, 1], t[:, 2], t[:, 0]])
    b = np.concatenate([t[:, 1], t[:, 2], t[:, 0], t[:, 0], t[:, 1], t[:, 2]])
    m = coo_matrix((np.ones(len(a)), (a, b)), shape=(n, n)).tocsr()
    m.data[:] = 1.0
    return m


def _xyz(nodo):
    return [float(nodo.find(f"Property[@name='{e}']").get("value"))
            for e in "XYZ"]


def _poner_xyz(nodo, p):
    for eje, valor in zip("XYZ", p):
        nodo.find(f"Property[@name='{eje}']").set("value", f"{valor:.6f}")


def main(carpeta: Path) -> int:
    geo = carpeta / "FIEND.GEOMETRY.MXML"
    dat = carpeta / "FIEND.GEOMETRY.DATA.MXML"
    escena = carpeta / "FIEND.SCENE.MXML"
    s = nmsgeom.leer_streams(dat)
    if nmsgeom.layout(geo)["stride"] != 16:
        raise SystemExit("stride distinto de 16: pasar antes Repack-NMSVertex.py")

    pos = np.frombuffer(s.posiciones, dtype="<f2").reshape(-1, 8).astype(np.float64)
    v = pos[:, :3].copy()
    caja = v.max(axis=0) - v.min(axis=0)
    if caja[1] <= caja[2]:
        raise SystemExit(f"caja {caja.round(3)}: ya esta acostada, no se gira")

    # Regiones, en la caja DE PIE, donde se midieron.
    u, vv, w = ((v - v.min(axis=0)) / caja).T
    region = np.full(len(v), -1)
    for k, (_, cabe) in enumerate(REGIONES):
        region[(region < 0) & cabe(u, vv, w)] = k

    # El giro y el encaje, como UNA cuenta que sirve tambien para el casco.
    joints = nmsskin.leer_joints(VANILLA / "fiend.scene.MXML")
    bind_v = nmsskin.bind_mundo(VANILLA / "fiend.geometry.MXML")
    caderas = float(np.mean([bind_v[joints[n]][2] for n in (
        "LFirstLeg1JNT", "RFirstLeg1JNT", "LFourthLeg1JNT", "RFourthLeg1JNT")]))
    patas = np.isin(region, [1, 2])
    dy = -v[:, 2].min()
    dz = caderas - (v[patas, 1].min() + v[patas, 1].max()) / 2

    def mover(p):
        p = np.atleast_2d(p)
        return np.stack([-p[:, 0], p[:, 2] + dy, p[:, 1] + dz], axis=1)

    nuevo = mover(v)

    # El lado, en el marco final.
    hueso = np.array([
        (("L" if x < 0 else "R") + REGIONES[k][0] + "JNT")
        if "Leg" in REGIONES[k][0] else REGIONES[k][0]
        for k, x in zip(region, nuevo[:, 0])])

    palet = nmsskin.layout_paleta(geo)
    por_indice = {j: n for n, j in joints.items()}
    nombres_pal = [por_indice[j] for j in palet]
    faltan = set(hueso) - set(nombres_pal)
    assert not faltan, f"regiones sin hueco en la paleta: {faltan}"

    # Pesos: uno por region, promediados por aristas entre vertices soldados.
    _, soldado = np.unique(np.round(v, 4), axis=0, return_inverse=True)
    soldado = soldado.ravel()
    ns = int(soldado.max()) + 1
    tri = np.frombuffer(s.indices, dtype="<u2").astype(np.int64).reshape(-1, 3)
    adj = _vecinas(tri, soldado, ns)
    grado = np.maximum(np.asarray(adj.sum(axis=1)).ravel(), 1)
    P = np.zeros((ns, len(nombres_pal)))
    P[soldado, [nombres_pal.index(h) for h in hueso]] = 1.0
    for _ in range(PASADAS):
        P = 0.5 * P + 0.5 * (adj @ P) / grado[:, None]
    P = P[soldado]
    orden = np.argsort(-P, axis=1)[:, :RANURAS]
    peso = np.take_along_axis(P, orden, axis=1)
    peso[peso < 0.01] = 0.0
    peso /= peso.sum(axis=1, keepdims=True)
    orden[peso == 0] = 0

    # Los streams.
    vert = bytearray(s.vertices)
    V = np.frombuffer(vert, dtype=np.uint8).reshape(-1, 16)
    V[:, 0:4] = orden.astype(np.uint8)
    V[:, 4:12] = peso.astype("<f2").view(np.uint8).reshape(-1, 8)
    viejo = V[:, 12:16].copy().view("<u4").ravel()
    n = _normales(viejo)
    n = np.stack([-n[:, 0], n[:, 2], n[:, 1]], axis=1)
    V[:, 12:16] = _sem11(n, viejo).astype("<u4").view(np.uint8).reshape(-1, 4)
    pos[:, :3] = nuevo
    s.vertices = bytes(vert)
    s.posiciones = pos.astype("<f2").tobytes()
    nmsgeom.escribir_streams(dat, s)

    # El .GEOMETRY: cajas, casco, y el bind del vanilla.
    lo, hi = nuevo.min(axis=0), nuevo.max(axis=0)
    arbol = ET.parse(geo)
    r = arbol.getroot()
    _poner_xyz(r.find("Property[@name='MeshAABBMin']")[0], lo)
    _poner_xyz(r.find("Property[@name='MeshAABBMax']")[0], hi)
    for p in r.find("Property[@name='BoundHullVerts']"):
        _poner_xyz(p, mover(_xyz(p))[0])
    suyo = ET.parse(VANILLA / "fiend.geometry.MXML").getroot()
    mio_jb = r.find("Property[@name='JointBindings']")
    suyo_jb = suyo.find("Property[@name='JointBindings']")
    assert len(mio_jb) == len(suyo_jb), (len(mio_jb), len(suyo_jb))
    for a, b in zip(mio_jb, suyo_jb):
        for x, y in zip(a.find("Property[@name='InvBindMatrix']"),
                        b.find("Property[@name='InvBindMatrix']")):
            x.set("value", y.get("value"))
    arbol.write(geo, encoding="utf-8", xml_declaration=True)

    # El .SCENE lleva la misma caja en los atributos del nodo de malla.
    arbol = ET.parse(escena)
    for a in arbol.getroot().iter("Property"):
        if a.get("value") != "TkSceneNodeAttributeData":
            continue
        nombre = a.find("Property[@name='Name']").get("value")
        if nombre[:7] in ("AABBMIN", "AABBMAX") and len(nombre) == 8:
            valor = (lo if nombre[4:7] == "MIN" else hi)["XYZ".index(nombre[7])]
            a.find("Property[@name='Value']").set("value", f"{valor:.6f}")
    arbol.write(escena, encoding="utf-8", xml_declaration=True)

    cuenta = {h: int((hueso == h).sum()) for h in nombres_pal}
    print(f"caja {caja.round(3)} -> {(hi - lo).round(3)}, z {dz:+.3f}")
    print("vertices por region:", cuenta)
    return 0


if __name__ == "__main__":
    sys.exit(main(Path(sys.argv[1])))
