# Receta: poner piel a una malla propia

**Para qué sirve:** para que una malla nuestra deje de ir rígida y se mueva con el esqueleto
del bicho vanilla al que sustituye. No se anima nada: el esqueleto y sus animaciones ya están
en el juego. Lo que falta es **pegar nuestra malla a esos huesos**.

Esta receta salió de hacerlo entero con el **SkrullCrawler** el 2026-08-15. Está escrita para
repetirla con los otros tres modelos sin volver a investigar nada.

Actualizado: **2026-09-05**, con la segunda hornada —el **warrior bug** y el **cry wolf**— que
sustituye a los dos bípedos y que **enseñó cuál era la causa de fondo de las dieciocho pruebas
anteriores**. Está en §3, «la altura: la malla no puede subir por encima del esqueleto».

---

## 0 · Qué cambia por modelo y qué no

Casi todo está automatizado. Lo que hay que decidir en cada modelo nuevo son **ocho cosas**:

| Qué | Dónde se pone | Cómo se decide |
|---|---|---|
| El `.blend` y el nombre del objeto | `BLEND` y `NUESTRA` en `tools/Weight-NMSMesh.py` | Se saben |
| El bicho vanilla al que sustituye | `VANILLA` en el mismo archivo | El que ya usa el mod |
| **`GIRO_Z`** | Igual | §3. **No se adivina, se mide** |
| **`espejo`** | Igual | Los dos trozos de nombre que distinguen izquierda de derecha. El `SPIDERRIG` usa `L`/`R` al principio y el `ARTHROPOD` usa `_L`/`_R` en medio. Lo consume el assert de simetría, que es **el que de verdad corta** |
| **`escala_piel`** | Igual | `"altura"` **sólo** si nuestra malla mide lo mismo que el bicho vanilla. Si no, **`1.0`**. Ver §3, «la escala del pesado» |
| **`tope_reparto`** | Igual | `None` si nuestro bicho es del mismo tipo de animal que el vanilla; un número absoluto —**0.85**— si es un bípedo montado en una araña. Ver §3 |
| **`regiones`** | Igual | **El mapa a mano región → hueso.** Sin él se copia del vecino más cercano, que sólo vale entre dos bichos del mismo tipo de animal. Sale del volcado, no de suponer. Ver §3, «el mapa a mano» |
| **`sin_claves`** | Igual | Los huesos de la paleta **sin ni una clave en ningún `.ANIM`**. Se leen del `.ANIM` del bicho, no se suponen. Es lo que impide colgar un miembro de un hueso que no gira: la `PRUEBA05`. Ver §3, «estar en el `SkinMatrixLayout` no quiere decir que el hueso se mueva» |

Todo lo demás —el stride, los offsets, la paleta, el casado, la comprobación— no lo toca nadie.

---

## 1 · El problema, en una frase

Cada vértice de nuestra malla ocupa **8 bytes**: normal y tangente. No hay sitio para «de qué
hueso cuelgo y cuánto». El vanilla ocupa **20**: los mismos 8, más 4 de índice de hueso
(canal 5) y 8 de peso (canal 6).

| SemanticID | Qué es | `Type` | Bytes | `Offset` |
|---:|---|---:|---:|---:|
| 2 | normal | 36255 (`INT_2_10_10_10_REV`) | 4 | 0 |
| 3 | tangente | 36255 | 4 | 4 |
| **5** | **índice de hueso** | **5121 (`UNSIGNED_BYTE`)** | **4** | **8** |
| **6** | **peso de hueso** | **5131 (`HALF_FLOAT`)** | **8** | **12** |

O sea: abrir 12 bytes por vértice y llenarlos.

---

## 2 · Los seis pasos

```
1. Extraer el vanilla del .pak                          una vez por bicho
2. tools/Weight-NMSMesh.py       -> pesos.json          Blender, sin interfaz
3. tools/Skin-NMSGeometry.py     -> carpeta _anim       sin Blender
4. tools/Check-NMSGraft.py       -> pasa o no pasa      ANTES de construir
5. _F02_SKINNED en el .MATERIAL  -> Flag-NMSMaterial      el ultimo, siempre
6. tools/Check-NMSGraft.py       -> OTRA VEZ              el paso 3 borro el flag
```

> **Antes de la piel hay que meter la malla, y eso son otros cinco pasos.** Con el
> SkrullCrawler se hicieron a mano y costaron once pruebas; con el necromorfo, el
> 2026-08-20, quedaron automatizados. La malla **rígida** es una entrada al juego que se
> mide sola, y solo cuando pasa se le pone la piel encima.
>
> ```
> 0a. tools/Decimate-NMSMesh.py    -> .blend         FBX unido, triangulado y decimado
> 0b. tools/Atlas-NMSMesh.py       -> _atlas.blend   SOLO si el modelo trae varias texturas
> 0c. tools/Export-NMSMesh.py -- <modelo>            gira, escala, asienta y exporta
> 0d. tools/Graft-NMSScene.py      -> carpeta        el .SCENE vanilla con nuestra malla
> 0e. tools/Patch-NMSGraft.py      -> .GEOMETRY      los cuatro arrays por hueso, del vanilla
> 0e-bis. ...--bind <ANIM>#<fot>   -> .GEOMETRY      el bind, SI nuestra postura no es la del vanilla
>     y despues recompilar el .GEOMETRY.MXML, que Patch- deja solo el XML
> ```
>
> **Y las tres texturas, que van aparte y no dependen de la piel:**
>
> ```
> tools/Bake-NMSNormal.py    -> .NORMAL.PNG   el relieve, HORNEADO del alto poly
> tools/Make-NMSNormal.py    -> .NORMAL.PNG   apaño: lo saca de la luminancia
> tools/Make-NMSMasks.py     -> .MASKS.PNG    el brillo, si el asset no trae rugosidad
> tools/Make-NMSTexture.py   -> .DDS          codifica BC7 / ATI2 / ATI1
> ```
>
> **`Bake-` antes que `Make-NMSNormal`, siempre que haya alto poly.** El de la luminancia
> convierte la pintura en bultos y no puede inventar lo que el atlas no tiene: en el warrior
> bug daba desviación **2,3** contra los 17,2 del vanilla, y horneado del `.fbx` de 133 108
> triángulos da **20,1**. Ver `0.6.9` en [`CHANGELOG-MOD2.md`](CHANGELOG-MOD2.md).
>
> ⚠️ **Una máscara plana es lo que se ve como plástico**, y no lo arregla cambiarle el nivel:
> lo que le falta es **variación**. El vanilla varía ±30 alrededor de su media.
>
> ⚠️ **Y el fondo sin usar del atlas se queda a 0 en las máscaras**, se derrama después con
> `--rellenar`. Invertir o normalizar el atlas entero manda ese fondo a brillo alto y sangra
> por los mips: le pasó al cry wolf, con el 50,1 % de su atlas a 255.
>
> Lo que hay que decidir por modelo en el `0c` son **el giro y la altura**, y los dos se
> miden en el AABB del bicho vanilla, no se adivinan:
>
> | | Cómo se saca |
> |---|---|
> | **La altura** | `AABBMAXY − AABBMINY` del nodo de malla vanilla. La escala es **uniforme** y sale de ahí: encajar los tres ejes deforma, porque el vanilla arrastra cola o patas largas |
> | **El giro** | Al importar con NMSDK, `Y_blender = −Z_nms`. Se mira dónde cae la cabeza del vanilla en Blender y se gira la nuestra hasta que coincida. El FIEND la tiene en `+Y` de Blender, o sea mirando a `−Z` de NMS |
>
> Y la malla se **asienta**: pies en `Y 0`, centrada en X y en Z. El FBX trae su propio
> origen y sin esto la criatura sale flotando o hundida, y descolocada respecto a la
> colisión, que es la del vanilla y no se toca.

### Paso 1 — extraer el vanilla

```
tools/AMUMSS/MODBUILDER/hgpaktool.exe -U -f "*NOMBREDELBICHO*"
```

De `NMSARC.EntitySceneMBIN.pak`, `MeshPlanetCREATURES`, `MetadataEtc` y `AnimMBIN`.

> **La carpeta tiene que repetir la ruta interna de la escena.** El importador de NMSDK lo
> exige (`import_scene.py:220`, `base_path`). Por eso el FreighterFiend está en
> `work/models/vanilla_freighterfiend/models/planets/creatures/spiderrig/`.
>
> ⚠️ **Y hacen falta los `.MBIN.PC` del `.GEOMETRY`, no sólo el `.SCENE`.** El importador abre
> `<bicho>.geometry.mbin.pc` y `<bicho>.geometry.data.mbin.pc` por su cuenta. El BUGFIEND se
> extrajo el 21/08 sin ellos y `M4-PIEL` se quedó parado ahí el 26/08.

### Paso 2 — los pesos

```
"C:\Program Files\Blender Foundation\Blender 5.2\blender.exe" --background --python tools/Weight-NMSMesh.py
```

Deja `pesos.json` al lado de la malla: una entrada por vértice, `[x, y, z, [[hueso, peso], …]]`.

**Se pesa COPIANDO LA PIEL DEL VANILLA, no midiendo distancias a los huesos.** Han fallado dos
métodos antes que éste y los dos con el mismo síntoma en partida —*«láminas planas tensadas»*—.
El detalle entero está en §3; en corto, son tres pasos:

```
1. candidatos = SkinMatrixLayout del .GEOMETRY vanilla    los huesos a los que
                                                          el juego SI pega piel
2. cada vertice promedia los 8 vecinos de la piel vanilla, peso 1/distancia
3. 12 pasadas de promedio por las aristas de NUESTRA malla
```

**Lo que tiene que salir, y si no sale hay que parar:**

```
vertices con peso: N de N                    <- N de N o hay fallo de alineacion
la piel del vanilla se pega a K huesos       <- 19 en el SPIDERRIG, 40 en el
                                                FIEND, 29 en el ARTHROPOD
asignaciones: ~2 por vertice                 <- si sale ~1, el suavizado no corrio
                                                de 4 ranuras; ver §3, las ranuras
el vanilla con su propia piel: mayor X%, asimetria A
nuestra asimetria B contra A del vanilla     <- LA QUE CORTA. Ver §3
```

**Los topes se comparan contra el vanilla, medido en la misma corrida, no contra números a ojo.**
Por eso valen igual para los tres esqueletos sin tocar nada.

> ⚠️ **El importador de NMSDK escupe un error de material (`realize_path` con una textura
> `None`), y NO es inofensivo: aborta la escena y se come las mallas que faltaban.** Está
> anulado desde el 27/08 en `_callar_materiales()`. Ver §3.

### Paso 3 — coser

```
python tools/Skin-NMSGeometry.py work/models/<malla> work/models/<malla>_anim
```

No toca la carpeta de origen: copia y trabaja sobre la copia. Aborta solo si la malla no
viene a stride 8 o si ya está cosida, y dice exactamente qué pasa.

### Paso 4 — comprobar

```
python tools/Check-NMSGraft.py work/models/<malla>_anim
```

**Nada de construir ni desplegar hasta que esto pase.** Ver §4.

### Paso 5 — el flag, y volver a correr el paso 4

```
python tools/Flag-NMSMaterial.py work/models/<malla>_anim/<X>.MATERIAL.MBIN --poner _F02_SKINNED
python tools/Set-NMSSampler.py   work/models/<malla>_anim/<X>.MATERIAL.MBIN --ver
python tools/Check-NMSGraft.py   work/models/<malla>_anim        <- OTRA VEZ, y ahora sí
```

`_F02_SKINNED` de vuelta en el `.MATERIAL`. **El último siempre**, porque es el que convierte un
error de datos en un cierre del juego.

> 🔴 **Y NO SE SALTA NUNCA, ni «si ya estaba puesto».** El paso 3 **copia la carpeta de origen
> entera**, y la de origen **no** lleva el flag: cada re-cosido lo borra en silencio, junto con
> cualquier sampler reapuntado. Saltárselo costó la `PRUEBA05` de los dos bípedos. Ver §3.
>
> Por eso el paso 4 se corre **dos veces**: antes de poner el flag, para los índices, y después,
> para el material. La segunda es la que autoriza a construir.

---

## 2b · 🔴 La vía muerta: `Retarget-NMSRig.py`. **No la uses**

`tools/Retarget-NMSRig.py` existe, está entera y funciona, y **no está en la receta a
propósito**. Se escribió el **04/09** para el cry wolf: reescribe los nueve `.ANIM` del vanilla
como delta contra el fotograma 0 de `idle` aplicado sobre **nuestro** reposo, y calcula el bind
con ellos.

**Se construyó como `HT_CryWolf_PRUEBA06`, se desplegó, se midió y salió PEOR.** Se retiró el
mismo día. La `PRUEBA07` —la que está en el juego y está congelada por `B16`— resuelve lo mismo
**sin escribir un solo `.ANIM`**: con `--bind <ANIM>#<fotograma>` de
[`../tools/Patch-NMSGraft.py`](../tools/Patch-NMSGraft.py), y su `.SCENE` va byte a byte el de
la `PRUEBA05`.

| | `Retarget-NMSRig.py` (vía muerta) | `--bind ANIM#fot` (la buena) |
|---|---|---|
| Qué escribe | los **nueve** `.ANIM` **y** el `.SCENE` | **44 matrices** y nada más |
| Superficie de fallo | nueve archivos de animación reescritos | una constante por hueso |
| Resultado medido | **peor** que la `PRUEBA05` | tensión 34,85 → **18,22** |

**La lección, que es la que hay que llevarse:** el problema era el **bind**, no los clips. Un
clip guarda una pose absoluta por fotograma, así que la tentación de reescribirlos es fuerte —
pero el bind es una sola matriz por hueso y el clip son nueve archivos. **Si las dos vías
arreglan lo mismo, gana la que escribe menos.** Ver `B15` en [`ACUERDOS.md`](ACUERDOS.md).

---

## 3 · Las trampas que costaron una sesión cada una

### El index buffer: NMSDK escribe el de **antes** de partir los vértices

**Sale en los tres modelos y no se ve hasta que entras al juego.** `mesh_parser` **sí** parte
bien los vértices de costura —uno por cada combinación de vértice y UV— y devuelve **dos**
listas de índices: `indexes`, ya remapeada, y `np_indexes`, que es
`data.loops.foreach_get("vertex_index")` y por tanto la de **antes** de partir. Y `export.py`
serializa **la segunda**.

Los vértices partidos entran al buffer y **no los apunta nadie**. Cada vértice de costura se
queda con la **primera** UV que le tocara, que en un atlas de Meshy —cientos de islas
diminutas— es de otra isla cualquiera. Medido el 24/08 sobre lo que estaba desplegado:

| | Vértices | Muertos | Aristas de UV por encima de 0,10 | Corr. UV ↔ 3D |
|---|---:|---:|---:|---:|
| SkrullCrawler | 11 357 | **6 537** | **30,89 %** | 0,044 |
| Necromorfo | 59 384 | **43 336** | **30,30 %** | −0,147 |
| Zombie | 31 475 | **13 496** | **13,67 %** | 0,035 |

**La malla en 3D sale perfecta**, porque los índices bajos sí apuntan a las posiciones buenas.
Sólo se rompe la piel. Por eso el síntoma es «bien plantado y la textura a remolinos», y por
eso se diagnosticó tres veces mal —UV, presupuesto de triángulos, máscaras— antes de mirar el
index.

**Ya está arreglado en `tools/Export-NMSMesh.py`**, que parchea `Exporter.mesh_parser` desde
fuera —el addon vive en `AppData` y se pierde al reinstalarlo— y de paso escribe las normales
**de Blender** en vez de `poly.normal`, que es la normal de **cara** de la primera cara que
tocó el vértice: 21,6° de error mediano y un 2,7 % de vértices al revés, contra 8,1° y 0,52 %.

El guion trae el `assert` que lo caza sin entrar al juego: si una arista de UV cruza más del
10 % del atlas, el export **revienta**. El límite está medido — los FBX de Meshy no pasan de
0,06.

> **Rehacer cualquiera de los tres es una orden**, y después el resto de la receta:
>
> ```
> blender.exe --background --python tools/Export-NMSMesh.py -- <modelo>
> ```
>
> ⚠️ **Si Blender revienta con `EXCEPTION_ACCESS_VIOLATION` en vez de dar un error,
> mira la preferencia `mbincompiler_path` del addon NMSDK.** Vive en el `userpref.blend`
> de la máquina, **fuera del repo y fuera de git**, y la mudanza del repo del 2026-09 no
> la reescribió: siguió apuntando a `C:\Users\<usuario>\NMS_MOD_ZOMBIES\...`, sin `MODS`.
> Cuando esa ruta no existe, NMSDK abre un cuadro de diálogo y llama a
> `bpy.ops.screen.userpref_show()`, y las dos cosas **presuponen interfaz**: en
> `--background` eso no es un mensaje, es un crash. Medido el 2026-09-19 exportando el
> xenodog. Se arregla apuntándola al `tools\AMUMSS\MODBUILDER\MBINCompiler.exe` del repo
> actual.
>
> ⚠️ **Antes hay que borrar los `.MBIN` y `.MXML` viejos de
> `BLENDER/CUSTOMMODELS/MODELGROUP/`.** MBINCompiler **no sobrescribe**: si el `.MBIN.PC` ya
> existe se salta la conversión sin decir nada y te llevas la malla de la vez anterior.

### El pesado: adjudicar a **un ganador** es lo que tensa las láminas

**Han fallado dos métodos y los dos dieron el mismo síntoma en partida**, escrito las dos veces
con las mismas palabras: *«láminas planas tensadas»*.

| | Método | Lo que dio |
|---|---|---|
| `PRUEBA12` | punto más cercano de la **superficie** vanilla | las dos puntas delanteras con el **82 %** y `RootJNT` con el 0,4 % |
| `PRUEBA14` | distancia al **segmento** de cada hueso | `LFirstLeg3JNT` **12,1 %** y `RFirstLeg3JNT` **0,0 %** |

La causa común no es la alineación: es **elegir un ganador entre huesos que están casi a la
misma distancia**. El FreighterFiend es una araña de patas largas y cuerpo pequeño y el nuestro
es compacto, así que sus patas atraviesan nuestro volumen. Una franja del torso se va con una
pata, la de al lado se queda con la espalda, y al andar la costura entre las dos se estira.

**Y la `PRUEBA14` traía además una segunda causa, que son las astillas.** El `.SCENE` trae 114
huesos pero **la piel del vanilla sólo se pega a 19**, y esos 19 están escritos en el
`SkinMatrixLayout` de su `.GEOMETRY`. Pesando contra los 113, **30 de los 42 grupos caían
fuera**: mandíbula, cola, y `REyelidLowerJNT`, `LEyeParentJNT` o `LowerLMouthJNT` con **un
vértice cada uno**. Un vértice colgado de un párpado sale disparado en cuanto el bicho parpadea.

**Los tres pasos que lo arreglan, y por qué cada uno:**

```
1. candidatos = SkinMatrixLayout vanilla   los parpados dejan de poder ganar
                                            porque dejan de estar en la lista
2. promedio de los 8 vecinos, 1/distancia  sin ganador unico no hay costura
3. 12 pasadas por NUESTRAS aristas         una lamina tensada ES un salto de
                                            peso entre dos vertices unidos
```

El paso 3 es el único que puede devolver al torso la trasera que las patas se llevan, porque
ahí, en el espacio, **no hay nada del vanilla que copiar salvo pata**.

> ⚠️ **Dos medidas más quedan descartadas, y con número, para no volver a mirarlas.**
>
> | | Por qué no sirve |
> |---|---|
> | El **`GIRO_Z`** | Los cuatro giros —0, 90, 180 y 270— fallan igual, y **ninguno pasa del 4,8 %** en `NewHeadJNT` cuando el vanilla le da el **27,5 %** |
> | La **distancia del vértice a su hueso** | **El vanilla contra su propio esqueleto da 1,039** de media sobre una diagonal de 4,22, *peor* que los 0,903 del método que fallaba |
>
> **Lo que sí separa es la SIMETRÍA.** El reparto del vanilla está pareado al vértice
> —`RFirstLeg3JNT` 260 y `LFirstLeg3JNT` 260— y da **0,000**; la `PRUEBA14` daba **0,253**. Es
> un assert y sale gratis, porque se mide contra el propio vanilla en la misma corrida.

### El importador de NMSDK se come las mallas que faltan, y no lo dice

**Esto costó `M3-PIEL` y `M4-PIEL` enteros.** `render_scene` envuelve el bucle que añade
nodos en un `try/except Exception` que **imprime y para**:

```
An exception ocurred while rendering <bicho>.scene.mbin:
```

Lo que hay debajo son dos errores distintos, los dos reales:

| Dónde | Qué |
|---|---|
| `create_material_node` | `realize_path` devuelve `None` cuando la textura no está en disco, y la función hace `op.join` con ese `None`: `TypeError` |
| `_add_light_to_scene` | busca `light.node_tree.nodes['Emission']`, que Blender 5.2 ya no crea: `KeyError` |

**Todo nodo que fuera después se pierde en silencio.** Con el `FreighterFiend` no se notó
porque sólo hay una malla y el fallo llega después; con el `BUGFIEND` entraba **sólo
`FiendButt`**, 746 vértices de 26 299 pegados nada más que a la cola, y el zombie se pesaba
contra el culo del bicho.

Se anulan las dos desde fuera, en `_callar_materiales()` de `Weight-NMSMesh.py`. Aquí no se
usan ni materiales ni luces: se pesan vértices, grupos y huesos.

> Y **se leen TODAS las mallas con piel del vanilla, no la primera.** El `FreighterFiend`
> trae una, el `FIEND` tres y el `BUGFIEND` once. Un `next()` bastaba para el primero y
> mentía en los otros dos.

### El mapa a mano: copiar del vecino sólo vale entre el mismo tipo de animal

**El SkrullCrawler es una araña puesta sobre una araña y por eso copiar del vecino más cercano
funcionó.** El necromorfo y el zombie son **bípedos montados sobre arañas**, y ahí no puede
funcionar. El número que lo dice está medido, y sale de
`tools/Weight-NMSMesh.py --volcar-huesos`, que imprime **dónde vive la piel de cada hueso vanilla
dentro de NUESTRA caja**:

| | La piel del vanilla ocupa (en fracción de nuestra malla) |
|---|---|
| Necromorfo / `FIEND` | **y de 0,05 a 0,37** sobre 3,62 m · z de 0,00 a 1,56 sobre 2,22 m |
| Zombie / `ARTHROPOD` | **y de 0,08 a 0,51** sobre 2,43 m |

O sea: **el bicho vanilla cabe entero en la mitad de abajo**, y nuestros brazos y nuestra cabeza
no tienen cerca más que cuerpo. Por eso salía un solo hueso con el 79,5 % y el 80,1 %.

**El arreglo es decirlo a mano**, en `regiones`: una lista de `(hueso, predicado)` sobre las
coordenadas normalizadas `u, v, w` de nuestra caja, y **gana la primera fila que case**. Las
fronteras salen duras y las deshace el suavizado de 2b, que es exactamente para lo que estaba.

```
("NewHeadJNT",     lambda u, v, w: v > 0.86),                    # cabeza
("LFirstLeg1JNT",  lambda u, v, w: v > 0.45 and u > 0.70),       # brazo -> pata delantera
("RFirstLeg1JNT",  lambda u, v, w: v > 0.45 and u < 0.30),
("NewBack1JNT",    lambda u, v, w: v > 0.55),                    # torso
("LFourthLeg1JNT", lambda u, v, w: v <= 0.40 and u >= 0.50),     # pierna -> pata trasera
("RFourthLeg1JNT", lambda u, v, w: v <= 0.40 and u < 0.50),
("RootJNT",        lambda u, v, w: True),                        # lo que quede
```

> ⚠️ **El volcado mide la PIEL, no el esqueleto, y es a propósito.** `huesos` sale de
> `armature.matrix_world` y la malla de `vanilla.matrix_world`, y **NMSDK no las deja
> alineadas**: volcando los huesos del `FIEND` sale una lámina plana pegada al suelo. El pesado
> nunca usó la posición de los huesos —copia de los vértices—, así que ese desajuste no rompía
> el pesado, rompía el diagnóstico.

**Y la guarda cambia con el método, que si no no guarda nada.** Con mapa a mano el **tope de
punta no aplica**: mide una anatomía —«el cuerpo no cuelga de la punta de una pata»— que el mapa
dice al revés a propósito, porque nuestras piernas **sí** cuelgan de las patas traseras. Se
sustituye por una más fuerte: **que el reparto que sale no se separe más de 5 puntos del que
pedía el mapa**. El fallo del 15/08 eran 40 puntos.

### El eslabón de la pata: el mapa nombra el **primero**, no el tercero

**Esto costó la `PRUEBA04` de los dos bípedos.** Con el mapa a mano puesto y la textura ya
sana, el necromorfo y el zombie entraron al juego con el cuerpo bien plantado y **los brazos y
las piernas estirados en cuchillas de varios metros**. No era el mapa: eran las **filas**.

El número sale del `.SCENE` del vanilla, midiendo el desplazamiento de cada hueso respecto a
su padre:

```
SPIDERRIG   RootJNT -> LFirstLeg1JNT 0,34 -> Leg2 +0,29 -> Leg3 +0,61 -> Leg4END +0,59
ARTHROPOD   spine   -> legbase_L0_0  0,69 -> leg_0 +0,35 -> leg_1 +0,48 -> leg_2 +0,49
```

Los dos mapas colgaban los miembros del **tercer** eslabón —`*Leg3JNT` y `leg_*_1_jnt`—, que
está a **0,85 m pata afuera** y además **acumula el giro de sus dos padres**. Y nuestros brazos
están **por encima de todo el bicho vanilla**: su piel cabe en la mitad de abajo de nuestra caja
(§«el mapa a mano»), así que el brazo de palanca hasta la mano son **metros**.

> **Giro acumulado × palanca larga = el estirón.** Y explica la firma exacta: el cuerpo sale
> bien, porque cuelga del tronco, y sólo se van las puntas.

**La regla, corregida el 29/08: el eslabón que nombra el mapa es el PRIMERO QUE TENGA CLAVES
DE ANIMACIÓN.** No el primero de la cadena — eso fue la `PRUEBA05` y salió peor. Lleva un solo
giro propio y su origen apenas se mueve, así que el miembro entero va **rígido con la pata** en
vez de estirarse detrás de ella.

| | El primero **con claves** |
|---|---|
| `SPIDERRIG` (necromorfo) | **`*Leg1JNT`** — que es a la vez el primero de la cadena |
| `ARTHROPOD` (zombie) | **`leg_*_0_jnt`** — el primero de la cadena, `legbase_*`, **está quieto** |

Comprobar siempre que el eslabón elegido esté en el `SkinMatrixLayout`; el `assert` de regiones
lo corta si no.

### 🔴 Recoser la piel BORRA el `_F02_SKINNED`, y con él los samplers

**Esto costó la `PRUEBA05` entera, en los dos bípedos a la vez, y es el fallo más caro de toda
la receta porque IMITA UN ÉXITO.** Los dos bichos entraron al juego **sin estirarse** —que era
justo lo que la `PRUEBA05` iba a arreglar— **y sin moverse**, y el zombie además peor de textura
que en la `PRUEBA04`.

**Las tres cosas salen de un solo archivo.** Comparando md5 contra la `PRUEBA04` desplegada, el
`.MATERIAL` de la `PRUEBA05` **no declaraba `_F02_SKINNED`**, y en el zombie el `gMasksMap`
había vuelto además a `ARTHROPODTHORAX01.BASE.MASKS.DDS`.

| Lo que se ve en partida | Por qué |
|---|---|
| No se mueve | Sin `_F02_SKINNED` el juego **no aplica el esqueleto**. La malla se dibuja sin pesar |
| **No se estira** | Porque **no se deforma nada**. Parece que el pesado ha mejorado; lo que pasa es que ya no se pesa |
| Textura peor (zombie) | El `gMasksMap` compartido con toda la fauna artrópodo: `M-BABA` otra vez |

> ⚠️ **Un pesado roto y un pesado desconectado se ven distinto, y hay que saber distinguirlos:**
> **estirado = el flag está y los pesos están mal**; **rígido = el flag no está**. Si una prueba
> «arregla el estirón» y de paso pierde el movimiento, **sospechar del flag antes que del mapa**.

**El porqué, que es lo que hay que recordar:** `Skin-NMSGeometry.py` **copia la carpeta de origen
entera**, y en la de origen el `.MATERIAL` no lleva ni el flag ni el sampler reapuntado — porque
los dos son el **paso 5**, y el paso 5 se aplica al final, **sobre la copia**. Así que **cada vez
que se rehace la piel los dos se pierden en silencio**. Y el `COMMENT` del `.lua` seguía diciendo
«`CON _F02_SKINNED`», porque el comentario no se rehace con el archivo.

```
python tools/Flag-NMSMaterial.py <material> --poner _F02_SKINNED
python tools/Set-NMSSampler.py  <material> gMasksMap TEXTURES/.../ZOMBIE.BASE.MASKS.DDS
python tools/Check-NMSGraft.py  work/models/<malla>_anim      <- ahora lo verifica
```

> 🛡️ **`Check-NMSGraft.py` lo caza desde el 29/08** y da **salida 1** si falta el flag o si un
> sampler ha vuelto a una textura compartida del vanilla. Comprobado contra la `PRUEBA05`
> desplegada: la caza. **El paso 4 vuelve a correrse después del paso 5**, y ése es el orden bueno.

### Estar en el `SkinMatrixLayout` NO quiere decir que el hueso se mueva

**Esto no fue lo que se vio en la `PRUEBA05` —eso era el flag— pero es un fallo real que estaba
debajo, y se encontró midiendo.** Con el flag puesto, el mapa de la `PRUEBA05` habría dado los
miembros rígidos igual, porque colgaban de huesos que no giran. Se arregla en la misma vuelta.

La causa se mide en los **`.ANIM`**, no en el `.SCENE`:

```
tools/AMUMSS/MODBUILDER/hgpaktool.exe -U -f "*creatures/arthropod/anims/*" ^
    -O ./anims "…\PCBANKS\NMSARC.AnimMBIN.pak"
MBINCompiler.exe anims\...\arthropodwalk.anim.mbin          (uno por clip)
python tools/Sway-NMSJoint.py <.SCENE.MXML> anims\...\*.MXML
```

**`Sway-NMSJoint.py` es el que da la respuesta**, y de paso escribe la tupla `sin_claves` lista
para pegar. Marca cada hueso `SI` / `QUIETO` / `a veces` y le pone al lado su **giro de mundo**
en cada clip. La firma del fallo se lee de un vistazo, porque el hueso quieto da **exactamente**
el mismo número que su padre:

```
hueso                      claves arthropodwa arthropodru arthropodid arthropodat
spine_C0_0_jnt                 SI         5.8         2.2         0.8        38.1
legbase_L0_0_jnt           QUIETO         5.8         2.2         0.8        38.1   <- ni uno propio
leg_L0_0_jnt                   SI        18.1        52.1         3.1        62.9   <- este si
leg_L0_1_jnt                   SI        31.3        40.0         2.2        34.9
```

Un `.ANIM` trae `NodeData` con un `RotIndex` por hueso y dos bloques de fotogramas. **Si el
`RotIndex` cae por encima del número de rotaciones de `AnimFrameData`, el hueso no tiene clave:
se lee de `StillFrameData` y no se mueve nunca.** Medido sobre los cuatro clips del `ARTHROPOD`
—`WALK`, `RUN`, `IDLE` y `ATTACK01`—:

| | |
|---|---|
| Huesos de la paleta del `ARTHROPOD` | 29 |
| **Quietos en los cuatro clips** | **6, y son los seis `legbase_*`** |
| Los que la `PRUEBA05` puso bajo brazos y piernas | **4 de esos 6 — el 52,2 % de la malla** |
| Huesos de la paleta del `SPIDERRIG` | 7 |
| Quietos | **1, `NewBack1JNT`** — y es el **torso**, así que ahí está bien |

Un hueso quieto **no está congelado en el mundo**: hereda a su padre. `legbase_*` cuelga de
`spine_C0_0_jnt` y gira exactamente los mismos **4,0°** de mundo que el torso. Por eso el bicho
no se rompía —se movía entero, de una pieza— y por eso tampoco se movía.

**El giro de MUNDO es el número que decide**, no el local, porque es el que multiplica la
palanca. Promediado sobre `WALK` y `RUN`:

| Cadena del `ARTHROPOD` | `spine` | `legbase` | **`leg_*_0`** | `leg_*_1` |
|---|---:|---:|---:|---:|
| Giro de mundo | 4,0° | **4,0°** | **18–35°** | 28–36° |
| Desplazamiento en nuestra pierna | — | 0,04 / 0,06 m | **0,27 / 0,52 m** | 0,12 / 0,62 m |
| Desplazamiento en nuestro brazo | — | 0,10 / 0,10 m | **0,90 / 0,86 m** | 0,85 / 1,03 m |

`leg_*_0_jnt` es el primero que se mueve por su cuenta y arrastra **un solo** giro; `leg_*_1_jnt`
—la `PRUEBA04`— arrastra **dos**, y eso por la palanca de metros hasta nuestras manos es el
estirón.

Y en el `SPIDERRIG` la misma medida **confirma** el mapa que ya había, así que el necromorfo no
se toca:

| Desplazamiento, `WALK` + `RUN` | `Leg1` | `Leg2` | `Leg3` |
|---|---:|---:|---:|
| Brazo (L / R) | **1,12 / 0,86** | 1,03 / 0,99 | 1,11 / 1,11 m |
| Pierna (L / R) | **0,84 / 0,35** | 1,25 / 0,39 | 1,43 / 0,29 m |

> **Y queda un `assert` que lo corta antes de entrar al juego.** En `Weight-NMSMesh.py`, justo
> detrás del que comprueba la paleta: si el mapa cuelga un **miembro** de un hueso de
> `sin_claves`, revienta. El **tronco** sí puede colgar de uno quieto —hereda al padre y no
> necesita giro propio—, y por eso la excepción se decide con los fragmentos de `tronco` del
> propio modelo.

### Las cuatro ranuras del buffer, y no dos

El canal 5 son **4 bytes** de índice y el 6 son **4 half** de peso: el contrato del vanilla da
**cuatro** huesos por vértice, y `nmsskin.canales()` siempre escribió los cuatro. Lo que
truncaba a **dos** —y renormalizaba— era `Weight-NMSMesh.py`.

**Renormalizar a dos deshace el suavizado justo donde hacía falta:** la frontera entre dos
regiones es el único sitio donde se juntan tres o más huesos, y es exactamente donde se tensa
la lámina. Un vértice que salía del suavizado con 0,4 / 0,3 / 0,2 / 0,1 se guardaba como
0,57 / 0,43. Arreglado el 28/08: se guardan las `nmsskin.RANURAS` mayores.

| | PRUEBA04 | PRUEBA05 |
|---|---:|---:|
| Influencias por vértice, necromorfo | 1,71 | **2,10** |
| Influencias por vértice, zombie | 1,81 | **2,04** |

> ⚠️ **Y las ranuras quedan DESCARTADAS como causa de nada, con número.** Cuando la `PRUEBA05`
> salió rígida y con la textura peor, las cuatro ranuras eran el otro cambio de esa entrega y
> había que descartarlas. Se recalculó el reparto truncando el **mismo** `pesos.json` a 2 y a 4:
>
> | | top-2 | top-4 |
> |---|---:|---:|
> | Peso en los miembros, necromorfo | 60,4 % | 60,5 % |
> | Peso en los miembros, zombie | 52,1 % | 52,1 % |
>
> **0,1 puntos.** Las ranuras sólo tocan los vértices de la frontera, que es exactamente para lo
> que están. No eran ellas: era el eslabón. Y el `VertexLayout` del vanilla declara `Size = 4`
> en los canales 5 **y** 6, así que cuatro es el contrato, no una decisión nuestra.

### 🔴 La altura: **la malla no puede subir por encima del esqueleto**

**Esto es la causa de fondo de las dieciocho pruebas del zombie y el necromorfo, y se leyó mal
todo ese tiempo como «es que son bípedos».** Se encontró el 02/09 al montar dos bichos que **sí**
son del mismo tipo de animal que su vanilla — un insecto de cuatro patas sobre el `ARTHROPOD` y
un cuadrúpedo sobre el `FIEND` — y ver que **fallaban igual**.

Los acuerdos `B1` y `B2` subieron el necromorfo a **3,62 m** y el zombie a **2,43 m** porque a
la altura del vanilla «se veían enanos». Lo que no se midió entonces es dónde deja eso al
esqueleto:

| | Mide el esqueleto | Nuestra malla | Malla **sin un solo hueso encima** |
|---|---:|---:|---:|
| `FIEND` / necromorfo y cry wolf | **1,34 m** | 3,62 m | **59,5 %** |
| `ARTHROPOD` / zombie y warrior bug | **1,05 m** | 2,43 m | **60,7 %** |

**Más de la mitad de la malla flota por encima del último hueso**, y ahí el vecino más cercano
no encuentra otra cosa que tronco. De ahí salen los dos números que cortan:

```
cry wolf a 3,62 m     RootJNT          62,8 %   (tope 25,5)
warrior bug a 2,43 m  spine_C0_0_jnt   43,0 %   (tope 39,3)
```

**La regla: el bicho se escala a 1,4-1,7× su vanilla, no a 2-3×.** Con 1,90 m y 1,80 m el
esqueleto cubre el 70-75 % de la malla, los dos siguen siendo claramente mayores que el bicho
del juego —que es lo que `B1` y `B2` querían— y los dos pesados pasan.

> **El bipedismo lo agravaba, pero no era la causa.** Un bípedo estira la malla hacia arriba y
> por eso llegaba antes al problema; el fallo lo produce la escala, y le pasa igual a un
> cuadrúpedo. Ver `B10` en [`ACUERDOS.md`](ACUERDOS.md).

### El giro: el assert mide la ALTURA y **no ve un bicho montado del revés**

**Los dos entraron mirando hacia atrás y nada lo cazó.** El assert de orientación compara
`RootJNT` contra las puntas de las patas, o sea mide **arriba/abajo**; delante/detrás no lo
mira nadie.

Se ve poniendo lado a lado el volcado del vanilla y el histograma de nuestra malla, en las
mismas coordenadas:

| | Nuestra parte alta | La cabeza del vanilla |
|---|---:|---:|
| cry wolf | `w` **0,05** | `NewHeadJNT` en `w` **1,51** |
| warrior bug | `w` **0,38** | `head_C0_0_jnt` en `w` **0,84** |

Se arregla con `giro=(-90, 0)` en vez de `(-90, 180)` en `Export-NMSMesh.py`. **Y ojo con
tantear el `GIRO_Z` de `Weight-NMSMesh.py` para esto: ése gira el ESQUELETO, no nuestra malla,
y el `Rz(180)` es el que lo pone de pie** — con 0 el esqueleto queda boca abajo, aunque el
reparto parezca mejorar.

> 🔴 **Y ese arreglo ERA AL REVÉS. Medido en partida el 02/09**: con `giro=(-90, 0)` los dos
> entraron **de espalda**, así que el `180` que ya usaban las otras tres entradas del conducto
> era el bueno y el volcado medía otra cosa — *el décimo superior de un insecto son las patas
> levantadas, no la cabeza*. **La regla que queda: el giro no lo decide un volcado, lo decide
> una entrada al juego.** El volcado sólo sirve para descartar, nunca para confirmar.

### El giro de 180° ESPEJA el mapa a mano, y el assert sí lo caza

**Los cortes de `regiones` están en coordenadas normalizadas de NUESTRA caja, y `Ry(180)`
espeja dos de sus tres ejes: `u → 1−u` y `w → 1−w`.** Cambiar el giro sin espejarlos deja el
mapa señalando al revés: en el warrior bug la región de la cabeza pasó a cazar la punta del
abdomen —759 vértices en vez de 2 665— y `spine_C0_0_jnt` subió al **92,2 %** contra un tope
de 85.

No hay que re-derivar nada del histograma: es la **misma línea** con las dos sustituciones.
`v` —la altura— no se toca.

```
("head_C0_0_jnt", lambda u, v, w: v > 0.70 and w > 0.55)   antes
("head_C0_0_jnt", lambda u, v, w: v > 0.70 and w < 0.45)   después
```

### La POSTURA de reposo no la arregla ningún peso: si el bicho está mal plantado, es la malla

**Medido el 04/09 en el cry wolf, y es la comprobación que hay que hacer ANTES de tocar pesos.**
La queja era que la cabeza iba por delante. Se deformó **la misma malla** con `fiendwalk` usando
dos repartos de peso distintos —el de la `PRUEBA03` y el de la `PRUEBA04`— y **los dos renders
salen iguales**; y el `reposo.png`, que es la malla **sin animar**, ya traía el cuello adelante.

**Y tiene que ser así, no es casualidad:** en la pose de bind la piel devuelve cada vértice a su
sitio por construcción —`v' = Σ w · M·B⁻¹ · v` con `M = B` da `v` sea cual sea el reparto—. O sea
que **ningún alfa, ningún tope y ningún agarre pueden cambiar la postura de reposo**. Es
matemática, no ajuste.

La prueba que lo separa, y cuesta dos corridas:

```
python tools/Pose-NMSMesh.py <bicho> --pesos <A>.json --clips <clip> --vista
python tools/Pose-NMSMesh.py <bicho> --pesos <B>.json --clips <clip> --vista
```

Si los dos renders salen iguales, **no es el pesado**. Y `reposo.png` dice si ya venía de fábrica.

**Arreglarlo es re-posar la geometría**, y en `Export-NMSMesh.py` hay un sitio para eso: la clave
`pose` del modelo, que va **entre el giro y la escala** —en el marco de NMS, con Y arriba— y
dobla una parte de la malla con una **rampa `smoothstep`**, no con un giro rígido. La rampa
importa: un giro rígido deja un **pliegue** en la frontera, y un pliegue es geometría que el
suavizado de los pesos no puede deshacer.

**Y arrastra dos cosas, siempre:**

1. **La caja cambia**, así que con `alto` fijo la escala uniforme cambia y **el cuerpo cambia de
   tamaño** aunque la silueta mida lo mismo. En el lobo, doblar 30° dejó el cuerpo un **12 %**
   más pequeño.
2. **Los cortes del mapa de regiones hay que re-medirlos.** Van en coordenadas normalizadas: no
   cambian con la escala —eso es `B14` de `ACUERDOS.md`— pero **sí con la forma**.

Y con las aristas más cortas la `tensión` sube aunque el estirón baje, porque es una **razón**
entre vecinos y la referencia se encogió. Cuando la forma cambia, el número que se compara es
**`abre`, en metros**.


### El tope tiene que leer TODOS los clips que el bicho reproduce, y el mod decide cuáles

**Medido el 03/09 en el cry wolf, y costó una entrada al juego.** `clips_tope` llevaba cuatro
animaciones —`walk`, `run`, `idle` y `attack`— y el `FIEND` tiene **nueve**. La que más tensa
no es ninguna de las cuatro:

| clip | roar | run | pounce | attack | walk | idle | attack2 | trot | attack3 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| tensión | **36,4** | 28,2 | 26,8 | 26,2 | 25,8 | 15,7 | 8,9 | 8,2 | 7,6 |

Y la diferencia no es de matiz: en `roar` el giro de mundo de `RootJNT` vale **44,2** grados
contra los **6,3** de `walk`, `NewBack1JNT` **49,4** contra 6,3 y `NewHeadJNT` **72,2** contra
2,9. Con esos tres fuera de la lista, el tope se elige sobre un vaivén infravalorado **ocho
veces**, y en partida se ve exactamente donde el tope no miraba.

**Y cuál es el peor clip lo decide el MOD, no el vanilla.** Aquí `roar` importa porque
`SpawnBroodAnim` del `FIEND` vale `ROAR` y el mod enciende `AllowSpawnBrood` con
`SpawnBroodTimer` a 10 s: **el rugido es el parto**, así que es de los clips que más se
reproducen. En vanilla, con `AllowSpawnBrood = false`, casi no sale.

**La regla, entonces:** la lista de clips no se copia del bicho anterior. Se saca de
`tools/AMUMSS/TOOLS/NMS_FULL_pak_list.txt` —que lista los `.ANIM` del esqueleto— y se cruza
con lo que el mod enciende en `CREATUREDATATABLE`: `AllowPounce` mete `pounce`,
`AllowSpitAlways` mete `spit`, `SpawnBroodAnim` mete el que diga. `Pose-NMSMesh.py --clips`
los saca del `.pak` solo, así que medirlos todos cuesta una corrida.

**Corolario que también costó una prueba:** una región **sin `agarre` no la topa nadie**.
`alfas_de` sólo recorre `AGARRE`, así que un hueso que no esté ahí se queda con su vaivén
entero por muy alto que sea — `NewBack1JNT` del lobo iba a **279** contra un objetivo de 170,
siendo el hueso que `Pose-NMSMesh.py` culpaba en los nueve clips. Ya había pasado con
`tail_C0_0_jnt` en el zombie. **Si una región aparece como culpable y no tiene ancla, ése es
el fallo, y no hace falta partir la región en dos.**


### El tope de vaivén NO es invariante de escala: escala con la malla

**El vaivén es giro × PALANCA, y la palanca es la distancia de la región al pivote del hueso
partida por el tamaño de la región.** El esqueleto del juego **no** crece con nosotros, así que
doblar la malla sube la palanca **más** del doble — en el warrior bug la cabeza pasó de `4,4x`
a `7,0x`.

Con `objetivo` quieto, doblar el bicho **lo deja tieso**: el agarre de la cabeza subió del 53 %
al 76 % y `spine` pasó a mandar el 90,1 %. Y el número nuevo **no se elige a ojo, es una
ventana que se mide** en la propia corrida, leyendo la columna `todos` de cada región:

| | Por debajo | Por encima |
|---|---|---|
| warrior bug 3,60 m | **255** — la cabeza (`todos` 510) pierde su hueso | **375** — las patas delanteras (`todos` 750) se sueltan del tórax |
| warrior bug 2,70 m | **195** (`todos` 391) | **316** (`todos` 633) |
| cry wolf 3,80 m | **155** (`todos` 309) | **250** (`todos` 506) |
| cry wolf 2,85 m | **129** (`todos` 258) | **214** (`todos` 428) |

**La ventana se mueve con cada cambio de `alto`, así que se vuelve a leer cada vez.** Dentro de
ella el criterio es reproducir el reparto dominante de la entrega que ya se vio bien: **el tope
nuevo es el que devuelve el reparto viejo.**

> ⚠️ **Y el centro de la ventana no se coge a ciegas: se puntúa con `Pose-NMSMesh.py`.** En el
> cry wolf a 2,85 m, `200` daba tensión 30,3/33,2/30,8 y costura 45/49/52 cm, y `170` la bajó a
> 25,8/28,2/26,2 y 39/42/46 **con el mismo reparto**. Dos números válidos por el assert no son
> el mismo bicho.

> **Lo que la escala NO explica, en el cry wolf.** A 3,80 m abría 45/49/56 cm y a 2,85 abre
> 39/42/46: bajarle un cuarto de tamaño casi no lo movió, y la `PRUEBA01` a 1,90 abría 10/12/13.
> El medidor pone la costura en `NewBack1JNT` en los cuatro clips, o sea **el cuello largo
> colgando del pecho**. Si en partida se ve abrir ahí, el arreglo no es el tope —ya está en el
> centro de su ventana— sino **partir `NewBack1JNT` en dos regiones, cuello y pecho**.

### La proporción: dos cuadrúpedos pueden no casar, y entonces hace falta el mapa igual

**El cry wolf y el `FIEND` son los dos cuadrúpedos y aun así hizo falta mapa a mano.** El
motivo no es la anatomía sino la forma: medido en el volcado, el `FIEND` ocupa **dentro de
nuestra caja** de `w` −0,47 a **1,64**, o sea **4,4 m de largo por 1,2 de alto —3,5 a 1—**
contra el **1,1 a 1** del lobo. Sus patas delanteras (`w` 1,08) y su cabeza (`w` 1,51) caen
**por delante de nuestra malla**, así que ahí no hay nada que copiar.

> **La condición para el vecino más cercano no es «mismo tipo de animal»: es que el esqueleto
> del vanilla quepa dentro de nuestra malla.** El SkrullCrawler cumplía las dos —araña sobre
> araña **y** misma altura, escala 1,0005— y por eso salió a la primera.

### Los cortes del mapa salen del HISTOGRAMA de nuestra malla, no del ojo

Con `regiones` ya no hay que adivinar dónde está cada parte: se mira la nube de nuestros
propios vértices en `u, v, w` normalizados y las jorobas son los miembros.

```
warrior bug, mitad de abajo (v < 0,45, el 23% de la malla)
    w 0,2-0,4   1353 vertices   patas traseras
    w 0,5-0,7   2107 vertices   patas delanteras
cry wolf, eje w entero
    w 0,2-0,5   4650 vertices   cuerpo, con las cuatro patas
    w 0,9-1,0   3174 vertices   cuello y cabeza, el 34% del bicho
```

### El agarre hace falta **aunque la anatomía case**, y se mide antes de construir

Se entregaron los dos primero con el mapa duro —`alfa` 1,0, sin agarre— y `Pose-NMSMesh.py` lo
tumbó sin entrar al juego, que es exactamente para lo que está:

| | Mapa duro | Con agarre y tope 120 | Zombie `PRUEBA10`, ya aceptado |
|---|---:|---:|---:|
| warrior bug, `walk` / `run` / `attack` | 55,1 / 81,9 / 117,4 | **25,9 / 38,7 / 55,3** | 11,5 / 17,0 / 13,0 |
| cry wolf, `walk` / `run` / `attack` | 71,8 / 55,6 / 64,9 | **16,2 / 12,6 / 15,0** | — |

**Y el tope por vaivén no lo arregla todo solo.** En el warrior bug, con el agarre puesto, el
hueso que pasaba a mandar era `tail_C0_0_jnt` —el abdomen, 28,5 % de la malla— con **vaivén 8**,
o sea muy por debajo del tope, que ni lo veía. Lo que abría no era su giro sino el **salto**
contra `spine_C0_0_jnt` en la frontera del mapa. Se arregla con `alfas_fijos`, igual que las
piernas del zombie en la `PRUEBA10`.

### La escala del pesado: **1.0**, aunque nuestra malla mida otra cosa

**El pesado NO puede hinchar el esqueleto para que quepa.** Los `JointBindings` —las matrices
de bind inversas— se copian del vanilla tal cual en `Patch-NMSGraft.py`, así que **en partida
el juego lee nuestros vértices en el espacio del vanilla, sin reescalar nada**. Casar contra
un rig hinchado es casar cada vértice con un hueso que en partida está en otro sitio.

Con el SkrullCrawler no se veía, porque los dos bichos miden lo mismo —1,851 el nuestro contra
1,850 el vanilla, escala 1,0005—. El necromorfo se subió **a propósito** a 3,62 m, el doble del
`FIEND`, y ahí la escala salía **×2,0008**:

| | escala «altura» | escala 1.0 |
|---|---:|---:|
| Vértice medio a su hueso (diagonal 4,97) | 2,170 | **1,558** |
| Huesos con peso | 12 | **15** |
| `NewHeadJNT` | 0 % | **2,7 %** |

### El tope de reparto: contra el vanilla sólo si es el mismo animal

`HOLGURA_REPARTO` compara el hueso más cargado con el más cargado del vanilla. Vale para el
SkrullCrawler —araña contra araña, 43,5 % contra 45,9 %— y **no puede valer para un bípedo
montado en una araña**: un bípedo cuelga casi entero de la columna y a una araña la masa se le
va a la cabeza y a las ocho patas. El `FIEND` pone su máximo en `RootJNT` con el **20,4 %** y
el `ARTHROPOD` en `head_C0_0_jnt` con el **31,4 %**, así que **ningún** pesado de un bípedo
pasa el tope relativo, ni el bueno.

Por eso esos dos llevan `tope_reparto` **absoluto**, 0,85. **Y no se quedan sin guarda:** los
tres asserts que de verdad cazaron los fallos —tronco mínimo, tope de punta y simetría— siguen
midiendo contra el vanilla en la misma corrida.

### La orientación: el vanilla viene Z arriba y lo nuestro Y arriba

Son 90° de diferencia. Sin corregirlo, las patas cuartas se quedan **con 0 vértices** y una
pata delantera se traga un tercio de la malla. El script ya gira +90° en X y encaja las cajas.

### El giro de 180°: **puntuar por «cuántos grupos reciben vértices» elige mal**

Ese criterio da `GIRO_Z 0`, que deja el cráneo **mirando hacia atrás**. Lo que sí decide es
**dónde cae la cabeza**: en el FreighterFiend está en **+Y**. El script lo comprueba solo con
un assert sobre el centroide de `NewHeadJNT`, y revienta si sale negativo.

> Para un bicho nuevo, mirar primero dónde tiene la cabeza **el vanilla** y ajustar el assert
> a eso. Es el único sitio donde hay que pensar.
>
> ⚠️ **Y el assert mide el TRONCO, no la cabeza. Desde el 27/08.** En el `SPIDERRIG` —el mismo
> esqueleto en el `FIEND` y en el `FreighterFiend`— `NewHeadJNT` cae a la **misma** altura que
> la media de las puntas de las patas, porque estos bichos llevan la cabeza a ras de suelo:
> pasaba por centésimas en el SkrullCrawler y fallaba por 3 cm en el necromorfo. Era una moneda
> al aire. `RootJNT` está a **+0,341** sobre las puntas, once veces más margen, y boca abajo se
> iría a −0,341.

### El casado va por **vecino más cercano**, nunca por posición exacta

El exportador parte los vértices —4 820 se convirtieron en 11 357, uno por combinación de
normal y UV—, así que hay que casar por posición. Pero **el buffer guarda en `half` y
`pesos.json` en float**, y el mismo vértice sale movido hasta **1,4 ULP**: `1.829884` en el
JSON contra `1.8291016` en el buffer. Casar por clave exacta falla en **10 014 de 11 357**.

Está resuelto en `nmsskin.casar`, con la tolerancia medida entre dos límites:

| | |
|---|---:|
| vértice peor casado | 0,001355 |
| segundo vecino más cercano de toda la malla | 0,005036 |
| tolerancia | **0,003** |

Si en un modelo nuevo esto salta, el mensaje trae las dos cajas envolventes. **Cajas
distintas = `pesos.json` salió de otra malla o de otra escala**, y hay que volver al paso 2.

---

## 4 · Lo que cierra el juego, y por qué el `Check` va antes

Dos fallos conocidos, los dos vividos:

| Síntoma | Causa |
|---|---|
| El bicho **se estira sin forma** (`PRUEBA01`) | El flag puesto y los pesos mal |
| El juego **cierra sin avisar** (`PRUEBA05`) | El flag puesto y los índices fuera de rango |

Y el detalle que separa las dos cosas, leído en `import_scene.py:1085-1098`:

```
skin_mats = SkinMatrixLayout[FIRSTSKINMAT : LASTSKINMAT]
por cada skin_mat -> un grupo de vertices, en ese orden
blend_indices[j] indexa DIRECTAMENTE esa lista de grupos
```

> **El byte del canal 5 NO es el número de hueso: es la posición dentro de la paleta.** Los
> valores de `SkinMatrixLayout` sí son `JOINTINDEX`, y `JOINTINDEX` empieza en 1. Confundir
> las dos cosas es exactamente el cierre de la `PRUEBA05`.

Con una paleta de 14 huesos, los bytes del canal 5 van de **0 a 13**. Si aparece un 40 porque
alguien metió el `JOINTINDEX` en vez de la posición, el juego se cierra.

---

## 5 · Lo que salió en los cinco, para comparar

### 5a · La segunda hornada, que es la que hay en el juego

| | Warrior bug | Cry wolf |
|---|---:|---:|
| Vanilla al que sustituye | `BUGFIEND` (`ARTHROPOD`) | `FIEND` (`SPIDERRIG`) |
| Sustituye a su vez a | el zombie | el necromorfo |
| Tipo de animal | insecto de 4 patas | cuadrúpedo de cuello largo |
| Triángulos, del FBX → decimados | 133 108 → 36 000 | 18 920 → **sin decimar** |
| Vértices en Blender / exportados | 18 063 / 20 257 | 9 672 / 11 100 |
| Aristas de UV por encima de 0,10 | 4 de 108 000 (0,0037 %) | **0** de 56 760 |
| Texturas del asset → atlas | **12** → 2048, 12 de 16 celdas | 2 → 2048, 8 de 16 celdas |
| Normal | inventado de la luminancia | **del asset** |
| Máscaras | planas a 87 | **rugosidad del asset, invertida** |
| `.DDS` | 2048 (el zombie iba a 1024) | 2048 |
| **Altura** | **1,80 m** (1,7× el vanilla) | **1,90 m** (1,4× el vanilla) |
| Giro | `(-90, 0)` | `(-90, 0)` |
| Método de pesado | mapa a mano + agarre | mapa a mano + agarre |
| Grupos que reciben peso | 7 | 7 |
| Influencias por vértice | **2,17** | **2,22** |
| Asimetría, nuestra / del vanilla | **0,000 / 0,018** | **0,000 / 0,005** |
| Vértice medio a su hueso / diagonal | 0,60 / 3,49 | 1,51 / 2,95 |
| Tensión `walk` / `run` / `attack` | 25,9 / 38,7 / 55,3 | **16,2 / 12,6 / 15,0** |
| La costura abre | 11 / 17 / 28 cm | **10 / 12 / 13 cm** |

> **El cry wolf entra mejor que la `HT_ZombieMesh_PRUEBA10`**, que era la mejor de las
> dieciocho pruebas anteriores: 11,5 / 17,0 / 13,0 de tensión y 7 / 13 / 21 cm de apertura.
> Y lo hace en su **`PRUEBA01`**, sin una sola medida en partida.

### 5b · La primera hornada

| | SkrullCrawler | Necromorfo | Zombie |
|---|---:|---:|---:|
| Vanilla al que sustituye | `FreighterFiend` | `FIEND` | `BUGFIEND` |
| Mallas con piel del vanilla | 1 | 3 | **11** |
| Huesos del esqueleto | 113 | 43 | 51 |
| Huesos a los que el vanilla pega SU piel | 19 | 40 | 29 |
| `escala_piel` | altura (1,0005) | **1.0** | **1.0** |
| Vértices en Blender | 4 820 | 16 048 | 17 983 |
| Vértices exportados | 7 627 | 42 742 | 22 982 |
| Método de pesado | vecino más cercano | **mapa a mano** | **mapa a mano** |
| Eslabón del que cuelgan los miembros | — | **`*Leg1JNT`** | **`leg_*_0_jnt`** |
| Huesos de la paleta **sin claves** | — | 1 (`NewBack1JNT`, y es torso) | **6 (`legbase_*`)** |
| Grupos que reciben peso | 14 | 7 | 7 |
| Mayor reparto, nuestro / del vanilla | 43,5 % / 45,9 % | 21,0 % / 20,4 % | 23,7 % / 31,4 % |
| Asimetría, nuestra / del vanilla | 0,026 / 0,000 | 0,014 / 0,005 | 0,052 / 0,018 |
| Influencias por vértice | 1,96 | **2,10** | **2,04** |
| Vértice medio a su hueso / diagonal | 0,90 / 4,22 | 1,74 / 4,97 | 0,86 / 3,05 |
| `FIRSTSKINMAT` → `LASTSKINMAT` | 0 → 14 | 0 → 7 | 0 → 7 |

> **Los dos 80 % de la primera entrega eran el bloque, y el mapa a mano los deshizo:** el hueso
> más cargado baja de 79,5 % a 21,0 % en el necromorfo y de 80,1 % a 23,7 % en el zombie, con
> siete huesos repartiendo en vez de uno.
>
> **Y el reparto no volvió a moverse desde entonces**, ni al cambiar de eslabón ni al pasar de
> dos ranuras a cuatro: las tres entregas del zombie —`04`, `05` y `06`— dan los mismos
> porcentajes con un punto de diferencia, porque el mapa por regiones es el mismo. **Lo único
> que cambia entre ellas es de qué hueso cuelga cada región**, y eso no se ve en el reparto: se
> ve en el giro de mundo y en partida.

---

## 5b · El detalle del SkrullCrawler

| | |
|---|---:|
| Huesos del esqueleto vanilla | 113 |
| Grupos que reciben peso | **14** |
| Huesos a los que el vanilla pega SU piel | **19** |
| Mayor reparto, nuestro / del vanilla | **43,5 % / 45,9 %** |
| Asimetría, nuestra / del vanilla | **0,026 / 0,000** |
| Vértices en Blender | 4 820 |
| Vértices exportados | 11 357 |
| Asignaciones | 4 895 (1,02 por vértice) |
| Máximo de huesos por vértice | 2 |
| Buffer | 90 856 → **227 140** bytes |
| `FIRSTSKINMAT` → `LASTSKINMAT` | 0 → 14 |

> **El bicho vanilla es casi rígido**: 1,05 huesos por vértice. Eso rebaja mucho el listón —no
> hace falta un pesado fino, basta con el hueso más cercano—. Si en un modelo nuevo sale muy
> por encima de 2 huesos por vértice, sospechar de la alineación antes que del pesado.

---

## 6 · Qué se versiona y qué no

| | |
|---|---|
| ✅ Los `.py` de `tools/` | Fuente propia |
| ✅ `pesos.json` | 285 KB de texto, y es lo que consume el paso 3. **Se perdió una vez por no versionarlo** |
| ✅ El `.blend` | Decisión del 15/08, aun pesando 20,9 MB |
| ⛔ **Las carpetas `_anim`** | Son `.MBIN` de Hello Games. Se rehacen con una orden |

Las excepciones del `.gitignore` tienen truco: **git no puede re-incluir nada dentro de un
directorio excluido**. Por eso la regla es `work/models/*` y no `work/models/`, y hay que
abrir todos los directorios padre. Con `*.blend` no hace falta, que es patrón de archivo.

---

## 7 · Dónde está cada cosa

| | |
|---|---|
| Diseño, con los porqués | [`superpowers/specs/2026-08-14-skin-nmsgeometry-design.md`](superpowers/specs/2026-08-14-skin-nmsgeometry-design.md) |
| Plan de implementación | [`superpowers/plans/2026-08-14-skin-nmsgeometry.md`](superpowers/plans/2026-08-14-skin-nmsgeometry.md) |
| Estado y cola | [`PENDIENTES.md`](PENDIENTES.md) §2.1 |
| Tests | `python -m unittest discover -s tools/tests` desde la raíz — `unittest`, **no pytest** |
