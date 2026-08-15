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

--invertir-y da la vuelta al canal verde. Las dos convenciones existen
-OpenGL con +Y arriba y DirectX con +Y abajo- y cual quiere el ubershader
de NMS no esta escrito en ninguna parte que hayamos leido. Si en el juego
el relieve sale hundido donde deberia sobresalir, es esto: se vuelve a
generar con la bandera puesta y no hay que tocar nada mas.

La salida es un PNG. Para el .DDS que come el juego, despues:

    python tools/Make-NMSTexture.py <salida.png> <vanilla ATI2>.DDS <final>.DDS

Requiere: Pillow, numpy.
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


if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.exit(__doc__)

    origen, salida = sys.argv[1], sys.argv[2]
    fuerza = 2.0
    suavizar = 1.0
    invertir_y = "--invertir-y" in sys.argv
    if "--fuerza" in sys.argv:
        fuerza = float(sys.argv[sys.argv.index("--fuerza") + 1])
    if "--suavizar" in sys.argv:
        suavizar = float(sys.argv[sys.argv.index("--suavizar") + 1])

    img = Image.open(origen).convert("L")
    if suavizar > 0:
        img = img.filter(ImageFilter.GaussianBlur(suavizar))
    altura = np.asarray(img)

    rgb = normal_desde_altura(altura, fuerza, invertir_y)
    Image.fromarray(rgb, "RGB").save(salida)

    print(f"\n  origen     {origen}  {altura.shape[1]}x{altura.shape[0]}")
    print(f"  fuerza {fuerza}  suavizado {suavizar}  "
          f"invertir-y {'si' if invertir_y else 'no'}")
    print(f"  desvio de la vertical: X {rgb[..., 0].std():.1f}  "
          f"Y {rgb[..., 1].std():.1f} sobre 128 (0 seria un mapa plano)")
    print(f"  escrito    {salida}\n")
