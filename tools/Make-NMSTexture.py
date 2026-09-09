"""
Convierte una imagen (JPG/PNG) al .DDS que come No Man's Sky, con mipmaps.

Tres formatos, elegidos leyendo la cabecera del .DDS vanilla de referencia:

  DX10 / dxgi 98  ->  BC7_UNORM   color base (gDiffuseMap)
  ATI2            ->  BC5 (3Dc)   normales de dos canales (gNormalMap)
  ATI1            ->  BC4         mascaras de un canal (gMasksMap)

Por que existe: NMS usa estos dos y no hay ningun conversor en el sistema (ni
texconv ni nvcompress). BC7 se codifica en modo 6, que es el modo de un solo
subset: dos endpoints RGBA de 7 bits + p-bit e indices de 4 bits. BC5 son dos
bloques BC4 seguidos, uno por canal, cada uno con endpoints de 8 bits e indices
de 3 bits en el modo de 8 valores.

La cabecera DDS se copia byte a byte de la textura vanilla de referencia, asi que
formato, dimensiones y numero de mips salen identicos por construccion.

Uso:
    python tools/Make-NMSTexture.py <origen.png> <vanilla.dds> <salida.dds>
                                    [--tile N] [--suma otra.png] [--canales RG]

    origen      imagen de la que sacar el color
    vanilla     .DDS del juego que da cabecera, formato y tamano
    salida      .DDS a escribir
    --tile N    repite el origen NxN antes de escalar (por defecto 1)
    --suma IMG  suma otra imagen al origen, saturando en 255. Sirve para hornear
                un mapa de emision dentro del color base cuando no hay glow real
    --canales   solo BC5: que dos canales del origen van a los dos bloques.
                Por defecto RG (X en el primero, Y en el segundo, como DXGI BC5)
    --canal C   solo BC4: que canal del origen va al bloque. Por defecto R
    --rellenar  derrama cada isla de UV sobre el fondo negro antes de hacer
                los mips, para que el negro no sangre en los bordes. Ver dilatar()
    --invertir  da la vuelta al valor (255-x) antes de codificar. Para cuando el
                mapa de un canal viene al reves de lo que espera el shader,
                rugosidad frente a suavidad
    --tamano N  escribe el .DDS a NxN en vez de al tamano del vanilla, parcheando
                ancho, alto, mips y linearSize de la cabecera copiada. El formato
                y los flags siguen siendo los del vanilla. Existe por `Q-TEXBUG`:
                el atlas del warrior bug guarda a 512 unos PNG de 2048, y la unica
                forma de darle mas pixeles sin tocar una UV es subir el .DDS

Requiere: Pillow, numpy. Y scipy, pero solo con --rellenar.
"""
import struct
import sys

import numpy as np
from PIL import Image

DDS_MAGIC = b"DDS "
HEADER_LEN = 128
DX10_LEN = 20
DXGI_BC7_UNORM = 98

# Pesos de interpolacion de los indices de 4 bits (tabla aWeight4 del spec BC7).
W4 = np.array([0, 4, 9, 13, 17, 21, 26, 30, 34, 38, 43, 47, 51, 55, 60, 64])


def read_dds_header(path):
    """-> (cabecera, ancho, alto, mips, formato). formato es 'BC7' o 'BC5'."""
    with open(path, "rb") as fh:
        head = fh.read(HEADER_LEN + DX10_LEN)
    if head[:4] != DDS_MAGIC:
        raise SystemExit(f"{path}: no es un DDS")
    height, width = struct.unpack_from("<2I", head, 12)
    mips = struct.unpack_from("<I", head, 28)[0]
    fourcc = head[84:88]
    if fourcc == b"DX10":
        dxgi = struct.unpack_from("<I", head, HEADER_LEN)[0]
        if dxgi != DXGI_BC7_UNORM:
            raise SystemExit(f"{path}: dxgi {dxgi}, se esperaba {DXGI_BC7_UNORM} (BC7_UNORM)")
        return head, width, height, max(mips, 1), "BC7"
    if fourcc == b"ATI2":
        # ATI2 no lleva bloque DX10: la cabecera son 128 bytes y ya.
        return head[:HEADER_LEN], width, height, max(mips, 1), "BC5"
    if fourcc == b"ATI1":
        # ATI1 es medio ATI2: un solo bloque BC4, un solo canal.
        return head[:HEADER_LEN], width, height, max(mips, 1), "BC4"
    raise SystemExit(
        f"{path}: fourcc {fourcc!r}, solo se soportan DX10/BC7, ATI2/BC5 y ATI1/BC4")


def to_blocks(img):
    """(H,W,4) uint8 -> (nblocks,16,4) int16, rellenando hasta multiplo de 4."""
    h, w, _ = img.shape
    ph, pw = (-h) % 4, (-w) % 4
    if ph or pw:
        img = np.pad(img, ((0, ph), (0, pw), (0, 0)), mode="edge")
        h, w = img.shape[:2]
    bh, bw = h // 4, w // 4
    blk = img.reshape(bh, 4, bw, 4, 4).transpose(0, 2, 1, 3, 4)
    return blk.reshape(bh * bw, 16, 4).astype(np.int16)


def encode_bc7_mode6(img):
    """Codifica (H,W,4) uint8 a bytes BC7 modo 6."""
    px = to_blocks(img)
    n = px.shape[0]

    # Endpoints: caja minima del bloque. p-bit fijo a 1 -> valor8 = v7*2+1.
    lo8 = px.min(axis=1)
    hi8 = px.max(axis=1)
    v7_lo = np.clip(lo8 // 2, 0, 127).astype(np.int16)
    v7_hi = np.clip(hi8 // 2, 0, 127).astype(np.int16)
    e0 = (v7_lo * 2 + 1).astype(np.int32)
    e1 = (v7_hi * 2 + 1).astype(np.int32)

    # Indice por pixel: proyeccion sobre la recta e0->e1 en RGBA.
    d = (e1 - e0).astype(np.float32)
    denom = (d * d).sum(axis=1)
    flat = denom < 1e-6
    denom = np.where(flat, 1.0, denom)
    rel = px.astype(np.float32) - e0[:, None, :].astype(np.float32)
    t = np.einsum("bpc,bc->bp", rel, d) / denom[:, None]
    idx = np.clip(np.rint(t * 15.0), 0, 15).astype(np.int64)
    idx[flat] = 0

    # El indice ancla (pixel 0) lleva el bit alto implicito a 0: debe ser <= 7.
    swap = idx[:, 0] > 7
    if swap.any():
        idx[swap] = 15 - idx[swap]
        v7_lo[swap], v7_hi[swap] = v7_hi[swap].copy(), v7_lo[swap].copy()

    lo = np.zeros(n, dtype=np.uint64)
    hi = np.zeros(n, dtype=np.uint64)

    lo |= np.uint64(0x40)  # modo 6: seis ceros y un uno
    a = v7_lo.astype(np.uint64)
    b = v7_hi.astype(np.uint64)
    for i, off in enumerate((7, 21, 35, 49)):  # R, G, B, A
        lo |= a[:, i] << np.uint64(off)
        lo |= b[:, i] << np.uint64(off + 7)
    lo |= np.uint64(1) << np.uint64(63)  # P0
    hi |= np.uint64(1)  # P1

    ix = idx.astype(np.uint64)
    hi |= (ix[:, 0] & np.uint64(7)) << np.uint64(1)
    for p in range(1, 16):
        hi |= ix[:, p] << np.uint64(4 + 4 * (p - 1))

    out = np.empty((n, 2), dtype="<u8")
    out[:, 0] = lo
    out[:, 1] = hi
    return out.tobytes()


def encode_bc4_blocks(px):
    """(nbloques,16) uint8 de UN canal -> (nbloques,8) uint8, bloque BC4.

    Modo de 8 valores: exige r0 > r1. La paleta es r0, r1 y seis interpolados
    p[k] = ((8-k)*r0 + (k-1)*r1) / 7 para k = 2..7, o sea r0 pesando (8-k)/7.
    """
    n = px.shape[0]
    r0 = px.max(axis=1).astype(np.int32)  # el alto va primero: r0 > r1
    r1 = px.min(axis=1).astype(np.int32)
    delta = r0 - r1
    plano = delta == 0

    t = (px.astype(np.float32) - r1[:, None]) / np.where(plano, 1, delta)[:, None]
    q = np.clip(np.rint(t * 7.0), 0, 7).astype(np.int64)  # 7 = r0, 0 = r1

    # q -> indice BC4: 7->0 (r0), 0->1 (r1), 1..6 -> 7..2.
    k = np.where(q == 7, 0, np.where(q == 0, 1, 8 - q))
    k[plano] = 0  # bloque uniforme: todo apunta a r0, que vale lo mismo que r1

    bits = np.zeros(n, dtype=np.uint64)
    ki = k.astype(np.uint64)
    for i in range(16):
        bits |= ki[:, i] << np.uint64(3 * i)

    out = np.empty((n, 8), dtype=np.uint8)
    out[:, 0] = r0.astype(np.uint8)
    out[:, 1] = r1.astype(np.uint8)
    for b in range(6):
        out[:, 2 + b] = ((bits >> np.uint64(8 * b)) & np.uint64(0xFF)).astype(np.uint8)
    return out


def encode_bc5(img, canales="RG"):
    """Codifica (H,W,4) uint8 a bytes ATI2/BC5: dos bloques BC4 seguidos."""
    ci = {"R": 0, "G": 1, "B": 2, "A": 3}
    a, b = ci[canales[0].upper()], ci[canales[1].upper()]
    px = to_blocks(img).astype(np.uint8)  # (nbloques,16,4)
    ba = encode_bc4_blocks(px[:, :, a])
    bb = encode_bc4_blocks(px[:, :, b])
    return np.concatenate([ba, bb], axis=1).tobytes()


def encode_bc4(img, canal="R"):
    """Codifica (H,W,4) uint8 a bytes ATI1/BC4: un bloque por cada 4x4, un canal."""
    ci = {"R": 0, "G": 1, "B": 2, "A": 3}
    px = to_blocks(img).astype(np.uint8)  # (nbloques,16,4)
    return encode_bc4_blocks(px[:, :, ci[canal[0].upper()]]).tobytes()


def decode_bc4_blocks(data):
    """Inversa de encode_bc4_blocks, solo para verificar. (n,8) uint8 -> (n,16)."""
    n = data.shape[0]
    r0 = data[:, 0].astype(np.int32)
    r1 = data[:, 1].astype(np.int32)
    bits = np.zeros(n, dtype=np.uint64)
    for b in range(6):
        bits |= data[:, 2 + b].astype(np.uint64) << np.uint64(8 * b)
    k = np.empty((n, 16), dtype=np.int64)
    for i in range(16):
        k[:, i] = ((bits >> np.uint64(3 * i)) & np.uint64(7)).astype(np.int64)
    pal = np.empty((n, 8), dtype=np.float64)
    pal[:, 0] = r0
    pal[:, 1] = r1
    for j in range(2, 8):
        pal[:, j] = ((8 - j) * r0 + (j - 1) * r1) / 7.0
    return np.take_along_axis(pal, k, axis=1)


def dilatar(im):
    """Derrama el color de cada isla de UV sobre el fondo sin usar.

    NMS construye 12 mips hasta 1x1, y cada reduccion promedia el borde de la
    isla con lo que tenga al lado. En un atlas de Meshy ese lado es NEGRO: el
    12,34% de la textura del SkrullCrawler es hueco, y la isla mediana solo
    tiene 34 px hasta el borde. A partir del mip 3 el negro ya ha entrado en el
    9,3% de la superficie util, y en el mip 5 en el 46,6%. Ademas el remuestreo
    LANCZOS tiene lobulos negativos, asi que un salto duro de carne a negro
    repica y deja anillos.

    El arreglo estandar: rellenar el hueco con el color del pixel util mas
    cercano, para que no haya salto que promediar. Solo mira el fondo NEGRO
    PURO, que en este asset es exactamente el hueco -medido: 12,34% a 0 y
    12,40% por debajo de 8, o sea una meseta limpia-.
    """
    from scipy import ndimage  # solo aqui: el resto del guion es numpy y PIL

    px = np.asarray(im, dtype=np.uint8)
    fondo = px[..., :3].max(2) == 0
    if not fondo.any():
        print("  --rellenar: no hay fondo negro que rellenar")
        return im
    # EDT mide de lo no-cero a lo cero, asi que los indices que devuelve
    # apuntan al pixel UTIL mas cercano. Los utiles se apuntan a si mismos.
    _, (yi, xi) = ndimage.distance_transform_edt(fondo, return_indices=True)
    print(f"  --rellenar: {fondo.mean() * 100:.2f}% de fondo derramado desde la isla vecina")
    return Image.fromarray(px[yi, xi], "RGBA")


def opcion(nombre, defecto=None):
    """Lee --nombre=valor o --nombre valor de sys.argv."""
    for i, a in enumerate(sys.argv[1:], start=1):
        if a == f"--{nombre}":
            return sys.argv[i + 1]
        if a.startswith(f"--{nombre}="):
            return a.split("=", 1)[1]
    return defecto


def main():
    args = []
    saltar = False
    for i, a in enumerate(sys.argv[1:], start=1):
        if saltar:
            saltar = False
            continue
        if a.startswith("--"):
            saltar = "=" not in a and i + 1 < len(sys.argv) and not sys.argv[i + 1].startswith("--")
            continue
        args.append(a)
    if len(args) < 3:
        raise SystemExit(__doc__)
    src, vanilla, dst = args[0], args[1], args[2]

    tile = int(opcion("tile", 1))
    suma = opcion("suma")
    canales = opcion("canales", "RG")
    canal = opcion("canal", "R")
    invertir = any(a == "--invertir" or a.startswith("--invertir=")
                   for a in sys.argv[1:])
    rellenar = any(a == "--rellenar" or a.startswith("--rellenar=")
                   for a in sys.argv[1:])

    head, width, height, mips, formato = read_dds_header(vanilla)

    tamano = opcion("tamano")
    if tamano:
        # La cabecera se copia del vanilla y con ella vienen sus dimensiones.
        # Subir el atlas exige parchear cuatro campos y NADA mas: formato,
        # flags y el bloque DX10 se quedan como estan.
        #
        #   +12 alto   +16 ancho   +20 linearSize   +28 mips
        #
        # `linearSize` en un formato de bloques es el tamano del mip 0: los
        # bloques de 4x4 por 16 bytes en BC7 y BC5, por 8 en BC4. Y los mips
        # bajan hasta 1x1, o sea log2(N)+1.
        n = int(tamano)
        assert n and n & (n - 1) == 0, f"--tamano {n} no es potencia de dos"
        head = bytearray(head)
        bloque = 8 if formato == "BC4" else 16
        struct.pack_into("<2I", head, 12, n, n)
        struct.pack_into("<I", head, 20, (n // 4) * (n // 4) * bloque)
        struct.pack_into("<I", head, 28, n.bit_length())
        head, width, height, mips = bytes(head), n, n, n.bit_length()

    # RGBA desde el principio: los iconos de UI llevan fondo transparente y
    # convertir a RGB primero lo aplastaba a negro opaco. Un JPG sin alfa entra
    # igual con alfa 255, asi que el flujo de pieles no cambia.
    im = Image.open(src).convert("RGBA")
    if tile > 1:
        w, h = im.size
        sheet = Image.new("RGBA", (w * tile, h * tile))
        for y in range(tile):
            for x in range(tile):
                sheet.paste(im, (x * w, y * h))
        im = sheet
    im = im.resize((width, height), Image.LANCZOS)

    if suma:
        extra = Image.open(suma).convert("RGBA").resize((width, height), Image.LANCZOS)
        base = np.asarray(im, dtype=np.int16)
        mas = np.asarray(extra, dtype=np.int16)
        mez = np.clip(base + mas, 0, 255).astype(np.uint8)
        mez[..., 3] = base[..., 3]  # el alfa no se suma: lo manda el origen
        im = Image.fromarray(mez, "RGBA")

    if invertir:
        # Un mapa de un canal puede venir con el sentido contrario al que espera
        # el shader -rugosidad frente a suavidad-. Esto lo da la vuelta sin
        # tocar el alfa, que no se codifica en BC4 ni en BC5.
        px = np.asarray(im, dtype=np.uint8).copy()
        px[..., :3] = 255 - px[..., :3]
        im = Image.fromarray(px, "RGBA")

    if rellenar:
        im = dilatar(im)

    chunks = []
    w, h = width, height
    for level in range(mips):
        lvl = im if level == 0 else im.resize((w, h), Image.LANCZOS)
        px = np.asarray(lvl, dtype=np.uint8)
        if formato == "BC7":
            chunks.append(encode_bc7_mode6(px))
        elif formato == "BC5":
            chunks.append(encode_bc5(px, canales))
        else:
            chunks.append(encode_bc4(px, canal))
        w, h = max(1, w // 2), max(1, h // 2)

    data = b"".join(chunks)
    with open(dst, "wb") as fh:
        fh.write(head)
        fh.write(data)

    import os

    ref = os.path.getsize(vanilla)
    got = os.path.getsize(dst)
    if formato == "BC7":
        detalle = "BC7"
    elif formato == "BC5":
        detalle = f"BC5 canales {canales.upper()}"
    else:
        detalle = f"BC4 canal {canal[0].upper()}"
    if invertir:
        detalle += ", invertido"
    print(f"{dst}: {got} bytes ({width}x{height}, {mips} mips, {detalle})")
    if width != struct.unpack_from("<I", read_dds_header(vanilla)[0], 16)[0]:
        print(f"vanilla: {ref} bytes  ->  {got}, y DISTINTO A PROPOSITO "
              f"(--tamano {width})")
    else:
        print(f"vanilla: {ref} bytes  ->  "
              f"{'IGUAL' if ref == got else 'DISTINTO (revisar)'}")


if __name__ == "__main__":
    main()
