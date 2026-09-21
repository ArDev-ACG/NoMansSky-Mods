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
  encaje    escala uniforme para que la distancia entre pisadas delanteras
            y traseras sea la del FIEND, los pies al suelo -y minima 0- y en
            Z las pisadas centradas sobre las cuatro puntas Leg4END.
  regiones  las MISMAS de Weight-NMSMesh.py, leidas en la caja de antes del
            giro, que es donde se midieron. Solo cambia el LADO: sale del
            signo de x en el marco final, donde el FIEND pone los L* en x
            negativa.
  pesos     uno por region y suavizado por las aristas, con las costuras de
            UV soldadas por posicion para que no se abran. El pie de cada
            pata va a su Leg4END, que el clip mantiene plantado.
  caras     los triangulos al reves -el 1,9%, por los que se veia el fondo-
            se dan la vuelta.
  bind      los JointBindings del FIEND vanilla tal cual: la malla ya esta
            en la pose de reposo de su esqueleto. DESPUES hay que pasar
            Patch-NMSGraft.py --bind fiendidle.anim.MXML#0: el reposo del
            FIEND no es la postura en que anda -en idle baja la cabeza 35
            grados-, y con el bind de idle nuestra malla sale en idle tal
            cual se modelo y los clips solo le suman lo que se separan de
            idle. Asi los pies quedan plantados.

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
#
# LA CABEZA VA CON EL PECHO, a NewBack1JNT, y no a NewHeadJNT. Visto el 20/09
# en `fiendroar`: la cabeza se partia en dos por la costura entre los dos
# huesos. Medido sobre los 27 clips, NewHeadJNT gira respecto a NewBack1JNT
# 35..75 grados en casi todos -35 dentro del mismo idle-, porque el FIEND
# tiene un cuello largo de cuatro huesos y nuestro bicho no tiene cuello: el
# craneo sale de los hombros y es rigido. Ninguna rampa reparte 75 grados en
# un craneo sin doblarlo como goma.
#
# Y LA CABEZA EMPIEZA POR ENCIMA DE LA LINEA DE LAS PATAS, w >= 0,40. Las
# garras delanteras asoman por delante hasta v < 0,16 y con la regla vieja
# -solo v- 119 vertices de garra, a ras de suelo, colgaban del pecho: en
# `fiendroar` la pata se levanta y la garra se quedaba, un estiron de 0,62 m.
REGIONES = (
    ("NewBack1JNT", lambda u, v, w: (v < 0.16) & (w >= 0.40)),
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

# La rampa del pie, en metros sobre el suelo: en el suelo todo es Leg4END y a
# 1,4 m -o sea por encima de la cadera- todo es la cadera. LARGA A PROPOSITO:
# Leg1 y Leg4END giran muy distinto y una mezcla lineal corta entre los dos
# aplasta la pata en el medio -el "envoltorio de caramelo"-. Medido el 20/09
# con el bind de idle: 0,15..0,55 abria la espinilla; 0..0,6 da p99,9 3,54,
# 0..1,4 da 3,44 y 0..1,8 vuelve a 3,61. El vanilla con su piel da 3,45.
PIE = (0.0, 1.4)

# La rampa de la cola, en la v de la caja de pie -cabeza 0, punta de cola 1-:
# la cola arranca en la grupa hacia v 0,55 y termina en 1.
COLA = (0.55, 1.0)


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
    # ESCALA Y ENCAJE POR LAS PISADAS. El pie cuelga de Leg4END (ver abajo),
    # y todo lo que nuestro pie este lejos de esa punta es palanca: medido el
    # 20/09 con escala 1 y las patas centradas en las caderas, nuestras
    # pisadas distaban 1,03 m de delante a detras y las del FIEND 1,24, y el
    # pie trasero -a 0,31 m de su punta- se hundia 0,15 m al andar. Asi que la
    # escala es la razon entre las dos distancias, y en Z se centran las
    # pisadas sobre las puntas.
    alto0 = v[:, 2] - v[:, 2].min()
    pisa = alto0 < 0.12
    delante = v[(region == 1) & pisa, 1].mean()
    detras = v[(region == 2) & pisa, 1].mean()
    punta_z = {n: bind_v[joints[n]][2] for n in (
        "LFirstLeg4END", "RFirstLeg4END", "LFourthLeg4END", "RFourthLeg4END")}
    delante_v = (punta_z["LFirstLeg4END"] + punta_z["RFirstLeg4END"]) / 2
    detras_v = (punta_z["LFourthLeg4END"] + punta_z["RFourthLeg4END"]) / 2
    escala = (detras_v - delante_v) / (detras - delante)
    dy = -v[:, 2].min()
    dz = (delante_v + detras_v) / 2 - escala * (delante + detras) / 2

    def mover(p):
        p = np.atleast_2d(p)
        return np.stack([-escala * p[:, 0], escala * (p[:, 2] + dy),
                         escala * p[:, 1] + dz], axis=1)

    nuevo = mover(v)

    # El lado, en el marco final.
    hueso = np.array([
        (("L" if x < 0 else "R") + REGIONES[k][0] + "JNT")
        if "Leg" in REGIONES[k][0] else REGIONES[k][0]
        for k, x in zip(region, nuevo[:, 0])])

    # EL PIE VA AL Leg4END, la punta de la pata del FIEND. Visto en partida el
    # 20/09 con la pata entera colgada del Leg1: el vanilla deja sus cuatro
    # puntas en y -0,02 en walk, idle y attack, y las nuestras subian a
    # 0,15..0,66 m, porque la cadera gira y la pata rigida sube como un palo.
    # La punta es la que el clip mantiene plantada, asi que el pie la sigue y
    # la cadera se queda con lo de arriba; en medio, rampa suave.
    pie = np.zeros(len(v))
    en_pata = np.char.find(hueso, "Leg1JNT") >= 0
    t = np.clip((nuevo[:, 1] - PIE[0]) / (PIE[1] - PIE[0]), 0.0, 1.0)
    pie[en_pata] = 1.0 - (t * t * (3.0 - 2.0 * t))[en_pata]
    punta = np.array([h.replace("Leg1JNT", "Leg4END") for h in hueso])

    # LA COLA EN RAMPA, de RootJNT en la grupa a NewTail1JNT en la punta, por
    # el mismo motivo que el pie: NewTail1JNT gira respecto a RootJNT 25..56
    # grados segun el clip, y con la costura corta del suavizado la cola salia
    # disparada como una lanza en `fiendroar`. Repartido por todo el largo, se
    # dobla como un tubo. Reusa `pie` y `punta`: la cola "base" es hueso y la
    # "punta" NewTail1JNT.
    en_cola = hueso == "NewTail1JNT"
    largo = np.clip((vv - COLA[0]) / (COLA[1] - COLA[0]), 0.0, 1.0)
    pie[en_cola] = (largo * largo * (3.0 - 2.0 * largo))[en_cola]
    hueso[en_cola] = "RootJNT"
    punta[en_cola] = "NewTail1JNT"

    palet = nmsskin.layout_paleta(geo)
    for nombre in sorted(set(punta[en_pata])):
        if joints[nombre] not in palet:
            palet.append(joints[nombre])
    por_indice = {j: n for n, j in joints.items()}
    nombres_pal = [por_indice[j] for j in palet]
    faltan = set(hueso) - set(nombres_pal)
    assert not faltan, f"regiones sin hueco en la paleta: {faltan}"

    # Triangulos al reves: el juego no dibuja su cara de atras y por ellos se
    # ve el fondo -la cara y una placa del lomo, en partida-. El vanilla no
    # tiene ninguno; aqui el decimador dejo el 1,9%. Se decide contra la
    # normal de vertice, que si esta bien -0,996 de mediana contra la de la
    # geometria, el vanilla 0,999-.
    tri = np.frombuffer(s.indices, dtype="<u2").astype(np.int64).reshape(-1, 3)
    n_v = _normales(np.frombuffer(s.vertices, dtype=np.uint8).reshape(
        -1, 16)[:, 12:16].copy().view("<u4").ravel())
    cara = np.cross(v[tri[:, 1]] - v[tri[:, 0]], v[tri[:, 2]] - v[tri[:, 0]])
    al_reves = (cara * n_v[tri].sum(axis=1)).sum(axis=1) < 0
    tri[al_reves] = tri[al_reves][:, [0, 2, 1]]
    s.indices = tri.astype("<u2").tobytes()

    # Pesos: uno por region, promediados por aristas entre vertices soldados.
    _, soldado = np.unique(np.round(v, 4), axis=0, return_inverse=True)
    soldado = soldado.ravel()
    ns = int(soldado.max()) + 1
    adj = _vecinas(tri, soldado, ns)
    grado = np.maximum(np.asarray(adj.sum(axis=1)).ravel(), 1)
    P = np.zeros((ns, len(nombres_pal)))
    P[soldado, [nombres_pal.index(h) for h in hueso]] = 1.0 - pie
    P[soldado, [nombres_pal.index(h) for h in punta]] += pie
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
    # LA V DE LA UV, DE ARRIBA ABAJO. El juego muestrea la textura con el
    # origen arriba y esta malla trae la V de Blender, con el origen abajo.
    # Con una textura normal eso solo la voltearia; con la de este asset -un
    # atlas automatico de cientos de islas- cada triangulo cae en una isla
    # ajena, y eso eran las "esquirlas" de partida. Visto el 20/09 en un
    # render con la textura: con la V tal cual sale identico al .glb, y con
    # la V invertida sale el cristal roto de las capturas.
    pos[:, 5] = 1.0 - pos[:, 5]
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
    capa = r.find("Property[@name='SkinMatrixLayout']")
    for hijo in list(capa):
        capa.remove(hijo)
    for i, j in enumerate(palet):
        ET.SubElement(capa, "Property", {"name": "SkinMatrixLayout",
                                          "value": str(j), "_index": str(i)})
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
        # La paleta crece con los cuatro Leg4END, y el rango del nodo tiene
        # que crecer con ella: si no, Check-NMSGraft avisa de indices fuera de
        # rango, y fuera de rango el juego cierra sin avisar.
        if nombre == "LASTSKINMAT":
            a.find("Property[@name='Value']").set("value", str(len(palet)))
        if nombre[:7] in ("AABBMIN", "AABBMAX") and len(nombre) == 8:
            valor = (lo if nombre[4:7] == "MIN" else hi)["XYZ".index(nombre[7])]
            a.find("Property[@name='Value']").set("value", f"{valor:.6f}")
    arbol.write(escena, encoding="utf-8", xml_declaration=True)

    cuenta = {h: int((hueso == h).sum()) for h in nombres_pal}
    print(f"caja {caja.round(3)} -> {(hi - lo).round(3)}, escala {escala:.3f}, "
          f"z {dz:+.3f}, {int(al_reves.sum())} caras dadas la vuelta")
    print("vertices por region:", cuenta)
    return 0


if __name__ == "__main__":
    sys.exit(main(Path(sys.argv[1])))
