# Receta: poner piel a una malla propia

**Para qué sirve:** para que una malla nuestra deje de ir rígida y se mueva con el esqueleto
del bicho vanilla al que sustituye. No se anima nada: el esqueleto y sus animaciones ya están
en el juego. Lo que falta es **pegar nuestra malla a esos huesos**.

Esta receta salió de hacerlo entero con el **SkrullCrawler** el 2026-08-15. Está escrita para
repetirla con los otros tres modelos sin volver a investigar nada.

Actualizado: **2026-08-27**.

---

## 0 · Qué cambia por modelo y qué no

Casi todo está automatizado. Lo que hay que decidir en cada modelo nuevo son **siete cosas**:

| Qué | Dónde se pone | Cómo se decide |
|---|---|---|
| El `.blend` y el nombre del objeto | `BLEND` y `NUESTRA` en `tools/Weight-NMSMesh.py` | Se saben |
| El bicho vanilla al que sustituye | `VANILLA` en el mismo archivo | El que ya usa el mod |
| **`GIRO_Z`** | Igual | §3. **No se adivina, se mide** |
| **`espejo`** | Igual | Los dos trozos de nombre que distinguen izquierda de derecha. El `SPIDERRIG` usa `L`/`R` al principio y el `ARTHROPOD` usa `_L`/`_R` en medio. Lo consume el assert de simetría, que es **el que de verdad corta** |
| **`escala_piel`** | Igual | `"altura"` **sólo** si nuestra malla mide lo mismo que el bicho vanilla. Si no, **`1.0`**. Ver §3, «la escala del pesado» |
| **`tope_reparto`** | Igual | `None` si nuestro bicho es del mismo tipo de animal que el vanilla; un número absoluto —**0.85**— si es un bípedo montado en una araña. Ver §3 |
| **`regiones`** | Igual | **El mapa a mano región → hueso.** Sin él se copia del vecino más cercano, que sólo vale entre dos bichos del mismo tipo de animal. Sale del volcado, no de suponer. Ver §3, «el mapa a mano» |

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

## 2 · Los cinco pasos

```
1. Extraer el vanilla del .pak                          una vez por bicho
2. tools/Weight-NMSMesh.py       -> pesos.json          Blender, sin interfaz
3. tools/Skin-NMSGeometry.py     -> carpeta _anim       sin Blender
4. tools/Check-NMSGraft.py       -> pasa o no pasa      ANTES de construir
5. _F02_SKINNED en el .MATERIAL  -> va en el .lua       el ultimo, siempre
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
>     y despues recompilar el .GEOMETRY.MXML, que Patch- deja solo el XML
> ```
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

### Paso 5 — el flag

`_F02_SKINNED` de vuelta en el `.MATERIAL`, y eso va en el `.lua`, no aquí. **El último
siempre**, porque es el que convierte un error de datos en un cierre del juego.

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
("LFirstLeg3JNT",  lambda u, v, w: v > 0.45 and u > 0.70),       # brazo -> pata delantera
("RFirstLeg3JNT",  lambda u, v, w: v > 0.45 and u < 0.30),
("NewBack1JNT",    lambda u, v, w: v > 0.55),                    # torso
("LFourthLeg3JNT", lambda u, v, w: v <= 0.40 and u >= 0.50),     # pierna -> pata trasera
("RFourthLeg3JNT", lambda u, v, w: v <= 0.40 and u < 0.50),
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

## 5 · Lo que salió en los tres, para comparar

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
| Grupos que reciben peso | 14 | 7 | 7 |
| Mayor reparto, nuestro / del vanilla | 43,5 % / 45,9 % | 21,0 % / 20,4 % | 23,7 % / 31,4 % |
| Asimetría, nuestra / del vanilla | 0,026 / 0,000 | 0,014 / 0,005 | 0,052 / 0,018 |
| Influencias por vértice | 1,96 | 1,71 | 1,81 |
| Vértice medio a su hueso / diagonal | 0,90 / 4,22 | 1,74 / 4,97 | 0,86 / 3,05 |
| `FIRSTSKINMAT` → `LASTSKINMAT` | 0 → 14 | 0 → 7 | 0 → 7 |

> **Los dos 80 % de la primera entrega eran el bloque, y el mapa a mano los deshizo:** el hueso
> más cargado baja de 79,5 % a 21,0 % en el necromorfo y de 80,1 % a 23,7 % en el zombie, con
> siete huesos repartiendo en vez de uno. Lo que queda por ver en partida es si los miembros se
> mueven por su cuenta y si los lados están cruzados.

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
