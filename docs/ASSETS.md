# Assets — el aspecto del mod, y cómo meter arte propio

Cómo se cambia lo que se ve: texturas, colores, partes de criatura, **assets nuestros hechos
en Blender**, y dónde se pueden clavar monstruos en el mundo. Absorbió a `MALLA-PROPIA.md`
el 13/08: eran el mismo tema contado dos veces.

Se consulta por secciones; no hace falta leerlo entero. **§0 dice cuál abrir.**

- Verificado contra la instalación local: NMS **170671**, MBINCompiler **6.45.0.1**,
  índice `NMS_FULL_pak_list.txt` (184.919 rutas) y `NMSARC.Precache.pak` descompilado.
- Marcas: sin marca = **leído en el archivo**. `[Inferencia]` = deducido.
  `[Sin probar]` = no se ha llevado al juego.

---

## 0. Resumen — las seis vías, y en qué quedó cada una

Ordenadas por lo que hoy da resultado, no por lo que prometían.

| § | Vía | Sirve para | Veredicto **al 2026-08-13** |
|---|---|---|---|
| **4** | **Blender + NMSDK — assets propios** | Huevos, nidos, props: geometría nuestra | ✅ **Etapas 1 y 2 pasadas en partida el 13/08.** El obelisco del marker sale en el sitio del huevo. Siguiente: su textura (`HT_EggMesh_PRUEBA03`) |
| **2** | Teñir materiales (`gMaterialColourVec4`) | Un color por tipo de bicho | ✅ **visto in-game el 11/08** — la cría salió verde ácido |
| **3** | `.DESCRIPTOR` por partes | Sesgar qué cabezas/bocas salen | ✅ **visto in-game el 12/08** — con `_HEAD_` de 8 a 2 solo salen cabezas de reptil |
| **1** | Sustituir el `.DDS` | «Pegarle un JPG» al Fiend | ✅ **resuelto el 11/08.** `tools/Make-NMSTexture.py` produce un DDS válido |
| **5** | `.LSYSTEM` de los edificios abandonados | Huevos/nidos **dentro** de los edificios | 🟡 por el `.LSYSTEM` falla. **Hay una puerta lateral que no toca el `.LSYSTEM`** y que además trae la plaga del carguero entera → §5.7 |
| **6** | `GcEnvironmentSpawnData.Creatures` | Criatura fija junto a objetos de bioma | ⬜ sigue sin probar |

Y un hallazgo suelto que no encaja en ninguna: **`GcAlienPodComponentData`** (§5.3), la
palanca de «el nido reacciona a tu movimiento y a tu linterna».

**Lo que sigue cerrado en contra:** una **criatura** nuestra. NMSDK no exporta mallas con
pesos de hueso, y toda criatura de NMS es `_F02_SKINNED` — detalle en §4.2.

---

## 1. Ruta del `.DDS` — «pegarles un JPG»

### 1.1 El Fiend es un modelo fijo, y eso lo hace barato

`FIEND.DESCRIPTOR.MBIN` tiene **un solo descriptor**: `_FIEND_BODY`. Cero variación
procedural. Cuatro materiales:

```
MODELS\PLANETS\CREATURES\SPIDERRIG\FIEND\FIEND_MAT.MATERIAL.MBIN
                                        \GLOWEYE_MAT.MATERIAL.MBIN
                                        \TRANSGLOW_MAT.MATERIAL.MBIN
                                        \LAMBERT1.MATERIAL.MBIN
```

Sus texturas, en `NMSARC.TexCreatureSPIDERRIG.pak` (88 MB):

| Archivo | Qué es |
|---|---|
| `TEXTURES\PLANETS\CREATURES\SPIDERRIG\FIEND.BASE.DDS` | **color base — el que se cambia** |
| `…\FIEND.BASE.MASKS.DDS` | máscaras (metalicidad/rugosidad/glow) |
| `…\FIEND.BASE.NORMAL.DDS` | normales |
| `…\FIEND.DDS` | mapa de referencia |

El del carguero es el gemelo: `FREIGHTERFIEND.BASE{,.MASKS,.NORMAL}.DDS`, mismo pak
(y duplicado en `TEXTURES\COMMON\PLAYER\PLAYERCHARACTER\`).

### 1.2 Los depredadores **no** son un objetivo barato

Son procedurales: cada rig tiene su carpeta de texturas y **una textura por pieza**.
`NMSARC.TexCreatureTREXRIG.pak` trae **559** archivos; `TRICERATOPSRIG`, **1135**. No
existe «la textura del depredador»: existen cientos, y cada planeta compone la suya.
Para depredadores la vía barata sigue siendo la **2 (paletas)**.

### 1.3 Cómo se entrega

**Un `.DDS` suelto en la carpeta del mod sustituye al del juego.** No hace falta MBIN ni
build. Precedente en la propia instalación:

- `MODS\TEXTURES\EFFECTS\WARP\SCROLLINGWAVES2.DDS` (Hyperlight Warps 1.4)
- `MODS\Screen\TEXTURES\EFFECTS\GRADIENT_LONGFALLOFF.ORANGE.DDS`

Es decir: copiar a `GAMEDATA\MODS\<mod>\TEXTURES\PLANETS\CREATURES\SPIDERRIG\FIEND.BASE.DDS`.
Con AMUMSS, lo mismo se hace con **`ADD_FILES` + `EXTERNAL_FILE_SOURCE` / `FILE_DESTINATION`**
(`README-AMUMSS_Script_Rules.html`, sección `ADD_FILES`).

### 1.4 🔓 Resuelto el 2026-08-07 — el formato exacto y el conversor

Extraído `NMSARC.TexCreatureSPIDERRIG.pak` (192 archivos) y leídas las cabeceras:

| Textura | Formato |
|---|---|
| `FIEND.BASE.DDS` | **BC7_UNORM**, 2048×2048, **12 mips**, cabecera DX10 |
| `FIEND.BASE.MASKS.DDS` | `ATI1` (BC4, un canal) |
| `FIEND.BASE.NORMAL.DDS` | `ATI2` (BC5) |

De los 192 archivos del pak: **109 BC7, 56 ATI2, 27 ATI1**. Ni un solo DXT/BC3, así que
BC7 no es opcional: es lo que hay que producir.

**No existe `texconv` en el sistema y no hizo falta.** `tools/Make-NMSTexture.py` codifica
BC7 en **modo 6** (un subset, dos endpoints RGBA de 7 bits + p-bit, índices de 4 bits) con
numpy, y copia la cabecera DDS byte a byte de la textura vanilla, así que formato,
dimensiones y número de mips salen idénticos por construcción.

Validado de dos formas independientes:

- El archivo generado pesa **5.592.580 bytes, exactamente lo mismo que el vanilla**.
- **Pillow lo decodifica** (soporta BC7 desde 9.4): PSNR **39,15 dB** contra el original.
  Que lo lea un decodificador ajeno prueba que el empaquetado de bits sigue el spec, no
  solo que es coherente consigo mismo.

```
python tools/Make-NMSTexture.py asset/necro/Spider-Skull.jpg <vanilla.dds> <salida.dds> --tile 4
```

#### 🔓 El canal del `gMasksMap` de criatura se comporta como **brillo**, no como rugosidad

Medido el 2026-08-22 sobre el `FIEND` vanilla y el nuestro. En criaturas el mapa es `ATI1` de
**un solo canal** (`_F25_MASKS_MAP`), y lo que hace ese canal se dedujo del resultado en
partida, no del nombre:

| | media | útil media | p1 | p99 | máx |
|---|---:|---:|---:|---:|---:|
| `FIEND` vanilla — hueso mate | 85,4 | 86,9 | 5 | 156 | 192 |
| Nuestro `roughness` de Meshy tal cual — **sale de baba** | 173,6 | 199,5 | 69 | 236 | 255 |

Valor **alto = mojado**. El asset entrega `roughness`, donde alto = áspero = mate, así que el
mapa entra **al revés**. `255 − 173,6 = 81`, contra los `85` del vanilla. El arreglo es
invertir, no atenuar — y **el fondo de UV sin usar hay que retenerlo a 0**, porque invertirlo
lo pone a 255 y sangra por los mips. El detalle está en
[`PENDIENTES.md`](PENDIENTES.md) §2.1.

### 🔓 Ampliado el 2026-08-13 — también produce normales (ATI2/BC5)

Para texturar el obelisco hacía falta el otro formato del juego. La herramienta ahora
**elige el codificador leyendo el `fourcc` del `.DDS` vanilla de referencia**: `DX10`+dxgi 98
→ BC7, `ATI2` → BC5. BC5 son dos bloques BC4 seguidos, uno por canal, con endpoints de 8 bits
e índices de 3 bits en el modo de ocho valores.

Dos opciones nuevas: `--suma IMG` suma otra imagen al origen saturando en 255 —sirve para
**hornear un mapa de emisión dentro del color base** mientras el glow real no esté resuelto—
y `--canales RG` dice qué dos canales del origen van a los dos bloques del BC5.

**El orden de canales no se adivinó, se midió.** Pillow decodifica
`FIEND.BASE.NORMAL.DDS` vanilla como `R≈126, G≈127, B=0`: el primer bloque es X, el segundo
es Y, y la Z la reconstruye el shader. Nuestro decodificador da lo mismo con un error máximo
de 0.86 sobre 255 contra Pillow, o sea que el empaquetado de bits coincide con una
implementación ajena, no solo consigo mismo.

| Salida del 13/08 | Formato | Bytes | Contra el vanilla | PSNR |
|---|---|---:|---|---:|
| `work/textures/MARKER.BASE.DDS` | BC7 2048² 12 mips | 5.592.580 | **idéntico** a `FIEND.BASE.DDS` | 34,6 dB |
| `work/textures/MARKER.BASE.NORMAL.DDS` | ATI2/BC5 2048² 12 mips | 5.592.560 | **idéntico** a `FIEND.BASE.NORMAL.DDS` | 51,5 dB |

⚠️ **No se generó mapa de máscaras, a propósito.** El vanilla del huevo
(`EGGSHELL.BASE3.1.MASKS.DDS`, ATI2) mide `R` media 179 y `G` media 73. Si `R` fuera
metalicidad, un cascarón de huevo sería metálico al 70 %, que no se lo cree nadie — así que
la convención de canales que circula por ahí no cuadra con lo que hay en el archivo, y
**no sabemos qué canal es qué**. Se deja el vanilla y queda como pregunta abierta.

⚠️ **Los JPG de `asset/necro/` son arte de Dead Space.** Valen para probar la ruta en
local; **no se pueden publicar**. Para Nexus hay que pintar encima del atlas vanilla.

---

## 2. Ruta de las paletas — colores

**Ya resuelta y ya probada in-game** en el mod 1. Cadena:

```
.TEXTURE.MBIN declara TkPaletteTexture  ->  *COLOURPALETTES.MBIN del bioma  ->  color por semilla
```

- 5 paletas de piel usadas por fauna: `Scale` 1318, `Underbelly` 512, `Fur` 470,
  `Feather` 128 (+`Rock` y `Paint`, descartadas por compartirse con terreno y naves).
- Script de referencia archivado: `work/scripts/HorribleTerror_RedFauna.lua` — 47 archivos
  × 960 líneas, rojo carne, **confirmado jugando el 2026-07-29**.
- Detalle: `CHANGELOG.md`, «Fase 2».

### 🔓 Resuelto el 2026-08-07 — el Fiend NO pasa por paletas, pero se tiñe igual

**No existe `FIEND.TEXTURE.MBIN`.** Las piezas procedurales del `SPIDERRIG` sí lo tienen
(`MANTISBODY`, `CRABHEAD`, `SPIDEREYE`… 20 archivos, con su `TkPaletteTexture`), pero el
Fiend **no**: su color sale directo del `.DDS`. La vía de las paletas no lo alcanza, y por
eso el `RedFauna` del mod 1 nunca lo tocó.

> ⚠️ **Corregido el 2026-08-12 — el FreighterFiend sí tiene `.TEXTURE.MBIN`.** Aquí se decía
> que ni el Fiend ni el FreighterFiend lo tenían. **Falso para el segundo**, y no estaba en la
> carpeta donde se buscó:
>
> ```
> TEXTURES\COMMON\PLAYER\PLAYERCHARACTER\FREIGHTERFIEND.TEXTURE.MBIN
> TEXTURES\COMMON\PLAYER\PLAYERCHARACTER\FREIGHTERFIENDEYE.TEXTURE.MBIN
> ```
>
> Descompilado: es un `cTkProceduralTextureList` con **tres capas** —`SKIN`, `MARKINGS`
> (3 texturas) y `BASEF`— todas con `TkPaletteTexture` apuntando a la paleta **`Custom_Head`**.
> O sea: el FreighterFiend **sí pasa por paletas**, y por una que el mod 1 nunca tocó porque
> `Custom_Head` no está en las cinco de fauna.
>
> **Lo que no se sabe todavía:** si esa paleta se aplica al bicho del carguero o solo al
> modelo de jugador —la ruta es `PLAYERCHARACTER`—, y si el color de paleta **pisa en runtime**
> el `gMaterialColourVec4` del material. Esa segunda pregunta es candidata a explicar la
> prueba fallida del 12/08. `[Sin probar]`
>
> **Y el MiniFiend no tiene textura propia.** `MINIFIEND_PET\FFIENDMAT.MATERIAL.MBIN` apunta a
> `TEXTURES\PLANETS\CREATURES\SPIDERRIG\FREIGHTERFIEND.BASE{,.MASKS,.NORMAL}.DDS`: **comparte
> las tres con el Horror grande.** Consecuencia para la vía 1: retexturar el grande repinta
> también a los pequeños. Lo único que los separa hoy es el `gMaterialColourVec4`, que sí es
> un archivo por bicho.

**Pero hay una vía más barata que el DDS.** Sus materiales tienen el uniform de tinte:

```
MODELS\PLANETS\CREATURES\SPIDERRIG\FIEND\FIEND_MAT.MATERIAL.MBIN
MODELS\PLANETS\CREATURES\SPIDERRIG\FREIGHTERFIEND\FFIENDMAT.MATERIAL.MBIN
    gMaterialColourVec4 = (1, 1, 1, 1)   <- multiplicador, vanilla neutro
```

Bajar G y B tiñe el bicho de rojo carne **sin tocar una sola textura**: tres floats, un
MBIN, cero megas. Es lo que hace `HorribleTerror_NecroSkin` sobre el FreighterFiend.
`[Sin probar in-game]`

---

## 3. Ruta por partes — «por la categoría de las entidades mostradas»

Existe y está mapeada. `*.DESCRIPTOR.MBIN` es un **árbol de categorías**:

```
_TREX_
 └ _TREX_3XRARE ─ _TAILB_ ─ _TAILB_ALIEN1 ─ _VERS_ ─ _VERS_1 / _VERS_2 …
```

`trex.descriptor` tiene **172 descriptores** repartidos en categorías `TypeId`:
`_HEAD_`, `_HEADB_`, `_MOUTH_`, `_MOUTHE_`, `_MOUTHF_`, `_MOUTHW_`, `_EYES_`, `_EYESB_`,
`_EYESE_`, `_LIMBS_`, `_BODY_`, `_REAR_`, `_ORBS_`, `_ANTENNAS_`, `_BACKPACK_`,
`_JELLYFINGERS_`, `_REXHEAD_`, `_RATBACK_`…

Palancas posibles:

1. **`Chance`** — subirlo en las piezas feas para que salgan más.
2. **Borrar descriptores** — si solo queda una opción en la categoría, sale siempre.

⚠️ **Los 172 `Chance` valen `0.000000`.** No hay un solo ejemplo vanilla de valor
distinto de cero en el archivo, así que el reparto real parece uniforme y **no sabemos qué
hace un `Chance > 0`** ni en qué escala. Por eso la palanca que se prueba es la 2, borrar.

No aplica al Fiend ni al FreighterFiend: un descriptor, una pieza.

> ⚠️ **Corregido el 2026-08-12 — casi todo lo que sigue en esta sección estaba mal.** Se
> recorrió el árbol de verdad, con un parser recursivo en vez de leer el XML plano, y salieron
> tres errores. Detalle en [`../work/scripts/predadores/README.md`](../work/scripts/predadores/README.md):
>
> 1. **`_HEAD_` tiene 8 opciones**, colgadas directas de `_TREX_4`. Lo de que las cabezas
>    estaban repartidas como hojas de `_CHACC_`, `_REXHEADJ_`, `_REAR_` y `_THACC_` es al
>    revés: **ésas son los accesorios que cuelgan de cada cabeza**. Cabeza, cuerpo y cola son
>    tres ranuras independientes.
> 2. **`_RATBACK_` tiene 14 hojas, no 15.** La «15ª» que se avisaba de no borrar
>    (`_BODY_TREX`) es hermana en `_BODY_`; nunca estuvo dentro de la lista.
> 3. **`REMOVE = "SECTION"` con `CREATE_HOES = "TRUE"` no borra el nodo: lo vacía.** El manual
>    de AMUMSS dice que el flag existe *«to preserve the Head as a HOES»*. La tabla de abajo
>    («15 opciones → 2») nunca fue cierta: quedaban 14 ranuras con 13 huecas. Sin el flag el
>    elemento sí desaparece y el MBIN recompila igual — verificado el 2026-08-12 con
>    `HT_PredatorParts_PRUEBA03`: de 172 descriptores quedan **91**, `_HEAD_` con **2**.

### 🔓 Resuelto el 2026-08-07 — borrar opciones funciona

`HT_PredatorParts_PRUEBA01` borra 26 descriptores de `TREX.DESCRIPTOR.MBIN` con
`REMOVE = "SECTION"` + `CREATE_HOES = "TRUE"`. Verificado descompilando el MBIN construido:

| Categoría | Vanilla | Después |
|---|---:|---:|
| `_RATBACK_` | 15 opciones | **2** (`_RATBACK_2` + `_BODY_TREX`) |
| `_REXBACK_` | 15 opciones | **2** (`_REXBACK_2` + `_BODY_HOLESXRARE`) |

Dos avisos que costaron una build:

1. **`SPECIAL_KEY_WORDS` con varios pares es un camino encadenado (AND), no una lista.**
   Poner los 26 ids en un solo `SKW` da **0 cambios y ningún error**. Hay que emitir una
   sub-tabla por descriptor — en el script se generan con un `for`, que AMUMSS acepta
   porque los `.lua` son Lua de verdad.
2. **`Build-Tiers.ps1` reporta 0 cambios en un mod que solo borra.** El contador lee
   `[N CHANGE(s) made]` del REPORT y los `REMOVE` no cuentan como CHANGE. Hay que mirar el
   log (`-- Lines N - M REMOVED`) o descompilar el MBIN.

### ⚠️ El descriptor es un árbol, no una lista de categorías

`_HEAD_` parece tener **una sola** opción, pero el rig tiene cinco cabezas: están repartidas
como hojas de otras ramas — `_HEAD_TREX` cuelga de `_CHACC_`, `_HEAD_RAT` de `_REXHEADJ_`,
`_HEAD_TOUCANA` de `_REAR_`, `_HEAD_ALIEN` de `_THACC_`. Y en las listas de lomo, el último
elemento (`_BODY_TREX`, `_BODY_HOLESXRARE`) **no es un lomo**: es otra rama de cuerpo
entera. Borrarlo por descuido quita un tipo de bicho completo.

**Traducción de «que solo haya 4 heads y 5 eyes»:** sí se puede, pero hay que recorrer el
árbol rig por rig y decidir a mano qué hoja se queda, no filtrar por nombre de categoría.

### ✅ Confirmado en partida el 2026-08-09

`HT_PredatorParts_PRUEBA01` lleva desplegado desde el 07/08 y se jugó el 09/08: **ningún
TREX crasheó y ninguno salió con el modelo roto**. La vía queda validada de punta a punta.

Lo que eso decide: **el descriptor tolera huecos.** No hace falta la alternativa de sesgar
con `Chance` — que además seguiría siendo a ciegas, porque los 172 valen 0.0 y no hay
ejemplo vanilla del que copiar la escala. **Borrar es la palanca.**

Queda sin cerrar si los lomos **se repiten** de verdad (prueba 5.2): es aritmética de 26
secciones borradas, pero no se comparó pieza a pieza.

### 🔓 2026-08-09 — `BUGFIEND` también es procedural, y es de otro rig

Buscando los materiales para el mod de marcadores salió un dato que cambia el mapa:

```
MODELS\PLANETS\CREATURES\ARTHROPOD\BUGFIEND.SCENE.MBIN
MODELS\PLANETS\CREATURES\ARTHROPOD\BUGFIEND.DESCRIPTOR.MBIN   <- tiene descriptor
MODELS\PLANETS\CREATURES\ARTHROPOD\BUGFIEND\*.MATERIAL.MBIN   <- 9 materiales
```

**La cría del brood no es del `SPIDERRIG`: es del rig `ARTHROPOD`, y tiene descriptor
propio.** Hasta ahora se daba por hecho que toda la familia Fiend era «un descriptor, una
pieza» — eso vale para `FIEND` y `FREIGHTERFIEND`, **no para `BUGFIEND`**.

Consecuencia práctica: la ruta por partes **sí alcanza a un bicho del mod 2**, no solo a la
fauna procedural. Es el único candidato de la familia al que se le pueden quitar piezas.

> 🔓 **Corregido el 2026-08-21, leyendo el `BUGFIEND.DESCRIPTOR`:** ni es aleatorio ni tiene
> los `ReferencePaths` vacíos. Son **ocho grupos con una sola opción cada uno** y `Chance 0.0`
> —o sea la cría vanilla **siempre sale igual**—, y los ocho `ReferencePaths` apuntan a
> `MODELS/PLANETS/CREATURES/ARTHROPOD/ARTHROPOD.SCENE.MBIN`. Lo que estaba vacío eran los 172
> del `TREX`, y eso no se generaliza. Detalle y consecuencias en
> [`../work/scripts/malla/README.md`](../work/scripts/malla/README.md), serie `HT_ZombieMesh`.

### ⛔ `ReferencePaths` — la vía que parecía y no es (todavía)

Cada nodo del descriptor tiene este campo:

```xml
<Property name="Descriptors" value="TkResourceDescriptorData" _id="_TAILB_ALIEN1">
  <Property name="Id"   value="_TAILB_ALIEN1" />
  <Property name="Name" value="_TailB_Alien1" />
  <Property name="ReferencePaths" />        <!-- VACÍO en los 172 -->
  <Property name="Chance" value="0.000000" />
```

Si `ReferencePaths` aceptara una ruta a un `.SCENE` nuestro, sería **exactamente** «meter
nuestra propia cabeza»: se apunta el nodo a otra malla y listo, sin geometría nueva.

**Pero en `TREX.DESCRIPTOR` está vacío en los 172 descriptores.** La malla no sale de ahí:
sale de nodos **con ese mismo nombre** dentro del `.SCENE` del rig. El descriptor **elige**
entre piezas que ya están en la escena; no las trae de fuera.

Así que la pregunta real es otra: **¿el juego resuelve un `ReferencePaths` con ruta puesta,
o lo ignora?** No hay ejemplo vanilla en este archivo del que copiar. Es la vía barata que
queda por probar, y la prueba es pequeña: poner una ruta a un `.SCENE` vanilla de otro rig
en **un** descriptor y mirar si sale ese trozo, sale el de siempre, o crashea.

⚠️ Aunque funcione, no da un bicho a la carta: la malla ajena vendría **sin pesar contra el
esqueleto** de este rig. Lo más probable es que salga deformada o flotando. Serviría para
robar piezas entre rigs parecidos, no entre cualquiera.

---

## 4. Assets propios — clonar datos, y esculpir con Blender

- **§4.1** clonar y editar lo que ya existe · **§4.2** qué se puede esculpir y qué no
- **§4.3 el plan por etapas de Blender + NMSDK — la Etapa 1 pasó el 13/08**

### 4.1 Clonar y crear entidades

AMUMSS lo soporta:

- **`ADD_FILES`** con `INTERNAL_FILE_SOURCE` (copiar un archivo del juego a otra ruta),
  `EXTERNAL_FILE_SOURCE` (traer uno nuestro) o `FILE_CONTENT`.
- **`MBIN_FILE_SOURCE` sintaxis alternativa #3** — clonar un MBIN a una ruta nueva **y**
  editarlo en la misma pasada. Es la forma correcta de clonar un `.ENTITY` o un `.SCENE`.

Uso realista para este mod: clonar `FIENDEGG.SCENE` + su `.ENTITY` a una ruta propia y
darle otros valores (más vida, otra explosión, otro `FiendCrime`) sin tocar el huevo
vanilla. Un bicho **nuevo de verdad** es otra cosa: haría falta geometría, y el
comportamiento va atado al `CreatureID` de `CREATUREDATATABLE`, que no acepta IDs
inventados sin más. **Última de la lista.**

### 🔓 «¿Cómo metemos nuestros propios assets?» — respuesta del 2026-08-07

Hay **tres niveles**, y solo los dos primeros están a nuestro alcance hoy:

| Nivel | Qué se mete | Cómo | Estado |
|---|---|---|---|
| **1. Texturas** | `.DDS` propio en cualquier ruta del juego | `ADD_FILES` + `EXTERNAL_FILE_SOURCE` / `FILE_DESTINATION`, o copiar el archivo a la carpeta del mod | ✅ **hecho y desplegado** |
| **2. Datos** | `.MBIN` clonado a ruta nueva y editado | `MBIN_FILE_SOURCE` sintaxis #3, o `ADD_FILES` + `INTERNAL_FILE_SOURCE` | ✅ soportado, sin usar aún |
| **3. Malla** | `.GEOMETRY.MBIN.PC` + `.SCENE.MBIN` nuevos | **AMUMSS no los genera.** MBINCompiler compila datos, no modelos. Haría falta **Blender + NMSDK** | ⛔ fuera de la caja de herramientas actual |

Es decir: **repintar y recomponer lo que ya existe, sí; esculpir un bicho nuevo, no** —
no sin meter Blender y el addon NMSDK en el proyecto, que es una decisión aparte.

### 4.2 Qué se puede esculpir, y qué no

| Qué se quiere | ¿Se puede hoy? | Cómo |
|---|---|---|
| **Esculpir** un objeto **estático** (huevo, nido, props) | ✅ **Sí, y la ida y vuelta está probada en partida** | Blender + NMSDK → §4.3 |
| **Quitar** piezas para que salgan siempre las que nos gustan | ✅ Sí, visto en partida el 12/08 | `REMOVE = "SECTION"` sobre el `.DESCRIPTOR`. Es `HT_PredatorParts_PRUEBA03` |
| **Repintar** una pieza o un bicho entero | ✅ Sí, visto en partida el 11/08 | `gMaterialColourVec4` del material. Es `HT_FiendMarkers_*` |
| **Retexturar** con arte propio | ✅ Sí, resuelto el 11/08 | `tools/Make-NMSTexture.py` + `ADD_FILES`. Es `HorribleTerror_NecroSkin` |
| **Mover** una malla vanilla a otro rig | ⬜ Sin probar, y degradado a curiosidad | `ReferencePaths`, arriba en §3 |
| **Esculpir** una pieza de **criatura** (cabeza, ojo) | ⛔ **No, y tampoco con Blender** | El muro está aquí abajo |

**El muro, y por qué no hay truco de script que lo sortee.** Una pieza de criatura tiene que
**pesar contra el esqueleto** del rig, hueso por hueso. `docs/exporting/node_docs.md` de
NMSDK, sección `Joint`, verbatim:

> «A `Joint` node is used for animations involving bones and meshes with weight bindings.
> **Currently the ability to export scenes with these types of animations is not possible**
> but it will hopefully come in the future, so stay tuned!»

Y **toda criatura de NMS es `_F02_SKINNED`** — flag leído en `FFIENDMAT`, `FFIENDEYEMAT` y
`GLOWEYE_MAT`. AMUMSS compila datos, no modelos; NMSDK compila modelos, pero no con pesos.
Eso explica de paso el dato que parecía raro: que nadie de la comunidad haya publicado nunca
una criatura nueva. No es difícil, **es que la herramienta no lo permite**.

Lo que queda para las criaturas son las dos palancas ya probadas —**podar el descriptor** y
**teñir el material**—, y ninguna necesita Blender.

#### 🔴 «¿Y con el Fiend podemos hacer lo mismo que con el huevo?» — no, y aquí está el número

Es la pregunta natural después de ver el obelisco en partida: si una malla nuestra sustituye
al huevo, ¿por qué no al Horror? Porque el huevo es un objeto rígido y el Horror no.

| | Huevo (`FIENDEGG.SCENE`) | Fiend (`FIEND.SCENE`) |
|---|---:|---:|
| Nodos `JOINT` | **0** | **44** |
| Necesita pesos de hueso | no | sí, uno por vértice y hueso |
| ¿NMSDK lo exporta? | ✅ probado el 13/08 | ⛔ no, ni con Blender |

Contado sobre el `.SCENE` descompilado del juego el 13/08. Meterle la geometría de un
necromorfo a un esqueleto de 44 huesos sin pesos da un amasijo, no un bicho. Y el muro no es
de este proyecto: es que **NMSDK no exporta pesos**, verbatim en su propia documentación
(arriba). Por eso nadie de la comunidad ha publicado nunca una criatura nueva.

**Lo que sí se puede con el Fiend, y ya está resuelto:** repintarlo entero con una textura
nuestra por la vía 1 (`HorribleTerror_NecroSkin` ya lo hace), teñirlo con
`gMaterialColourVec4`, y —solo el `BUGFIEND`, que es procedural— podarle piezas del
descriptor. Cambiarle **la silueta** no. Para eso el camino realista es al revés: **poner
mallas nuestras alrededor del bicho** —huevos, nidos, props—, que es justo lo que la Etapa 2
acaba de abrir.

Misma respuesta, mismo motivo, para el tentáculo del techo: `TENTACLEPLANT.SCENE` tiene
**13 `JOINT`**. Esculpir uno propio, no; **cambiar por cuál se sustituye, sí** → §5.7.

#### 🔓 2026-08-13 — cuáles de nuestros modelos valen, leído dentro del `.FBX`

Se escanearon los `.FBX` de `asset/Modelos Descomprimidos/` buscando los tokens que delatan
un esqueleto: `Deformer` y `Cluster` (los pesos), `LimbNode` (los huesos) y `AnimationCurve`.

| Modelo | Tamaño | `Deformer` | `Cluster` | `LimbNode` | `AnimationCurve` | Qué es |
|---|---:|---:|---:|---:|---:|---|
| `marker-1` *(el que ya funciona)* | 0,1 MB | 0 | 0 | 0 | 0 | estático |
| **`ScrullCrawler_max_hd`** | 14,3 MB | **0** | **0** | **0** | **0** | ✅ **estático** |
| **`Necro_partes_7_own_2`** | 6,1 MB | **0** | **0** | **0** | **0** | ✅ **estático**, y en **22 objetos** sueltos |
| `zombie-monster-slasher-necromorph` | 0,7 MB | 59 | 56 | 66 | 203 | ⛔ **rigged y animado** |

**Los dos primeros son exactamente igual de exportables que el marker.** Cero huesos, cero
pesos: entran por el mismo conducto de la Etapa 2 sin ninguna incógnita nueva.

**El tercero es el único que no**, y es una ironía útil: viene con esqueleto de 66 huesos y
203 curvas de animación —justo lo que haría falta para un bicho— y es precisamente eso lo que
NMSDK no sabe exportar. Como estático saldría congelado en su pose «Agonizing».

> ⚠️ **Ser estático no los mete en la ranura del Fiend.** Que no tengan huesos no cambia que
> `FIEND.SCENE` **espera** una malla pesada contra 44 huesos. Lo que abre es la otra jugada:
> meterlos donde el juego ya pone objetos rígidos.

**Dónde caben, por orden de riesgo:**

| Ranura | Qué es hoy | Por qué encaja |
|---|---|---|
| **El huevo** (`RARERESOURCE\GROUND\FIENDEGG`) | hoy el obelisco | Conducto **ya probado dos veces**. Un `ScrullCrawler` agazapado en vez de huevo = cría dormida por todo el planeta, y hereda `FIENDHATCH` y el `IncreaseFiendWanted` al romperlo |
| **Props de edificio abandonado** — `WALLPROP_`, `WALLHIGHPROP_`, `TECHBOX_`, `TERMINAL_` | escombro y cacharros | 5 reglas cada uno en los tres edificios (§5.1). Un necromorfo clavado a la pared. Ojo: `DEBRISLARGE_COMMON.SCENE` **también es un envoltorio con `REFERENCE` y sin `MESH`**, igual que el tentáculo (§5.7) |
| **`Necro_partes_7_own_2`, por piezas** | — | 22 objetos sueltos en un `.FBX`: da para varios props distintos de un solo modelo, o para un descriptor propio con variantes (Etapa 4) |

⚠️ **El presupuesto de polígonos hay que mirarlo en Blender antes de exportar.** El marker
que funciona son **822 vértices y 1636 triángulos** y su `.FBX` pesa 0,1 MB. `ScrullCrawler`
pesa 14,3 MB y `Necro_partes` 6,1 MB — dos órdenes de magnitud arriba. Son mallas de Meshy /
Tripo sin optimizar, y un prop que se instancia por todo un planeta a esa densidad es un
problema de rendimiento, no de formato. **Decimar en Blender es parte del trabajo**, y el
número al que apuntar es el del vanilla, no el del ZIP descargado.

> `ADD_FILES` con `EXTERNAL_FILE_SOURCE` necesita **ruta absoluta**. En
> `HorribleTerror_NecroSkin.lua` está en la constante `NECRO_DDS`, y hay que ajustarla si el
> repo se mueve de sitio.

### 4.3 Blender + NMSDK — el plan por etapas

Absorbido de `MALLA-PROPIA.md` (abierto el 09/08, cerrado como documento aparte el 13/08).
**Si una etapa falla, se para: no se pasa a la siguiente.**

#### ✅ Etapa 1 — ¿carga lo que exporta? · **PASÓ el 2026-08-13**

Ida y vuelta de un asset estático vanilla: importar `FIENDEGG.SCENE.MBIN` a Blender con
NMSDK, **re-exportarlo sin tocar un vértice**, y entregarlo con `ADD_FILES` +
`EXTERNAL_FILE_SOURCE` para que pise al vanilla. Es `HT_EggMesh_PRUEBA01`.

**Resultado: el huevo sale igual que siempre.** Eso cierra dos incógnitas de una:

| Lo que estaba en duda | Veredicto |
|---|---|
| ¿El formato de NMSDK `alpha13` (soporte 6.2X) carga en NMS **6.45**? | ✅ **sí** |
| ¿La ida y vuelta destroza la geometría o la escala? | ✅ **no.** Sale idéntico |

Se eligió el huevo de superficie —y no un cubo colgado de un edificio, como decía el plan
original— porque el locator `TENTACLE_` de los `.LSYSTEM` está roto y sin diagnosticar. Un
cubo que no sale por ahí no distingue «NMSDK no sirve» de «el conducto no sirve».

#### ✅ Etapa 2 — la primera malla nuestra · **PASÓ el 2026-08-13**

Mismo conducto, geometría distinta: el **obelisco del marker** (822 vértices, 1636
triángulos, importado en FBX) en el sitio del huevo vanilla. Sin huesos, sin pesos, sin
descriptor — un objeto estático con su material. Es `HT_EggMesh_PRUEBA02`.

**Resultado: el obelisco sale en el mundo, en el sitio del huevo.** Es la primera geometría
nuestra dentro de No Man's Sky. El mod lo reparte sin escribir ninguna regla nueva, porque
del huevo se conservaron el material, la `.ENTITY` y la colisión.

#### Etapa 2b — su propia textura ⬅ **aquí estamos**

`HT_EggMesh_PRUEBA03`: la misma malla, pero con `MARKER.BASE.DDS` y
`MARKER.BASE.NORMAL.DDS` en vez del atlas del huevo de cueva. Se reapunta el `gDiffuseMap` y
el `gNormalMap` de
`MODELS\PLANETS\BIOMES\COMMON\RARERESOURCE\GROUND\FIENDEGG\EGGSHELL_MAT.MATERIAL.MBIN`, que
es **un archivo exclusivo del huevo de superficie**: el huevo de cueva
(`RARERESOURCE\CAVE\EGGRESOURCE`), el del carguero (`SPACEBASE\FIENDEGG`) y el de recompensa
(`FIENDEGGPARTS\FIENDEGGREWARD`) tienen cada uno su propia copia y no se tocan.

Detalle del conversor y del orden de canales en §1.4. Carpetas y vuelta completa de Blender:
[`../BLENDER/README.md`](../BLENDER/README.md).

#### Etapa 3 — un `props` propio para los edificios

Lo mismo, colgado de un locator de `.LSYSTEM`. **Requiere cerrar N1 antes**
([`PENDIENTES.md`](PENDIENTES.md) §2): es el conducto que hoy no funciona. Ojo: lo que se
cuelga de `TENTACLE_` es un **envoltorio sin malla** (§5.7), así que la Etapa 3 no sustituye
al tentáculo, sino a la escena a la que ese envoltorio apunta.

#### Etapa 4 — descriptor propio, solo para estáticos

NMSDK **sí** genera proc-gen: nodo `Reference` con *Is a proc-gen scene?*, hijos con *Proc
type* `Random` + *Proc prefix*, y produce las hojas `_[PREFIX]_[NOMBRE]` — el mismo esquema
que `_TREX_` / `_HEAD_`. Sirve para que **nuestro** nido o huevo tenga variantes al azar.
**No sirve** para meter una hoja nuestra en `TREX.DESCRIPTOR`: eso vuelve al muro de §4.2.

#### El banco de trabajo

**Las carpetas, cuál se abre para ver el modelo actual y el arreglo del prefijo están en
[`../BLENDER/README.md`](../BLENDER/README.md).** Resumen de una línea: se modela en
`BLENDER/proyectos/`, NMSDK escribe en `BLENDER/CUSTOMMODELS/…` —que se pisa en cada
exportación—, y lo bueno se congela en `work/models/<modelo>mesh/`, que es de donde tira el
`.lua`.

| Pieza | Estado |
|---|---|
| Blender **≥ 4.2** (lo pide el README de `master`; la web de docs dice 2.80 y está desfasada) | ✅ instalado |
| NMSDK **`0.10.0-alpha13`** (10/06/2026), desde el `.zip` del release | ✅ instalado |
| Rutas del addon: **PCBANKS** y **MBINCompiler** (`tools\AMUMSS\MODBUILDER\MBINCompiler.exe`) | ✅ configuradas |
| Carpeta de exportación | `BLENDER\CUSTOMMODELS\MODELGROUP\MODELS\...` — NMSDK prefija `CUSTOMMODELS/MODELGROUP` en **tres sitios del `.SCENE`**, y hay que quitarlo a mano antes de congelar |

**El pipeline de mods no cambia.** NMSDK fabrica archivos, AMUMSS los reparte: esa mitad ya
estaba resuelta y probada por `HorribleTerror_NecroSkin`.

Fuentes leídas de primera mano el 12/08:
[repo](https://github.com/monkeyman192/NMSDK) ·
[`0.10.0-alpha13`](https://github.com/monkeyman192/NMSDK/releases/tag/0.10.0-alpha13) ·
[docs](https://monkeyman192.github.io/NMSDK/) (⚠️ desfasada en el setup) ·
`docs/exporting/node_docs.md`, `importing.md` (*import bones* «still reasonably broken»),
`exporting.md`, `proc_gen.md`, `animations.md`.

---

## 5. ⭐ Fijar monstruos a los edificios abandonados del planeta

**Se puede, y por una vía barata que no habíamos visto.**

### 5.1 Los edificios abandonados son L-systems

```
MODELS\PLANETS\BIOMES\COMMON\BUILDINGS\ABANDONED\ABANDONDEDSCIENTIFIC.LSYSTEM.MBIN
                                                \ABANDONDEDTRADER.LSYSTEM.MBIN
                                                \ABANDONDEDWARRIOR.LSYSTEM.MBIN
                                        (+ las 3 variantes UNDERWATER_)
```

(el typo `ABANDONDED` es de Hello Games). Cada uno es un `cTkLSystemRulesData`: reglas que
cuelgan modelos de **locators** con una probabilidad.

```xml
<Property name="LocatorType" value="TENTACLE_" />
<Property name="Entries" value="TkLSystemLocatorEntry" _index="0">
  <Property name="Model" value="MODELS/PLANETS/BIOMES/COMMON/BUILDINGS/PROPS/ABANDONED/INTERIOR_TENTACLEPLANT.SCENE.MBIN" />
  <Property name="Probability" value="30.000000" />
</Property>
```

Locators disponibles (nº de reglas que los usan):

| Edificio | Reglas | Entradas | Locators de props |
|---|---:|---:|---|
| `SCIENTIFIC` | 13 | 55 | `TENTACLE_` ×5, `WALLPROP_` ×5, `WALLHIGHPROP_` ×5, `TECHBOX_` ×5, `TERMINAL_` ×5 |
| `TRADER` | 13 | 47 | ídem + `WALLATTATCH_` |
| `WARRIOR` | 16 | 56 | ídem + `CORRIDOR_`, `SAVEPOINT_` |

**`TENTACLE_` ya es un hueco de bicho orgánico colgado, al 30 %, en los tres edificios.**
Es el sitio evidente donde meter otra cosa.

### 5.2 Qué se puede colgar ahí

| Candidato | Ruta | Por qué |
|---|---|---|
| **Huevo de Fiend** | `MODELS\PLANETS\BIOMES\COMMON\RARERESOURCE\GROUND\FIENDEGG.SCENE.MBIN` | ⭐ **el más seguro**: ya es un asset de superficie planetaria y su spawn ya funciona (§5.4) |
| Nido del carguero | `…\BUILDABLEPARTS\SPACEBASE\INFESTATION\LARGEPILLARSLIME.SCENE.MBIN` (y `MEDIUMHANGSLIME`, `LARGE90SLIME`) | Es el nido de verdad del carguero, con su componente de agro |
| Huevo del carguero | `…\SPACEBASE\FIENDEGG.SCENE.MBIN` | Variante interior del huevo |

⚠️ Los `SPACEBASE\*` son piezas de interior de carguero y **no está probado** que funcionen
colgadas de un edificio de superficie (iluminación, colisión, navmesh). Por eso el huevo de
`RARERESOURCE\GROUND` va primero: mismo efecto y cero incógnitas de contexto.

Dos formas de escribirlo:
- **Sustituir** el `Model` de la entrada `TENTACLE_` → cambio de un valor, ×5 reglas.
- **Añadir** una entrada al lado y repartir la probabilidad → `ADD_SECTION`, más limpio de
  cara a Nexus porque no borra contenido vanilla.

### 5.3 Cómo funcionan de verdad los monstruos del carguero

Dos bichos distintos, no uno:

| Bicho | Modelo | De dónde sale |
|---|---|---|
| **FreighterFiend** | `SPIDERRIG\FREIGHTERFIEND.SCENE.MBIN` | el Horror grande del carguero |
| **MiniFiend** | `SPIDERRIG\MINIFIEND_PET.SCENE.MBIN` | los pequeños, salen de los nidos |

> 🔴 **Esta tabla está mal, y se supo el 2026-08-12.** Es la inferencia que costó cuatro
> pruebas de `FiendMarkers`. La verdad está en
> `METADATA\SIMULATION\ECOSYSTEM\CREATUREFILENAMETABLE.MBIN`, que mapea `CreatureID` → modelo:
>
> | `CreatureID` | Modelo | Quién es de verdad |
> |---|---|---|
> | `FIEND` | `SPIDERRIG/FIEND.SCENE.MBIN` | el Horror de superficie |
> | `MINIFIEND` | `SPIDERRIG/FIEND.SCENE.MBIN` | **mismo modelo que `FIEND`**: no se pueden separar por material |
> | `BUGFIEND` | `ARTHROPOD/BUGFIEND.SCENE.MBIN` | la cría del rugido |
> | **`SCUTTLER`** | **`SPIDERRIG/FREIGHTERFIEND.SCENE.MBIN`** | **el del nido del carguero** |
> | **`SCUTTLER_PET`** | **`SPIDERRIG/MINIFIEND_PET.SCENE.MBIN`** | **la mascota domesticada.** Nunca sale en un carguero |
>
> **No existe un `CreatureID` `FREIGHTERFIEND`,** y `SCUTTLER` tiene `MinScale = MaxScale = 1.0`:
> **no hay un «Horror grande» aparte del carguero.** Lo que salía de los nidos siempre fue
> `SCUTTLER`, con el modelo que llamábamos «del grande».
>
> Detalle y arreglo en [`../work/scripts/marcadores/README.md`](../work/scripts/marcadores/README.md).

Y el nido (`LARGEPILLARSLIME.ENTITY.MBIN`) trae **ocho componentes**, dos de ellos nuevos
para este proyecto:

```
GcAlienPodComponentData      <- NUNCA lo habíamos visto
    AgroRate -5.0            AgroMovement 11.0        AgroMovementRange 8.5
    AgroTorch 0.0            AgroTorchRange 10.0      AgroTorchFOV 25.0
    AgroThreshold 15.0       AgroThresholdOffscreen 17.0
    AgroSpookValue 8.0       AgroSpookTime 10.0 (min 10 / max 30)
    InstaAgroDistance 0.0    GunfireAgro 0.0          GunfireAgroRange 20.0

GcDestructableComponentData
    Explosion INFESTPILLAREXP    Health 600    GivesReward DE_FATSLIME
    DestroyedModel -> LARGEPILLARSLIME_DESTROYED.SCENE.MBIN   <- de aquí salen los MiniFiends
```

**`GcAlienPodComponentData` es la mecánica de «el nido te huele».** Reacciona a tu
movimiento (`AgroMovement` en un radio de 8.5 m), a la linterna (`AgroTorch`, hoy a 0, con
cono de 25° y 10 m) y a los disparos (`GunfireAgro`, hoy a 0, radio 20 m). `AgroRate = -5`
lo enfría solo. **`AgroTorch` y `GunfireAgro` están a cero: los dos son interruptores
apagados por Hello Games**, exactamente igual que `AllowSpawnBrood`.

### 5.4 Por qué el huevo funciona en cualquier sitio

`FIENDEGG.ENTITY.MBIN` **no contiene ningún spawner**. Lo que tiene es:

```
Explosion            = FIENDHATCH
IncreaseFiendWanted  = true      IncreaseFiendWantedChance = 1.0
IncreaseFiendCrime   = EggDestroyed
Health               = 125
```

Es decir: **romper un huevo no invoca bichos, sube el «se busca» de Fiends**, y quien
decide cuántos salen y cuándo es el sistema global de `GCCREATUREGLOBALS` — los mismos
`FiendAggroIncreaseDestroyEgg`, `MaxFiendsToSpawn`, `FiendMaxEngaged` y compañía que la
0.3.1 ya sube en Hardcore.

**Consecuencia:** el sistema de spawn es **global, no local**. Un huevo dentro de un
edificio abandonado dispara la misma maquinaria que uno en campo abierto, y hereda gratis
todos los ajustes de 0.3.1. Ésta es la razón de fondo por la que la vía 5 es la barata.

### 5.5 ✅ Conflicto resuelto el 2026-08-12

**`NoDerelictMiniHorrors` (de Lenni) ya no está activo.** Tocaba justo estos archivos: le
quitaba `GcAlienPodComponentData`, `GcScannableComponentData` y el `DestroyedModel` a
`LARGEPILLARSLIME` y `MEDIUMHANGSLIME`, y mientras estuvo puesto **los cargueros abandonados
no eran vanilla**.

Comprobado el 2026-08-12: Vortex lo purgó y en `GAMEDATA\MODS\NoDerelictMiniHorrors\` **no
queda ni un `.MBIN`** — solo el árbol de carpetas vacío con sus marcas
`__folder_managed_by_vortex`. El paso 2 de la cola (§7) queda cerrado.

**Quien escribe esos dos `.ENTITY` ahora es nuestro `HorribleTerror_Infestation_4-Hardcore`,
y es el único.** Se verificó archivo por archivo en todo `GAMEDATA\MODS`: ningún mod de
terceros toca criaturas, nidos ni la tabla de cargueros.

### 5.6 Palanca extra: cuántos cargueros salen infestados

`METADATA\REALITY\TABLES\FREIGHTERDUNGEONSTABLE.MBIN` define **10 tipos de interior**:
`CARGO_` y `MEDI_` × `TURRETS` / `MAZE` / `BUGS` / `FLOATERS` / `SLIME`.

Los `_BUGS` son los infestados y se distinguen por sus salas: `R_BUG_BARR`, `R_BUG_CARG`,
`R_S_BUG_*`, y ramas `B_BUG_BARR` / `B_BUG_CARG`. Reescribir los `MainRoomTypes` de los
tipos no-bug con salas `BUG` = **todos los cargueros abandonados infestados**. Es más
edición que la vía 5, pero es el equivalente a lo que `DANGEROUS → Weight 1000` hizo con
los planetas.

### 5.7 ⭐ 2026-08-13 — el tentáculo del techo **no tiene malla**, y eso lo cambia todo

Se descompiló `INTERIOR_TENTACLEPLANT.SCENE.MBIN`, que es lo que el locator `TENTACLE_`
cuelga al 30 % en los tres edificios. **No hay ni un nodo `MESH` dentro.** Es un envoltorio:

```
INTERIOR_TENTACLEPLANT.SCENE          MODEL
└ ObjectSpawner                       LOCATOR   ATTACHMENT -> …\ENTITIES\OBJECTSPAWNER.ENTITY.MBIN
  └ TentacleRef                       REFERENCE SCENEGRAPH -> …\ABANDONED\TENTACLEPLANT.SCENE.MBIN
                                                EMBEDGEOMETRY = TRUE
                                                RotZ = 180        <- por eso cuelga boca abajo
```

Tres consecuencias, y las tres importan:

1. **Hay una puerta que no pasa por el `.LSYSTEM`.** Cambiando **un solo valor** —el
   `SCENEGRAPH` de `TentacleRef`— se cuelga otra cosa del techo. El `.LSYSTEM` se queda
   vanilla, la regla del 30 % se queda vanilla, y no se toca el conducto que falló en 0.3.2.
2. **Explica por qué el huevo desapareció.** El giro de 180° en Z vive en el envoltorio, no
   en la escena apuntada. Al sustituir el `Model` desde el `.LSYSTEM` se tira el envoltorio
   entero **y con él la compensación de giro**: el huevo se colocaba en el locator del techo
   sin darse la vuelta, o sea metido en el techo. `[Inferencia, encaja con lo visto]`
3. **Esculpir un tentáculo propio sigue sin poder ser.** `TENTACLEPLANT.SCENE` tiene
   **13 `JOINT`** — mismo muro que el Fiend (§4.2). Lo que se puede es **elegir a qué escena
   ya existente apunta**.

#### La plaga parasitaria del carguero, colgada del techo

El candidato evidente es `MEDIUMHANGSLIME.SCENE.MBIN`: es el nido colgante del carguero, con
la misma forma de «algo que cuelga». Y no viene solo — su `.ENTITY` trae, leído del archivo:

```
GcDestructableComponentData   Explosion INFESTPILLAREXP · GivesReward DE_FATSLIME
                              DestroyedModel -> MEDIUMHANGSLIME_DESTROYED
GcShootableComponentData      Health 600
GcAlienPodComponentData       AgroMovement 11 / rango 8.5 · AgroTorch · GunfireAgro …
GcScannableComponentData      sale en el escáner
```

Más un nodo `LIGHT`, 6 mallas y su colisión. O sea: **un nido de verdad, destruible, que
huele al jugador y que da recompensa** — no un adorno.

Y el remate: esa `.ENTITY` **ya la retoca nuestro `HorribleTerror_Infestation`**
(`…\MEDIUMHANGSLIME\ENTITIES\MEDIUMHANGSLIME.ENTITY.MBIN`, junto con `LARGEPILLARSLIME`).
El nido del techo hereda gratis el `AgroTorch` y el `GunfireAgro` que la 0.3.2 encendió.

**Y llega gratis a todas las estructuras que usen ese prop.** Como lo que se edita es la
escena del prop y no las reglas, el cambio alcanza a **cualquier `.LSYSTEM` que cuelgue
`INTERIOR_TENTACLEPLANT`**: los tres edificios abandonados de superficie **y sus tres
variantes `UNDERWATER_`** (§5.1). No hay que escribir una regla por edificio, ni repetir el
truco si mañana aparece otra estructura que use el mismo prop. Es la diferencia entre editar
seis archivos de reglas y editar uno de escena.

Escrito y sin construir: **`HT_CeilingPlague_PRUEBA01`**
([`../work/scripts/pruebas/HT_CeilingPlague_PRUEBA01.lua`](../work/scripts/pruebas/HT_CeilingPlague_PRUEBA01.lua)).
Escribe **un solo archivo**, así que no choca con nada nuestro.

> ⚠️ **Hay que quitar `HT_LocatorTest_PRUEBA01` antes de probarlo.** Ese secuestra el mismo
> locator desde el `.LSYSTEM` y pone `DEBRISLARGE_COMMON` al 100 %: mientras esté puesto, el
> cambio de `SCENEGRAPH` no se ve. No es un conflicto de archivos —tocan archivos distintos—
> es que uno tapa al otro.

---

## 6. Criaturas fijas junto a objetos de bioma

Sin novedades: sigue siendo el «camino B» de [`IDEAS.md`](IDEAS.md) §1 —
`GcEnvironmentSpawnData.Creatures`, con un único precedente vanilla (los pájaros de
`rocky/rockobjectsfull`). `FIEND.SCENE.MBIN` existe y es referenciable, así que la
construcción es posible. Sigue `[Sin probar]` y sigue siendo **más caro que la vía 5** para
el mismo resultado aparente.

---

## 7. Estado de la cola — cerrada el 2026-08-07

| # | Paso | Estado |
|---|---|---|
| 1 | `FIENDEGG.SCENE` en el locator `TENTACLE_` de los 3 `.LSYSTEM` | ✅ construido y desplegado (0.3.2) |
| 2 | Quitar `NoDerelictMiniHorrors` para ver un carguero vanilla | ⬜ **lo tiene que hacer el usuario en Vortex** |
| 3 | `AgroTorch` / `GunfireAgro` del nido | ✅ 12 y 8, desplegado (0.3.2) |
| 4 | Formato de `FIEND.BASE.DDS` y conversor | ✅ BC7 2048² 12 mips · `tools/Make-NMSTexture.py` |
| 5 | ¿Se tiñe el Fiend? | ✅ no por paleta, **sí por `gMaterialColourVec4`** |
| 6 | Salas `BUG` en `FREIGHTERDUNGEONSTABLE` | ✅ `HorribleTerror_DerelictBugs` 0.1.0, 57 cambios |
| 7 | ¿Sirve podar el descriptor de un depredador? | ✅ mecánicamente sí · `HT_PredatorParts_PRUEBA01` |

Todo eso está **sin jugar**. Plan de prueba: [`CHECKLIST-0.3.2.md`](_archivo/CHECKLIST-0.3.2.md).

### Lo siguiente, según qué salga

| Si la prueba… | Entonces |
|---|---|
| 1.1 sale bien (huevos dentro) | Repetir el truco en **estaciones abandonadas** y en las variantes `UNDERWATER_` |
| 1.4 sale injugable | Bajar `EGG_PROB` de 100 a 30-50; es un número |
| 4.1 sale bien (textura) | Pintar una textura **propia** sobre el atlas vanilla, publicable |
| 4.2 sale bien (tinte) | Tinte por tier: rojo en Hardcore, gris en Fácil |
| 5.1-5.2 salen bien (poda) | Recorrer el árbol de `TREXRIG` entero y quedarse con las piezas feas |
| 3.2 falla (misión del carguero) | Desinstalar `DerelictBugs` y convertir solo `MainRoomTypes`, sin tocar `ValidRoomIDs` |

**Regla que sigue en pie:** dos scripts nuestros nunca escriben el mismo archivo. Los
cuatro mods desplegados tocan rutas disjuntas — comprobado archivo por archivo.
