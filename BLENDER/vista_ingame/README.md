# `vista_ingame/` — ver en Blender lo que hay en el juego

Los tres mapas que el SCUTTLER lleva puestos **ahora mismo**, descodificados a PNG desde los
`.DDS` desplegados en `GAMEDATA\MODS\HT_ScuttlerMesh_PRUEBA11`. Existen porque Blender no lee
bien los tres formatos que usa NMS: **BC7**, **ATI1** y **ATI2**.

Salen del archivo desplegado y no del original, así que **incluyen lo que la compresión les
hizo**. Es lo que se ve en pantalla, no lo que se quiso poner.

| PNG | De dónde sale | Espacio de color en Blender |
|---|---|---|
| `01_color_base.png` | `SKRULLCRAWLER.BASE.DDS` (BC7) | **sRGB** |
| `02_rugosidad.png` | `SKRULLCRAWLER.BASE.MASKS.DDS` (ATI1) | **Non-Color** |
| `03_normal_vanilla.png` | `FREIGHTERFIEND.BASE.NORMAL.DDS` (ATI2) | **Non-Color** |

> **El normal es el del bicho vanilla, y está mal a propósito.** ATI2 guarda solo X e Y; la Z
> se reconstruye como `sqrt(1 - x² - y²)`, que es lo que hace el shader. Ese mapa está pintado
> para las UV del SCUTTLER original, no para las nuestras: es el defecto que queda por
> arreglar, y aquí se puede juzgar sin entrar al juego.

---

## Qué archivo abrir

`../proyectos/scuttler.blend` — es de donde salió la exportación, y el objeto se llama
`polySurface6`, colgado de la raíz `NMS_Scene`. La malla viene de
`asset\Modelos Descomprimidos\ScrullCrawler_max_hd\Meshy_AI_Skullcrawler_0813180805_texture_fbx`.

> **No es `skrullcrawler.blend`.** Ese es la decimación anterior a 6000 triángulos que dejó
> `tools/Decimate-NMSMesh.py`: sin raíz `NMS_Scene`, sin la rotación aplicada y con otras
> medidas. No es lo que corre en el juego.

**Comprueba que es la misma malla que corre en el juego** antes de fiarte de lo que veas.
Con la estadística de la vista 3D (`Overlays ▸ Statistics`), el objeto tiene que dar:

| | En Blender | En el `.GEOMETRY` desplegado |
|---|---:|---:|
| Vértices | **4 820** | 11 357 |
| Triángulos | **9 592** | **9 592** |
| Alto (Y) | **1,851 m** | 1,85 |
| Ancho (X) | 2,637 m | 2,64 |
| Fondo (Z) | 2,768 m | 2,77 |

**Los dos conteos de vértices son correctos a la vez.** NMS guarda un vértice por *esquina de
cara* allí donde la UV o la normal se parten, así que el `.GEOMETRY` trae más que Blender. Lo
que sí tiene que cuadrar exacto son los **triángulos** y las medidas.

Si no cuadra, la malla del `.blend` no es la exportada: reimporta el FBX, aplica **−90° en X y
luego 180° en Y**, y aplica la escala — el exportador de NMSDK escribe coordenadas locales e
ignora `ob.scale`.

La prueba que no admite discusión: el `.GEOMETRY.DATA.MBIN.PC` que salió de este `.blend`
(`BLENDER/CUSTOMMODELS/MODELGROUP/SCUTTLER.GEOMETRY.DATA.MBIN.PC`) y el desplegado en
`GAMEDATA\MODS\HT_ScuttlerMesh_PRUEBA11\…\FREIGHTERFIEND.GEOMETRY.DATA.MBIN.PC` dan el
**mismo md5** (`07512712ca887aa72f98e8eed8dec248`). El `.GEOMETRY.MBIN.PC` no coincide, y es
correcto que no coincida: el desplegado lleva encima el parche de `tools/Patch-NMSGraft.py`.

## Cómo montar el material

El `.blend` **ya trae uno**, `Material.001`, con las cuatro imágenes del asset **empaquetadas
dentro del archivo** (`packed`). Sus rutas externas apuntan a un `model.fbm` que era temporal
del importador de FBX y ya no existe: da igual, abren bien. **No pulses `File ▸ External Data
▸ Unpack` ni «Find Missing Files»**, que es la forma de perderlas.

Trae dos conexiones que no corresponden a lo que hace el juego, y conviene arreglarlas antes
de juzgar nada:

| Conexión que hay | Qué pasa | Qué hacer |
|---|---|---|
| `Baked_BaseColor` (copia **Non-Color**) → **Alpha** | vuelve el bicho translúcido donde el color es oscuro | **quitarla** (clic en el hilo + `X`), Alpha a `1.0` |
| `texture_0_metallic` → **Metallic** | lo pone metálico; el juego **no recibe mapa metálico** | **quitarla**, `Metallic = 0` |

El nodo `Mapa de normales` está conectado al `Normal` del BSDF pero **no le entra ninguna
imagen**: sale plano, que es inofensivo. Es justo el hueco del `gNormalMap` pendiente.

Lo que queda, y es lo que el juego sí usa:

```
Baked_BaseColor      (sRGB)       -> Base Color
texture_0_roughness  (Non-Color)  -> Roughness
Metallic = 0 · Emission Strength = 0
```

Si lo que quieres ver es **lo que hay en pantalla** y no lo que se quiso poner, cambia esas
dos imágenes por los PNG de esta carpeta —llevan encima la compresión— y añade el normal:

```
Image Texture  01_color_base.png     (sRGB)       -> Base Color
Image Texture  02_rugosidad.png      (Non-Color)  -> Roughness
Image Texture  03_normal_vanilla.png (Non-Color)  -> Normal Map -> Normal
Metallic = 0
Emission = 0
```

`Metallic` a **0** y sin emisión: el material del juego no entrega mapa metálico, y sus tres
uniforms de efectos —`gMaterialSFXVec4`, `gMaterialSFX2Vec4`, `gMaterialSFXColVec4`— valen
cero. El tinte `gMaterialColourVec4` está en `(1, 1, 1)`, o sea neutro: no hay que multiplicar
el color por nada.

## Cuatro cosas que Blender **no** te va a reproducir

1. **La luz.** El sombreado de Blender no es el ubershader de NMS. La rugosidad se leerá
   parecida, no idéntica.
2. **No le pongas una luz amarilla verdosa.** El `AttackLight` que el bicho llevaba dentro
   —360°, radio 4,47, color `(0.861, 1, 0)`— está **neutralizado** desde la `PRUEBA10`. Usa un
   HDRI neutro o dos áreas blancas.
3. **El ojo no está.** El injerto perdió el nodo `SUB1polySurface6` con `FFIENDEYEMAT`, y en
   el `.blend` tampoco va a aparecer.
4. **La escala del entorno.** 1,85 m de alto es el bicho; en la penumbra de un carguero se ve
   más pequeño de lo que sugiere el visor.

## La prueba que de verdad vale la pena hacer aquí

**Desconecta y reconecta el nodo `Normal Map`.** La diferencia entre las dos vistas es
exactamente lo que ganaríamos fabricando un normal propio. El asset no trae uno, así que habría
que generarlo del color o del `roughness`, y esa decisión se puede tomar mirando esto en vez de
gastando una sesión de juego.

## Cómo se regeneran estos PNG

Si cambian las texturas desplegadas, se rehacen leyendo los `.DDS` de `GAMEDATA\MODS` con
Pillow y guardando en PNG; el normal necesita además reconstruir la Z. El detalle de por qué
cada mapa es del formato que es está en
[`../../work/scripts/malla/README.md`](../../work/scripts/malla/README.md).
