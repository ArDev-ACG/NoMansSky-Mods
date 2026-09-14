# Checklist de prueba — mod 2 Infestation 0.3.1

Lo que hay que comprobar jugando **antes** de dar por buena la 0.3.1 y antes de que la
0.3.2 meta ruido encima. Se aparca aquí para no perderlo mientras se trabaja en assets.

- Versión bajo prueba: **0.3.1**, solo `HorribleTerror_Infestation_4-Hardcore`.
- Estado del despliegue: **9 MBIN verificados** descompilando desde `GAMEDATA\MODS` (05/08).
- Detalle de cada campo: [`MODIFICACIONES.md`](MODIFICACIONES.md) · [`CHANGELOG-MOD2.md`](CHANGELOG-MOD2.md)

> **Nada de esto se ha jugado todavía.** La prueba del 04/08 midió 0.1.0 por el fallo de
> despliegue (EXML en vez de MBIN), así que **0.2.0 y 0.3.0 se estrenan aquí junto con
> 0.3.1**. Son 21 cambios de conducta a la vez: si algo sale raro, la culpa puede ser de
> cualquiera de las tres versiones.

---

## 0 · Antes de arrancar

| | Qué | Estado |
|---|---|---|
| 0.1 | Backup de saves etiquetado (`Backup-NMSSave.ps1`) — **lo corro yo, no hay que pedirlo** | ⬜ |
| 0.2 | **Desinstalar `NoDerelictMiniHorrors`** si se va a mirar un carguero abandonado. Quita `GcAlienPodComponentData` y el `DestroyedModel` de dos nidos: con él puesto, los cargueros que veas **no son vanilla** | ⬜ |
| 0.3 | Usar el save de pruebas, no la partida principal | ⬜ |
| 0.4 | Planeta con vida `Full` — sin eso no hay fauna terrestre y media prueba no aplica | ⬜ |

---

## 1 · Marcadores de UI — la ruta nueva de 0.3.1

| # | Qué se prueba | Cómo | Esperado | ⬜ |
|---|---|---|---|---|
| 1.1 | `ShowOnscreenPredatorMarkers = false` (#58) | Dejar que un depredador te cace en campo abierto | **Ningún icono** sobre él. Te cae encima sin aviso | ⬜ |
| 1.2 | `FiendOnscreenMarkers = false` (#17) | Romper un huevo y esperar la oleada | Ningún icono sobre los Horrores | ⬜ |
| 1.3 | **El cursor del menú** — testigo del conflicto con `Small Cursor 6.6` | Abrir el menú rápido y mirar el tamaño del cursor | Sigue **pequeño**. Si vuelve al tamaño vanilla, nuestro MBIN de `GCUIGLOBALS` está pisando el EXML del otro mod | ⬜ |
| 1.4 | Que el escáner no se rompa | Escanear un huevo de Fiend | Sale su nombre y sigue valiendo para la misión (`FIENDCORE`) | ⬜ |

> 1.3 es gratis y es la única prueba que tenemos de si dos mods pueden compartir
> `GCUIGLOBALS`. Mirarlo aunque no se pruebe nada más.

---

## 2 · Que no suelten la presa — el bloque grande de 0.3.1

| # | Qué se prueba | Cómo | Esperado | ⬜ |
|---|---|---|---|---|
| 2.1 | `FiendPerceptionDistance` 120 (#18) | Romper un huevo y **quedarse quieto a ~110 m** de otro nido sin tocar | Los de ese nido también te fijan | ⬜ |
| 2.2 | `FiendAggroDecreasePerSpawn` 0.0 (#53) — **la causa de fondo** | Romper un huevo, dejar salir la oleada entera y **no matar a ninguno** | El aggro **no se vacía solo**. Siguen viniendo | ⬜ |
| 2.3 | `FiendAggroTime` 600 (#16) | Cronometrar desde que te pierden de vista | Te buscan **minutos**, no dos | ⬜ |
| 2.4 | `FiendDespawnDistance` 300 (#57) | Correr 200 m en línea recta | **No se evaporan** al pasar de 150 m | ⬜ |
| 2.5 | `FiendBeingShotMemoryTime` 60 (#56) | Disparar a uno y esconderse | Ese en concreto sigue pegado a ti ~1 min | ⬜ |
| 2.6 | `FiendMaxEngaged` 16 / `MaxAttackers` 8 (#13-14) | Contar cuántos te rodean y cuántos pegan | Deja de haber Horrores «mirando» a distancia sin entrar | ⬜ |

---

## 3 · Movimiento — se estrena 0.3.0 aquí

| # | Qué se prueba | Cómo | Esperado | ⬜ |
|---|---|---|---|---|
| 3.1 | **Zigzag: la prueba que separa las causas** | Mirar **un Horror SOLO**, no una oleada | Si uno suelto viene derecho → la causa era el steering/giro (#44-45). Si sigue haciendo eses solo → ninguno de los dos, y toca mirar `PathOverestimate` / `FlowFieldWeight` | ⬜ |
| 3.2 | Sin acechar (#40-42) | Dejarte ver a ~35 m en campo abierto | Arranca **sin pausa** y no se para a mitad | ⬜ |
| 3.3 | Horda (#46-50) | Manada de 5-7 depredadores | Llegan **como un bloque**, ni en fila india ni desperdigados | ⬜ |
| 3.4 | Árbol `MELEE` (#51-52) | Ver la llegada del golpe | Cierran en `Fast` y **no frenan** encima de ti | ⬜ |
| 3.5 | **Rendimiento** con `SteeringUpdateRate` 0.10 | Zona con muchos bichos, mirar FPS | Si cae, **éste es el primero que se revierte** | ⬜ |

---

## 4 · Lo que puede salir mal — sin respaldo vanilla

| # | Qué se prueba | Cómo | Esperado | ⬜ |
|---|---|---|---|---|
| 4.1 | `AllowSpawnBrood` (#27-29) | **Hace falta un sitio con Horrores pero sin huevos cerca**: con huevos ×20 una cría es indistinguible de un recién eclosionado | Aparecen `BUGFIEND` de la nada cada ~10 s. Si no: probar `SpawnBroodAnim = BIRTHING`; si tampoco, revertir el brood entero | ✅ **FUNCIONA** — ver abajo |
| 4.2 | `SCUTTLER_PET` intacta | Sacar la mascota domesticada | Se comporta igual que antes. Los anclajes `_id="FIEND"` la protegen | ⬜ |
| 4.3 | Que escapar siga siendo posible | Percepción 80 + aburrimiento 150 en depredadores | Si es imposible escapar: **subir el aburrimiento**, no bajar la percepción | ⬜ |
| 4.4 | Gusano a 10 m (#22) | Cruzar una zona con `WORMSPAWNER` | Sale cuando ya lo tienes encima, no a 100 m | ⬜ |

---

### ✅ 4.1 resuelta el 2026-08-09 — el brood funciona

Observado en partida: rompes un huevo, salen los Horrores, y **al rugir llaman a una
segunda tanda** que no venía del huevo. Eso es `AllowSpawnBrood`, y cierra tres preguntas
que llevaban abiertas desde `COMPORTAMIENTO.md` §3:

| Pregunta abierta | Respuesta |
|---|---|
| ¿`SpawnBroodID = BUGFIENDS` resuelve fuera del contexto de `BUGQUEEN`? | **Sí.** Es un identificador de grupo global, no algo atado a la reina |
| ¿Hacía falta `SpawnBroodAnim = BIRTHING`? | **No.** `ROAR`, que es lo que el `FIEND` ya traía, dispara el parto igual. **Un cambio por intento, y el primer intento valió** |
| ¿`AllowSpawnBrood` es un interruptor suelto o necesita compañía? | Suelto. A diferencia de `AllowPushBackAttack` —que sí necesita `PushBackAttackFrame`— aquí bastó el booleano + ID + timer |

**Consecuencia directa, y es lo que motiva 0.3.3:** las crías son entradas `BUGFIEND` del
datatable, no `FIEND`. Salían con estadísticas **vanilla** (2-4 golpes, salto 2.0 s, anim
1.0) mientras sus padres iban a 3-6 / 1.2 / 1.2. 0.3.3 las iguala.

`AllowSpawnBrood` sale de la lista de reversión: **deja de ser el cambio con menos respaldo
vanilla, ya es un cambio verificado en partida.**

## 5 · Orden de reversión si algo va mal

1. `SteeringUpdateRate` (#44) — si caen los FPS.
2. `MaxTurnRadius` (#45) — si se atascan en el terreno o giran raro.
3. Las dos filas del árbol `MELEE` (#51-52) — si la IA de ataque hace algo extraño.
4. ~~`AllowSpawnBrood` (#27-29) — es el cambio con menos respaldo vanilla.~~
   **Verificado en partida el 2026-08-09. Ya no es candidato a revertir.**

## 6 · Al terminar

- Anotar resultados en `CHANGELOG-MOD2.md` bajo 0.3.1, **con la versión de NMS**.
- Quitar los `[SIN PROBAR]` que hayan pasado en `MODIFICACIONES.md`.
- Si algo se revierte, moverlo a la tabla «Retirado» con el motivo.
