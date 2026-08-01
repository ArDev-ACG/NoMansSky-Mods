# Mod 2 — Infestación (Horrores Biológicos)

Mod nuevo, versionado aparte, arrancando en **0.1.0**. No es una actualización del
mod 1: es otro mod que reutiliza su calibración.

| | Mod 1 | Mod 2 |
|---|---|---|
| Nombre | `HorribleTerror_Predators` | `HorribleTerror_Infestation` |
| Versión | 1.0.0 | 0.1.0 |
| Qué hace | dificultad de depredadores | lo del mod 1 **+** los Fiends |
| Página de Nexus | la suya | la suya |

**El mod 2 contiene al mod 1.** Escriben los mismos archivos, así que instalar los
dos hace que uno pise al otro en silencio. En Nexus hay que decirlo en la primera
línea de las dos páginas.

---

## Las cuatro configuraciones

Se instala **una sola**.

| Parámetro | Vanilla | 1 Fácil | 2 Normal | 3 Difícil | 4 Hardcore |
|---|---|---|---|---|---|
| **Heredado del mod 1** ||||||
| Densidad terrestre | ×1 | ×2 | ×5 | ×20 | ×20 |
| Peso `DANGEROUS` | 1 | 3 | 10 | 1000 | 1000 |
| Manada min/max | 1/1 | 1/2 | 2/3 | 3/5 | 5/7 |
| Percepción depredador (m) | 40 | 45 | 50 | 60 | 80 |
| Huye al % de vida | 40 | 30 | 15 | 0 | 0 |
| % depredadores hostiles | 0.5 | 0.6 | 0.75 | 1.0 | 1.0 |
| Tope criaturas a la vez | 40 | 45 | 50 | 60 | 70 |
| Distancia de aburrimiento | 80 | 80 | 80 | 80 | 150 |
| **Nuevo: Fiends** ||||||
| Densidad de huevos | ×1 | ×2 | ×5 | ×20 | ×20 |
| `FiendMaxAttackers` | 2 | 2 | 3 | 4 | 6 |
| `FiendMaxEngaged` | 6 | 6 | 8 | 10 | 12 |
| `MaxFiendsToSpawn` | 6 | 6 | 8 | 10 | 12 |
| `FiendAggroTime` (s) | 45 | 45 | 60 | 90 | 120 |

Fácil no escribe ningún global de Fiend: los cuatro valores coinciden con vanilla y
escribirlos ensuciaría el EXML delta sin cambiar nada. Solo multiplica los huevos.

---

## Conteo de cambios esperado por tier

Si `REPORT` no da estos números, algo no encajó y **no se despliega**.

| Tier | Total | Desglose |
|---|---|---|
| 1 Fácil | **23** | 5 + 4 + 4 globals + 4 eggs + 6 infest |
| 2 Normal | **27** | 5 + 4 + 8 globals + 4 eggs + 6 infest |
| 3 Difícil | **27** | 5 + 4 + 8 globals + 4 eggs + 6 infest |
| 4 Hardcore | **28** | 5 + 4 + 9 globals + 4 eggs + 6 infest |

Hardcore lleva un global de más porque es el único tier que toca
`PlayerPredatorBoredomDistance`.

**Construidos y verificados el 2026-08-01** contra NMS 170671 / MBINCompiler 6.45.0.1:
los cuatro dan 23 / 27 / 27 / 28 con 0 errores, 0 warnings y 0 notices, y los deltas
se comprobaron propiedad por propiedad contra la tabla de configuraciones.

---

## Rutas que toca

```
METADATA\SIMULATION\ECOSYSTEM\CREATUREGENERATIONDATA.MBIN
METADATA\SIMULATION\ECOSYSTEM\GROUND\GROUNDTABLEPLAYERPREDATORMED.MBIN
METADATA\SIMULATION\ECOSYSTEM\GROUND\GROUNDTABLEPLAYERPREDATORLARGE.MBIN
GLOBALS\GCCREATUREGLOBALS.MBIN
METADATA\SIMULATION\SOLARSYSTEM\BIOMES\OBJECTS\RARE\FIENDEGGS.MBIN
METADATA\SIMULATION\SOLARSYSTEM\BIOMES\OBJECTS\RARE\INFESTATION.MBIN
```

Escaneo de conflictos del **2026-07-30** sobre los 87 mods de terceros instalados:
`FIENDEGGS`, `INFESTATION` y `CREATUREDATATABLE` están **libres**. La única ruta
disputada es `GCCREATUREGLOBALS`, y solo contra nuestro propio mod 1.

---

## La trampa de los dos bloques de densidad

Lo más importante de este mod y lo más fácil de romper.

Cada objeto de `FIENDEGGS` / `INFESTATION` lleva **dos** bloques de densidad:

- `QualityVariants` → los valores reales, distintos por objeto.
- `QualityVariantData` → `Coverage 0.2` / `FlatDensity 0.5`, **idéntico en los cinco
  objetos de los dos archivos**. Tiene pinta de struct por defecto, no de dato real.

Multiplicar `FlatDensity` a secas tocaría los dos. Por eso los scripts usan
`VALUE_MATCH`: solo se multiplican las ocurrencias cuyo valor actual es el de vanilla
del bloque bueno.

`Coverage` **no se toca**. Los valores reales son 0.1, 1.0 y 2.0, y no sabemos el
rango válido del campo — ×20 sobre 2.0 podría salirse.
`FlatDensity`/`SlopeDensity` son la palanca de densidad de verdad.

---

## La trampa de orden (encontrada al construir, 2026-08-01)

Las reglas de un mismo archivo se aplican **en secuencia** sobre el MXML, así que un
valor ya escrito puede encajar en el `VALUE_MATCH` de una regla posterior.

En Normal (`EGG_MULT = 5`) pasó exactamente eso: la regla de huevos subía
`0.005 → 0.025`, y la del gusano (`VALUE_MATCH 0.025`) los volvía a multiplicar.
`FlatDensity` de los huevos acabó en **0.125 = ×25** en vez de ×5, y el `REPORT` dio
**29** cambios en vez de 27.

Fácil (×2 → 0.010) y Difícil/Hardcore (×20 → 0.100) no colisionaban: el bug solo
aparecía en Normal. Un conteo por tier es lo que lo delató.

**El arreglo:** en `INFESTATION` el gusano va **primero** y los huevos **últimos**. La
salida del gusano es `0.025·M` / `0.030·M`, que para cualquier M ≥ 1 nunca vale 0.005,
así que no puede contaminar la regla de los huevos; y la de los huevos, al ir última,
no contamina nada. Si algún día se añade una cuarta regla a este archivo, hay que
comprobar que su `VALUE_MATCH` no coincida con ninguna salida de las anteriores.

---

## Valores vanilla verificados

NMS 170671, MBINCompiler 6.45.0.1, extraídos de `NMSARC.Precache.pak` el 2026-07-30.

**`FIENDEGGS.MBIN`** — 2 objetos, los dos `FIENDEGG.SCENE`:

| Objeto | Placement | FlatDensity | SlopeDensity | Coverage |
|---|---|---|---|---|
| `Objects[0]` | `FLORACLUMP` | 0.005 | 0.005 | 0.1 |
| `DetailObjects[0]` | `RAREX` | 0.005 | 0.005 | 2.0 |

**`INFESTATION.MBIN`** — 3 objetos:

| Objeto | Modelo | Placement | FlatDensity | SlopeDensity | Coverage |
|---|---|---|---|---|---|
| `WORMSPAWNER` | `GROUNDWORMSPAWNER` | `WORDSTONE` | 0.025 | 0.030 | 1.0 |
| `FIENDEGGS` | `FIENDEGG` | `FLORACLUMP` | 0.005 | 0.005 | 0.1 |
| (sin nombre) | `FIENDEGG` | `RAREX` | 0.005 | 0.005 | 2.0 |

---

## Cómo cambiar de configuración

1. Borrar la carpeta del tier actual de `GAMEDATA\MODS\`.
2. Poner el `.lua` del tier nuevo en `tools\AMUMSS\ModScript\`.
3. Correr `BUILDMOD.bat` en modo FULL.
4. Comprobar el conteo de `REPORT` contra la tabla de arriba.
5. Copiar la carpeta de `CreatedMODS\` a `GAMEDATA\MODS\`.

NMS solo carga mods **al arrancar**. No sirve cambiar con el juego abierto.

---

## Aplazado a 0.2.0

- **`CREATUREDATATABLE.MBIN`** — es donde vive `GcCreatureFiendAttackData`, con 8
  bloques (uno por variante: `FIEND`, `BUGFIEND`, `MINIFIEND`, `FIENDFISHSMALL`,
  `FIENDFISHBIG`) más 2 de `GcCreatureSpookFiendAttackData`. Ahí están
  `MinFlurryHits`/`MaxFlurryHits` (2/4), `DelayBetweenPounceAttacks` (2.0) y
  `DelayBetweenSpitAttacks` (1.0). La ruta está libre. Se deja fuera de 0.1.0 para no
  meter demasiadas variables sin probar de golpe.
- **`AllowSpawnBrood = true`** — bichos que se multiplican mientras luchas. Está
  implementado y apagado en vanilla. `SpawnBroodID` viene vacío y no sabemos qué
  acepta. Requiere su propia sesión de pruebas.
- **`MaxFiendsToSpawnCarnage = 10`** — hay un modo "carnage" y no sabemos qué lo
  dispara.
