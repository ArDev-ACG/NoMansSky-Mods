# NMS Mod — Zombies / Monstruos

Mod para No Man's Sky. Fauna hostil con look podrido, estilo Dead Space.
Destino: Nexus Mods, categoría Creatures.

## Qué doc abrir

**Empieza siempre por el primero.** Los de abajo se consultan, no se leen enteros.

| Doc | Cuándo se abre |
|---|---|
| ⭐ [`PENDIENTES.md`](PENDIENTES.md) | **Siempre, primero.** Lo que está en el juego sin medir, la cola, y las preguntas sin responder. Nada más |
- [`ACUERDOS.md`](ACUERDOS.md) — **lo ya aprobado en partida y que no se toca**, con quién lo comprueba. Se lee antes de cambiar cualquier constante
| [`MODIFICACIONES.md`](MODIFICACIONES.md) | «¿Qué campo toca el mod y sobre qué bicho?» — tabla viva |
| [`ASSETS.md`](ASSETS.md) | «¿Cómo cambio el aspecto?» — texturas, colores, partes, y **Blender + NMSDK** en §4 |
| [`../BLENDER/README.md`](../BLENDER/README.md) | «¿Qué carpeta abro para ver el modelo que hay en el juego?» — banco de Blender, la vuelta completa y el prefijo que hay que quitar |
| [`COMPORTAMIENTO.md`](COMPORTAMIENTO.md) | «¿Qué campo controla percepción / acecho / ataque?» |
| [`IDEAS.md`](IDEAS.md) | Mapa de spawn y cola de ideas sin comprometer |
| [`FAUNA_REFERENCE.md`](FAUNA_REFERENCE.md) | Arquetipos y tablas de fauna vanilla |
| [`NEXUS.md`](NEXUS.md) | Publicación y textos de la página |

### Historia — el «por qué» de cada decisión

| Doc | Qué cubre |
|---|---|
| [`CHANGELOG-MOD2.md`](CHANGELOG-MOD2.md) | **Mod 2 (Infestation), el que se está tocando.** Versiones y sesiones de prueba, lo nuevo arriba |
| [`CHANGELOG.md`](CHANGELOG.md) | Proyecto y mod 1 (Predators) |
| [`CHANGELOG-MOD3.md`](CHANGELOG-MOD3.md) | Mod 3 (Mapa Galáctico a Pie), cerrado |
| [`CHECKLIST-0.3.1.md`](CHECKLIST-0.3.1.md) · [`CHECKLIST-0.3.2.md`](CHECKLIST-0.3.2.md) | Listas de prueba de esas dos versiones, ya cerradas |

> **Cada mod se versiona aparte.** El mod 2 **contiene** al mod 1: se instala uno o el otro,
> nunca los dos. Doc de diseño: [`../proyecto_mod_nms_zombies.md`](../proyecto_mod_nms_zombies.md)

## Qué hay en este repo

Solo fuentes propias: `work/scripts/` (los `.lua` de AMUMSS — el mod real vive ahí),
`work/palettes/`, `BLENDER/` (exportaciones de NMSDK) y `docs/`.
**No** hay assets del juego: son de Hello Games. Ver `.gitignore`.

## Build

```
1. Editar .lua en work/scripts/
2. Copiarlo a tools/AMUMSS/ModScript/   (AMUMSS solo lee de ahi)
3. Correr tools/AMUMSS/BUILDMOD.bat     modo FULL
4. VERIFICAR contra el vanilla, no contra el .EXML del build
5. DESPLEGAR los .MBIN de tools/AMUMSS/ModBackups/<mod>/ a:
   C:\Program Files (x86)\Steam\steamapps\common\No Man's Sky\GAMEDATA\MODS\<mod>\
6. Arrancar por Steam. Probar en save de pruebas.
7. Si OK -> releases/ + anotar en el CHANGELOG que toque
```

**Las cuatro trampas, cada una costó una prueba entera:**

| Trampa | Qué pasa |
|---|---|
| `CreatedMODS/` **no despliega** | Es EXML **delta**, un informe con marcas `!# CHANGED`. Los `.MBIN` completos están en `ModBackups/<mod>/`, y el `.pak` en `ModBackups/________________BuildHistory/` |
| Los `GLOBALS` caen en la raíz | `ModBackups` deja `GCCREATUREGLOBALS.MBIN` y `GCUIGLOBALS.GLOBAL.MBIN` **en la raíz** del mod. Si se copian tal cual, el juego no los lee y se pierde media conducta **sin ningún aviso**. Van a `GLOBALS\` |
| El `.lua` desplegado miente | AMUMSS **no lo sobrescribe** al redesplegar: puede decir una versión vieja. Los `.MBIN` sí se sobrescriben. Para saber qué corre, **descompilar el MBIN de `GAMEDATA\MODS`** |
| **Un crash apaga TODOS los mods** | El diálogo «Desactivar mods» que sale cuando el juego se cierra solo escribe `DisableAllMods=true` en `Binaries\SETTINGS\GCMODSETTINGS.MXML`. **La prueba siguiente corre en vanilla puro y parece que pasó**, sin ningún aviso. Es un ajuste del juego: da igual arrancar por Steam o por Vortex |

### El interruptor general de mods

Después de **cualquier** crash, antes de volver a probar:

```
findstr DisableAllMods "C:\Program Files (x86)\Steam\steamapps\common\No Man's Sky\Binaries\SETTINGS\GCMODSETTINGS.MXML"
```

Tiene que decir `value="false"`. Si dice `true` se enciende desde el menú de mods del juego, o
cambiando ese valor con el juego **cerrado** — lo reescribe al salir.

Dos señales de que ese archivo es la foto de una sesión vieja: los mods que lista no coinciden
con lo que hay en `GAMEDATA\MODS`, y su fecha es anterior al último despliegue. Con el
interruptor apagado el juego **no vuelve a escanear** la carpeta.

Pasó el **2026-08-14**: el crash de `HT_ScuttlerMesh_PRUEBA05` lo dejó en `true`, y la sesión
de la `PRUEBA06` se midió sin un solo mod cargado.

### Si el build falla en esta máquina

| Síntoma | Causa |
|---|---|
| «Bad Active Code Page Detected» | El shell va en UTF-8. Lanzar con `chcp 850` |
| «`MBINCompiler.exe` no se reconoce» y luego `attempt to compare nil with number` | `NoDefaultCurrentDirectoryInExePath=1` en el entorno: `cmd` no busca ejecutables en el directorio actual, y AMUMSS los llama por ruta relativa. Quitar esa variable |

## Entorno verificado

| Cosa | Valor |
|---|---|
| NMS | **rama Public**, versión 170671 |
| MBINCompiler | 6.45.0.1 |
| AMUMSS | v5.6.2.0W, modo FULL |
| Blender / NMSDK | ≥ 4.2 / `0.10.0-alpha13` |
| Mods instalados | ~90 vía Vortex. **Los nuestros no los gestiona Vortex**: se copian a mano y se arranca por Steam |

## Antes de testear

- Backup de saves: `tools\Backup-NMSSave.ps1 -Etiqueta "<qué se prueba>"`.
- Usar save de pruebas, no la partida principal.
- Reiniciar NMS: **solo carga mods al arrancar**.
