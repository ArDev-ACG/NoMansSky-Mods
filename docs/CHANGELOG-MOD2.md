# Changelog — Mod 2: Horrible Terror · Infestation

Formato: [Keep a Changelog](https://keepachangelog.com/). Versionado: SemVer.

Este mod se versiona **aparte del mod 1**. No es una actualización de
`HorribleTerror_Predators`: es otro mod que **contiene** al mod 1 y añade los Horrores
Biológicos. Se instala uno o el otro, nunca los dos.

- Changelog del mod 1 y del proyecto: [`CHANGELOG.md`](CHANGELOG.md)
- Referencia de conducta: [`COMPORTAMIENTO.md`](COMPORTAMIENTO.md)
- **Tabla viva de todos los campos: [`MODIFICACIONES.md`](MODIFICACIONES.md)**
- Tabla de configuraciones: [`../work/scripts/infestacion/README.md`](../work/scripts/infestacion/README.md)

Cada entrada anota la **versión de NMS** contra la que se probó.

---

## Vuelta de medida del 05/09 — la malla se cierra, y el interés no era (2026-09-05)

**Seis pruebas medidas en partida de una sentada.** Dos cierran con la malla congelada, una
descarta su hipótesis, una cierra el mod de conducta anterior, una sigue sin encontrarse y una
se descarta entera.

### ✅ `HT_CryWolf_PRUEBA07` — aceptada. **La malla del cry wolf se congela**

«Dejamos ya las pruebas con el lobo como está ahorita in game.» El bind por `--bind
fiendwalk#24` entra y se queda: es el que hay desplegado. **No se vuelve a tocar un vértice ni
un peso del cry wolf** sin que se pida.

Con esto se cierra la serie de siete pruebas que abrió el 02/09, y el hallazgo que la cierra
es `B15` en [`ACUERDOS.md`](ACUERDOS.md): el `JointBindings` del vanilla sólo vale si nuestra
malla está modelada en la postura en que se pesó la suya.

### ⬜ `HT_CryWolf_PRUEBA05` — no tiene veredicto propio, y no lo va a tener

«No sabría ya si esta prueba funcionó, pero la que tenemos actual es la buena.» Es correcto y
no hay nada que medir: **el `.SCENE` de la `PRUEBA07` es byte a byte el de la `PRUEBA05`**, md5
`2c30d9cf`. El doblez de cuello a 65° que introdujo la `05` **está dentro de la `07`**, así que
se acepta con ella. Lo que la `05` no pudo demostrar por separado es cuánto de la mejora era
suyo: entre las dos había un bind roto que tapaba el resultado.

> **La lección de método, que es la tercera vez que sale:** una prueba que entra encima de un
> fallo sin diagnosticar no se puede leer. La `05` se midió el 04/09 y devolvió «sigue flotando
> y las patas están tiesas», que no era su culpa.

### ❌ `HT_WarriorBug_PRUEBA05` — «no hubo mucho aumento». **`Q-TEXBUG` cierra por descarte**

El atlas a **4096 con celdas de 1024** —×4 píxeles por trozo, `.DDS` de 14 a 56 MB— se ve
prácticamente igual que la `PRUEBA04`. Es el segundo de los cuatro finales escritos antes de
entrar: **la resolución nunca fue el techo.**

Lo que eso deja probado, y vale para los cuatro modelos: con el 18 % del atlas pintado y once
PNG de origen a 2048, **subían los texeles y no subía lo que se ve**. El techo está en el
material o en la luz, no en el número de píxeles. Las dos vías de `Q-TEXBUG` quedan cerradas:
la (a) exigía UV nuevas y la (b) —ésta— no dio.

**La piel del warrior bug se congela tal como está.** El atlas de 4096 se queda porque ya está
desplegado y no cuesta un frame medido, pero **deja de ser una línea de trabajo**.

**Y en su lugar entra lo que sí se pidió: mapear las patas para las animaciones.** Es la misma
frontera que topó el cry wolf en su quinto final —colgamos de `*Leg1JNT`, que es la **cadera** y
sube con el cuerpo, en vez de partir la pata y colgar la parte baja de `Leg3`—, y es trabajo de
peso de hueso, no de textura. Ficha nueva `M6-PATAS` en [`PENDIENTES.md`](PENDIENTES.md).

### 🔴 `Infestation 4-Hardcore 0.9.0` — **el interés no era.** Y la queja trae el dato que faltaba

«Siguen alejándose **en cuanto rugen**.» Es el segundo de los cuatro finales: los tres campos
de interés —`PredatorBoredomDistance` a 150 y los dos `RegainInterestTime` a 2 s— no cambiaron
la conducta. Se quedan puestos porque no hacen daño, pero **`Q-INTERES` no cierra por ahí.**

**Lo nuevo está en las tres palabras «en cuanto rugen»,** y señalan directamente al único campo
que la `0.9.0` dejó fuera a propósito. El rugido **es** el parto —`SpawnBroodAnim = ROAR`—, o
sea que el instante en que te sueltan es exactamente el instante en que **le nacen crías
pegadas al cuerpo**. Y `FiendDistToConsiderTargetSwtich` vale **10**: cada candidato a menos de
10 m le hace replantearse a quién ataca. Hasta ahora era una sospecha por correlación —empeoró
según subían los contadores de 8 a 24—; ahora hay un **disparador nombrado**, y encaja entero.

Va sola en la `0.10.0`, y sigue en pie la razón de separarla: **su signo no está claro** —puede
querer decir «cambia si hay algo a menos de 10 m», y entonces se **baja**, o «cambia sólo si el
nuevo está 10 m más cerca», y entonces se **sube**—. Con una sola palanca en la vuelta, el
resultado dice el signo.

### ✅ `Infestation 4-Hardcore 0.8.0` — cierra

«Si tal vez percibí más agresividad.» Las seis palancas del 04/09 —los tres contadores a 24, el
parto cada 5 s, el salto a 3,0× y 1,0 m, la cadencia y las rachas, `AllowSpitAlways` y
`TurnToFaceTime` a 0,15— **se quedan**, y con ellas las dos de la `0.7.0`. Ninguna costó FPS y
ninguna atascó la puerta del carguero, que eran los dos riesgos escritos. Pasan a
[`ACUERDOS.md`](ACUERDOS.md).

**La presión está terminada.** De aquí en adelante las vueltas de conducta van al
desenganche, no a apretar más.

### ⬜ `HT_CeilingPlague_PRUEBA03` — sigue sin encontrarse, y eso no es un veredicto

«Sigo buscando in game, no me ha vuelto a aparecer; no significa que no sirva ni nada.» Queda
en §1 tal cual. Lleva desplegado desde el **21/08** sin una sola lectura, y el problema no es
el mod: es que **el nido colgante del carguero abandonado es un hallazgo raro**. Detalle en
§5.1 de [`PENDIENTES.md`](PENDIENTES.md).

### ❌ `MOD4_Contenedores_PRUEBA01` — la idea se cierra

«No funcionó, vamos a cerrar la idea y quitar lo referente de él.» El cofre sigue saliendo de
50 casillas. La firma escrita antes de entrar decía que, si salía con 50, **el layout viene
horneado en la partida** y hacía falta una partida nueva para decidir; se decide no gastar esa
partida. El mod sale de `GAMEDATA\MODS\` a `MODS_Retirados\`.

[`MOD4-CONTENEDORES.md`](MOD4-CONTENEDORES.md) **se queda, marcado como cerrado.** No es
documentación de un mod vivo: es el mapa de qué se puede tocar y qué no en los diez cofres
globales, y eso vale igual cuando la respuesta es «no se puede».

---

## `HT_CryWolf_PRUEBA07` — el bind deja de ser el del vanilla (2026-09-05)

**Las dos quejas del 04/09 —«sigue flotando» y «las patas están tiesas»— son un solo fallo.**

### La causa

`Patch-NMSGraft.py` copiaba `JointBindings` del vanilla tal cual. Esa matriz **no es una
constante del hueso**: es la inversa de la pose de mundo **en que se pesó la malla**, porque el
juego hace `v' = Σ peso · mundo(t) · bind · v`. Copiarla vale mientras nuestra malla esté
modelada en la misma postura que la del vanilla. La del cry wolf no lo está.

Medido sobre la `PRUEBA05` **descompilando el `.MBIN` de `GAMEDATA\MODS`** (45 de 45 binds
iguales al vanilla): con la pose de reposo puesta, `mundo · bind` debería dar la identidad y
desplaza la cabeza **1,69 m**, el cuello 1,45 y las patas de 0,45 a 1,27. Sólo `RootJNT` sale
a cero.

**Y el reposo del `.SCENE` no es el sustituto**: se probó y sale **peor** —tensión 87 contra
35—, porque la malla del vanilla tampoco está pesada en su reposo.

### Por qué eso produce los dos síntomas

Como cada región que se agarraba a su hueso salía disparada, el tope de vaivén se fue
apretando prueba tras prueba hasta dejar el agarre en 0,10 y 0,20 en las patas delanteras.
Resultado medido: **ninguna pata mandaba en un solo vértice**, y los pies de la malla colgaban
un **70,6 % del torso** y sólo un 29,4 % de las patas. Por eso no se abrían —tiesas— y por eso
subían y bajaban con el cuerpo en vez de quedarse en el suelo —flotando—.

### Lo que se entrega

`Patch-NMSGraft.py` gana **`--bind <ANIM.MXML>#<fotograma>`**: el bind pasa a ser la inversa de
la pose de mundo del **vanilla** en ese fotograma, así que `mundo(t) · bind` es el movimiento
del hueso **desde** ese fotograma, y eso sí se le puede aplicar a nuestra malla tal como está
modelada. **Es un retarget y no reescribe ni un `.ANIM` ni el `.SCENE`** —el `.SCENE` va byte a
byte el de la `PRUEBA05`, md5 `2c30d9cf`—, que es lo que separa esta prueba de la `PRUEBA06`,
retirada el 04/09 por empeorar.

El fotograma se barrió contra los **nueve** clips a la vez, por tensión y por distancia al
suelo: gana `fiendwalk` **f24**. Y con el bind bueno se suelta el agarre: el pesado pasa de
`obj110` a **`obj200`**, que ya estaba barrido en disco.

### Los números, sobre los archivos que se entregan

| | `PRUEBA05` | `PRUEBA07` |
|---|---:|---:|
| tensión, peor de los 9 clips | 34,85 | **18,22** |
| `flex` p99 | 3,33 | **2,46** |
| `abre` | 33 cm | **20 cm** |
| alto medio de la malla | 2,42 m | **2,85 m** |
| patas al andar | 0,45 m | **0,87 m** |
| peso de pata en los pies | 29,4 % | **46,4 %** |

Los pies del propio vanilla recorren **1,06 m**, así que 0,87 es el 82 % de lo que hace el
bicho al que sustituimos.

**El suelo, por clip** (antes → ahora): `walk` 0,44-0,67 → **−0,02-0,22** · `idle` 0,49-0,60 →
**0,01-0,11** · `run` 0,60-0,75 → **0,17-0,30** · `roar` 0,26-0,62 → −0,27-0,38 · `pounce`
0,22-1,17 → −0,25-0,74.

> ⚠️ **El precio, entregado sabiéndolo.** `trot`, `attack2` y `attack3` pasan de 0,00-0,09 a
> **hundirse entre 24 y 47 cm**. El vaivén vertical del esqueleto del `FIEND` son **0,83 m** y
> el bind sólo puede **correr** esa ventana, no estrecharla: antes estaba entera por encima del
> suelo —flotaba siempre y no se hundía nunca— y ahora está centrada. Estrecharla de verdad
> pide colgar la parte baja de la pata de `Leg3` en vez de `Leg1JNT`, que es la **cadera** y
> sube con el cuerpo, y eso es re-pesar en Blender.

### Dos guardas que cambian

- **`Patch-NMSGraft.py`** comprueba que la inversa que escribe sea de verdad la inversa y
  aborta si no (`peor < 1e-6`).
- **`Pose-NMSMesh.py`** ya no da por hecho que el bind sea el reposo del `.SCENE`: **busca** la
  pose de referencia entre el reposo y todos los fotogramas de los clips, y aborta si no la
  encuentra en ninguna. El assert viejo **abortaba una entrega buena**; el nuevo sigue cazando
  un `JOINTINDEX` o una transpuesta mal, que es para lo que existe. Sobre lo entregado dice
  «inversa de `fiendwalk` fotograma 24 en **7 de 7** huesos».

Verificado descompilando el `.MBIN` **desplegado**: bind correcto en los 7 huesos con peso,
error 4,4e-08 —que es la precisión `float32` del binario—, y md5 idéntico al construido
(`94c0277a`). `Check-NMSGraft.py` salida **0**.

---

## [0.9.0] — 2026-09-05 · NMS 170671

**La primera vuelta que toca el interés en vez de la presión.**

Diez vueltas subiendo cuántos caben, cuánto pegan y cuánto ven —y el interés no se había
tocado nunca—. La queja seguía siendo la misma: **se van sin hacer caso**.

### Lo que se descartó primero, con medida

1. **El despliegue no era.** Descompilado `GCCREATUREGLOBALS.MBIN` de `GAMEDATA\MODS`: la
   `0.8.0` estaba viva y **las 36 palancas llegaban exactas**.
2. **El árbol de comportamiento tampoco.** Sus nodos —`GetTarget`, `MoveToTarget`,
   `MaintainRange`— no llevan ni temporizador de rendición ni correa: sólo `TargetKey`,
   `ArriveDist` y velocidades. La decisión de soltarte está en código.
3. **Y `GCCREATUREGLOBALS` es el único fichero de IA de criaturas del juego**: los otros seis
   `GLOBALS\*` son robot, asentamiento, UI, colocación, tabla de juego y depuración.

### Lo que apareció

En ese fichero hay **exactamente seis** campos que gobiernan perder y recuperar el interés.
El mod había subido **dos** y dejado **cuatro** en vanilla.

| campo | vanilla | 0.8.0 | 0.9.0 |
|---|---:|---:|---:|
| `FiendBeingShotMemoryTime` | 10 | 60 | 60 |
| `PlayerPredatorBoredomDistance` | 80 | 150 | 150 |
| `PredatorBoredomDistance` | 80 | **80** | **150** |
| `PlayerPredatorRegainInterestTime` | 30 | **30** | **2** |
| `PredatorRegainInterestTime` | 30 | **30** | **2** |
| `FiendDistToConsiderTargetSwtich` | 10 | **10** | **10** — fuera a propósito |

`PredatorBoredomDistance` es **el gemelo** del que ya estaba subido: el juego trae dos
temperamentos —`TEMPERAMENT_PREDATOR` y `TEMPERAMENT_PLAYERPREDATOR`— y sólo se le había
subido la distancia de aburrimiento a uno.

> **No se ponen a cero a propósito, y la lección es de esta misma casa:** en la `0.6.1` el
> drenaje de aggro se puso a cero y dejó la primera puerta del carguero abandonado sin abrirse
> nunca. Un temporizador **se encoge, no se anula**.

### El cuarto se queda fuera, y por qué

`FiendDistToConsiderTargetSwtich` (el typo es del juego) es **el sospechoso más gordo**: con 24
Horrores enganchados y manadas de 5-7 encima, un Fiend se replantea a quién ataca cada vez que
hay un candidato a menos de 10 m —o sea permanentemente—, y encaja con que empeorara según
subían los contadores de 8 a 24, porque eso multiplica las ocasiones de replantearse.

**Se queda fuera porque su signo no está claro:** 10 puede significar «cambia si hay algo a
menos de 10 m» —y hay que **bajarlo**— o «cambia sólo si el nuevo está 10 m más cerca» —y hay
que **subirlo**—. Son direcciones opuestas, así que va solo en la `0.10.0`.

**No cambia nada más**: ni un contador, ni el salto, ni la cadencia, ni el drenaje, ni la malla,
ni el árbol. Tres números. Verificado descompilando el `.MBIN` **desplegado**.

---

## [0.8.0] — 2026-09-04 · NMS 170671

### Changed — subir la agresividad otra vuelta, por petición expresa

La `0.7.0` arregló que el combate **se apagara solo**. Esto es que además **apriete**. Seis
palancas, todas números sueltos: no se toca el árbol de comportamiento ni la malla.

| Campo | En quién | Antes | Ahora | Vanilla |
|---|---|---:|---:|---:|
| `FiendMaxAttackers` · `FiendMaxEngaged` · `MaxFiendsToSpawn` | globals | 16 | **24** | 2 · 6 · 6 |
| `SpawnBroodTimer` | `FIEND` | 10 | **5** | 0 |
| `FiendPounceDistanceModifier` | globals | 1.7 | **3.0** | 1.7 |
| `FiendMaxVerticalForPounce` | globals | 0.3 | **1.0** | 0.3 |
| `DelayBetweenPounceAttacks` | los dos | 1.2 | **0.7** | 2.0 |
| `MinFlurryHits` / `MaxFlurryHits` | los dos | 3 / 6 | **4 / 8** | 2 / 4 |
| `AllowSpitAlways` | `FIEND` | `false` | **`true`** | `false` |
| `DelayBetweenSpitAttacks` | los dos | 1.0 | **0.6** | 1.0 |
| `TurnToFaceTime` | los dos | 0.3 | **0.15** | 0.3 |

**Los tres contadores van a la par a propósito:** si caben 24 comprometidos pero sólo nacen 16,
el cupo extra no lo llena nadie. Y `SpawnBroodTimer` a 5 s **sólo se puede permitir porque la
`0.7.0` dejó el drenaje de aggro en 0,02**: con el drenaje vanilla, doblar los partos habría
doblado la velocidad a la que la oleada se desactivaba sola.

**El salto es la palanca que más cambia la sensación y no cuesta un frame.** Con
`FiendMaxVerticalForPounce` en 0.3, subirte a una roca era refugio; con 1.0 no.

**`AllowSpitAlways` no es un invento, es copiarle al padre lo del hijo.** Verificado en el
`CREATUREDATATABLE` **descompilado del juego**, no supuesto: el `BUGFIEND` lo trae en **`true`
de vanilla** y el `FIEND` en `false`. O sea que la cría ya disparaba de lejos y el padre era el
único de los dos que no. `AllowSpit` es `true` en los dos y `SpitFacingRequirement` 0.95 en los
dos, así que la condición que queda es la misma.

**Lo que se deja quieto, y por qué:** `RoarChanceOnHit` y `RoarChanceOnMiss` siguen en **0.0**
aunque los globales de depredador valgan 0.6 y 0.7 — `SpawnBroodAnim` vale `ROAR`, así que
subirlos es **parir por cada golpe** sin saber cuánto. Y `AllowSpawnBrood` del `BUGFIEND` sigue
en `false`: es **el techo de la oleada**, y encenderlo es crecimiento exponencial.

⚠️ **Lo que hay que vigilar son los FPS**, y el orden de reversión va escrito de antemano: con
`MaxEcosystemCreaturesNormal` en 70 —vanilla 40—, `SteeringUpdateRate` en 0.10 y ahora 24
enganchados pariendo cada 5 s, si el juego se atasca **primero** `SpawnBroodTimer` vuelve a 10,
**luego** los tres contadores a 16, y **sólo después** `SteeringUpdateRate` a 0.25.

Construido con 0 `[ERROR]` / 0 `[WARNING]` / 0 `[NOTICE]`, **80 cambios en 11 MBIN** (72 + 8).
Verificado **descompilando el MBIN de `GAMEDATA\MODS`**.

### Changed — `HT_CryWolf_PRUEBA05`: se re-posa el cuello, y **esta sí mueve vértices**

Las cuatro anteriores tocaron escala, giro, textura y peso de hueso; **ninguna tocó la forma**.
Ésta reabre el modelo, a petición expresa tras medir que no había otra vía (ver abajo).

**La medida del cuello.** Sobre la malla ya girada, el cuello arranca en `w 0,45` —donde el ancho
en x salta de 0,08 a 0,15, o sea donde empieza el pecho— y la cabeza vive en `w 0,00-0,10`. Del
arranque a la cabeza **sube 0,151 y avanza 0,213**: el cuello iba a **35° sobre la horizontal**.
Se dobla **30°** y pasa a **65°**.

**No es un giro rígido, es una rampa.** Va en `Export-NMSMesh.py`, entre el giro y la escala, con
un *smoothstep* que vale 0 en el arranque del cuello y 1 en la cabeza: el cuello **curva** y la
cabeza gira entera, con tangente cero en los dos extremos. Un giro rígido habría dejado un
**pliegue** en la frontera, y un pliegue es geometría — el suavizado de los pesos no lo deshace.
Toca 3719 vértices, el **38,5 %**.

**Dos efectos secundarios, medidos y aceptados:**

1. La caja pasa de `1,356 × 2,85 × 3,102` a `1,199 × 2,85 × 2,292`. Con el alto clavado en
   2,85 m, la escala uniforme cae de 5,834 a 5,158: **el cuerpo sale un 12 % más pequeño** aunque
   la silueta mida lo mismo. Si se ve pequeño, el arreglo es **un número** (`alto` 3,22 devuelve
   el cuerpo a su tamaño) y ya se sabe que 3,80 salió demasiado grande.
2. **Los cortes del mapa se re-miden**, porque van en coordenadas normalizadas: no cambian con la
   escala, pero **sí con la forma**. El arranque del cuello baja de `w 0,45` a **`w 0,35`**.

**Y el tope baja de 140 a 110.** Con las aristas un 12 % más cortas la `tensión` sube aunque el
estirón baje —es una razón entre vecinos y la referencia se encogió—, así que aquí manda `abre`,
**el estirón en metros, que es lo que se ve**. Barrido sobre los nueve clips, en cm:

| | walk | run | attack | idle | roar | pounce |
|---|---:|---:|---:|---:|---:|---:|
| `PRUEBA04` (sin doblez) | 33 | 36 | 41 | 23 | **19** | 33 |
| `PRUEBA05` obj 170 | 36 | 35 | 35 | 28 | 28 | 50 |
| `PRUEBA05` obj 140 | 30 | 28 | 31 | 23 | 23 | 42 |
| **`PRUEBA05` obj 110** | **23** | **25** | **26** | **18** | 20 | **33** |

**110 gana o empata en los seis**, y el `flex` de locomoción queda en 3,02 y 3,33 —**más suelto**
que el 2,78 y 3,40 de la `PRUEBA04`—, así que no es la estatua contra la que avisa `alfas_de`. La
pata delantera izquierda se queda en **0,9x**, un 10 % menos que la propia piel del vanilla, y se
acepta: es el 8,8 % de la malla contra la costura, que es lo que se mira.

Asimetría **0,000** contra 0,005 del vanilla, 2,71 asignaciones por vértice, `Check-NMSGraft` en
salida 0. **Las texturas no se tocan y no hace falta: el doblez mueve vértices, no UV.**

### Known — por qué hizo falta tocar la malla: **no era el pesado**

Medido el 04/09 con las capturas nuevas delante. Se deformó la misma malla con `fiendwalk`
usando los pesos de la `PRUEBA03` y los de la `PRUEBA04`, mismo fotograma: **los dos renders son
casi el mismo**. Y el `reposo.png` —la malla sin animar— ya trae el cuello largo saliendo hacia
delante.

Es decir: lo que se ve **estaba antes del pesado y sigue después**, porque es la postura de
reposo del asset. Ningún reparto de peso la cambia: en la pose de bind la piel devuelve el
vértice a su sitio por construcción. **Arreglarlo es re-posar el cuello en Blender y volver a
exportar**, o sea buffer de vértices nuevo, pesos nuevos y la altura de 2,85 m a re-medir — es
reabrir el modelo congelado. Queda **anotado y sin hacer**, a decisión del usuario.

---

## [0.7.0] — 2026-09-03 · NMS 170671

### Fixed — el combate se apagaba solo, y las tres quejas eran el mismo número

Lo que se vio jugando la `0.6.9`: **«el lobo se va después de rugir y va decreciendo el nivel
de enemigos, y los warrior bug también se van separando»**. Las tres son
`FiendAggroDecreasePerSpawn` multiplicado por el parto.

| Campo | Antes | Ahora | Vanilla |
|---|---:|---:|---:|
| `FiendAggroDecreasePerSpawn` | 0.1 | **0.02** | 0.1 |
| `FiendMaxAttackers` | 8 | **16** | 2 |

**La cuenta.** `AllowSpawnBrood` está encendido en el `FIEND` desde la `0.3.1` y
`SpawnBroodTimer` vale **10 s**, así que cada Horror pare una cría cada diez segundos — y
**cada bicho que nace resta 0,1 de aggro**. Con ocho atacantes son **0,8 cada 10 s** contra los
**3,0** que da romper un huevo: la oleada **se desactiva sola en menos de un minuto**, sin que
el jugador haga nada. Y cuando el medidor toca cero no se suelta uno: se suelta **la oleada
entera**, padre y crías. De ahí las tres quejas a la vez.

**Y el rugido no es casualidad.** `SpawnBroodAnim` del `FIEND` vale `ROAR`, o sea que **el
rugido ES el parto**. «Se va después de rugir» es literalmente «se va después de gastar aggro».

**Por qué 0,02 y no 0,0.** A cero estuvo desde la `0.3.1` y la `0.6.2` lo devolvió a vanilla
por una razón concreta: la **primera puerta del carguero abandonado** pedía seguridad adicional
y no abría nunca, porque esa puerta necesita que el medidor **se vacíe**. Con 0,02 se sigue
vaciando —cinco veces más despacio—, que es el tiempo que dura una pelea y no el que dura la
partida. **Si la puerta vuelve a atascarse, se sube a 0,05 antes que a 0,1.**

**`FiendMaxAttackers` 8 → 16** es el mismo número que `FiendMaxEngaged`. Con 8, sólo la mitad
de los enganchados podía pegar y la otra mitad se quedaba esperando alrededor: eso es el «se
van separando» de las crías, y no hacía falta ningún campo de dispersión para producirlo.

**No se toca ni la malla ni el árbol de comportamiento.** Construido con 0 `[ERROR]` / 0
`[WARNING]` / 0 `[NOTICE]`, **72 cambios en 11 MBIN** —uno más que los 71 de la `0.6.4`, y es
exactamente `FiendAggroDecreasePerSpawn`, que a 0,1 coincidía con vanilla y no contaba—.
Verificado **descompilando el MBIN de `GAMEDATA\MODS`**, no el `.EXML` del build.

> ⚠️ **Trampa de AMUMSS que costó un build:** una comilla doble dentro de `MOD_DESCRIPTION`
> cierra la cadena Lua. El error que sale es `'}' expected (to close '{' at line 59)`, que
> apunta a la llave y no a la comilla. En las descripciones se entrecomilla con guiones.

### Fixed — el cry wolf: el tope de vaivén no veía el peor clip de los nueve

`HT_CryWolf_PRUEBA04`. **La geometría no se toca**: seis de los siete archivos van byte a byte
los de la `PRUEBA03` y el séptimo —el buffer de vértices— mide los mismos 513 252 bytes con los
mismos 11 100 vértices en el mismo sitio. Lo único que cambia es **el peso de hueso**.

Lo que se vio jugando: **las dos patas traseras se deforman al rugir y al atacar, y camina como
si le pesara la cabeza**. Dos causas medidas, y son una sola vista dos veces.

**1 · El tope leía cuatro clips y el `FIEND` tiene nueve.** Medidos los nueve con
`Pose-NMSMesh.py` sobre la `PRUEBA03` ya desplegada, el que más tensa **no es ninguno de los
cuatro**:

| clip | roar | run | pounce | attack | walk | idle | attack2 | trot | attack3 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| tensión | **36,4** | 28,2 | 26,8 | 26,2 | 25,8 | 15,7 | 8,9 | 8,2 | 7,6 |

Y en `roar` el giro de mundo de `RootJNT` pasa de los **6,3** que veía el tope a **44,2**
—siete veces—, `NewBack1JNT` de 6,3 a **49,4** y `NewHeadJNT` de 2,9 a **72,2**. El 170 de la
`PRUEBA03` se eligió sobre un vaivén **infravalorado ocho veces**. Y `roar` no es un clip raro
en este mod: es el que más se ve, porque **es la animación del parto**.

**2 · Al cuello no lo topaba nadie.** `NewBack1JNT` es el hueso del que cuelga el cuello largo,
y es el que `Pose-NMSMesh.py` culpa en **los nueve clips**. No tenía `agarre`, y `alfas_de`
**sólo recorre las regiones que lo tienen**: se quedaba en vaivén **279** contra un objetivo de
170, sin que ningún tope lo mirase. Es el mismo fallo exacto que el zombie tuvo con
`tail_C0_0_jnt` hasta su `PRUEBA09`. **La firma de la `PRUEBA03` pedía partir `NewBack1JNT` en
cuello y pecho y no hacía falta: no le faltaba una región, le faltaba un ancla.**

Barrido de `objetivo` puntuado con los nueve clips, y se entrega **140**:

| | peor clip | costura walk/run/attack | flex locomoción |
|---|---:|---:|---:|
| `PRUEBA03` | 36,4 | 39 / 42 / 46 cm | 3,74 y 5,25 |
| obj 200 | 27,8 | 45 / 49 / 52 cm | 3,53 y 4,50 |
| obj 170 | 23,7 | 39 / 42 / 46 cm | 3,15 y 3,95 |
| **obj 140** | **19,6** | **33 / 36 / 41 cm** | **2,78 y 3,40** |
| obj 110 | 15,5 | 26 / 29 / 33 cm | 2,37 y 2,82 |

No se coge 110 por el aviso del propio guion —apretar el alfa baja la tensión **siempre** y al
final deja una estatua—: a 110 la pata delantera izquierda se queda en **0,9x**, o sea moviendo
**menos que la propia piel del vanilla**. A 140 la locomoción queda en flex 2,78 y 3,40, por
encima del 1,84-2,36 con el que se aceptó el zombie.

Contra la `PRUEBA03`: **roar 36,4 → 15,2**, run 28,2 → 16,9, attack 26,2 → 15,5, walk 25,8 →
19,0, y la pata trasera derecha —el hueso con más tensión propia después de los dos del tronco—
baja de **6,09 a 1,77**. Asimetría **0,000** contra 0,005 del vanilla, `Check-NMSGraft` en
salida 0.

### Known — el despegue del suelo es traslación, y no lo arregla ningún peso

Medido y escrito antes de entrar: en `roar` el pivote de `RootJNT` **sube 58 cm** y en `pounce`
el bicho entero sube **1,39 m**. Eso es traslación del propio `.ANIM` del juego, y la
traslación **no se multiplica por la palanca ni la corrige ningún peso**: mueve 1:1 todo lo que
cuelgue del hueso. El vanilla da el mismo salto con un bicho de 1,2 m y por eso no canta. Si el
lobo «vuela» **al saltar**, es esto.

### Changed — el warrior bug a ×4 de píxeles, que es la otra mitad de `Q-TEXBUG`

`HT_WarriorBug_PRUEBA05`. La `0.6.9` arregló lo que **no** era resolución y en partida el bicho
**se sigue viendo igual**. Queda lo que su propia firma dejó apuntado.

**El agujero, medido sobre el atlas entregado:** 73,4 % negro puro, **81,9 % por debajo de 6**,
la fila de arriba —cuatro celdas— **completamente vacía** y la mejor celda al 64,7 %. Lo
pintado ocupa el **18 %** de los cuatro millones de píxeles, o sea ~760 000 texeles para un
bicho de 2,70 m: **menos de los que tiene el `ARTHROPOD` vanilla en su atlas de 1024**, que es
al que sustituye. El bug iba con **menos** resolución que el vanilla, no con más.

El atlas pasa a **4096 con celdas de 1024**: ×4 píxeles por trozo, y de tirar 15 de cada 16
píxeles de los PNG de origen a tirar 3 de cada 4. Los tres `.DDS` pasan de 14 MB a **56**.

**Y no se toca una UV.** La rejilla sigue siendo 4×4 —`LADO = atlas // celda`— y las
coordenadas se calculan en **fracción** del atlas, así que salen idénticas: el buffer de
vértices va byte a byte el de la `PRUEBA03`, y ése es el comprobante. El normal se vuelve a
hornear a 4096 y da desviación **17,2 / 17,3** con medias 127,9 / 128,0 —la `0.6.9` daba
20,1 / 20,2 a 2048—: no baja porque se aplane, baja porque la misma pendiente repartida entre
cuatro veces más texeles cambia menos de un texel al siguiente. Las máscaras salen del atlas
nuevo y miden lo mismo, útil **146,1 / 30,6** contra 146,6 / 30,6 del vanilla.

**La otra vía de `Q-TEXBUG` queda descartada, no aplazada:** repacar las islas apretando el
81 % vacío exige **UV nuevas**, y UV nuevas son buffer de vértices nuevo, o sea reabrir la
malla que se congeló el 03/09. El hueco **no lo crea el atlas**, viene dentro de cada PNG de
origen.

### Added — `--tamano` en `tools/Make-NMSTexture.py`

La cabecera DDS se copia byte a byte del vanilla, y con ella venían sus dimensiones: subir el
atlas era imposible sin un donante de 4096. `--tamano N` parchea **cuatro campos** —alto,
ancho, `linearSize` y número de mips— y deja formato, flags y bloque DX10 como los del juego.
Los tres archivos se validan bloque a bloque contra lo que exige su propia cabecera.

---

## [0.6.9] — 2026-09-03 · NMS 170671

### Fixed — el warrior bug no se veía de plástico por una causa, sino por dos

`HT_WarriorBug_PRUEBA04`. **La malla no se toca**: seis de los ocho archivos van byte a byte
los de la `PRUEBA03`, verificado por md5 contra `ModBackups`. Cambian **dos**, y lo que mide
esta entrega son dos cosas separadas que se leían como una sola.

| | Antes (`PRUEBA03`) | Ahora | Vanilla |
|---|---:|---:|---:|
| Normal, desviación R / G | **2,3 / 3,6** | **20,1 / 20,2** | 17,2 / 18,3 (`FIEND`) |
| Normal, media R / G | 127,7 / 127,7 | 128,6 / 128,5 | 127,1 / 127,9 |
| Máscaras, media / desviación útil | **87,0 / 0,0** | **146,1 / 30,6** | 146,6 / 30,6 (`ARTHROPOD`) |

**«Plano» y «de plástico» no eran el mismo defecto.** El normal iba **siete veces más liso**
que el del vanilla porque `Make-NMSNormal.py` lo saca de la luminancia del color y las doce
texturas de este asset vienen pintadas muy planas: no había relieve que extraer. Y las
máscaras eran **el número 87 repetido en los cuatro millones de píxeles** —desviación exacta
0,0—, y un brillo idéntico en todo el cuerpo es justo lo que el ojo lee como plástico. Encima
el 87 se había copiado del `FIEND`, que es el vanilla del **otro** bicho: el `ARTHROPOD` mide
146,6.

### Added — `tools/Bake-NMSNormal.py`: el relieve sale de la geometría, no de la pintura

El asset entra con **133 108** triángulos y el juego se lleva **36 000**, así que tres cuartas
partes de la forma estaban esperando en el `.fbx`. El guion nuevo las hornea sobre las UV de
nuestra malla con Cycles, `selected_to_active`.

**No se subió `--fuerza` al mapa viejo, y es a propósito:** multiplicar por siete un relieve
sacado de la pintura convierte cada línea pintada en un bulto, que es el efecto «baba» que ya
costó la `PRUEBA12` del SkrullCrawler.

Dos trampas medidas, las dos con guarda dentro del guion:

1. **Las dos mallas no importan en el mismo sitio.** Miden lo mismo hasta el milímetro y están
   separadas **4,556**, porque `Decimate-NMSMesh.py` asienta la malla y el `.fbx` sigue en su
   origen. Se alinean por el centro de la caja; si las **medidas** no casan, aborta.
2. **Un normal no es color.** Guardado en sRGB, el PNG sale con la media en **187,6** en vez de
   128 —0,502 lineal pasa a 0,735 con la curva— y el plano deja de estar en el centro. La
   imagen se marca `Non-Color`.

Y el assert que de verdad corta: **si la desviación sale por debajo de 8, no ha horneado nada**
y el guion no deja un PNG que parece bueno.

### Added — `tools/Make-NMSMasks.py`: variación cuando el asset no trae rugosidad

El brillo sale de la **luminancia del propio atlas de color**, y es una aproximación elegida a
sabiendas: en un modelo pintado las grietas van oscuras y son mates y los bultos van claros y
brillan. Se tipifica y se vuelve a escalar a la media y la desviación del vanilla, porque lo
que falta no es el nivel, **es la variación**.

**El fondo se queda a 0 y ese es el punto.** El **81,3 %** del atlas del bug es fondo sin usar;
normalizarlo entero lo mandaría al valor medio y a partir del cuarto mip sangraría hacia dentro
de cada isla. Es la misma trampa que el `--invertir` del conversor le hizo al cry wolf, que le
dejó el **50,1 %** de su atlas a **255**, o sea a brillo máximo. El derrame se hace después, con
`--rellenar`.

### Known — el cry wolf tiene ese fallo y **no se ha tocado**

Medido el 03/09 y anotado sin arreglar, por decisión del usuario —«el lobo está bien»—:

```
CRYWOLF.BASE.MASKS.DDS   media 214,4   contra los 85,6 del FIEND vanilla
  50,1% del atlas es fondo sin usar, invertido a 255 = brillo maximo
  zona util 173,7, el doble del vanilla
```

Su **normal sí está bien** —126,7 / 127,3 / 244,1 en la zona útil—; lo que bajaba la media a 63
era el fondo negro del atlas, no el mapa. Si algún día el lobo se ve mojado, esto es lo primero
que mirar, y es **un solo archivo**.

---

## [0.6.8] — 2026-09-03 · NMS 170671

### 🏁 Cerrada la malla: el warrior bug y el cry wolf quedan congelados

`HT_WarriorBug_PRUEBA03` y `HT_CryWolf_PRUEBA03`. **Estos son los modelos definitivos del
mod y no se vuelven a tocar.** Con esto termina la línea que empezó el 13/08 con el huevo y
que se llevó dieciocho pruebas del zombie y el necromorfo antes de cambiar de bicho.

| | Warrior bug | Cry wolf |
|---|---|---|
| Sustituye a | el zombie, en el `BUGFIEND` | el necromorfo, en el `FIEND` |
| Altura | **2,70 m** | **2,85 m** |
| Giro en Y | **180°** | **180°** |
| Reparto dominante | spine 76,5 % · head 13,6 % · tail 9,9 % | Root 42,6 % · Head 35,5 % · Back 18,3 % |
| Asimetría, nuestra / vanilla | **0,000** / 0,018 | **0,000** / 0,005 |
| Tensión `walk` / `run` / `attack` | 14,4 · 26,0 · 30,9 | 25,8 · 28,2 · 26,2 |
| La costura abre | 9 · 18 · 26 cm | 39 · 42 · 46 cm |
| `Check-NMSGraft` sobre lo desplegado | **salida 0** | **salida 0** |

### Changed — el tamaño y el giro los decidió la partida, no el volcado

Tres entregas en dos días, y las dos correcciones vinieron de mirar el bicho en el juego:

| | Bug | Lobo | Veredicto |
|---|---:|---:|---|
| `PRUEBA01` | 1,80 m, `giro (-90, 0)` | 1,90 m | 🔴 **entraban de espalda** |
| `PRUEBA02` | 3,60 m, `giro (-90, 180)` | 3,80 m | 🔴 **girados bien, pero demasiado grandes** |
| `PRUEBA03` | **2,70 m** | **2,85 m** | 🏁 **cerrada** |

**El giro de la `PRUEBA01` se eligió con un volcado y el volcado medía otra cosa.** Decía que
con `180` el décimo superior de la malla caía en `w 0,38` contra la cabeza vanilla en `w 0,84`,
o sea «montado del revés». En un insecto **el décimo superior son las patas levantadas, no la
cabeza**. Corrige `B11` en [`ACUERDOS.md`](ACUERDOS.md): el giro no lo confirma un volcado, lo
confirma una entrada al juego.

**Y la regla «1,4-1,7× el vanilla» de `B10` duró un día.** A 2,70 y 2,85 los dos van a **2,6×
y 2,1× su esqueleto**, muy por encima de aquel tope, **y el pesado pasa igual**. Lo que aquella
regla explicaba era el fallo del **vecino más cercano**, no un límite de tamaño: con mapa a mano
la cobertura del esqueleto deja de mandar.

### Added — `B14`: cambiar la altura obliga a re-medir el tope de vaivén

Dos cosas que sólo se ven al tocar la escala, y que ahora están en `RECETA-PIEL.md` §3:

1. **El mapa de regiones se espeja si cambia el giro.** Va en coordenadas normalizadas de
   nuestra caja, y `Ry(180)` espeja `u` y `w`. Sin espejar los cortes, la región de la cabeza
   del bug cazaba la punta del abdomen —759 vértices en vez de 2 665— y `spine_C0_0_jnt` subía
   al **92,2 %** contra un tope de 85. Es la misma línea con `u → 1−u` y `w → 1−w`; `v` no se
   toca.
2. **El tope de vaivén NO es invariante de escala.** El vaivén es giro × palanca, y la palanca
   es la distancia de la región al pivote partida por el tamaño de la región: el esqueleto del
   juego **no** crece con nosotros. La cabeza del bug va **4,4×** a 1,80 m, **5,4×** a 2,70 y
   **7,0×** a 3,60. Con el tope quieto en 120, agrandar el bicho **lo deja tieso** —el agarre de
   la cabeza subía al 76 %— y además rompe el assert.

El número nuevo es una **ventana**, no un valor, y se lee en la columna `todos` de la propia
corrida:

| | Por debajo, la cabeza pierde su hueso | Por encima, las patas se sueltan | Elegido |
|---|---:|---:|---:|
| Bug 2,70 m | 195 | 316 | **300** |
| Lobo 2,85 m | 129 | 214 | **170** |

**Y dentro de la ventana no se coge el centro a ciegas: se puntúa con `Pose-NMSMesh.py`.** En el
lobo, `200` daba tensión 30,3 / 33,2 / 30,8 y costura 45 / 49 / 52 cm, y `170` la bajó a
25,8 / 28,2 / 26,2 y 39 / 42 / 46 **con el mismo reparto**. Dos números que el assert acepta
igual no son el mismo bicho.

### Known — al lobo le queda costura, y no es la escala

**El cry wolf abre 39-46 cm y la `PRUEBA01` abría 10-13.** No lo explica el tamaño: a 3,80 m
abría 45-56 y bajarlo a 2,85 casi no lo movió. `Pose-NMSMesh.py` pone la costura en
`NewBack1JNT` en los cuatro clips, o sea **el cuello largo colgando del pecho**. Si algún día
molesta en partida, el arreglo **no es el tope** —ya está en el centro de su ventana— sino
**partir `NewBack1JNT` en dos regiones, cuello y pecho**. Se deja anotado y **no se toca**: el
modelo está cerrado por decisión del 03/09.

---

## [0.6.7] — 2026-08-22 · NMS 170671

### Fixed — `M-BABA`: el `gMasksMap` no estaba flojo, estaba al revés

`HT_ScuttlerMesh_PRUEBA13`. Es la `PRUEBA12` con **un solo archivo cambiado** —los otros
siete salen byte a byte iguales, verificado por md5 contra `ModBackups`—, así que lo que mide
es una cosa y no dos. Construida con 0 errores / 0 warnings / 0 notices y desplegada con los
ocho archivos verificados por md5 en `GAMEDATA\MODS`.

| `ATI1` de un canal | media | útil media | p1 | p99 | máx |
|---|---:|---:|---:|---:|---:|
| `FIEND` vanilla | 85,4 | 86,9 | 5 | 156 | 192 |
| Nuestro, `PRUEBA12` | 173,6 | 199,5 | 69 | 236 | 255 |
| Nuestro, `PRUEBA13` | 47,3 | **54,0** | 17 | 105 | 255 |

**La causa, y no es la que se había anotado.** Desde el 20/08 estaba escrito que nuestras
máscaras daban «el doble de brillo» que las del vanilla, lo cual invitaba a atenuarlas. Al
medirlas otra vez sale algo más concreto: el asset de Meshy entrega **`roughness`** —valor
alto = áspero = **mate**— y el shader lee ese canal como **brillo** —valor alto = **mojado**—.
El mapa viene **al revés**, no flojo. La aritmética lo ata: **255 − 173,6 = 81**, contra los
**85** del vanilla.

Por eso se **invierte** y no se atenúa: atenuar dejaría las grietas brillantes y los bultos
mates, que es el mismo mapa del revés y sólo un poco más flojo.

> **El `--invertir` del conversor no basta, y por eso el PNG se prepara aparte.** El **13,3 %**
> de nuestra textura es UV sin usar y está a 0; invertirla lo pondría a **255**, brillo máximo
> pegado al borde de cada isla, que a partir del cuarto mip sangra hacia dentro. Que ese 13,3 %
> es hueco de verdad está comprobado: **donde la rugosidad vale 0 el color base también es
> negro** (RGB 2,8 / 1,8 / 1,7 con desviación 15, contra 106,7 / 68,3 / 65,3 en la parte útil).
> Se invierte sólo lo útil y el fondo se queda a 0.

**Contesta a `Q-MASCARAS` a medias:** no dice qué nombre tiene el canal, pero sí que se
comporta como brillo y no como rugosidad, que es lo que hacía falta para arreglarlo.

**Y le queda la otra mitad**: el necromorfo y el zombie no llevan máscaras propias —usan las
del vanilla cayendo en nuestras UV— y en las capturas el zombie sale mojado. Mismo arreglo,
prueba aparte, y **después** de que la `PRUEBA13` diga si la inversión es la buena.

### 🔓 El SkrullCrawler nunca se decimó, así que `M-NUCA` no es el presupuesto

Se pidió subirlo a 30 000 triángulos, por lo mismo que arregló el confeti del necromorfo y del
zombie. **No se puede, y no haría nada:** el FBX de Meshy trae **9 592 triángulos** y la malla
que está en el juego trae los mismos **9 592**. Este bicho entró por el conducto manual de las
once primeras pruebas, antes de que existiera `Decimate-NMSMesh.py`, y **nunca pasó por un
decimador**. El colapso de UV que puso a confeti a los otros dos no le aplica.

Con eso `M-NUCA` —la nuca con la textura estirada— pierde a su sospechoso principal y se queda
donde ya apuntaba: el desenvuelto del asset. Queda escrito en el propio
`tools/Decimate-NMSMesh.py`, con presupuesto 30 000 que no dispara nunca, para que nadie
vuelva a proponerlo.

### Fixed — `M-CONFETI` cerrado, medido en partida

Capturas del 2026-08-22 en `asset/Errores/`. Ni el necromorfo ni el zombie salen ya con el
color a confeti: los dos van en gris hueso y **la silueta se lee** —al zombie se le distinguen
cráneo, costillas y dedos; al necromorfo, el cráneo y los miembros con garra—. El diagnóstico
del horneado por triángulo de la 0.6.6 queda **validado en partida**.

**Y el juego no se cerró al parir el Horror**, que era la otra mitad de lo que medía la
`HT_ZombieMesh_PRUEBA02`: el `.DESCRIPTOR` recortado aguanta.

Las capturas dejan además dos cosas que no se preguntaban, y las dos **desbloquean cola**:

| Lo que se ve | Qué desbloquea |
|---|---|
| El **zombie se deforma** — tres capturas, tres posturas: brazo alzado, zancada, brazos recogidos | `M4-PIEL`. La cría **sí** aplica el esqueleto |
| El **necromorfo va rígido**, abierto en estrella e idéntico en las tres | `M3-PIEL`. Es la firma exacta de la malla sin `_F02_SKINNED`, o sea que se entregó como se quería |

---

## [0.6.6] — 2026-08-21 · NMS 170671

### Changed — `HT_FiendMesh_PRUEBA02` y `HT_ZombieMesh_PRUEBA02`: el presupuesto de triángulos

Sustituyen a las dos `PRUEBA01`, que ya entraron en partida el 21/08. **Misma malla, misma
textura, mismo injerto: lo único que cambia es cuántos triángulos se conservan.** Construidas
con 0 errores / 0 warnings / 0 notices, `Check-NMSGraft` en salida 0 las dos, y los `.MBIN`
verificados por md5 y descompilados desde `GAMEDATA\MODS` tras desplegar.

| | Origen FBX | `PRUEBA01` | `PRUEBA02` | Vértices exportados |
|---|---:|---:|---:|---:|
| Necromorfo → `FIEND` | 278 381 | 5 999 (2,2 %) | **30 000 (10,8 %)** | 14 233 → **59 384** |
| Zombie → `BUGFIEND` | 349 911 | 5 999 (1,7 %) | **36 000 (10,3 %)** | 8 172 → **31 475** |
| *`FIEND` vanilla* | | | *36 590* | *20 508* |

**Por qué: la textura no estaba mal elegida, estaba bien puesta sobre una malla que ya no era
la suya.** En partida la `PRUEBA01` salió bien plantada y del tamaño correcto pero con el color
raro. Los assets de Tripo y Meshy vienen **horneados por triángulo** —una isla de UV por cara,
por eso el atlas se ve a confeti cuando se mira suelto—, así que al colapsar 46:1 y 58:1 cada
cara superviviente muestrea a caballo entre islas que ya no le corresponden. El atlas se
verificó por md5: es **el mismo archivo** que la `PRUEBA01`. No depende de la malla, sólo las
UV, y ésas viajan en el `.GEOMETRY`.

### 🔓 El techo no es el vanilla, es el formato: `Indices16Bit`

**Hallazgo que costó un export.** El `.GEOMETRY` se escribe con `Indices16Bit = 1` —índices de
dos bytes, **65 536 vértices como máximo**— y **NMSDK no lo comprueba**: a 36 000 triángulos el
necromorfo salió con `VertexCount 69261` y la bandera de 16 bits puesta, **sin una sola queja**.
Eso son índices que dan la vuelta, y se habría llevado al juego una malla rota sin aviso.

Y el número **hay que medirlo después de exportar, no antes**: el exportador parte vértices, y
cuánto depende del desenvuelto. El necromorfo da **1,92** exportados por triángulo (siete piezas
y atlas, casi cada esquina se parte); el zombie **0,87** (un material, desenvuelto continuo).
De ahí que quepan 36 000 en uno y sólo 30 000 en el otro.

`tools/Check-NMSGraft.py` **comprueba ahora `VertexCount` contra el techo** y da salida 1.
Comprobado que salta con el export de 69 261. `tools/Decimate-NMSMesh.py` pasa a presupuesto
**por modelo** y acepta `-- <modelo>` para no reescribir el `.blend` de los otros.

> **Las dos siguen rígidas a propósito**, sin `_F02_SKINNED`. `M3-PIEL` y `M4-PIEL` van
> **después** de esta prueba y no antes: el `pesos.json` sale de la geometría, y rehacer la
> malla obliga a repetir el pesado entero.

---

## [0.6.5] — 2026-08-21 · NMS 170671

### Added — `HT_ZombieMesh_PRUEBA01`, un zombie en la cría y la primera ranura procedural

Cuarta ranura, **primera fuera del `SPIDERRIG`**: el cuerpo del `BUGFIEND`, la cría que el
Horror pare al rugir. Rig `ARTHROPOD`, 53 huesos, **once** nodos `MESH` y `.DESCRIPTOR` propio.
`Check-NMSGraft` en salida 0 antes de construir; 0 errores / 0 warnings / 0 notices.

**Lo nuevo es el descriptor, y es lo único que puede cerrar el juego.** El injerto borra diez
de los once nodos `MESH` y **siete de las ocho entradas del descriptor los nombran**. Por eso
esta prueba **entrega también el `.DESCRIPTOR`**, recortado a la forma exacta del `FIEND`: un
grupo, una entrada (`_Arthropod_1`), sin hijos. El nodo conservado es `ArthropodThorax`, que
no figura en el descriptor y por tanto siempre está.

**Dos supuestos del proyecto caen, leyendo el archivo:**

| Se creía | Lo que dice |
|---|---|
| El `BUGFIEND` sale distinto cada vez | Es **determinista**: ocho grupos, **una opción** cada uno, `Chance 0.0` |
| `ReferencePaths` vacío en todos los descriptores (`Q-REFPATHS`) | **Aquí no**: los ocho apuntan a `ARTHROPOD.SCENE.MBIN`. Vacíos estaban los 172 del `TREX` |

Escala **2,43 m**, sacada de una regla y no de un gusto: el necromorfo quedó a 0,727 de la
dimensión mayor del `FIEND` (3,62 sobre 4,98), y la mayor del `BUGFIEND` es 3,34.

Y **ninguna textura vanilla se pisa**: `ARTHROPODTHORAX01.BASE.DDS` lo comparte toda la fauna
artrópodo, así que se reapunta el material —exclusivo del `BUGFIEND`— a `ZOMBIE.BASE.DDS` y
`ZOMBIE.BASE.NORMAL.DDS`. El normal de este asset **sí viene esculpido**: desviación 51,8.

### Changed — el necromorfo, al doble

Salió entero, de pie y con los colores en su sitio, pero **se veía pequeño**. La causa estaba
en la propia regla de escala: se midió contra la **altura** del `FIEND` vanilla (1,81 m), y ese
bicho es bajo pero **5 m de largo**, así que un humanoide erguido a su altura se ve enano.
Rehecho a **3,62 m**. La colisión sigue siendo la del vanilla: el bicho es ahora más alto que
su caja.

### Fixed — el nido no brotaba: ganaba el `Infestation`

`HT_CeilingPlague_PRUEBA03` no llamó Horrores, y lo hizo **con la firma escrita de antemano**:
el nido despertaba con la linterna pero romperlo no hacía nada. Prioridades del
`GCMODSETTINGS.MXML`: `PRUEBA03` en **2**, `Infestation` en **18** — **gana el número más
alto**, dato nuevo y medido.

En vez de pelear con el orden de carga, el campo se puso **también** en el `Infestation`
Hardcore. Los dos mods escriben ahora un MBIN **byte a byte idéntico** (`5c0bc001…`), así que
el empate deja de existir en vez de resolverse a favor de alguien.

### Added — `HT_FiendMesh_PRUEBA01`, el necromorfo en la ranura del `FIEND`

Segunda malla propia dentro de una criatura, y la primera en el Horror **de superficie** —y
en el `MINIFIEND`, que comparte modelo por `CREATUREFILENAMETABLE`—. Construida con AMUMSS
5.6.2.0w, **0 errores / 0 warnings / 0 notices**, y desplegada a `GAMEDATA\MODS` con los seis
archivos verificados por md5 contra la fuente que pasó `Check-NMSGraft` con salida 0.

Va **rígida a propósito**: `FIEND_MAT` sin `_F02_SKINNED`, que es el equivalente de la
`PRUEBA02` del SCUTTLER. Pesar contra el `SPIDERRIG` es `M3-PIEL` y va en su propia prueba.

**Las once pruebas del SCUTTLER se comprimen en una** porque la receta quedó automatizada:
`Atlas-NMSMesh.py` funde los siete colores del asset en un atlas de 2048² y mueve las UV, y
`Graft-NMSScene.py` reescribe los diecisiete atributos del nodo de malla.

### Fixed — `M-ANIM` cerrado: el SkrullCrawler se mueve con el esqueleto

`HT_ScuttlerMesh_PRUEBA12`, medida en partida el **2026-08-20**. La malla **se deforma con el
`SPIDERRIG`** en vez de deslizarse rígida, y el movimiento se ve natural. Con eso el conducto
de piel —`Weight-NMSMesh` → `Skin-NMSGeometry` → `Check-NMSGraft`— queda **validado en
partida**, no solo en disco, y con él la receta de [`RECETA-PIEL.md`](RECETA-PIEL.md).

**El desempate escrito de antemano acertó.** La prueba llevaba `M-ANIM` y `M-TEX` en el mismo
`.lua`, con la regla «bicho estirado sin forma = la piel; bicho bien plantado con la textura
rara = el normal». Salió lo segundo, así que **una sola entrada al juego cerró una y descartó
la otra** sin volver a entrar.

### Known issues — lo que la `PRUEBA12` deja abierto

| ID | Qué se ve | Qué está medido |
|---|---|---|
| **`M-BABA`** | El bicho se ve **húmedo, como baba**, en vez de hueso y piel | **No es el normal.** El nuestro tiene desviación 17,8 y el vanilla 17,2: el relieve es correcto. El que se sale es el `gMasksMap` — `ATI1` de un canal, media **174** contra los **85** del `FIEND` vanilla |
| **`M-NUCA`** | **La nuca sale con la textura estirada.** De frente, patas y cráneo están bien | Es UV: no hay estirón de malla ni desgarro |

### Added — `HT_CeilingPlague_PRUEBA03`, el nido del techo llama Horrores

Un campo. `MEDIUMHANGSLIME.ENTITY.MBIN` ya venía cableado como un huevo —
`IncreaseFiendCrime = EggDestroyed`, `IncreaseFiendWantedChance 1.0`, `GcShootableComponentData`,
escena `_DESTROYED` propia, locator `SPAWNPOS_` y un `GcAlienPodComponentData` con agro por
movimiento a 8,5 m, linterna a 10 m y disparo a 20 m— y **solo tenía `IncreaseFiendWanted` en
`false`**. Se pone en `true`.

Los Horrores no salen del prop: los suelta el sistema de *fiend wanted* al cometerse el crimen
`EggDestroyed`, que es exactamente como funcionan los huevos del suelo. La explosión se queda
en `INFESTPILLAREXP` a propósito: lo que se mide es si brotan, no cómo se ve el reventón.

**Contiene entera a la `PRUEBA02`**, que ya pasó, y la sustituye — escriben el mismo
`INTERIOR_TENTACLEPLANT.SCENE.MBIN`. Construida con 3 + 1 cambios, 0 errores / 0 warnings /
0 notices, y los dos `.MBIN` verificados por md5 tras desplegar.

⚠️ **Alcance compartido:** el `.ENTITY` lo usa también la infestación de cargueros
abandonados, así que allí romper baba también llamará Horrores. Es deliberado, y es la mitad
de lo que hay que mirar en partida.

⚠️ **Y el archivo lo escribe también `HorribleTerror_Infestation_4-Hardcore`** — las filas
#61 y #62 de [`MODIFICACIONES.md`](MODIFICACIONES.md) §10. Dos mods sobre un MBIN: el segundo
que cargue gana entero y en silencio. Se resolvió **por superconjunto**: la `PRUEBA03` escribe
también `AgroTorch` 12 y `GunfireAgro` 8, y el `diff` contra el MBIN desplegado del Infestation
deja **una sola línea**, la del campo nuevo. Si aun así gana el Infestation, la firma es que el
nido despierte con la linterna pero romperlo no llame Horrores.

### Verificación — `HT_CeilingPlague_PRUEBA02` cerrada de sitio

Medida en partida el **2026-08-20**: el nido queda pegado al techo y la vaina cuelga de
cabeza. **De posición no se toca nada más.** Lo que quedaba —que broten Horrores— lo recoge
la `PRUEBA03` de arriba. El detalle, en [`PENDIENTES.md`](PENDIENTES.md) §2.1.

---

## [0.6.4] — 2026-08-18 · NMS 170671

### Changed — Fácil y Normal, en sincronía con el mod 1 · 2.1.0

**Este mod contiene al mod 1, así que el reequilibrio de Fácil y Normal entra aquí igual.**
Los seis campos y sus valores están en [`CHANGELOG.md`](CHANGELOG.md), entrada `[2.1.0]`;
no se repiten para que no puedan divergir. En corto: Fácil deja de sesgar qué planetas son
hostiles, Normal pasa de la mitad a uno de cada cuatro, y los dos bajan manada, densidad y
tenacidad.

**Los bloques de mundo de este mod no se tocan.** Huevos de Horror y gusanos de arena
siguen con sus multiplicadores; los Fiends de Normal, igual.

### Verificación — la invariante, medida y no supuesta

Construido el mismo día que los cuatro tiers del mod 1, misma AMUMSS 5.6.2.0w, 0 errores /
0 warnings / 0 notices. Conteos de `!# CHANGED`:

| Tier | Mod 1 (2.1.0) | Mod 2 (0.6.4) | Diferencia |
|---|---:|---:|---:|
| Fácil | 10 | 20 | **+10** |
| Normal | 35 | 45 | **+10** |
| Difícil | 40 | 50 | **+10** |
| Hardcore | 61 | 71 | **+10** |

**Los 10 son siempre los mismos**: cinco `FlatDensity` y cinco `SlopeDensity`, el huevo de
Horror y el gusano de arena. Ésa es la comprobación que sustituye a la vieja «suma igual a
Infestation 0.3.3», que dejó de valer cuando la 0.6.1 retiró los huevos de interior y la
0.6.2 devolvió tres campos a vanilla.

### Known — cadena de versión desfasada en las descripciones

`2-Normal` y `1-Facil` pasan a decir **0.6.4**. `3-Dificil` **sigue diciendo `Terror
0.5.0`** en su `MOD_DESCRIPTION` y no se ha tocado en esta pasada: es una cadena vieja, no
un mod viejo. Corregirla exige reconstruir ese tier y no había motivo en esta entrada.

## [0.6.3] — 2026-08-13 · NMS 170671

### Fixed — la banda de ataque vuelve a vanilla, porque el arreglo era peor que el problema

`FIEND`: `NearDist` 1.0 → **6.0** y `FarDist` 3.0 → **10.0**. Se borra el bloque entero del
`.lua`: no escribir el campo *es* dejarlo en vanilla.

**Lo que se vio jugando:** «los fiends me están ignorando completamente, y también sus
hijos». Con el límite lejano en 3 m, el Horror no se comprometía con nada que estuviera más
lejos, y el bicho más agresivo del mod se volvió decorado.

**Es el efecto secundario de 0.6.1.** Aquella versión estrechó la banda a 1/3 para que el
padre no retrocediera al rugir, y el 12/08 se dio por buena: «todo correcto, ya no salen
corriendo». Pasó la prueba que se le puso — **y la prueba estaba mal planteada**: medía si el
padre se alejaba, no si atacaba. Un ✅ solo cubre lo que mira.

Las crías nunca tuvieron la banda tocada (`BUGFIEND` siempre en 6/10, anclado por
`SPECIAL_KEY_WORDS`). Que también parecieran pasivas encaja con que el padre no llegaba a
entrar en combate. **Si tras esto la cría sigue ignorándote, es otro problema.**

Construido con 0 `[ERROR]` / 0 `[WARNING]` / 0 `[NOTICE]`, 71 cambios en 11 MBIN.
Verificado **descompilando el MBIN de `GAMEDATA\MODS`**, no el `.EXML` del build.

> **Trampa de herramienta que costó dos builds fallidos.** AMUMSS llama a `MBINCompiler.exe`
> y a media docena de `.bat` por **ruta relativa**. Si en el entorno está
> `NoDefaultCurrentDirectoryInExePath=1`, `cmd` no busca en el directorio actual, **todas**
> esas llamadas fallan con «no se reconoce como un comando», y el build muere con un
> `attempt to compare nil with number` que no dice nada. Y hay que lanzarlo con **codepage
> 850**: con 65001 AMUMSS se planta en «Bad Active Code Page Detected».

---

## Pruebas in-game — 2026-08-13 · NMS 170671

### ✅ La 0.6.3 se mide entera y pasa — y de paso cae `Q-BICHO`

| ID | Qué se miraba | Veredicto |
|---|---|---|
| `F-BANDA` | Que los Horrores vuelvan a atacar de lejos, no solo si los tocas | ✅ **correcto** |
| `F-CRIAS` | Que las crías también ataquen | ✅ **correcto** |
| `Q-BICHO` | Qué bicho sale de verdad de los nidos del carguero | ✅ **los mini-Fiends** |

**`F-CRIAS` confirma lo que la 0.6.3 apostó.** El changelog de esa versión dejó escrito: «si
tras esto la cría sigue ignorándote, es otro problema». No sigue. La cría parecía pasiva
porque el padre no llegaba a entrar en combate, no porque tuviera nada roto — y el mod nunca
le tocó la banda al `BUGFIEND`, que siempre estuvo en 6/10. **Una hipótesis escrita antes de
la prueba, y que la prueba podía haber tumbado.**

**`Q-BICHO` cierra cuatro pruebas de tinte gastadas pintando un bicho ausente**, pero deja un
fleco: «mini-Fiend» es lo que se ve, no un `CreatureID`. La `CREATUREFILENAMETABLE` dice que
del nido sale `SCUTTLER` —modelo `FREIGHTERFIEND.SCENE`, `MinScale = MaxScale = 1.0`— y que
`MINIFIEND` usa `FIEND.SCENE`. Atar el nombre visto al ID sigue siendo trabajo de
`HT_FiendMarkers_PRUEBA05`.

### ✅ La Etapa 2 de Blender pasa — **hay geometría nuestra dentro de No Man's Sky**

`HT_EggMesh_PRUEBA02`: el obelisco del marker (822 vértices, 1636 triángulos, importado en
FBX) en el sitio del huevo de Fiend. **Sale en el mundo.** No es la ida y vuelta de la
Etapa 1: es una malla que no existía en el juego.

Del huevo se conservaron las tres cosas que no son geometría —el material `EGGSHELL_MAT`, la
`FIENDEGG.ENTITY` (`FIENDHATCH`, `IncreaseFiendWanted`, `Health 125`) y la esfera de colisión
de radio 0.395—, y por eso el mod lo reparte por el mundo **sin escribir ninguna regla
nueva**. Plan y etapas en [`ASSETS.md`](ASSETS.md) §4.3.

### Construido y desplegado, sin medir — la textura propia y la plaga del techo

| ID | Qué hace |
|---|---|
| `HT_EggMesh_PRUEBA03` | La misma malla **con su textura**: `MARKER.BASE.DDS` (BC7 2048² 12 mips) y `MARKER.BASE.NORMAL.DDS` (ATI2/BC5), reapuntando `gDiffuseMap` y `gNormalMap` del `EGGSHELL_MAT` del huevo de superficie, que es un archivo exclusivo suyo |
| `HT_CeilingPlague_PRUEBA01` | El nido colgante del carguero en el techo de los edificios abandonados, **sin tocar ningún `.LSYSTEM`** |

### 🔴 A la malla del obelisco le faltan caras — y la Etapa 2 no estaba tan cerrada

Mirado de cerca en partida el 13/08: **el obelisco está incompleto**. El original en
`asset/Modelos Descomprimidos/` sí lo está — 822 vértices, 830 polígonos, 1636 triángulos.

Lo que reparte el mod se contradice consigo mismo: la cabecera del `.GEOMETRY` declara 1708
vértices y 4908 índices (1636 tris), pero el `StreamMetaData` dice `IndexDataSize 6592` y el
buffer real trae 3294 índices numerados hasta el vértice 821 — **1098 triángulos**. Por eso
NMSDK tampoco puede reimportarlo: lanza `MeshError` e `import_scene.py:464` se lo traga con
un `except ... pass`, así que la escena entra vacía sin decir nada.

**El culpable es la rama de triangulación del exportador** (`addon_script.py:633`): con quads
en la malla —el marker tiene 806— saca los índices del `face_map` de `bmesh.ops.triangulate`
y los reordena con un `sort` que el propio addon documenta como aproximado. Detalle en
[`../BLENDER/README.md`](../BLENDER/README.md) §2b.

### ✅ `HT_EggMesh_PRUEBA04` — el obelisco entero

Triangulada la malla **antes** de exportar (1636 caras, todas de 3 lados), el exportador toma
la rama que copia los índices tal cual y las cuentas cuadran:

| | `PRUEBA03` | `PRUEBA04` |
|---|---:|---:|
| `IndexDataSize` | 6592 B | **9816 B** = 4908 × 2 |
| Triángulos repartidos | 1098 | **1636** |
| `.GEOMETRY.DATA` | 47 713 B | 50 937 B = 129 + 13 664 + 9816 + 27 328 |

**El `.SCENE` no se tocó.** Sigue siendo el vanilla del huevo —con `EGGSHELL_MAT`, la
`FIENDEGG.ENTITY` (`FIENDHATCH`, `Health 125`) y la colisión de radio 0.395— y sus
`BATCHCOUNT 4908` y `VERTRENDGRAPHIC 1707` ya describían la malla entera. Para que encajaran
solo hacía falta que el `IdString` del `.GEOMETRY` volviera a ser `FIENDEGG`: el juego ata el
nodo de malla a su stream por **hash**, y el `1391952726` del nodo tenía que coincidir. Se
consigue nombrando `FiendEgg` al objeto en Blender — con el nombre que trae el FBX salía
`LOW_MARKER`, y el juego no habría encontrado la geometría.

Construido con 0 `[ERROR]` / 0 `[WARNING]` / 0 `[NOTICE]`. Desplegado y verificado por md5.
`PRUEBA02`, `PRUEBA03` y `HT_LocatorTest_PRUEBA01` movidos a `GAMEDATA\MODS_Retirados\`.

**Medido el 13/08: sale entero y con su textura.** Y sale del tamaño de una montaña.

### ✅ `HT_EggMesh_PRUEBA05` — y el obelisco a su tamaño

`ob.scale` valía **0.01**. El exportador escribe `data.vertices[vi].co`, que son coordenadas
**locales**, e ignora la escala del objeto: en Blender el obelisco medía 1,63 m y al juego iba
de **163**.

El `.SCENE` lo decía desde el principio y nadie lo leyó: su AABB va de `0.008757` a
`1.642224`, que son exactamente las coordenadas locales divididas por 100. **El `.SCENE`
describía una malla que el `.GEOMETRY` no contenía** — igual que con los índices, y por el
mismo motivo: el exportador calcula la cabecera de una manera y los buffers de otra.

Aplicada la escala antes de exportar (`transform_apply(scale=True)`, sin tocar la rotación,
que es la que deja el eje alto en Y), la malla mide **1,6335** en local: cuadra con el AABB y
es algo más del doble del huevo vanilla, que mide 0,7615. `tools/Export-NMSMesh.py` ahora la
aplica y **aborta si la malla mide más de 10 en local**.

Construido con 0 `[ERROR]` / 0 `[WARNING]` / 0 `[NOTICE]`, desplegado y verificado por md5.
La `PRUEBA04` se retira a `MODS_Retirados\`.

> **Tres pruebas seguidas para una malla, y cada fallo escondía al siguiente:** primero
> faltaban caras, y sólo al verla entera se pudo ver que era gigante. Las dos veces la
> comprobación que hubiera avisado sin entrar al juego estaba dentro del propio archivo —
> `IndexDataSize` frente a `IndexCount`, y el AABB frente a las coordenadas. Las dos están
> ahora en `Export-NMSMesh.py` como asserts.

### 🏁 La Etapa 2 se cierra — el conducto de Blender está terminado

Medido el 13/08: **el obelisco sale perfecto.** Malla completa, tamaño correcto y las
texturas propias se ven bien. La `PRUEBA05` es la versión buena de la Etapa 2.

Con esto la vía Blender queda cerrada de punta a punta y es **repetible sin criterio
humano**: `tools/Export-NMSMesh.py` hace FBX → triangular → aplicar escala → raíz NMS →
`material_path` → nombre del nodo → export, y aborta si la malla no está triangulada o si se
va de tamaño. Lo que queda del conducto está en
[`../BLENDER/README.md`](../BLENDER/README.md) §3.

**Lo que desbloquea:** `M3`, la segunda malla propia. `ScrullCrawler_max_hd` y
`Necro_partes_7_own_2` son estáticos y entran por aquí; lo único pendiente antes es decimar,
porque pesan 14,3 y 6,1 MB frente a los 822 vértices del marker. Lo que **no** desbloquea es
la criatura propia: NMSDK sigue sin poder exportar pesos de hueso.

### 🔬 Etapa 3 — `HT_ScuttlerMesh_PRUEBA01`: la malla entra en una criatura, y se estira

Primera malla propia en un bicho animado, no en un prop: el SkrullCrawler (9 592 tris) en el
sitio del cuerpo del SCUTTLER de los cargueros. El `.SCENE` es el vanilla injertado —se
conservan los **114 nodos `JOINT`**, las colisiones, las luces, `FFIENDMAT` y el `ATTACHMENT`
con la `FREIGHTERFIEND.ENTITY`—, cambiando sólo los 17 atributos que describen la malla y
borrando el nodo del ojo, que se habría quedado sin stream.

**Medido el 13/08:** el bicho sale, se mueve y **sigue atacando** — la geometría entra y la
entidad funciona. Pero la malla **se estira sin forma** siguiendo el movimiento.

Eso contesta la pregunta que se le puso, y con más precisión de la que se esperaba: **el
juego sí aplica el skinning.** No es que ignore los huesos y pinte la malla rígida; es que
transforma cada vértice por una matriz de hueso, y como nuestra geometría no trae los
`SemanticID` 5 y 6 —índices y pesos— cada vértice recibe una que no le corresponde.

| | Vanilla `FREIGHTERFIEND` | Nuestra exportación |
|---|---|---|
| `VertexLayout` | `0` pos · `1` UV · `2` normal · `3` tangente · **`5` índices de hueso** · **`6` pesos** | `0` · `1` · `2` · `3` |

Descartado el desenlace bueno, queda uno intermedio que la `PRUEBA02` prueba: **quitarle al
material la bandera `_F02_SKINNED`**, que es la que enciende ese camino en el shader. Sin
ella, la malla debería pintarse con la transformación del nodo y ya — rígida, pero entera.

> **Trampa al editar un `.MATERIAL`:** borrar el `MaterialFlag` de dentro deja el contenedor
> `TkMaterialFlags` vacío, y **MBINCompiler lo rellena con un valor por defecto** — salió la
> lista con `_F01_DIFFUSEMAP` duplicado. Hay que borrar el contenedor entero y renumerar los
> `_index`. Se cazó verificando el `.MBIN` construido, no en partida.

### 🏁 `HT_ScuttlerMesh_PRUEBA02` — hay criaturas propias en el mod

**Medido el 13/08: sale entero y rígido.** Quitar `_F02_SKINNED` del material apaga el camino
que deformaba la malla, y el SkrullCrawler aparece con su volumen, se mueve por el mundo con
la animación de la raíz y sigue atacando. Captura en
`asset/Errores/modelo_scruttler_.jpg`.

**Lo que esto abre.** Se pueden sustituir criaturas por modelos propios. Lo que se pierde es
la deformación: el bicho no dobla las patas al andar, se desplaza entero. A cambio conserva
comportamiento, colisión, IA y sonido, porque el `.SCENE` sigue siendo el vanilla.

**Lo que no arregla.** Los pesos de hueso siguen sin poder escribirse; esto los rodea, no los
resuelve. Una criatura que dependa de doblarse para leerse bien —un bípedo andando— se va a
notar más rara que un bicho que repta.

### `HT_ScuttlerMesh_PRUEBA03` y `PRUEBA04` — la orientación, y una lección de método

La `PRUEBA02` salía **de pie pero mirando al lado contrario**. Se leyó como «al revés» y se
le dieron 180° en **X** — que no gira el bicho, lo **tumba**: la `PRUEBA03` salió patas
arriba. El giro bueno es **−90 en X** (de Z-arriba a Y-arriba) **+ 180 en Y** para la media
vuelta. Es la `PRUEBA04`.

**Lo que cambió el método:** en vez de averiguarlo con un tercer viaje al carguero, se
renderizaron las tres candidatas en Blender headless, mirándolas ya en ejes de NMS. Un
vistazo descartó dos. Hasta entonces cada intento de orientación costaba construir,
desplegar, reiniciar, volar a un carguero y provocar un nido.

> **Dos verificaciones que ya no se saltan**, porque las dos han cazado algo hoy: el md5 del
> `.GEOMETRY.DATA` **tiene que cambiar** entre versiones —si no, se construyó lo mismo— y la
> orientación se mira en un render antes de construir.

### 🔴 `HT_ScuttlerMesh_PRUEBA05` — matar uno tiraba el juego

Con la `PRUEBA04` el bicho salía entero, rígido y bien orientado. **Al destruir uno, crash**
—diálogo «Desactivar mods», incidencia `170671M_0x16F9CB7`—, y con el nido reventado había
unos cuantos a los que disparar.

El momento lo delataba: sólo al morir. La `FREIGHTERFIEND.ENTITY` trae
**`GcRagdollComponentData`** y **`GcEasyRagdollSetUpData`**, y el ragdoll recorre los huesos.
El `.SCENE` conserva los **114 nodos `JOINT`** del vanilla; el `.GEOMETRY` es nuestro, y
NMSDK **no escribe los arrays por hueso**:

| | Vanilla | Nuestra exportación |
|---|---:|---:|
| `JointExtents` | 115 | **vacío** |
| `JointMirrorPairs` | 115 | **vacío** |
| `SkinMatrixLayout` | 23 | vacío |

114 huesos buscando su extensión en un array de cero entradas. Devueltos los dos arrays del
vanilla —**son datos por hueso, no por malla**, y los huesos son los suyos sin tocar, así que
se corresponden uno a uno—, el `.GEOMETRY` pasa de 4 214 a 10 188 bytes.

**`SkinMatrixLayout` y `MeshBaseSkinMat` no se copian**: esos sí describen cómo se reparte
una malla concreta sobre los huesos, y la nuestra no es la de ellos. Copiarlos sería volver
al problema del que nos sacó quitar `_F02_SKINNED`.

> **Lo que enseña este fallo:** injertar en un `.SCENE` vanilla no es sólo cuadrar las
> cuentas de la malla. Todo lo que el vanilla conserva —huesos, entidad, ragdoll— sigue
> esperando encontrar sus datos en **nuestro** `.GEOMETRY`. Lo que no exporta NMSDK hay que
> devolverlo a mano.

### 🏁 `HT_ScuttlerMesh_PRUEBA06` — el injerto aguanta la muerte. Cierra la Etapa 3

**Pasó el 2026-08-14.** El SkrullCrawler sale entero y **matar SCUTTLERs ya no tira el
juego**. Con esto hay criaturas propias en el mod de punta a punta: aparecen, se comportan
como el vanilla y se mueren sin llevarse la partida.

Lo que faltaba no eran dos arrays, eran **cinco**. La `PRUEBA05` devolvió `JointExtents` y
`JointMirrorPairs` y seguía cerrando:

| Va **por hueso** — se copia del vanilla | Va **por malla** — se calcula de la nuestra |
|---|---|
| `JointBindings`, `JointExtents`, `JointMirrorAxes`, `JointMirrorPairs` — 115 cada uno | `MeshBaseSkinMat`, del `FIRSTSKINMAT` de nuestro nodo |

`SkinMatrixLayout` se queda **vacío a propósito**: el nodo lo pide de `FIRSTSKINMAT` 0 a
`LASTSKINMAT` 0, que es un rango vacío y no lee nada. El `.GEOMETRY` pasa de 10 188 a
27 212 bytes.

**Lo que cambió el método:** dos herramientas nuevas, las dos sin entrar al juego.
`tools/Patch-NMSGraft.py` devuelve los arrays, y `tools/Check-NMSGraft.py` cruza cada índice
del `.SCENE` contra la longitud del array que lo recibe — pasa con el vanilla intacto y
fallaba con la `PRUEBA05`, que es lo que la hace valer. Rellenarlos de uno en uno, según iba
crasheando, había costado dos sesiones de juego.

> 🔴 **La primera lectura de esta prueba fue falsa, y la trampa vale más que la prueba.** El
> crash de la `PRUEBA05` sacó el diálogo «Desactivar mods», que escribe `DisableAllMods=true`
> en `Binaries\SETTINGS\GCMODSETTINGS.MXML`. La sesión siguiente corrió **sin un solo mod**:
> salió el SCUTTLER vanilla, no crasheó, y parecía que la prueba había pasado. Los 93 mods
> seguían en `Enabled=true` — lo cortado era el interruptor general, así que daba igual
> arrancar por Steam o por Vortex. Queda como cuarta trampa en [`README.md`](README.md).

> **El injerto ya no lleva números a mano.** `patch_scene.py` lee las cuentas y el AABB de
> nuestra escena exportada en vez de tenerlos escritos: cada reexportación los cambia, y
> copiarlos era pedir un error de los que no avisan.

**Tres cosas que ninguna herramienta dijo, y que valen para la próxima malla:**
el `IdString` del `.GEOMETRY` sale del **nombre del objeto en Blender**, y el juego ata nodo y
stream por su hash — si se entrega un `.SCENE` vanilla, el objeto tiene que llamarse como su
nodo de malla · el exportador escribe coordenadas **locales**, así que la escala hay que
aplicarla · con quads, los índices salen incompletos.

> **Tres trampas de NMSDK que costaron la tarde**, ninguna con mensaje de error:
> sus paneles llevan `bl_context = 'objectmode'`, así que **en modo edición la pestaña NMSDK
> desaparece** · `Create empty NMSDK scene` **no tiene botón** en ningún panel, solo sale por
> `F3` · y sin esa raíz el export escribe una escena con `Children` vacío y `VertexCount 0`
> sin quejarse. El export bueno se acabó haciendo con Blender en headless.

**Lo que esto cambia del 12/08.** «Hay geometría nuestra dentro de No Man's Sky» sigue siendo
cierto, y sigue siendo el hito. Lo que no vale es el «quedó perfecto»: la prueba miró si la
malla aparecía, no si aparecía entera. Van dos veces que un ✅ cubre menos de lo que parecía.

Construidos con 0 `[ERROR]` / 0 `[WARNING]` / 0 `[NOTICE]`: 2 cambios y 5 archivos añadidos
en la `PRUEBA03`, 1 cambio en la plaga. Ya están en `GAMEDATA\MODS` y el md5 del `.MBIN`
desplegado coincide con el de `ModBackups`. Falta **quitar `HT_EggMesh_PRUEBA02` y
`HT_LocatorTest_PRUEBA01`**, que escriben encima de cada uno.

> **`BUILDMOD_AUTO.bat` ya no pregunta nada.** Las seis opciones que estaban en `ASK`
> —`DEV_MODE`, `GameVersion`, `CombineModPak`, `CopyToGamefolder`, `UseExtraFilesInPAK`,
> `UseLuaScriptInPak`— tienen valor fijo, así que el build corre sin consola interactiva. Con
> `CopyToGamefolder N` **no despliega**, que es lo que queremos: desplegar es un paso aparte.
> Sigue exigiendo **codepage 850** y un `PATH` de Windows de verdad — lanzado desde el `PATH`
> estilo POSIX de Git Bash, AMUMSS aborta con «Your System Path is missing important system
> paths».

**`tools/Make-NMSTexture.py` ahora produce también ATI2/BC5**, que es el formato de normales
y máscaras. Elige codificador leyendo el `fourcc` del `.DDS` vanilla de referencia. El orden
de canales no se adivinó: Pillow decodifica `FIEND.BASE.NORMAL.DDS` vanilla como
`R≈126 G≈127 B=0`, o sea primer bloque X, segundo Y. Nuestro decodificador coincide con
Pillow con error máximo **0,86 sobre 255**, y los dos archivos generados pesan **exactamente
lo mismo que sus donantes vanilla**.

Sin mapa de máscaras a propósito: el vanilla del huevo mide `R` media 179 y `G` media 73, que
no cuadra con la convención «R = metalicidad» que circula, así que **no sabemos qué canal es
qué**. Queda como `Q-MASCARAS` en [`PENDIENTES.md`](PENDIENTES.md) §3.

### 🔴 El tentáculo del techo no tiene malla — y eso desatasca la vía 5

Descompilado `INTERIOR_TENTACLEPLANT.SCENE.MBIN`: **cero nodos `MESH`.** Es un envoltorio con
un `LOCATOR` y dentro un nodo `REFERENCE` que apunta por `SCENEGRAPH` a
`TENTACLEPLANT.SCENE.MBIN`, **girado 180° en Z** para colgar boca abajo.

Eso da una puerta que no pasa por el `.LSYSTEM` —cambiar ese `SCENEGRAPH` cuelga otra cosa
del techo, un solo valor— y de paso explica el fallo de 0.3.2: al sustituir el `Model` desde
el `.LSYSTEM` se tira el envoltorio **y con él la compensación de giro**, así que el huevo se
colocaba metido en el techo. `[Inferencia]`

El candidato es `MEDIUMHANGSLIME`, el nido colgante del carguero, que trae
`GcDestructableComponentData` (Health 600, `INFESTPILLAREXP`, `DE_FATSLIME`),
`GcAlienPodComponentData` y `GcScannableComponentData` — y cuya `.ENTITY` **ya la retoca
nuestro `Infestation`**, así que hereda gratis `AgroTorch` y `GunfireAgro`. Detalle en
[`ASSETS.md`](ASSETS.md) §5.7.

### 🔴 Al Fiend no se le puede hacer lo mismo que al huevo

Contado sobre los `.SCENE` descompilados: el huevo tiene **0** nodos `JOINT`, `FIEND` tiene
**44** y `TENTACLEPLANT` **13**. NMSDK no exporta pesos de hueso —verbatim en su propia
documentación—, así que una malla nuestra sobre un esqueleto de 44 huesos sale sin pesar.

Lo que sí: repintarlo (vía 1, ya hecho en `NecroSkin`), teñirlo (`gMaterialColourVec4`) y
podar el descriptor del `BUGFIEND`. Cambiarle la silueta, no. El camino que sí escala es
poner **mallas nuestras alrededor** del bicho, que es lo que la Etapa 2 acaba de abrir.
Detalle en [`ASSETS.md`](ASSETS.md) §4.2.

### ✅ La Etapa 1 de Blender pasa — NMSDK sirve

`HT_EggMesh_PRUEBA01`: `FIENDEGG.SCENE.MBIN` importado a Blender con NMSDK
`0.10.0-alpha13`, re-exportado **sin tocar un vértice** y entregado con `ADD_FILES` +
`EXTERNAL_FILE_SOURCE`. **El huevo sale igual que siempre.**

Cierra dos incógnitas de una: el formato que produce NMSDK (soporte declarado 6.2X) **carga
en NMS 6.45**, y la ida y vuelta **no daña la geometría ni la escala**. Es la puerta que
decidía si merecía la pena aprender a modelar. Plan y siguientes etapas en
[`ASSETS.md`](ASSETS.md) §4.3.

---

## Pruebas in-game — 2026-08-12 · NMS 170671

Tres pasan, y la cuarta da un dato mejor que un ✅.

| Qué se miraba | Veredicto |
|---|---|
| Que el padre **no retroceda** al rugir (0.6.1) | ✅ pasa — **y ver 0.6.3: la prueba no cubría si atacaba** |
| La puerta de «seguridad adicional» y que el juego cierre (`HT_DerelictBugs_PRUEBA02`, solo `BARR`) | ✅ pasa. Siguiente: devolver `CARG` y `MEDI` de a una |
| `HT_PredatorParts_PRUEBA03` — podar el descriptor | ✅ pasa. Solo salieron cabezas de reptil/lagarto, cero mallas rotas. **`_HEAD_` de 8 a 2 se ve en pantalla** |
| El Horror **grande** del carguero, rojo entero | 🔶 no se pudo medir, y por qué no se pudo es el hallazgo |

### 🔴 El hallazgo: el Horror grande no existe donde lo buscábamos

Lo que dijo el usuario: «el Horror grande **no sale**; el que se pintó como rojo es el que
spawnea cuando se rompe el nido. En todos los cargueros solo salen los pequeños».

`METADATA\SIMULATION\ECOSYSTEM\CREATUREFILENAMETABLE.MBIN` lo contesta sin jugar:

| `CreatureID` | Modelo |
|---|---|
| `FIEND` **y** `MINIFIEND` | `SPIDERRIG/FIEND.SCENE.MBIN` — comparten modelo |
| **`SCUTTLER`** | **`SPIDERRIG/FREIGHTERFIEND.SCENE.MBIN`** |
| **`SCUTTLER_PET`** | **`SPIDERRIG/MINIFIEND_PET.SCENE.MBIN`** |

1. `MINIFIEND_PET.SCENE` es de `SCUTTLER_PET`, **la mascota domesticada**. No pisa un
   carguero: el azul nunca falló, **no había a quién pintárselo**.
2. El del nido es `SCUTTLER`, con el modelo que pintamos de rojo. El «sale rojo» **era
   nuestro tinte funcionando**, no la alarma.
3. **No existe `CreatureID` `FREIGHTERFIEND`**, y `SCUTTLER` va a `MinScale = MaxScale = 1.0`:
   no hay un «Horror grande» aparte.

**Regla:** antes de pintar un bicho, mirar `CREATUREFILENAMETABLE`. El nombre del archivo de
modelo **no** dice qué criatura lo usa. Cuatro pruebas de tinte se gastaron por saltárselo.

### La lección del despliegue: el `.EXML` del build no verifica nada

El `README` de `derelict` mandaba comprobar que en el `.EXML` del build **no apareciera**
cierto ID. Dos cosas estaban mal: ese `.EXML` es un **informe** con marcas `!# CHANGED`, así
que lo que no se toca no sale ahí jamás y la comprobación se cumple sola; y los IDs existen
en vanilla, así que buscarlos en la tabla real acierta con el mod bien y con el mod mal.

La comprobación buena es **contar contra el vanilla extraído con `hgpaktool`**. Así cuadró:
`R_BUG_BARR` 10 → 26 y `R_S_BUG_BARR` 6 → 14, los 24 cambios.

**Regla:** una verificación que no puede fallar no es una verificación.

---

## Pruebas in-game — 2026-08-11 · NMS 170671

No es una versión: **es la sesión que midió lo desplegado.** Se jugó con
`HorribleTerror_Infestation_4-Hardcore` 0.5.0 más los cuatro mods de prueba. Lista completa
y siguientes pasos en [`PENDIENTES.md`](PENDIENTES.md).

### Lo que pasa

| Bloque | Versión | Veredicto |
|---|---|---|
| Crías `BUGFIEND` con las armas del padre (3/6 · 1.2 · anim ×1.2) | 0.3.3 | ✅ |
| Que la cría **no** para | 0.3.3 | ✅ ninguna cría vista pariendo |
| No sueltan la presa — los 10 campos | 0.3.1 §2 | ✅ |
| Movimiento: sin acechar, derechos, en horda, árbol `MELEE` | 0.3.1 §3 | ✅ |
| **Rendimiento** con `SteeringUpdateRate` 0.10 y huevos ×20 | 0.3.1 §3.5 | ✅ **no hay caída** |
| `SCUTTLER_PET` intacta | 0.3.1 §4.2 | ✅ el ancla protege a la mascota |
| Que escapar siga siendo posible | 0.3.1 §4.3 | ✅ en Difícil y en Hardcore |

**3.5 era la única prueba que podía obligar a revertir algo por sí sola.** Pasa: los diez
campos de 0.3.1 y los cuatro de 0.3.3 se quedan, y con ellos las dos versiones enteras.

### 🎉 El verde cierra dos preguntas de una vez

Las crías del rugido salieron **verde ácido**, el color que `HT_FiendMarkers_PRUEBA01`
reserva a `BUGFIEND`:

| Pregunta | Respuesta |
|---|---|
| ¿`gMaterialColourVec4` tiñe criaturas **in-game**? | **Sí.** Estaba dado por bueno desde el 09/08 descompilando, sin jugarlo nunca |
| ¿El brood engendra `BUGFIEND` o simplemente más `FIEND`? | **`BUGFIEND`** |

Lo segundo es lo que importa: **sin el verde, los cuatro campos de 0.3.3 eran una impresión.**
Con él, 0.3.3 mide lo que dice medir.

### ✅ La textura funciona — el blanco del 09/08 está resuelto

`HorribleTerror_NecroSkin` pinta el `FIEND` con su imagen, como se quería. Los tres candidatos
que se abrieron el 09/08 (sin mipmaps, cabecera DX10/BC7, paleta de recoloreado) **no hicieron
falta**: `tools/Make-NMSTexture.py` produce un `.DDS` válido y `ADD_FILES` lo entrega bien.

Consecuencia para [`ASSETS.md`](ASSETS.md) §4.3: la mitad «cómo se entrega» de la vía
Blender está probada de verdad, no supuesta.

⚠️ Se cae de rebote la nota del README de `marcadores` que daba el blanco del `FIEND` por su
marca de color. Ya no sale blanco; lo distingue la textura.

### ❌ Retirado — los huevos dentro de los edificios abandonados (0.3.2)

**No funciona, y ya no es «prueba incompleta»: es fallo confirmado con la causa acotada.**

Dentro del edificio **la planta que colgaba del techo ya no está y el huevo tampoco**.

**Que la planta desaparezca es lo que convierte esto en información.** Demuestra que el mod
está activo, que el locator `TENTACLE_` se resuelve y que el `Model` se escribió. El fallo no
está en la regla —verificada en el MXML construido, cinco reglas con `Probability 100`— sino
en la **escena**: `FIENDEGG.SCENE` vive en `RARERESOURCE\GROUND\` y es un asset de superficie
planetaria.

[`ASSETS.md`](ASSETS.md) §5.2 lo eligió sobre la variante `SPACEBASE` por tener «cero
incógnitas de contexto». **Era justo al revés**, y ésa es la lección de la entrada.

Segundo intento planificado en [`PENDIENTES.md`](PENDIENTES.md) §N1, con un control primero:
colgar del mismo locator un modelo que ese archivo ya usa (`DEBRISLARGE_COMMON`) antes de
probar el huevo de interior. Sin el control, un segundo «no sale» volvería a ser ambiguo.

> **Esto bloquea la Etapa 1 de Blender**, que usa el mismo locator como banco de pruebas del
> cubo. Si el cubo no saliera hoy, no sabríamos si falló NMSDK o falló el conducto.

### Abierto por esta sesión

| Qué | Dónde |
|---|---|
| **El padre se aleja cuando ruge** y salen las crías; después vuelve. Se quiere que no se vaya | `PENDIENTES.md` §N2. Palanca candidata: `NearDist` 6 / `FarDist` 10 del `GcCreatureFiendAttackData`, que el mod nunca ha tocado |
| **Puerta de carguero** que la terminal desbloquea pero no deja cruzar, con una cuenta de «seguridad» subiendo | `PENDIENTES.md` §N3. Nada nuestro toca puertas, pero `FreighterDespawnDist` 150 y `MaxFiendsToSpawn` 16 podrían impedir que una sala se considere limpia |

---

## [0.5.0] — 2026-08-09

**Revierte el reparto de 0.4.0: el mod 2 vuelve a contener al mod 1.** Ni un valor cambia
respecto a 0.3.3 — los cuatro tiers vuelven a dar **23 / 45 / 50 / 101**, que es la prueba.

### La decisión, y por qué

0.4.0 separó los mods **por tipo de campo**: conducta al mod 1, colocación al mod 2. Se
construyó, se verificó, se desplegó… y el criterio era el equivocado.

**Lo que tiene que diferenciar a los dos mods son los modelos de los monstruos, no el tipo de
campo.** La conducta la comparten por definición: el mod 2 es el mod completo y el mod 1 es la
puerta de entrada para quien solo quiera dificultad.

| | Mod 1 · `HorribleTerror_Predators` 2.0.0 | Mod 2 · `HorribleTerror_Infestation` 0.5.0 |
|---|---|---|
| Qué es | la conducta sola | conducta + mundo + **modelos propios (lo que viene)** |
| Rutas | 7 | 12 |
| Instalado | **no** | **sí** |

Se instala uno **o** el otro. `HorribleTerror_Predators` se retiró de `GAMEDATA\MODS`.

### Cómo se compone ahora

Mod 2 = **bloques del mod 1 + bloques de mundo**. Los de conducta son los mismos archivos
fuente; si se cambia un valor en el tier del mod 1 hay que recomponer aquí. **El conteo lo
delata:** mod 2 = mod 1 + 10, y + 40 en Hardcore.

| Tier | Mod 1 | Mundo | Mod 2 | 0.3.3 |
|---|---:|---:|---:|---:|
| Fácil | 13 | 10 | **23** | 23 |
| Normal | 35 | 10 | **45** | 45 |
| Difícil | 40 | 10 | **50** | 50 |
| Hardcore | 61 | 40 | **101** | 101 |

### Desplegado y verificado

Construido contra NMS **170671**, MBINCompiler 6.45.0.1, 0 errores. Desplegado y comprobado
**descompilando el MBIN de `GAMEDATA\MODS`**: `SpawnBroodID = BUGFIENDS`,
`FiendAggroDecreasePerSpawn` 0.0, `FiendBeingShotMemoryTime` 60, `FiendMinSpawnTime` 0.1 y
`FlatDensity` 0.1 en los huevos. Conducta y mundo en el mismo mod.

### ⚠️ Trampa nueva del despliegue

**`ModBackups` deja `GCCREATUREGLOBALS.MBIN` y `GCUIGLOBALS.GLOBAL.MBIN` en la raíz de la
carpeta del mod, no en `GLOBALS\`.** Copiados tal cual, el juego los ignora y se pierde media
conducta **sin ningún error ni aviso**. Hay que moverlos a `GLOBALS\` al desplegar. El
despliegue viejo funcionaba porque tenía las dos copias, la buena y la muerta.

### Bug de composición que costó una build

Al recomponer los tiers por concatenación, recortar un bloque buscando `"        },"` (8
espacios) también casa **dentro** de `"            },"` (12), así que el corte cayó a media
regla. Hardcore salió con 3 errores de sintaxis Lua (`unexpected symbol near '}'`, línea 412)
y **no se construyó**. Se arregló componiendo con los bloques de mundo literales en vez de
cirugía de cadenas.

### Sonda de `ReferencePaths` — retirada de esta versión

Iba en 0.4.0 y no aterrizaba (ver el README de la carpeta). **No está en 0.5.0**, y es lo
correcto: escribía `TREX.DESCRIPTOR.MBIN` idéntico a vanilla, lo que habría pisado en silencio
a `HT_PredatorParts_PRUEBA01`, que escribe el mismo archivo.

## [0.4.0] — 2026-08-09

**El reparto entre los dos mods cambia de eje.** No hay ni un valor nuevo: lo que hay es una
mudanza, y el conteo lo prueba.

### Por qué

Hasta 0.3.3 el reparto era **por bicho** — mod 1 los depredadores, mod 2 los depredadores
**más** los Fiends. Eso tenía dos costes: el mod 2 contenía al mod 1, así que **había que
instalar uno o el otro**, y cada mejora de conducta de un Fiend había que decidir en cuál de
los dos iba.

El eje nuevo es **por tipo de cambio**:

| | Mod 1 · `HorribleTerror_Predators` 2.0.0 | Mod 2 · `HorribleTerror_Infestation` 0.4.0 |
|---|---|---|
| Qué manda | conducta y agresividad de **todos** los bichos | **dónde** aparecen, cuántos, y cómo se ven |
| Rutas | 7 | 3 |

**No comparten ni un archivo, así que ahora se instalan los dos a la vez.** Eso era
imposible antes.

### Se muda al mod 1 — todo lo de conducta

`GCCREATUREGLOBALS` (presión, percepción, eclosión, sin-acecho, steering, horda, tenacidad,
distancias de carguero), `CREATUREDATATABLE` (`FIEND` + `BUGFIEND` + brood),
`CREATUREBEHAVIOURTREES` (árbol `MELEE`), `GCUIGLOBALS` (marcador de depredador) y los dos
`*SLIME.ENTITY` (el nido que reacciona a la linterna y a los disparos).

El nido de carguero se va al mod 1 aunque sea una pieza de edificio: lo que cambia es su
**agresividad**, no dónde está.

### Se queda aquí — colocación en el mundo

`FIENDEGGS`, `INFESTATION` y las tres `ABANDONDED*.LSYSTEM` (huevos dentro de los edificios,
solo Hardcore).

### ⚠️ Incompatible para quien tenga solo el mod 2

Quien tenga Infestation instalado y no el mod 1 **pierde toda la conducta**: brood, tenacidad,
sin-acecho, crías, marcadores. Hay que instalar los dos. Va en la primera línea de las dos
páginas de Nexus.

### Verificación — la suma tiene que cuadrar

Construido contra NMS **170671**, MBINCompiler 6.45.0.1, **0 errores en los ocho**:

| Tier | Mod 1 | Mod 2 | Suma | 0.3.3 |
|---|---:|---:|---:|---:|
| Fácil | 13 | 10 | **23** | 23 |
| Normal | 35 | 10 | **45** | 45 |
| Difícil | 40 | 10 | **50** | 50 |
| Hardcore | 61 | 40 | **101** | 101 |

**Que las cuatro sumas coincidan con los totales de 0.3.3 es la prueba de que la mudanza no
perdió ni duplicó un solo campo.** Es la comprobación que sustituye a «compara el delta a
mano» en un cambio que toca ocho archivos a la vez.

### Sin desplegar

Construido y verificado, **no copiado a `GAMEDATA\MODS`**. Construir no es desplegar.

## [0.3.3] — 2026-08-09

Construido y desplegado contra NMS **170671**, MBINCompiler 6.45.0.1. **Solo cambia
Hardcore**: 97 → **101** cambios, 0 errores. Fácil, Normal y Difícil salen otra vez
idénticos (23 / 45 / 50).

Versión pequeña con una noticia grande detrás: **el brood de 0.3.1 funciona**, y probarlo
destapó que estaba a medias.

### 🎉 Confirmado — `AllowSpawnBrood` funciona

Lo que se vio jugando: rompes un huevo, salen los Horrores, y **al rugir llaman a una
segunda tanda** que no salió del huevo. Es el brood de 0.3.1, que llevaba desde el 05/08
marcado `[SIN PROBAR]` y era **el primer candidato a revertir** por no tener respaldo
vanilla fuera de `BUGQUEEN`.

Cierra tres preguntas abiertas desde [`COMPORTAMIENTO.md`](COMPORTAMIENTO.md) §3:

| Pregunta | Respuesta |
|---|---|
| ¿`SpawnBroodID = BUGFIENDS` resuelve fuera del contexto de `BUGQUEEN`? | **Sí.** Es un identificador de grupo global |
| ¿Hacía falta `SpawnBroodAnim = BIRTHING`? | **No.** `ROAR` —lo que el `FIEND` ya traía— dispara el parto igual |
| ¿`AllowSpawnBrood` necesita compañía, como `AllowPushBackAttack` necesita su frame? | **No.** Booleano + ID + timer y ya |

### Changed — las crías pegan como sus padres

**El fallo que destapó la prueba:** las crías del brood no son `FIEND`, son **`BUGFIEND`**,
otra entrada del mismo `CREATUREDATATABLE`. Todo lo que 0.2.0 subió estaba anclado a
`{"Id","FIEND"}`, así que la segunda oleada llegaba con estadísticas **de vanilla**:

| Campo | Padre (`FIEND`) | Cría (`BUGFIEND`) hasta 0.3.2 | Cría desde 0.3.3 |
|---|---:|---:|---:|
| `MinFlurryHits` / `MaxFlurryHits` | 3 / 6 | 2 / 4 | **3 / 6** |
| `DelayBetweenPounceAttacks` | 1.2 | 2.0 | **1.2** |
| `AnimSpeedModifier` | 1.2 | 1.0 | **1.2** |

Cuatro cambios nuevos, el patrón anclado de siempre pero con `{"Id","BUGFIEND"}`.

### Deliberadamente NO hecho — el brood de la cría

`AllowSpawnBrood` **no** se copia a `BUGFIEND`. Si la cría pariese, cada parto añadiría
paridoras: crecimiento exponencial **sin techo conocido**, porque `MaxFiendsToSpawn` (16)
limita la eclosión del huevo, no el brood. La oleada se queda en dos escalones —
huevo → `FIEND` → `BUGFIEND`— y ahí para.

### Por qué solo Hardcore

El brood es exclusivo de Hardcore, así que en Normal y Difícil **no hay crías que igualar**.
Se llegó a escribir la regla en los tres tiers y se retiró de dos: allí solo habría tocado
`BUGFIEND` salvajes que nadie pidió, y habría obligado a re-verificar y re-publicar dos
tiers congelados desde 0.2.0.

### Conteo

| Tier | gen | med | large | globals | lsystem ×3 | nidos ×2 | uigl | árbol | **datatable** | eggs | infest | Total |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 4 Hardcore | 5 | 2 | 2 | 34 | 10+10+10 | 2+2 | 1 | 2 | **11** | 4 | 6 | **101** |

Los 11 de `datatable` son 4 de `FIEND` + 3 del brood + **4 de `BUGFIEND`**.

**Verificado descompilando desde `GAMEDATA\MODS`**, no desde el delta: `FIEND` con 3/6 ·
1.2 · brood activo, `BUGFIEND` con 3/6 · 1.2 · **brood en `false`**, y `SCUTTLER_PET`
intacta en vanilla (2/4 · 2.0 · 1.0) — el ancla protege a la mascota del jugador con dos
dueños igual que con uno.

### Sin probar

Los cuatro campos de `BUGFIEND`. Save respaldado:
`NMS_saves_2026-08-09_1415_antes-033-crias-bugfiend`.

**Cómo se comprueba:** hace falta ver la segunda oleada, no la primera. Romper un huevo,
dejar que los Horrores rujan, y mirar a las crías: deberían encadenar 3-6 golpes en vez de
2-4 y saltar a casi el doble de ritmo. Si se ve alguna cría pariendo a su vez, algo se coló
y hay que revertir ya.

---

## [0.3.2] — 2026-08-07

Construido contra NMS **170671**, MBINCompiler 6.45.0.1. **Solo cambia Hardcore**: Fácil,
Normal y Difícil salen idénticos (23 / 45 / 50). Hardcore pasa de **60 a 97** cambios,
0 errores. Es la primera versión que toca **geometría del mundo** en vez de solo números.

### Added — los Horrores anidan dentro de los edificios abandonados

**Décima ruta, y la primera fuera de `METADATA` y `GLOBALS`:**

```
MODELS\PLANETS\BIOMES\COMMON\BUILDINGS\ABANDONED\ABANDONDEDSCIENTIFIC.LSYSTEM.MBIN
                                                \ABANDONDEDTRADER.LSYSTEM.MBIN
                                                \ABANDONDEDWARRIOR.LSYSTEM.MBIN
```

(el typo `ABANDONDED` es de Hello Games). Los edificios abandonados **no son modelos
fijos**: son L-systems que cuelgan props de *locators* con una probabilidad. Los tres
traen un locator **`TENTACLE_`** —hueco de bicho orgánico colgado— con
`INTERIOR_TENTACLEPLANT` al 30 %, cinco veces por edificio.

Ese modelo pasa a ser `RARERESOURCE\GROUND\FIENDEGG.SCENE.MBIN` y la probabilidad sube a
100. Resultado: **hasta 5 huevos por edificio abandonado, siempre.**

**Por qué esto funciona sin escribir nada de spawn:** el huevo **no invoca criaturas**. Su
entidad solo declara `Explosion = FIENDHATCH` e `IncreaseFiendCrime = EggDestroyed`; quién
sale, cuántos y cuándo lo decide el sistema global de `GCCREATUREGLOBALS`. Es decir, el
spawn de Horrores es **global, no local**, y un huevo puesto en cualquier sitio hereda
gratis los diez campos que 0.3.1 ya subió. Detalle en [`ASSETS.md`](ASSETS.md) §5.4.

### Added — los nidos del carguero reaccionan a la linterna y a los disparos

**Undécima ruta:** `…\SPACEBASE\INFESTATION\{LARGEPILLARSLIME,MEDIUMHANGSLIME}\ENTITIES\*.ENTITY.MBIN`.

Los nidos de los cargueros abandonados llevan un componente que no habíamos visto nunca,
**`GcAlienPodComponentData`**, con la mecánica de «el nido te huele»:

| Campo | Vanilla | 0.3.2 | Qué hace |
|---|---:|---:|---|
| `AgroMovement` / `Range` | 11.0 / 8.5 | — | te detecta por moverte cerca |
| **`AgroTorch`** | **0.0** | **12.0** | apuntar con la linterna lo despierta |
| **`GunfireAgro`** | **0.0** | **8.0** | disparar cerca lo despierta |

Los dos que subimos estaban **a cero: interruptores implementados y apagados por Hello
Games**, igual que `AllowSpawnBrood`. `AgroThreshold` (15) y `AgroRate` (−5) se dejan
quietos, así que la escala de los valores nuevos es **inferencia sin confirmar**.

### Added — los Horrores de interior salen antes y aguantan más

En `GCCREATUREGLOBALS`, tres campos que el mod nunca había tocado:

| Campo | Vanilla | 0.3.2 |
|---|---:|---:|
| `FreighterSpawnDist` | 30 | **60** |
| `FreighterDespawnDist` | 50 | **150** |
| `FiendSpawnDistance` | 70 | **120** |

Los dos primeros son **específicos de interiores de carguero** y viven pegados al bloque
`Indoor*`, no al de Fiend — por eso no aparecieron en los barridos anteriores.

### Conteo

| Tier | gen | med | large | globals | uigl | árbol | datatable | eggs | infest | **lsystem** | **nidos** | Total |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 4 Hardcore | 5 | 2 | 2 | **34** | 1 | 2 | 7 | 4 | 6 | **30** | **4** | **97** |

Verificado descompilando desde `GAMEDATA\MODS`: 5 huevos por L-system, los otros cinco
`Probability = 30` del archivo **sin tocar**, y `AgroMovement`/`AgroThreshold` intactos.

### ⚠️ Conflicto conocido

**`NoDerelictMiniHorrors` (Lenni) escribe los mismos dos `.ENTITY.MBIN`** de los nidos. Hay
que desactivarlo en Vortex antes de probar cargueros, o no se mide nada: ese mod les quita
el `GcAlienPodComponentData` entero y el `DestroyedModel` que suelta los MiniFiends.

### ✅ Probado el 2026-08-09 — NMS 170671

Plan de prueba: [`CHECKLIST-0.3.2.md`](CHECKLIST-0.3.2.md).

| Qué | Veredicto |
|---|---|
| **Los nidos del carguero reaccionan** | ✅ **Pasa.** Linterna y disparos despiertan el nido, salen MiniFiends y también el Horror grande. `AgroTorch` 12 / `GunfireAgro` 8 contra un umbral de 15 **son la escala correcta**: deja de ser inferencia |
| **Los Horrores de interior salen antes** | ✅ Más presión de la habitual dentro del carguero |
| **Huevos dentro de los edificios abandonados** | ❌ **Sin medir.** No aparecieron, pero **no se visitaron los tres tipos de edificio**. Prueba incompleta, no fallo confirmado. Sigue siendo lo principal de 0.3.2 y sigue pendiente |

**Los otros dos mods que iban en la misma tanda:**

- `HorribleTerror_DerelictBugs` — ✅ **se queda.** La misión del carguero abandonado
  **termina**: convertir los `ValidRoomIDs` de colocación de objetos de misión no la rompe.
  Era la condición de desinstalación y pasa.
- `HT_PredatorParts_PRUEBA01` — ✅ **se queda.** Ningún TREX crasheó ni salió con el modelo
  roto. **Borrar secciones de un `.DESCRIPTOR` es vía válida**: el juego tolera huecos, no
  hace falta sesgar. La respuesta a «¿sirve dejar solo 4 heads y 5 eyes?» es **sí**.
- `HorribleTerror_NecroSkin` — ⚠️ **carga pero no sirve.** Los Horrores salen **blancos**,
  no con las calaveras. La ruta del `.DDS` es válida —el bicho cambia— pero el DDS que
  produce `Make-NMSTexture.py` no se muestrea. Candidatos por orden: sin mipmaps, cabecera
  DX10/BC7 mal declarada, o que mande la paleta de recoloreado. Siguiente paso barato:
  empaquetar el DDS **vanilla sin tocar** y ver si sigue blanco.

De la 0.3.1 se cierra además **`AllowSpawnBrood`**: funciona. Ver la entrada 0.3.3 arriba y
[`CHECKLIST-0.3.1.md`](CHECKLIST-0.3.1.md) §4.1. Del resto de 0.3.1 sigue casi todo
pendiente.

---

## [0.3.1] — 2026-08-05

Construido contra NMS **170671** (rama Public), MBINCompiler 6.45.0.1.
**Solo cambia Hardcore.** Fácil, Normal y Difícil salen idénticos a 0.3.0 — mismo conteo
(23 / 45 / 50) y mismos deltas.

### Added

- **Se le quita el marcador de UI a los depredadores**, no solo a los Horrores.
  El campo **no está en `GCCREATUREGLOBALS`**, que es donde se buscó primero: vive en
  `GLOBALS\GCUIGLOBALS.GLOBAL.MBIN`, línea 2572, y se llama
  **`ShowOnscreenPredatorMarkers`** (`true` en vanilla). Es una **novena ruta** para el mod
  y la primera fuera del ecosistema.
  - Cómo se encontró: barriendo la tabla de cadenas de `libMBIN.dll` por `Marker` — el
    mismo método que destapó `DebugGalaxyMapInQuickMenu` en el mod 3. Devuelve 230
    identificadores y `ShowOnscreenPredatorMarkers` es el único que pega. Buscar campo por
    archivo no lo habría encontrado nunca: nadie iba a abrir `GCUIGLOBALS` buscando
    depredadores.
  - Es un booleano, único en el archivo, sin colisión de prefijo.

### Changed — los Horrores no sueltan la presa

El diagnóstico de por qué unos vienen y otros se van. Son **tres causas distintas**, y
solo la tercera es la que suena a «pierden el interés»:

| Causa | Campo | Qué pasaba |
|---|---|---|
| **Nunca te vieron** | `FiendPerceptionDistance` = 80 | Con huevos ×20 hay nidos por todas partes. Un Horror que sale de un nido que no has tocado y a más de 80 m **no llega a fijarte**: no pierde el interés, es que nunca lo tuvo. Ése es el que «se aleja» — está haciendo su ronda |
| **El aggro se drena solo** | `FiendAggroDecreasePerSpawn` = 0.1 | Es la causa de fondo. Romper un huevo sube el aggro +1.0; **cada Horror que nace lo baja 0.1**. Con 12 saliendo en oleada el medidor se vacía él solo en un combate, sin que tú hagas nada. Es un sistema pensado para 6 bichos y densidad ×1 |
| **Caducaba** | `FiendAggroTime` = 120 s | Dos minutos y a casa |

Además, `FiendMaxEngaged` = 12 con `MaxFiendsToSpawn` = 12 dejaba el cupo justo: cualquier
Horror de más se queda mirando en vez de entrar.

Valores nuevos, todos solo en Hardcore:

| Campo | 0.3.0 | 0.3.1 | Qué hace |
|---|---:|---:|---|
| `FiendAggroDecreasePerSpawn` | 0.1 | **0.0** | nacer ya no gasta aggro |
| `FiendAggroIncreaseDamageEgg` | 1.0 | **3.0** | rozar un huevo llena el medidor a fondo |
| `FiendAggroIncreaseDestroyEgg` | 1.0 | **3.0** | ídem al romperlo |
| `FiendAggroTime` | 120 | **600** | diez minutos de rencor |
| `FiendPerceptionDistance` | 80 | **120** | te fijan desde el doble de lejos que en vanilla |
| `FiendMaxEngaged` | 12 | **16** | cuántos te tienen fichado |
| `FiendMaxAttackers` | 6 | **8** | cuántos pegan a la vez |
| `MaxFiendsToSpawn` | 12 | **16** | si sube el cupo de comprometidos, el de vivos tiene que dar |
| `FiendBeingShotMemoryTime` | 10 | **60** | dispararle a uno lo deja pegado a ti un minuto |
| `FiendDespawnDistance` | 150 | **300** | correr 150 m ya no los evapora |

Conteo Hardcore: **54 → 60** (31 globals + 1 uiglobals). 0 errores. Delta verificado
propiedad por propiedad, y `MaxFiendsToSpawnCarnage` **sin tocar** pese a que
`MaxFiendsToSpawn` es prefijo suyo — AMUMSS empareja el nombre exacto, no por prefijo.

### Fixed — el mod no estaba desplegado, otra vez

Lo que había en `GAMEDATA\MODS\HorribleTerror_Infestation_4-Hardcore\` eran **8 EXML y 0
MBIN**, y los EXML eran el delta de `CreatedMODS` **con sus 26 marcas `!# CHANGED` dentro
del XML**. Es exactamente lo que hundió la PRUEBA 01 del mod 3, y es la tercera vez que
esta trampa muerde a este proyecto (ver también la sesión del 04/08 en el README de
`infestacion`, donde la prueba midió 0.1.0 creyendo medir 0.2.0).

**Consecuencia:** las observaciones in-game de 0.3.0 —incluida «unos Horrores vienen y
otros se van»— se hicieron contra un mod que **probablemente no estaba activo**. El
diagnóstico de arriba se sostiene igual, porque sale de leer los campos vanilla y no de lo
que se vio en pantalla; pero **0.3.1 es el primer despliegue de Hardcore que está
verificado como MBIN**, y por tanto la primera medición que va a valer.

Desplegado desde `ModBackups\` creando el `GLOBALS\` a mano —AMUMSS deja los dos MBIN de
globals sueltos en la raíz, mismo detalle que en la PRUEBA 05 del mod 3— y verificado
descompilando de vuelta desde `GAMEDATA\MODS`. La carpeta vieja se retiró a
`build\_retirado_2026-08-05_infestacion-0.3.0-EXML\`.

### Tooling

`Build-Tiers.ps1` borraba de `ModScript\` solo los `.lua` cuyo nombre coincidía con los de
la carpeta que se construía, así que un script olvidado de otra sesión se construía también
y contaminaba el conteo agregado. Ahora los borra **todos**. Lo destapó el mod 3 y aquí
habría vuelto a pasar: `MOD3_MapaGalactico_PRUEBA06.lua` seguía en la carpeta.

### Sin probar

- Todo lo de esta versión. Save respaldado: `NMS_saves_2026-08-05_0111_antes-infestacion-031`.
- **Mirar el cursor del menú.** Es el testigo gratis de si nuestro MBIN de `GCUIGLOBALS`
  convive con el EXML de `Small Cursor 6.6`. Ver el README de `infestacion`.
- `FiendDistToConsiderTargetSwtich` (10.0, el typo es de Hello Games) y el `MoveRange` =
  100 del `FIEND` en `CREATUREDATATABLE` se dejan quietos: los dos podrían ser palancas de
  «a quién persigue» y «hasta dónde», pero no sabemos en qué dirección empujan y esta
  versión ya cambia diez campos. Quedan para la siguiente si con esto todavía se sueltan.

---

## [0.3.0] — 2026-08-04

Construido contra NMS **170671** (rama Public), MBINCompiler 6.45.0.1.
**Hardcore desplegado y verificado en `GAMEDATA\MODS`: 54 cambios en 8 EXML.**
Sin probar in-game todavía.

0.1.0 subió la **cantidad** de Fiends. 0.2.0 cambió su **conducta de ataque**.
0.3.0 cambia **cómo se te acercan**: sin acechar, derechos y en horda.

### Added

- **Archivo nuevo: `METADATA\SIMULATION\ECOSYSTEM\CREATUREBEHAVIOURTREES.MBIN`.** Octava
  ruta del mod y **la primera vez que se toca un árbol de comportamiento**, no solo
  valores sueltos.
  - `BehaviourMoveSpeed` `Normal` → **`Fast`** en el nodo `MoveToTarget` de `MELEE`
    (Difícil y Hardcore). `Fast` está verificado como valor válido del enum porque
    `RANGED_FIRE` ya lo usa en vanilla.
  - `DynamicMoveSlowdownDistMul` 4.0 → 3.0/2.0/1.0. Los bichos **frenaban** al acercarse;
    ahora llegan encima sin decelerar.
  - Las dos reglas van ancladas con `SPECIAL_KEY_WORDS = {"Id", "MELEE"}` y
    `REPLACE_TYPE = "ONCE"`. **Verificado en el delta:** un solo `_id="MELEE"`, un solo
    nodo `GcBehaviourMoveToTargetData`. `RANGED_SPIT` y `RANGED_FIRE` intactos.
- **Se acabó el acecho** — cuatro campos de `GCCREATUREGLOBALS` que nunca se habían
  tocado. La secuencia vanilla era: te ve → **pausa 1.5 s** → se acerca → **acecha 4 s** →
  carga solo a 7 m.
  - `PredatorNoticePauseTime` 1.5 → 0.8/0.3/**0.0**
  - `PredatorApproachTime` 4.0 → 2.0/0.5/**0.0**
  - `PredatorChargeDist` 7.0 → 12/25/**40**: carga desde lejos en vez de acercarse primero.
  - `PredatorEnergyUseChasing` -0.1 → -0.05/**0.0**. **Hallazgo nuevo:** perseguir gastaba
    energía. A 0 no se cansan a mitad de la persecución.
- **Que vengan derechos** — los sospechosos reales del zigzag:
  - **`SteeringUpdateRate` 0.25 → 0.20/0.15/0.10. Hallazgo nuevo y sospechoso nº1.** El
    rumbo se recalculaba solo **4 veces por segundo**; contra un jugador que se mueve, eso
    garantiza sobrepasar y corregir, que es exactamente lo que se ve como zigzag.
  - `MaxTurnRadius` 5.0 → 4.0/3.0/**2.0**. Ya estaba en la lista de sospechosos de
    `COMPORTAMIENTO.md` §5b y por fin entra.
- **Movimiento de horda** — la manada se mueve como un bloque:
  - `FollowLeaderCohereWeight` 0.1 → 0.4/0.8/**1.2**. **Hallazgo nuevo.** Vanilla lo tenía
    casi apagado.
  - `FollowLeaderAlignWeight` 1.0 → 1.5/2.5/**3.5**: alinean su dirección entre sí.
  - `SpherePusherWeight` Small/Medium 10 → 9/7/**5** y Large 5 → 4.5/4/**3**. Menos empujón
    mutuo = no se sacan unos a otros de su línea de carga. Ataca a la vez el
    amontonamiento y el sospechoso (b) del zigzag. `Huge` **no se toca**.

### Changed

- **Fácil sigue sin cambiar**, tercera versión consecutiva. Ninguno de los 13 cambios de
  0.3.0 entra en ese tier. Sus EXML son idénticos a los de 0.1.0.
- Conteo esperado por tier: **23 / 45 / 50 / 54** (antes 23 / 33 / 37 / 41).
- El mod pasa de 7 rutas a **8**.

### Decisiones de diseño

- **`AvoidCreaturesStrength` del árbol `MELEE` se queda en 0.0, a propósito.**
  `COMPORTAMIENTO.md` §7 lo tenía como punto 11 — subirlo a 0.5 para que los atacantes no
  se amontonen durante la carga. **Va justo en contra de «que el movimiento sea como en
  horda»**, que es lo pedido. El apelotonamiento se combate por física de empuje
  (`SpherePusherWeight`), no separando la manada. Queda descartado mientras el objetivo
  sea la horda.
- **`PathOverestimate` (6.0) se deja fuera** pese a ser candidato del zigzag: no se sabe si
  es margen de seguridad del pathfinding, y bajarlo podría hacer que se claven en el
  terreno. Es el siguiente a probar si #44 y #45 no bastan.

### Trampas nuevas documentadas

- **Los backups de AMUMSS siguen sin servir como vanilla.** Los valores de esta versión se
  sacaron desempaquetando `NMSARC.globals.pak` con `hgpaktool` y decompilando con
  MBINCompiler. `hgpaktool -f <filtro>` **no filtró nada** con ningún patrón probado; hubo
  que desempaquetar el pak entero (41 archivos, es pequeño) y buscar dentro.
- **`PredatorEnergyUseChasing` es negativo en vanilla** (`-0.100000`). Es el primer campo
  del mod cuyo valor vanilla lleva signo.
- **`BehaviourMoveSpeed` es un enum, no un número:** se escribe `Fast` / `Normal` sin
  comillas en el MXML.
- **En un árbol de comportamiento, `0.000000` aparece por todas partes.** Cualquier regla
  sobre `CREATUREBEHAVIOURTREES` necesita ancla; sin ella, `MELEE`, `RANGED_SPIT` y
  `RANGED_FIRE` comparten `DynamicMoveSlowdownDistMul = 4.0` y `AvoidCreaturesStrength = 0`.

### Build y despliegue — 2026-08-04

- Los cuatro tiers, **0 errores**. Conteos **23 / 45 / 50 / 54**, exactamente los previstos:

  | Tier | gen | med | large | globals | datatable | eggs | infest | árbol | Total |
  |---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
  | 1 Fácil | 5 | 2 | 2 | 4 | — | 4 | 6 | — | **23** |
  | 2 Normal | 5 | 2 | 2 | 24 | 1 | 4 | 6 | 1 | **45** |
  | 3 Difícil | 5 | 2 | 2 | 25 | 4 | 4 | 6 | 2 | **50** |
  | 4 Hardcore | 5 | 2 | 2 | 26 | 7 | 4 | 6 | 2 | **54** |

- ✅ **Desplegado a `GAMEDATA\MODS` y verificado leyendo el EXML**, que es el paso que
  faltó en 0.2.0: 54 `!# CHANGED` repartidos 26+2+7+5+2+2+4+6 en 8 archivos.
- ✅ El delta de `SpherePusherWeight` toca `Small`, `Medium` y `Large`, y **no `Huge`**.
- Backup previo: `NMS_saves_2026-08-04_1240_antes-mod2-0.3.0-movimiento`.

### Pendiente

- [ ] **Prueba in-game.** Empezar por **un Fiend solo**: es lo que separa las causas del
      zigzag. Si uno suelto ya viene derecho, era el steering/giro; si sigue haciendo eses
      solo, ninguno de los dos era.
- [ ] Comprobar que arrancan **sin pausa** al verte y llegan sin pararse a mitad.
- [ ] Comprobar que la manada de 5-7 llega **como un bloque**.
- [ ] **Vigilar los FPS.** 70 criaturas recalculando rumbo 10 veces/s en vez de 4.
      `SteeringUpdateRate` es el primero a revertir si hay caída.
- [ ] Todo lo que 0.2.0 dejó sin medir: brood, marcador de UI, eclosión en oleada.

---

## [0.2.0] — en curso

Probado contra NMS **170671** (rama Public), MBINCompiler 6.45.0.1.

0.1.0 subía la **cantidad** de Fiends. 0.2.0 cambia su **conducta**.

### Added

- **Archivo nuevo: `METADATA\SIMULATION\ECOSYSTEM\CREATUREDATATABLE.MBIN`.** Es la
  séptima ruta del mod y la primera vez que se tocan datos de ataque por especie.
- **Sin marcador de UI** (`FiendOnscreenMarkers` `true` → `false`). El juego dibujaba
  un icono sobre cada Fiend. Quitarlo no cambia ningún número de dificultad, solo te
  quita el aviso. Difícil y Hardcore.
- **Percepción propia del Fiend** (`FiendPerceptionDistance` 60 → 65/70/80). Es un
  campo **independiente** de `PredatorPerceptionDistance`; hasta ahora no se tocaba, y
  eso dejaba a los Fiend de Hardcore viéndote *más tarde* (60) que a un depredador
  normal (80). Corregido.
- **Eclosión en oleada** (`FiendMinSpawnTime`/`MaxSpawnTime` 0.25/3.0 → hasta 0.1/0.5).
  Los Fiend salían del huevo escalonados a lo largo de 3 segundos; ahora salen de golpe.
- **Menos amontonamiento** (`AvoidCreaturesWeight` 6 → 8/10). Primer intento barato
  contra el apelotonamiento de las manadas de 5-7 que introdujo el mod 1.
- **Gusano por cercanía** (`GroundWormSpawnerActivateRadius` 100 → 50/20/10). El
  `WORMSPAWNER` de `INFESTATION.MBIN` es un spawner **activado por proximidad, sin
  romper nada**, y ya estaba en el mod desde 0.1.0 sin que lo aprovecháramos. Bajar el
  radio hace que salte cuando ya lo tienes encima.
- **Más golpes por racha** (`MinFlurryHits`/`MaxFlurryHits` 2/4 → 3/5 y 3/6). Difícil
  y Hardcore.
- **Salto más seguido** (`DelayBetweenPounceAttacks` 2.0 → 1.8/1.5/1.2).
- **Ataques más rápidos** (`AnimSpeedModifier` 1.0 → 1.1/1.2), sin tocar el daño.
- **Los Fiend se multiplican mientras luchas** (`AllowSpawnBrood` `false` → `true`,
  `SpawnBroodID` → `BUGFIENDS`, `SpawnBroodTimer` → 10). **Solo Hardcore.**
  Sigue `[Sin probar]` — ver la prueba in-game más abajo.

### Changed

- **Fácil no cambia en 0.2.0**, a propósito. Ninguno de los ocho cambios entra en ese
  tier: sus valores coincidirían con vanilla y escribirlos ensuciaría el EXML delta sin
  cambiar nada, que es el mismo criterio que ya seguía en 0.1.0. **Su EXML es idéntico
  al de 0.1.0** — quien tenga Fácil instalado no necesita actualizar.
- Conteo de cambios esperado por tier: **23 / 33 / 37 / 41** (antes 23 / 27 / 27 / 28).

### Removed

- **Aproximación en zigzag** (`FiendZigZagSpeed`/`Strength`). Entró en la primera build
  de 0.2.0 con 1.0/0.10 en Difícil y 1.5/0.15 en Hardcore, y **se retira tras probarla
  in-game**. Ver abajo. Se quita la regla entera en vez de escribir 0: escribir el
  propio valor vanilla ensucia el EXML delta sin cambiar nada.

### Trampas nuevas documentadas

- **`CREATUREDATATABLE` tiene diez bloques de `GcCreatureFiendAttackData`, no uno.**
  Los dueños son `FIEND`, `BUGFIEND`, `BUGQUEEN`, `SCUTTLER`, **`SCUTTLER_PET`**,
  `SLUG`, `MINIFIEND` y `MINIDRONE`, más 2 de `GcCreatureSpookFiendAttackData`
  (`JELLYBOSS_BROOD`, `LAND_SQUID`).
  - `SCUTTLER_PET` **es la mascota del jugador** y `BUGQUEEN` es un jefe calibrado
    aparte. Un `REPLACE_TYPE = "ALL"` los tocaría a los diez.
  - Por eso cada regla del archivo va anclada con
    `SPECIAL_KEY_WORDS = {"Id", "FIEND"}` y `REPLACE_TYPE = "ONCE"`, el mismo patrón
    que ya se usaba para el peso de `DANGEROUS`.
- `MinFlurryHits` y `MaxFlurryHits` son **enteros** en el MXML, como
  `FiendMaxAttackers` y `MaxEcosystemCreaturesNormal`. Se escriben `3`, no `3.000000`.
- `FiendOnscreenMarkers` y `AllowSpawnBrood` son **booleanos**: `false` / `true` en
  minúsculas.

### ⚠️ Sesión del 2026-08-04 — la prueba in-game midió 0.1.0, no 0.2.0

**0.2.0 se construyó el 04/08 y nunca se copió a `GAMEDATA\MODS`.** La prueba de esa
tarde se jugó contra 0.1.0. Comprobado leyendo el EXML desplegado: 9 cambios en
`GCCREATUREGLOBALS` — los de 0.1.0 — y **ningún `CREATUREDATATABLE.EXML`**, que es el
archivo que estrena esta versión. Ni `FiendOnscreenMarkers` ni `FiendZigZag*` estaban
puestos.

> **Regla nueva: construir no es desplegar.** Antes de cualquier prueba in-game, leer el
> EXML de `GAMEDATA\MODS` y confirmar que contiene los campos de la versión que se cree
> estar probando. Un `REPORT` con el conteo correcto dice que la build salió; **no** dice
> que esté en el juego. Los conteos 23/33/39/43 de la build del 04/08 eran correctos y
> aun así se jugó contra la versión anterior.

Qué queda en pie de esa prueba:

| Observación | Veredicto |
|---|---|
| Los Fiend se acercan zigzagueando, no vienen derechos | **Válida** — y con `FiendZigZagSpeed` a 0 |
| No se multiplicaban | **Nula.** El archivo no estaba en el juego |
| El marcador de UI | **Nula.** El cambio no estaba desplegado |

**El zigzag se retira igualmente**, por lo que sí demuestra la observación válida: los
Fiend zigzaguean **con el campo a 0**, luego `FiendZigZagSpeed` no es la palanca que lo
causa, y subirlo solo habría empujado en la dirección que molesta. Nunca llegó a estar
en el juego.

**La causa real del zigzag sigue sin identificar.** Sospechosos: `MaxTurnRadius = 5.0`
(no pueden girar cerrado hacia ti, sobrepasan y corrigen), el empuje entre bichos de las
manadas 5/7 que introdujo el mod 1 (`SpherePusher*`), y `AvoidCreaturesStrength = 0` en
el árbol `MELEE`. Ninguno probado.

### Sin verificar — revertir primero si algo falla

- **`AllowSpawnBrood` en Hardcore.** `BUGQUEEN` lo usa en vanilla con
  `SpawnBroodID = BUGFIENDS`, timer 30 y anim `BIRTHING`. Aquí se copia el ID, se baja el
  timer a 10 y se deja `SpawnBroodAnim` en `ROAR`, que es lo que el `FIEND` ya trae: no
  sabemos si el `FIEND` tiene animación `BIRTHING`. **Sigue siendo el primer cambio a
  revertir.**
- **`FiendOnscreenMarkers = false`.** Sin probar: nunca llegó a desplegarse. Sigue
  abierta la duda de si quita solo el marcador o también la detección del escáner y las
  misiones que usan `FIENDCORE` como `ValidMissionSurveyId` del huevo.

### Build — 2026-08-04 (primera, con zigzag)

- **Los cuatro tiers construidos, 0 errores.** Conteos **23 / 33 / 39 / 43**,
  exactamente los previstos, con el desglose por archivo cuadrando también:

  | Tier | gen | med | large | globals | datatable | eggs | infest | Total |
  |---|---:|---:|---:|---:|---:|---:|---:|---:|
  | 1 Fácil | 5 | 2 | 2 | 4 | — | 4 | 6 | **23** |
  | 2 Normal | 5 | 2 | 2 | 13 | 1 | 4 | 6 | **33** |
  | 3 Difícil | 5 | 2 | 2 | 16 | 4 | 4 | 6 | **39** |
  | 4 Hardcore | 5 | 2 | 2 | 17 | 7 | 4 | 6 | **43** |

- ✅ **El anclaje a `FIEND` funciona.** El delta de `CREATUREDATATABLE` de los tres
  tiers que lo tocan contiene **una sola entrada, `_id="FIEND"`**. Ni `SCUTTLER_PET`
  ni `BUGQUEEN` ni ninguno de los otros seis bloques aparece. Era la comprobación más
  importante de esta versión.
- ✅ Tipos correctos en el EXML: `MinFlurryHits` `3` y `MaxFlurryHits` `6` sin
  decimales, `MaxEcosystemCreaturesNormal` `70`, `FiendMaxAttackers` `6`,
  `FiendOnscreenMarkers` `false` y `AllowSpawnBrood` `true` en minúsculas, y
  `SpawnBroodID` como cadena `BUGFIENDS`.
- ✅ **Fácil confirmado sin cambios:** sus 6 EXML son byte a byte idénticos a los de
  0.1.0, como estaba previsto por diseño.
- Salida archivada en `build\infestacion_2026-08-04\`.

### Pendiente

- [x] ~~Confirmar el zigzag.~~ **Retirado** sin probarlo: no es la palanca.
- [x] ~~Rebuild con el zigzag fuera y el timer de brood en 10.~~ 2026-08-04,
      conteos **23 / 33 / 37 / 41**, 0 errores, `_id="FIEND"` único en el delta.
- [ ] **Desplegar 0.2.0 a `GAMEDATA\MODS` y verificar el EXML desplegado** antes de
      volver a probar. Este es el paso que faltó.
- [ ] Prueba in-game real de los 4 tiers. Empezar por Hardcore.
- [ ] **Confirmar que los Fiend se multiplican** (`AllowSpawnBrood`), **lejos de los
      huevos** para que la prueba mida algo.
- [ ] Comprobar que quitar el marcador de UI no rompe el escáner ni las misiones que
      usan `FIENDCORE` como `ValidMissionSurveyId` del huevo.
- [ ] **Identificar qué causa el zigzag real.** Empezar por `MaxTurnRadius` y por si
      `AvoidCreaturesWeight` (ya en 0.2.0) lo mejora de refilón.
- [ ] Capturas propias del mod 2 y su página de Nexus.

---

## [0.1.0] — 2026-08-02

Probado contra NMS **170671** (rama Public), MBINCompiler 6.45.0.1.
Verificado in-game a mano, tier Hardcore.

### Added

- **Mod nuevo, versionado aparte del mod 1**, empezando en 0.1.0. Contiene al mod 1
  (mismos archivos, misma calibración por tier) y añade los Horrores Biológicos.
- Cuatro configuraciones: Fácil, Normal, Difícil y Hardcore. Se instala una sola.
- **Densidad de huevos de Fiend ×2/×5/×20/×20** sobre `FIENDEGGS.MBIN` e
  `INFESTATION.MBIN`, incluido el `GROUNDWORMSPAWNER`.
- **Presión de combate:** `FiendMaxAttackers` 2/3/4/6, `FiendMaxEngaged` 6/8/10/12,
  `MaxFiendsToSpawn` 6/8/10/12 y `FiendAggroTime` 45/60/90/120.
- Fácil no escribe ningún global de Fiend: sus valores coinciden con vanilla.
- Conteo de cambios por tier: **23 / 27 / 27 / 28**, verificado.

### Fixed

- **Bug de cascada de reglas.** Las reglas de un mismo archivo se aplican en secuencia,
  así que en `INFESTATION` la regla de huevos subía `0.005 → 0.025` y la del gusano
  (`VALUE_MATCH "0.025000"`) los volvía a multiplicar: `FlatDensity` acababa en 0.125
  = **×25** en vez de ×5, y el REPORT daba 29 en vez de 27.
  - **Solo se manifestaba en Normal.** Con ×2 y ×20 no había colisión, así que tres de
    las cuatro configuraciones daban el conteo correcto con el mismo script defectuoso.
    De ahí la regla de comprobar el conteo en las cuatro.
  - Arreglado invirtiendo el orden: el gusano va primero y los huevos últimos.

### Trampas documentadas

- Cada objeto de `FIENDEGGS`/`INFESTATION` lleva **dos** bloques de densidad. El bueno
  es `QualityVariants`; debajo hay un `QualityVariantData` con `Coverage 0.2` /
  `FlatDensity 0.5` idéntico en los cinco objetos de los dos archivos. Los scripts usan
  `VALUE_MATCH` para no tocarlo.
- `Coverage` se deja intacto: rango válido desconocido.
- `FiendMaxAttackers`, `FiendMaxEngaged` y `MaxFiendsToSpawn` son enteros.

### Verificado in-game (Hardcore)

Los 13 cambios confirmados jugando: los 5 de Fiend (densidad de huevos ×20, densidad
del `WORMSPAWNER` ×20, `FiendMaxAttackers` 6, `FiendMaxEngaged`/`MaxFiendsToSpawn` 12,
`FiendAggroTime` 120) y los 8 heredados del mod 1.
