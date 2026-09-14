# Pendientes

**Solo dos cosas viven aquí: lo que está en el juego sin medir, y las preguntas sin
responder.** Lo comprobado no se repite aquí: se borra y se anota en el changelog que le
toque. Si buscas *por qué* se hizo algo, está en
[`CHANGELOG-MOD2.md`](CHANGELOG-MOD2.md).

**Cada fila lleva un identificador y el archivo donde se lee el detalle.** El identificador
es el nombre del `.lua` cuando la prueba tiene uno (`HT_EggMesh_PRUEBA03`), y un código corto
cuando es una pregunta y no un mod (`N1`, `Q-GLOW`).

Actualizado: **2026-09-14** (decimocuarta vuelta, y **no mide nada**: es de papeleo. El repo se
mudó a `C:\Users\<usuario>\MODS\NMS_MOD_ZOMBIES` el 13/09, y ese mismo día entró el **huevo del
facehugger** en el `FIENDEGG`, que **releva al marker** —los dos escriben los mismos archivos—.
Esta lista llevaba desde el 05/09 sin tocarse y decía dos cosas que ya no son verdad: que el
`HT_EggMesh_PRUEBA05` sigue desplegado, y que lo nuestro en el juego son ocho carpetas. **Leído
de `GAMEDATA\MODS` el 14/09, carpeta por carpeta**: el `EggMesh` ya no está y el facehugger sí.
Lo que hay que mirar en partida son ahora **dos** filas en §1).

<details>
<summary>Lo que decía la cabecera anterior</summary>

Actualizado: **2026-09-05** (decimotercera vuelta, y **es la de cerrar**: se miden seis
pruebas de una sentada y cuatro salen de aquí para no volver. La **malla del cry wolf se
congela** en la `PRUEBA07` —«dejamos el lobo como está ahorita in game»—; la **piel del warrior
bug se congela** y `Q-TEXBUG` cierra por descarte, porque el atlas a 4096 no se ve; la `0.8.0`
**cierra** y con ella la presión, que ya no se sube más; y el mod 4 se **descarta entero**. Lo
que queda vivo es lo que la partida pidió a cambio: **mapear las patas** para las animaciones
—`M6-PATAS`—, y el desenganche, que sigue abierto con **un solo sospechoso nombrado**:
«siguen alejándose en cuanto rugen», y el rugido **es** el parto).

Actualizado: **2026-09-03** (duodécima vuelta, y **es la primera que mide conducta**: entran a
la vez las tres cosas que la partida pidió. El **cry wolf** vuelve en `PRUEBA04` con el mismo
cuerpo y otro reparto de peso —el tope de vaivén se había elegido sin mirar `roar`, que resulta
ser el peor de los nueve clips—; el **warrior bug** entra en `PRUEBA05` con el atlas a 4096, que
es la otra mitad de `Q-TEXBUG` y no toca una UV; y el mod pasa a **0.7.0**, que arregla que el
combate se apagaba solo. Las mallas siguen congeladas: **ninguna de las dos mueve un vértice**).


Actualizado: **2026-09-02** (décima vuelta, y **cambian los dos bichos**: el zombie y el
necromorfo se retiran y entran el **warrior bug de Starship Troopers** sobre el `BUGFIEND` y
el **cry wolf** sobre el `FIEND`, los dos en `PRUEBA01` y mod nuevo. Los dos **medidos fuera
de la partida antes de construirlos** con `tools/Pose-NMSMesh.py`, y el cry wolf sale **mejor
que la `PRUEBA10` del zombie ya aceptada**. El hallazgo de fondo: **la causa de las dieciocho
pruebas anteriores no era el bipedismo, era la escala** — ver `B10` en `ACUERDOS.md`).

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

**Quedan dos filas.** La vuelta del 05/09 vació esta sección:
la malla del cry wolf y la piel del warrior bug **se congelan**, la `0.8.0` cierra, la `0.9.0`
dice que el interés no era y el mod 4 se descarta. Los seis veredictos, en
[`CHANGELOG-MOD2.md`](CHANGELOG-MOD2.md), entrada del 05/09. **La otra fila es nueva**: el
**huevo del facehugger**, desplegado el 13/09 y todavía sin una sola lectura.

| ID | Qué mirar |
|---|---|
| `HT_CeilingPlague_PRUEBA03` | **¿Brota el nido del techo?** Desplegado el **21/08** y todavía sin una sola lectura. **Buscado el 05/09 y no apareció, y eso no es un veredicto**: el nido colgante del carguero abandonado es un hallazgo raro, así que la fila se queda esperando a que salga uno. El detalle, en §5.1 |
| `HT_FacehuggerEgg_PRUEBA01` | **¿Sale bien puesto el huevo nuevo del suelo?** Desplegado el **13/09**, **releva al marker** (`HT_EggMesh_PRUEBA05`, que sale de `GAMEDATA\MODS` porque los dos escriben los mismos archivos). **Tres cosas y sólo tres**, ya escritas en el `.lua`: el **ancho** —1,113 contra 0,643 del vanilla, o sea **1,7 veces más ancho a la misma altura**, y puede clavarse en el decorado o solaparse con el de al lado—; el **giro en Y**, que se dejó en **0** porque el huevo es casi de revolución y lo único que lo orienta es por dónde abre; y la **altura de apoyo**, que se apoya en `Y = 0` mientras la vanilla se hunde 5 cm, así que puede flotar. La ficha, en [`MODELOS/facehuggerEgg.md`](MODELOS/facehuggerEgg.md) |

> **Lo que está desplegado y ya no se mide** porque cerró: `HT_CryWolf_PRUEBA07` (malla
> congelada), `HT_WarriorBug_PRUEBA05` (piel congelada), `HorribleTerror_Infestation_4-Hardcore`
> `0.9.0` (contiene la `0.8.0`, que cerró; los tres campos de interés se quedan puestos aunque
> no fueran la causa), `HT_ScuttlerMesh_PRUEBA17`, `HT_DerelictBugs_PRUEBA02`
> y `HT_PredatorParts_PRUEBA03`. La lista completa, en §3.

---

### Lo que se retira

| ID | Por qué |
|---|---|
| ✅ `HT_CryWolf_PRUEBA07` | **Se queda desplegada, pero sale de la cola.** Medida el 05/09: «dejamos ya las pruebas con el lobo como está ahorita in game». **La malla del cry wolf se congela** — no se toca un vértice ni un peso sin que se pida |
| ~~`HT_CryWolf_PRUEBA05`~~ | Ya estaba retirada el 05/09 por la `PRUEBA07`. **No tiene veredicto propio y no lo va a tener**: el `.SCENE` de la `07` es byte a byte el suyo (md5 `2c30d9cf`), así que su doblez de cuello a 65° **se acepta dentro de la `07`** |
| ✅ `HT_WarriorBug_PRUEBA05` | **Se queda desplegada, pero sale de la cola.** Medida el 05/09: «no hubo mucho aumento». El atlas a 4096 se ve igual que el de 2048, o sea que **la resolución nunca fue el techo** — `Q-TEXBUG` cierra por descarte. **La piel se congela**; lo que entra en su lugar es `M6-PATAS` |
| 🔴 `Infestation 4-Hardcore 0.9.0` | **Los tres campos de interés no eran.** Medida el 05/09: «siguen alejándose **en cuanto rugen**». Se quedan puestos porque no hacen daño, pero `Q-INTERES` no cierra por ahí. Lo que sí trae la queja es el **disparador**: el rugido es el parto, y eso apunta a `FiendDistToConsiderTargetSwtich`, que va sola en la `0.10.0` |
| ✅ `Infestation 4-Hardcore 0.8.0` | **Cierra.** Medida el 05/09: «si tal vez percibí más agresividad». Las seis palancas del 04/09 y las dos de la `0.7.0` se quedan; ni FPS ni puerta del carguero atascada, que eran los dos riesgos escritos. Pasan a [`ACUERDOS.md`](ACUERDOS.md). **La presión está terminada** |
| ❌ ~~`MOD4_Contenedores_PRUEBA01`~~ | **La idea se cierra entera**, decidido el 05/09: «no funcionó, vamos a cerrar la idea y quitar lo referente de él». El cofre sigue saliendo de 50 y comprobarlo exigía gastar una partida nueva. A `MODS_Retirados\` el 05/09. [`MOD4-CONTENEDORES.md`](MOD4-CONTENEDORES.md) se queda marcado como cerrado: es el mapa de qué **no** se puede tocar, y eso vale igual |
| ~~`HT_CryWolf_PRUEBA05`~~ | La sustituye la `PRUEBA07`, que escribe los mismos archivos. Se midió el 04/09 y la respuesta fue **«sigue flotando y las patas están tiesas»**: el doblez del cuello entró bien, pero el fallo era otro y estaba debajo —el bind—. A `MODS_Retirados\` el 05/09 |
| ~~`HT_CryWolf_PRUEBA03`~~ | La sustituye la `PRUEBA04`, que escribe los mismos archivos. Se midió el 03/09 y salió **buena de tamaño y de sitio**; lo que no salió es el reparto de peso. A `MODS_Retirados\` el 03/09 |
| ~~`HT_WarriorBug_PRUEBA04`~~ | La sustituye la `PRUEBA05`. **Medida el 03/09: el bicho se ve igual que la `PRUEBA03`**, así que lo que arreglaba —normal horneado y máscaras con variación— no era lo que se veía. Los dos archivos siguen dentro de la `05`. A `MODS_Retirados\` el 03/09 |
| ~~`HT_ZombieMesh_PRUEBA10`~~ | Escribe los mismos `BUGFIEND.*` que el warrior bug: **no pueden convivir.** Movido a `GAMEDATA\MODS_Retirados\` el 02/09 |
| ~~`HT_FiendMesh_PRUEBA09`~~ | Escribe los mismos `FIEND.*` que el cry wolf. Movido a `MODS_Retirados\` el 02/09. **Se retira sin medir en partida**: llevaba desde el 01/09 desplegado sin mirar |
| ~~`HT_WarriorBug_PRUEBA01` y `PRUEBA02`~~ | Las sustituye la `PRUEBA03`, que escribe los mismos archivos. La `01` medía **1,80 m** y entraba **de espalda**; la `02` la giró bien pero a **3,60 m** salió demasiado grande. A `MODS_Retirados\` el 02 y el 03/09 |
| ~~`HT_CryWolf_PRUEBA01` y `PRUEBA02`~~ | Mismo caso: **1,90 m** de espalda y **3,80 m** demasiado grande. A `MODS_Retirados\` el 02 y el 03/09 |

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
| **`Q-INTERES`** | 🔴 **El interés NO era, medido el 05/09**, y la queja trae el dato que faltaba: **«siguen alejándose en cuanto rugen».** Los tres campos que entraron en la `0.9.0` —`PredatorBoredomDistance` 80 → 150 y los dos `RegainInterestTime` 30 s → 2— no cambiaron nada; se quedan puestos porque no hacen daño. Antes ya se habían descartado con medida el despliegue (las 36 palancas de la `0.8.0` llegan exactas al `GCCREATUREGLOBALS.MBIN` de `GAMEDATA\MODS`) y el árbol de comportamiento (`GetTarget`, `MoveToTarget`, `MaintainRange` no llevan ni temporizador de rendición ni correa). **Queda un solo campo de los seis, y ahora tiene disparador nombrado.** | 🆕 **`FiendDistToConsiderTargetSwtich` = 10** (el typo es del juego), solo en la **`0.10.0`**. El rugido **es** el parto —`SpawnBroodAnim = ROAR`—, así que el instante en que te sueltan es el instante en que le nacen crías **pegadas al cuerpo**, y cada candidato a menos de 10 m le hace replantearse a quién ataca. Encaja también con que empeorase al subir los contadores de 8 a 24. **Va sola porque su signo no está claro**: 10 puede querer decir «cambia si hay algo a menos de 10 m» —y se **baja**— o «cambia sólo si el nuevo está 10 m más cerca» —y se **sube**—. Con una palanca por vuelta, el resultado dice el signo |
| **`Q-IDBICHO`** | A qué `CreatureID` corresponde el mini-Fiend que sale del nido del carguero: la `CREATUREFILENAMETABLE` dice que el nido suelta `SCUTTLER`, no `MINIFIEND` | `HT_FiendMarkers_PRUEBA05` → [`../work/scripts/marcadores/README.md`](../work/scripts/marcadores/README.md) |
| **`Q-TECHO`** | ¿Por qué el huevo de interior borra la planta del techo y no pone nada en su sitio? | **Hipótesis del 13/08:** el giro de 180° vive en el envoltorio y el `.LSYSTEM` lo tira. Prueba `N1` A/B → [`ASSETS.md`](ASSETS.md) §5.7 |
| **`Q-MASCARAS`** | ¿Qué canal del `gMasksMap` es qué? El vanilla del huevo da `R` media 179 y `G` media 73, que no cuadra con «R = metalicidad». **Contestada a medias el 22/08:** en criaturas el mapa es `ATI1` de **un canal**, y ese canal **se comporta como brillo, no como rugosidad** — con 174 el bicho sale mojado, y el vanilla mide 85, que es justo `255 − 174`. Qué nombre tiene el canal sigue sin saberse; cómo se usa, ya sí | La `HT_ScuttlerMesh_PRUEBA13` lo confirma o lo tumba → §2.1 |
| ~~**`Q-TEXBUG`**~~ | ✅ **CERRADA POR DESCARTE el 05/09: la resolución nunca fue el techo.** La vía (b) —`HT_WarriorBug_PRUEBA05`, atlas de 2048/celdas 512 a **4096/celdas 1024**, ×4 píxeles por trozo, `.DDS` de 14 a 56 MB, sin mover una UV— se midió en partida y **«no hubo mucho aumento»**. Con el 18 % del atlas pintado y once PNG de origen a 2048, subían los texeles y no subía lo que se ve. La vía (a) —repacar apretando las islas— ya estaba descartada porque el hueco viene dentro de cada PNG y apretarlo exige UV nuevas, o sea reabrir la malla congelada; la (c), 8192, por los ~270 MB | **El techo está en el material o en la luz, no en el número de píxeles** — y eso vale para los cuatro modelos, no sólo para el bug. El atlas de 4096 se queda porque ya está desplegado y no cuesta un frame medido, pero **deja de ser línea de trabajo**. Lo que entra en su lugar es `M6-PATAS` |
| **`Q-GLOW`** | ¿Cómo se enciende un emisivo de verdad? Hoy la emisión del marker va **horneada dentro del color base** | Ninguna prueba escrita → [`ASSETS.md`](ASSETS.md) §1.4 |
| **`Q-REFPATHS`** | ¿Se puede recolocar una malla vanilla en otro rig con `ReferencePaths`? **Dato nuevo del 21/08:** en el `BUGFIEND` **no están vacíos** —los ocho apuntan a `ARTHROPOD.SCENE.MBIN`—, así que el campo sí se usa. Vacíos estaban los 172 del `TREX` | [`ASSETS.md`](ASSETS.md) §3. Sube de curiosidad a vía posible |
| **`Q-CHANCE`** | ¿Qué hace un `Chance > 0` en un descriptor? | Los 172 valen 0.0 en vanilla; no hay ejemplo del que copiar → [`ASSETS.md`](ASSETS.md) §3 |
| **`Q-CARNAGE`** | ¿Qué dispara el modo «carnage» de `MaxFiendsToSpawnCarnage`? | — |
| **`Q-ANTAGONIST`** | ¿`GcAntagonistComponentData` en el huevo salvaje? | Aplazado: exige **añadir** un componente, no cambiar un valor |

---

## 3 · Qué está instalado — 2026-09-14 (con la malla y la piel congeladas)

Todo se mide con **`HorribleTerror_Infestation_4-Hardcore` 0.9.1**, que contiene al mod 1.
**Aquí ponía `0.9.0` y llevaba desfasado desde el 09/09**: lo desplegado son los `.MBIN` del
09/09 —la `0.9.1`, que es la `0.9.0` **reconstruida para 7.0 Cosmos sin tocar un valor**—. La
`0.9.2` del 10/09 **no cambia nada aquí**: sólo tocó `2-Normal` y `3-Dificil`, y el Hardcore se
quedó donde estaba.
`HorribleTerror_Predators` **no debe estar instalado**: escriben los mismos archivos.

**Leído de `GAMEDATA\MODS` el 2026-09-14, carpeta por carpeta.** Siguen siendo **ocho**, pero
no son las mismas ocho que el 05/09: **sale `HT_EggMesh_PRUEBA05` y entra
`HT_FacehuggerEgg_PRUEBA01`**, que escribe los mismos archivos y por eso lo releva. El
05/09 ya había salido `MOD4_Contenedores_PRUEBA01`, descartado ese día.

| Mod | Qué entrega | |
|---|---:|---|
| `HorribleTerror_Infestation_4-Hardcore` **0.9.1** | 11 MBIN | ✅ la `0.8.0` que contiene **cerró** el 05/09. Los `.MBIN` desplegados son del **09/09** |
| **`HT_FacehuggerEgg_PRUEBA01`** — el **huevo cerrado del facehugger** sustituye al obelisco del marker en el `FIENDEGG`; prop estático, sin piel ni pesos | 1 + 5 `ADD_FILES` | desplegado el 13/09, **sin medir**: §1. Injertado contra el **vanilla de 7.0**, que es el único que descompila |
| **`HT_ScuttlerMesh_PRUEBA17`** — la `16` con el `AttackLight` de vuelta a cero | **8** `ADD_FILES` | ✅ **medida y CONGELADA el 28/08**: ojo apagado y espalda limpia. **No se toca más** — es la versión buena del SkrullCrawler |
| **`HT_CryWolf_PRUEBA07`** — el **cuadrúpedo de cuello largo** sustituye al necromorfo en el `FIEND`; bind por `--bind fiendwalk#24` | **7** `ADD_FILES` | ✅ **malla congelada** el 05/09 |
| **`HT_WarriorBug_PRUEBA05`** — el **bicho de Starship Troopers** sustituye al zombie en el `BUGFIEND`; atlas a **4096** | **7** `ADD_FILES` | ✅ **piel congelada** el 05/09 |
| `HT_CeilingPlague_PRUEBA03` — la `02` **más** el campo que hace brotar | 2 MBIN | desplegado el 21/08, **sin medir** y **en espera**: §5 |
| `HT_DerelictBugs_PRUEBA02` | 1 MBIN | |
| `HT_PredatorParts_PRUEBA03` | 1 MBIN | |

Y aparte, nuestro pero de calidad de vida: **`BetterExtractorsDepots`**, 1 MBIN
(`BASEBUILDINGOBJECTSTABLE`). Es el **único** archivo de esa tabla en toda la carpeta `MODS`
—comprobado el 27/08— y no hay **ningún** `.pak`: los demás mods que la tocan son carpetas de
Vortex con sólo `.EXML`, que el juego no lee. Ver §1.

**Los dos despliegues del 03/09 están verificados descompilando el `.MBIN` de `GAMEDATA\MODS`**,
no el de `ModBackups`, y `Check-NMSGraft.py` da **salida 0** sobre lo desplegado en los dos:

| | Warrior bug | Cry wolf |
|---|---|---|
| Sustituye a | el zombie, en el `BUGFIEND` | el necromorfo, en el `FIEND` |
| `stride` / canales | 20 · 2, 3, 5, 6 | 20 · 2, 3, 5, 6 |
| `_F02_SKINNED` | ✅ **presente** | ✅ **presente** |
| Samplers | los **tres** a `…/WARRIORBUG.BASE*.DDS` | los **tres** a `…/CRYWOLF.BASE*.DDS` |
| Nodos, leídos sobre lo desplegado | 53 `JOINT`, 1 `MESH` | 44 `JOINT`, 1 `MESH` |
| Vértices exportados | 20 257 | 11 100 |
| Altura | **2,70 m** (2,6× el esqueleto) | **2,85 m** (2,1× el esqueleto) |
| Giro en Y | **180°** | **180°** |
| Influencias por vértice | 2,42 | 2,54 |
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

**Retirados a `GAMEDATA\MODS_Retirados\`** — **11 carpetas** el 02/09
(`HT_FiendMesh_PRUEBA04`, `05`, `07`, `08` y **`09`**, y `HT_ZombieMesh_PRUEBA04`, `05`,
`06_sin_flag`, `07`, `08` y **`10`**) **y 4 más entre el 02 y el 03/09**:
`HT_WarriorBug_PRUEBA01` y `PRUEBA02`, `HT_CryWolf_PRUEBA01` y `PRUEBA02`, que las sustituye
la `PRUEBA03` de cada uno.
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

## 5 · La cola, ya sin bloqueo

**El bloqueo se levantó el 03/09**, al cerrar el warrior bug y el cry wolf, y el **05/09 se
congelan las dos**: la malla del uno y la piel del otro no se vuelven a tocar sin que se pida.
Sigue valiendo **una prueba a la vez**.

De las dos que estaban desplegadas, `MOD4_Contenedores_PRUEBA01` **se descartó** el 05/09 y
`HT_CeilingPlague_PRUEBA03` sigue en §1 esperando a que aparezca un nido. Aquí queda lo que ni
siquiera está construido, y **la primera fila es lo que la partida pidió el 05/09**:

| ID | Qué | Estado |
|---|---|---|
| 🆕 **`M6-PATAS`** | **Mapear las patas para las animaciones**, pedido el 05/09 en lugar de seguir con la piel. Es la frontera que ya topó el cry wolf en su quinto final: las dos mallas cuelgan de **`*Leg1JNT`, que es la cadera** y sube con el cuerpo, así que la pata se mueve **poco**. El arreglo es partir la pata y colgar la parte baja de **`Leg3`**, y eso **sí es re-pesar**: reabre el reparto de peso de los dos bichos, no el buffer de vértices. Se mide fuera de la partida antes de construir, con [`../tools/Pose-NMSMesh.py`](../tools/Pose-NMSMesh.py) | ⬜ sin escribir · empieza por el **warrior bug**, que es el que se pidió |
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

---

## 6 · Lo siguiente: revisar la CONDUCTA de los dos bichos

**Cerrar las mallas desbloquea esto, y no es una coincidencia de calendario: es la
herramienta que faltaba.** Desde la `0.2.0` no se ha medido en partida **ni un solo** cambio
de conducta —la prueba del 04/08 midió la `0.1.0`—, y entre la `0.2.0` y la `0.3.3` hay
**veintiún cambios estrenándose a la vez**. La razón por la que se dejó parado está escrita en
`MODIFICACIONES.md`: casi todo lo que hay que mirar es **quién hace qué**, y hasta hoy los dos
bichos eran el mismo bicho con otra piel.

> 🔓 **El desbloqueo concreto, y estaba escrito como imposible.** `AllowSpawnBrood` decía:
> *«hace falta un sitio con Fiends pero sin huevos cerca: con `FiendMaxEngaged = 12` y huevos
> ×20, **una cría es indistinguible de un Fiend recién eclosionado**»*. Ya no: el `FIEND` es un
> **cuadrúpedo de cuello largo de 2,85 m** y el `BUGFIEND` es un **insecto de cuatro patas de
> 2,70 m**. Se distinguen de un vistazo y a contraluz. La condición que pedía aquella prueba
> —un escenario sin huevos— **deja de hacer falta**.

### Qué mirar, en este orden

Una entrada al juego por bloque, y **el bloque 1 antes que nada**: si la conducta base está
rota, todo lo demás se mide sobre ruido.

| # | Qué | Cómo se mira | Qué campos hay detrás |
|---|---|---|---|
| **1** | **¿Vienen derechos, o hacen eses?** | **Un Fiend SOLO**, en campo abierto. Es la prueba que separa las causas: si uno suelto ya viene derecho, era el *steering*; si sigue zigzagueando solo, no era ninguno de los dos y toca `PathOverestimate` | `SteeringUpdateRate` #44 · `MaxTurnRadius` #45 |
| **2** | **¿Acechan o cargan?** | Dejarte ver a **~35 m** en campo abierto. Tiene que arrancar **sin pausa** y llegar sin pararse a mitad | filas 40-42 |
| **3** | **¿Se mueven como horda?** | Manada de 5-7 depredadores: bloque, no fila india ni desperdigados | filas 46-50 |
| **4** | **¿Se multiplican?** — `AllowSpawnBrood` | **Ahora sí se puede**: cuenta cuántos insectos de cuatro patas aparecen mientras peleas con el cuadrúpedo. Los que salgan del huevo son cuadrúpedos; las crías, insectos | filas 27-29 |
| **5** | **¿Sigue el aggro sin agotarse?** | Alejarse en línea recta y ver si suelta la presa | `0.3.1` |
| **6** | **FPS** | 70 criaturas recalculando rumbo 10 veces/s. **Si cae, `SteeringUpdateRate` es el primero a revertir** | #44 |

### Antes de entrar

1. **Backup de partidas** — lo corre Claude, no el usuario.
2. **Comprobar `DisableAllMods`** en `GCMODSETTINGS.MXML`: un cierre lo deja en `true` y la
   sesión entera se mide contra vanilla sin enterarse.
3. **Verificar sobre lo desplegado**, no sobre `ModBackups`: el conteo del `REPORT` dice que la
   build salió, no que esté instalada.
4. **Arrancar por Steam**, no por Vortex.

### Lo que NO se toca al hacer esto

**Las mallas están congeladas.** Si algo de conducta obliga a tocar un `.SCENE` o un
`.GEOMETRY`, se anota y se para: la conducta vive en `GCCREATUREGLOBALS`,
`CREATUREDATATABLE`, `CREATUREBEHAVIOURTREES` e `INFESTATION`, y ninguno de esos cuatro es un
archivo de malla. El orden para revertir, si algo va mal, está al final de
[`MODIFICACIONES.md`](MODIFICACIONES.md).
