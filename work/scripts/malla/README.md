# `malla/` — las series `HT_EggMesh` y `HT_ScuttlerMesh`

Geometría nuestra dentro del juego, por la vía Blender + NMSDK. **Dos series, 16 `.lua`**:
cinco de `HT_EggMesh` (el obelisco, Etapa 2) y once de `HT_ScuttlerMesh` (el bicho, Etapa 3).

**Dentro de cada serie los `.lua` escriben los mismos archivos y no pueden convivir**: cada
uno sustituye al anterior. Entre series sí conviven — tocan mallas distintas. En el juego
están la `HT_EggMesh_PRUEBA05` y la `HT_ScuttlerMesh_PRUEBA11`; el resto, en
`GAMEDATA\MODS_Retirados\`.

- El porqué y el plan por etapas: [`../../../docs/ASSETS.md`](../../../docs/ASSETS.md) §4.3
- Carpetas de Blender y la vuelta completa: [`../../../BLENDER/README.md`](../../../BLENDER/README.md)

---

## Los cinco, y qué mide cada uno

| `.lua` | Qué entrega | Pregunta que contesta | Estado |
|---|---|---|---|
| `HT_EggMesh_PRUEBA01` | El huevo vanilla, **ida y vuelta por NMSDK sin tocar un vértice** | ¿El formato de NMSDK `alpha13` carga en NMS 6.45, y la ida y vuelta conserva la malla? | ✅ **pasó el 13/08.** El huevo sale igual que siempre |
| `HT_EggMesh_PRUEBA02` | El **obelisco del marker** en el sitio del huevo | ¿Acepta el conducto geometría nuestra, y no solo la vanilla reciclada? | ✅ **pasó el 13/08.** Primera malla propia en el juego — aunque **le faltaban caras**, y eso no se vio hasta la noche |
| `HT_EggMesh_PRUEBA03` | La misma malla **+ sus texturas**, y el material reapuntado | ¿Se le puede poner textura propia a una malla nuestra? | 🔴 **retirado.** Heredaba la malla incompleta de la `PRUEBA02` |
| `HT_EggMesh_PRUEBA04` | La malla **triangulada y entera** (822 vértices, 1636 triángulos) + las texturas | ¿Sale el obelisco completo, y con su textura? | ✅ **pasó el 13/08** — completo y texturado. Pero salía **de 163 m** |
| `HT_EggMesh_PRUEBA05` | La misma, **con la escala aplicada** | ¿Mide 1,64 m, algo más del doble del huevo vanilla? | 🏁 **pasó el 13/08. Cierra la Etapa 2**: malla completa, tamaño correcto y texturas propias |

> **Dos fallos del exportador, uno escondiendo al otro.** La malla de la `PRUEBA02` y la `03`
> repartía 1098 de sus 1636 triángulos, porque NMSDK toma otro camino cuando hay quads. Y la
> `PRUEBA04` salía 100× grande, porque el exportador escribe coordenadas **locales** e ignora
> `ob.scale`, que en el FBX vale 0.01. Diagnóstico en
> [`../../../BLENDER/README.md`](../../../BLENDER/README.md) §2b; las dos comprobaciones que
> los cazan sin entrar al juego están como asserts en `tools/Export-NMSMesh.py`.

## La serie `HT_ScuttlerMesh` — malla propia en una criatura

Misma carpeta, otra diana: el cuerpo del SCUTTLER de los cargueros
(`SPIDERRIG\FREIGHTERFIEND`) en vez de un prop. El `.SCENE` es el vanilla injertado, así que
el bicho conserva comportamiento, colisión, IA y sonido.

| `.lua` | Qué cambia | Veredicto |
|---|---|---|
| `PRUEBA01` | La malla, con el material vanilla intacto | 🔴 **se estira sin forma.** El juego sí aplica skinning y nuestra malla no trae los canales 5 y 6 |
| `PRUEBA02` | `FFIENDMAT` sin `_F02_SKINNED` | ✅ **entero y rígido.** Hay criaturas propias en el mod |
| `PRUEBA03` | +180° en X | 🔴 **patas arriba.** En X el giro tumba, no gira |
| `PRUEBA04` | −90° X + 180° **Y** | ✅ **de pie y mirando bien.** Decidido con renders, no en partida |
| `PRUEBA05` | `JointExtents` y `JointMirrorPairs` del vanilla devueltos | 🔴 **seguía crasheando.** Los arrays vacíos no eran dos, eran cinco |
| `PRUEBA06` | Los **cuatro** arrays por hueso + `MeshBaseSkinMat` | 🏁 **pasó el 14/08. Cierra la Etapa 3**: el bicho sale entero y **matarlo ya no tira el juego**. Primer injerto validado sin entrar al juego |
| `PRUEBA07` | `SKRULLCRAWLER.BASE.DDS` propia + `gDiffuseMap` reapuntado | 🔴 **sin efecto.** El bicho salió dorado: el difuso no se lee del material |
| `PRUEBA08` | `FREIGHTERFIEND.TEXTURE.MBIN` con las capas vacías | ✅ **pasó el 14/08.** El difuso ya es el nuestro |
| `PRUEBA09` | `AttackLight` con `INTENSITY 0` | 🔴 **tiro perdido.** Un solo campo no apaga ese nodo |
| `PRUEBA10` | `AttackLight` neutralizado entero: radio, caída y color a cero | 🏁 **pasó el 14/08. Cierra el color**: carne roja y cráneo hueso, sin oro |
| `PRUEBA11` | `SKRULLCRAWLER.BASE.MASKS.DDS` propia, ATI1 desde el roughness del asset | 🏁 **pasó el 14/08. Es la configuración buena y de aquí no se retrocede** |
| `PRUEBA12` | **Piel + normal propio.** El buffer a stride 20 con los canales 5 y 6, `_F02_SKINNED` de vuelta en `FFIENDMAT` y el `gNormalMap` propio | ⬜ el `.GEOMETRY` **está hecho y pasa el `Check`**; falta escribir el `.lua` |

> **Las dos cosas de la `PRUEBA12` van en el MISMO `.lua` y las mide una sola entrada al
> juego.** Si sale mal, el `.GEOMETRY` dice cuál de las dos falló sin volver a entrar: el
> bicho estirado sin forma es la piel, el bicho bien plantado y con la textura rara es el
> normal. Los tres `.MBIN` con piel salen de
> `python tools/Skin-NMSGeometry.py work/models/scuttlermesh work/models/scuttlermesh_anim`,
> y **no se entra al juego sin que `tools/Check-NMSGraft.py` dé salida 0**: con los índices de
> hueso fuera de rango el juego cierra sin avisar, y ya pasó en la `PRUEBA05`.

> **La `PRUEBA11` es la línea base.** Siete `ADD_FILES`: el `.SCENE` injertado, los dos
> `.GEOMETRY`, `FFIENDMAT`, las dos `.DDS` propias y la lista procedural vaciada. Cualquier
> prueba nueva **parte de estos siete archivos** y solo cambia lo que vaya a medir.
>
> Quedan **dos mejoras, no dos fallos**, las dos en
> [`../../../docs/PENDIENTES.md`](../../../docs/PENDIENTES.md) §2:
>
> | ID | Qué falta | Por qué se nota |
> |---|---|---|
> | **`M-TEX`** | El `gNormalMap` sigue siendo `FREIGHTERFIEND.BASE.NORMAL.DDS`, del bicho vanilla | Está pintado para las UV del SCUTTLER original: el relieve cae donde no toca. El asset no trae normal, así que hay que generarlo |
> | **`M-ANIM`** | La malla va **rígida**: se desliza en vez de deformarse con el `SPIDERRIG` | `FFIENDMAT` sin `_F02_SKINNED` y sin los canales `SemanticID` 5 y 6. El plan está en `PENDIENTES.md` §2.1 |
>
> **Las dos van en el mismo `.lua`** (`PRUEBA12`): escriben los mismos archivos, así que no
> pueden convivir como mods separados, y así **una sola entrada al juego mide las dos**.
>
> Y falta un tercer detalle, más pequeño: el injerto perdió el nodo `SUB1polySurface6` con
> `FFIENDEYEMAT`, **el ojo**.

### Por qué el color costó cuatro pruebas

**El SCUTTLER no lee su difuso del material: lo compone en runtime.**
`TEXTURES\COMMON\PLAYER\PLAYERCHARACTER\FREIGHTERFIEND.TEXTURE.MBIN` es un
`cTkProceduralTextureList` con las capas `SKIN.1`, `MARKINGS.0/1/2` y `BASEF.1`, todas
pasadas por la paleta `Custom_Head`. Esa composición **pisa el `gDiffuseMap`**, así que
reapuntar el material —la `PRUEBA07`— no hace nada. `Layers` es un array **fijo de ocho**:
vaciarlo deja ocho capas en blanco con `Probability 0`, y entonces sí manda el material.

**Y el `.SCENE` vanilla trae una luz puesta al bicho.** `AttackLight`, colgada del hueso
`NewJawEND`: 360°, `RADIUS` 4.47, color `(0.861, 1.0, 0.0)`, amarillo verdoso. Con la piel
oscura del vanilla no se nota; con nuestros blancos lo vuelve oro. **`INTENSITY 0` no basta**,
porque el nodo lleva `MATERIAL = MATERIALS/LIGHT.MATERIAL.MBIN` y eso dibuja un destello que
no depende de la intensidad. Hay que anular también `RADIUS`, `FALLOFF` y `COL_*`, dejándola
como la `Light_pointLight1` que ya viene inerte en ese mismo archivo.

> **La comprobación que ahorra una prueba: mirar el vanilla primero.** El `.SCENE` original
> trae ese `AttackLight` a `INTENSITY 1.0` y el SCUTTLER vanilla no es dorado. Con ese dato,
> la `PRUEBA09` no habría llegado a construirse.

**Lo que el injerto perdió por el camino:** el vanilla tiene **dos** nodos `MESH`
—`polySurface6` con `FFIENDMAT` y `SUB1polySurface6` con `FFIENDEYEMAT`, que es el ojo— y el
nuestro solo el primero. Pendiente de recuperar.

**Lo que hay que devolver a mano** cuando se injerta en un `.SCENE` vanilla: todo lo que el
vanilla conserva sigue esperando encontrar sus datos en *nuestro* `.GEOMETRY`, y NMSDK **no
escribe ninguno de esos arrays**. La regla, que es lo que importa y no la lista de nombres:

| Va **por hueso** — se copia del vanilla | Va **por malla** — se calcula de la nuestra |
|---|---|
| `JointBindings`, `JointExtents`, `JointMirrorAxes`, `JointMirrorPairs` | `MeshBaseSkinMat` (del `FIRSTSKINMAT` de nuestro nodo) |

Nuestros huesos **son** los del vanilla, sin tocar, así que se corresponden uno a uno. Los de
malla no: el vanilla describe sus mallas, no la nuestra.

`SkinMatrixLayout` se deja **vacío a propósito**: es la paleta de huesos sobre la que se
reparte una malla concreta, y la nuestra va rígida. El nodo lo pide de `FIRSTSKINMAT` 0 a
`LASTSKINMAT` 0 — rango vacío, no lee nada.

> **Los dos fines de rango son exclusivos, pese al nombre.** `BOUNDHULLED` y `LASTSKINMAT`
> son fin exclusivo, no último índice válido: el nodo del ojo vanilla dice `LASTSKINMAT` 23
> sobre 23 entradas. Suponer lo contrario da un falso positivo, y lo cazó el control contra
> el vanilla.

**Las dos herramientas de esta vuelta**, las dos sin entrar al juego:

```
python tools/Patch-NMSGraft.py work/models/scuttlermesh <vanilla .GEOMETRY.MXML>
python tools/Check-NMSGraft.py work/models/scuttlermesh
```

El `Check` cruza cada índice del `.SCENE` contra la longitud del array que lo recibe.
**Pasa con el vanilla intacto y fallaba con la `PRUEBA05`**: por eso vale. Rellenar los
arrays de uno en uno, según iba crasheando, costó dos sesiones de juego.

## Qué escribe cada uno

Los cinco entregan por `ADD_FILES` los mismos tres archivos de malla:

```
MODELS\PLANETS\BIOMES\COMMON\RARERESOURCE\GROUND\FIENDEGG.SCENE.MBIN
                                                \FIENDEGG.GEOMETRY.MBIN.PC
                                                \FIENDEGG.GEOMETRY.DATA.MBIN.PC
```

Las `PRUEBA03`, `04` y `05` añaden dos texturas y **un único cambio de MBIN**:

| Qué | Valor |
|---|---|
| `TEXTURES\…\RARERESOURCE\GROUND\MARKER.BASE.DDS` | BC7 2048² 12 mips — color del marker **con la emisión horneada encima** |
| `TEXTURES\…\RARERESOURCE\GROUND\MARKER.BASE.NORMAL.DDS` | ATI2/BC5 2048² 12 mips — canales `R=X`, `G=Y` |
| `…\GROUND\FIENDEGG\EGGSHELL_MAT.MATERIAL.MBIN` | `gDiffuseMap` y `gNormalMap` reapuntados a las dos de arriba |

Las dos se generan con `tools/Make-NMSTexture.py` y pesan **exactamente lo mismo que sus
donantes vanilla**. Comando exacto y validación en
[`../../../docs/ASSETS.md`](../../../docs/ASSETS.md) §1.4.

## Tres decisiones que conviene no deshacer sin motivo

**El `EGGSHELL_MAT` que se toca es el del huevo de superficie, y solo ese.** Es un archivo
exclusivo suyo: el huevo de cueva (`RARERESOURCE\CAVE\EGGRESOURCE`), el del carguero
(`SPACEBASE\FIENDEGG`) y el de recompensa (`FIENDEGGPARTS\FIENDEGGREWARD`) tienen cada uno su
propia copia. Tocar el de superficie no repinta a los otros tres.

**No se entrega mapa de máscaras.** El vanilla del huevo mide `R` media 179 y `G` media 73,
que no cuadra con la convención «`R` = metalicidad» que circula. Se deja el vanilla hasta
saber qué canal es qué — es `Q-MASCARAS` en
[`../../../docs/PENDIENTES.md`](../../../docs/PENDIENTES.md) §3.

**No se toca el flag `_F21_VERTEXCUSTOM` del material**, aunque nuestra malla no exporte el
canal de color de vértice que ese flag usa. Era la duda `Q-VERTEXCUSTOM`, y la `PRUEBA05` la
cierra: **con la textura propia puesta tampoco aparece ningún tinte raro**, que era el
escenario donde se temía que molestara. Se deja como está.

## Cómo se construye

En `tools/AMUMSS/ModScript/` va sólo la `PRUEBA05`; las demás, en `Disabled scripts and
paks/`. **El build ya corre desatendido** con `tools/AMUMSS/BUILDMOD_AUTO.bat`, que tiene
fijadas las seis opciones que antes preguntaban por consola. Hay que lanzarlo con **codepage
850** y con el `PATH` de Windows. Pasos completos en
[`../../../docs/README.md`](../../../docs/README.md).

**Antes de dar por buena una malla, dos comprobaciones que no necesitan entrar al juego:**
`IndexDataSize == IndexCount * 2` en el `.GEOMETRY` —cazaba la malla incompleta de la
`PRUEBA02`— y que el alto en coordenadas locales de Blender coincida con el `AABB` del
`.SCENE` —cazaba el obelisco de 163 m de la `PRUEBA04`—. Las dos están como asserts en
`tools/Export-NMSMesh.py`.

> `MOD_AUTHOR` es **AldrichDDD** en los cinco, y los `.lua` van **sin comentarios**: la
> explicación vive aquí y en `docs/`.
