# Pendientes

**Solo dos cosas viven aquí: lo que está en el juego sin medir, y las preguntas sin
responder.** Lo comprobado no se repite aquí: se borra y se anota en el changelog que le
toque. Si buscas *por qué* se hizo algo, está en
[`CHANGELOG-MOD2.md`](CHANGELOG-MOD2.md).

**Cada fila lleva un identificador y el archivo donde se lee el detalle.** El identificador
es el nombre del `.lua` cuando la prueba tiene uno (`HT_EggMesh_PRUEBA03`), y un código corto
cuando es una pregunta y no un mod (`N1`, `Q-GLOW`).

Actualizado: **2026-09-02** (décima vuelta, y **cambian los dos bichos**: el zombie y el
necromorfo se retiran y entran el **warrior bug de Starship Troopers** sobre el `BUGFIEND` y
el **cry wolf** sobre el `FIEND`, los dos en `PRUEBA01` y mod nuevo. Los dos **medidos fuera
de la partida antes de construirlos** con `tools/Pose-NMSMesh.py`, y el cry wolf sale **mejor
que la `PRUEBA10` del zombie ya aceptada**. El hallazgo de fondo: **la causa de las dieciocho
pruebas anteriores no era el bipedismo, era la escala** — ver `B10` en `ACUERDOS.md`).

<details>
<summary>Lo que decía la cabecera anterior</summary>

Actualizado: **2026-09-01** (novena vuelta: entregada la `HT_ZombieMesh_PRUEBA10` —
`M4-SIMETRIA`—, la **primera prueba de la serie medida antes de construirla**, con
`tools/Pose-NMSMesh.py`. La `PRUEBA09` del zombie **se retira sin medir en partida**: la
herramienta nueva la midió fuera y dijo dónde falla. El necromorfo sigue en su `PRUEBA09`,
sin medir. **De aquí
en adelante solo se trabajan esos dos**; lo demás baja a §5 hasta que cierren).

</details>

> 📌 **Lo ya aprobado, y que no se toca, vive en [`ACUERDOS.md`](ACUERDOS.md).** Se creó el
> 27/08 porque la `PRUEBA14` resucitó sin querer el `AttackLight` que la `PRUEBA13` había
> apagado, y nadie lo vio hasta dos pruebas después.

---

## 1 · En el juego ahora, sin medir

**Solo se trabajan el zombie y el necromorfo.** Todo lo demás está parado y esperando turno
en §5. Construido **y desplegado** en `GAMEDATA\MODS` el **2026-09-01 a las 00:01**, verificado
descompilando el `.MBIN` de `GAMEDATA\MODS` —no el de `ModBackups`—: `Check-NMSGraft.py` da
**salida 0** en los dos, con el flag y los tres samplers leídos, y el buffer desplegado da el
**mismo md5** que el construido.

| ID | Qué mirar |
|---|---|
| 🆕 **`HT_WarriorBug_PRUEBA01`** | **¿Entra y anda el bicho de Starship Troopers en el sitio del zombie?** Mod **nuevo**, 0.1.0. **El zombie se retira**: era un bípedo sobre un artrópodo. Malla 133 108 → 36 000 tris, 20 257 vértices exportados, atlas de **doce** texturas a 2048. Pesado con mapa a mano de 7 regiones, agarre, tope 120 y alfa 0,4 en abdomen y patas traseras. **Medido antes de construir**: tensión 25,9 andando · 38,7 corriendo · 55,3 atacando, y la costura abre 11 / 17 / 28 cm; `flex` 1,12-3,06, o sea que **no es una estatua**. Asimetría **0,000** contra 0,018 del vanilla. **Cuatro finales:** entra plantado y anda con las patas → el conducto cierra · sale estirado → el flag está y los pesos no, mirar el mapa · sale rígido de una pieza → es el flag, no el mapa · textura a remolinos → es el casado de los doce slots del atlas |
| 🆕 **`HT_CryWolf_PRUEBA01`** | **¿Entra y anda el cuadrúpedo de cuello largo en el sitio del necromorfo?** Mod **nuevo**, 0.1.0. **El necromorfo se retira.** Se eligió contra el `crying-head` con motivo medido: aquél es una esfera con veinte brazos radiales y su masa vive arriba, o sea el mismo fallo por otra vía. 9 672 vértices → 11 100 exportados, **cero** aristas de UV rotas de 56 760, y **normal y rugosidad reales del asset** —lo primero de la serie: el zombie y el necromorfo llevaban normal inventado de la luminancia y máscaras planas—. **Medido antes de construir**: tensión 16,2 / 12,6 / 15,0 y abre 10 / 12 / 13 cm, o sea **mejor que la `HT_ZombieMesh_PRUEBA10` ya aceptada** (11,5 / 17,0 / 13,0 y 7 / 13 / 21 cm). Asimetría 0,000 contra 0,005. **Tres finales:** anda con las cuatro patas y el cuello no saca cuchilla → cierra · el cuello se estira → es la palanca de `NewHeadJNT`, bajarle el alfa · rígido de una pieza → es el flag |

> 🔬 **Los dos se midieron fuera de la partida antes de construirlos, y la vista lo enseña.**
> `BLENDER/vista_anim/warriorbug/` y `.../crywolf/` traen los fotogramas deformados con los
> `.ANIM` del juego. Puestos al lado de `BLENDER/vista_anim/necromorph/`, que es **lo que
> estaba desplegado**, la diferencia se ve sin medir: el necromorfo sale aplastado y con las
> cuchillas de varios metros que esta misma sección describía, y los dos nuevos salen enteros.

> 🔴 **Y el hallazgo de fondo de la sesión, que cambia la lectura de dieciocho pruebas:**
> **la causa nunca fue el bipedismo, fue la ESCALA.** Los acuerdos `B1` y `B2` subieron el
> necromorfo a 3,62 m y el zombie a 2,43 m porque a tamaño vanilla se veían enanos, y el
> precio no se midió hasta ahora: el esqueleto del `FIEND` mide **1,34 m** y el del
> `ARTHROPOD` **1,05 m**, así que **más de la mitad de la malla quedaba por encima del último
> hueso** —59,5 % y 60,7 %— donde el pesado no encuentra más que tronco. Ver `B10` en
> [`ACUERDOS.md`](ACUERDOS.md). El bipedismo lo agravaba; no era la causa.

---

### Lo que se retira

| ID | Por qué |
|---|---|
| ~~`HT_ZombieMesh_PRUEBA10`~~ | Escribe los mismos `BUGFIEND.*` que el warrior bug: **no pueden convivir.** Movido a `GAMEDATA\MODS_Retirados\` el 02/09 |
| ~~`HT_FiendMesh_PRUEBA09`~~ | Escribe los mismos `FIEND.*` que el cry wolf. Movido a `MODS_Retirados\` el 02/09. **Se retira sin medir en partida**: llevaba desde el 01/09 desplegado sin mirar |

<details>
<summary>Lo que decían las dos entregas retiradas, para no perder el rastro</summary>

| ID | Qué mirar |
|---|---|
| **`HT_ZombieMesh_PRUEBA10`** | **`M4-SIMETRIA` — ¿se acaba el descuadre de un lado?** Es la **primera prueba medida antes de entrar**, con `tools/Pose-NMSMesh.py`, que deforma nuestra malla con los `.ANIM` del juego y hace lo mismo que hace el juego. **La causa de la asimetría está medida y no es el ARTHROPOD**, que es simétrico —al andar sus dos patas giran **17,9 y 17,8** grados—: la fabrica **el propio tope**. En `attack01` los dos huesos giran 46,8 y 41,6 pero nuestras palancas son 3,6× y 2,1×, así que el vaivén sale **168 y 87** y el tope de 120 **agarra la izquierda a 0,71 y deja suelta la derecha a 1,0**. Y en locomoción el tope no llega a ninguna —valen 65 y 59—, mientras la costura de la cadera abre **22 cm**. Ahora las **dos piernas van al mismo alfa fijo de 0,4** y el tope de 120 se queda para brazos y cabeza. **Medido antes de construir:** andando 16→**7 cm**, corriendo 22→**13 cm**, atacando 21 cm sin cambio, parado sin cambio; `flex` entre 1,84 y 2,36, o sea que **no es una estatua**. **Solo cambia el buffer de vértices**: los otros cuatro MBIN, md5 idéntico a la `09`. **Tres finales:** abajo deja de descuadrarse de un lado → **`M4-SIMETRIA` cierra y solo queda el hombro** · sigue la cuchilla de un lado y no del otro → no es el alfa, es el reparto (2746 vértices contra 3610) y hay que igualar las **regiones** · sale tieso de piernas → 0,4 se pasó, subir a 0,6, que medido deja la carrera en 25,0 en vez de 17,0 |
| **`HT_FiendMesh_PRUEBA09`** | **`M3-TOPE` — ¿dejan de estirar los brazos ya descongelados?** Iban **congelados** en el alfa de la `07` desde el 30/08, y el 31/08 se vio que eso los dejaba en vaivén **207 y 154**, casi el doble de los **113** de las piernas, que son lo único que se ve bien. Entra el tope global de vaivén a **113** —el mismo número, no uno nuevo—: el brazo izquierdo baja de 207 a 113 con un agarre del **88 %** al torso y el derecho de 154 a 113 con un **82 %**. **Van a salir más tiesos, y se entrega sabiéndolo.** La cabeza sigue congelada en 0,65. **Solo cambia el buffer de vértices**. **Tres finales:** dejan de sacar cuchillas y sólo salen tiesos → el tope es la respuesta y lo que quede de estirón ya se mide sin ruido · siguen estirando con vaivén 113 → el estirón no es de giro, y toca mirar las **traslaciones** · sale todo en bloque → el tope se pasó y hay que subirlo |

> 📏 **De dónde salen esos números: se midió el 31/08 en las ocho capturas de `asset/Errores/`,
> con la `PRUEBA08` desplegada.** Cinco del zombie y tres del necromorfo. Vaivén = giro de mundo
> del hueso × palanca hasta nuestra piel, ya con el alfa aplicado:
>
> | Región | `walk`/`run` | `attack` | `idle` |
> |---|---:|---:|---:|
> | Zombie · cabeza `head_C0_0_jnt` | 21 → el tope no la veía | **300** | 123 |
> | Zombie · ancla `tail_C0_0_jnt`, de la que cuelga la cintura | 13 | 106 | 2 |
> | Zombie · piernas, **que en partida se ven bien** | 65 y 59 | 169 y 86 | 10 |
> | Necro · brazos, congelados en el alfa de la `07` | **207 y 154** | 220 | 28 |
> | Necro · piernas, tras el espejo | 113 y 113 | 258 | 21 |
>
> **El número a igualar son los 59-65 de las piernas del zombie**, que es lo único que en
> partida se ve bien en los dos bichos.

> ⚠️ **Al necromorfo le queda una cosa que ningún tope de giro arregla: el cuerpo se despega
> del suelo.** Un despegue es **traslación**, no giro, y la traslación **no** se multiplica por
> la palanca: mueve 1:1 todo lo que cuelgue del hueso. Con el **41,7 %** de la malla colgando
> de las dos patas traseras del `FIEND`, lo que suba ese pivote lo sube la malla entera. La
> tabla de traslaciones la imprime `tools/Sway-NMSJoint.py`. **Se mira cuando los brazos estén
> quietos**, no antes: hoy tapan la medida.

</details>

> 📌 **Y las dos entregas retiradas dejan una lección que sí se conserva:** todo lo que
> aprendieron —el eslabón con claves, las cuatro ranuras, el agarre, el tope de vaivén, los
> alfas fijos y `Pose-NMSMesh.py` entero— **es lo que hizo posible que los dos bichos nuevos
> salieran a la primera**. Lo que se retira son las mallas, no el método.

---

> ⚠️ **Cerrar NMS antes de desplegar, y arrancar de nuevo por Steam.** Los mods se leen **al
> arrancar** y punto: el 21/08 se desplegó con `NMS.exe` abierto y no pasó nada. **Vortex sólo
> para mods de terceros.**

> ⚠️ **Un crash apaga todos los mods.** Antes de la prueba siguiente, comprobar que
> `DisableAllMods` sigue en `false` en `Binaries\SETTINGS\GCMODSETTINGS.MXML`. Comprobado el
> 2026-09-01 al desplegar: **`false`**.

---

## 2 · Preguntas sin responder

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

## 3 · Qué está instalado — 2026-09-02 (tras cambiar los dos bichos)

Todo se mide con **`HorribleTerror_Infestation_4-Hardcore` 0.6.5**, que contiene al mod 1.
`HorribleTerror_Predators` **no debe estar instalado**: escriben los mismos archivos.

**Leído de `GAMEDATA\MODS` el 2026-09-02, carpeta por carpeta.** Nuestros siguen siendo
**nueve**: los dos de malla cambian de bicho, no de número.

| Mod | Qué entrega | |
|---|---:|---|
| `HorribleTerror_Infestation_4-Hardcore` **0.6.5** | 11 MBIN | |
| `HT_EggMesh_PRUEBA05` — obelisco entero, con textura **y a su tamaño** | 1 + 5 `ADD_FILES` | |
| **`HT_ScuttlerMesh_PRUEBA17`** — la `16` con el `AttackLight` de vuelta a cero | **8** `ADD_FILES` | ✅ **medida y CONGELADA el 28/08**: ojo apagado y espalda limpia. **No se toca más** — es la versión buena del SkrullCrawler |
| **`HT_CryWolf_PRUEBA01`** — el **cuadrúpedo de cuello largo** sustituye al necromorfo en el `FIEND` | **7** `ADD_FILES` | 🆕 desplegado el **02/09**, **sin medir en partida** pero **medido fuera**: tensión 16,2 / 12,6 / 15,0 y abre 10 / 12 / 13 cm. Único de la serie con **normal y rugosidad reales del asset**. Verificado descompilando el `.MBIN` de `GAMEDATA\MODS`: `Check-NMSGraft` **salida 0** |
| **`HT_WarriorBug_PRUEBA01`** — el **bicho de Starship Troopers** sustituye al zombie en el `BUGFIEND` | **8** `ADD_FILES` | 🆕 desplegado el **02/09**, **sin medir en partida** pero **medido fuera**: tensión 25,9 / 38,7 / 55,3 y abre 11 / 17 / 28 cm. Atlas de **doce** texturas a 2048, el doble de resolución que el zombie. Verificado sobre lo desplegado: `Check-NMSGraft` **salida 0** |
| **`MOD4_Contenedores_PRUEBA01`** — el cofre 1 de **50 a 100** casillas, un solo campo | **1** MBIN | 🔴 medido y **no funcionó**. Se queda instalado —no choca con nada de malla— y **en espera**: §5 |
| `HT_CeilingPlague_PRUEBA03` — la `02` **más** el campo que hace brotar | 2 MBIN | desplegado el 21/08, **sin medir** y **en espera**: §5 |
| `HT_DerelictBugs_PRUEBA02` | 1 MBIN | |
| `HT_PredatorParts_PRUEBA03` | 1 MBIN | |

Y aparte, nuestro pero de calidad de vida: **`BetterExtractorsDepots`**, 1 MBIN
(`BASEBUILDINGOBJECTSTABLE`). Es el **único** archivo de esa tabla en toda la carpeta `MODS`
—comprobado el 27/08— y no hay **ningún** `.pak`: los demás mods que la tocan son carpetas de
Vortex con sólo `.EXML`, que el juego no lee. Ver §1.

**Los dos despliegues del 02/09 están verificados descompilando el `.MBIN` de `GAMEDATA\MODS`**,
no el de `ModBackups`, y `Check-NMSGraft.py` da **salida 0** sobre lo desplegado en los dos:

| | Warrior bug | Cry wolf |
|---|---|---|
| Sustituye a | el zombie, en el `BUGFIEND` | el necromorfo, en el `FIEND` |
| `stride` / canales | 20 · 2, 3, 5, 6 | 20 · 2, 3, 5, 6 |
| `_F02_SKINNED` | ✅ **presente** | ✅ **presente** |
| Samplers | los **tres** a `…/WARRIORBUG.BASE*.DDS` | los **tres** a `…/CRYWOLF.BASE*.DDS` |
| Nodos, leídos sobre lo desplegado | 53 `JOINT`, 1 `MESH` | 44 `JOINT`, 1 `MESH` |
| Vértices exportados | 20 257 | 11 100 |
| Altura | **1,80 m** (1,7× el vanilla) | **1,90 m** (1,4× el vanilla) |
| Influencias por vértice | 2,17 | 2,22 |
| Asimetría, nuestra / del vanilla | **0,000** / 0,018 | **0,000** / 0,005 |
| Buffer de vértices desplegado vs. construido | **md5 idéntico** | **md5 idéntico** |
| `.SCENE` y `.MATERIAL` desplegados vs. construidos | **md5 idéntico** | **md5 idéntico** |

> ⚠️ **Y una trampa nueva que costó una vuelta: `MBINCompiler` no sobrescribe.** Tras
> `Patch-NMSGraft.py` hay que **borrar** el `.GEOMETRY.MBIN.PC` antes de recompilar el
> `.MXML`, o el binario se queda con los `JointBindings` vacíos de NMSDK **sin decir nada**.
> Y `Check-NMSGraft.py` **da salida 0 igual**, porque lee el `.MXML`. Se caza por tamaño: el
> crudo son 3 353 / 4 677 bytes y el parcheado ~14 000. Ver `B13` en [`ACUERDOS.md`](ACUERDOS.md).

> ⚠️ **El conteo de la build NO sirve de verificación en estos mods, y conviene saberlo.**
> `Build-Tiers.ps1` borra los `.lua` sueltos de `ModScript\` pero **no los de sus subcarpetas**,
> así que cada build arrastra también `BetterExtractorsDepots` —los bloques de **9 684**, **1 972**
> y **3**—. De los 11 683 cambios que reporta, lo nuestro son **`18 + 4 + 1 + 1`**; el resto es de
> otro mod y no se despliega, porque `Build-Tiers` corre con `-CopyToGamefolder NONE`. Lo que sí
> verifica una entrega de `ADD_FILES` es **el recuento de archivos** —7 y 8— y el `Check` sobre lo
> desplegado.

**Retirados a `GAMEDATA\MODS_Retirados\`** — **11 carpetas** el 02/09:
`HT_FiendMesh_PRUEBA04`, `05`, `07`, `08` y **`09`**, y `HT_ZombieMesh_PRUEBA04`, `05`,
`06_sin_flag`, `07`, `08` y **`10`**. Las dos últimas se retiran hoy porque escriben los
mismos archivos que el warrior bug y el cry wolf.
Todas escriben los mismos archivos que su sustituta, así que **no pueden convivir**.

> ⚠️ **Aquí ponía «28 carpetas» y era falso.** Contado carpeta por carpeta el 29/08 hay **tres**:
> `HT_ScuttlerMesh_PRUEBA16`, `HT_FiendMesh_PRUEBA02` y `HT_ZombieMesh_PRUEBA02`, que esta tabla
> daba por retiradas el 27/08, **ya no están en el disco**. No es un problema —lo que importa es
> que no estén en `GAMEDATA\MODS`, y no están— pero el número no se vuelve a copiar sin contar.

`NoDerelictMiniHorrors` **ya no está** en `GAMEDATA\MODS`: apuntaba a las dos carpetas donde
escribe nuestro `Infestation`.

✅ `DisableAllMods` = **`false`** el 2026-09-01, comprobado al desplegar. La última sesión no
dejó el interruptor general apagado.

**Fuera de `GAMEDATA\MODS` desde el 21/08, y no son nuestros:** `Better Extractors 10x`,
`Better Supply Depots 10x` y `Biogenerator PowerupX1000`. Eran carpetas de Vortex con **sólo
`.EXML`**, y los tres están reconstruidos a `.MBIN` dentro de `BetterExtractorsDepots`.

---

## 4 · Cómo se usa

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

---

## 5 · En espera — se retoma cuando cierren el zombie y el necromorfo

**Nada de aquí se toca hasta entonces.** Es una decisión del 2026-09-01: una prueba a la vez y
las dos mallas de superficie primero.

| ID | Qué | Estado |
|---|---|---|
| **`MOD4_Contenedores_PRUEBA01`** | El cofre 1 de **50 a 100** casillas, un solo campo en `METADATA\GAMESTATE\DEFAULTSAVEDATA.MBIN` | 🔴 **medido y NO funcionó.** Sigue desplegado porque no choca con nada de malla. Cuando se retome: la firma decía que si sale con 50, el layout viene horneado en la partida y hay que probarlo en una **partida nueva** antes de decidir nada |
| **`HT_CeilingPlague_PRUEBA03` + `Infestation 0.6.5`** | La segunda vuelta del nido: los dos MBIN son ya byte a byte iguales | ⬜ desplegado el 21/08 y **sin medir**. El detalle, en §5.1 |
| **`HT_FiendMarkers_PRUEBA05`** | Marcadores de Horror. En el juego no hay ninguno: el `PRUEBA04` está retirado | ✍️ escrito, sin construir · **choca**, ver abajo |
| **`HT_DerelictBugs`** | Devolver `CARG` y `MEDI`, **de una en una** | ⬜ sin escribir · [`../work/scripts/derelict/README.md`](../work/scripts/derelict/README.md) |
| **`N1`** | **Huevo de interior**: prueba **A** (control con `DEBRISLARGE_COMMON`) y luego **B** (huevo de `SPACEBASE`) | ⬜ la **A** escrita, la **B** no · [`ASSETS.md`](ASSETS.md) §5.1 y §5.7 |
| **`M5`** | **Cuarta malla propia.** Quedan sin usar el `angel`, la `LivingFlesh` y el traje de Dead Space. `SCUTTLER_PET` **no se toca**: es la mascota del jugador | ⬜ sin escribir · [`ASSETS.md`](ASSETS.md) §4.2 |

> **`HT_FiendMarkers_PRUEBA05` choca con la serie del SCUTTLER.** Las dos escriben
> `SPIDERRIG\FREIGHTERFIEND.SCENE.MBIN`. Por eso la `PRUEBA04` está retirada. Cuando toque,
> hay que **fusionarlas en un `.lua`** y decidir el `AttackLight`: marcadores lo quiere vivo
> (1.0 · 0.15 · 0.12), la malla lo tiene **a cero** para que el bicho no salga dorado. Manda
> la malla; los marcadores tendrán que pintar por otra vía.

---

### 5.1 · `HT_CeilingPlague_PRUEBA03` — qué toca, y por qué es un campo

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
