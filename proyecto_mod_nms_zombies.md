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
- `.EXML` → MBIN decompilado a xml. Editable en texto.
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

### Fase 1 — Comportamiento + spawn (núcleo, era Fase 2)
- [ ] Localizar `CREATUREGENERATIONDATA` vía Modding Station.
- [ ] Script lua mínimo: cambiar UN valor. Buildear. Cargar. Confirmar cambio in-game.
- [ ] Editar rol → forzar depredador / hostil.
- [ ] Ajustar tamaño (más grande = más amenazante).
- [ ] Controlar en qué planetas/biomas aparecen.

**Meta real de Fase 1:** pipeline vivo (extraer→decompilar→editar→compilar→empacar→cargar)
demostrado con un cambio numérico. Todo lo demás depende de esto. Es EL hito.

**Meta ampliada:** "planeta infestado". Fauna hostil donde antes no la había.

### Fase 2 — Look zombie (era Fase 1)
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

1. Editar textura/paleta/EXML en `work\`.
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
| **Rama del juego** | ⚠️ **EXPERIMENTAL**, versión 170671 |
| MBINCompiler | ✅ 6.45.0.1 (el que pide Experimental) |
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
