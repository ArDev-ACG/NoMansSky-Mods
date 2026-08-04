# Comportamiento de las criaturas — qué se puede tocar

Referencia profunda de las palancas de **conducta**, no de spawn ni de densidad.
Responde a cinco preguntas: a qué distancia te ven, cómo se te acercan, con qué te
atacan, a qué ritmo, y cuánto sitio ocupan entre ellas.

Todo verificado contra la instalación local el **2026-08-03**: NMS 170671,
MBINCompiler 6.45.0.1. Los valores vanilla salen de `NMSARC.globals.pak` y
`NMSARC.Precache.pak` extraídos con `hgpaktool`, no de los backups de AMUMSS.

> ⚠️ **Los backups de AMUMSS no son vanilla.** `tools\AMUMSS\ModBackups\<mod>\*.MBIN`
> contiene el archivo **ya modificado**. Se comprobó al leer allí
> `PredatorPerceptionDistance = 80`, que es nuestro valor de Hardcore. Para valores
> vanilla hay que extraer del `.pak` del juego. Ver §6.

---

## Los cuatro archivos que gobiernan la conducta

| Archivo | Qué controla | Riesgo | Terceros |
|---|---|---|---|
| `GLOBALS\GCCREATUREGLOBALS.MBIN` | Sensores, agro, velocidades, topes, Fiends | **Bajo** — son números sueltos | libre |
| `METADATA\...\ECOSYSTEM\CREATUREDATATABLE.MBIN` | Ataques por especie (`GcCreatureFiendAttackData`) | **Medio** — 10 bloques, fácil pasarse de alcance | libre |
| `METADATA\...\ECOSYSTEM\CREATUREBEHAVIOURTREES.MBIN` | Árboles de decisión: mover → encarar → golpear → esperar | **Alto** — estructura anidada, un fallo rompe la IA | libre |
| `METADATA\...\ECOSYSTEM\GROUND\GROUNDTABLE*.MBIN` | Rol, tamaño de grupo, densidad | bajo | libre |

Escaneo del 2026-08-03 sobre los mods instalados: **ninguna de las cuatro rutas la
toca un mod de terceros.** La única competencia es nuestro propio mod 1/2.

---

## 1. A qué distancia te ven

`GCCREATUREGLOBALS`. Todos son floats sueltos, cambio de bajo riesgo.

| Campo | Vanilla | Nuestro Hardcore | Qué hace |
|---|---:|---:|---|
| `PredatorPerceptionDistance` | 40 | **80** | radio al que el depredador te detecta |
| `FiendPerceptionDistance` | **60** | 60 | **el de los Fiend es aparte — no lo tocamos todavía** |
| `PredatorFishPerceptionDistance` | 60 | 60 | igual, bajo el agua |
| `SmallCreaturePerceptionDistance` | 30 | 30 | criaturas pequeñas |
| `largeCreaturePerceptionDistance` | 70 | 70 | grandes (nótese la `l` minúscula del campo) |
| `CreatureSightRange` | 100 | 100 | vista genérica, no específica de depredador |
| `CreatureHearingRange` | 10 | 10 | oído genérico |
| `PredatorStealthDist` | 11 | 11 | umbral de sigilo `[Sin probar]` |
| `PerceptionUpdateRate` | 4 | 4 | cada cuántos frames re-evalúa `[Inferencia]` |
| `AdultBabyKilledNoticeDistance` | 70 | 70 | radio al que el adulto nota que matas a su cría |

**Hallazgo nuevo: `FiendPerceptionDistance = 60` existe y es independiente.** El mod 2
sube la percepción de depredadores a 80 pero deja a los Fiend en 60 vanilla. Es una
incoherencia nuestra, no del juego: en Hardcore un Fiend te detecta *más tarde* que un
depredador normal. Candidato claro para 0.2.0.

### Corrección: `AlertTable` no tiene que ver contigo

`docs/IDEAS.md` lo listaba bajo "sensores hacia el jugador". **Es falso.** Las 4
entradas son:

| AlertTarget | AlertInitiator | Hearing | Sight | Ángulo | FleeRange |
|---|---|---:|---:|---:|---:|
| Prey | Predator | 30 | 30 | 60 | 15 |
| FishPrey | FishPredator | 30 | 30 | 60 | 15 |
| Prey | Drone | 15 | 15 | 60 | 10 |
| Passive | Drone | 15 | 15 | 60 | 10 |

Ninguna menciona `PlayerPredator` ni al jugador. Es **propagación de alerta entre
criaturas**: la presa que ve a un depredador huye. Tocarlo cambia cómo reacciona la
fauna pacífica, no cómo te detectan a ti. El `SightAngle = 60` tampoco es tu cono de
visibilidad.

---

## 2. Cómo te acechan

La secuencia vanilla es: te detecta → **pausa** → se acerca → **acecha** → carga.

| Campo | Vanilla | Qué hace |
|---|---:|---|
| `PredatorNoticePauseTime` | 1.5 | pausa dramática al detectarte, antes de moverse |
| `PredatorApproachTime` | 4.0 | segundos acechando antes de lanzarse |
| `PredatorChargeDist` | 7.0 | distancia a la que arranca la carga |
| `PredatorChargeDistScale` | 0.3 | escalado de esa distancia por tamaño `[Inferencia]` |
| `PredatorBoredomDistance` | 80 | se aburre (depredador de presas) |
| `PlayerPredatorBoredomDistance` | 80 → **150** en Hardcore | se aburre contigo |
| `PredatorRegainInterestTime` | 30 | segundos hasta volver a interesarse |
| `PlayerPredatorRegainInterestTime` | 30 | idem contigo |
| `PredatorRoarProbAfterHit` | 0.6 | probabilidad de rugir tras acertar |
| `PredatorRoarProbAfterMiss` | 0.7 | tras fallar |

### La palanca que parecía infrautilizada: zigzag — ❌ descartada, no es la palanca

> **Retirada del mod el 2026-08-04, sin llegar a probarla.** El motivo es una observación
> in-game que va en contra de lo que decía esta sección: **los Fiend ya se acercan
> zigzagueando con `FiendZigZagSpeed = 0`.** Luego este campo no es lo que causa el
> vaivén que se ve en pantalla, y subirlo solo empujaría más en la dirección que molesta.
>
> Es un buen recordatorio de que "vanilla lo tiene a 0 y apagado" **no** implica "esa
> conducta no ocurre": puede estar produciéndola otro sistema. Ver §5b para los
> sospechosos reales. Lo de abajo se conserva como referencia de campos.


| Campo | Vanilla | Nota |
|---|---:|---|
| `FiendZigZagSpeed` | **0.0** | **apagado** |
| `FiendZigZagStrength` | **0.0** | **apagado** |
| `ScuttlerZigZagTimeMin` / `Max` | 0.3 / 1.0 | el Scuttler **sí** zigzaguea |
| `ScuttlerZigZagStrength` | 0.1 | referencia de magnitud que el juego usa |

El Fiend tiene movimiento en zigzag implementado y desactivado. El Scuttler lo usa con
`Strength 0.1`, así que hay un valor vanilla funcional del que copiar el orden de
magnitud. Encenderlo cambia la aproximación de "línea recta predecible" a errática —
que es exactamente "cómo te acechan". **Coste: dos números. `[Sin probar]`.**

### Aggro de Fiend — más campos de los que teníamos

| Campo | Vanilla | Qué hace |
|---|---:|---|
| `FiendAggroTime` | 45 | duración del agro |
| `FiendDistToConsiderTargetSwtich` | 10 | a qué distancia se plantea cambiar de objetivo (typo de HG: `Swtich`) |
| `FiendDistReduceForBeingShot` | 70 | dispararle acorta la distancia a la que reacciona |
| `FiendBeingShotMemoryTime` | 10 | cuánto recuerda que le disparaste |
| `FiendAggroIncreaseDamageEgg` | 1.0 | subida de agro al dañar un huevo |
| `FiendAggroIncreaseDestroyEgg` | 1.0 | al destruirlo |
| `FiendAggroDecreasePerSpawn` | 0.1 | el agro baja según van saliendo |
| `FiendSpawnDistance` | 70 | a qué distancia aparecen |
| `FiendDespawnDistance` | 150 | a qué distancia desaparecen |
| `FiendMinSpawnTime` / `MaxSpawnTime` | 0.25 / 3.0 | **ritmo al que brotan del huevo** |
| `FiendOnscreenMarkers` | `true` | **marcador de UI sobre el bicho** |

Dos ideas fuertes:

- **`FiendOnscreenMarkers = false`.** Quita el icono que te chiva dónde está cada
  Fiend. Para un mod de terror es el cambio más barato con más efecto atmosférico: no
  toca ningún número de dificultad, solo te quita el aviso. `[Sin probar]`
- **`FiendMinSpawnTime`/`MaxSpawnTime` a 0.1 / 0.5.** Hoy salen escalonados en hasta
  3 s. Bajarlo convierte la eclosión en una oleada de golpe.

---

## 3. Con qué te atacan

`CREATUREDATATABLE.MBIN`, estructura `GcCreatureFiendAttackData` (39 campos).

### ⚠️ Corrección importante: quién tiene estos bloques

`IDEAS.md` decía que los 8 bloques eran de `FIEND`, `BUGFIEND`, `MINIFIEND`,
`FIENDFISHSMALL` y `FIENDFISHBIG`. **Los dueños reales son otros:**

| # | Dueño | Nota |
|---|---|---|
| 1 | `FIEND` | el Horror Biológico estándar |
| 2 | `BUGFIEND` | |
| 3 | `BUGQUEEN` | **jefe — ver abajo** |
| 4 | `SCUTTLER` | |
| 5 | `SCUTTLER_PET` | ⚠️ **es la mascota del jugador** |
| 6 | `SLUG` | |
| 7 | `MINIFIEND` | |
| 8 | `MINIDRONE` | |
| 9-10 | `JELLYBOSS_BROOD`, `LAND_SQUID` | `GcCreatureSpookFiendAttackData`, estructura distinta |

**Consecuencia:** un `REPLACE_TYPE = "ALL"` sobre `MinFlurryHits` o
`DelayBetweenPounceAttacks` tocaría también a `SCUTTLER_PET`, que es un compañero
domesticado, y a `BUGQUEEN`, que es un jefe calibrado aparte. Hay que acotar por
`SPECIAL_KEY_WORDS` con el `Id` de la entrada, igual que se hizo con `DANGEROUS`.

### Valores vanilla de `FIEND`

| Campo | Vanilla | Qué hace |
|---|---:|---|
| `NearDist` / `FarDist` | 6 / 10 | ventana de decisión de ataque |
| `ModifyDistanceForHeight` | 3.0 | corrección por desnivel |
| `AllowPounce` | `true` | salto encima |
| `DelayBetweenPounceAttacks` | 2.0 | **cadencia del salto** |
| `FiendPounceDistanceModifier` | 1.7 (global) | alcance del salto |
| `FiendMaxVerticalForPounce` | 0.3 (global) | desnivel máximo para saltar |
| `AllowSpit` | `true` | escupitajo |
| `AllowSpitAlways` | `false` | escupir sin condición previa |
| `AOESpitAttack` | `false` | escupitajo en área |
| `SpitFacingRequirement` | 0.95 | cuánto tiene que encararte para escupir |
| `DelayBetweenSpitAttacks` | 1.0 | **cadencia del escupitajo** |
| `FiendEggsToUnlockSpit` | 0 (global) | huevos rotos antes de poder escupir |
| `MinFlurryHits` / `MaxFlurryHits` | 2 / 4 | **golpes por ráfaga** |
| `StartDamageTime` | 0.3 | retardo hasta que el golpe hace daño |
| `TurnToFaceTime` | 0.3 | lo que tarda en encararte |
| `AnimSpeedModifier` | 1.0 | **velocidad de las animaciones de ataque** |
| `AllowPushBackAttack` | `false` | empujón |
| `PushBackRange` | 5.0 | alcance del empujón |
| `PushBackAttackFrame` | **0** | ⚠️ ver abajo |
| `AllowSpawnBrood` | `false` | **engendra crías** |
| `SpawnBroodID` | *(vacío)* | qué engendra |
| `SpawnBroodTimer` | 0.0 | cada cuánto |
| `SpawnBroodAnim` | `ROAR` | animación |
| `RoarChanceOnHit` / `OnMiss` | 0.0 / 0.0 | rugido (los globales de depredador son 0.6/0.7) |

### 🔓 Resuelta la pregunta abierta de `SpawnBroodID`

`IDEAS.md` la tenía como incógnita: *"¿Qué acepta `SpawnBroodID`? ¿Un CreatureID, un
archivo, un rol?"*. **`BUGQUEEN` lo usa en vanilla y funciona:**

```
AllowSpawnBrood     true
SpawnBroodID        BUGFIENDS      <- un ID en plural, no una ruta
SpawnBroodTimer     30.000000
SpawnBroodAnim      BIRTHING
```

Es decir: acepta un **identificador de grupo de criatura**, y hay un ejemplo vanilla
funcional del que copiar. Encender `AllowSpawnBrood` en `FIEND` con
`SpawnBroodID = BUGFIENDS` y un `SpawnBroodTimer` de 20-30 s deja de ser especulación
y pasa a ser copiar un patrón que el juego ya ejecuta. `[Sin probar]` sigue siendo
necesario — no sabemos si `FIEND` tiene la animación `BIRTHING` ni si `BUGFIENDS`
resuelve fuera del contexto de la reina.

`BUGQUEEN` demuestra además que `AllowPushBackAttack = true` funciona, pero con
`PushBackAttackAnim = BOUNCE` y `PushBackAttackFrame = 71`. En `FIEND` el frame es
**0** y la anim es `ATTACK`: encender el empujón sin ajustar el frame probablemente dé
un empujón sin animación o instantáneo. No es un booleano suelto.

---

## 4. A qué ritmo atacan

Hay **tres capas** de cadencia y se multiplican entre sí. Es el punto más confuso del
sistema, así que conviene tenerlo claro antes de tocar nada.

```
CAPA 1 — arbol de comportamiento    CREATUREBEHAVIOURTREES
   MELEE: ... -> ATTACK -> Wait 0.1 s -> repite
                            ^ el ciclo entero

CAPA 2 — datos por especie          CREATUREDATATABLE
   DelayBetweenPounceAttacks 2.0    <- entre saltos
   DelayBetweenSpitAttacks   1.0    <- entre escupitajos
   MinFlurryHits/MaxFlurryHits 2/4  <- golpes dentro de una racha
   AnimSpeedModifier 1.0            <- velocidad de la animacion

CAPA 3 — topes globales             GCCREATUREGLOBALS
   FiendMaxAttackers 2              <- cuantos pegan a la vez
   FiendMaxEngaged   6              <- cuantos participan
```

### El árbol `MELEE`, nodo a nodo

Este es el ciclo de ataque completo de los depredadores cuerpo a cuerpo:

```
CheckDeath
Appear (GRNDAPPEAR)
MELEE [concurrente]
  RegisterAttacker (TARGET)
  MELEE [secuencial, Looping=false]
    MOVE_CLOSE [concurrente]
      GetTarget (TARGET)
      MoveToTarget
        ArriveDist                 1.0     <- se para a 1 m
        BehaviourMoveSpeed         Normal  <- enum: existe "Fast"
        DynamicMoveSlowdownDistMul 4.0     <- frena al acercarse
        SpeedModifier              1.0
        AvoidCreaturesStrength     0.0     <- NO se esquivan entre si
    ATTACK [secuencial]
      FaceTarget  ArriveAngle 5.0          <- debe encararte a 5 grados
      HIT [concurrente]
        PlayAnim ATTACK1  BlendIn 0.2  BlendOut 0.9
          trigger frame 20 -> HIT
        ApplyDamage  FIEND_DMG  Radius 1.0  Offset (0, 1, 1.5)
    Wait  0.1 s                            <- pausa entre ciclos
```

**`Wait = 0.1 s` es la cadencia real del cuerpo a cuerpo.** Es el único número del
árbol que controla cada cuánto se repite el ciclo entero. Subirlo da respiro; bajarlo
casi no queda margen (ya es 0.1).

**`BehaviourMoveSpeed = Normal` tiene un valor mejor documentado de lo que parece:**
el árbol `RANGED_FIRE` usa `Fast` en el mismo campo. O sea que `Fast` es un valor
válido del enum, confirmado por vanilla. Cambiar `MELEE` de `Normal` a `Fast` haría que
los cuerpo a cuerpo cierren la distancia notablemente más rápido, sin tocar ninguna
velocidad global. **Es el cambio de mayor efecto por línea tocada de todo el árbol.**

### Comparativa de los 8 árboles

| Árbol | ArriveDist | MoveSpeed | Wait | Ataque |
|---|---:|---|---:|---|
| `MELEE` | 1.0 | Normal | 0.1 | anim `ATTACK1`, daño r=1.0 |
| `RANGED_SPIT` | 10.0 | Normal | 0.1 | 3 disparos `FIENDSPIT` (frames 25/35/45) |
| `RANGED_FIRE` | 5.0 | **Fast** | 1.0 | `FIENDSPIT` + 3 triggers |
| `FLYING` | MinDist 2 / MaxDist 4 | — | 1.0 | `FIENDSPIT`, `AvoidCreaturesStrength` **1.0** |
| `CRASHY` | MinDist 4 / MaxDist 8 | — | — | cooldown 1.0, umbral 20 |
| `COOLDOWN` | — | — | — | cooldown 2.0, umbral 10 |
| `IDLE` | — | — | — | sin ataque |
| `HERBIVORE` | — | — | — | 9 nodos `GcBehaviourLegacyData` (sistema viejo, opaco) |

`RANGED_SPIT` se acerca a 10 m y dispara tres veces por animación con solo 0.1 s de
pausa: es el árbol más agresivo de todos en cadencia bruta.

---

## 5. Cuánto sitio ocupan entre ellas

Aquí está la respuesta a por qué las manadas de 5-7 se amontonan.

### El problema

`AvoidCreaturesStrength = 0.0` en el nodo `MoveToTarget` de `MELEE`, `RANGED_SPIT` y
`RANGED_FIRE`. **Mientras cargan contra ti, los atacantes ignoran por completo la
evitación entre criaturas.** No es un descuido: los árboles voladores (`FLYING`,
`CRASHY`) lo tienen a `1.0`, así que HG lo puso a cero a propósito en los terrestres.

Con `MinGroupSize/MaxGroupSize` de 1/1 en vanilla eso no se nota nunca — solo hay un
atacante. Nuestro mod los sube a 5/7, así que sí se nota.

### Lo que separa a los bichos

| Campo | Archivo | Vanilla | Qué hace |
|---|---|---:|---|
| `AvoidCreaturesStrength` | árbol, por nodo | **0.0** (terrestres) / 1.0 (voladores) | evitación durante el movimiento |
| `AvoidCreaturesWeight` | globals | 6.0 | peso global de la evitación |
| `SoftenAvoidanceRadiusMod` | globals | 0.2 | suaviza el radio de evitación |
| `InfluenceRadius` | globals | 15.0 | radio de influencia mutua |
| `SpherePusherRadiusMul` | globals | S .33 / M .40 / L .33 / H .50 | **radio físico que empuja**, por tamaño |
| `SpherePusherWeight` | globals | S 10 / M 10 / L 5 / H 2 | cuánto empuja: los pequeños empujan más |
| `SpherePusherOffset` | globals | S .40 / M .40 / L .30 / H .30 | desplazamiento de la esfera |
| `AttractedMinAvoidCreaturesStrength` | globals | 0.0 | evitación con cebo, mínimo |
| `AttractedMaxAvoidCreaturesStrength` | globals | 0.120661 | con cebo, máximo (valor raro, calculado) |
| `AttractedMin/MaxAvoidCreaturesDist` | globals | 3.0 / 7.0 | distancias del sistema de cebo |

**Dos vías para arreglar el amontonamiento, con riesgos muy distintos:**

- **Vía barata (globals):** subir `AvoidCreaturesWeight` de 6 a 10-12. Bajo riesgo,
  archivo que ya tocamos, sin estructura anidada. **Pero puede no bastar**, porque el
  nodo del árbol pone la *strength* a 0 y el peso global multiplica algo que vale cero
  `[Inferencia]` — depende de si el juego suma o multiplica ambos, y no lo sabemos.
- **Vía correcta (árbol):** subir `AvoidCreaturesStrength` de 0.0 a ~0.5 en el nodo
  `MoveToTarget` de `MELEE`. Ataca la causa exacta. Riesgo alto: hay que localizar un
  nodo anidado sin tocar los otros dos árboles que tienen el mismo campo con el mismo
  valor. Requiere `SPECIAL_KEY_WORDS` encadenado, y `0.000000` aparece muchas veces en
  el archivo.

Los `AttractedMin/Max` sugieren que **con cebo el juego sí aplica evitación** (0.12
frente a 0.0), lo que apoya que 0.0 en el árbol es literalmente "ninguna".

---

## 5b. Por qué no vienen derechos a por ti

Observado in-game el **2026-08-04**, jugando 0.1.0 en Hardcore: los Fiend **no cargan en
línea recta**, se acercan haciendo eses. Y lo hacen con `FiendZigZagSpeed = 0`, o sea que
el campo con "ZigZag" en el nombre **no es la causa** (§2).

> **Revisado el 2026-08-04 con el vanilla completo delante.** Al extraer
> `NMSARC.globals.pak` entero aparecieron **dos campos de dirección que esta sección no
> tenía**, y uno de ellos explica el zigzag mejor que los tres sospechosos originales.
> Todos entran en **0.3.0**; ver `MODIFICACIONES.md` #44-45.

### 0) `SteeringUpdateRate = 0.25` — el sospechoso nº1 ⭐ *(nuevo)*

**El rumbo se recalcula 4 veces por segundo.** Entre recálculo y recálculo la criatura
mantiene la dirección vieja, así que contra un blanco que se mueve **siempre** apunta a
donde estabas hasta 250 ms atrás: avanza en la dirección obsoleta, recalcula, corrige,
repite. Eso es literalmente un zigzag, y no necesita ningún campo con «ZigZag» en el
nombre para producirse.

Explica además dos cosas que los otros candidatos no:

- **Por qué se ve con un Fiend solo**, sin manada que lo empuje.
- **Por qué escala con tu velocidad**: cuanto más te mueves, más se desvía la dirección
  obsoleta. Encaja con que se note al esquivar y no al quedarse quieto.

Es un float suelto en `GCCREATUREGLOBALS`. **Riesgo real: rendimiento.** Con
`MaxEcosystemCreaturesNormal = 70`, bajarlo a 0.10 son 70 criaturas recalculando rumbo
10 veces/s en vez de 4. Es el primer campo a revertir si caen los FPS.

### 0b) `PathOverestimate = 6.0` *(nuevo, sin usar)*

El camino se sobreestima en 6 m. Si eso significa que apuntan 6 m más allá de ti, produce
sobrepasar-y-corregir igual que lo anterior. **Se deja fuera de 0.3.0**: no se sabe si es
margen de seguridad del pathfinding, y bajarlo podría hacer que se claven en el terreno.
Es el siguiente a probar si #44 y #45 no bastan.

Otros campos de dirección encontrados en la misma pasada, ninguno tocado:
`TurnRadiusMultiplier` 1.0, `TurnSlowAreaCos` 0.75, `BadTurnPercent` 0.7,
**`BadTurnWeight` 0.0** (la penalización por girar mal está apagada),
`NavMapLookAhead` 1.5, `FlowFieldWeight` 0.7 frente a `FollowWeight` 5.0.

---

Los tres sospechosos originales, revisados:

### a) `MaxTurnRadius = 5.0` — el más simple

Un radio de giro de 5 m significa que la criatura **no puede virar cerrado hacia ti**. Si
te mueves, apunta a donde estabas, no llega a girar a tiempo, sobrepasa, y corrige.
Repetido cada pocos metros eso se ve exactamente como un zigzag. Va acompañado de
`ImpassabilityTurnSpeedMultiplier = 4.0`, que solo acelera el giro **ante obstáculo**.

Es un float suelto en `GCCREATUREGLOBALS`, archivo que ya escribimos: **el candidato más
barato de probar.** Bajarlo a 1-2 debería hacer que apunten mucho más directo.

### b) Nuestras propias manadas empujándose

**Este lo causamos nosotros.** El mod 1 sube `MinGroupSize`/`MaxGroupSize` a 5/7; con
`AvoidCreaturesStrength = 0.0` en el árbol `MELEE` (§5) los atacantes no se esquivan, así
que la única cosa que los separa es la física de empuje (`SpherePusherRadiusMul`,
`SpherePusherWeight`). Siete bichos convergiendo en el mismo punto se empujan unos a
otros **fuera de su línea de carga**, y cada uno vuelve a corregir hacia ti.

Encaja con que en vanilla no se note: con manadas de 1/1 no hay nadie que te empuje.

`AvoidCreaturesWeight` 6 → 8/10 ya entra en 0.2.0 y ataca esto de refilón. **La primera
prueba real de 0.2.0 ya dirá algo**, aunque con la duda de §5 sobre si el peso global
sirve de algo con la strength del árbol a 0.

### c) `AvoidCreaturesStrength` en el árbol

La vía correcta según §5, y la cara: editar un nodo anidado de `MELEE`. Solo merece la
pena si (a) y (b) no bastan.

### Cómo distinguirlos

**Mirar primero un Fiend SOLO.** Si uno suelto viene derecho y las eses solo salen en
manada, la causa era (b), el empuje entre bichos. Si uno suelto también hace eses, es (0)
o (a) — steering o radio de giro.

Con 0.3.0 los tres están tocados a la vez, así que la prueba ya no distingue *cuál* era;
distingue si **alguno** lo era. Si el zigzag persiste con 0.3.0 puesto, ninguno de los
tres es la causa y toca ir a `PathOverestimate` y `FlowFieldWeight`.

---

## 5c. Que no te acechen — la secuencia completa *(nuevo, 2026-08-04)*

§2 listaba los campos del acecho como referencia. Al mirarlos juntos se ve que forman una
**secuencia obligatoria** que se interpone entre «te ve» y «te ataca»:

```
te detecta a PredatorPerceptionDistance (40 vanilla / 80 Hardcore)
   |
   +-- PredatorNoticePauseTime  1.5 s   <- se queda quieto
   |
   +-- se acerca... y acecha
   |     PredatorApproachTime   4.0 s   <- ronda sin atacar
   |
   +-- PredatorChargeDist       7.0 m   <- solo ahora carga
```

**Son 5,5 segundos y 33 metros de teatro** entre verte y ir a por ti. Poner los dos
tiempos a 0 y subir `PredatorChargeDist` a 40 convierte la secuencia en «te ve → viene».

**Hallazgo nuevo: `PredatorEnergyUseChasing = -0.1`.** Perseguir **gasta energía**, y
`PredatorEnergyRecoverRate = 0.1` la repone. Es la explicación más simple de que un
depredador rompa la persecución a mitad sin haberse alejado lo bastante como para
aburrirse (`PlayerPredatorBoredomDistance`). A 0 no se cansan nunca.

Los cuatro campos entran en 0.3.0. Ver `MODIFICACIONES.md` #40-43.

---

## 5d. Movimiento de horda *(nuevo, 2026-08-04)*

«Que no se amontonen» y «que se muevan como una horda» **tiran en direcciones opuestas**,
y conviene tenerlo claro antes de tocar nada: una horda es una masa **compacta y alineada**
que avanza junta, no siete bichos repartiéndose el espacio.

Por eso 0.3.0 **descarta el punto 11 de §7** (`AvoidCreaturesStrength` 0.0 → 0.5 en el
árbol `MELEE`). Separar a los atacantes es exactamente lo contrario de lo pedido.

Las palancas que sí construyen una horda, todas en `GCCREATUREGLOBALS`:

| Campo | Vanilla | Qué aporta |
|---|---:|---|
| **`FollowLeaderCohereWeight`** | **0.1** | Cohesión de la manada. Vanilla lo tiene casi apagado |
| **`FollowLeaderAlignWeight`** | 1.0 | Alineación de direcciones: todos al mismo sitio |
| `SpherePusherWeight` S/M/L | 10/10/5 | Empuje físico mutuo. **Bajarlo** evita que se saquen unos a otros de su línea de carga — ataca a la vez el zigzag (b) y la dispersión |
| `HerdGroupSizeMultiplier` | 4.0 | Sin tocar. Multiplicador de tamaño de manada |
| `InfluenceRadius` / `Force` / `Deflect` | 15 / 20 / 0.8 | Sin tocar. Parecen del sistema de enjambre |

`SpherePusherWeight.Huge` (2.0) **no se toca**: los bichos enormes ya empujan poco y
bajarlo más los haría atravesarse.

---

## 6. Velocidades de movimiento

| Campo | Vanilla | Qué hace |
|---|---:|---|
| `PredatorWalkMoveSpeed` | 1.0 | andar |
| `PredatorTrotMoveSpeed` | 3.0 | trote |
| `PredatorRunMoveSpeed` | 6.0 | correr |
| `DefaultWalk/Trot/RunMoveSpeed` | 1.0 / 2.5 / 5.0 | fauna no depredadora |
| `PredatorSpeedMultiplier` | 1.1 | multiplicador global de depredador |
| `CreatureSpeedMultiplier` | 1.2 | multiplicador global de fauna |
| `CreatureIndoorSpeedMultiplier` | **0.7** | **más lentos en interiores** |
| `MaxSpeed` | 30.0 | tope duro |
| `CreatureMinRunTime` | 8.0 | mínimo que aguantan corriendo |
| `ImpassabilityTurnSpeedMultiplier` | 4.0 | giro ante obstáculo |
| `MaxTurnRadius` | 5.0 | radio de giro máximo |
| `PlayerPredatorHealthModifier` | 1.3 | vida extra del que te caza |
| `FiendHealth` | 1000 | vida base del Fiend |
| `FiendHealthLevelMul` | 2.0 | multiplicador por nivel |

`CreatureIndoorSpeedMultiplier = 0.7` importa para la idea de las fragatas abandonadas:
dentro los bichos van al 70%. Si el escenario cerrado acaba siendo la feature, ese es
el número que hace que se sienta lento o agobiante.

---

## 7. Qué haría en 0.2.0, por relación efecto/coste

Ordenado. Los cinco primeros son números sueltos en archivos que ya tocamos.

> **Estado a 2026-08-04:** los puntos 1-9 están construidos y desplegados (0.2.0 + 0.3.0).
> El **10** entró en 0.3.0 y salió bien. El **11 queda descartado** mientras el objetivo sea
> el movimiento en horda (§5d). El **12** sigue sin tocar.
>
> 0.3.0 añade además 11 campos que esta tabla no tenía: los cuatro del acecho (§5c), los
> dos de rumbo (§5b·0 y §5b·a), los tres de horda y `DynamicMoveSlowdownDistMul` del árbol
> `MELEE` — que resultó ser tan buena palanca como el punto 10 y del mismo coste.

| # | Cambio | Archivo | Riesgo | Por qué |
|---|---|---|---|---|
| 1 | 🔨 `FiendOnscreenMarkers` → `false` | globals | bajo | **En 0.2.0, construido, sin probar.** Quita el chivato de UI |
| 2 | 🔨 `FiendPerceptionDistance` 60 → 80 | globals | bajo | **En 0.2.0.** Cierra la incoherencia: el Fiend te veía más tarde que un depredador en Hardcore |
| 3 | ❌ `FiendZigZagSpeed`/`Strength` 0 → valores del Scuttler | globals | bajo | **Descartado sin probar: no es la palanca.** Ya zigzaguean con el campo a 0. Ver §2 y §5b |
| 4 | 🔨 `FiendMinSpawnTime`/`Max` 0.25/3.0 → 0.1/0.5 | globals | bajo | **En 0.2.0.** La eclosión pasa de goteo a oleada |
| 5 | `AvoidCreaturesWeight` 6 → 10 | globals | bajo | Primer intento barato contra el amontonamiento de las manadas de 5-7 |
| 5b | `GroundWormSpawnerActivateRadius` 100 → 5-10 | globals | bajo | Spawner por cercanía que **ya funciona**, sin romper nada. Ver §8 |
| 6 | `MinFlurryHits`/`Max` 2/4 → 3/6, **solo `FIEND`** | datatable | medio | Acotar con `SPECIAL_KEY_WORDS`: hay que evitar `SCUTTLER_PET` y `BUGQUEEN` |
| 7 | `DelayBetweenPounceAttacks` 2.0 → 1.2, solo `FIEND` | datatable | medio | Cadencia real del salto. Mismo cuidado de alcance |
| 8 | `AnimSpeedModifier` 1.0 → 1.2, solo `FIEND` | datatable | medio | Ataques visiblemente más rápidos sin tocar daño |
| 9 | `AllowSpawnBrood` + `SpawnBroodID = BUGFIENDS` | datatable | medio-alto | Ya no es especulación: `BUGQUEEN` lo hace en vanilla. Necesita prueba dedicada |
| 10 | `BehaviourMoveSpeed` `Normal` → `Fast` en `MELEE` | árboles | **alto** | El cambio de conducta más grande por una línea. `RANGED_FIRE` prueba que el valor existe |
| 11 | `AvoidCreaturesStrength` 0.0 → 0.5 en `MOVE_CLOSE` de `MELEE` | árboles | **alto** | La causa real del amontonamiento. Difícil de acotar: el mismo valor aparece en 3 árboles |
| 12 | `Wait` 0.1 → otro valor en `MELEE` | árboles | **alto** | Solo si el combate resulta demasiado frenético |

**Recomendación:** 0.2.0 = puntos **1-5** (todos en `GCCREATUREGLOBALS`, un solo script,
un solo archivo, mismo patrón que ya usamos) y probarlos in-game antes de meter nada de
`CREATUREDATATABLE`. Los puntos 10-12 son un mod aparte o una versión posterior: tocar
árboles de comportamiento es la primera vez que editaríamos estructura en vez de
valores, y conviene no mezclarlo con cambios que sí sabemos leer en el delta.

⚠️ **Los puntos 1-5 van todos al mismo archivo que el mod 2 ya escribe**
(`GCCREATUREGLOBALS`), así que no pueden ser un mod aparte: entran en los 4 tiers del
mod 2 o no entran (§10i del doc de proyecto).

---

## 8. Que salgan del huevo sin romperlo, a ~5 m

Investigado el 2026-08-03. **Respuesta corta: en vanilla no existe. El huevo salvaje
solo eclosiona al destruirlo.** Pero hay un molde vanilla del que copiar, y está a
6 metros.

### Lo que hay dentro del huevo salvaje

`MODELS\PLANETS\BIOMES\COMMON\RARERESOURCE\GROUND\FIENDEGG\ENTITIES\FIENDEGG.ENTITY.MBIN`
— el que colocan `FIENDEGGS.MBIN` e `INFESTATION.MBIN`, o sea el que nuestro mod 2
multiplica. Tiene **4 componentes**:

| Componente | Qué aporta |
|---|---|
| `GcScannableComponentData` | `ScanRange 150`, icono `HazardEgg`, nombre `UI_FIEND_POD_NAME_L` |
| `GcShootableComponentData` | `Health 125`, `FiendCrimeType None` |
| `GcDestructableComponentData` | `Explosion = FIENDHATCH`, `IncreaseFiendCrime = EggDestroyed`, `ShowInteractRange 8.0` |
| `TkStaticPhysicsComponentData` | `TriggerVolume = false`, `TriggerVolumeType Open` |

**La eclosión *es* la destrucción.** `Explosion = FIENDHATCH` en el componente
destructible: el huevo no "se abre", se rompe y el efecto de rotura se llama eclosión.
No hay componente de animación, ni de disparador, ni de percepción. No hay ningún
campo de radio de proximidad que tocar.

### El molde: el huevo construible sí percibe

`...\BUILDABLEPARTS\SPACEBASE\FIENDEGG\ENTITIES\FIENDEGG.ENTITY.MBIN` — el huevo que
el jugador puede construir en su base. Tiene **7 componentes**, tres de ellos que al
salvaje le faltan:

- **`TkAnimationComponentData`** con tres animaciones: `IDLE`, **`IDLENEAR`** y `HATCH`.
  O sea que el estado "el jugador está cerca" **existe y está animado**.
- `TkSketchComponentData` (grafo de lógica, vacío aquí).
- **`GcAntagonistComponentData`** — y aquí está lo bueno:

```
Group                    Fiends
Enemies.Player
    HatredFactor         1.000000
    GrudgeFactor         0.800000
    Perceptions          <VACIO>          <- el hueco
Perceptions
    HIVE_MIND
        Range            6.000000         <- ~los 5 m que pides
        XFOV             360.000000       <- todo alrededor
        YFOV             180.000000
        Raycast          false            <- atraviesa obstaculos
```

`HIVE_MIND` con `Range 6`, 360° y sin raycast es exactamente la forma de una
percepción de proximidad pura. Pero está declarada bajo `Friends.Fiends`: es cómo el
huevo habla con **otros Fiend**, no cómo te detecta a ti. **`Enemies.Player.Perceptions`
está vacío.**

Ese hueco vacío es el punto de enganche: hay un sitio donde declarar "percibe al
jugador", y al lado un ejemplo funcional con el radio ya en 6 m.

### Rutas, de más barata a más cara

| Ruta | Qué es | Coste | Verificado |
|---|---|---|---|
| **A** | `GroundWormSpawnerActivateRadius` 100 → 5-10 | trivial | ✅ **es proximidad real y ya funciona** |
| **B** | Añadir `GcAntagonistComponentData` al huevo salvaje con percepción de jugador a 5 m | alto | ❌ `[Sin probar]` |
| **C** | `TriggerVolume` `false` → `true` en el huevo salvaje | trivial | ❌ probablemente inútil |
| **D** | Bajar `Health` del huevo de 125 a ~1 | trivial | ✅ funciona, pero **sigue habiendo que romperlo** |

**Ruta A es la única que ya hace lo que pides, hoy, sin añadir nada.**
`GroundWormSpawnerActivateRadius = 100` es un spawner **activado por cercanía, sin
tocar nada**, y el `WORMSPAWNER` ya lo coloca `INFESTATION.MBIN` — o sea que ya está en
el mod 2. Salen gusanos, no Fiends, y ese es el pero. Los números que lo acompañan:

| Campo | Vanilla |
|---|---:|
| `GroundWormSpawnerActivateRadius` | 100 |
| `GroundWormSpawnRadius` | 40 |
| `GroundWormSpawnSpacing` | 10 |
| `GroundWormSpawnMin` / `Max` | 3 / 3 |
| `GroundWormSpawnChance` | 1.0 |
| `GroundWormSpawnTimeOut` | 180 |
| `GroundWormSpawnerDestroyRadiusActive` | 150 |

Bajar `ActivateRadius` a 5-10 hace que el spawner salte **cuando ya lo tienes encima**,
que es justo la sensación de "he pasado al lado y ha salido algo". Es un número, en un
archivo que ya escribimos.

**Ruta C** casi seguro no sirve: `TriggerVolume = true` convierte el objeto en volumen
de disparo, pero sin un componente de acción asociado no hay nada que disparar. El
huevo salvaje no lo tiene. `[Inferencia]`

**Ruta B** es la que hace literalmente lo que pides, y es cara: no es cambiar un valor,
es **añadir un componente entero** a un `.ENTITY.MBIN`, con AMUMSS y `ADD_OPTION`. Dos
incógnitas encima:

1. No se sabe si el sistema antagonista **dispara la eclosión** al percibir al jugador,
   o si solo sube el agro. Puede que percibirte no haga nada visible.
2. El huevo salvaje **no tiene componente de animación**, así que aunque eclosionara
   por proximidad no habría animación de apertura: desaparecería con el efecto
   `FIENDHATCH`. Habría que añadir también el `TkAnimationComponentData`.

### Recomendación

Para 0.2.0, **ruta A**: `GroundWormSpawnerActivateRadius` a 5-10 en los tiers altos.
Es un número, en `GCCREATUREGLOBALS`, que ya tocamos, y da la mecánica que pides —
aunque con gusano en vez de Fiend.

La ruta B merece **su propia sesión de pruebas**, no meterla en 0.2.0 junto a cinco
cambios más: si algo sale mal no se sabría cuál de los seis fue. Además sería el primer
`.ENTITY.MBIN` que tocamos y el primer componente que añadimos, no solo un valor.

---

## 9. Preguntas que siguen abiertas

- `[Sin probar]` ¿`AvoidCreaturesWeight` global surte efecto cuando el nodo del árbol
  tiene `AvoidCreaturesStrength = 0`? Determina si el punto 5 sirve de algo o si hay
  que ir directo al punto 11.
- `[Sin probar]` ¿`SpawnBroodID = BUGFIENDS` resuelve fuera del contexto de `BUGQUEEN`?
  ¿Tiene `FIEND` la animación `BIRTHING`, o hay que dejar `ROAR`? **Sigue abierta tras
  la prueba del 2026-08-04: no se vio ninguna cría.** El siguiente intento baja
  `SpawnBroodTimer` de 30 a 10; si tampoco, se prueba `BIRTHING`.
- `[Sin probar]` ¿`FiendOnscreenMarkers = false` quita solo el marcador o también la
  detección del escáner? **Sigue abierta:** el cambio se construyó en 0.2.0 pero nunca
  llegó a desplegarse, así que la sesión del 2026-08-04 no lo midió.
- `[Sin identificar]` **¿Qué causa el zigzag que sí se ve in-game?** 0.3.0 ataca los tres
  sospechosos a la vez (`SteeringUpdateRate`, `MaxTurnRadius`, `SpherePusherWeight`), así
  que la próxima prueba dirá si es **alguno** de ellos, no cuál. Si persiste, quedan
  `PathOverestimate` y `FlowFieldWeight`. Ver §5b.
- `[Sin probar]` **¿Cuánto cuesta `SteeringUpdateRate = 0.10` en FPS?** 70 criaturas
  recalculando rumbo 10 veces/s en vez de 4. Es el primer campo de 0.3.0 a revertir.
- `[Sin probar]` ¿`PathOverestimate = 6.0` es margen de seguridad del pathfinding o
  sobreestimación del punto de destino? Determina si es candidato de zigzag o una trampa.
- `[Sin investigar]` `BadTurnWeight = 0.0`: la penalización por girar mal está apagada en
  vanilla. Subirla podría hacer que se comprometan con un rumbo en vez de corregir tanto.
- `[Sin probar]` ¿`PredatorStealthDist = 11` es "te ve aunque vayas agachado" o
  "dentro de esto te ve pase lo que pase"? El nombre admite las dos lecturas.
- `[Sin investigar]` `GcCreatureSpookFiendAttackData` (`JELLYBOSS_BROOD`, `LAND_SQUID`)
  es una estructura distinta que no hemos abierto.
- `[Sin investigar]` `HERBIVORE` usa 9 nodos `GcBehaviourLegacyData` — un sistema de
  comportamiento anterior que no expone parámetros. Si algún día hace falta tocar
  herbívoros, hay que investigar qué hay detrás.
- `[Sin probar]` `MaxFiendsToSpawnCarnage = 10`: sigue sin saberse qué dispara el modo
  "carnage".
