# `pruebas/` — experimentos de una sola pregunta

Mods que no se publican. Cada uno existe para contestar **una** pregunta y luego se
desinstala. Si algo de aquí funciona, se reescribe limpio en la carpeta que le toque.

---

## Qué hay

| `.lua` | Pregunta única | Archivos que escribe | Estado |
|---|---|---|---|
| `HT_LocatorTest_PRUEBA01` | ¿Cuelga el locator `TENTACLE_` una escena que no sea la suya? | los **3 `.LSYSTEM`** de edificio abandonado | 🟡 desplegado, sin leer |
| `HT_CeilingPlague_PRUEBA01` | ¿Se puede colgar del techo el nido del carguero **sin tocar el `.LSYSTEM`**? | **1**: `INTERIOR_TENTACLEPLANT.SCENE.MBIN` | ✅ contestada — jugado el 17/08. **Sí llega, pero flota** |
| `HT_CeilingPlague_PRUEBA02` | ¿Se pega al techo quitando el giro de la planta y bajando el nodo 4 m? | **1**: el mismo | 🏁 contestada — jugado el 20/08. **Sí.** De sitio, cerrado. Retirada el 21/08 porque la `03` la contiene |
| `HT_CeilingPlague_PRUEBA03` | ¿Llama Horrores romper el nido, como romper un huevo de suelo? | **2**: el mismo **+** `MEDIUMHANGSLIME.ENTITY.MBIN` | ⬜ desplegada el 21/08, sin medir |
| `HT_PredatorParts_PRUEBA01` | ¿Sirve podar el `.DESCRIPTOR` de un depredador? | `TREX.DESCRIPTOR.MBIN` | ✅ contestada — jugado el 09/08 |

> ⚠️ **`LocatorTest` y `CeilingPlague` no pueden estar puestos a la vez.** No chocan por
> archivo —tocan archivos distintos—, sino porque el primero **tapa** al segundo: pone
> `DEBRISLARGE_COMMON` al 100 % en el mismo locator del que cuelga el prop que el segundo
> modifica. Con los dos puestos, el cambio de `CeilingPlague` no se ve.

## `HT_CeilingPlague_PRUEBA01` — por qué es distinto de todo lo anterior

Las intentonas previas de meter algo en los edificios abandonados iban por el `.LSYSTEM`:
cambiar el `Model` de la entrada `TENTACLE_`. Ésta no.

`INTERIOR_TENTACLEPLANT.SCENE.MBIN` **no tiene ni un nodo `MESH`**. Es un envoltorio:

```
INTERIOR_TENTACLEPLANT.SCENE      MODEL
└ ObjectSpawner                   LOCATOR    ATTACHMENT -> OBJECTSPAWNER.ENTITY.MBIN
  └ TentacleRef                   REFERENCE  SCENEGRAPH -> …\ABANDONED\TENTACLEPLANT.SCENE.MBIN
                                             RotZ = 180      <- por eso cuelga boca abajo
```

Se cambia **ese `SCENEGRAPH`** por `MEDIUMHANGSLIME.SCENE.MBIN`, el nido colgante del
carguero. Tres ventajas que ninguna intentona anterior tenía:

1. **El `.LSYSTEM` se queda vanilla.** La regla del 30 % y el locator no se tocan.
2. **El giro de 180° se conserva**, porque vive en el envoltorio y no en la escena apuntada.
   Ésa es además la hipótesis de por qué el huevo de 0.3.2 desapareció: al sustituir desde el
   `.LSYSTEM` se tiraba el envoltorio y con él la compensación de giro.
3. **Llega a las seis estructuras de golpe** — los 3 edificios de superficie y sus 3
   variantes `UNDERWATER_` — porque cualquiera que cuelgue ese prop hereda el cambio.

Y el nido no viene solo: su `.ENTITY` trae `GcDestructableComponentData` (Health 600,
explosión `INFESTPILLAREXP`, recompensa `DE_FATSLIME`, modelo destruido),
`GcShootableComponentData`, `GcScannableComponentData` y `GcAlienPodComponentData` — la
mecánica de que el nido te huele. Esa `.ENTITY` **ya la retoca `HorribleTerror_Infestation`**,
así que hereda gratis el `AgroTorch` y el `GunfireAgro` que la 0.3.2 encendió.

Detalle completo: [`../../../docs/ASSETS.md`](../../../docs/ASSETS.md) §5.7.

## 🔓 2026-08-17 — la `PRUEBA01` contestó que sí, y de paso dijo por qué flotaba

**El nido llega.** El `SCENEGRAPH` del envoltorio se puede cambiar y el juego carga la escena
nueva: la vía queda abierta y `N1` deja de ser un bloqueo. Capturas en
`asset/Pruebas/HT_CeilingPlague_PRUEBA01_0{1..4}.jpg`.

**Pero sale flotando**, y la causa está medida, no supuesta. Se sacó el `MEDIUMHANGSLIME` del
`.pak` y se leyeron sus vértices (`MeshPositionDataStream`, half x4, stride 16, los seis
submallas):

| | Y mín | Y máx | Qué hay ahí |
|---|---:|---:|---|
| Modelo entero | 0,00 | **4,11** | todo **por encima** del origen |
| Carne abierta y ancha | 3,4 | 4,0 | la parte que **pega en el techo** |
| Tronco | 1,2 | 3,4 | |
| Vaina con los huevos | 0,0 | 1,0 | **el origen está aquí** |

Y el locator del edificio, leído de `LAYOUT_ABANDONED1..5.SCENE`: `Tentacle_` está en
**Y ≈ 6,45 – 6,83**, con la sala llegando hasta 7,20. O sea, pegado al techo.

**El envoltorio traía `RotZ 180` para la planta vanilla**, que crece hacia arriba (0 → 15,4)
y con el giro cuelga. El nido del carguero es **al revés**: ya viene modelado colgando, con
la carne arriba y el origen en la vaina. Aplicarle los mismos 180° lo pone del revés — la
vaina se mete en el techo y la carne queda flotando en el aire a 2,45 m.

| | Carne | Vaina |
|---|---|---|
| `RotZ 180` — la `PRUEBA01` | flotando a **2,45 m** | metida en el techo |
| `RotZ 0` a secas | 4 m **por encima** del techo, no se ve | pegada al techo |
| **`RotZ 0` + `TransY −4`** — la `PRUEBA02` | **a ras del techo** | colgando a **2,45 m del suelo** |

Los dos cambios van juntos **a propósito**: por separado ninguno deja el nido donde toca, y
el `.GEOMETRY` ya dijo cuál de los dos falla si sale mal. **Jugado el 20/08: la fila de abajo
es la buena**, y de posición no se toca nada más.

## `HT_CeilingPlague_PRUEBA03` — el campo que hace brotar

La `03` **contiene entera a la `02`** y añade un solo campo, en un segundo archivo. El nido
del techo ya venía cableado como un huevo de Horror y solo tenía el interruptor apagado:

| `GcDestructableComponentData` | Huevo de suelo (`FIENDEGG`) | Nido del techo (`MEDIUMHANGSLIME`) |
|---|---|---|
| `IncreaseFiendWanted` | **`true`** | era **`false`** ← lo único que se toca |
| `IncreaseFiendWantedChance` | `1.0` | `1.0` |
| `IncreaseFiendCrime` | `EggDestroyed` | `EggDestroyed` |
| `Explosion` | `FIENDHATCH` | `INFESTPILLAREXP` — **se deja**, se mide si brotan, no cómo revienta |

Los Horrores no salen del prop: los suelta el sistema de *fiend wanted* al cometerse el crimen
`EggDestroyed`. Y el nido ya traía con qué reaccionar — locator `SPAWNPOS_`,
`GcShootableComponentData`, escena `_DESTROYED` propia y un `GcAlienPodComponentData` con agro
por movimiento a 8,5 m, linterna a 10 m y disparo a 20 m—: le faltaba la consecuencia.

> ⚠️ **El `.ENTITY` lo comparte la infestación de cargueros abandonados.** Encenderlo aquí lo
> enciende también allí. Es deliberado, y es **la mitad de lo que hay que mirar**: si salen a
> manadas donde no toca, se vuelve a la `PRUEBA02`, que solo escribe el primer archivo.

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


> El `.ENTITY` vive en `NMSARC.MetadataEtc.pak`, **no** en el `NMSARC.EntitySceneMBIN.pak`
> donde está el `.SCENE`. El filtro de `hgpaktool` es un **glob**: `-f "*mediumhangslime*"`
> encuentra, `-f "mediumhangslime"` da cero.

## Qué mirar cuando se pruebe

| Si se ve… | Entonces |
|---|---|
| El nido colgando del techo, destruible y escaneable | ✅ la vía queda abierta, y `N1` deja de ser un bloqueo |
| Nada en el techo, ni la planta ni el nido | El envoltorio no resuelve un `SCENEGRAPH` cambiado. Vuelve `N1` |
| La planta de siempre | El cambio no llegó: mirar si `HT_LocatorTest_PRUEBA01` sigue puesto |
| El nido pero atravesado o boca arriba | La escena del carguero espera otra orientación. Se ajusta el `RotZ` del envoltorio |

> Los `.lua` van **sin comentarios** y con `MOD_AUTHOR` **AldrichDDD**. La explicación vive
> aquí. Cola y estado de cada prueba:
> [`../../../docs/PENDIENTES.md`](../../../docs/PENDIENTES.md) §2.
