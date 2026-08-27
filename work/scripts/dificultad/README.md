# Mod 1 — More Aggressive Predators · Conducta · 4 configuraciones

> **En Nexus se llama `More Aggressive Predators`** desde 2.1.0. Las carpetas y los
> `MOD_FILENAME` siguen siendo `HorribleTerror_Predators_<tier>` y **no se renombran**:
> el mod está publicado con ese nombre y renombrarlo dejaría dos carpetas en
> `GAMEDATA\MODS\` a quien actualice. Ver [`../../../docs/NEXUS.md`](../../../docs/NEXUS.md).

**Todo lo que se mueve, caza y ataca.** Depredadores de fauna procedural **y** Horrores
Biológicos, en el mismo mod y con la misma escala de dificultad.

## Su sitio en el proyecto — 2026-08-09

**El mod 2 contiene a este mod.** Se instala uno **o** el otro, nunca los dos: escriben los
mismos 7 archivos.

| | Mod 1 · este | Mod 2 · Infestación |
|---|---|---|
| Versión | **2.1.0** | 0.6.4 |
| Qué es | la conducta sola | la conducta + el mundo + (pronto) los modelos |
| Rutas | 7 | 12 |
| **Instalado en la máquina** | **no** | **sí** |

**Para quién es este mod:** quien quiera solo la dificultad, sin huevos por todas partes ni
monstruos nuevos. Es el producto de entrada; el mod 2 es el completo.

**Lo que va a diferenciar al mod 2 no es el tipo de campo, son los modelos de los
monstruos.** La conducta la comparten por definición.

> ⚠️ **En 0.4.0 se probó repartirlos por tipo de cambio** —conducta aquí, colocación allí,
> para poder instalar los dos a la vez— y **se revirtió el mismo día**. Queda anotado para no
> volver a proponerlo.

⚠️ **Este es el archivo fuente de la conducta.** El mod 2 se compone como *bloques de este
mod + bloques de mundo*. Si aquí cambia un valor y no se recompone el mod 2, los dos mods se
separan en silencio. El conteo lo delata: mod 2 = este + 10 (+ 40 en Hardcore).

## ⚠️ Instala UNA sola de las cuatro

Las cuatro escriben los mismos archivos. Dos activas hacen que una pise a la otra en
silencio. Lo mismo al construir: **solo una en `ModScript\` a la vez** — `Build-Tiers.ps1`
ya se encarga.

## Las cuatro configuraciones

| Parámetro | Vanilla | 1 Fácil | 2 Normal | 3 Difícil | 4 Hardcore |
|---|---|---|---|---|---|
| **Depredadores de fauna** ||||||
| Densidad terrestre | ×1 | ×2 | ×3 | ×20 | ×20 |
| Peso `DANGEROUS` | 1 | **—** | **4** | 1000 | 1000 |
| → % planetas hostiles | 9% | **9%** | **27%** | 99% | 99% |
| Manada min/max | 1/1 | 1/2 | **1/2** | 3/5 | 5/7 |
| Percepción (m) | 40 | 45 | 50 | 60 | 80 |
| Huye al % de vida | 40 | **—** | **25** | 0 | 0 |
| % depredadores hostiles | 0.5 | **—** | **0.6** | 1.0 | 1.0 |
| Tope criaturas a la vez | 40 | 45 | 50 | 60 | 70 |
| Distancia de aburrimiento | 80 | 80 | 80 | 80 | 150 |
| **Presión de los Horrores** ||||||
| `FiendMaxAttackers` | 2 | — | 3 | 4 | **8** |
| `FiendMaxEngaged` | 6 | — | 8 | 10 | **16** |
| `MaxFiendsToSpawn` | 6 | — | 8 | 10 | **16** |
| `FiendAggroTime` (s) | 45 | — | 60 | 90 | **600** |
| **Sentidos y marcadores** ||||||
| Marcador de UI del Fiend | sí | — | sí | **NO** | **NO** |
| `ShowOnscreenPredatorMarkers` | sí | — | — | — | **NO** |
| `FiendPerceptionDistance` (m) | 60 | — | 65 | 70 | **120** |
| **Eclosión y separación** ||||||
| Eclosión min/max (s) | 0.25/3.0 | — | 0.2/2.0 | 0.15/1.0 | 0.1/0.5 |
| `AvoidCreaturesWeight` | 6 | — | 8 | 10 | 10 |
| Radio activación gusano (m) | 100 | — | 50 | 20 | 10 |
| **Ataque del `FIEND`** ||||||
| Golpes por racha | 2/4 | — | 2/4 | 3/5 | 3/6 |
| Cadencia del salto (s) | 2.0 | — | 1.8 | 1.5 | 1.2 |
| Velocidad de ataque | 1.0 | — | 1.0 | 1.1 | 1.2 |
| Se multiplican | no | — | no | no | **SÍ** (`BUGFIENDS`, timer 10, `ROAR`) |
| **Crías `BUGFIEND`: las mismas armas que el padre** ||||||
| Golpes por racha | 2/4 | — | — | — | **3/6** |
| Cadencia del salto (s) | 2.0 | — | — | — | **1.2** |
| Velocidad de ataque | 1.0 | — | — | — | **1.2** |
| Se multiplica | no | — | — | — | **no**, a propósito |
| **Movimiento: sin acechar** ||||||
| `PredatorNoticePauseTime` (s) | 1.5 | — | 0.8 | 0.3 | **0.0** |
| `PredatorApproachTime` (s) | 4.0 | — | 2.0 | 0.5 | **0.0** |
| `PredatorChargeDist` (m) | 7 | — | 12 | 25 | **40** |
| `PredatorEnergyUseChasing` | -0.1 | — | -0.05 | **0.0** | **0.0** |
| **Movimiento: derechos** ||||||
| `SteeringUpdateRate` (s) | 0.25 | — | 0.20 | 0.15 | **0.10** |
| `MaxTurnRadius` (m) | 5.0 | — | 4.0 | 3.0 | **2.0** |
| **Movimiento: horda** ||||||
| `FollowLeaderCohereWeight` | 0.1 | — | 0.4 | 0.8 | **1.2** |
| `FollowLeaderAlignWeight` | 1.0 | — | 1.5 | 2.5 | **3.5** |
| `SpherePusherWeight` S/M | 10 | — | 9 | 7 | **5** |
| `SpherePusherWeight` L | 5 | — | 4.5 | 4 | **3** |
| **Árbol `MELEE`** ||||||
| `BehaviourMoveSpeed` | Normal | — | Normal | **Fast** | **Fast** |
| `DynamicMoveSlowdownDistMul` | 4.0 | — | 3.0 | 2.0 | **1.0** |
| **Tenacidad** ||||||
| `FiendAggroDecreasePerSpawn` | 0.1 | — | — | — | **0.0** |
| `FiendAggroIncrease` Damage/DestroyEgg | 1.0 | — | — | — | **3.0** |
| `FiendBeingShotMemoryTime` (s) | 10 | — | — | — | **60** |
| `FiendDespawnDistance` (m) | 150 | — | — | — | **300** |
| **Interiores de carguero** ||||||
| `FreighterSpawnDist` (m) | vanilla | — | — | — | **60** |
| `FreighterDespawnDist` (m) | vanilla | — | — | — | **150** |
| `FiendSpawnDistance` (m) | vanilla | — | — | — | **120** |
| Nido: `AgroTorch` | 0 | — | — | — | **12** |
| Nido: `GunfireAgro` | 0 | — | — | — | **8** |

**Fácil no toca ni un campo de Fiend.** Escribir su valor vanilla ensuciaría el EXML delta
sin cambiar nada — mismo criterio que `PlayerPredatorBoredomDistance` en los tres primeros
tiers.

**Fácil** — vanilla con un empujón. **No cambia qué planetas son hostiles ni cuántos
depredadores van a por ti**: solo hay más fauna, salen de dos en dos y te ven un poco antes.
**Normal** — uno de cada cuatro planetas hostil, y los Horrores ya vienen derechos y en grupo.
**Difícil** — casi todo planeta hostil, nunca huyen, y los Horrores pierden el marcador.
**Hardcore** — manadas de 5-7, detección a 80 m, y los Horrores se multiplican al rugir sin
soltarte nunca.

## Conteo esperado por build

Si `REPORT` no da estos números, **no se despliega**.

| Config | Total | Desglose (gen + predtables + globals + nidos + uiglobals + árbol + datatable) |
|---|---:|---|
| 1 Fácil | **10** | 4 + 2+2 + 2 + — + — + — + — |
| 2 Normal | **35** | 5 + 2+2 + 24 + — + — + 1 + 1 |
| 3 Difícil | **40** | 5 + 2+2 + 25 + — + — + 2 + 4 |
| 4 Hardcore | **61** | 5 + 2+2 + 34 + 2+2 + 1 + 2 + 11 |

**La suma con el mod 2 tiene que dar los totales de antes del reparto** — es la comprobación
de que la mudanza no perdió ni duplicó nada:

| Tier | Mod 1 | Mod 2 | Diferencia |
|---|---:|---:|---:|
| Fácil | 10 | 20 | **+10** |
| Normal | 35 | 45 | **+10** |
| Difícil | 40 | 50 | **+10** |
| Hardcore | 61 | 71 | **+10** |

> **Medido el 2026-08-18, los ocho builds del mismo día.** La comprobación ya no es contra
> los totales de `Infestation 0.3.3` —el mod 2 se movió a la 0.6.x y devolvió campos a
> vanilla por el camino—, sino contra **la diferencia**: el mod 2 añade exactamente **10
> campos de mundo por tier** sobre el mod 1, y esos 10 son siempre los mismos
> (`FlatDensity` y `SlopeDensity` del huevo y del gusano). Si esa diferencia deja de ser
> 10 en cualquier tier, los dos mods se han separado.

Los 11 `datatable` de Hardcore son 4 de `FIEND` + 3 del brood + 4 de `BUGFIEND`.

## Archivos que toca — 7 rutas

```
METADATA\SIMULATION\ECOSYSTEM\CREATUREGENERATIONDATA.MBIN
METADATA\SIMULATION\ECOSYSTEM\GROUND\GROUNDTABLEPLAYERPREDATOR{MED,LARGE}.MBIN
METADATA\SIMULATION\ECOSYSTEM\CREATUREDATATABLE.MBIN
METADATA\SIMULATION\ECOSYSTEM\CREATUREBEHAVIOURTREES.MBIN
GLOBALS\GCCREATUREGLOBALS.MBIN
GLOBALS\GCUIGLOBALS.GLOBAL.MBIN
MODELS\...\INFESTATION\{LARGEPILLARSLIME,MEDIUMHANGSLIME}\ENTITIES\*.ENTITY.MBIN
```

Fácil solo toca 3: no necesita `CREATUREDATATABLE`, `CREATUREBEHAVIOURTREES`, `GCUIGLOBALS`
ni los nidos.

**Ninguna la toca el mod 2.** Y de los 87 mods de terceros instalados, la única disputada es
`GCUIGLOBALS`, contra `Small Cursor 6.6` — ver la nota de convivencia MBIN/EXML en
[`CHANGELOG-MOD2.md`](../../../docs/CHANGELOG-MOD2.md).

## Las dos trampas que hay que respetar al editar

**1 · `CREATUREDATATABLE` tiene diez bloques `GcCreatureFiendAttackData`,** uno de ellos es
`SCUTTLER_PET` — la mascota del jugador. Cada regla va anclada:

```lua
["SPECIAL_KEY_WORDS"] = {"Id", "FIEND"},
["REPLACE_TYPE"]      = "ONCE",
```

`FIEND` está antes que `BUGFIEND` en el archivo (14804 vs 14988), así que `ONCE` para en la
correcta y buscar `"BUGFIEND"` no casa con el literal más corto.

**2 · `CREATUREBEHAVIOURTREES` comparte campos entre tres árboles.** `MELEE`, `RANGED_SPIT`
y `RANGED_FIRE` tienen los mismos nombres, y `0.000000` aparece por todo el archivo. Ancla
con `{"Id", "MELEE"}` + `ONCE`; `MELEE` es además el primer árbol.

`AvoidCreaturesStrength` se deja en 0.0 **a propósito**: subirlo separaría la manada, que va
contra el objetivo de que se muevan en horda.

## Cómo construir

```
tools\Build-Tiers.ps1 -Carpeta dificultad
```

Construye los 4 de una pasada y archiva cada salida en `build\dificultad_<fecha>\`.

Desplegar copiando los `.MBIN` de `tools\AMUMSS\ModBackups\<nombre>\` a
`GAMEDATA\MODS\<nombre>\`. **El EXML de `CreatedMODS` es un informe, no despliega nada.**
NMS solo carga mods **al arrancar**.

## Si hay que aflojar

Los parámetros **se multiplican entre sí**. Orden para bajar dificultad sin saltar de tier:

1. `PCT_HOSTILE` — el que más rinde y no cuesta rendimiento.
2. `PACK_MAX` — tamaño de manada.
3. `MAX_CREATURE` — el único con coste de FPS real.
4. `STEER_RATE` — 0.10 con densidad ×20 **nunca se ha medido con el contador de FPS**. Es la
   prueba 3.5 de [`PENDIENTES.md`](../../../docs/PENDIENTES.md), y la única que puede obligar
   a revertir algo por sí sola.
5. `DENSITY_MULT` — **el último**. Ya está topado por `MaxEcosystemCreatures`.
