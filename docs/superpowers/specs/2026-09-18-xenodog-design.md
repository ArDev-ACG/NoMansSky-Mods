# Diseño — xenodog, alternativa al cryWolf en el `FIEND`

**Fecha:** 2026-09-18 · **Estado:** aprobado, sin implementar

Un modelo nuevo para el hueco `FIEND` / `SPIDERRIG`, a partir de
`asset/Modelos Descomprimidos/alien-xenodog/`. **No releva al cryWolf: convive
con él como alternativa**, igual que los dos huevos.

---

## 1 · Alcance

- Modelo nuevo `xenodog` → `FIEND`, rig `SPIDERRIG`, nodo `_Fiend_Body`.
- Se construye como `HT_Xenodog_PRUEBA01` y se publica como `infestedXenodog`.
- **El cryWolf sigue publicado y no se toca.** Los dos escriben los mismos
  archivos: **no se instalan a la vez**, y sus README lo dicen con el mismo
  bloque de convivencia excluyente que ya usan el markerEgg y el facehuggerEgg,
  generalizado — deja de hablar sólo de huevos.
- **Fuera de alcance:** el mod 2 de infestación y sus cuatro `.lua`.
- **Fuera de alcance:** la feature de noches oscuras, descartada el 2026-09-18.

## 2 · La licencia

**«Alien Xenodog» de p.lindemann5311** (https://skfb.ly/pBBGG), **CC BY 4.0**.
Libre, permite uso comercial, exige crédito. Mismo trato que el cryWolf y el
warriorBug: atribución **dentro del zip y en la página de Nexus**, las dos. Sin
restricciones de Donation Points. Anotado en [`../../credits.md`](../../credits.md).

## 3 · El asset, medido

`source/model.glb`, 59,8 MB. Leído con el parser de glTF el 2026-09-18:

| | |
|---|---|
| Malla | **una sola primitiva, sin nombre** |
| Tamaño | **1 623 582 triángulos, 919 486 vértices** |
| Atributos | `POSITION`, `NORMAL`, `TEXCOORD_0` |
| Esqueleto | **ninguno** — ni `JOINTS_0`, ni `WEIGHTS_0`, ni `skins` |
| Animación | **ninguna** |
| Material | **uno**, sin nombre |
| Texturas | **3** imágenes JPEG embebidas |
| AABB | 1,043 × 1,549 × 1,903 |

Los nombres de las texturas —`gltf_embedded_1@channels=B.jpeg` y
`@channels=G.jpeg`— dicen que **una textura empaquetada se partió por canal** al
exportar. Cuál es color base, cuál normal y cuál máscara **se mira antes de
convertir nada**; no se supone por el número.

## 4 · Las dos diferencias que mandan el trabajo

**1. Hay que decimar 54:1**, de 1 623 582 a los 30 000 del presupuesto del
`FIEND`. Es el mismo orden que el 46:1 que en el necromorfo dejó la piel **a
confeti**, y por eso esto se mide antes de gastar el resto del conducto.

El porqué del confeti está escrito en `Decimate-NMSMesh.py`: las texturas de
Tripo y Meshy vienen **horneadas por triángulo**, una isla de UV por cara, así
que al colapsar, cada cara superviviente muestrea entre islas que ya no son la
suya. **Un escaneo fotogramétrico normalmente no es así**: lleva islas grandes y
UV continuas, que es el caso del warriorBug, que aguantó 3,7:1 sin despeinarse.

**Esto se comprueba, no se asume**, y es la primera tarea del plan: medir la
continuidad de las UV antes de decimar. Si sale horneado por triángulo, el modelo
**no entra** y se dice, en vez de gastar once pasos para descubrirlo en pantalla.

**2. No trae esqueleto, y da igual.** El conducto nunca usa el rig del asset: pesa
nuestra malla contra el esqueleto **vanilla** del `FIEND` (`Weight-NMSMesh.py`).
Que el cryWolf trajera huesos propios tampoco sirvió de nada. Lo único que se
pierde es la rama B —retargetear una animación propia—, que en el cryWolf ya se
había medido **peor** (`PRUEBA06`) y que aquí ni existe.

## 5 · La cola, que es la razón de que este modelo exista

El `FIEND` vanilla tiene **6 huesos de cola** y **los mueve**. Medido con
`Sway-NMSJoint.py` sobre `fiend.scene.MXML` el 2026-09-18, giro de mundo en grados:

| hueso | `fiendidle` | `fiendfastwalk` | `fiendattack` |
|---|---:|---:|---:|
| `NewTail1JNT` | 3,0 | 13,9 | 23,9 |
| `NewTail2JNT` | 4,4 | 22,7 | 28,9 |
| `NewTail3JNT` | 6,1 | 29,8 | 33,9 |
| `NewTail4JNT` | 7,9 | 35,0 | 38,9 |
| `NewTail4JNT_2` | 9,7 | 37,9 | 44,0 |
| `NewTail5JNT` | 11,5 | **38,7** | **45,4** |

Latigazo creciente hacia la punta, en los tres clips, ya en el juego y gratis.

**Y el cryWolf no lo aprovecha.** Su mapa de `regiones` en `Weight-NMSMesh.py` no
nombra ni un `NewTail*JNT`: su grupa y su cola caen en el `("RootJNT", True)` del
final, y `RootJNT` gira 2,4° / 4,1° / 18,9°. Por eso el cryWolf va con la cola
muerta.

**El xenodog sí los nombra.** Esa es la diferencia visible entre los dos modelos
del hueco, y la razón de que el xenodog sea una alternativa con sentido y no un
capricho. Los cortes salen del **histograma de nuestra malla** en coordenadas
normalizadas, medidos con `--volcar-huesos`, **no se eligen**.

## 6 · Un cambio de herramienta, obligado

`tools/Decimate-NMSMesh.py` importa **sólo FBX** (`bpy.ops.import_scene.fbx`,
línea 113) y el xenodog es `.glb`. Se despacha por extensión: `.glb`/`.gltf` →
`bpy.ops.import_scene.gltf`. **Es el único cambio de código del plan** y toca una
función; los modelos que ya entran por FBX no cambian de comportamiento.

Presupuesto: **30 000**, el mismo que el cryWolf, heredado del `FIEND` vanilla
(36 590 triángulos) y limitado de verdad por el formato — `Indices16Bit=1`, o sea
65 535 vértices como mucho, y el exportador además parte vértices.

**No hace falta `Atlas-NMSMesh.py`:** un material, una malla.

## 7 · El pesado

Entrada `xenodog` en `tools/Weight-NMSMesh.py`:

| clave | valor | por qué |
|---|---|---|
| `vanilla` | `work/models/vanilla_fiend/.../fiend.scene.mbin` | el mismo del cryWolf |
| `objeto` | `_Fiend_Body` | nodo de malla del `FIEND` |
| `giro_z` | de arranque `180`; **se re-mide** | el assert de «boca abajo» es el que corta |
| `espejo` | `("L", "R")` | el `SPIDERRIG` usa L/R al principio |
| `escala_piel` | `1.0` | nuestra malla no mide lo que el esqueleto vanilla |
| `tope_reparto` | de arranque `0.85`; **se re-mide** | |
| `regiones` | **a mano, con los `NewTail*JNT` dentro** | §5 |
| `agarre` | patas delanteras y cabeza al pecho, traseras a la cadera | como el cryWolf |
| `sin_claves` | de `Sway-NMSJoint.py` sobre **los 22 clips** | no se suponen |

De los tres clips ya medidos salen **quietos**: `GlobalCTRLJNT`, `NewBack1JNT`,
`NewBack2JNT`, `NewBack3JNT`, `RPincer4JNT`, `LPincer4JNT`, `RPincer6END`,
`LPincer6END`, `NewJawEND`. La lista definitiva sale de los 22.

## 8 · Los parámetros de `Export-NMSMesh.py`

| clave | valor | por qué |
|---|---|---|
| `salida` | `BLENDER\FIEND` | |
| `nodo` / `escena` | `_Fiend_Body` / `FIEND` | |
| `material` | `MODELS\PLANETS\CREATURES\SPIDERRIG\FIEND\FIEND_MAT.MATERIAL.MBIN` | |
| `giro` | `(-90, 180)` **de arranque** | el del cryWolf, mismo hueco y mismo rig |
| `alto` | `2.850` **de arranque** | el único valor de este hueco **elegido en partida** |
| `pose` | **ninguna** | el doblez de cuello era un defecto del asset del cryWolf |

Los tres se re-miden con el volcado.

## 9 · Verificación, sin entrar al juego

1. `Check-NMSGraft.py` **antes** de construir.
2. `Flag-NMSMaterial.py` → `_F02_SKINNED`.
3. `Check-NMSGraft.py` **otra vez**: el paso de piel borra el flag.
4. **`Pose-NMSMesh.py`**, que deforma nuestra malla con los clips del vanilla sin
   arrancar NMS. Aquí es donde se mira **si la cola se mueve**, antes de gastar
   una sesión de partida.
5. **Plantilla 7.x:** `.SCENE` compilado con **MBINCompiler 7.02**, y el stream de
   vértices **stride 16 / `sem11`** vía `Repack-NMSVertex.py`.
6. Bytes `0x18`/`0x19` del `.MBIN` = `07 02`; hash de plantilla en `0x10..0x17`.

## 10 · Publicación

Entra en `Package-SinFuente.ps1` como `infestedXenodog`, y **el cryWolf y el
xenodog pasan los dos** al bloque de convivencia excluyente que hoy usan los
huevos. Ese bloque se generaliza: deja de hablar de huevos y pasa a decir «elige
uno de los que ocupan este hueco».

Versión: **`models-0.1.3`**, con los seis. La `0.1.2` no se re-empaqueta.

## 11 · Documentación

- Ficha nueva `docs/MODELOS/xenodog.md`, con el formato de las otras.
- `docs/MODELOS/cryWolf.md` ya dice que el xenodog es alternativa, no relevo.
- `docs/MODELOS/README.md`: el xenodog entra en la tabla al publicarse.

## 12 · Criterio de aceptación

1. **Puerta previa:** las UV del asset **no** están horneadas por triángulo. Si lo
   están, el modelo se descarta aquí y se dice por qué.
2. `Check-NMSGraft.py` pasa las dos veces.
3. `Pose-NMSMesh.py` enseña la cola moviéndose en `fiendfastwalk` y `fiendattack`.
4. En partida: **opaco** (no traslúcido) y el juego **no cierra** al empezar
   partida nueva.
5. `RootJNT` por debajo del tope de reparto.
6. Instalado junto al cryWolf, el jugador ve uno solo y el README se lo avisó.
