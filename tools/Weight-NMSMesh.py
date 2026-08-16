"""Pesa nuestra malla contra el esqueleto vanilla, sin tocar el interfaz.

    blender.exe --background --python tools/Weight-NMSMesh.py

Deja dos cosas, y las dos se versionan: el .blend y
work/models/scuttlermesh/pesos.json, que es lo que consume el splice.

SE PESA CONTRA EL HUESO MAS CERCANO, NO CONTRA LA SUPERFICIE DEL VANILLA.

La primera version usaba el Data Transfer de Blender con POLYINTERP_NEAREST,
o sea que cada vertice nuestro copiaba los pesos del punto mas cercano de la
PIEL del bicho vanilla. Eso se probo en partida el 2026-08-15 y salio mal:

    RFirstLeg3JNT     2084 vertices   43.2%   caja 1.32 / 1.54 / 2.65
    LFirstLeg3JNT     1861 vertices   38.6%   caja 1.32 / 1.50 / 2.64
    RootJNT             17 vertices    0.4%

...con la malla entera midiendo 2.64 / 1.85 / 2.77. O sea que la PUNTA de
cada pata delantera era dueña de medio bicho, y el cuerpo colgaba de ellas.
Al caminar, las patas se llevaban el torso: se veian patas de mas -que era
el cuerpo estirado- y laminas planas entre lo que se iba y lo que se
quedaba. La animacion parecia normal porque el esqueleto SI se movia bien.

La causa es que el FreighterFiend es una araña de patas largas y cuerpo
pequeño, y el nuestro es compacto: al encajar las cajas envolventes, las
patas delanteras del vanilla barren todo el volumen donde esta nuestro
cuerpo, asi que casi cada vertice nuestro encuentra una pata como superficie
mas proxima. Por bien que se alinee, la superficie del vanilla miente.

La distancia al SEGMENTO de cada hueso no depende de que los dos bichos
tengan la misma forma, que es justo lo que hacia falta.

Otras dos cosas que costaron una sesion cada una y siguen aplicando:

  1. NMSDK IMPORTA pesos pero NO los EXPORTA: escribe JointBindings,
     MeshBaseSkinMat y SkinMatrixLayout vacios. El muro es solo de salida.
  2. El importador exige que la carpeta repita la ruta interna de la
     escena (import_scene.py:220, base_path). Por eso el vanilla esta
     extraido en work/models/vanilla_freighterfiend/models/planets/...

Y el giro de 180 en Z no se decide contando grupos con vertices -eso da
GIRO_Z 0, que pone nuestro craneo mirando hacia atras-. Se decide por
donde cae la cabeza: la del vanilla esta en +Y.
"""

import json
import os
import math
from pathlib import Path

import bpy
import numpy as np
from mathutils import Matrix

RAIZ = Path(os.path.expanduser(r"~\NMS_MOD_ZOMBIES"))
BLEND = RAIZ / "BLENDER" / "proyectos" / "scuttler.blend"
VANILLA = (RAIZ / "work" / "models" / "vanilla_freighterfiend" / "models" /
           "planets" / "creatures" / "spiderrig" / "freighterfiend.scene.mbin")
SALIDA = RAIZ / "work" / "models" / "scuttlermesh" / "pesos.json"

NUESTRA = "polySurface6"
GIRO_Z = 180

# Cuando el segundo hueso mas cercano queda a menos de esto veces el
# primero, el vertice reparte entre los dos. Suaviza las costuras sin
# pasar de 2 influencias, que es lo que cabe comodo en el buffer.
MEZCLA = 1.25

# Lo que NO puede pasar, y que la version anterior no miraba.
#
#   TOPE_REPARTO   que un solo hueso se quede con media malla. El fallo del
#                  15/08 daba 43.2%; pesando por hueso el mayor es 18.9%.
#   MINIMO_TRONCO  que el cuerpo cuelgue de la COLUMNA. El 15/08 colgaba de
#                  las puntas de las patas y RootJNT tenia 17 vertices.
#   TOPE_PUNTA     que ninguna punta de miembro se lleve un trozo grande.
#                  RFirstLeg3JNT tenia el 43.2%.
#
# Se probaron y se descartaron dos medidas que NO separan lo bueno de lo
# malo: el tamaño de la caja que ocupa cada hueso -la columna da 0.86 del
# bicho y eso es anatomia normal- y la distancia del vertice a su hueso
# -sale 0.89 de media porque nuestro bicho es gordo y el esqueleto de la
# araña es fino, y el fallo malo tambien daba distancias grandes-. Lo que
# de verdad distingue es DE QUE cuelga el cuerpo.
TOPE_REPARTO = 0.35
MINIMO_TRONCO = 0.30
TOPE_PUNTA = 0.10
PUNTAS = ("Leg3", "Leg4", "END")
CABEZA = ("Head", "Jaw", "Skull")
PIES = ("Leg4END", "Leg3END")


def caja_mundo(ob):
    co = [ob.matrix_world @ v.co for v in ob.data.vertices]
    lo = np.array([min(c[i] for c in co) for i in range(3)])
    hi = np.array([max(c[i] for c in co) for i in range(3)])
    return lo, hi


def dist_a_segmento(p, a, b):
    """Distancia de cada punto p (n,3) al segmento a->b."""
    ab = b - a
    largo = float(ab @ ab)
    if largo < 1e-12:
        return np.linalg.norm(p - a, axis=1)
    t = np.clip(((p - a) @ ab) / largo, 0.0, 1.0)[:, None]
    return np.linalg.norm(p - (a + t * ab), axis=1)


bpy.ops.wm.open_mainfile(filepath=str(BLEND))
nuestra = bpy.data.objects[NUESTRA]

bpy.ops.nmsdk.import_scene(path=str(VANILLA), clear_scene=False,
                           import_bones=True, import_collisions=False,
                           import_recursively=False)

vanilla = next(o for o in bpy.data.objects
               if o.type == "MESH" and o.vertex_groups and o is not nuestra)
armature = next(o for o in bpy.data.objects if o.type == "ARMATURE")
print(f"vanilla {vanilla.name}: {len(vanilla.data.vertices)} vertices, "
      f"{len(armature.data.bones)} huesos")

# 1. La transformacion que lleva el espacio del vanilla al nuestro. Se
#    calcula con la MALLA del vanilla y despues se aplica a los HUESOS, que
#    es lo unico que se usa para pesar.
giro = (Matrix.Rotation(math.radians(GIRO_Z), 4, "Z")
        @ Matrix.Rotation(math.radians(90), 4, "X"))

vv = np.array([list(giro @ (vanilla.matrix_world @ v.co))
               for v in vanilla.data.vertices])
lo_n, hi_n = caja_mundo(nuestra)
lo_v, hi_v = vv.min(axis=0), vv.max(axis=0)

# La escala sale de la ALTURA, no del eje mas apretado. Los dos bichos
# ocupan la misma plaza en el juego y de hecho ya miden casi lo mismo de
# alto -1.851 el nuestro contra 1.850 el vanilla-; lo que descuadra es el
# fondo, porque el vanilla arrastra una cola larga. Escalar por min() de
# las tres razones daba 0.847 y ENCOGIA el esqueleto: la distancia media de
# un vertice a su hueso se iba a 0.858 sobre una diagonal de 4.25, o sea que
# el rig se quedaba fuera de nuestra piel.
escala = float((hi_n[1] - lo_n[1]) / (hi_v[1] - lo_v[1]))

# Y se apoyan los PIES en el suelo, no los centros de las cajas: los dos
# bichos andan por el suelo, y la cola del vanilla desplaza su centro.
desplaza = np.array([
    (lo_n[0] + hi_n[0]) / 2 - escala * (lo_v[0] + hi_v[0]) / 2,
    lo_n[1] - escala * lo_v[1],
    (lo_n[2] + hi_n[2]) / 2 - escala * (lo_v[2] + hi_v[2]) / 2,
])

a_local = np.array(nuestra.matrix_world.inverted().to_4x4())


def al_espacio_nuestro(punto):
    p = np.array(list(giro @ (armature.matrix_world @ punto)))
    p = escala * p + desplaza
    return (a_local @ np.append(p, 1.0))[:3]


huesos = [(h.name, al_espacio_nuestro(h.head_local),
           al_espacio_nuestro(h.tail_local)) for h in armature.data.bones]
print(f"escala {escala:.4f}, {len(huesos)} huesos llevados a nuestro espacio")

# 2. Cada vertice, al hueso mas cercano. Nada de superficies.
puntos = np.array([list(v.co) for v in nuestra.data.vertices],
                  dtype=np.float64)
distancias = np.stack([dist_a_segmento(puntos, a, b) for _, a, b in huesos],
                      axis=1)
orden = np.argsort(distancias, axis=1)[:, :2]
d1 = distancias[np.arange(len(puntos)), orden[:, 0]]
d2 = distancias[np.arange(len(puntos)), orden[:, 1]]

salida = []
for i in range(len(puntos)):
    a, b = huesos[orden[i, 0]][0], huesos[orden[i, 1]][0]
    if d2[i] < d1[i] * MEZCLA and d1[i] + d2[i] > 1e-9:
        w = d2[i] / (d1[i] + d2[i])
        pares = [(a, round(float(w), 6)), (b, round(float(1 - w), 6))]
        pares.sort(key=lambda t: -t[1])
    else:
        pares = [(a, 1.0)]
    co = nuestra.data.vertices[i].co
    salida.append([round(co.x, 6), round(co.y, 6), round(co.z, 6),
                   [list(t) for t in pares]])

# 3. Dejar los grupos puestos en el .blend, para poder mirarlo a mano.
for g in list(nuestra.vertex_groups):
    nuestra.vertex_groups.remove(g)
grupos = {}
for i, e in enumerate(salida):
    for nombre, w in e[3]:
        if nombre not in grupos:
            grupos[nombre] = nuestra.vertex_groups.new(name=nombre)
        grupos[nombre].add([i], w, "REPLACE")

# --- lo que puede fallar, y falla aqui y no en el juego ---
dominante = [max(e[3], key=lambda t: t[1])[0] for e in salida]
reparto = {}
for g in dominante:
    reparto[g] = reparto.get(g, 0) + 1

tam = puntos.max(axis=0) - puntos.min(axis=0)
asignaciones = sum(len(e[3]) for e in salida)
print(f"\nvertices con peso: {len(salida)} de {len(nuestra.data.vertices)}")
print(f"asignaciones: {asignaciones}  "
      f"({asignaciones / len(salida):.2f} por vertice)")
print(f"huesos con peso: {len(set(g for e in salida for g, _ in e[3]))}")
print(f"la malla mide {tam[0]:.2f} / {tam[1]:.2f} / {tam[2]:.2f}\n")
print(f"{'hueso':22} {'vert':>5} {'%':>6}   caja")
for g, n in sorted(reparto.items(), key=lambda t: -t[1])[:12]:
    c = puntos[np.array(dominante) == g]
    d = c.max(axis=0) - c.min(axis=0)
    print(f"{g:22} {n:5} {n / len(salida) * 100:5.1f}%   "
          f"{d[0]:.2f} / {d[1]:.2f} / {d[2]:.2f}")

# Informativo, no assert: se midio y NO sirve para decidir. Ver la nota de
# arriba. Se imprime porque un salto grande entre corridas si querria decir
# que la alineacion se ha movido.
segmento = {n: (a, b) for n, a, b in huesos}
lejos = np.array([dist_a_segmento(puntos[i:i + 1], *segmento[dominante[i]])[0]
                  for i in range(len(puntos))])
print(f"\ndistancia de cada vertice a SU hueso: media {lejos.mean():.3f}, "
      f"maxima {lejos.max():.3f}, diagonal del bicho "
      f"{float(np.linalg.norm(tam)):.2f}")

assert len(salida) == 4820, len(salida)
assert all(e[3] for e in salida), "hay vertices sin peso"
assert max(len(e[3]) for e in salida) <= 2, "algun vertice cuelga de 3+"
for i, e in enumerate(salida):
    total = sum(p for _, p in e[3])
    assert abs(total - 1.0) < 1e-4, f"vertice {i} suma {total}"

peor, cuantos = max(reparto.items(), key=lambda t: t[1])
assert cuantos / len(salida) < TOPE_REPARTO, (
    f"{peor} se lleva {cuantos / len(salida) * 100:.1f}% de la malla. Es el "
    f"fallo del 15/08: un hueso dueño de medio bicho")
tronco = sum(n for g, n in reparto.items()
             if "Root" in g or "Back" in g) / len(salida)
assert tronco >= MINIMO_TRONCO, (
    f"la raiz y la espalda solo se llevan {tronco * 100:.1f}% de la malla. "
    f"El cuerpo tiene que colgar de la columna; el 15/08 colgaba de las "
    f"puntas de las patas y RootJNT tenia 17 vertices")

for g, n in reparto.items():
    if not any(t in g for t in PUNTAS):
        continue
    assert n / len(salida) < TOPE_PUNTA, (
        f"{g} es una punta de miembro y se lleva {n / len(salida) * 100:.1f}% "
        f"de la malla. Asi empezo el fallo del 15/08: RFirstLeg3JNT con 43.2%")

# La orientacion. El GIRO_Z no es solo delante/detras: giro = Rz @ Rx, y el
# Rx(90) deja al bicho boca abajo -la Z de arriba del vanilla va a -Y-, asi
# que es el Rz(180) el que lo pone de pie. Con GIRO_Z 0 el esqueleto queda
# invertido y los huesos de la cabeza caen a la altura de nuestros pies.
#
# El assert de antes comparaba contra 0 y NO PODIA FALLAR: nuestra malla va
# de -0.02 a +1.83, asi que la media de cualquier trozo sale positiva. Ahora
# se compara contra la altura del bicho, que es lo que de verdad distingue
# la cabeza arriba de la cabeza abajo.
# Se mide sobre los HUESOS ya transformados, no sobre nuestros vertices: lo
# que puede estar del reves es el esqueleto, y nuestra malla no cambia con
# el GIRO_Z. Medirlo en la malla era ademas un assert que no podia fallar.
altura = {n: (a[1] + b[1]) / 2 for n, a, b in huesos}
arriba = [y for n, y in altura.items() if any(t in n for t in CABEZA)]
abajo = [y for n, y in altura.items() if any(t in n for t in PIES)]
assert arriba and abajo, f"no encuentro huesos de {CABEZA} y {PIES}"
print(f"esqueleto: cabeza a Y {sum(arriba) / len(arriba):+.2f}, "
      f"pies a Y {sum(abajo) / len(abajo):+.2f}")
assert sum(arriba) / len(arriba) > sum(abajo) / len(abajo), (
    f"la cabeza del esqueleto queda POR DEBAJO de los pies: con GIRO_Z "
    f"{GIRO_Z} esta boca abajo. El giro no es solo delante/detras, es el "
    f"que lo pone de pie")

SALIDA.write_text(json.dumps(salida), encoding="utf-8")
print(f"escrito {SALIDA}")

bpy.data.objects.remove(vanilla, do_unlink=True)
bpy.data.objects.remove(armature, do_unlink=True)
bpy.ops.wm.save_as_mainfile(filepath=str(BLEND))
print(f"guardado {BLEND}")
