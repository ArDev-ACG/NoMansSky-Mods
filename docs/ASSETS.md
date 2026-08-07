# Assets — cómo cambiar el aspecto y dónde se pueden fijar monstruos

Investigación para la **0.3.2**. Hasta ahora el mod solo ha tocado **números**. Esto mapea
lo otro: texturas, colores, partes, entidades nuevas y **meter los bichos del carguero
abandonado dentro de los edificios abandonados del planeta**.

- Verificado contra la instalación local: NMS **170671**, MBINCompiler **6.45.0.1**,
  índice `NMS_FULL_pak_list.txt` (184.919 rutas) y `NMSARC.Precache.pak` descompilado.
- Marcas: sin marca = **leído en el archivo**. `[Inferencia]` = deducido.
  `[Sin probar]` = no se ha llevado al juego.

---

## 0. Resumen — las seis vías, ordenadas por efecto/coste

| # | Vía | Sirve para | Coste | Veredicto |
|---|---|---|---|---|
| **5** | **`.LSYSTEM` de los edificios abandonados** | Meter huevos/nidos **dentro** de los edificios del planeta | bajo | ⭐ **empezar por aquí** |
| 2 | Paletas de color | Teñir la fauna procedural | bajo | ✅ ya probado in-game (mod 1) |
| 1 | Sustituir el `.DDS` | «Pegarle un JPG» al Fiend | bajo-medio | ✅ viable, falta un conversor |
| 6 | `GcEnvironmentSpawnData.Creatures` | Criatura fija junto a objetos de bioma | alto | 🕒 sigue sin probar |
| 3 | `.DESCRIPTOR` por partes | Sesgar qué cabezas/bocas salen | medio | ⚠️ mecánica sin confirmar |
| 4 | Clonar / crear entidades | Bicho propio del mod | alto | 🚧 último de la lista |

Y un hallazgo suelto que no encaja en ninguna: **`GcAlienPodComponentData`** (§5.3), la
palanca de «el nido reacta a tu movimiento y a tu linterna». Nunca la habíamos visto.

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
Fiend y el FreighterFiend **no**: su color sale directo del `.DDS`. La vía de las paletas
no los alcanza, y por eso el `RedFauna` del mod 1 nunca los tocó.

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

---

## 4. Clonar y crear entidades nuevas

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

`ADD_FILES` con `EXTERNAL_FILE_SOURCE` necesita **ruta absoluta**. En
`HorribleTerror_NecroSkin.lua` está en la constante `NECRO_DDS` y hay que ajustarla si el
repo se mueve de sitio.

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

### 5.5 ⚠️ Conflicto ya instalado

**`NoDerelictMiniHorrors` (de Lenni) está instalado ahora mismo** y toca justo estos
archivos: le quita `GcAlienPodComponentData`, `GcScannableComponentData` y el
`DestroyedModel` a `LARGEPILLARSLIME` y `MEDIUMHANGSLIME`.

- Cualquier trabajo nuestro sobre los nidos **choca de frente** con él.
- Y mientras siga puesto, **los cargueros abandonados que veas no son vanilla**: no salen
  MiniFiends. Hay que quitarlo antes de medir nada ahí dentro.

### 5.6 Palanca extra: cuántos cargueros salen infestados

`METADATA\REALITY\TABLES\FREIGHTERDUNGEONSTABLE.MBIN` define **10 tipos de interior**:
`CARGO_` y `MEDI_` × `TURRETS` / `MAZE` / `BUGS` / `FLOATERS` / `SLIME`.

Los `_BUGS` son los infestados y se distinguen por sus salas: `R_BUG_BARR`, `R_BUG_CARG`,
`R_S_BUG_*`, y ramas `B_BUG_BARR` / `B_BUG_CARG`. Reescribir los `MainRoomTypes` de los
tipos no-bug con salas `BUG` = **todos los cargueros abandonados infestados**. Es más
edición que la vía 5, pero es el equivalente a lo que `DANGEROUS → Weight 1000` hizo con
los planetas.

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

Todo eso está **sin jugar**. Plan de prueba: [`CHECKLIST-0.3.2.md`](CHECKLIST-0.3.2.md).

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
