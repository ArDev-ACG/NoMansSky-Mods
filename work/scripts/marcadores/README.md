# `HT_FiendMarkers` — un color por tipo de Horror

Mod de prueba. Se versiona aparte: reutiliza la vía de tinte que estrenó
`HorribleTerror_NecroSkin`, pero no es una actualización suya.

| Script | Materiales | Estado |
|---|---:|---|
| `HT_FiendMarkers_PRUEBA01.lua` | 13 | ✅ Probado el 2026-08-11 — la cría sale verde ácido. **Retirado el 2026-08-12** a `build\_retirado_2026-08-12_fiendmarkers-prueba01\` |
| `HT_FiendMarkers_PRUEBA02.lua` | 15 | ✅ Construido el 2026-08-11 (45 cambios) y desplegado el 2026-08-12. ❌ **Probado en partida el 2026-08-12: el MiniFiend NO salió azul.** **Retirado** a `build\_retirado_2026-08-12_fiendmarkers-prueba02\` |
| `HT_FiendMarkers_PRUEBA03.lua` | 15 | ✅ Construido y desplegado el 2026-08-12 (45 cambios). ✅ **Probado el 2026-08-12: el negro SÍ aplicó.** **Retirado** a `build\_retirado_2026-08-12_fiendmarkers-prueba03\` |
| `HT_FiendMarkers_PRUEBA04.lua` | **15 + 2 escenas** | ✅ Construido y desplegado el 2026-08-12 (51 cambios, 0 errores). ❌ **Probado el 2026-08-12: el MiniFiend sigue sin verse azul** — y el 12/08 se supo por qué: **ese bicho no sale** |
| `HT_FiendMarkers_PRUEBA05.lua` | **12 + 1 escena** | ⬜ **Escrito el 2026-08-12, sin construir.** Quita `MINIFIEND_PET` (es la mascota, no el del nido) y añade `_F07_UNLIT` al ojo del `SCUTTLER`. Esperado: **39 cambios + 1 `ADD`** |

**Los tres escriben los mismos materiales: no puede haber dos desplegados a la vez.**
Cada uno contiene al anterior, así que al desplegar el nuevo el viejo sale.

## Para qué sirve

Ahora mismo no hay forma de saber, mirando la pantalla, **qué bicho es cuál**. Eso hace
inverificable media lista de pendientes: cuando 0.3.3 dice «las crías pegan más», hay que
poder señalar a una cría. Y con huevos ×20 más el brood, todo lo que corre hacia ti parece
lo mismo.

Este mod pinta cada uno de un color, sin tocar ninguna textura: multiplica
`gMaterialColourVec4` en sus materiales.

| Criatura | Quién es | Color | Materiales |
|---|---|---|---:|
| `FIEND` | El Horror Biológico, el que sale del huevo | **blanco** — no se toca | 0 |
| `BUGFIEND` | **La cría del rugido.** Lo que 0.3.3 acaba de igualar | **verde ácido** (0.12, 1.0, 0.15) | 9 |
| `MINIFIEND` | Los pequeños de los nidos de carguero | **azul** (0.15, 0.35, 1.0) | 3 |
| `FREIGHTERFIEND` | El Horror grande del carguero | **rojo carne** (1.0, 0.15, 0.12) | 1 → **3 en PRUEBA02** |

**PRUEBA01: 13 materiales × 3 floats = 39 cambios. PRUEBA02: 15 × 3 = 45.** Si el REPORT no
da el número, no se despliega.

### Por qué el `FIEND` se queda sin teñir

`gMaterialColourVec4` es un **multiplicador**: solo puede oscurecer. No hay tinte que
produzca blanco.

> ⚠️ **Corregido el 2026-08-11.** Esta sección decía que el `FIEND` «ya sale blanco por su
> cuenta» por la textura rota de `NecroSkin`, y que ese blanco era su marca. **Se cayó:** la
> textura de `NecroSkin` **funciona** y el `FIEND` sale con las calaveras, no blanco.
>
> No cambia lo que hace este mod. El `FIEND` sigue siendo el único de los cuatro sin teñir, y
> la textura lo distingue igual de bien. Pero **si se desinstala `NecroSkin`, el `FIEND` se
> queda sin ninguna marca**.

## Hallazgo que hizo falta para escribirlo

**`BUGFIEND` no es del `SPIDERRIG`.** Es del rig **`ARTHROPOD`**, con nueve materiales
propios y —esto es lo interesante— **su propio `BUGFIEND.DESCRIPTOR.MBIN`**: la cría es una
criatura **procedural por partes**, como el TREX, no un modelo fijo como el `FIEND`.

Se explica solo mirando los paths: el padre es una araña y la cría es un bicho. Se ven
distintos de entrada; el verde solo lo confirma sin lugar a dudas.

## ⚠️ Solape con `NecroSkin`

Los dos escriben `SPIDERRIG\FREIGHTERFIEND\FFIENDMAT.MATERIAL.MBIN`, y son **MBIN
completos**: el que cargue después gana, en silencio.

**No importa en la práctica: los dos escriben el mismo rojo** (1.0, 0.15, 0.12), así que el
resultado es idéntico gane quien gane. Si algún día se cambia el rojo, hay que cambiarlo en
los dos o quitar el bloque de uno.

## PRUEBA 02 — el Horror de carguero iba pintado a un tercio

**Lo que se pidió el 11/08:** que se pinten «los que están en los cargueros abandonados».
Los pequeños ya estaban —`MINIFIEND_PET`, azul, sus tres materiales desde el 09/08—, así que
se fue a mirar el grande. Y ahí había un hueco de verdad:

| `MODELS\PLANETS\CREATURES\SPIDERRIG\FREIGHTERFIEND\` | Vanilla | PRUEBA01 | PRUEBA02 |
|---|---|---|---|
| `FFIENDMAT.MATERIAL.MBIN` — el cuerpo | (1, 1, 1, 1) | ✅ rojo | ✅ rojo |
| `FFIENDEYEMAT.MATERIAL.MBIN` — el ojo | (1, 1, 1, 1) | ❌ **sin tocar** | ✅ rojo |
| `LAMBERT1.MATERIAL.MBIN` — el resto | **(0.5, 0.5, 0.5, 1)** | ❌ **sin tocar** | ✅ rojo |

El `MINIFIEND_PET` tiene exactamente los mismos tres nombres de material y el mod le teñía
los tres. Al `FREIGHTERFIEND` le teñía **uno**. No era una decisión: era que la lista se
escribió con la ruta que aparecía en `ASSETS.md` §2, que solo cita `FFIENDMAT`.

**Cómo se supo, y sirve para la próxima vez.** No hacía falta abrir el explorador de PAKs:

```
tools\AMUMSS\MODBUILDER\hgpaktool.exe -L "<NMS>\GAMEDATA\PCBANKS"
```

deja un `filenames.json` de 15 MB con **todos** los archivos del juego, 97 PAKs en 3,5 s.
Y para sacar un archivo concreto y descompilarlo:

```
hgpaktool.exe -U -f "*creatures/spiderrig/freighterfiend/*material*" -O ext "<NMS>\GAMEDATA\PCBANKS"
MBINCompiler.exe ffiendeyemat.material.mbin
```

Con eso se comprobó **antes de escribir el script** que los tres materiales llevan
`gMaterialColourVec4`. Si a alguno le faltara, el `SPECIAL_KEY_WORDS` no encontraría nada y
el conteo saldría corto sin error.

### El ojo va en su propio bloque a propósito

`FFIENDEYEMAT` no lleva flag de emisión —sus flags son `_F01_DIFFUSEMAP`, `_F02_SKINNED`,
`_F13_UV_EFFECT`, `_F25_MASKS_MAP`—, así que el tinte le entra como al cuerpo y no debería
apagar ningún brillo. Aun así está separado en `FREIGHTERFIEND_EYE_MATS`: **si el ojo sale
mal, se quita esa lista y se reconstruye**, sin tocar el resto.

Y ojo con `LAMBERT1`: en vanilla vale **0.5**, no 1. Teñirlo lo aclara además de teñirlo.

## PRUEBA 04 — marcar por la luz, no por la piel

**El brillo no es el ojo: es un nodo `LIGHT` dentro del `.SCENE.MBIN`.** Los dos bichos del
carguero llevan uno, y en vanilla es **idéntico**:

```
LIGHT  AttackLight    COL_R 0.861  COL_G 1.000  COL_B 0.000   <- amarillo
                      INTENSITY 1.0   RADIUS 4.472   FOV 360
LIGHT  Light_pointLight1   1,1,1   INTENSITY 0.000001   <- no toca, es residual
```

Ésa es la causa de fondo de que no se distinguieran: **en penumbra del bicho solo se ve su
propia luz**, y la luz era la misma en los dos. Teñir `gMaterialColourVec4` pintaba justo la
parte que no se ve.

Una luz **no depende de la iluminación de la sala**: se ve igual a oscuras. Por eso es el
marcador correcto y no hace falta pelear con el ámbar del carguero.

| Bicho | `AttackLight` | Piel (se mantiene) |
|---|---|---|
| `MINIFIEND_PET` | **azul** (0.15, 0.35, 1.0) | azul |
| `FREIGHTERFIEND` | **rojo carne** (1.0, 0.15, 0.12) | rojo carne |
| `BUGFIEND` | — sin `AttackLight` | verde ácido |

### La trampa: acotar al nodo correcto

Las dos luces de cada escena usan los mismos nombres de atributo `COL_R/COL_G/COL_B`. Un
`REPLACE_TYPE = "ALL"` se llevaría por delante `Light_pointLight1`. Se acota con
**`SPECIAL_KEY_WORDS` encadenado**, que aquí sí se quiere como camino AND:

```lua
["SPECIAL_KEY_WORDS"] = {"Name", "AttackLight", "Name", "COL_R"},
["REPLACE_TYPE"]      = "ONCE",
["VALUE_CHANGE_TABLE"] = { {"Value", "0.150000"} },
```

Un canal por sub-tabla, tres por escena. **Verificar siempre que `Light_pointLight1` sigue en
(1, 1, 1) con `INTENSITY 0.000001`**: si cambió, el acotado falló.

### `_F07_UNLIT`, la segunda vía si ésta no basta

`FIEND\GLOWEYE_MAT.MATERIAL.MBIN` lleva flags `_F02_SKINNED` + **`_F07_UNLIT`**, y su
`gMaterialColourVec4` vale **(0.581, 0.813, 0.558)** — un color de verdad, no el neutro
`(1,1,1)`. En un material UNLIT el uniform **pinta** en vez de multiplicar, así que también
sobrevive a cualquier iluminación. El `FFIENDEYEMAT` de los bichos del carguero **no** lo
lleva (`_F01_DIFFUSEMAP`, `_F02_SKINNED`, `_F13_UV_EFFECT`, `_F25_MASKS_MAP`).

### Por qué «pegarle un JPG» no sirve para separar estos dos

`MINIFIEND_PET\FFIENDMAT` y `FREIGHTERFIEND\FFIENDMAT` apuntan a **las mismas tres DDS**
(`FREIGHTERFIEND.BASE{,.MASKS,.NORMAL}`). Una textura propia los marca **a los dos igual**, y
en penumbra tampoco se leería. La vía del `.DDS` vale para el `FIEND` de superficie, a plena
luz — que es donde `NecroSkin` sí funciona.

## Construir

```
tools\Build-Tiers.ps1 -Carpeta marcadores
```

Construye los cuatro `.lua`, uno por pasada. **Esperado: 39 cambios en PRUEBA01, 45 en
PRUEBA02, 45 en PRUEBA03 y 51 en PRUEBA04** (45 de materiales + 6 de las dos escenas), 0
errores. El único `[NOTICE]` es de estilo Lua —«una sentencia por línea»—, no el aviso de
`duplicates` de AMUMSS.

Desplegar copiando los `.MBIN` de `tools\AMUMSS\ModBackups\HT_FiendMarkers_PRUEBA04\` a
`GAMEDATA\MODS\HT_FiendMarkers_PRUEBA04\`, y **sacando de ahí el anterior**: comparten los 15
materiales y el que cargue después gana en silencio. **NMS solo carga mods al arrancar, y se
abre por Steam** — estos mods no los gestiona Vortex.

Verificar descompilando desde `GAMEDATA\MODS`, no desde el build. Comprobado así el
**2026-08-12** para la PRUEBA04 (17 archivos: 15 materiales + 2 escenas):

| Qué | Esperado | Leído |
|---|---|---|
| `FREIGHTERFIEND\` los tres materiales | 1.0, 0.15, 0.12 | ✔ |
| `MINIFIEND_PET\` los tres materiales | 0.15, 0.35, 1.0 | ✔ |
| `BUGFIEND\ARTHROPODSHELL01MAT1` | 0.12, 1.0, 0.15 | ✔ |
| `FREIGHTERFIEND.SCENE` → `AttackLight` | 1.0, 0.15, 0.12 | ✔ |
| `MINIFIEND_PET.SCENE` → `AttackLight` | 0.15, 0.35, 1.0 | ✔ |
| **`Light_pointLight1` en las dos escenas** | **1, 1, 1 · INT 0.000001 — intacto** | ✔ |

La última fila es la que prueba que el acotado funcionó.

## Estado

**PRUEBA01 construido y desplegado el 2026-08-09.** 39 cambios, 0 errores. Verificado
descompilando desde `GAMEDATA\MODS`: el caparazón de `BUGFIEND` en (0.12, 1.0, 0.15) y el
`MINIFIEND` en (0.15, 0.35, 1.0). **Retirado el 2026-08-12** al desplegar PRUEBA02.

**PRUEBA02 construido el 2026-08-11** (45 cambios = 15 materiales × 3 floats, 0 errores; el
único `[NOTICE]` es de estilo Lua —«una sentencia por línea»—, no el aviso de `duplicates`
de AMUMSS) **y desplegado el 2026-08-12.** Verificado descompilando los seis materiales
desde `GAMEDATA\MODS`:

| Material | `FREIGHTERFIEND` | `MINIFIEND_PET` |
|---|---|---|
| `FFIENDMAT` | 1.0, 0.15, 0.12 ✔ | 0.15, 0.35, 1.0 ✔ |
| `FFIENDEYEMAT` | 1.0, 0.15, 0.12 ✔ | 0.15, 0.35, 1.0 ✔ |
| `LAMBERT1` | 1.0, 0.15, 0.12 ✔ | 0.15, 0.35, 1.0 ✔ |

**Los tres del grande, no uno.** Era el hueco que abrió la PRUEBA02.

### El solape con `NecroSkin` está medido, ya no supuesto

El `FFIENDMAT.MATERIAL.MBIN` que `NecroSkin` tiene desplegado se descompiló el 2026-08-12:
**(1.0, 0.15, 0.12)**, idéntico. Gane quien gane el orden de carga, el resultado es el
mismo. Sigue en pie la condición: si algún día se cambia el rojo, hay que cambiarlo en los
dos.

## ✅ Probado el 2026-08-11 — pasa, y cierra otra pregunta de paso

**Las crías del rugido salen verde ácido.** El mod hace lo que dice, y de rebote responde dos
cosas que llevaban meses en el aire:

| Pregunta | Respuesta |
|---|---|
| ¿`gMaterialColourVec4` tiñe criaturas **in-game**, o solo en el MBIN? | **In-game.** Estaba dado por bueno desde el 09/08 sin haberlo jugado nunca. Ahora está visto |
| ¿El brood engendra `BUGFIEND` o simplemente más `FIEND`? | **`BUGFIEND`.** Y eso valida 0.3.3 entera: los cuatro campos de la cría miden lo que dicen medir |

Ése era el punto del mod. Sin el verde, «las crías pegan como el padre» era una impresión.

Sin medir todavía:

1. El rojo del `FREIGHTERFIEND`, ahora **entero**. Es la prueba **N4** de
   [`../../../docs/PENDIENTES.md`](../../../docs/PENDIENTES.md), y hasta PRUEBA02 iba a
   medirse con un tercio del bicho pintado. Sigue pendiente: **el Horror grande no llegó a
   aparecer** en la partida del 12/08.
2. Si el ojo del `FREIGHTERFIEND` sale raro, quitar `FREIGHTERFIEND_EYE_MATS` y reconstruir:
   43 cambios en vez de 45.

## ❌ Probado el 2026-08-12 — el MiniFiend no salió azul

Carguero abandonado, nidos despiertos, MiniFiends a la vista: **salieron con el color
vanilla**, marrón-naranja con el ojo amarillo. Capturas en
[`../../../asset/Errores/`](../../../asset/Errores/). El Horror grande no apareció, así que su
rojo sigue sin medirse.

**No es un fallo de despliegue.** Se descartó uno por uno el mismo día:

| Sospechoso | Cómo se descartó |
|---|---|
| MBIN mal construidos | Descompilados los 6 desde `GAMEDATA\MODS`: FF en (1.0, 0.15, 0.12), Mini en (0.15, 0.35, 1.0) |
| Materiales equivocados | `MINIFIEND_PET.SCENE` y `FREIGHTERFIEND.SCENE` referencian justo esos `FFIENDMAT`/`FFIENDEYEMAT` |
| Otro mod pisando | Barrido de todo `GAMEDATA\MODS`: nadie más toca criaturas. El solape con `NecroSkin` escribe el mismo rojo |
| `NoDerelictMiniHorrors` | Vortex ya lo purgó: cero `.MBIN`, solo carpetas vacías |
| Juego sin reiniciar | Deploy 09:03, capturas 12:46, save 14:13. Cargó |
| El mecanismo no sirve | El BUGFIEND verde del 11/08 lo desmiente |

Ojo con `LAMBERT1`: las escenas **no lo usan**. Los dos bichos montan solo `FFIENDMAT` y
`FFIENDEYEMAT`; el tercer archivo se tiñe pero no pinta nada. Los materiales que deciden son
**dos por bicho**, no tres.

## PRUEBA 03 — la discriminante: negro absoluto

Quedaron dos causas vivas y el archivo no puede separarlas:

| | Hipótesis | Qué predice |
|---|---|---|
| **H1** | **La luz del carguero se come el tinte.** `gMaterialColourVec4` multiplica el albedo y el resultado se multiplica otra vez por la luz. Las capturas están bañadas en verde-ámbar: **esa sala no tiene componente azul**. Un tinte azul sin luz azul que reflejar no puede verse azul | El material sí aplica; el azul era invisible por física, no por error |
| **H2** | **Lo que sale del nido no es `MINIFIEND_PET`.** El sufijo `_PET` es el modelo de la *mascota*. Que los del nido sean ése es una inferencia de `ASSETS.md` §5.3 que **nunca se verificó** | El material no aplica a ese bicho; se está pintando algo que no sale |

**Negro es negro bajo cualquier iluminación.** Por eso la PRUEBA03 cambia una sola variable:
`MINI_R/G/B` de (0.15, 0.35, 1.0) a **(0, 0, 0)**. Todo lo demás es idéntico a la PRUEBA02.

| Lo que se vea | Lectura |
|---|---|
| MiniFiend **negro silueta** | **H1.** El material es el bueno y era la luz. Para marcarlo hay que elegir un color que sobreviva a luz ámbar, o marcarlo por otra vía |
| MiniFiend **igual que ahora** (marrón-naranja) | **H2.** Ese material no lo lleva ese bicho. Hay que averiguar qué `.SCENE` monta de verdad antes de seguir pintando |

Cualquiera de los dos resultados cierra la pregunta. No hay resultado ambiguo.

### ✅ Salió H1 — probado el 2026-08-12

La captura `asset\Errores\20260812163516_1.jpg` (16:35) es de **la PRUEBA03, no de la 02**: el
único FiendMarkers desplegado desde las 15:08 era el negro, y los saves de esa sesión son de
las 16:22-16:28. Se pidió como prueba de la 02 por error.

**El bicho salió en silueta sobre un suelo verde iluminado.** Vanilla habría tomado esa luz y
se vería ámbar claro, como en la captura de las 12:46. **El material es suyo y el tinte
aplica.** El azul nunca se vio porque en esa sala no hay componente azul que reflejar.

Y de paso queda visto lo que importaba: **lo único que sobrevive es el brillo amarillo.**

> ⚠️ Antes decía aquí: «si algo sale **negro** en vez de teñido, el multiplicador está pisando
> un canal que no toca». **Eso no aplica a la PRUEBA03**, donde el negro es el resultado
> buscado y no un síntoma.

## ❌ Probado el 2026-08-12 — la PRUEBA04 tampoco marca al MiniFiend

Capturas `asset\Errores\20260812165826_1.jpg`, `…165859_1.jpg`, `…165900_1.jpg`.

**La partida sí llevaba la PRUEBA04**, y esta vez está fechado, no supuesto:

| Hito | Hora |
|---|---|
| `GAMEDATA\MODS\HT_FiendMarkers_PRUEBA04\` escrito | **16:50:25** |
| `%APPDATA%\HelloGames\NMS\…\cache\INTRO_FEED_CACHE.JSON` reescrito — **el juego arrancó** | **16:55:30** |
| Capturas | **16:58 – 16:59** |

`INTRO_FEED_CACHE.JSON` se reescribe al arrancar: sirve de sello de reinicio y ahorra la
pregunta «¿lo cerraste?». **Anotado para las próximas pruebas.**

Y el despliegue está bien. Descompilado `MINIFIEND_PET.SCENE.MBIN` desde `GAMEDATA\MODS`:

```
AttackLight         COL_R 0.150000   COL_G 0.350000   COL_B 1.000000   <- azul, correcto
Light_pointLight1   COL 1,1,1        INTENSITY 0.000001               <- intacto, acotado OK
```

**Lo que se vio:** cuerpo oscuro, **boca amarilla exactamente igual que en vanilla**, y el
resplandor del lomo del color de la sala — verde a las 16:35, rojo a las 16:58, que es cuando
el carguero está en alarma. Ni rastro de azul, ni en la piel ni al atacar.

### Por qué: el emisivo no pasa por `gMaterialColourVec4`

La escena del MiniFiend monta **dos materiales y nada más** —lo demás son los dos nodos
`LIGHT`, que usan `MATERIALS/LIGHT.MATERIAL.MBIN`, no los suyos:

```
FFIENDMAT.MATERIAL.MBIN      <- cuerpo
FFIENDEYEMAT.MATERIAL.MBIN   <- la boca/lomo que brilla
```

La boca **siguió amarilla con el tinte en (0,0,0)** de la PRUEBA03. Un multiplicador a cero
deja negro todo lo que multiplica: si el amarillo sobrevive, **ese brillo no lo multiplica el
uniform**. Sale del emisivo del material, que va por textura.

De ahí la frase del usuario, que resume el problema entero: **«solo brillaba»**. Lo único
legible del bicho en penumbra es justo la parte que el tinte no alcanza — y el resto, que sí
teñimos, no se ve.

Y el `AttackLight` azul tampoco rescata la marca: (0.15, 0.35, 1.0) con `INTENSITY 1.0` y
`RADIUS 4.472` en una sala en alarma roja es invisible. El amarillo vanilla (0.861, 1.0, 0)
tiene mucha más luminancia; cambiarlo a azul **quita brillo en vez de recolorearlo**.
`[Inferencia]` sobre la luminancia; el hecho medido es que no se vio nada.

### Lo que queda de esta vía: `_F07_UNLIT`

Es la segunda vía que ya estaba anotada arriba, y ahora es la única que sigue viva. En un
material con `_F07_UNLIT` el uniform **pinta** en vez de multiplicar —`FIEND\GLOWEYE_MAT` lo
lleva y su `gMaterialColourVec4` vale (0.581, 0.813, 0.558), un color de verdad—. Añadir ese
flag a `FFIENDEYEMAT` es un cambio de un campo y ataca exactamente la parte que sí se ve.
`[Sin probar]`

**Conclusión de la 01→04:** teñir la piel funciona a plena luz (el `BUGFIEND` verde del 11/08)
y **no sirve dentro de un carguero**. Cuatro pruebas para acotarlo.

## 🔴 2026-08-12, segunda partida — puede que llevemos cuatro pruebas pintando al bicho equivocado

Lo que se vio con la **PRUEBA04** desplegada (`FREIGHTERFIEND` rojo, `MINIFIEND_PET` azul):

> «El Horror grande **no sale**; **el que se pintó como rojo es el que spawnea cuando se rompe
> el nido**. En todos los cargueros solo salen los pequeños. Los pequeños de los nidos,
> azules — **estos salen rojos**.»

**El bicho del nido salió del color del `FREIGHTERFIEND`.** Si eso es cierto, la premisa de
[`../../../docs/ASSETS.md`](../../../docs/ASSETS.md) §5.3 —«`MINIFIEND` = los pequeños de los
nidos»— es **falsa**, y lo ha sido desde el 09/08:

| Lo que decía ASSETS §5.3 | Lo que sugiere la partida |
|---|---|
| `FREIGHTERFIEND` = el Horror grande | `FREIGHTERFIEND` = **el único que sale**, grande o pequeño |
| `MINIFIEND_PET` = los pequeños del nido | `MINIFIEND_PET` = la **mascota** del jugador, como dice su sufijo. **Nunca aparece en un carguero** |

Eso explicaría las cuatro pruebas de golpe: **el azul nunca se vio porque no había a quién
pintárselo.** Y explica por qué el `DestroyedModel` del nido nunca se comprobó: se dio por
supuesto qué spawnea.

### ✅ Confirmado por archivo el 2026-08-12 — no hizo falta jugar

Se iba a escribir una PRUEBA05 «discriminante» con el `FREIGHTERFIEND` en negro. **No hace
falta: la tabla lo dice.** `METADATA\SIMULATION\ECOSYSTEM\CREATUREFILENAMETABLE.MBIN` mapea
cada `CreatureID` a su modelo, y ahí se acaba la discusión:

| `CreatureID` | Modelo |
|---|---|
| `FIEND` | `SPIDERRIG/FIEND.SCENE.MBIN` |
| `BUGFIEND` | `ARTHROPOD/BUGFIEND.SCENE.MBIN` |
| **`SCUTTLER`** | **`SPIDERRIG/FREIGHTERFIEND.SCENE.MBIN`** |
| **`SCUTTLER_PET`** | **`SPIDERRIG/MINIFIEND_PET.SCENE.MBIN`** |
| `MINIFIEND` | `SPIDERRIG/FIEND.SCENE.MBIN` |

**Tres consecuencias, y ninguna es menor:**

1. **`MINIFIEND_PET.SCENE` es de `SCUTTLER_PET`, la mascota domesticada.** Nunca aparece en un
   carguero. **El azul no falló: no había a quién pintárselo.** Cuatro pruebas gastadas en un
   bicho que no sale.
2. **El bicho del nido es `SCUTTLER`, y usa `FREIGHTERFIEND.SCENE`** — el que pintamos de rojo.
   El «sale rojo» del usuario no era la alarma: **era nuestro tinte funcionando.** La H1 de la
   PRUEBA03 y esto no se contradicen: el material aplica, y ahora además sabemos de quién es.
3. **No existe un `CreatureID` `FREIGHTERFIEND`.** El «Horror grande del carguero» que este
   README y `ASSETS.md` §5.3 daban por un bicho aparte **no existe**: `SCUTTLER` tiene
   `MinScale` y `MaxScale` a **1.0**, un solo tamaño. Lo que el usuario llama «los pequeños»
   es el único que hay.

⚠️ **`MINIFIEND` y `FIEND` comparten modelo.** Nunca se podrán separar por material: cualquier
tinte les entra a los dos a la vez.

## PRUEBA 05 — dejar de pintar al ausente y atacar lo que sí se ve

`HT_FiendMarkers_PRUEBA05.lua`. Dos cambios respecto a la 04:

1. **Fuera `MINIFIEND_PET`**, materiales y escena. El mod **deja de escribir esos 4 archivos**,
   así que al retirar la PRUEBA04 vuelven solos a vanilla. Nombres del script renombrados a
   `SCUTTLER_*` para que no se repita el malentendido.
2. **`_F07_UNLIT` añadido a `FREIGHTERFIEND\FFIENDEYEMAT`**, vía `ADD_OPTION = "ADDafterSECTION"`
   anclado en `_F25_MASKS_MAP`. Es la última vía viva de la 01→04: en un material `UNLIT` el
   uniform **pinta** en vez de multiplicar, y el emisivo —la boca/lomo, **lo único legible en
   penumbra**— pasaría de amarillo a rojo carne.

El material es `MaterialClass = Glow`, con `gDiffuseMap` y `gMasksMap` a
`FREIGHTERFIENDEYE.BASE33{,.MASKS}.DDS`. El amarillo sale de ahí, y por eso sobrevivió al
tinte en (0,0,0) de la PRUEBA03.

**Esperado: 39 cambios + 1 `ADD`, 0 errores.** Desglose: `BUGFIEND` 9 × 3 = 27, cuerpo del
`SCUTTLER` 2 × 3 = 6, ojo 3, `AttackLight` 3. Archivos escritos: **12 materiales + 1 escena**,
contra 15 + 2 de la PRUEBA04.

Verificar descompilando desde `GAMEDATA\MODS`:

| Qué | Esperado |
|---|---|
| `FFIENDEYEMAT` → `Flags` | **5 entradas**: `_F01_DIFFUSEMAP`, `_F02_SKINNED`, `_F13_UV_EFFECT`, `_F25_MASKS_MAP`, **`_F07_UNLIT`** |
| `FFIENDEYEMAT` → `gMaterialColourVec4` | 1.0, 0.15, 0.12 |
| `FREIGHTERFIEND.SCENE` → `AttackLight` | 1.0, 0.15, 0.12 · `Light_pointLight1` intacto |
| `MINIFIEND_PET\` | **no debe existir en la carpeta del mod** |

| Lo que se vea en el carguero | Lectura |
|---|---|
| La boca/lomo **roja** en vez de amarilla | ✅ `_F07_UNLIT` es la palanca del emisivo. Marcador resuelto |
| Sigue amarilla | El emisivo no pasa por el uniform ni con `UNLIT`. Queda **repintar `FREIGHTERFIEND EYE.BASE33.DDS`** con `tools/Make-NMSTexture.py`, que ya produce BC7 válido |
| El bicho sale plano / sin sombra | `UNLIT` es demasiado: quitar el flag y pasar directo a la vía de la textura |

**Solape con `NecroSkin`:** sigue escribiendo `FREIGHTERFIEND\FFIENDMAT` con el mismo rojo, así
que da igual quién gane. No toca el `FFIENDEYEMAT`, que es lo nuevo de aquí.
