# Pendientes

**Solo dos cosas viven aquí: lo que está en el juego sin medir, y las preguntas sin
responder.** Lo comprobado no se repite aquí: se borra y se anota en el changelog que le
toque. Si buscas *por qué* se hizo algo, está en
[`CHANGELOG-MOD2.md`](CHANGELOG-MOD2.md).

**Cada fila lleva un identificador y el archivo donde se lee el detalle.** El identificador
es el nombre del `.lua` cuando la prueba tiene uno (`HT_EggMesh_PRUEBA03`), y un código corto
cuando es una pregunta y no un mod (`N1`, `Q-GLOW`).

Actualizado: **2026-08-27** (sexta vuelta: `M-PALETA` cerrado, `M3-PIEL` y `M4-PIEL`
entregados, y el `AttackLight` de vuelta a cero).

> 📌 **Lo ya aprobado, y que no se toca, vive en [`ACUERDOS.md`](ACUERDOS.md).** Se creó el
> 27/08 porque la `PRUEBA14` resucitó sin querer el `AttackLight` que la `PRUEBA13` había
> apagado, y nadie lo vio hasta dos pruebas después.

---

## 1 · En el juego ahora, sin medir

Construido **y desplegado** en `GAMEDATA\MODS`, verificado por md5. Las 22 pruebas que
chocaban están movidas a `GAMEDATA\MODS_Retirados\`, fuera de donde el juego lee.

**Dos cosas, y las dos tienen su firma escrita de antemano.**

| ID | Qué mirar |
|---|---|
| **`HT_ScuttlerMesh_PRUEBA17`** | **`M-OJO` — ¿se apaga el ojo del SkrullCrawler?** La malla **no se toca**: los dos archivos de geometría salen byte a byte como en la `PRUEBA16`, verificado con `cmp`, y lo único que cambia son **seis flotantes del `.SCENE`**. **Tres finales:** ojo apagado y espalda limpia → cerrado, y la `PRUEBA16` queda confirmada entera · ojo todavía encendido → no era el `AttackLight` y el sospechoso pasa a ser el emisivo horneado en el color base (`Q-GLOW`), que se mide en la textura · vuelve la lona de la espalda → **no se desplegó**, mirar la fecha del `.MBIN` |
| **`HT_FiendMesh_PRUEBA04`** | **`M3-PIEL` — ¿mueve el necromorfo brazos y piernas por separado?** Lleva `_F02_SKINNED`, normal rehecho, máscaras propias y **mapa a mano región → hueso**: 7 huesos, el mayor al **21,0 %** (era `RootJNT` al 79,5 %). **Tres finales:** miembros que se mueven por su cuenta → cerrado · brazos que van con las piernas → el mapa tiene los lados cruzados, se cambian `L` por `R` en las dos filas de `FirstLeg` · un trozo sale disparado → la frontera de esa región es dura y hay que subir `SUAVIZADOS` |
| **`HT_ZombieMesh_PRUEBA04`** | **`M4-PIEL` + la segunda mitad de `M-BABA` — ¿mueve los miembros y deja de verse mojado?** Mismo mapa a mano: 7 huesos, el mayor al **23,7 %** (era `spine_C0_0_jnt` al 80,1 %). **Tres finales:** se mueve y sale seco → cerrado, y con él `M-BABA` entero · sigue mojado → el canal no era brillo y hay que ir al material · el juego cierra al parir el Horror → el descriptor |
| **`HT_CeilingPlague_PRUEBA03` + `Infestation 0.6.5`** | **La segunda vuelta del nido.** La primera no brotó nada: ganó el `Infestation`, exactamente por la firma escrita de antemano. Ahora **los dos MBIN son byte a byte iguales**. Sigue **sin medir** desde el 21/08 |

> 🏁 **`M-BABA` y `M-UVIDX` cerrados el 2026-08-26 en el SkrullCrawler**, medidos en las cuatro
> capturas de la `PRUEBA14`. **De frente el bicho sale perfecto**: se leen cráneo, ojos y pinzas, la
> textura es continua y no queda ni un dibujo de estrella. La inversión del `gMasksMap` era la buena
> y el index buffer era la causa de los remolinos, las dos cosas confirmadas en partida.
>
> 🏁 **`M-PALETA` cerrado el 2026-08-27 con la `PRUEBA16`, confirmado por ti en partida.** La
> espalda deja de salir en lonas y astillas. Eran dos causas y las dos están arregladas en
> `tools/Weight-NMSMesh.py`: los candidatos salen del `SkinMatrixLayout` del vanilla —19 de 113,
> así que los párpados dejan de poder ganar— y cada vértice promedia los **8** vecinos más
> cercanos de la piel vanilla con 12 pasadas de suavizado por nuestras aristas, que quita el
> ganador único. **Esa versión del modelo es la que nos quedamos.**
>
> 🔴 **Pero la `PRUEBA14` se llevó por delante otra cosa, y tardó dos pruebas en verse: el
> `AttackLight`.** Su propio `COMMENT` lo dice —«el nodo de malla **reinjertado sobre el `.SCENE`
> vanilla**»— y el injerto conserva las luces del vanilla, así que la neutralización de la
> `PRUEBA13`, que era un paso a mano, desapareció. Medido el 27/08 sobre los `.MBIN` de
> `ModBackups`:
>
> | | `0.861` | `4.472136` | `0.0001` |
> |---|---:|---:|---:|
> | `PRUEBA13` (aprobada, luz muerta) | 0 | 0 | **2** |
> | `PRUEBA14` | 1 | 1 | 1 |
> | `PRUEBA16` | 1 | 1 | 1 |
>
> **El arreglo no es la `PRUEBA17`, es que no pueda repetirse:** `tools/Graft-NMSScene.py` apaga
> ahora el `AttackLight` dentro del propio injerto, y `tools/Check-NMSGraft.py` trae el bloque
> **ACUERDOS PERDIDOS**, que sale con código 1 si aparece encendido. Comprobado en los dos
> sentidos. Y el acuerdo queda anotado en [`ACUERDOS.md`](ACUERDOS.md) **A1**.

> 🏁 **`M-CONFETI` cerrado el 2026-08-22, medido en las capturas de `asset/Errores/`.**
> Ni el necromorfo ni el zombie salen ya con el color a confeti: los dos van en gris hueso y
> **la silueta se lee** — al zombie se le distinguen cráneo, costillas y dedos; al necromorfo,
> el cráneo y los miembros con garra. Subir de 5 999 a 30 000 y 36 000 triángulos era el
> arreglo, y el diagnóstico del horneado por triángulo queda **validado en partida**.
>
> **Y las capturas dejan dos cosas más, que no se preguntaban:**
>
> | Lo que se ve | Dónde baja |
> |---|---|
> | El **zombie se deforma**: en las tres capturas está en postura distinta —brazo alzado, zancada, brazos recogidos—, o sea que la cría **sí** aplica el esqueleto | `M4-PIEL` §2, **desbloqueado** |
> | El **necromorfo va rígido**, con los miembros abiertos en estrella e idénticos en las tres. Es la malla sin `_F02_SKINNED`, exactamente como se entregó | `M3-PIEL` §2, **desbloqueado** |
> | El **zombie se ve mojado**, igual que el SkrullCrawler | Es `M-BABA`, pero **por otra causa**: el zombie no lleva máscaras propias, lleva las del `ARTHROPOD` vanilla cayendo en NUESTRAS UV. Ver §2 fila 1 |
>
> **Y el juego no se cerró al parir el Horror**, que era la otra mitad de lo que medía la
> `HT_ZombieMesh_PRUEBA02`: el `.DESCRIPTOR` recortado aguanta.

> 🏁 **Las dos mallas de superficie YA NO van rígidas.** `M3-PIEL` y `M4-PIEL` entregados el
> 27/08 con `_F02_SKINNED`, `HT_FiendMesh_PRUEBA03` y `HT_ZombieMesh_PRUEBA03`. Lo que los
> bloqueaba no era el pesado, y son tres cosas medidas:
>
> | Lo que estaba mal | Qué pasaba | Dónde se arregló |
> |---|---|---|
> | `Weight-NMSMesh.py` cogía la **primera** malla vanilla con grupos de vértices, un `next()` | El `FreighterFiend` trae **una** y por eso bastó; el `BUGFIEND` trae **once** y la primera es `FiendButt`, 746 vértices de 26 299 pegados sólo a la cola. El zombie se pesaba contra el culo del bicho: 86,0 % en `tail_C0_1_jnt` | `vanillas`, una lista |
> | El importador de NMSDK **aborta la escena entera** en el primer material roto (`realize_path` → `None` → `op.join` con `None`), y en el `FIEND` además revienta en `_add_light_to_scene` buscando un nodo `Emission` que Blender 5.2 ya no crea | La receta lo llamaba «ruidoso pero inofensivo». **No lo es**: se lleva por delante las mallas que quedaban por añadir | `_callar_materiales()`, parcheado desde fuera |
> | El pesado **hinchaba el esqueleto** hasta llenar nuestra malla (×2,0008 en el necromorfo) | Los `JointBindings` se copian del vanilla en `Patch-NMSGraft.py`, así que **en partida los vértices se leen en el espacio del vanilla, sin reescalar**. Casar contra un rig hinchado es casar contra huesos que en partida están en otro sitio: `RootJNT` 63,7 % | `escala_piel = 1.0` |
>
> Con las tres, la distancia del vértice medio a su hueso baja de **2,479 → 0,578** en el zombie
> (diagonal 3,05) y de **2,170 → 1,558** en el necromorfo (diagonal 4,97).

> ⚠️ **Confirmado el 21/08: ganó el `Infestation` y el orden de carga sí importaba.** El nido
> despertaba con la linterna pero romperlo no llamaba nada, que es la firma exacta que se
> dejó escrita. Prioridades leídas del `GCMODSETTINGS.MXML`: `PRUEBA03` en **2**,
> `Infestation` en **18** — o sea **gana el número más alto**. En vez de pelear con el orden,
> el campo se puso **también** en el `Infestation`, y ahora los dos escriben el MISMO MBIN
> (`5c0bc001…`). El empate deja de existir.

> 🏁 **El `gMasksMap` del necromorfo y del zombie ya es PROPIO**, entregado el 27/08 en las dos
> `PRUEBA03`. **Va plano a 87**, que es la media útil del `gMasksMap` del `FIEND` vanilla medida
> el 22/08, con el hueco de UV retenido a 0 —35,4 % en el necromorfo, 3,2 % en el zombie—. Plano
> y no invertido del `roughness` **porque estos dos assets no traen `roughness`**: el de Tripo y
> el de Meshy sólo dan color. Es el arreglo mínimo que quita el brillo de baba sin inventar
> relieve; si al verlo se echa de menos variación, ahí sí hay que hornear un mapa.
>
> El del zombie va a **ruta propia**, `ZOMBIE.BASE.MASKS.DDS`, con el sampler reapuntado:
> `ARTHROPODTHORAX01.BASE.MASKS.DDS` la comparte toda la fauna artrópodo del juego.

> 🏁 **El normal liso del necromorfo, arreglado el 27/08.** Rehecho con `--fuerza 9` y
> `--sin-costuras`, que aplana el 21,0 % de la textura —borde de isla y hueco—. Desviación
> **17,1 / 15,8**, contra los **4,7** de antes, los **17,2** del `FIEND` vanilla y los **17,8**
> del SkrullCrawler que funciona.

> ⚠️ **El 21/08 se desplegó con NMS.exe abierto.** Los mods se leen **al arrancar** y punto:
> desplegar con el juego abierto no hace nada. **Cerrar NMS antes de desplegar, y arrancar de
> nuevo por Steam.**

> 🔎 **`BetterExtractorsDepots`: el archivo está BIEN y el diagnóstico del 26/08 estaba MAL.**
> Medido el 27/08 descompilando el `.MBIN` desplegado y comparándolo con el vanilla sacado de
> los 97 `.pak`, campo por campo:
>
> | | vanilla | desplegado | |
> |---|---:|---:|---|
> | `U_EXTRACTOR_S` · `Rate` | 100 | **1000** | ×10 ✅ |
> | `U_GASEXTRACTOR` · `Rate` | 100 | **1000** | ×10 ✅ |
> | `U_SILO_S` · `Storage` | 1 440 000 | **14 400 000** | ×10 ✅ |
> | `U_BIOGENERATOR` · `DependentRate` | 50 | **50 000** | ×1000 ✅, y **funciona en partida** |
>
> **Y lo que lo cierra: los cuatro valores viven en el MISMO archivo.** Si el biogenerador va a
> ×1000 en partida, el juego está leyendo ese `.MBIN`, y por tanto está leyendo también el
> `Rate` 1000 y el `Storage` 14 400 000. **No es el mod.**
>
> ❌ **La teoría de la prioridad era falsa y se retira.** Se dijo que cinco mods entregaban la
> misma tabla por encima del nuestro. **No la entregan:** `EXTRACTOR`, `DD-BUILDITHERE`,
> `DD-SIZEITALL`, `FF_CUSTOMCORVETTEINTERIORMODULES_640` y `_BEYOND BASE BUILDING` son carpetas
> de Vortex con **sólo `.EXML`**, que el juego no lee. Buscado el 27/08 en las 94 carpetas de
> `GAMEDATA\MODS`: hay **un solo** `BASEBUILDINGOBJECTSTABLE.MBIN`, el nuestro, y **ningún**
> `.pak`. Subir la prioridad a 96 no arregló nada porque no había nada que arreglar.
>
> ⬜ **Lo que queda por separar, y no hace falta tocar ningún archivo.** Si los datos están y el
> juego los lee, lo que queda es estado **horneado en la partida**: los extractores y depósitos
> YA COLOCADOS. La prueba que lo separa es **colocar uno nuevo al lado de uno viejo**. Si el
> nuevo va a ×10 y el viejo no, es la partida; si tampoco va el nuevo, entonces `Rate` y
> `Storage` no son los campos que mueven ese número y hay que buscar cuál.
>
> ⚠️ Nota aparte, medida: el **buffer** del extractor sigue en 360 000 (vanilla), sólo se subió
> el `Rate`. Un extractor lleno no extrae, así que el ×10 sólo se nota **drenando**.

> Arrancar **por Steam**. Reiniciar NMS: los mods solo se leen al arrancar.

---
## 2 · La cola, en orden

**No se empieza uno hasta cerrar el de arriba.**

| # | ID | Qué | Estado | Dónde lo leo |
|---|---|---|---|---|
| 1 | **`HT_FiendMarkers_PRUEBA05`** | Marcadores de Horror. En el juego no hay ninguno: el `PRUEBA04` está retirado | ✍️ escrito, sin construir · **choca**, ver abajo | [`../work/scripts/marcadores/README.md`](../work/scripts/marcadores/README.md) |
| 2 | **`HT_DerelictBugs`** | Devolver `CARG` y `MEDI`, **de una en una** | ⬜ sin escribir | [`../work/scripts/derelict/README.md`](../work/scripts/derelict/README.md) |
| 3 | **`N1`** | **Huevo de interior**: prueba **A** (control con `DEBRISLARGE_COMMON`) y luego **B** (huevo de `SPACEBASE`). Ya no bloquea nada | ⬜ la **A** ya está escrita, la **B** no | [`ASSETS.md`](ASSETS.md) §5.1 y §5.7 |
| 4 | **`M5`** | **Cuarta malla propia.** Quedan sin usar el `angel`, la `LivingFlesh` y el traje de Dead Space. `SCUTTLER_PET` **no se toca**: es la mascota del jugador | ⬜ sin escribir | [`ASSETS.md`](ASSETS.md) §4.2 |

> 🏁 **`M-PALETA`, `M3-PIEL` y `M4-PIEL` salen de la cola el 2026-08-27**, y con ellos la
> Etapa 4 entera: los tres modelos propios llevan ya piel del esqueleto vanilla. Los tres
> están desplegados y **sin medir**: ver §1.
>
> 🏁 **`M-CONFETI` sale de la cola: cerrado el 2026-08-22.** Las capturas de `asset/Errores/`
> lo dan por bueno en los dos bichos. Ver §1 y el changelog 0.6.6.

> **`HT_FiendMarkers_PRUEBA05` choca con la serie del SCUTTLER.** Las dos escriben
> `SPIDERRIG\FREIGHTERFIEND.SCENE.MBIN`. Por eso la `PRUEBA04` está retirada. Cuando toque,
> hay que **fusionarlas en un `.lua`** y decidir el `AttackLight`: marcadores lo quiere vivo
> (1.0 · 0.15 · 0.12), la malla lo tiene **a cero** para que el bicho no salga dorado. Manda
> la malla; los marcadores tendrán que pintar por otra vía.

---

### 2.1 · `M-BABA` — el canal no estaba flojo, estaba al revés

**Medido el 2026-08-22, antes de tocar nada.** El `gMasksMap` de las criaturas es un `ATI1`
de **un solo canal**, y los números son estos:

| | media | útil media | p1 | p99 | máx |
|---|---:|---:|---:|---:|---:|
| `FIEND` vanilla | 85,4 | 86,9 | 5 | 156 | 192 |
| Nuestro, `PRUEBA12` | 173,6 | 199,5 | 69 | 236 | 255 |
| Nuestro, `PRUEBA13` | 47,3 | 54,0 | 17 | 105 | 255 |

*«Útil»* es sin el fondo (`≤ 2`), porque el nuestro tiene **13,3 %** de UV sin usar y el
vanilla sólo **1,7 %**: comparar las medias crudas mezclaba hueco con superficie.

**La causa no es que el mapa esté flojo, es que viene al revés.** El asset de Meshy entrega
**`roughness`** —valor alto = áspero = **mate**— y el shader lee ese canal como **brillo**
—valor alto = **mojado**—. Con un mapa casi todo alto el bicho salía entero de baba, que es
exactamente lo que se vio. Y el número lo ata: **255 − 173,6 = 81**, contra los **85** del
vanilla. No es una coincidencia que sobreviva a tres decimales por casualidad.

Por eso **se invierte y no se atenúa**. Atenuar dejaría las grietas brillantes y los bultos
mates —el mismo mapa del revés, sólo que más flojo—, que es un fallo distinto y no el arreglo.

> **Una cosa que el `--invertir` del conversor no hace, y por eso el PNG se prepara aparte.**
> Ese 13,3 % de hueco está a 0, e invertirlo lo pondría a **255** — brillo máximo pegado al
> borde de cada isla, que a partir del cuarto mip sangra hacia dentro. Se comprobó que el
> hueco es hueco de verdad: **donde la rugosidad vale 0 el color base también es negro**
> (RGB 2,8 / 1,8 / 1,7 con desviación 15, contra 106,7 / 68,3 / 65,3 en la parte útil). Así
> que se invierte sólo lo útil y el fondo se queda a 0, que es mate y es lo que hace el
> vanilla.
>
> ```
> out = np.where(rough <= 2, 0, 255 - rough)
> python tools/Make-NMSTexture.py work/textures/SKRULLCRAWLER.BASE.MASKS.PNG <vanilla ATI1>.DDS work/textures/SKRULLCRAWLER.BASE.MASKS.INV.DDS
> ```

**Esto contesta a `Q-MASCARAS` a medias**: no dice qué canal es qué, pero sí dice que **el
único canal que hay se comporta como brillo y no como rugosidad**, que es lo que hacía falta
para arreglarlo. La `PRUEBA13` lo confirma o lo tumba.

**Y le queda una segunda mitad:** el necromorfo y el zombie **no llevan máscaras propias** —
usan las del vanilla cayendo en nuestras UV—, y en las capturas el zombie sale mojado. El
arreglo es el mismo, con el `roughness` de cada asset, pero va **después** de que la
`PRUEBA13` diga si la inversión es la buena.

---

### 2.2 · `HT_CeilingPlague_PRUEBA03` — qué toca, y por qué es un campo

**Construida y desplegada el 21/08** (3 + 1 cambios, 0 errores / 0 warnings / 0 notices).
El nido del techo estaba a **un campo** de soltar Horrores y no hubo que añadir ningún
componente. Los dos `.ENTITY` se leyeron del PCBANKS, no se supusieron:

| `GcDestructableComponentData` | Huevo de suelo (`FIENDEGG`) | Nido del techo (`MEDIUMHANGSLIME`) |
|---|---|---|
| `IncreaseFiendWanted` | **`true`** | era **`false`** ← lo único que difiere, y lo único que toca la `PRUEBA03` |
| `IncreaseFiendWantedChance` | `1.0` | `1.0` |
| `IncreaseFiendCrime` | `EggDestroyed` | `EggDestroyed` |
| `Explosion` | `FIENDHATCH` | `INFESTPILLAREXP` |

O sea: **el nido ya está cableado como un huevo y solo tiene el interruptor apagado.** Los
Horrores no salen del prop: los suelta el sistema de «fiend wanted» cuando se comete el
crimen `EggDestroyed`, que es exactamente cómo funcionan los huevos del suelo.

Lo que hay alrededor, y que también está leído:

- El `MEDIUMHANGSLIME.SCENE` trae un locator **`SPAWNPOS_`** y un `GcAlienPodComponentData`
  con agro por movimiento, linterna y disparo: el nido **ya reacciona al jugador**.
- Trae `GcShootableComponentData` y un `MEDIUMHANGSLIME_DESTROYED.SCENE` propio, así que
  romperlo es una interacción vanilla y no hay que inventarla.

⚠️ **El archivo es compartido con la infestación de cargueros.** Encenderlo aquí lo enciende
también allí: romper baba en un derrelicto también llamará Horrores. **Es deliberado**, y es
la mitad de lo que hay que mirar en partida. Si sale a manadas donde no toca, se vuelve a la
`PRUEBA02`, que solo escribe el primero de los dos archivos.

> ⚠️ **Empate de archivo con `HorribleTerror_Infestation_4-Hardcore`, y está resuelto por
> superconjunto.** Los dos mods escriben `MEDIUMHANGSLIME.ENTITY.MBIN`, y cuando dos mods
> escriben el mismo MBIN **el segundo que cargue gana entero y en silencio**. Las dos
> versiones diferían en **tres campos y solo tres** — el Infestation pone `AgroTorch` 12 y
> `GunfireAgro` 8 y deja `IncreaseFiendWanted` en `false`; la `PRUEBA03` hacía lo contrario—,
> así que la `PRUEBA03` **escribe los tres**. Comprobado tras construir: el `diff` contra el
> MBIN desplegado del Infestation deja **una sola línea**, la del campo nuevo.

> **Queda un solo escenario malo:** que gane el Infestation, y entonces no brota nada. Tiene
> firma propia — el nido **despierta con la linterna pero romperlo no llama Horrores** — y se
> arregla subiendo la prioridad de la `PRUEBA03` por encima del Infestation en el menú de mods
> del juego. Hoy son **2** y **18** en `GCMODSETTINGS.MXML`.


> El `.ENTITY` sale de `NMSARC.MetadataEtc.pak`, **no** del `NMSARC.EntitySceneMBIN.pak`
> donde está el `.SCENE`. El filtro de `hgpaktool` es un **glob**, no una subcadena:
> `-f "*mediumhangslime*"` encuentra, `-f "mediumhangslime"` da cero.


> **✅ `N1` ya no bloquea nada — lo desbloqueó la `HT_CeilingPlague_PRUEBA01` el 17/08.**
> Los dos querían el locator `TENTACLE_`, y la plaga lo alcanza **sin pasar por el
> `.LSYSTEM`**, que es justo el trozo que `N1` intentaba diagnosticar. La `PRUEBA01` demostró
> que **cambiar el `SCENEGRAPH` del envoltorio funciona**: el juego carga la escena nueva. Lo
> único que quedó mal fue **dónde** queda, y eso es aritmética de transform, no una incógnita
> de formato — lo arregla la `PRUEBA02`. `N1` baja a curiosidad.

> **El build ya corre desatendido.** `tools/AMUMSS/BUILDMOD_AUTO.bat` tiene fijadas las seis
> opciones que antes preguntaban por consola (`DEV_MODE F`, `GameVersion P`,
> `CombineModPak N`, `CopyToGamefolder N`, `UseExtraFilesInPAK N`, `UseLuaScriptInPak N`).
> Hay que lanzarlo con **codepage 850** y sin `NoDefaultCurrentDirectoryInExePath`.
> Con `CopyToGamefolder N` **no despliega**: los `.MBIN` se copian a mano desde `ModBackups`.

---

## 3 · Preguntas sin responder

| ID | Pregunta | Dónde se contestaría |
|---|---|---|
| **`Q-IDBICHO`** | A qué `CreatureID` corresponde el mini-Fiend que sale del nido del carguero: la `CREATUREFILENAMETABLE` dice que el nido suelta `SCUTTLER`, no `MINIFIEND` | `HT_FiendMarkers_PRUEBA05` → [`../work/scripts/marcadores/README.md`](../work/scripts/marcadores/README.md) |
| **`Q-TECHO`** | ¿Por qué el huevo de interior borra la planta del techo y no pone nada en su sitio? | **Hipótesis del 13/08:** el giro de 180° vive en el envoltorio y el `.LSYSTEM` lo tira. Prueba `N1` A/B → [`ASSETS.md`](ASSETS.md) §5.7 |
| **`Q-MASCARAS`** | ¿Qué canal del `gMasksMap` es qué? El vanilla del huevo da `R` media 179 y `G` media 73, que no cuadra con «R = metalicidad». **Contestada a medias el 22/08:** en criaturas el mapa es `ATI1` de **un canal**, y ese canal **se comporta como brillo, no como rugosidad** — con 174 el bicho sale mojado, y el vanilla mide 85, que es justo `255 − 174`. Qué nombre tiene el canal sigue sin saberse; cómo se usa, ya sí | La `HT_ScuttlerMesh_PRUEBA13` lo confirma o lo tumba → §2.1 |
| **`Q-GLOW`** | ¿Cómo se enciende un emisivo de verdad? Hoy la emisión del marker va **horneada dentro del color base** | Ninguna prueba escrita → [`ASSETS.md`](ASSETS.md) §1.4 |
| **`Q-REFPATHS`** | ¿Se puede recolocar una malla vanilla en otro rig con `ReferencePaths`? **Dato nuevo del 21/08:** en el `BUGFIEND` **no están vacíos** —los ocho apuntan a `ARTHROPOD.SCENE.MBIN`—, así que el campo sí se usa. Vacíos estaban los 172 del `TREX` | [`ASSETS.md`](ASSETS.md) §3. Sube de curiosidad a vía posible |
| **`Q-CHANCE`** | ¿Qué hace un `Chance > 0` en un descriptor? | Los 172 valen 0.0 en vanilla; no hay ejemplo del que copiar → [`ASSETS.md`](ASSETS.md) §3 |
| **`Q-CARNAGE`** | ¿Qué dispara el modo «carnage» de `MaxFiendsToSpawnCarnage`? | — |
| **`Q-ANTAGONIST`** | ¿`GcAntagonistComponentData` en el huevo salvaje? | Aplazado: exige **añadir** un componente, no cambiar un valor |

---

## 4 · Qué está instalado — 2026-08-27 (tras desplegar las tres `PRUEBA` nuevas)

Todo se mide con **`HorribleTerror_Infestation_4-Hardcore` 0.6.5**, que contiene al mod 1.
`HorribleTerror_Predators` **no debe estar instalado**: escriben los mismos archivos.

**Leído de `GAMEDATA\MODS` el 2026-08-27, carpeta por carpeta.** Nuestros son estos ocho, de
un total de 94 carpetas:

| Mod | Qué entrega | |
|---|---:|---|
| `HorribleTerror_Infestation_4-Hardcore` **0.6.5** | 11 MBIN | |
| `HT_EggMesh_PRUEBA05` — obelisco entero, con textura **y a su tamaño** | 1 + 5 `ADD_FILES` | |
| **`HT_ScuttlerMesh_PRUEBA17`** — la `16` con el `AttackLight` de vuelta a cero | **8** `ADD_FILES` | 🆕 desplegado el 27/08, **sin medir**. La geometría va byte a byte como la `16`, verificado con `cmp`. La `16` baja a `MODS_Retirados` |
| **`HT_FiendMesh_PRUEBA04`** — el necromorfo **con piel de mapa a mano**, normal rehecho y máscaras propias | **7** `ADD_FILES` | 🆕 desplegado el 27/08, **sin medir**. Sustituye a la `02` y a la `03` |
| **`HT_ZombieMesh_PRUEBA04`** — el zombie **con piel de mapa a mano** y máscaras propias en ruta propia | **8** `ADD_FILES` | 🆕 desplegado el 27/08, **sin medir**. Sustituye a la `02` y a la `03` |
| `HT_CeilingPlague_PRUEBA03` — la `02` **más** el campo que hace brotar | 2 MBIN | desplegado el 21/08, **sigue sin medir** |
| `HT_DerelictBugs_PRUEBA02` | 1 MBIN | |
| `HT_PredatorParts_PRUEBA03` | 1 MBIN | |

Y aparte, nuestro pero de calidad de vida: **`BetterExtractorsDepots`**, 1 MBIN
(`BASEBUILDINGOBJECTSTABLE`). Es el **único** archivo de esa tabla en toda la carpeta `MODS`
—comprobado el 27/08— y no hay **ningún** `.pak`: los demás mods que la tocan son carpetas de
Vortex con sólo `.EXML`, que el juego no lee. Ver §1.

**Los tres despliegues del 27/08 están verificados descompilando el `.MBIN` de
`GAMEDATA\MODS`**, no el de `ModBackups`: `Check-NMSGraft.py` da **salida 0** en los tres, con
stride 20 y los canales 2, 3, 5 y 6.

**Retirados a `GAMEDATA\MODS_Retirados\`** — 28 carpetas, con `HT_ScuttlerMesh_PRUEBA16`,
`HT_FiendMesh_PRUEBA02` y `HT_ZombieMesh_PRUEBA02` añadidas el 27/08. Todas escriben los
mismos archivos que su sustituta, así que **no pueden convivir**.

`NoDerelictMiniHorrors` **ya no está** en `GAMEDATA\MODS`: apuntaba a las dos carpetas donde
escribe nuestro `Infestation`.

✅ `DisableAllMods` = **`false`** el 2026-08-27. La última sesión no dejó el interruptor
general apagado.

**Fuera de `GAMEDATA\MODS` desde el 21/08, y no son nuestros:** `Better Extractors 10x`,
`Better Supply Depots 10x` y `Biogenerator PowerupX1000`. Eran carpetas de Vortex con **sólo
`.EXML`**, y los tres están reconstruidos a `.MBIN` dentro de `BetterExtractorsDepots`.

---

## 5 · Cómo se usa

1. Antes de jugar: `tools\Backup-NMSSave.ps1 -Etiqueta "<qué se prueba>"` — **lo corro yo**.
2. **Si la sesión anterior crasheó**, comprobar el interruptor general antes de nada:
   `findstr DisableAllMods "<NMS>\Binaries\SETTINGS\GCMODSETTINGS.MXML"` tiene que dar
   `value="false"`. Ver [`README.md`](README.md) §«El interruptor general de mods».
3. Reiniciar NMS **desde Steam**.
4. Al volver: borrar de §1 lo medido y anotarlo en el changelog **con su ID**. Lo que falle,
   a «Retirado» con el motivo.

> **Cuatro reglas que costaron una prueba cada una:**
> construir no es desplegar, y desplegar no es probar · el `.EXML` de `CreatedMODS` es un
> informe y no despliega nada, los `.MBIN` salen de `ModBackups` · una verificación que no
> puede fallar no es una verificación · **una prueba después de un crash puede estar
> midiendo el vanilla**, porque el crash apaga todos los mods.
