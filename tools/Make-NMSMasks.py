"""Fabrica el gMasksMap cuando el asset NO trae rugosidad propia.

    python tools/Make-NMSMasks.py <atlas de color.png> <salida.png>
                                  [--media M] [--desv D]

El canal que el juego lee en las criaturas es un ATI1 de UN canal y se
comporta como BRILLO, no como rugosidad: con 174 el bicho sale mojado y el
vanilla mide 85. Eso esta medido y contesta a `Q-MASCARAS`.

POR QUE EXISTE: una mascara PLANA es lo que el ojo lee como plastico. El
warrior bug iba a 87 en los cuatro millones de pixeles -desviacion 0,0- y por
eso salia de plastico; el ARTHROPOD vanilla mide 146,6 con desviacion 30,6 y
el FIEND 85,6 con 37,9. No es el nivel lo que falta, es la VARIACION.

DE DONDE SALE EL RELIEVE DE BRILLO CUANDO NO HAY RUGOSIDAD: de la luminancia
del propio atlas de color. Es una aproximacion, y se elige a sabiendas: en un
modelo pintado las grietas y la mugre van oscuras y son mates, y los bultos
lavados van claros y brillan. No es una medida fisica, es la correlacion que
el pintor ya metio en el color.

EL FONDO SE QUEDA A 0 Y ESA ES LA TRAMPA QUE ESTE GUION EVITA. Un atlas deja
celdas sin usar, y ahi el color es negro. Si la mascara se normaliza entera,
ese fondo se va al valor medio y a partir del cuarto mip sangra hacia dentro
de cada isla. Es el mismo fallo que el `--invertir` del conversor le hizo al
cry wolf, que dejo el 50,1% de su atlas a 255, o sea a brillo maximo.

Requiere: Pillow, numpy.
"""

import sys
from pathlib import Path

import numpy as np
from PIL import Image

# Lo que mide el vanilla, y por eso son los valores por defecto: el
# ARTHROPOD del BUGFIEND da media 146,6 y desviacion 30,6, leido de
# arthropodthorax01.base.masks.dds.
MEDIA = 146.6
DESV = 30.6
# Por debajo de esto el pixel es fondo de atlas, no modelo. El mismo corte
# que usa Make-NMSTexture.py --rellenar.
NEGRO = 6


def mascara_desde_color(rgb, media, desv):
    """(H,W,3) -> (H,W) uint8. Fondo a 0, util centrado en `media`."""
    fondo = rgb.astype(np.int32).sum(axis=2) <= NEGRO
    lum = rgb @ np.array([0.2126, 0.7152, 0.0722])
    util = lum[~fondo]
    if util.size == 0:
        raise SystemExit("el atlas esta entero en negro")
    # Tipificar y volver a escalar: lo que importa es la VARIACION, y la
    # luminancia cruda de un atlas no tiene por que caer donde el vanilla.
    sigma = util.std()
    if sigma < 1e-6:
        raise SystemExit("la luminancia del atlas es plana: no hay de donde "
                         "sacar variacion, hace falta hornear")
    fuera = (lum - util.mean()) / sigma * desv + media
    fuera = np.clip(fuera, 0, 255)
    fuera[fondo] = 0
    return fuera.astype(np.uint8), fondo


def main():
    if len(sys.argv) < 3:
        raise SystemExit(__doc__)
    origen, salida = Path(sys.argv[1]), Path(sys.argv[2])
    media = float(sys.argv[sys.argv.index("--media") + 1]
                  if "--media" in sys.argv else MEDIA)
    desv = float(sys.argv[sys.argv.index("--desv") + 1]
                 if "--desv" in sys.argv else DESV)

    rgb = np.asarray(Image.open(origen).convert("RGB")).astype(np.float64)
    px, fondo = mascara_desde_color(rgb, media, desv)

    util = px[~fondo]
    print(f"{origen.name} -> {salida.name}  {px.shape[1]}x{px.shape[0]}")
    print(f"  fondo    {fondo.mean() * 100:5.1f}% del atlas, a 0")
    print(f"  util     media {util.mean():5.1f}  desv {util.std():5.1f}  "
          f"p1 {np.percentile(util, 1):3.0f}  p99 {np.percentile(util, 99):3.0f}")
    print(f"  objetivo media {media:5.1f}  desv {desv:5.1f}")

    # El recorte en 0..255 mueve la media y la desviacion, y mucho recorte
    # querria decir que el objetivo no cabe. Se avisa aqui y no en partida.
    assert abs(util.mean() - media) < 12, (
        f"la media util sale {util.mean():.1f} contra un objetivo de {media}: "
        f"el recorte se esta comiendo la cola, baja --desv")
    assert util.std() > desv * 0.6, (
        f"la desviacion util sale {util.std():.1f} de {desv}: el atlas no "
        f"tiene contraste que repartir")

    Image.fromarray(px, mode="L").save(salida)
    print(f"  escrito  {salida}")


def demo():
    """python tools/Make-NMSMasks.py --demo"""
    alto = np.tile(np.linspace(0, 255, 64), (64, 1))
    rgb = np.dstack([alto] * 3)
    rgb[:, :8] = 0                      # una franja de fondo
    px, fondo = mascara_desde_color(rgb, 146.6, 30.6)
    assert (px[fondo] == 0).all(), "el fondo tiene que quedarse a 0"
    assert fondo.mean() == 8 / 64, f"fondo detectado {fondo.mean()}"
    util = px[~fondo].astype(float)
    assert abs(util.mean() - 146.6) < 3, util.mean()
    assert abs(util.std() - 30.6) < 3, util.std()
    # Y la variacion tiene que SEGUIR al color, no ir al reves.
    assert px[0, -1] > px[0, 10], "el pixel claro tiene que salir mas brillante"
    print("demo ok")


if __name__ == "__main__":
    if "--demo" in sys.argv:
        demo()
    else:
        main()
