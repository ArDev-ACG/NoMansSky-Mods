# Pendientes

**Solo dos cosas viven aquí: lo que está en el juego sin medir, y las preguntas sin
responder.** Lo comprobado no se repite aquí: se borra y se anota en el changelog que le
toque. Si buscas *por qué* se hizo algo, está en
[`CHANGELOG-MOD2.md`](CHANGELOG-MOD2.md).

**Cada fila lleva un identificador y el archivo donde se lee el detalle.** El identificador
es el nombre del `.lua` cuando la prueba tiene uno (`HT_EggMesh_PRUEBA03`), y un código corto
cuando es una pregunta y no un mod (`N1`, `Q-GLOW`).

Actualizado: **2026-08-15**.

---

## 1 · En el juego ahora, sin medir

Construido **y desplegado** en `GAMEDATA\MODS`, verificado por md5. Las 16 pruebas que
chocaban están movidas a `GAMEDATA\MODS_Retirados\`, fuera de donde el juego lee.

| ID | Qué mirar |
|---|---|
| **`HT_CeilingPlague_PRUEBA01`** | Que el nido colgante del carguero salga **del techo** de los edificios abandonados, en el sitio de la planta |

> Arrancar **por Steam**. Reiniciar NMS: los mods solo se leen al arrancar.

> 🏁 **`HT_ScuttlerMesh_PRUEBA11` es la configuración buena, dada por buena en partida el
> 2026-08-14.** Malla propia entera, difuso propio, máscaras propias y el `AttackLight`
> neutralizado. **De aquí no se retrocede**: cualquier prueba nueva parte de estos mismos
> siete archivos y solo cambia lo que vaya a medir. El detalle, en
> [`CHANGELOG-MOD2.md`](CHANGELOG-MOD2.md) y en
> [`../work/scripts/malla/README.md`](../work/scripts/malla/README.md).
>
> Lo que queda del bicho son **dos mejoras, no dos fallos**: el **normal** sigue siendo el del
> bicho vanilla, y la malla **no se deforma con el esqueleto**. Van en §2 como `M-TEX` y
> `M-ANIM`. En Blender se ve claramente mejor que en pantalla, y esa diferencia es justo lo
> que esas dos filas persiguen.

---

## 2 · La cola, en orden

**No se empieza uno hasta cerrar el de arriba.**

| # | ID | Qué | Estado | Dónde lo leo |
|---|---|---|---|---|
| 1 | **`M-ANIM`** | **Etapa 4 — que el SkrullCrawler se mueva con el esqueleto.** Hoy va rígido: se desliza | ⬜ sin escribir · plan abajo en §2.1 | §2.1 y [`ASSETS.md`](ASSETS.md) §4.2 |
| 2 | **`M-TEX`** | **Normal propio** para el SkrullCrawler. El `gNormalMap` sigue siendo el vanilla, pintado para otras UV | ⬜ sin escribir | [`../BLENDER/vista_ingame/README.md`](../BLENDER/vista_ingame/README.md) |
| 3 | **`HT_FiendMarkers_PRUEBA05`** | Marcadores de Horror. En el juego no hay ninguno: el `PRUEBA04` está retirado | ✍️ escrito, sin construir · **choca**, ver abajo | [`../work/scripts/marcadores/README.md`](../work/scripts/marcadores/README.md) |
| 4 | **`HT_DerelictBugs`** | Devolver `CARG` y `MEDI`, **de una en una** | ⬜ sin escribir | [`../work/scripts/derelict/README.md`](../work/scripts/derelict/README.md) |
| 5 | **`N1`** | **Huevo de interior**: prueba **A** (control con `DEBRISLARGE_COMMON`) y luego **B** (huevo de `SPACEBASE`). Bloquea la Etapa 3 de Blender, que usa el mismo locator | ⬜ la **A** ya está escrita, la **B** no | [`ASSETS.md`](ASSETS.md) §5.1 y §5.7 · [`../work/scripts/pruebas/HT_LocatorTest_PRUEBA01.lua`](../work/scripts/pruebas/HT_LocatorTest_PRUEBA01.lua) |
| 6 | **`M3`** | **Segunda malla propia.** *Para la piel de estas, la receta ya está escrita: [`RECETA-PIEL.md`](RECETA-PIEL.md).* `ScrullCrawler_max_hd` y `Necro_partes_7_own_2` son estáticos y entran por el conducto de la Etapa 2, que **ya está cerrado y automatizado** en `tools/Export-NMSMesh.py`; `zombie-monster-slasher` no, viene rigged. Antes hay que **decimar en Blender**: el marker son 822 vértices y esos dos pesan 14,3 y 6,1 MB | ⬜ sin escribir | [`ASSETS.md`](ASSETS.md) §4.2 |

> **`M-ANIM` y `M-TEX` van en el MISMO `.lua`.** Los dos escriben `FFIENDMAT.MATERIAL.MBIN` y
> los dos `.GEOMETRY`: no pueden ser dos mods a la vez. La `PRUEBA12` lleva las dos cosas y
> **una sola entrada al juego mide las dos**, que es como se quiere trabajar de aquí en
> adelante. Si sale mal, el `.GEOMETRY` dice cuál de las dos falló sin volver a entrar.

> **`HT_FiendMarkers_PRUEBA05` choca con la serie del SCUTTLER.** Las dos escriben
> `SPIDERRIG\FREIGHTERFIEND.SCENE.MBIN`. Por eso la `PRUEBA04` está retirada. Cuando toque,
> hay que **fusionarlas en un `.lua`** y decidir el `AttackLight`: marcadores lo quiere vivo
> (1.0 · 0.15 · 0.12), la malla lo tiene **a cero** para que el bicho no salga dorado. Manda
> la malla; los marcadores tendrán que pintar por otra vía.

---

### 2.1 · `M-ANIM` — qué falta exactamente para que se mueva

Hoy el bicho va **rígido**: `FFIENDMAT` sin `_F02_SKINNED`, `SkinMatrixLayout` vacío y el nodo
pidiendo `FIRSTSKINMAT` 0 → `LASTSKINMAT` 0. Fue **a propósito** —la `PRUEBA01` con el
material vanilla salió estirada sin forma— y es lo que hay que deshacer al revés: primero los
datos, después el flag.

**Tres cosas leídas en el código, no supuestas:**

| Hecho | Dónde se lee |
|---|---|
| ✅ **NMSDK sí IMPORTA pesos**: crea un grupo de vértices por hueso y reparte `blendWeight` | `ModelImporter/import_scene.py:1090-1098` |
| ⛔ **NMSDK NO los EXPORTA**: escribe `JointBindings`, `MeshBaseSkinMat` y `SkinMatrixLayout` **vacíos** | `ModelExporter/export.py:768-779` |
| ⛔ **Nuestra malla no trae los canales de piel**: `VertexLayout` de stride 8 con `SemanticID` 2 y 3 (normal y tangente). Faltan el **5** y el **6**, índice y peso de hueso | `work/models/scuttlermesh/FREIGHTERFIEND.GEOMETRY.MXML` |

O sea: **el muro de NMSDK es solo de salida**, y el esqueleto que hace falta ya está en el
juego —es el `SPIDERRIG` vanilla, con sus animaciones—. No hay que animar nada: hay que
**pesar nuestra malla contra sus huesos**.

El camino, y cada paso se puede comprobar sin entrar al juego:

```
1. Importar el FREIGHTERFIEND vanilla con NMSDK, con "import bones" puesto   [HECHO]
      -> entran el Armature y los grupos de vértices con sus pesos
2. Transferir esos pesos a polySurface6 con el modificador Data Transfer   [HECHO]
      (Vertex Group Data, por superficie más cercana)
3. Escribir los canales 5 y 6 en el .GEOMETRY nosotros, como ya se hace con
      los arrays por hueso -> herramienta nueva, hermana de Patch-NMSGraft.py   [HECHO]
4. Rellenar SkinMatrixLayout y MeshBaseSkinMat, y abrir el rango
      FIRSTSKINMAT / LASTSKINMAT del nodo de malla en el .SCENE   [HECHO]
5. Devolver _F02_SKINNED a FFIENDMAT   <- LO UNICO QUE QUEDA, y va en el .lua
6. tools/Check-NMSGraft.py, que es quien caza los índices fuera de rango   [HECHO]
```

> **Pasos 3, 4 y 6 hechos, sin entrar al juego.** `work/models/scuttlermesh_anim/` lleva el
> buffer a stride 20 con los canales 5 y 6, `SkinMatrixLayout` de 14 huesos, `MeshBaseSkinMat`
> a `[0]` y el nodo de malla con `FIRSTSKINMAT` 0 → `LASTSKINMAT` 14. `Check-NMSGraft` pasa
> con salida 0, y **caza los tres modos de fallo** cuando se rompe a propósito. Falta el paso
> 5 —`_F02_SKINNED`— que va en el `.lua` de la `PRUEBA12` junto a `M-TEX`.
>
> **Esa carpeta no está en git**: son `.MBIN` de Hello Games. Se rehace con
> `python tools/Skin-NMSGeometry.py work/models/scuttlermesh work/models/scuttlermesh_anim`.
>
> Para repetir todo esto con otra malla, la receta está en [`RECETA-PIEL.md`](RECETA-PIEL.md).

**El paso 3 es el trabajo de verdad**: cambia el stride del buffer de vértices, así que hay
que reescribir el `.GEOMETRY.DATA` entrelazando los dos canales nuevos. Lo demás es
contabilidad.

> **Ojo con el `[HECHO]` del paso 2.** El modificador se aplicó en su día, pero
> `scuttler.blend` tiene hoy **0 grupos de vértices**: los pesos no están en disco. Por eso
> el paso 3 los vuelve a generar y los versiona en un archivo aparte, en vez de darlos por
> supuestos.

#### El paso 3, en marcha — dónde va y qué falta

Diseño y plan escritos y comiteados; la implementación va por tareas, un subagente cada una,
con revisión detrás. El ledger vivo está en `.superpowers/sdd/progress.md` (no va a git).

| | |
|---|---|
| Diseño | [`superpowers/specs/2026-08-14-skin-nmsgeometry-design.md`](superpowers/specs/2026-08-14-skin-nmsgeometry-design.md) · commit `8687740` |
| Plan | [`superpowers/plans/2026-08-14-skin-nmsgeometry.md`](superpowers/plans/2026-08-14-skin-nmsgeometry.md) · commits `a8cf111`, `ad173ea` |

Las siete tareas, y en qué estado están:

| # | Tarea | Entrega | Estado |
|---|---|---|---|
| 1 | `nmsgeom`, ida y vuelta del `.DATA` | `tools/nmsgeom.py`, `tools/tests/test_nmsgeom.py` | ✅ commit `bdd16ca` · **revisada** el 15/08 |
| 2 | `nmsgeom`, stride 8 → 20 y offsets | `ampliar_stride`, `layout`, `parchear_layout`, `parchear_metadata` | ✅ commit `55ddee8`, **11 tests OK** |
| 3 | `Weight-NMSMesh`, los pesos | `tools/Weight-NMSMesh.py` → `work/models/scuttlermesh/pesos.json` | ✅ commit `0a42a92`, **17 tests OK** |
| 4 | `nmsskin`, paleta y canales 5 y 6 | `tools/nmsskin.py` | ✅ commit `a5356e3`, **30 tests OK** |
| 5 | `Skin-NMSGeometry`, el comando | `tools/Skin-NMSGeometry.py` | ✅ commit `e4a0be1`, corrido sobre la malla real |
| 6 | `Check-NMSGraft` ampliado al binario | `_revisar_piel`, cinco comprobaciones nuevas | ✅ commit `a0c3f89`, **caza los 3 modos de fallo** |
| 7 | Pasada completa y documentación | fila de PRUEBA12 y cierre | ✅ conducto entero en verde desde cero |

Tres cosas que hay que tener presentes al retomar:

- **`tools/` ya no está ignorado en bloque** — commit `57bb8d5`, 2026-08-15. La regla pasó de
  `tools/` a `tools/*` con cuatro negaciones, porque git **no puede re-incluir nada que esté
  dentro de un directorio excluido** y un `!tools/*.py` a secas no habría hecho nada. Entraron
  a git los cinco `.py` que llevaban ahí sin versionar desde siempre (`Check-NMSGraft`,
  `Decimate-NMSMesh`, `Export-NMSMesh`, `Make-NMSTexture`, `Patch-NMSGraft`). AMUMSS, los
  `.exe` y `__pycache__` siguen fuera. **Las tareas 3 a 7 ya no necesitan `git add -f`.**
- **Los tests son `unittest` de la biblioteca estándar**, no pytest. Se corren desde la raíz
  del repo con `python -m unittest discover -s tools/tests`.
- **Nada de construir ni desplegar** hasta que el `Check-NMSGraft.py` ampliado pase. El
  cierre sin aviso del juego viene justo de aquí: el byte del canal 5 es la posición dentro
  de la paleta `SkinMatrixLayout[FIRSTSKINMAT:LASTSKINMAT]`, **no** el número de hueso.

Fuera del alcance de este plan, para después: construir y desplegar, el `.lua` de PRUEBA12,
devolver `_F02_SKINNED` (paso 5) y `M-TEX`.

#### El paso 1, hecho — lo que soltó el vanilla

Los originales están extraídos en **`work/models/vanilla_freighterfiend/`** (de
`NMSARC.EntitySceneMBIN.pak`, `MeshPlanetCREATURES`, `MetadataEtc` y `AnimMBIN`, con
`tools/AMUMSS/MODBUILDER/hgpaktool.exe -U -f "*FREIGHTERFIEND*"`).

Importado en Blender sin interfaz, con `import_bones=True`:

| | |
|---|---:|
| Huesos del Armature | **113** (raíz `RootJNT`) |
| `polySurface6` vanilla | 7 635 vértices · 14 424 triángulos |
| Grupos de vértices creados | **19** |
| Vértices con peso | 7 635 de 7 635 |
| Asignaciones totales | **8 042** |
| Máximo de huesos por vértice | **3** |
| Vértices cuya suma de pesos ≠ 1 | **0** |

> **El bicho vanilla es casi rígido.** 8 042 asignaciones para 7 635 vértices: la inmensa
> mayoría cuelga de **un solo hueso**, y solo las junturas reparten entre dos o tres. Eso
> rebaja mucho el listón: no hace falta un pesado fino, basta con asignar cada vértice al
> hueso más cercano y suavizar las costuras.

De los 113 huesos, la malla solo usa **19**: `RootJNT`, los dos `Pincer1`, primera y cuarta
pata de cada lado (`1JNT`, `2JNT`, `3JNT`), `NewBack1/2/3JNT` y `NewHeadJNT`. Las patas
segunda y tercera y toda la cola **no deforman nada**.

#### El paso 2, hecho — y el giro que casi lo estropea

Las dos mallas **no están en el mismo espacio**, y transferir sin alinear da basura:

| | X | Y | Z |
|---|---:|---:|---:|
| vanilla, tal como lo deja NMSDK | 1,925 | **3,268** | 1,850 |
| nuestro `polySurface6` | 2,637 | 1,851 | **2,768** |

El vanilla viene **Z arriba** y el nuestro **Y arriba**: 90° de diferencia. Sin corregirlo,
`RFourthLeg*` y `LFourthLeg*` se quedan **con 0 vértices** y `RFirstLeg3JNT` se traga 1 630.
La alineación es girar +90° en X, y después encajar la caja envolvente en la del vanilla.

Y queda un giro de 180° en Z que decidir —si el bicho mira adelante o atrás—. **Puntuar por
«cuántos grupos reciben vértices» elige mal**: da `GIRO_Z 0`, que pone nuestro cráneo mirando
hacia atrás. Lo que sí decide:

- la cabeza del vanilla está en **+Y** (centroide de los vértices con peso > 0,5 en
  `NewHeadJNT`: Y = **+0,365**, con la cola llegando a −2,049);
- con `GIRO_Z 0` nuestro cráneo cae en −Y, y con **`GIRO_Z 180`** en +Y.

**`GIRO_Z 180` es el bueno**, y de propina es el de mejor simetría izquierda/derecha (0,898
contra 0,787). Comprobado con renders laterales de las tres siluetas.

Resultado sobre nuestros 4 820 vértices:

| | |
|---|---:|
| Vértices con peso | **4 820 de 4 820** |
| Asignaciones | 4 895 |
| Máximo de huesos por vértice | **2** |
| Centroide de la cabeza en Y | **+1,493** |

1,02 huesos por vértice, contra 1,05 del vanilla: **sale igual de rígido que el original**, que
es exactamente lo que se buscaba. Y con máximo 2 influencias caben de sobra en los 4 huecos
del buffer.

> **Estos son los números de la corrida del 15/08, la que está en disco** —
> `work/models/scuttlermesh/pesos.json`, commit `0a42a92`—. La sesión del 13/08 había anotado
> 5 137 asignaciones (1,07); la diferencia es la variación admisible del `vert_mapping`, y los
> cuatro invariantes que sí mandan —4 820 de 4 820, el máximo de 2, los cinco grupos vacíos y
> el signo del centroide— salieron iguales.

> **Dos grupos se quedan a cero y hay que saberlo**: `NewBack1/2/3JNT` (la espalda no
> doblará; el cuerpo se moverá en bloque con `RootJNT`) y los dos `Pincer1JNT` (nuestro bicho
> no tiene pinzas, así que da igual). Se mueven cabeza y las ocho patas. Es mucho mejor que
> hoy, pero no es el vanilla entero.

#### El contrato binario del paso 3 — leído, no supuesto

`VertexLayout` del vanilla, de `freighterfiend.geometry.MXML`: **ElementCount 4, Stride 20**.

| SemanticID | Qué es | `Type` | Bytes | `Offset` |
|---:|---|---:|---:|---:|
| 2 | normal | 36255 (`INT_2_10_10_10_REV`) | 4 | 0 |
| 3 | tangente | 36255 | 4 | 4 |
| **5** | **índice de hueso** | **5121 (`UNSIGNED_BYTE`)** | **4** | **8** |
| **6** | **peso de hueso** | **5131 (`HALF_FLOAT`)** | **8** | **12** |

O sea: 4 + 4 + 4×1 + 4×2 = **20**. El nuestro hoy es ElementCount 2 / Stride 8, así que el
paso 3 son **+12 bytes por vértice** y reescribir el buffer entero.

Y el detalle que decide si crashea o no, de `ModelImporter/import_scene.py:1085-1098`:

```
skin_mats = SkinMatrixLayout[FIRSTSKINMAT : LASTSKINMAT]
por cada skin_mat -> un grupo de vértices, en ese orden
blend_indices[j] indexa DIRECTAMENTE esa lista de grupos
```

**El byte del canal 5 NO es el número de hueso: es la posición dentro del tramo
`FIRSTSKINMAT`→`LASTSKINMAT` de la malla.** Los valores de `SkinMatrixLayout` sí son
`JOINTINDEX` de nodos JOINT del `.SCENE` (`_find_joint`, línea 1327). Confundir las dos cosas
es exactamente el «índices fuera de rango» que cerró el juego en la `PRUEBA05`.

En el vanilla eso cuadra así: `SkinMatrixLayout` tiene 23 entradas y `MeshBaseSkinMat` es
`[0, 0, 0, 19]` — la malla del cuerpo usa las 19 primeras y la del ojo arranca en la 19.

> El importador solo lee **3 pesos** de los 4 (`np_blendWeight[i][0:3]`), aunque el hueco de 4
> exista en el buffer.

> **El casado va por vecino más cercano, no por posición exacta** — medido el 15/08 en la
> Task 4. El buffer guarda las posiciones en **half** y `pesos.json` en float, así que el
> mismo vértice sale movido hasta **1,4 ULP**: `1.829884` en el JSON contra `1.8291016` en el
> buffer. Casar por clave exacta falla en **10 014 de los 11 357**, y no es que sean mallas
> distintas —las cajas coinciden a la cuarta cifra y los 4 820 orígenes se alcanzan todos—.
> La tolerancia es **0,003**, entre el peor casado bueno (0,001355) y el segundo vecino más
> cercano de toda la malla (0,005036). No hay solape.

> **El riesgo conocido tiene nombre y ya nos pasó:** con el flag `_F02_SKINNED` puesto y los
> pesos mal, el bicho **se estira sin forma** (`PRUEBA01`). Con el flag puesto y los índices
> fuera de rango, el juego **cierra sin avisar** (`PRUEBA05`). Por eso el flag va el último y
> el `Check` va después.

> **`N1` depende de la `HT_CeilingPlague_PRUEBA01`.** Los dos quieren el locator `TENTACLE_`,
> y la plaga lo alcanza **sin pasar por el `.LSYSTEM`**, que es justo el trozo que `N1`
> intenta diagnosticar. Si la plaga sale bien, `N1` deja de ser un bloqueo y pasa a ser
> curiosidad.

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
| **`Q-MASCARAS`** | ¿Qué canal del `gMasksMap` es qué? El vanilla del huevo da `R` media 179 y `G` media 73, que no cuadra con «R = metalicidad» | Ninguna prueba escrita. Bloquea el tercer mapa del obelisco → [`ASSETS.md`](ASSETS.md) §1.4 |
| **`Q-GLOW`** | ¿Cómo se enciende un emisivo de verdad? Hoy la emisión del marker va **horneada dentro del color base** | Ninguna prueba escrita → [`ASSETS.md`](ASSETS.md) §1.4 |
| **`Q-REFPATHS`** | ¿Se puede recolocar una malla vanilla en otro rig con `ReferencePaths`? | [`ASSETS.md`](ASSETS.md) §3. Curiosidad, no puerta |
| **`Q-CHANCE`** | ¿Qué hace un `Chance > 0` en un descriptor? | Los 172 valen 0.0 en vanilla; no hay ejemplo del que copiar → [`ASSETS.md`](ASSETS.md) §3 |
| **`Q-CARNAGE`** | ¿Qué dispara el modo «carnage» de `MaxFiendsToSpawnCarnage`? | — |
| **`Q-ANTAGONIST`** | ¿`GcAntagonistComponentData` en el huevo salvaje? | Aplazado: exige **añadir** un componente, no cambiar un valor |

---

## 4 · Qué está instalado — 2026-08-14

Todo se mide con **`HorribleTerror_Infestation_4-Hardcore` 0.6.3**, que contiene al mod 1.
`HorribleTerror_Predators` **no debe estar instalado**: escriben los mismos archivos.

**Leído de `GAMEDATA\MODS` el 2026-08-14, carpeta por carpeta.** Son seis, y ninguno más
nuestro:

| Mod | MBIN | |
|---|---:|---|
| `HorribleTerror_Infestation_4-Hardcore` **0.6.3** | 11 | |
| `HT_EggMesh_PRUEBA05` — obelisco entero, con textura **y a su tamaño** | 1 + 5 `ADD_FILES` | |
| **`HT_ScuttlerMesh_PRUEBA11`** — el SkrullCrawler con difuso y máscaras propias | 0 (**7** `ADD_FILES`) | 🏁 la configuración buena |
| `HT_CeilingPlague_PRUEBA01` | 1 | sin medir |
| `HT_DerelictBugs_PRUEBA02` | 1 | |
| `HT_PredatorParts_PRUEBA03` | 1 | |

**Retirados a `GAMEDATA\MODS_Retirados\`** — 16 carpetas: las diez `HT_ScuttlerMesh_PRUEBA01`
a `10`, que escriben los mismos archivos que la `11`; `HT_EggMesh_PRUEBA02`, `03` y `04`;
`HT_LocatorTest_PRUEBA01` (los `.LSYSTEM` que toca la plaga del techo);
**`HT_FiendMarkers_PRUEBA04`**, que escribe el mismo `FREIGHTERFIEND.SCENE.MBIN` que la malla;
y **`HorribleTerror_NecroSkin`**.

`NoDerelictMiniHorrors` **ya no está** en `GAMEDATA\MODS`: apuntaba a las dos carpetas donde
escribe nuestro `Infestation`.

✅ `DisableAllMods` = **`false`** el 2026-08-14. La última sesión no dejó el interruptor
general apagado.

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
