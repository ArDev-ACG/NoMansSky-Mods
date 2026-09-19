# Diseño — xenoCuadripedo releva al cryWolf en el `FIEND`

**Fecha:** 2026-09-18 · **Estado:** aprobado, sin implementar

Un modelo nuevo para el hueco `FIEND` / `SPIDERRIG`, a partir del asset
`asset/Modelos Descomprimidos/xeno-cuadripedo/`. Se construye como `PRUEBA01`
y **convive con el cryWolf** hasta verlo en partida.

---

## 1 · Alcance

- Modelo nuevo `xenocuadripedo` → `FIEND`, rig `SPIDERRIG`, nodo `_Fiend_Body`.
- Se despliega como `HT_XenoCuadripedo_PRUEBA01`, **sin tocar `releases/models-0.1.1`**.
- El cryWolf sigue publicado. Escriben los mismos archivos: **no se instalan a la vez**.
- **Fuera de alcance:** el mod 2 de infestación y sus cuatro `.lua`. Esto es un mod
  de malla, como los otros cuatro.
- **Fuera de alcance:** la feature de noches oscuras (Natural Nights). Descartada el
  2026-09-18 por riesgo de afectar demasiado; no se toca ningún archivo de iluminación.

## 1 bis · La licencia, que condiciona la publicación

El asset es **«Xeno Animation» de LostBoyz2078** (https://skfb.ly/oG69A), **CC BY-NC 4.0**.

**Es el primer asset NonCommercial del repo**: los otros cinco son `CC BY` o `CC BY-SA`, que
sí permiten uso comercial. El NC **se contagia al derivado**, o sea que el `xenoCuadripedo`
entero —sus `.MBIN` y sus `.DDS`— sale bajo NC.

Lo que eso obliga, y **se decide antes de construir**:

- Descarga gratuita en Nexus: **encaja**, publicar gratis no es uso comercial.
- **Donation Points y donaciones: hay que apagarlos** en la página de ese mod, o conseguir
  permiso expreso de LostBoyz2078. Los DP son compensación monetaria por descargas y es
  defendible que sean uso comercial de una obra NC.
- El zip **no puede** declararse de libre reutilización comercial ni relicenciarse más
  permisivo.
- La atribución va **dentro del zip y en la página**, como los otros.

Esto **no toca a `models-0.1.2`**: ninguno de los cinco usa este asset. Detalle en
[`../../credits.md`](../../credits.md).

## 2 · El asset, medido

`source/Xeno animation.glb`, 3,9 MB. Leído con el parser de glTF el 2026-09-18:

| | |
|---|---|
| Malla | `Xeno_Brute` — **23 118 triángulos, 13 450 vértices**, una sola primitiva |
| Material | **uno**, `MI_Xenos_Brute`: base color + normal. **Sin atlas** |
| Texturas | `textures/gltf_embedded_0.jpeg` (base color), `gltf_embedded_1.jpeg` (normal) |
| Atributos | `POSITION`, `NORMAL`, `TEXCOORD_0`, `JOINTS_0`, `WEIGHTS_0` |
| Esqueleto | **90 huesos**, `XenosRunnerRig_*SHJnt` |
| Cola | **`RRM_Tail_Parent_01..15SHJnt`** (15) + `Blade_SHJnt` |
| AABB | x 100,4 · y 125,1 · z 315,4 → **largo/alto ≈ 2,5 : 1** |
| Animación | **una sola**, `idle`, 4,1 s, 124 fotogramas, 73 canales sobre 66 nodos |

Los 15 huesos de cola **sí** están animados en el `idle`; `Blade_SHJnt` **no**.

**El 2,5:1 es el dato que manda el pesado.** El `FIEND` es 3,5:1 y el cryWolf era
1,1:1. El xeno cae mucho más cerca del bicho al que sustituye, que es justo lo
que en el cryWolf obligó al mapa a mano y aun así dejó a `RootJNT` con el 62,8 %.

## 3 · Por qué NO se mete la animación del asset

La decisión de partida fue conservar su animación, porque **lo que importa es la
cola**. Se midió y la respuesta cambió.

**El `FIEND` vanilla ya tiene cola y ya la menea.** `Sway-NMSJoint.py` sobre
`fiend.scene.MXML` y tres clips, el 2026-09-18:

| hueso | `fiendidle` | `fiendfastwalk` | `fiendattack` |
|---|---:|---:|---:|
| `NewTail1JNT` | 3,0° | 13,9° | 23,9° |
| `NewTail2JNT` | 4,4° | 22,7° | 28,9° |
| `NewTail3JNT` | 6,1° | 29,8° | 33,9° |
| `NewTail4JNT` | 7,9° | 35,0° | 38,9° |
| `NewTail4JNT_2` | 9,7° | 37,9° | 44,0° |
| `NewTail5JNT` | 11,5° | **38,7°** | **45,4°** |

Latigazo creciente hacia la punta, en los tres clips, y ya está en el juego.

El asset trae **un** clip y NMS pide **22 rutas** en el `.ENTITY`. Meter su `idle`
daría cola propia **parado** y vanilla en andar, correr, atacar, morir y
enterrarse — o sea empeoraría el caso que más se ve, a cambio del trabajo de
`Retarget-NMSRig.py`, que en la `PRUEBA06` del cryWolf **se construyó, se midió y
salió peor**.

**Lo que decide si la cola se mueve no es la animación, es el pesado.**

## 4 · Un cambio de herramienta, obligado

`tools/Decimate-NMSMesh.py` importa **solo FBX** (`bpy.ops.import_scene.fbx`,
línea 113) y el xeno es `.glb`. Se despacha por extensión: `.glb`/`.gltf` →
`bpy.ops.import_scene.gltf`. **Es el único cambio de código del plan** y toca una
función; los modelos que ya entran por FBX no cambian de comportamiento.

**No se decima.** 23 118 triángulos contra los 36 590 del `FIEND` vanilla y contra
el techo real del formato, que son los 65 535 vértices de `Indices16Bit=1`. Entra
entero, como el facehuggerEgg.

**No hace falta `Atlas-NMSMesh.py`:** un material, un par D/N. El paso 0b se salta.

## 5 · El pesado, que es donde vive la cola

En `tools/Weight-NMSMesh.py`, entrada `xenocuadripedo`:

| clave | valor | por qué |
|---|---|---|
| `vanilla` | `work/models/vanilla_fiend/.../fiend.scene.mbin` | el mismo del cryWolf |
| `objeto` | `_Fiend_Body` | nodo de malla del `FIEND` |
| `giro_z` | `180` | de arranque, del cryWolf; **se re-mide en el volcado** |
| `espejo` | `("L", "R")` | el `SPIDERRIG` usa L/R al principio |
| `escala_piel` | `1.0` | nuestra malla no mide lo que el esqueleto vanilla |
| `tope_reparto` | de arranque `0.85`; **se re-mide** | el xeno es cuadrúpedo como el `FIEND`, así que puede no hacer falta |
| `regiones` | **a mano, y el tramo de cola es obligatorio** | ver abajo |
| `sin_claves` | de `Sway-NMSJoint.py` sobre **los 22 clips** | no se suponen |

**El mapa 15 → 6 de la cola es el corazón de este modelo.** Si se deja por
vecindad, la cola entera cuelga de `RootJNT` —que en los clips gira 2,4°/4,1°/18,9°—
y en pantalla se lee muerta. Los cortes salen del **histograma de nuestra malla**
en coordenadas normalizadas, medidos con el volcado, **no se eligen**. Es
literalmente el error que el cryWolf pagó.

`Blade_SHJnt` va con el último tramo (`NewTail5JNT`): en el asset tampoco tiene
claves, así que no aporta movimiento propio.

De los tres clips ya medidos salen **quietos**: `GlobalCTRLJNT`, `NewBack1JNT`,
`NewBack2JNT`, `NewBack3JNT`, `RPincer4JNT`, `LPincer4JNT`, `RPincer6END`,
`LPincer6END`, `NewJawEND`. La lista definitiva se saca de los 22.

## 6 · Los parámetros de `Export-NMSMesh.py`

Entrada `xenocuadripedo`, con `origen`/`objeto` (viene de `Decimate-`, eje alto en
Z de Blender), no con `fbx`:

| clave | valor | por qué |
|---|---|---|
| `salida` | `BLENDER\FIEND` | |
| `nodo` / `escena` | `_Fiend_Body` / `FIEND` | |
| `material` | `MODELS\PLANETS\CREATURES\SPIDERRIG\FIEND\FIEND_MAT.MATERIAL.MBIN` | |
| `giro` | `(-90, 180)` **de arranque** | el del cryWolf, mismo hueco y mismo rig |
| `alto` | `2.850` **de arranque** | el único valor de este hueco **elegido en partida**, no en la mesa |
| `pose` | **ninguna** | el doblez de cuello del cryWolf era un defecto de postura de *aquel* asset; a éste no se le inventa uno sin mirarlo |

Los tres son de arranque y se re-miden con el volcado.

## 7 · Verificación, sin entrar al juego

1. `Check-NMSGraft.py` **antes** de construir.
2. `Flag-NMSMaterial.py` → `_F02_SKINNED`.
3. `Check-NMSGraft.py` **otra vez**: el paso de piel borra el flag.
4. **Plantilla 7.x**, que es lo que costó la `0.1.1`: el `.SCENE` se compila con
   **MBINCompiler 7.02** (`TkSceneNodeData` con `InstanceTransforms`), y el stream
   de vértices va **stride 16 / `sem11`**, no el stride 20 de 6.45. Lo hace
   `Repack-NMSVertex.py`.
5. Byte `0x18`/`0x19` del `.MBIN` = `07 02`, y el hash de plantilla en `0x10..0x17`.

## 8 · La rama B, si la cola se lee muerta

`PRUEBA02` con `Retarget-NMSRig.py` sobre el `idle` de 4,1 s del asset. Cubriría
**un** clip de 22 y el precedente `PRUEBA06` salió peor. **Se decide con el bicho
delante, no ahora.**

## 9 · Documentación

- Ficha nueva `docs/MODELOS/xenoCuadripedo.md`, con el formato de las otras: qué
  es, a quién sustituye, cómo se hizo, qué salió mal.
- `docs/MODELOS/cryWolf.md` gana la línea de quién lo releva y desde cuándo, como
  `markerEgg.md` con el facehuggerEgg.
- `docs/MODELOS/README.md`: el xeno entra en la tabla cuando se publique, no antes.

## 10 · Criterio de aceptación

`PRUEBA01` está hecha cuando:

1. `Check-NMSGraft.py` pasa las dos veces.
2. El bicho se ve **opaco** en partida (no traslúcido: el fallo del vértice 7.x).
3. El juego **no cierra** al empezar partida nueva (el fallo del `.SCENE` 7.0).
4. La cola **se mueve al correr y al atacar**, que es lo que se pidió.
5. Ningún hueso con más peso del que le toca: `RootJNT` por debajo del tope.

Si 1-3 pasan y 4 no, se abre la rama B del §8.
