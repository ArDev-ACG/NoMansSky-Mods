# Acuerdos

**Decisiones ya aprobadas en partida. No se tocan sin que lo pidas.**

Existe por un fallo concreto: la `HT_ScuttlerMesh_PRUEBA14` reinjertó el nodo de malla sobre
el `.SCENE` **vanilla** y con eso resucitó el `AttackLight` que la `PRUEBA13` había dejado
muerto. El SkrullCrawler volvió a salir con el ojo encendido y nadie se enteró hasta verlo en
el juego, **dos pruebas después**. La causa no fue el descuido: fue que el acuerdo vivía en un
paso a mano y nada lo comprobaba.

**Por eso cada fila dice tres cosas: qué se acordó, dónde vive ahora, y quién lo comprueba.**
Un acuerdo cuyo «quién lo comprueba» sea *nadie* es un acuerdo que se va a perder.

Actualizado: **2026-09-05**, con la vuelta que **congela los dos modelos** y cierra la
presión. Lo aprobado ese día entra como `B16`, `B17` y `B18`.

---

## 1 · Los que ya tienen guarda

| # | Qué se acordó | Por qué | Dónde vive | Quién lo comprueba |
|---|---|---|---|---|
| **A1** | El **`AttackLight` va apagado**: `FALLOFF` 0, `INTENSITY` 0, `RADIUS` 0.0001 y `COL` 0,0,0 — los valores de `Light_pointLight1`, la luz inerte que el propio vanilla trae en esa escena | Es un punto de luz de 360° colgado de la mandíbula, amarillo verdoso puro (0.861, 1.0, 0.0) con radio 4,47. El bicho vanilla es rojo oscuro y se lo traga; nuestras pieles tienen blancos y rojos claros y lo devuelven, así que el Horror sale dorado y con el ojo encendido. Aprobado en la `PRUEBA13` | `apagar_luces()` en [`../tools/Graft-NMSScene.py`](../tools/Graft-NMSScene.py), dentro del injerto | `_revisar_acordados()` en [`../tools/Check-NMSGraft.py`](../tools/Check-NMSGraft.py) → bloque **ACUERDOS PERDIDOS** y **salida 1** |
| **A2** | El **techo de 16 bits**: `VertexCount` ≤ 65 536 con `Indices16Bit=1` | NMSDK exportó 69 261 vértices con la bandera puesta y sin una queja. Son índices que dan la vuelta | El presupuesto de triángulos en `tools/Decimate-NMSMesh.py` | `Check-NMSGraft.py`, salida 1 |
| **A3** | **Ningún índice del `.SCENE` fuera de su array del `.GEOMETRY`** | Con los índices pasados el juego cierra sin avisar. Pasó en la `PRUEBA05` | El injerto | `Check-NMSGraft.py`, salida 1 |
| **A4** | **Las aristas de UV no cruzan más del 10 % del atlas** | El index buffer que NMSDK escribía era el de *antes* de partir los vértices de costura: 6 537 vértices muertos en el SkrullCrawler y la piel a remolinos | El parche de `mesh_parser` en [`../tools/Export-NMSMesh.py`](../tools/Export-NMSMesh.py) | El propio `Export-NMSMesh.py`, con un `assert` que revienta el export |
| **A5** | **Los pesos cuelgan de la columna** y **ninguna punta de miembro se lleva más de la mitad del tronco**, y el **reparto va pareado izquierda/derecha** | Son los tres números que separaron los dos pesados malos (`PRUEBA12`, 82 % en dos puntas con `RootJNT` al 0,4 %; `PRUEBA14`, `LFirstLeg3JNT` 12,1 % contra `RFirstLeg3JNT` 0,0 %) | [`../tools/Weight-NMSMesh.py`](../tools/Weight-NMSMesh.py) | Tres `assert` medidos **contra el propio vanilla en la misma corrida** |

---

## 2 · Los que viven en una constante, y hay que leerlos antes de tocarla

**Ninguno de estos tiene guarda automática.** Cambiar el número es cambiar el acuerdo.

| # | Qué se acordó | Por qué | Dónde vive |
|---|---|---|---|
| **B1** | El **necromorfo mide 3,62 m**, o sea **el doble** del AABB del `FIEND` vanilla (1,8098) | La `HT_FiendMesh_PRUEBA01` se midió a la altura del vanilla y **«se veía enano»**: el FIEND es bajo pero mide 5 m de largo. Rehecho a 3,62 y redesplegado. ⚠️ **Tiene un precio que no se midió hasta el 02/09: ver `B10`** | `alto` en `MODELOS["necromorph"]`, [`../tools/Export-NMSMesh.py`](../tools/Export-NMSMesh.py) |
| **B2** | El **zombie mide 2,43 m** | Misma razón; el `ArthropodThorax` vanilla sólo mide 0,84. ⚠️ **Mismo precio: ver `B10`** | `alto` en `MODELOS["zombie"]` |
| **B10** | **El tamaño lo decide la partida, no la cobertura del esqueleto.** El warrior bug mide **2,70 m** y el cry wolf **2,85 m** — cerrado el 03/09 y **no se vuelve a tocar**. La cobertura sigue siendo un dato a mirar, pero **no es el que manda** | **El precio de `B1` y `B2`, medido el 02/09 y no antes.** El esqueleto del `FIEND` mide **1,34 m** y el del `ARTHROPOD` **1,05 m**. A 3,62 y 2,43 **más de la mitad de la malla queda por encima del último hueso** —59,5 % y 60,7 %—, y ahí el pesado por vecino más cercano no encuentra nada más que tronco: `RootJNT` se llevaba el **62,8 %** contra un tope de 25,5, y `spine_C0_0_jnt` el **43,0 %** contra 39,3. **Es la misma causa que se leyó ocho pruebas del necromorfo y diez del zombie como «es que son bípedos»**: el bipedismo lo agravaba, pero lo que rompe es la escala. A 1,80 y 1,90 el esqueleto cubre el 70-75 %. **Y la regla «1,4-1,7×» que aquí ponía duró un día**: el 02/09 se probaron a 3,60 y 3,80 —demasiado grandes— y el 03/09 quedaron en 2,70 y 2,85, o sea **2,6× y 2,1× el esqueleto**, muy por encima de aquel tope, y **el pesado pasa igual**. Lo que lo hace pasar es el **mapa a mano** —va en coordenadas normalizadas y no cambia con la escala— más el tope de vaivén re-medido: ver `B14`. La cobertura explicaba el fallo del **vecino más cercano**, no pone un límite de tamaño | `alto` en `MODELOS`, [`../tools/Export-NMSMesh.py`](../tools/Export-NMSMesh.py) |
| **B11** | 🆕 **El giro se comprueba en FRENTE, no sólo en altura**: la parte alta de nuestra malla tiene que caer en la misma `w` que la cabeza del vanilla | El assert de orientación mide **altura** —`RootJNT` por encima de las puntas— y por eso **no puede cazar un bicho montado mirando hacia atrás**. Pasó en los dos: el cry wolf tenía su cabeza en `w 0,05` y `NewHeadJNT` en `w 1,51`, y el warrior bug `w 0,38` contra `w 0,84`. Se cambió a `giro` **`(-90, 0)`**… **y era al revés: en partida los dos salieron DE ESPALDA con el `0`.** El volcado medía el décimo superior de la malla, y en un insecto eso son las patas levantadas, no la cabeza. **Queda `(-90, 180)` en los cuatro modelos, y la regla es que el giro no lo confirma un volcado, lo confirma una entrada al juego** | `giro` en `MODELOS`, `Export-NMSMesh.py`. **Sin guarda automática: el volcado sólo sirve para descartar** |
| **B12** | 🆕 **Fuera el color de vértice antes de exportar** | NMSDK exporta la capa de color como **canal 4**, cuatro bytes por vértice: el `.GEOMETRY` sale a **stride 12 con `[2, 3, 4]`** en vez de 8 con `[2, 3]`. Con eso `Skin-NMSGeometry.py` aborta —y hace bien, porque los offsets de los canales 5 y 6 los cuenta desde ahí— y el vanilla ni lee ese canal: declara `[2, 3, 5, 6]`. Lo trajo el FBX del cry wolf | El bucle sobre `color_attributes` en [`../tools/Export-NMSMesh.py`](../tools/Export-NMSMesh.py) |
| **B15** | 🆕 **El `JointBindings` del vanilla sólo vale si nuestra malla está modelada en la postura en que se pesó la suya** | Es la inversa de la pose de mundo **en que se pesó la malla**, no una constante del hueso. En el cry wolf desplazaba la cabeza **1,69 m**, y de ahí salían las dos quejas del 04/09: el tope de vaivén se apretó para tapar el destrozo hasta que **ninguna pata mandaba en un vértice**, los pies colgaban un **70,6 % del torso** y el bicho iba tieso y flotando. El reposo del `.SCENE` **no** es el sustituto: sale peor (tensión 87 contra 35). Lo que vale es la inversa del vanilla en **un fotograma de un clip**, elegido midiendo | `--bind <ANIM>#<fot>` en [`../tools/Patch-NMSGraft.py`](../tools/Patch-NMSGraft.py). El fotograma se barre con [`../tools/Pose-NMSMesh.py`](../tools/Pose-NMSMesh.py) |
| **B13** | 🆕 **Tras `Patch-NMSGraft.py` hay que BORRAR el `.GEOMETRY.MBIN.PC` antes de recompilar** | **MBINCompiler no sobrescribe**: si el `.MBIN.PC` ya existe se salta la conversión **sin decir nada** y el `.MBIN` desplegado se queda con los `JointBindings` vacíos que dejó NMSDK. Y **`Check-NMSGraft.py` da salida 0 igual**, porque lee el `.MXML`. Se caza por tamaño: el crudo de NMSDK son 3 353 y 4 677 bytes, el parcheado ~14 000 | Paso a mano. **Sin guarda: `Check-NMSGraft.py` debería comparar el `.MBIN.PC` contra su `.MXML`** |
| **B14** | 🆕 **Cambiar `alto` obliga a re-medir el tope de vaivén, y el mapa de regiones se espeja si cambia el giro** | Dos cosas que sólo se ven al tocar la escala. **El mapa a mano va en coordenadas normalizadas de nuestra caja**: la escala no lo toca, pero `Ry(180)` **espeja `u` y `w`** —sin espejar los cortes, la región de la cabeza del bug cazaba la punta del abdomen y `spine` subía al 92,2 % contra un tope de 85—. **El tope de vaivén sí escala**, porque el vaivén es giro × palanca y el esqueleto del juego no crece con nosotros: la cabeza del bug va 4,4× a 1,80 m, 5,4× a 2,70 y 7,0× a 3,60. Con el tope quieto, agrandar el bicho **lo deja tieso**. El número nuevo es una **ventana** que se lee en la columna `todos` de la propia corrida, y dentro de ella se elige con `Pose-NMSMesh.py` | `objetivo` y `regiones` en `MODELOS`, [`../tools/Weight-NMSMesh.py`](../tools/Weight-NMSMesh.py). Tabla por altura en [`RECETA-PIEL.md`](RECETA-PIEL.md) §3 |
| **B3** | El **pesado NO reescala el esqueleto** en esos dos: `escala_piel = 1.0` | Los `JointBindings` se copian del vanilla en `Patch-NMSGraft.py`, así que **en partida nuestros vértices se leen en el espacio del vanilla, sin reescalar**. Casar contra un rig hinchado es casar contra huesos que en partida están en otro sitio. Con ×2,0008 `RootJNT` se llevaba el 63,7 % | `escala_piel` en `MODELOS`, [`../tools/Weight-NMSMesh.py`](../tools/Weight-NMSMesh.py) |
| **B4** | El **tope de reparto es ABSOLUTO (85 %)** en el necromorfo y el zombie, y relativo al vanilla sólo en el SkrullCrawler | Un bípedo cuelga casi entero de la columna; una araña reparte la masa entre cabeza y ocho patas. El `FIEND` pone su máximo en `RootJNT` con el **20,4 %** y el `ARTHROPOD` en `head_C0_0_jnt` con el **31,4 %**: el tope relativo **no lo puede pasar ningún pesado de un bípedo, ni el bueno** | `tope_reparto` en `MODELOS` |
| **B4b** | El **necromorfo y el zombie llevan mapa a mano región → hueso**, y con él el tope de punta se sustituye por «el reparto no se separa más de 5 puntos del mapa» | Copiar del vecino más cercano sólo vale entre dos bichos del mismo tipo de animal. La piel del vanilla cabe entera en la **mitad de abajo** de las dos mallas, así que nuestros brazos y nuestra cabeza no tenían cerca más que cuerpo: un solo hueso con el 79,5 % y el 80,1 % | `regiones` en `MODELOS`, [`../tools/Weight-NMSMesh.py`](../tools/Weight-NMSMesh.py). El mapa sale de `--volcar-huesos`, **no se adivina** |
| **B4a** | **Recoser la piel BORRA el `_F02_SKINNED` y los samplers reapuntados**, así que el paso 5 se repite SIEMPRE y `Check-NMSGraft.py` se corre **otra vez** después | `Skin-NMSGeometry.py` copia la carpeta de origen entera y la de origen no lleva ninguna de las dos cosas. Costó la `PRUEBA05` de los dos bípedos: sin el flag el juego **no aplica el esqueleto**, así que el bicho sale rígido **y por eso mismo no se estira** — parece que el pesado ha mejorado cuando lo que pasa es que ya no se pesa. **Estirado = el flag está y los pesos están mal; rígido = el flag no está** | `tools/Flag-NMSMaterial.py`, `tools/Set-NMSSampler.py`, y el `assert` de material de [`../tools/Check-NMSGraft.py`](../tools/Check-NMSGraft.py) |
| **B4c** | Un **miembro cuelga del primer eslabón CON CLAVES DE ANIMACIÓN**, no del primero de la cadena. El **tronco** sí puede colgar de uno quieto | Estar en el `SkinMatrixLayout` dice que el vanilla le pega piel; **no** dice que el hueso se mueva. Los seis `legbase_*` del `ARTHROPOD` están en la paleta y **no tienen ni una clave** en `WALK`, `RUN`, `IDLE` ni `ATTACK01`: la `PRUEBA05` colgó de ellos el **52,2 %** del zombie y entró **rígido**, girando los mismos 4,0° de mundo que el torso. Un hueso quieto no está congelado —hereda al padre—, y por eso un torso sí puede usarlo | `sin_claves` en `MODELOS` y su `assert`, [`../tools/Weight-NMSMesh.py`](../tools/Weight-NMSMesh.py). Se lee del `.ANIM`, **no del `.SCENE`** |
| **B5** | El **`gMasksMap` se INVIERTE, no se atenúa** | El asset entrega `roughness` (alto = áspero = mate) y el shader lee ese canal como **brillo** (alto = mojado). `255 − 173,6 = 81` contra los **85** del vanilla. Atenuar dejaría las grietas brillantes y los bultos mates: el mismo mapa del revés, sólo que más flojo | `--invertir` de `Make-NMSTexture.py`, y el hueco de UV retenido a 0 aparte |
| **B6** | **Triángulos: necromorfo 30 000, zombie 36 000** | `M-CONFETI`. A 5 999 la textura salía a confetti porque estos atlas vienen **horneados por triángulo** | `tools/Decimate-NMSMesh.py` |
| **B7** | Las texturas del zombie van a **rutas propias** (`ZOMBIE.BASE*.DDS`), no a las del `ARTHROPOD` | `ARTHROPODTHORAX01.BASE*.DDS` las comparte **toda la fauna artrópodo del juego**. Lo que se reapunta es el material, que sí es exclusivo del `BUGFIEND` | El `.lua` y `tools/Set-NMSSampler.py` |
| **B8** | El **`.DESCRIPTOR` del `BUGFIEND` va recortado a una entrada**, `_Arthropod_1` sin hijos | Con los diez nodos MESH borrados por el injerto, el descriptor completo cerraba el juego al parir el Horror | `work/models/zombiemesh/BUGFIEND.DESCRIPTOR.MBIN` |
| **B9** | El **nido del techo enciende `IncreaseFiendWanted`**, y la `PRUEBA03` escribe **también** los otros dos campos del `Infestation` (`AgroTorch` 12, `GunfireAgro` 8) | Los dos mods escriben el mismo `MEDIUMHANGSLIME.ENTITY.MBIN` y **el que carga después gana entero y en silencio**. Resuelto por superconjunto: los dos escriben el MISMO MBIN | `HT_CeilingPlague_PRUEBA03.lua` y los cuatro `Infestation` |
| 🆕 **B16** | **La malla del cry wolf está CONGELADA en la `HT_CryWolf_PRUEBA07`** — geometría, pesos y bind | Aprobado en partida el **05/09**: «dejamos ya las pruebas con el lobo como está ahorita in game». Cierra siete pruebas. El bind es `--bind fiendwalk#24` y el `.SCENE` es el de la `PRUEBA05`, md5 `2c30d9cf` | [`../work/scripts/malla/HT_CryWolf_PRUEBA07.lua`](../work/scripts/malla/HT_CryWolf_PRUEBA07.lua) |
| 🆕 **B17** | **La piel del warrior bug está CONGELADA**, atlas de **4096** con celdas de 1024 | Aprobado el **05/09**: «no hubo mucho aumento». Cierra `Q-TEXBUG` **por descarte** — con el 18 % del atlas pintado, ×4 píxeles no se ven, así que **la resolución no era el techo** y subir a 8192 tampoco lo sería. Lo que queda por mirar es el material o la luz | [`../work/scripts/malla/HT_WarriorBug_PRUEBA05.lua`](../work/scripts/malla/HT_WarriorBug_PRUEBA05.lua) |
| 🆕 **B18** | **La presión está TERMINADA: no se suben más contadores, alcance, cadencia ni drenaje** | Aprobado el **05/09** al cerrar la `0.8.0` («si tal vez percibí más agresividad»). Once vueltas subiendo presión y la queja de fondo —se desenganchan— no se movió ni una vez. De aquí en adelante las vueltas de conducta van al **desenganche** | Las 36 palancas, en [`MODIFICACIONES.md`](MODIFICACIONES.md) |

---

## 3 · Los de forma, que no son técnicos pero también se pierden

| # | Qué |
|---|---|
| **C1** | `MOD_AUTHOR` es **`AldrichDDD`**, no el usuario de git |
| **C2** | Los `.lua` van **sin comentarios de código**: la explicación va a `docs/` y al `MOD_DESCRIPTION` |
| **C3** | Los nombres de release van en **camelCase y en inglés**, un `.lua` por zip; se traduce sólo al empaquetar |
| **C4** | Cada mod **versiona aparte**: uno nuevo arranca en 0.1.0 aunque reutilice otro |
| **C5** | El `.EXML` de `CreatedMODS` es un **informe**: lo que despliega son los `.MBIN` de `ModBackups` |
| 🆕 **C6** | **Una pregunta se cierra igual por descarte que por acierto**, y se anota igual de largo. `Q-TEXBUG` cerró el 05/09 diciendo «la resolución no era», y eso vale para los cuatro modelos: ahorra las vías (a) y (c) enteras |

---

## 4 · Cómo se añade uno

1. Se mide en partida y se aprueba.
2. Se mueve **fuera del paso a mano**: a un `tools/*.py` que lo haga solo.
3. Se le pone guarda en `Check-NMSGraft.py` si el acuerdo se puede leer del `.SCENE` o del
   `.GEOMETRY`, o un `assert` en el guion que lo produce si no.
4. Se anota aquí, con el número que lo justifica.

> **Un acuerdo sin el paso 3 va a la sección 2, y la sección 2 hay que leerla entera antes de
> tocar cualquier constante.**
