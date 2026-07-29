# Proyecto: Mod Zombies / Monstruos NMS

Mod para No Man's Sky. Estilo criaturas podridas / Dead Space en planetas. Destino: Nexus Mods.

Doc de arranque. Roadmap + tools + estructura + riesgos.

---

## 1. Verdad dura (leer primero)

Monstruo nuevo animado desde cero = casi imposible hoy con tools públicas.

**Por qué:** NMS usa motor propietario. Modelos estáticos se importan. Pero rig/animación de criatura hacia el sistema de animación del juego NO es viable aún para movimiento robusto de bicho (caminar, atacar).

Fuente: wiki modding NMS, estado ~Sept 2025.

**Traducción:** puedes meter un modelo. No puedes hacerlo caminar/atacar como criatura viva por ahora.

[Inferencia] Basado en estado reportado del toolset público. Puede cambiar si sale plugin de animación nuevo.

---

## 2. Alcance realista

Elegir ruta. No pelear contra el límite.

### Ruta A — Modificar fauna existente (RECOMENDADA)
- Retextura de criaturas hostiles vanilla → look zombie / carne / podrido.
- Cambiar tamaño, color, comportamiento a depredador.
- Editar tablas de spawn por planeta / bioma.
- Ya reusa animaciones vanilla. Funciona.

**A.1 — Paletas antes que texturas.** El color de fauna NMS sale en buena parte de
paletas (`TkPaletteTexture` / descriptors), no del DDS de la criatura. Cambiar la
paleta a tonos carne/putrefacto da look zombie **sin abrir Blender ni repintar DDS**.
Ruta mucho más barata. Probar esto ANTES de meterse a editar texturas.

**A.2 — La retextura es por RIG, no por criatura.** Ver §5b. Afecta a toda la fauna
que comparta ese rig en el universo entero. Para "infestación global" está perfecto.
Para "este bicho concreto" no sirve.

### Ruta B — Props estáticos custom
- Modelo tipo Dead Space como objeto decorativo / punto de interés.
- Sin animación real. Solo adorno de planeta.

### Ruta C — Criatura nueva 100% animada
- [Inferencia] Bloqueada por límite de animación. NO empezar aquí.
- Revisar de nuevo solo si aparece tool de animación.

**Decisión proyecto:** empezar por Ruta A. Sumar Ruta B después. Ruta C = descartada por ahora.

---

## 3. Toolset

Todo gratis.

| Tool | Función | Fuente |
|---|---|---|
| AMUMSS | Mod builder con scripts lua. Auto-actualiza MBINCompiler. Núcleo del flujo. | GitHub `HolterPhylo/AMUMSS` + Nexus mod 2626 |
| MBINCompiler | Decompila/compila `.MBIN` ↔ `.EXML` (xml editable) | GitHub `monkeyman192/MBINCompiler` |
| NMS Modding Station / PSArc Tool | Desempaca archivos `.pak` | Nexus Mods |
| NMSDK | Plugin Blender. Importa/exporta modelos NMS | blender-addons / GitHub `monkeyman192/NMSDK` |
| Blender | Modelado + textura | blender.org |
| Notepad++ | Editar EXML (xml) | notepad-plus-plus.org |
| Paint.NET / GIMP / Photoshop | Editar texturas (DDS) | según preferencia |

**Nota AV:** antivirus puede marcar AMUMSS falso positivo. Crear excepción de carpeta.

---

## 4. Requisitos sistema

- Windows (flujo diseñado para Win).
- .NET Desktop Runtime x64. Requisito de MBINCompiler. AMUMSS intenta auto-instalar.
- 7-Zip (descomprimir release AMUMSS).
- Espacio disco: pocos GB. Ver nota abajo.

**CORRECCIÓN — no desempacar el juego entero.** El plan original reservaba decenas de
GB para un unpack masivo. No hace falta. AMUMSS extrae y decompila **solo** los MBIN
que tu script lua nombra. El unpack completo es flujo viejo, pre-AMUMSS.

Modding Station se usa solo para *explorar* y localizar rutas de archivo, no para
volcar el juego a disco. `unpacked\` queda como caché puntual, no como copia total.

[Unverified] Versión exacta de .NET cambia con updates. Confirmar en página de descarga de AMUMSS al instalar.

---

## 5. Formato interno NMS (glosario mínimo)

- `.pak` → paquete comprimido del juego. Se desempaca.
- `.MBIN` → binario del juego. No editable directo.
- `.EXML` → MBIN decompilado a xml. Formato **antiguo**.
- `.MXML` → **lo que genera MBINCompiler 6.45 por defecto.** Mismo rol que EXML,
  más compacto. Verificado: decompilar un MBIN produce `.MXML`, no `.EXML`.
  Los scripts lua usan la clave `MXML_CHANGE_TABLE`.
- `GEOMETRY.MBIN` → contiene modelo 3D (malla).
- `MATERIAL.MBIN` → texturas + shader del modelo.
- `SCENE.MBIN` → contenedor. Une malla + material + comportamiento. Como "prefab".
- `CREATUREGENERATIONDATA.MBIN` → reglas de spawn de fauna. Aquí se toca comportamiento/spawn.

- `TkPaletteTexture` / descriptors → paletas de color procedural. De aquí sale gran parte del color de fauna.

Flujo edición: `.pak` → desempacar → `MBIN` → decompilar → `EXML` → editar → recompilar → empacar `.pak`.

AMUMSS con lua automatiza casi todo esto.

---

## 5b. Cómo guarda NMS la fauna (importante)

Verificado en la instalación local. Las texturas de criatura van agrupadas **por rig**:

```
NMSARC.TexCreatureTREXRIG.pak        181 MB
NMSARC.TexCreatureTRICERATOPSRIG.pak 333 MB
NMSARC.TexCreatureCATRIG.pak         250 MB
NMSARC.TexCreatureSPIDERRIG.pak       88 MB
NMSARC.TexCreatureARTHROPOD.pak      332 MB
... (~25 rigs en total)
```

**Consecuencia:** la fauna es procedural. Partes + paletas montadas sobre assets
compartidos por rig. No existe "la textura del bicho X".

Editas `TexCreatureTREXRIG` → **todos** los T-rex del universo salen zombie. No hay
selección por criatura individual ni por planeta desde la textura.

**Para el mod esto es bueno** (queremos infestación global). Pero hay que decirlo
claro en la descripción de Nexus o llegan quejas de "cambió fauna que no quería".

El control por planeta/bioma sí existe, pero vive en el lado de spawn
(`CREATUREGENERATIONDATA`), no en el lado de textura.

---

## 5d. Cómo colorea NMS a las criaturas — VERIFICADO

Esto desbloquea la Fase 2 entera. **No existe "la textura del bicho X"**, y tampoco
existe "el color del bicho X". El color se resuelve en tres saltos:

```
1. TEXTURES\PLANETS\CREATURES\<RIG>\<parte>.TEXTURE.MBIN
      <Property name="Palette"   value="Scale" />     <- nombre, no color
      <Property name="ColourAlt" value="Primary" />
      <Property name="Index"     value="-1" />        <- -1 = elige por semilla

2. El nombre se resuelve contra el archivo de paletas del BIOMA:
      METADATA\SIMULATION\SOLARSYSTEM\BIOMES\<X>\<X>COLOURPALETTES.MBIN
      = cGcPaletteList con 64 paletas de 64 colores RGBA cada una

3. El juego elige un color dentro de esa paleta usando la semilla de la criatura.
```

**Callejones sin salida descartados** (comprobados, no supuestos): los
`.MATERIAL.MBIN` y `.DESCRIPTOR.MBIN` de criatura **no** contienen ninguna
referencia a paletas — cero coincidencias en los 75 materiales y 27 descriptores
del rig TREX. `CREATUREDATATABLE` tampoco. La única vía es la de arriba.

### Qué paletas usa la fauna — medido

Decompilados los **432** `.TEXTURE.MBIN` de `TEXTURES\PLANETS\CREATURES\` y contada
cada capa:

| Paleta | Usos | ¿Tocar? |
|---|---:|---|
| `Scale` | 1318 | ✅ |
| `Underbelly` | 512 | ✅ |
| `Fur` | 470 | ✅ |
| `Rock` | 402 | ❌ compartida con el terreno |
| `Feather` | 128 | ✅ |
| `Paint` | 113 | ❌ compartida con naves y edificios |
| `Undercoat` | 1 | ✅ |
| resto (Leaf, Plant, Crystal…) | <30 c/u | ❌ marginal |

Las cinco marcadas cubren ~84% de las capas de criatura y **solo** afectan a fauna.
`Rock` y `Paint` se dejan fuera a propósito: tocarlas teñiría rocas y naves, y
entonces no se sabría si el cambio afectó a la fauna o al mundo entero.

### Cuántos archivos hay que parchear: 47

Cada bioma trae su propia lista. Verificado: **los 47** `*COLOURPALETTES.MBIN` /
`*COLOURPALETTE.MBIN` contienen las 5 paletas de fauna, todos dentro de
`NMSARC.Precache.pak`. Parchear uno solo → fauna roja solo en ese bioma.

Se excluye `METADATA\GAMESTATE\PLAYERDATA\CUSTOMISATIONCOLOURPALETTES.MBIN`: es la
personalización del jugador, no fauna.

### `Underbelly` vs `BioShip_Underbelly` — falsa alarma, RESUELTO

De los 64 nombres de paleta, `Underbelly` es el único con colisión de subcadena:
existe también `BioShip_Underbelly` (naves vivientes). Se temía que
`PRECEDING_KEY_WORDS` cazara las dos.

**No ocurre.** Verificado sobre el EXML desplegado: el delta contiene exactamente
las 5 paletas pedidas y `BioShip_Underbelly` no aparece. `PRECEDING_KEY_WORDS`
empareja por **nombre exacto de sección**, no por subcadena.

Dato útil para futuros scripts: no hace falta blindar los PKW contra nombres de
propiedad que sean prefijo/sufijo de otros.

### Cómo verificar que un cambio de paletas salió bien

El conteo tiene que cuadrar exacto. Por archivo de bioma:

```
5 paletas x 64 colores x 3 canales (R,G,B) = 960 lineas '!# CHANGED'
```

Si sale más, el match se fue de sección. Si sale menos, alguna paleta no se
encontró. El alpha (`A`) no se toca nunca y no entra en la cuenta.

---

> **Referencia completa de fauna, arquetipos, roles, edificios y naves:**
> [`docs/FAUNA_REFERENCE.md`](docs/FAUNA_REFERENCE.md)
> Ahí está el detalle archivo por archivo. Lo de abajo es el resumen.

## 5c. Mapa del ecosistema — VERIFICADO

Todo vive en `METADATA\SIMULATION\ECOSYSTEM\`, dentro de `NMSARC.Precache.pak`.
Extraído a `unpacked\` y decompilado con MBINCompiler 6.45.0.1.

| Archivo | Para qué sirve en este mod |
|---|---|
| `CREATUREGENERATIONDATA` | densidad, probabilidad de vida, frecuencia de roles |
| `CREATUREGENERATIONARCHETYPES` | arquetipos de spawn — incluye `DANGEROUS` |
| `CREATUREROLEDESCRIPTIONTABLE` | roles por bioma |
| `CREATUREBEHAVIOURTREES` | árboles de comportamiento |
| `CREATUREAUDIOTABLE` | sonidos — para gruñidos zombie |
| `CREATUREDATATABLE` | 255 KB, el grueso de los datos de fauna |

### Parámetros globales de CREATUREGENERATIONDATA (valores vanilla)

```
GroundGroupsPerKm      Sparse 25   Normal 50   Dense 100   VeryDense 200
WaterGroupsPerKm       Sparse 30   Normal 60   Dense  80   VeryDense 100
AirGroupsPerKm         Sparse 10   Normal 20   Dense  30   VeryDense  40
CaveGroupsPerKm        Sparse 50   Normal 100  Dense 200   VeryDense 300
DensityModifiers       Sparse 0.5  Normal 1    Dense   2   VeryDense   4
RoleFrequencyModifiers Never 0     Low 0.2     Normal  1   High        5
RarityFrequencyModifiers  Common 10  Uncommon 3  Rare 1.2  SuperRare 0.9
LifeChance             Dead 0      Low 0       Mid     0   Full        1
LifeLevelDensityModifiers Dead 0   Low 0.4     Mid   0.7   Full      1.2
HerdCreaturePenalty    0.5
SandwormPresenceChance por bioma (Dead 0.3, Swamp 0.4, Red/Green/Blue 0.5...)
```

### ⚠️ Trampa: claves repetidas

`Sparse`/`Normal`/`Dense`/`VeryDense` aparecen **idénticas** en cinco secciones
distintas. Un cambio sin acotar las toca todas. En los scripts lua hay que usar
siempre `PRECEDING_KEY_WORDS` con el nombre de la sección.

### Arquetipos hostiles ya existentes (oro para el mod)

`CREATUREGENERATIONARCHETYPES` define, entre otros:

- `DANGEROUS` → `GROUNDTABLEPLAYERPREDATORMED.MBIN`, `GROUNDTABLEPLAYERPREDATORLARGE.MBIN`
- `HERD` → `GROUNDTABLEPREDATORLARGE.MBIN`
- `WRDROLLPRED`, `WRDCRYSTALPRED` → depredadores del bioma Weird

Es decir: **el juego ya trae depredadores que cazan al jugador**. No hay que
inventar comportamiento hostil, solo subir su peso en las tablas de spawn.
Encaja perfecto con la Ruta A.

## 6. Estructura de carpetas de trabajo

CREADA. Ruta real: `C:\Users\<usuario>\NMS_MOD_ZOMBIES\` — sin acentos, fuera de OneDrive. OK para AMUMSS.

```
C:\Users\<usuario>\NMS_MOD_ZOMBIES\
├── .git\                # repo local (solo fuentes propias)
├── .gitignore
├── tools\               [no-git]
│   ├── AMUMSS\
│   └── ModdingStation\
├── unpacked\            [no-git] caché puntual de MBIN extraídos
├── work\
│   ├── textures\        [no-git] DDS editados
│   ├── models\          [no-git] blend + exports
│   ├── palettes\        [git] paletas editadas — ruta barata al look zombie
│   └── scripts\         [git] .lua para AMUMSS ← el corazón del mod
├── build\               [no-git] salida .pak de prueba
├── releases\            [no-git] versiones limpias para Nexus
└── docs\                [git]
    ├── README.md
    ├── CHANGELOG.md
    ├── credits.md
    └── screenshots\
```

Blender se instala normal en Program Files, no dentro del proyecto.

Regla 1: nunca editar carpeta del juego a mano. Todo pasa por `build\` y se copia a `PCBANKS\MODS`.

Regla 2 (git): al repo van scripts lua, paletas y docs. **Nunca** assets del juego —
son de Hello Games, subirlos a repo público es redistribución no autorizada. El
`.gitignore` ya bloquea `.pak`, `.mbin`, `.exml`, `.dds`, `unpacked\`, `build\`, `tools\`.

---

## 7. Roadmap por fases

**CORRECCIÓN — fases 1 y 2 invertidas respecto al plan original.**
Motivo: retextura = Blender + DDS + material + paletas + compresión. Muchas piezas,
muchos puntos de fallo. Comportamiento/spawn = editar XML en texto plano. Una pieza.
Se empieza por lo textual: valida el pipeline completo en una tarde, sin tocar arte.

### Fase 0 — Setup (1 sesión) ← AQUÍ ESTAMOS
- [x] Crear estructura de carpetas + `.gitignore` + repo git.
- [x] Repo remoto: https://github.com/ArDev-ACG/NoMansSky-Mods
- [x] .NET Desktop Runtime x64 — ya estaba (6.0.36 / 8.0.29 / 9.0.18).
- [x] 7-Zip 26.02 instalado vía winget.
- [x] Backup de saves → `backups\NMS_saves_2026-07-29_0000\` (75 archivos, 14 MB).
- [x] AMUMSS v5.6.2.0W descargado → `tools\AMUMSS_5.6.2.0_FULL.7z` (56 MB).
      sha256 `4a2887f739e9c1a532e73b7fc7cf86b6de87aab6a152cb68d700f2d1cfd25c18`
- [x] AMUMSS extraído a `tools\AMUMSS\` — 714/714 archivos, íntegro.
- [x] `BUILDMOD.bat` corrido en modo FULL. **0 errores, 0 warnings.**
      MBINCompiler 6.45.0.1 descargado. McAfee no interfirió — no hizo falta excepción.
- [x] Análisis de conflictos con los 87 mods instalados: limpio (§10d).

**FASE 0 CERRADA.** Entorno vivo y verificado.
- [ ] Vaciar `PCBANKS\MODS` de mods ajenos antes de testear (ver §10).
- [ ] Editor de texto — opcional, Notepad++ o VSCode. No bloquea.
- [ ] Blender + NMSDK → aplazado a Fase 3. No bloquea nada antes.

**Meta:** entorno vivo. Un decompile de prueba OK.

### Fase 1 — Comportamiento + spawn (núcleo, era Fase 2) ← EN CURSO
- [x] Localizado: `METADATA\SIMULATION\ECOSYSTEM\CREATUREGENERATIONDATA.MBIN`,
      dentro de `NMSARC.Precache.pak`. Extraído y decompilado (§5c).
- [x] Script lua escrito: `work\scripts\HorribleTerror_GroundDensity.lua`.
      Multiplica x3 `GroundGroupsPerKm`. Copiado a `tools\AMUMSS\ModScript\`.
- [x] `BUILDMOD.bat` corrido: 4 cambios, 0 errores, 0 warnings. Mod desplegado
      solo a `GAMEDATA\MODS\HorribleTerror_GroundDensity\` (§10f).
- [x] Subido `DENSITY_MULT` a **20** (500/1000/2000/4000). Valor de prueba, no de
      release — a x20 el rendimiento puede sufrir. Para el mod final: 2-4.
- [x] Segundo script de validación: `work\scripts\HorribleTerror_RedFauna.lua`.
      Pinta de rojo carne las 5 paletas de piel en los 47 archivos de bioma (§5d).
- [x] **CONFIRMADO IN-GAME (2026-07-29).** Más fauna y roja. ← **EL HITO, CERRADO.**
      El pipeline completo funciona de punta a punta. Todo lo demás ya solo es
      elegir qué valores tocar.
- [x] Mod de color archivado y retirado del juego una vez validado (§10g).
      Se sigue con densidad sola para poder leer el efecto de los cambios de rol.
- [ ] Editar rol → forzar depredador / hostil (vía arquetipo `DANGEROUS`).
- [ ] Ajustar tamaño (más grande = más amenazante).
- [ ] Controlar en qué planetas/biomas aparecen.

**Meta real de Fase 1:** pipeline vivo (extraer→decompilar→editar→compilar→empacar→cargar)
demostrado con un cambio numérico. Todo lo demás depende de esto. Es EL hito.

**Meta ampliada:** "planeta infestado". Fauna hostil donde antes no la había.

### Fase 2 — Look zombie (era Fase 1)
- [x] **Cadena de color de fauna resuelta** (§5d). Las paletas son la vía y está
      mapeada: 5 paletas × 47 archivos. Sin Blender, sin DDS.
- [ ] Primero paletas (`TkPaletteTexture`) → tonos carne/putrefacto. Sin Blender.
- [ ] Si paletas no bastan → editar DDS del rig elegido.
- [ ] Elegir rig objetivo (TREX / ARTHROPOD / SPIDER son los más "monstruo").
- [ ] Probar in-game.

**Meta:** fauna con skin zombie. Recordar: el cambio es global por rig (§5b).

### Fase 3 — Ambiente (opcional, Ruta B)
- [ ] Importar prop estático estilo Dead Space vía NMSDK.
- [ ] Colocarlo como objeto de planeta / POI.

**Meta:** atmósfera. Restos, estructuras podridas.

### Fase 4 — Pulido + release
- [ ] Balance dificultad.
- [ ] Probar contra update actual del juego.
- [ ] README + capturas + créditos.
- [ ] Publicar en Nexus (categoría Creatures).

---

## 8. Flujo de build (repetible)

**Paso 0 de cada prueba — backup del save.** Obligatorio, no opcional:

```powershell
.\tools\Backup-NMSSave.ps1 -Etiqueta "que-estoy-probando"
```

Crea `backups\NMS_saves_<fecha>_<etiqueta>\`, nunca sobreescribe, conserva los 15
más recientes y avisa si NMS está abierto (un save a medio escribir no sirve de nada).

1. Editar textura/paleta/MXML en `work\`.
2. Escribir/actualizar script `.lua` en `work\scripts\`.
3. Copiar el `.lua` a `tools\AMUMSS\ModScript\` (AMUMSS solo lee de ahí).
4. Correr `BUILDMOD.bat` → modo **FULL**, rama **Experimental**.
5. Copiar el resultado a `GAMEDATA\MODS\` (ver §10d — no es `PCBANKS\MODS`).
6. Lanzar juego. Probar en save de pruebas.
7. Si OK → `releases\` + anotar en CHANGELOG con la versión de NMS probada.

Verificado en la primera corrida: sin `.lua` en `ModScript\`, AMUMSS avisa
"NO user .lua Mod Script found" y termina sin hacer nada. Comportamiento correcto.

---

## 9. Publicación Nexus

- Cuenta en nexusmods.com.
- Subir `.pak` empaquetado (no la carpeta de trabajo).
- Categoría: Creatures.
- Incluir: descripción, instrucciones instalación, capturas, versión NMS compatible.
- Créditos: acreditar cualquier asset/tool de terceros. Revisar permisos de cada asset usado.

**Legal/permisos:** muchos mods NMS prohíben reusar sus assets. Si partes de otro mod, pedir permiso. Assets propios = sin problema.

---

## 10. Riesgos y pendientes por verificar

### Estado del sistema — VERIFICADO 2026-07-28

| Cosa | Estado |
|---|---|
| NMS instalado | ✅ `C:\Program Files (x86)\Steam\steamapps\common\No Man's Sky` |
| **Rama del juego** | ✅ **PUBLIC**, versión 170671 (buildid 24039799) |
| MBINCompiler | ✅ 6.45.0.1 — 'latest' y 'public' coinciden |
| Carpeta de mods real | ✅ `GAMEDATA\MODS\` — ver §10d |
| Mods instalados | 87 activos, gestionados por Vortex |
| `DISABLEMODS.TXT` | ✅ ausente → carga de mods habilitada |
| Espacio libre C: | 358 GB |
| Ruta proyecto | ✅ sin acentos, fuera de OneDrive |
| git | ✅ 2.50.0 |
| gh CLI | ❌ no instalado |

### 10d. Mods instalados — CORRECCIÓN de dónde viven

Lo que decía antes (`PCBANKS\MODS`, `.pak` sueltos) es el flujo **viejo**. Corregido
tras ver la salida real de AMUMSS y el disco.

**La carpeta real es `GAMEDATA\MODS\`**, con 108 elementos: 87 carpetas de mod + 21
sueltos. NMS 6.x carga mods como **carpetas descomprimidas**, no solo como `.pak`:

```
GAMEDATA\MODS\<NombreDelMod>\
├── <NombreDelMod>.lua        # el script AMUMSS fuente, incluido por el autor
├── GLOBALS\*.EXML
├── METADATA\*.MBIN
└── __folder_managed_by_vortex
```

Extensiones presentes en el árbol: 181 `.MBIN`, 102 `.EXML`, 54 `.DDS`, 38 `.lua`.

Vortex gestiona la carpeta (`__folder_managed_by_vortex`). No editar a mano lo que
Vortex controla — se lo puede llevar por delante en el siguiente deploy.

Detalle útil: muchos autores **incluyen su `.lua`**. Son ejemplos reales y funcionales
de scripts AMUMSS contra la versión actual del juego. Material de estudio gratis.

### 10g. Dónde queda un mod archivado

Cuando una prueba se valida y se retira del juego, queda en tres capas:

| Qué | Dónde | ¿git? |
|---|---|---|
| Fuente `.lua` | `work\scripts\<Mod>.lua` | ✅ sí |
| Mod construido | `build\<Mod>_VERIFICADO_<fecha>\` | ❌ gitignored |
| Script desactivado | `tools\AMUMSS\ModScript\Disabled scripts and paks\` | ❌ |

`Disabled scripts and paks\` es carpeta nativa de AMUMSS: los `.lua` de ahí no se
procesan en el siguiente `BUILDMOD`. Es la forma limpia de desactivar sin borrar.

Para reactivar: mover el `.lua` de vuelta a `ModScript\` y rebuildear. O, más
rápido, copiar la carpeta de `build\` directo a `GAMEDATA\MODS\` — ya está compilada.

**Nota:** `tools\AMUMSS\CreatedMODS\` y `ModBackups\` NO sirven como archivo. AMUMSS
los limpia en cada corrida. Por eso la copia va a `build\`.

### 10f. AMUMSS despliega EXML delta, no MBIN — VERIFICADO

Sorpresa útil de la primera build real. AMUMSS 5.6.2.0w compila el MBIN completo,
pero **lo que copia a `GAMEDATA\MODS\` es un EXML parcial** con solo las propiedades
tocadas:

```xml
<Data template="cGcCreatureGenerationData">
  <Property name="GroundGroupsPerKm">
    <Property name="Sparse" value="75.000000" /> !# CHANGED
    ...
```

496 bytes frente a los ~90 KB de la tabla entera. El MBIN completo queda en
`tools\AMUMSS\ModBackups\` y `MODBUILDER\MOD\`, sin desplegar.

**No es un fallo.** Comprobado contra los 87 mods instalados: 21 usan el mismo
formato y dos de ellos (`10x_Industrial_Waste_Spawn`, `Exocraft Inventory Improved`)
shippean EXML-delta **sin MBIN alguno**. NMS 6.x lee overlays parciales desde la
carpeta de mods.

**Consecuencia para el proyecto:** el mod solo reclama las 4 propiedades que cambia,
no la tabla completa. Otro mod que toque `CREATUREGENERATIONDATA` en otra sección
puede convivir. Mucho mejor de cara a Nexus que shippear el MBIN entero.

El `.pak` empaquetado sí existe (`ModBackups\________________BuildHistory\`) por si
hace falta la vía clásica.

### 10e. Análisis de conflictos — LIMPIO

Escaneados los 87 mods buscando colisiones con el plan de fauna:

- **Cero archivos** con `CREATURE`/`FAUNA` en el nombre. Nadie toca
  `CREATUREGENERATIONDATA` ni texturas de rig.
- 6 `.lua` mencionan las palabras, todos falsos positivos:
  `CreaturesCanEat` (propiedad de flora), `FARMDEADCREATURE` (planta),
  `CREATURE_FEED`/`CREATURE_FARM` (piezas de base), recompensas de escaneo.
- Único que roza: **`True Blood 2.6 - Red`** — cambia el color de sangre de criaturas.
  No compite; suma. Sangre roja + carne podrida van juntas.

**Conclusión:** no hace falta desinstalar nada para trabajar. Si algo se comporta
raro in-game, entonces sí se aísla moviendo mods fuera.

### 10b. Antivirus — el AV activo es McAfee, no Defender

Verificado: `root\SecurityCenter2` lista McAfee y Windows Defender, pero
`(Get-MpComputerStatus).RealTimeProtectionEnabled` = **False**. Windows apaga la
protección en tiempo real de Defender cuando hay un AV de terceros.

**Consecuencia:** `Add-MpPreference` es inútil aquí. La exclusión va en McAfee.

El README de AMUMSS (`README\README-AMUMSS_installation.txt`, líneas 19-23) es
explícito en dos puntos:
- La excepción se crea **antes** de ejecutar nada de AMUMSS.
- Algunos AV no registran bien la exclusión hasta **reiniciar**.

Rutas a excluir, en orden de preferencia:

1. Carpeta completa: `C:\Users\<usuario>\NMS_MOD_ZOMBIES\tools\AMUMSS`
2. Si McAfee solo admite archivos sueltos (varias versiones lo hacen), excluir:
   - `MODBUILDER\hgpaktool.exe`
   - `MODBUILDER\psarc.exe`
   - `MODBUILDER\RunThisJob.exe`
   - `MODBUILDER\MBINCompiler.exe` ← aún no existe, se crea al primer BUILDMOD
   - `_NMS PCBANKS Explorer.exe`
   - `_AMM_ModScript_Manager.exe`

Estado de la extracción: **limpia**. 714/714 archivos, McAfee no tocó nada.
Mark-of-the-Web: 0 archivos marcados (curl no aplica MOTW, a diferencia del navegador).

### 10c. Los .bat de AMUMSS son interactivos

Aprendido a la mala. Dos reglas:

- **Ejecutar cada `.bat` desde su propia carpeta.** Usan rutas relativas. Lanzar
  `TOOLS\Test_AMUMSS_install.bat` desde la raíz produce "falta un operando" y
  "no se encuentra la ruta" — errores que no apuntan a la causa.
- **No redirigir stdin a `NUL`.** Los scripts esperan input; con EOF se rompen o
  se cuelgan.

Conclusión: `BUILDMOD.bat` se corre a mano, en ventana normal. No es automatizable
sin trabajo extra, y no vale la pena para algo que se ejecuta una vez.

### Otros riesgos

- **Juegas en rama EXPERIMENTAL (170671).** Dos consecuencias:
  1. Experimental se actualiza mucho más seguido que Public. Los mods se rompen
     más a menudo y hay que re-buildear.
  2. **La mayoría de quien descargue en Nexus estará en Public.** Un mod construido
     y probado solo contra Experimental puede fallarles. Antes de publicar hay que
     verificar contra Public, o declarar en la descripción la versión exacta contra
     la que se probó.
- [Unverified] Compatibilidad NMSDK con versión ACTUAL de NMS y de Blender. Reportes de errores de import en foros. Probar antes de comprometer Ruta B.
- Probar siempre en partida nueva o save de pruebas, nunca en la principal.
- Mods pueden causar desync en multijugador. No es ban, pero cuidado si juegas online.
- [Unverified] Versión exacta de .NET requerida hoy. Confirmar al instalar.
- [Inferencia] Retextura + comportamiento (Ruta A) es lo más estable. Basado en patrón de mods de fauna existentes que ya funcionan así.
- Updates de NMS pueden romper mods. AMUMSS ayuda a re-buildear rápido, pero scripts los mantienes tú.
- Import de modelo estático puede fallar por formato geometry. Curva de aprendizaje alta.

---

## 11. Recursos / links

- AMUMSS (GitHub): https://github.com/HolterPhylo/AMUMSS
- AMUMSS (Nexus, instrucciones): https://www.nexusmods.com/nomanssky/mods/2626
- MBINCompiler (GitHub): https://github.com/monkeyman192/MBINCompiler
- NMSDK (plugin Blender): https://github.com/monkeyman192/NMSDK
- Wiki modding NMS: https://nmsmodding.fandom.com/
- Estado del modding (step wiki): https://stepmodifications.org/wiki/NoMansSky:Current_State_of_Modding
- Importar modelos custom: https://nmsmodding.fandom.com/wiki/Importing_Custom_Models
- Blender: https://www.blender.org/
- Notepad++: https://notepad-plus-plus.org/
- Discord modding NMS: canal en comunidad AMUMSS/Nexus (soporte en tiempo real, canal amumss-lua)

[Unverified] Links de GitHub `monkeyman192/*` no reconfirmados en esta sesión. Verificar que repos siguen activos antes de descargar.

---

## Siguiente paso

Fase 0, resto de checklist:

1. Excepción antivirus en `tools\AMUMSS\` — **antes** de descomprimir, o Defender
   borra archivos a mitad y el fallo sale confuso.
2. Instalar .NET Desktop Runtime x64 + 7-Zip.
3. Descargar AMUMSS → descomprimir en `tools\AMUMSS\`.
4. Correr `BUILDMOD.bat` en vacío. Debe bajar MBINCompiler solo. **Si esto falla,
   nada más importa — se arregla aquí antes de seguir.**
5. Backup de `%APPDATA%\HelloGames\NMS`.

Entorno vivo → Fase 1: lua que toca un valor de `CREATUREGENERATIONDATA`.
Ese cambio numérico visible in-game es el hito que desbloquea todo lo demás.

---

*Doc revisado 2026-07-28. Correcciones aplicadas: fases 1↔2 invertidas, unpack masivo
descartado, alcance de retextura aclarado (§5b). Estado del sistema verificado en §10.*
