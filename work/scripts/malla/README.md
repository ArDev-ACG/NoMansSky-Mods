# `malla/` — las series `HT_EggMesh` y `HT_ScuttlerMesh`

Geometría nuestra dentro del juego, por la vía Blender + NMSDK. **Dos series, 18 `.lua`**:
cinco de `HT_EggMesh` (el obelisco, Etapa 2) y trece de `HT_ScuttlerMesh` (el bicho, Etapas 3
y 4).

**Dentro de cada serie los `.lua` escriben los mismos archivos y no pueden convivir**: cada
uno sustituye al anterior. Entre series sí conviven — tocan mallas distintas. En el juego
están la `HT_EggMesh_PRUEBA05`, la `HT_ScuttlerMesh_PRUEBA13` y la `HT_FiendMesh_PRUEBA02`;
el resto, en `GAMEDATA\MODS_Retirados\`.

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
| `PRUEBA12` | **Piel + normal propio.** El buffer a stride 20 con los canales 5 y 6, `_F02_SKINNED` de vuelta en `FFIENDMAT` y el `gNormalMap` propio | 🏁 **la piel pasó el 20/08 — cierra la Etapa 4.** El bicho se deforma con el `SPIDERRIG` y el movimiento es natural. 🔴 **el normal no**: se ve húmedo, como baba, y la nuca sale con la textura estirada |
| `PRUEBA13` | **`M-BABA`.** Las mismas máscaras con el canal **invertido**, y el fondo de UV sin usar retenido a 0. Un solo archivo cambia; los otros siete son byte a byte los de la `12` | 🟡 **construida y desplegada el 22/08, sin medir** |
| `PRUEBA14` | **`M-UVIDX`.** El **index buffer** arreglado: NMSDK serializaba el de **antes** de partir los vértices de costura. Las cinco texturas y el material van byte a byte los de la `13` | 🏁 **medida el 25/08 y parte en dos.** ✅ **De frente, perfecta**: cráneo, ojos y pinzas se leen, la textura es continua y no queda un solo dibujo de estrella — `M-UVIDX` y `M-BABA` cerrados. 🔴 **Por detrás no**: la espalda sale como una lona negra con tiras planas y astillas rectas → `M-PALETA` |
| `PRUEBA15` | **`M-ESTRELLA`.** El color base con el hueco de UV derramado desde la isla vecina | ⬜ escrita el 24/08 y **nunca construida**. La adelanta la `PRUEBA16`: los dibujos de estrella ya no estaban en las capturas de la `14`, así que esto se queda sin síntoma que medir |
| `PRUEBA16` | **`M-PALETA`.** Los canales 5 y 6 rehechos: candidatos del `SkinMatrixLayout` vanilla, copia de los **8** vecinos de la piel vanilla y **12** pasadas de suavizado por nuestras aristas. Sólo cambian los tres archivos de geometría | 🟡 **cosida el 26/08, sin construir.** 14 huesos, todos subconjunto de los 19 del vanilla; `RootJNT` 43,5% contra 45,9%; asimetría 0,026 contra 0,000; `Check-NMSGraft` salida 0 |

> **Las dos cosas de la `PRUEBA12` fueron en el MISMO `.lua` y las midió una sola entrada al
> juego, y el desempate escrito de antemano acertó**: el bicho salió **bien plantado y con la
> textura rara**, que era la firma de «la piel bien, la textura no». Los tres `.MBIN` con piel
> salen de
> `python tools/Skin-NMSGeometry.py work/models/scuttlermesh work/models/scuttlermesh_anim`,
> y **no se entra al juego sin que `tools/Check-NMSGraft.py` dé salida 0**: con los índices de
> hueso fuera de rango el juego cierra sin avisar, y ya pasó en la `PRUEBA05`.

> **La `PRUEBA11` es la línea base.** Siete `ADD_FILES`: el `.SCENE` injertado, los dos
> `.GEOMETRY`, `FFIENDMAT`, las dos `.DDS` propias y la lista procedural vaciada. Cualquier
> prueba nueva **parte de estos siete archivos** y solo cambia lo que vaya a medir.
>
> **La `PRUEBA12` partió las dos en seco: `M-ANIM` pasó y `M-TEX` no.**
>
> | ID | Veredicto del 20/08 |
> |---|---|
> | **`M-ANIM`** | 🏁 **cerrado.** El bicho se deforma con el `SPIDERRIG`. La receta de `RECETA-PIEL.md` queda validada en partida |
> | **`M-TEX`** | 🔴 **el normal propio no arregla el aspecto: lo empeora.** Se ve húmedo, como baba, en vez de hueso y piel |
>
> **Y el normal no es el sospechoso, medido después.** Nuestro `SKRULLCRAWLER.BASE.NORMAL.DDS`
> tiene desviación **17,8**, y el vanilla **17,2**: el relieve es el correcto. El que se sale
> de rango son **las máscaras** — `ATI1` de un canal, media **174** contra los **85** del
> `FIEND` vanilla, el doble de brillo. Baja a `PENDIENTES.md` §2 como `M-BABA`, y de paso le
> pone datos a la pregunta `Q-MASCARAS`.
>
> Aparte, la nuca sale con **la textura estirada** — de frente está bien y no hay desgarro de
> malla, así que es UV. Es `M-NUCA` en la misma cola.

> **La `PRUEBA13` corrige el diagnóstico de `M-BABA`, medido de nuevo el 22/08.** No es que
> nuestras máscaras estén flojas: **vienen al revés**. El asset entrega `roughness` —alto =
> mate— y el shader lee brillo —alto = mojado—, y `255 − 173,6 = 81` contra los `85` del
> vanilla. Por eso se invierte y no se atenúa. El detalle que no hace el `--invertir` del
> conversor: el **13,3 %** de UV sin usar está a 0 e invertirlo lo pondría a 255, brillo máximo
> sangrando por los mips, así que el PNG se prepara aparte con
> `np.where(rough <= 2, 0, 255 - rough)`. Los números y el porqué, en
> [`../../../docs/PENDIENTES.md`](../../../docs/PENDIENTES.md) §2.1.

> **Y `M-NUCA` no es el presupuesto de triángulos.** Medido el 22/08: el FBX del SkrullCrawler
> trae **9 592** triángulos y la malla del juego trae los mismos **9 592**. Este bicho **nunca
> se decimó** —entró por el conducto manual, antes de que existiera `Decimate-NMSMesh.py`—, así
> que el colapso de UV que puso a confeti al necromorfo y al zombie no le aplica, y subirlo a
> 30 000 no es posible.

> **De paso, el SkrullCrawler ya no depende del conducto manual.** `tools/Export-NMSMesh.py`
> tiene ahora su entrada —`giro (-90, 180)`, `alto 1.85069`, nodo `polySurface6`—, y se
> comprobó corriéndola: sale con **9 592 triángulos y 11 357 vértices**, y caja
> **2,6367 / 1,8507 / 2,7676**, que son los mismos números que la malla desplegada. Las once
> primeras pruebas se hicieron a mano; ahora se rehacen con una orden.
>
> ⚠️ Con una diferencia de **2 cm**, y conviene saberla antes de usarla: el guion **asienta los
> pies en `Y 0`** y la malla que está en el juego va de `−0,020806` a `1,829884`, que es el
> `AABB` del vanilla copiado tal cual. Es la convención del guion, la misma que el `FIEND`, y
> no se ha tocado nada para que coincida.
>
> Y falta un tercer detalle, más pequeño: el injerto perdió el nodo `SUB1polySurface6` con
> `FFIENDEYEMAT`, **el ojo**.

> **La `PRUEBA14` cierra `M-NUCA`, y no era ni UV ni presupuesto de triángulos: era el
> exportador.** Leído en el código de NMSDK y medido en el `.GEOMETRY.DATA` desplegado.
> `mesh_parser` **sí** parte bien los vértices de costura —4 820 pasan a 11 357, uno por cada
> combinación de vértice y UV— y devuelve **dos** listas de índices:
>
> | | Qué es |
> |---|---|
> | `indexes` | Ya remapeada a los vértices partidos. **La buena** |
> | `np_indexes` | `data.loops.foreach_get("vertex_index")`, o sea la de **antes** de partir |
>
> y `export.py` serializa **la segunda**. En el archivo que está en el juego: 11 357 vértices
> en el buffer, **índice máximo usado 4 819**, o sea **6 537 vértices que no apunta nadie**.
> Cada vértice de costura se queda con la **primera** UV que le tocara, y en el atlas de Meshy
> —cientos de islas diminutas— esa primera UV es de otra isla cualquiera.
>
> | | Desplegado (`PRUEBA13`) | FBX de Meshy | `PRUEBA14` |
> |---|---:|---:|---:|
> | Vértices en el buffer | 11 357 | — | **7 627** |
> | Vértices que nadie apunta | **6 537** | — | **0** |
> | Arista de UV más larga | **1,2574** | 0,0582 | **0,0583** |
> | Aristas por encima de 0,10 | **30,89 %** | 0,00 % | **0,00 %** |
> | Correlación arista 3D ↔ arista UV | **0,044** | — | **0,804** |
>
> **La malla en 3D salía perfecta** —aristas de 6 cm de mediana, ninguna larga— porque los
> índices `0..4819` sí apuntan a las posiciones buenas. Por eso el bicho se veía **bien
> plantado y solo la piel a remolinos**, y por eso los dibujos de estrella con anillos del
> cráneo eran **bordes de isla de UV**, no relieve.
>
> **De paso, las normales.** NMSDK escribe `poly.normal` —la normal de **cara** de la primera
> cara que tocó el vértice—, ignorando las que Blender ya tiene calculadas: error mediano de
> **21,6°** y un **2,7 %** de vértices apuntando al revés. Con las de Blender quedan en
> **8,1°** y **0,52 %**.
>
> Se parchea desde `tools/Export-NMSMesh.py` y **no se toca el addon**, que vive en `AppData`
> y se pierde al reinstalarlo. El guion trae además un `assert`: si alguna arista de UV cruza
> más del 10 % del atlas, el export **revienta** en vez de escribir la malla mala.
>
> ⚠️ **La `PRUEBA14` cambia una segunda cosa, y hay que saberla para leer el resultado.** Al
> rehacer el export con el guion, la malla se asienta con los **pies en `Y 0`** en vez de en
> `−0,020806`. Son **2,08 cm**, siete veces la tolerancia de 0,003 con la que
> `Skin-NMSGeometry` casa los pesos, así que `pesos.json` se ha rehecho contra el `.blend`
> nuevo —y con el pesado por hueso más cercano de `d3bfd2d`—, y la paleta pasa de **14** huesos
> a **42**. Si la piel sale bien pero el bicho se deforma raro al andar o al morir, lo que
> falló es **la paleta**, no el index.
>
> **Y `tools/Weight-NMSMesh.py` apunta ahora a `scuttler30k.blend`**, que es el `.blend` que
> deja `Export-NMSMesh.py`. Pesar contra `scuttler.blend` —el del conducto manual— no casaba
> ni un vértice, por esos mismos 2 cm.

> **La `PRUEBA16` cierra `M-PALETA`, y son DOS causas con un solo síntoma.** Las capturas del 25/08
> parten la `PRUEBA14` en dos: de frente pasa entera, por detrás sale una lona negra con astillas.
>
> **Primera causa: se pesaba contra huesos a los que el juego no pega piel.** El `.SCENE` del
> FreighterFiend trae 114 huesos y **su piel sólo se pega a 19**, y esos 19 están escritos en el
> `SkinMatrixLayout` de su `.GEOMETRY`. La `PRUEBA14` pesaba contra los 113 del esqueleto:
>
> | | Vértices | Qué hueso es |
> |---|---:|---|
> | `NewJawJNT` + `NewJawEND` | 425 | mandíbula |
> | `NewTail2/3/4JNT` | 882 | cola |
> | `LThirdLeg3JNT` + `LThirdLeg4END` | 626 | pata tercera, **sin pareja derecha** |
> | `REyelidLowerJNT`, `LEyeParentJNT`, `LowerLMouthJNT`, `LPincer4JNT` | **1 cada uno** | párpado, ojo, boca |
>
> **30 de los 42 grupos caían fuera de la lista del vanilla.** Un vértice colgado de un párpado sale
> disparado en cuanto el bicho parpadea: eso son las astillas.
>
> **Segunda causa, y es la MISMA que mató a la `PRUEBA12`:** adjudicar a **un ganador** entre huesos
> que están casi a la misma distancia. El FreighterFiend es una araña de patas largas y cuerpo pequeño
> y el nuestro es compacto, así que sus patas atraviesan nuestro volumen. Una franja del torso se va
> con una pata, la de al lado se queda con la espalda, y al andar la costura entre las dos se tensa.
> **Eso es la lona**, y por eso el síntoma se escribió las dos veces con las mismas palabras.
>
> | | Método | Lo que dio |
> |---|---|---|
> | `PRUEBA12` | punto más cercano de la **superficie** vanilla | las dos puntas delanteras con el **82%** y `RootJNT` con el 0,4% |
> | `PRUEBA14` | distancia al **segmento** de cada hueso | `LFirstLeg3JNT` **12,1%** y `RFirstLeg3JNT` **0,0%** |
>
> **Dos hipótesis descartadas con números, para no volver a mirarlas.** El `GIRO_Z` no es: los cuatro
> giros —0, 90, 180 y 270— fallan igual, y ninguno pasa del **4,8%** en `NewHeadJNT` cuando el vanilla
> le da el **27,5%**. Y la distancia del vértice a su hueso tampoco: **el vanilla contra su propio
> esqueleto da 1,039** de media sobre una diagonal de 4,22, *peor* que los 0,903 del método que
> fallaba. Lo que sí separa es **la simetría** — el reparto del vanilla está pareado al vértice,
> `RFirstLeg3JNT` 260 y `LFirstLeg3JNT` 260, y da **0,000**; la `PRUEBA14` daba **0,253**.
>
> **El arreglo son tres pasos y ninguno inventa un número:**
>
> ```
> 1. candidatos = SkinMatrixLayout del .GEOMETRY vanilla   19 de 113
> 2. cada vertice promedia los 8 vecinos de la piel vanilla, peso 1/distancia
> 3. 12 pasadas de promedio por las aristas de NUESTRA malla
> ```
>
> El paso 3 es el que ataca el fallo de frente: **una lámina tensada ES un salto de peso entre dos
> vértices unidos por una arista**, y es lo único que devuelve al torso la trasera que las patas se
> llevan, porque ahí no hay nada del vanilla que copiar salvo pata.
>
> | | `PRUEBA14` | `PRUEBA16` | El vanilla |
> |---|---:|---:|---:|
> | Huesos con peso | 42 | **14** | 19 |
> | Fuera de la paleta vanilla | **30** | **0** | — |
> | Mayor reparto | 35,1% `NewBack1JNT` | **43,5%** `RootJNT` | 45,9% `RootJNT` |
> | Asimetría | **0,253** | **0,026** | **0,000** |
> | Influencias por vértice | 1,02 | **1,96** | 1,05 |
>
> ⚠️ **Los topes del guion se recalibraron contra el vanilla, y uno de ellos estaba mal desde el
> 15/08.** `TOPE_REPARTO` rechazaba a 0,35 lo que el propio juego hace al 45,9%, y `TOPE_PUNTA` medía
> fracción de vértices, que **no es comparable entre las dos mallas**: el vanilla amontona el 73% de
> los suyos en el cuerpo y la nuestra, que sale de decimar, los reparte parejos. Ahora se mide contra
> el tronco — el fallo del 15/08 era 43,2% de punta con el tronco al 0,4%, o sea la punta **cien veces
> el tronco**.

## La serie `HT_FiendMesh` — el necromorfo en el Horror de superficie

Tercera ranura, y la primera que **no** se hizo a mano: el cuerpo del `FIEND`
(`SPIDERRIG\FIEND.SCENE.MBIN`), que es también el del `MINIFIEND` porque
`CREATUREFILENAMETABLE` manda los dos al mismo modelo.

| `.lua` | Qué entrega | Estado |
|---|---|---|
| `HT_FiendMesh_PRUEBA01` | La malla **rígida** + atlas de color y normal propios | ✅ **salió el 21/08**: entero, de pie y con los colores en su sitio. 🔴 **se veía pequeño** — se midió a la altura del AABB vanilla (1,81 m) y ese bicho es bajo pero **5 m de largo**, así que al lado se ve enano. Rehecho a **3,62 m** y redesplegado |
| `HT_FiendMesh_PRUEBA02` | **La misma malla y la misma textura**, decimada a **30 000** triángulos en vez de 5 999 | ⬜ desplegado el 21/08, `Check-NMSGraft` en **salida 0**. Sin medir. Mide si el color deja de salir a confeti: el asset viene horneado **por triángulo** y se entregaba el 2,2 % de la malla. **30 000 y no más** porque a 36 000 el export dio 69 261 vértices con `Indices16Bit`, cuyo techo son 65 536 |

**Lo que la serie del SCUTTLER costó descubrir, aquí ya viene hecho.** Las once pruebas de
`HT_ScuttlerMesh` se comprimen en una porque los cinco pasos previos a la piel quedaron
automatizados el 2026-08-20 — están en [`../../../docs/RECETA-PIEL.md`](../../../docs/RECETA-PIEL.md)
§2, en el recuadro `0a` a `0e`. Dos guiones son nuevos:

| Herramienta | Qué resuelve |
|---|---|
| `tools/Atlas-NMSMesh.py` | NMSDK exporta **un** material por objeto, y el necromorfo viene en 22 piezas con 7 colores base. Funde las 7 en un atlas de 2048² y mueve las UV de cada pieza a su celda |
| `tools/Graft-NMSScene.py` | Los 17 atributos del nodo de malla. La regla resultó corta: **son los arrays por malla del `.GEOMETRY` dichos otra vez**. Borra además los nodos `MESH` sobrantes, que se quedarían indexando un stream que no existe |

> ⚠️ **El `.SCENE` que exporta NMSDK trae el AABB rancio** — el de antes de mover la malla,
> porque `ob.bound_box` está cacheado y en segundo plano nadie reevalúa el depsgraph. El
> `.GEOMETRY` del mismo export sí lo trae bien. **Se cree al `.GEOMETRY`**, y por eso
> `Graft-NMSScene.py` no lee ni un valor del `.SCENE` de NMSDK.

> ⚠️ **El buzón `BLENDER/CUSTOMMODELS/MODELGROUP/` guarda TODAS las exportaciones** —
> `FIEND`, `FIENDEGG`, `SCUTTLER`, `SCENE`—. Un `glob` con comodín se trae la primera que
> pille: pasó, y el injerto salió con el `.DATA` de otro bicho. Se copia **por nombre exacto**.

**Choca con `HorribleTerror_NecroSkin`**, que escribe la misma `FIEND.BASE.DDS`.

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

## La serie `HT_ZombieMesh` — el zombie en la cría, y la primera ranura procedural

Cuarta ranura y **primera fuera del `SPIDERRIG`**: el cuerpo del `BUGFIEND`, la cría que el
Horror pare al rugir en Hardcore. Rig `ARTHROPOD`, 53 huesos, **once** nodos `MESH` y
`.DESCRIPTOR` propio.

| `.lua` | Qué entrega | Estado |
|---|---|---|
| `HT_ZombieMesh_PRUEBA01` | La malla **rígida** a 2,43 m + color y normal propios + el `.DESCRIPTOR` recortado | ⬜ desplegado el 21/08, `Check-NMSGraft` en **salida 0**. Sin medir |
| `HT_ZombieMesh_PRUEBA02` | **La misma malla y la misma textura**, decimada a **36 000** triángulos en vez de 5 999 | ⬜ desplegado el 21/08, `Check-NMSGraft` en **salida 0**. Sin medir. Aquí caben los 36 000 completos —salen 31 475 vértices— porque el asset trae **un** material y desenvuelto continuo: parte 0,87 vértices por triángulo contra los 1,92 del necromorfo |

**Lo nuevo aquí es el descriptor, y es lo único que puede cerrar el juego.** El injerto borra
diez de los once nodos `MESH`, y **siete de las ocho entradas del descriptor los nombran**. Si
se entrega la malla sin tocar el descriptor, queda nombrando nodos que ya no existen.

Dos cosas que se leyeron del vanilla y contradicen lo que se daba por supuesto:

| Se creía | Lo que dice el archivo |
|---|---|
| El `BUGFIEND` es procedural, o sea sale distinto cada vez | Es **determinista**: ocho grupos con **una sola opción** cada uno y `Chance 0.0`. La cría vanilla siempre es la misma |
| `ReferencePaths` está vacío en todos los descriptores (`Q-REFPATHS`) | **Aquí no**: los ocho apuntan a `ARTHROPOD.SCENE.MBIN`. Lo que estaba vacío eran los 172 del `TREX` |

El recorte deja el descriptor **con la forma exacta del `FIEND`**: un grupo, una entrada
—`_Arthropod_1`— sin hijos. Y el nodo que se conserva es `ArthropodThorax`, que **no figura en
el descriptor** y por tanto siempre está.

> **La escala salió de una regla, no de un gusto.** El necromorfo quedó bueno a 0,727 de la
> dimensión mayor del `FIEND` vanilla (3,62 sobre 4,98). La mayor del `BUGFIEND` es 3,34 de
> largo → **2,43 m**, que además lo deja claramente más bajo que el necromorfo, como toca
> para una cría.

> **Las texturas no pisan ninguna vanilla.** `ARTHROPODTHORAX01.BASE.DDS` lo comparte **toda
> la fauna artrópodo del juego**. En vez de sobrescribirlo, se reapunta el material —que sí es
> exclusivo del `BUGFIEND`, vive en su propia carpeta— a `ZOMBIE.BASE.DDS` y
> `ZOMBIE.BASE.NORMAL.DDS`, dos rutas nuevas.

> **Y este asset sí trae normal esculpido**: desviación **51,8**, contra los 17,2 del vanilla
> y los 4,7 del necromorfo generado desde la luminancia. Aquí no hay que fabricar nada.

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

En `tools/AMUMSS/ModScript/` van la `HT_EggMesh_PRUEBA05`, la `HT_ScuttlerMesh_PRUEBA12` y la
`HT_FiendMesh_PRUEBA02`; las demás, en `Disabled scripts and paks/`. **El build ya corre desatendido** con `tools/AMUMSS/BUILDMOD_AUTO.bat`, que tiene
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
