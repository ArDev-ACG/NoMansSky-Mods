"""Fabrica un mapa de normales tangenciales a partir de una imagen de altura.

    python tools/Make-NMSNormal.py <origen.png> <salida.png> [--fuerza N]
                                   [--suavizar N] [--invertir-y]

Existe porque los assets de Meshy AI NO traen normal: el ScrullCrawler solo
da color, metallic y roughness. Sin esto, el gNormalMap se queda con el del
bicho vanilla, que esta pintado para las UV del SCUTTLER original y reparte
el relieve donde no toca.

La altura sale de la LUMINANCIA del origen. Es el truco clasico y aqui
funciona mejor de lo que parece: estos assets llevan la oclusion horneada
dentro del color, asi que lo oscuro ya son las grietas y lo claro los
bultos. No es un normal esculpido, pero es NUESTRO y cae en NUESTRAS UV.

    altura   -> pendiente en X e Y -> normal = normalizar(-dx*f, -dy*f, 1)
    normal   -> RGB de 0 a 255, con 128 como el cero

--fuerza sube o baja el relieve; por debajo de 1 casi no se nota y por
encima de 4 empieza a verse el ruido de la compresion del origen.

--sin-costuras N apaga el relieve en el borde de cada isla de UV. HACE FALTA
en los assets de Meshy y es lo que dibujaba las estrellas en la nuca del
SkrullCrawler: la altura sale de la luminancia y el fondo sin usar es NEGRO
PURO, asi que en el borde de cada isla la pendiente se dispara y el guion
graba una arruga siguiendo el corte del atlas. Medido sobre el normal que
estaba en partida: inclinacion 0.4905 en el borde contra 0.0850 dentro, o sea
UNA MENTIRA DE x5.8 pintada exactamente por donde Meshy corto las islas.

El arreglo son dos cosas, y las dos hacen falta:

  1. el hueco se rellena con el color de la isla mas cercana ANTES de derivar,
     para que no haya acantilado que derivar;
  2. dentro de los N primeros pixeles de cada isla la inclinacion se lleva a
     cero de forma suave. Ahi el relieve es del corte, no del bicho, y ademas
     asi las dos orillas de una costura coinciden -planas las dos- y la
     costura deja de verse.

El fondo queda plano, que es lo correcto y ademas no sangra por los mips.

--invertir-y da la vuelta al canal verde. Las dos convenciones existen
-OpenGL con +Y arriba y DirectX con +Y abajo- y cual quiere el ubershader
de NMS no esta escrito en ninguna parte que hayamos leido. Si en el juego
el relieve sale hundido donde deberia sobresalir, es esto: se vuelve a
generar con la bandera puesta y no hay que tocar nada mas.

La salida es un PNG. Para el .DDS que come el juego, despues:

    python tools/Make-NMSTexture.py <salida.png> <vanilla ATI2>.DDS <final>.DDS

Requiere: Pillow, numpy. Y scipy, pero solo con --sin-costuras.
"""

import sys

import numpy as np
from PIL import Image, ImageFilter


def normal_desde_altura(altura: np.ndarray, fuerza: float,
                        invertir_y: bool) -> np.ndarray:
    """La pendiente de la altura -> normal tangencial en 0..255."""
    # np.gradient da la pendiente en cada eje; el signo va al reves que la
    # normal, porque subir de altura inclina la superficie hacia atras.
    dy, dx = np.gradient(altura.astype(np.float32) / 255.0)
    x = -dx * fuerza
    y = -dy * fuerza
    if invertir_y:
        y = -y
    z = np.ones_like(x)

    largo = np.sqrt(x * x + y * y + z * z)
    x, y, z = x / largo, y / largo, z / largo

    salida = np.stack([x, y, z], axis=-1)
    return np.clip((salida * 0.5 + 0.5) * 255.0, 0, 255).astype(np.uint8)


def mascara_util(origen):
    """-> (util, relleno). util es donde el atlas tiene bicho; relleno es la
    imagen con el hueco derramado desde la isla mas cercana."""
    from scipy import ndimage  # solo con --sin-costuras

    rgb = np.asarray(Image.open(origen).convert("RGB"), np.uint8)
    fondo = rgb.max(2) == 0
    if not fondo.any():
        return None, None
    _, (yi, xi) = ndimage.distance_transform_edt(fondo, return_indices=True)
    dentro = ndimage.distance_transform_edt(~fondo)
    return dentro, Image.fromarray(rgb[yi, xi], "RGB")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.exit(__doc__)

    origen, salida = sys.argv[1], sys.argv[2]
    fuerza = 2.0
    suavizar = 1.0
    invertir_y = "--invertir-y" in sys.argv
    sin_costuras = 0.0
    if "--sin-costuras" in sys.argv:
        i = sys.argv.index("--sin-costuras")
        sig = sys.argv[i + 1] if i + 1 < len(sys.argv) else ""
        sin_costuras = float(sig) if sig and not sig.startswith("--") else 4.0
    if "--fuerza" in sys.argv:
        fuerza = float(sys.argv[sys.argv.index("--fuerza") + 1])
    if "--suavizar" in sys.argv:
        suavizar = float(sys.argv[sys.argv.index("--suavizar") + 1])

    dentro = None
    fuente = origen
    if sin_costuras > 0:
        dentro, relleno = mascara_util(origen)
        if dentro is None:
            print("  --sin-costuras: no hay fondo negro, no hay costuras que apagar")
        else:
            fuente = relleno

    img = (fuente if isinstance(fuente, Image.Image) else Image.open(fuente)).convert("L")
    if suavizar > 0:
        img = img.filter(ImageFilter.GaussianBlur(suavizar))
    altura = np.asarray(img)

    rgb = normal_desde_altura(altura, fuerza, invertir_y)

    if dentro is not None:
        # Suave de 0 en el borde a 1 a los N pixeles. Se aplica sobre el
        # desplazamiento respecto del plano, asi que 0 = normal plana.
        peso = np.clip(dentro / sin_costuras, 0.0, 1.0)[..., None]
        plano = np.array([128.0, 128.0, 255.0])
        rgb = np.clip(plano + (rgb.astype(np.float32) - plano) * peso,
                      0, 255).astype(np.uint8)
        print(f"  --sin-costuras {sin_costuras:g}: aplanado el "
              f"{(peso[..., 0] < 1).mean() * 100:.1f}% de la textura "
              f"(borde de isla y hueco)")

    Image.fromarray(rgb, "RGB").save(salida)

    print(f"\n  origen     {origen}  {altura.shape[1]}x{altura.shape[0]}")
    print(f"  fuerza {fuerza}  suavizado {suavizar}  "
          f"invertir-y {'si' if invertir_y else 'no'}")
    print(f"  desvio de la vertical: X {rgb[..., 0].std():.1f}  "
          f"Y {rgb[..., 1].std():.1f} sobre 128 (0 seria un mapa plano)")
    print(f"  escrito    {salida}\n")
