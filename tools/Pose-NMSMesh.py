"""Deforma NUESTRA malla con las animaciones del vanilla, SIN entrar al juego.

    python tools/Pose-NMSMesh.py zombie
    python tools/Pose-NMSMesh.py zombie --vista
    python tools/Pose-NMSMesh.py necromorph --clips fiendwalk.anim

Existe porque medir en partida cuesta una sesion entera por prueba -cerrar
NMS, desplegar, arrancar por Steam, encontrar al bicho, mirarlo- y lo que se
saca de ahi son capturas, no numeros. Aqui la misma pregunta se contesta en
segundos y con una cifra.

LO QUE HACE ES LO MISMO QUE HACE EL JUEGO, y por eso vale. En partida cada
vertice nuestro se deforma asi:

    v' = suma sobre huesos de  peso * pose_de_mundo(t) * inversa_de_bind * v

y las tres piezas estan en disco: los vertices y los pesos en `pesos.json`,
la pose de bind en el `.SCENE` del vanilla y la pose por fotograma en sus
`.ANIM`. `Patch-NMSGraft.py` copia los `JointBindings` del vanilla TAL CUAL,
asi que la inversa de bind es la del `.SCENE` del vanilla y no hay nada que
adivinar ni que alinear: la desalineacion que haya, si la hay, es la MISMA
que tiene el juego.

EL LECTOR DE `.ANIM` Y LA CADENA DE HUESOS NO SE REESCRIBEN. Son los de
`Sway-NMSJoint.py`, que son los que dieron los numeros de `giros.json` y de
la tabla de PENDIENTES.md. Aqui se importan.

LA COMPROBACION VA DENTRO Y ABORTA. Con la pose de bind como animacion, v'
tiene que salir igual que v. Si eso no da cero, la inversa de bind esta mal
y todos los demas numeros son ruido.

Los `.ANIM` no estan en el repo: se sacan del `.pak` del juego la primera vez
-con el `hgpaktool` que trae NMSDK- y se dejan en `work/models/vanilla_*/`,
asi que la segunda corrida ya no toca el juego.
"""

import importlib.util
import json
import subprocess
import sys
from pathlib import Path

import numpy as np

RAIZ = Path(__file__).resolve().parent.parent
PCBANKS = Path(r"C:\Program Files (x86)\Steam\steamapps\common"
               r"\No Man's Sky\GAMEDATA\PCBANKS")
MBINCOMPILER = RAIZ / "tools" / "AMUMSS" / "MODBUILDER" / "MBINCompiler.exe"
BLENDER = Path(r"C:\Program Files\Blender Foundation\Blender 5.2\blender.exe")

# Lo que cambia de un bicho a otro.
#
#   raiz    la carpeta que repite la ruta interna del juego. Es la misma que
#           usa Weight-NMSMesh.py, y por lo mismo: el importador de NMSDK la
#           exige asi, y los `.ANIM` se dejan dentro para que casen.
#   anims   la ruta INTERNA del juego donde viven los clips. Sale del
#           `.ENTITY` del bicho, no de suponer.
#   clips   los dos que mide Sway-NMSJoint.py, mas `attack` e `idle`, que
#           son los otros dos que el bicho reproduce en partida.
MODELOS = {
    "zombie": dict(
        pesos=RAIZ / "work" / "models" / "zombiemesh" / "pesos.json",
        raiz=RAIZ / "work" / "models" / "vanilla_bugfiend",
        scene="models/planets/creatures/arthropod/bugfiend.scene.MXML",
        geometria="models/planets/creatures/arthropod/bugfiend.geometry.MXML",
        anims="models/planets/creatures/arthropod/anims",
        clips=("arthropodwalk.anim", "arthropodrun.anim",
               "arthropodattack01.anim", "arthropodidle.anim"),
        blend=RAIZ / "BLENDER" / "proyectos" / "zombie_nms.blend",
        objeto="ArthropodThorax",
    ),
    "necromorph": dict(
        pesos=RAIZ / "work" / "models" / "fiendmesh" / "pesos.json",
        raiz=RAIZ / "work" / "models" / "vanilla_fiend",
        scene="models/planets/creatures/spiderrig/fiend.scene.MXML",
        geometria="models/planets/creatures/spiderrig/fiend.geometry.MXML",
        # ANIM en singular, y no ANIMS como en el ARTHROPOD. Sale de
        # tools/AMUMSS/TOOLS/NMS_FULL_pak_list.txt, que es el listado del
        # juego entero: el .ENTITY del FIEND no nombra ni un clip.
        anims="models/planets/creatures/spiderrig/anim",
        clips=("fiendwalk.anim", "fiendrun.anim",
               "fiendattack.anim", "fiendidle.anim"),
        blend=RAIZ / "BLENDER" / "proyectos" / "necromorph_nms.blend",
        objeto="_Fiend_Body",
    ),
    # Los dos de la segunda hornada. Mismos esqueletos y mismos clips que los
    # dos que sustituyen: lo unico que cambia es de que malla salen los pesos.
    "warriorbug": dict(
        pesos=RAIZ / "work" / "models" / "warriorbugmesh" / "pesos.json",
        raiz=RAIZ / "work" / "models" / "vanilla_bugfiend",
        scene="models/planets/creatures/arthropod/bugfiend.scene.MXML",
        geometria="models/planets/creatures/arthropod/bugfiend.geometry.MXML",
        anims="models/planets/creatures/arthropod/anims",
        clips=("arthropodwalk.anim", "arthropodrun.anim",
               "arthropodattack01.anim", "arthropodidle.anim"),
        blend=RAIZ / "BLENDER" / "proyectos" / "warriorbug_nms.blend",
        objeto="ArthropodThorax",
    ),
    # LO QUE SE ENTREGA, y no el vanilla: escena, bind y clips salen de la
    # carpeta cosida, o sea de los mismos archivos que van al .lua. Es la
    # unica forma de medir un retarget, porque `Retarget-NMSRig.py` cambia
    # justo las tres cosas que los otros modelos dan por buenas del juego.
    "crywolf06": dict(
        pesos=RAIZ / "work" / "models" / "crywolfmesh" / "pesos.json",
        raiz=RAIZ / "work" / "models" / "crywolfmesh_anim6",
        scene="FIEND.SCENE.MXML",
        geometria="FIEND.GEOMETRY.MXML",
        anims="ANIM_CRYWOLF",
        clips=("FIENDWALK.ANIM", "FIENDRUN.ANIM",
               "FIENDATTACK.ANIM", "FIENDIDLE.ANIM"),
        blend=RAIZ / "BLENDER" / "proyectos" / "crywolf_nms.blend",
        objeto="_Fiend_Body",
    ),
    # LO QUE SE ENTREGA EN LA PRUEBA07, y por eso lleva las raices partidas:
    # la escena y el bind salen de la carpeta cosida -o sea de los mismos
    # archivos que van al .lua- y los clips del VANILLA, porque esta prueba
    # no entrega ni un .ANIM. Es justo lo que el juego va a leer.
    "crywolf07": dict(
        pesos=RAIZ / "work" / "models" / "crywolfmesh_anim7" / "pesos.json",
        raiz=RAIZ / "work" / "models" / "crywolfmesh_anim7",
        scene="FIEND.SCENE.MXML",
        geometria="FIEND.GEOMETRY.MXML",
        anims_raiz=RAIZ / "work" / "models" / "vanilla_fiend",
        anims="models/planets/creatures/spiderrig/anim",
        clips=("fiendwalk.anim", "fiendrun.anim",
               "fiendattack.anim", "fiendidle.anim"),
        blend=RAIZ / "BLENDER" / "proyectos" / "crywolf_nms.blend",
        objeto="_Fiend_Body",
    ),
    # El que RELEVA al cry wolf en el mismo hueco. Los clips son los mismos
    # cuatro y los `.ANIM` se leen del vanilla de 7.0, que es de donde salio
    # `giros.json`: el esqueleto no cambio en Cosmos -495 cifras identicas-
    # pero se lee uno solo, y asi no hay dos verdades.
    "xenodog": dict(
        pesos=RAIZ / "work" / "models" / "xenodogmesh" / "pesos.json",
        raiz=RAIZ / "work" / "models" / "xenodogmesh_anim",
        scene="FIEND.SCENE.MXML",
        geometria="FIEND.GEOMETRY.MXML",
        anims_raiz=RAIZ / "work" / "models" / "vanilla_7.0_fiend",
        anims="models/planets/creatures/spiderrig/anim",
        clips=("fiendwalk.anim", "fiendrun.anim",
               "fiendattack.anim", "fiendidle.anim"),
        blend=RAIZ / "BLENDER" / "proyectos" / "xenodog_nms.blend",
        objeto="_Fiend_Body",
    ),
    "crywolf": dict(
        pesos=RAIZ / "work" / "models" / "crywolfmesh" / "pesos.json",
        raiz=RAIZ / "work" / "models" / "vanilla_fiend",
        scene="models/planets/creatures/spiderrig/fiend.scene.MXML",
        geometria="models/planets/creatures/spiderrig/fiend.geometry.MXML",
        anims="models/planets/creatures/spiderrig/anim",
        clips=("fiendwalk.anim", "fiendrun.anim",
               "fiendattack.anim", "fiendidle.anim"),
        blend=RAIZ / "BLENDER" / "proyectos" / "crywolf_nms.blend",
        objeto="_Fiend_Body",
    ),
}


def _sway():
    """Sway-NMSJoint.py como modulo. Lleva un guion y no se puede importar."""
    ruta = Path(__file__).with_name("Sway-NMSJoint.py")
    spec = importlib.util.spec_from_file_location("sway", ruta)
    modulo = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(modulo)
    return modulo


sway = _sway()


def asegurar_anim(raiz: Path, interna: str, clip: str) -> Path:
    """El `.ANIM.MXML` del clip en disco, sacandolo del `.pak` si hace falta.

    Dos pasos y los dos se cachean: el `.MBIN` sale del `.pak` por hash -no
    hay indice que leer- y el `.MXML` sale de MBINCompiler.
    """
    mxml = raiz / interna / f"{clip}.MXML"
    if mxml.exists():
        return mxml
    mbin = raiz / interna / f"{clip}.mbin"
    if not mbin.exists():
        from hgpaktool import HGPAKFile
        from hgpaktool.utils import normalise_path
        dentro = normalise_path(f"{interna}/{clip}.mbin")
        for pak in sorted(PCBANKS.glob("*.pak")):
            try:
                datos = HGPAKFile(pak).extract_specific(dentro, True)
            except Exception:
                continue
            if datos:
                mbin.parent.mkdir(parents=True, exist_ok=True)
                mbin.write_bytes(datos.getvalue())
                print(f"  {clip}: sacado de {pak.name}")
                break
        else:
            raise FileNotFoundError(f"{dentro} no esta en ningun .pak")
    subprocess.run([str(MBINCOMPILER), str(mbin)], check=True,
                   capture_output=True)
    assert mxml.exists(), f"MBINCompiler no dejo {mxml}"
    return mxml


def _campos(nodo):
    return {p.get("name"): p for p in nodo}


def leer_bind(scene_mxml: Path, geo_mxml: Path) -> dict:
    """nombre de hueso -> su InvBindMatrix (4,4), la que usa el juego.

    NO SE CALCULA INVIRTIENDO LA POSE DE REPOSO DEL .SCENE, y esa fue la
    equivocacion del 01/09. Medido: de los siete huesos con peso del zombie,
    solo `spine_C0_0_jnt` casa -exacto, y no por casualidad, porque su
    matriz lleva -0,96 y -0,2392 y no es la identidad-. Los otros seis no
    casan con NINGUN indice guardado: la malla del vanilla esta pesada en
    una pose que NO es la de reposo de su escena.

    Y esto es justo lo que el juego lee, porque `Patch-NMSGraft.py` copia
    estos JointBindings a nuestra malla TAL CUAL.

    El indice es el JOINTINDEX del nodo del .SCENE, no el orden del arbol.
    """
    jointindex = {}

    def recorrer(nodo):
        campos = _campos(nodo)
        if ("Name" in campos and campos.get("Type") is not None
                and campos["Type"].get("value") == "JOINT"):
            atributos = campos.get("Attributes")
            if atributos is not None:
                for a in atributos:
                    ca = _campos(a)
                    if (ca.get("Name") is not None
                            and ca["Name"].get("value") == "JOINTINDEX"):
                        jointindex[campos["Name"].get("value")] = int(
                            ca["Value"].get("value"))
        hijos = campos.get("Children")
        if hijos is not None:
            for h in hijos:
                recorrer(h)

    import xml.etree.ElementTree as ET
    recorrer(ET.parse(scene_mxml).getroot())
    guardados = _campos(ET.parse(geo_mxml).getroot())["JointBindings"]
    # Se guarda transpuesta. Sale de comparar contra `spine_C0_0_jnt`, que
    # es el unico que casa y por tanto el unico que dice cual es el formato.
    matrices = [np.array([float(x.get("value"))
                          for x in _campos(b)["InvBindMatrix"]]).reshape(4, 4).T
                for b in guardados]
    return {n: matrices[i] for n, i in jointindex.items() if i < len(matrices)}


def _a_matriz(q, p):
    """El cuaternion y el pivote de Sway, en una 4x4."""
    x, y, z, w = q[..., 0], q[..., 1], q[..., 2], q[..., 3]
    M = np.zeros(q.shape[:-1] + (4, 4))
    M[..., 0, 0] = 1 - 2 * (y * y + z * z)
    M[..., 0, 1] = 2 * (x * y - z * w)
    M[..., 0, 2] = 2 * (x * z + y * w)
    M[..., 1, 0] = 2 * (x * y + z * w)
    M[..., 1, 1] = 1 - 2 * (x * x + z * z)
    M[..., 1, 2] = 2 * (y * z - x * w)
    M[..., 2, 0] = 2 * (x * z - y * w)
    M[..., 2, 1] = 2 * (y * z + x * w)
    M[..., 2, 2] = 1 - 2 * (x * x + y * y)
    M[..., :3, 3] = p
    M[..., 3, 3] = 1.0
    return M


def cargar_pesos(ruta: Path):
    """(vertices (V,3), indices de hueso (V,K), pesos (V,K), nombres)."""
    crudo = json.loads(ruta.read_text(encoding="utf-8"))
    nombres = sorted({n for e in crudo for n, _ in e[3]})
    posicion = {n: i for i, n in enumerate(nombres)}
    ranuras = max(len(e[3]) for e in crudo)
    v = np.array([[e[0], e[1], e[2]] for e in crudo])
    idx = np.zeros((len(crudo), ranuras), dtype=np.int64)
    w = np.zeros((len(crudo), ranuras))
    for i, e in enumerate(crudo):
        for k, (nombre, peso) in enumerate(e[3]):
            idx[i, k] = posicion[nombre]
            w[i, k] = peso
    return v, idx, w, nombres


def piel(v, idx, w, invbind, pose, f):
    """Los vertices en el fotograma `f`. Esto ES el skinning del juego.

        v' = suma de  peso * pose_de_mundo(f) * inversa_de_bind * v
    """
    M = _a_matriz(pose[0][:, f, :], pose[1][:, f, :]) @ invbind   # (B,4,4)
    homogeneo = np.concatenate([v, np.ones((len(v), 1))], axis=1)
    movido = np.einsum("vkij,vj->vki", M[idx], homogeneo)[..., :3]
    return (w[..., None] * movido).sum(axis=1)


def apilar(huesos, nombres, giros, trasl, n):
    """pose_de_mundo puesta en dos arrays, (B,F,4) y (B,F,3), en orden."""
    poses = sway.pose_de_mundo(huesos, giros, trasl, n)
    q = np.stack([poses[nombre][0] for nombre in nombres])
    p = np.stack([poses[nombre][1] for nombre in nombres])
    return q, p


def main(argv):
    cual = next((a for a in argv[1:] if not a.startswith("-")), "zombie")
    M = MODELOS[cual]
    clips = M["clips"]
    if "--clips" in argv:
        clips = tuple(argv[argv.index("--clips") + 1].split(","))

    # `--pesos` existe para el barrido: cada candidato de
    # `Weight-NMSMesh.py --barrer --objetivo` deja su propio json.
    pesos = (Path(argv[argv.index("--pesos") + 1]) if "--pesos" in argv
             else M["pesos"])
    v, idx, w, nombres = cargar_pesos(pesos)
    huesos = sway.leer_scene(M["raiz"] / M["scene"])
    faltan = [n for n in nombres if n not in huesos]
    assert not faltan, f"pesos.json nombra huesos que no estan en el .SCENE: {faltan}"
    print(f"{cual}: {len(v)} vertices, {len(nombres)} huesos con peso, "
          f"{len(huesos)} en el esqueleto")

    binds = leer_bind(M["raiz"] / M["scene"], M["raiz"] / M["geometria"])
    sin_bind = [n for n in nombres if n not in binds]
    assert not sin_bind, f"sin JointBinding en el vanilla: {sin_bind}"
    invbind = np.stack([binds[n] for n in nombres])

    # COMPROBACION 1: que el JOINTINDEX y la transpuesta sean los buenos.
    #
    # La regla es que el bind TIENE que ser la inversa de la pose de mundo en
    # la que se peso la malla, asi que en ESA pose `mundo * bind` da la
    # identidad. Lo que no se puede dar por sabido es CUAL es esa pose: hasta
    # la PRUEBA05 era el reposo del .SCENE, porque el bind se copiaba del
    # vanilla; desde que `Patch-NMSGraft.py --bind` existe puede ser un
    # fotograma de un clip, y entonces con el reposo no casa NI UNO -medido,
    # y el assert viejo abortaba una entrega buena-.
    #
    # Asi que se busca la pose de referencia en vez de suponerla. Si no
    # aparece en ninguna, el JOINTINDEX o la transpuesta estan mal, que es
    # justo lo que este assert existe para cazar.
    q0, p0 = apilar(huesos, nombres, {}, {}, 1)
    candidatas = [("el reposo del .SCENE", _a_matriz(q0[:, 0, :], p0[:, 0, :]))]
    for clip in clips:
        giros, trasl, _ = sway.leer_anim(
            asegurar_anim(M.get("anims_raiz", M["raiz"]), M["anims"], clip))
        n = len(next(iter(giros.values())))
        q, p = apilar(huesos, nombres, giros, trasl, n)
        for f in range(n):
            candidatas.append((f"{clip} fotograma {f}",
                               _a_matriz(q[:, f, :], p[:, f, :])))
    mejor = (0, None)
    for etiqueta, mundo in candidatas:
        casan = [n for i, n in enumerate(nombres)
                 if np.abs(np.linalg.inv(mundo[i]) - invbind[i]).max() < 1e-4]
        if len(casan) > mejor[0]:
            mejor = (len(casan), (etiqueta, casan))
    assert mejor[1], ("el bind no es la inversa de ninguna pose de mundo: el "
                      "JOINTINDEX o la transpuesta estan mal")
    etiqueta, casan = mejor[1]
    print(f"bind: es la inversa de {etiqueta} en {len(casan)} de "
          f"{len(nombres)} huesos: {', '.join(casan)}")

    # Vecinos por distancia sobre la malla en reposo. Una "lamina tensada" ES
    # un par de vertices vecinos que se van uno del otro; sin topologia, los
    # seis mas cercanos valen igual para verlo.
    #
    # Y SE MIDE ENTRE VECINOS Y NO CONTRA EL REPOSO A PROPOSITO. Un bicho que
    # anda mueve TODOS sus vertices metros, y eso no es un fallo: es el paso.
    # La distancia entre dos vecinos, en cambio, no la cambia ningun
    # movimiento de cuerpo rigido. Lo que la cambia es la piel.
    from scipy.spatial import cKDTree
    vecinos = cKDTree(v).query(v, k=7)[1][:, 1:]
    largo0 = np.linalg.norm(v[vecinos] - v[:, None, :], axis=2)
    # Las costuras de UV traen vertices pegados -30 pares por debajo de 1 mm
    # en el zombie, y 3 exactamente duplicados-. Un par de largo cero da una
    # razon infinita que no dice nada, asi que no se miran.
    vale = largo0 >= 0.001

    dominante = np.array(nombres)[idx[np.arange(len(v)), w.argmax(axis=1)]]
    guardar = {}
    print(f"{'clip':22} {'fot':>4} {'tension':>8} {'flex':>6} {'abre':>7} "
          f"{'viaje':>7} {'alto':>7}  donde")
    for clip in clips:
        mxml = asegurar_anim(M.get("anims_raiz", M["raiz"]), M["anims"], clip)
        giros, trasl, _ = sway.leer_anim(mxml)
        n = len(next(iter(giros.values())))
        pose = apilar(huesos, nombres, giros, trasl, n)

        # COMPROBACION 2, y en la primera vuelta basta: con TODA la malla
        # colgando de UN hueso el skinning es un movimiento rigido, y un
        # movimiento rigido no cambia ninguna distancia. Si esto no da 1,00
        # exacto, el fallo esta en esta matematica y no en los pesos.
        if not guardar:
            uno = np.zeros((len(v), 1), dtype=np.int64)
            rigido = np.stack([piel(v, uno, np.ones((len(v), 1)), invbind,
                                    pose, f) for f in (0, n // 2)])
            d = np.linalg.norm(rigido[:, vecinos] - rigido[:, :, None, :],
                               axis=3)
            desvio = float(np.abs(d[:, vale] / largo0[vale] - 1.0).max())
            assert desvio < 1e-4, (
                f"un solo hueso deforma la malla un {desvio:.4%}, y no puede: "
                f"la matematica del skinning esta mal")
            print(f"rigido comprobado: un hueso solo no deforma "
                  f"({desvio:.1e})")

        cuadros = np.stack([piel(v, idx, w, invbind, pose, f) for f in range(n)])
        guardar[clip] = cuadros

        # Cuatro numeros, y los dos primeros son el fallo escrito en
        # PENDIENTES.md:
        #   tension  cuantas veces se estira la distancia entre dos vecinos.
        #            Una "cuchilla" o una "lamina plana tensada" es esto: un
        #            salto de peso entre dos vertices pegados. 1,0 es una
        #            malla que no se deforma nada.
        #   flex     la MISMA razon en el p99, o sea la deformacion normal
        #            de la piel. Existe para no premiar una estatua: apretar
        #            los alfas baja `tension` SIEMPRE, y al final deja un
        #            bicho tieso con flex 1,00 que en partida se ve peor.
        #   abre     el estiron en metros, que es lo que se ve en pantalla.
        #   viaje    cuanto se va un vertice del reposo. NO es un fallo: es
        #            el paso. Se imprime para no confundirlo con lo de
        #            arriba.
        #   alto     cuanto sube el bicho entero. Es el "se despega del
        #            suelo" del necromorfo, que es traslacion y no giro.
        largo = np.linalg.norm(cuadros[:, vecinos] - cuadros[:, :, None, :],
                               axis=3)
        razon = np.where(vale, largo / np.where(vale, largo0, 1.0), 0.0)
        abre = np.where(vale, largo - largo0, 0.0)
        salto = np.linalg.norm(cuadros - v, axis=2)
        alto = cuadros[..., 1].mean(axis=1)
        peor = int(razon.max(axis=(0, 2)).argmax())
        flex = float(np.percentile(razon[np.broadcast_to(vale, razon.shape)], 99))
        print(f"{clip:22} {n:4} {razon.max():8.2f} {flex:6.2f} "
              f"{abre.max():7.2f} {salto.max():7.2f} "
              f"{alto.max() - alto.min():7.2f}  {dominante[peor]}")
        guardar[clip + "_tension"] = razon.max(axis=(0, 2))

    # Los huesos que mas tensan, sumando todos los clips. Es la lista de a
    # quien hay que apretarle el alfa en Weight-NMSMesh.py.
    peor_de = {}
    for nombre, dato in guardar.items():
        if not nombre.endswith("_tension"):
            continue
        for hueso in set(dominante):
            m = dominante == hueso
            peor_de[hueso] = max(peor_de.get(hueso, 0.0), float(dato[m].max()))
    print(f"\n{'hueso':22} {'vert':>6} {'tension maxima':>15}")
    for hueso, razon in sorted(peor_de.items(), key=lambda t: -t[1])[:10]:
        print(f"{hueso:22} {int((dominante == hueso).sum()):6} {razon:15.2f}")
    guardar = {k: g for k, g in guardar.items() if not k.endswith("_tension")}

    if "--vista" in argv:
        salida = RAIZ / "BLENDER" / "vista_anim" / cual
        salida.mkdir(parents=True, exist_ok=True)
        npz = salida / "poses.npz"
        np.savez_compressed(npz, reposo=v, **guardar)
        subprocess.run([str(BLENDER), "--background", "--python", __file__,
                        "--", cual, "--pintar", str(npz)], check=True)
        print(f"\nfotogramas en {salida}")
    return 0


def pintar(cual, npz):
    """Dentro de Blender: la malla del .blend con los vertices ya deformados.

    No hace falta esqueleto ni modificador -los vertices vienen calculados- y
    por eso esto no depende de NMSDK, que en la version instalada trae la
    carga de animaciones a medias: `load_animations` acaba en un `return`
    muerto y `add_animation_to_scene` casca al animar el armature.

    La camara se orienta sola -el eje mas largo del bicho es el vertical- en
    vez de fiarse de si la malla es Y arriba o Z arriba.
    """
    import bpy
    from mathutils import Matrix, Vector

    M = MODELOS[cual]
    datos = np.load(npz)
    bpy.ops.wm.open_mainfile(filepath=str(M["blend"]))
    ob = bpy.data.objects[M["objeto"]]
    for otro in list(bpy.data.objects):
        if otro is not ob and otro.type in {"MESH", "ARMATURE"}:
            bpy.data.objects.remove(otro, do_unlink=True)

    sc = bpy.context.scene
    sc.render.engine = "BLENDER_WORKBENCH"
    sc.render.resolution_x = sc.render.resolution_y = 700
    sc.display.shading.light = "STUDIO"
    sc.display.shading.show_object_outline = True

    camara = bpy.data.objects.new("camara", bpy.data.cameras.new("camara"))
    sc.collection.objects.link(camara)
    sc.camera = camara
    camara.data.type = "ORTHO"

    reposo = datos["reposo"]
    caja = reposo.max(axis=0) - reposo.min(axis=0)
    arriba = int(caja.argmax())          # el bicho es mas alto que ancho
    lados = [i for i in range(3) if i != arriba]
    salida = Path(npz).parent

    # `reposo.png` primero, y es la imagen de control: si el bicho sale bien
    # ahi y roto en los clips, lo roto es la piel y no este guion.
    for clip in ["reposo"] + [c for c in datos.files if c != "reposo"]:
        cuadros = datos[clip][None, ...] if clip == "reposo" else datos[clip]
        # Seis fotogramas repartidos: mas no aporta y son PNG que mirar.
        for f in np.linspace(0, len(cuadros) - 1, 6).astype(int)[:1 if clip == "reposo" else None]:
            for i, co in enumerate(cuadros[f]):
                ob.data.vertices[i].co = Vector(co)
            ob.data.update()
            mundo = np.array([list(ob.matrix_world @ p.co)
                              for p in ob.data.vertices])
            centro = (mundo.max(axis=0) + mundo.min(axis=0)) / 2
            tam = mundo.max(axis=0) - mundo.min(axis=0)
            for k, fondo in enumerate(lados):
                eje_y = Vector((0, 0, 0))
                eje_y[arriba] = 1
                eje_z = Vector((0, 0, 0))
                eje_z[fondo] = 1
                eje_x = eje_y.cross(eje_z)
                camara.matrix_world = Matrix((
                    (eje_x.x, eje_y.x, eje_z.x, centro[0] + eje_z.x * 50),
                    (eje_x.y, eje_y.y, eje_z.y, centro[1] + eje_z.y * 50),
                    (eje_x.z, eje_y.z, eje_z.z, centro[2] + eje_z.z * 50),
                    (0, 0, 0, 1)))
                camara.data.ortho_scale = float(max(tam) * 1.25)
                sc.render.filepath = str(salida / f"{clip}_f{f:02d}_v{k}.png")
                bpy.ops.render.render(write_still=True)


if __name__ == "__main__":
    if "--pintar" in sys.argv:
        corte = sys.argv.index("--") + 1
        pintar(sys.argv[corte], sys.argv[sys.argv.index("--pintar") + 1])
    else:
        sys.exit(main(sys.argv))
