# NMS Mod — Zombies / Monstruos

Mod para No Man's Sky. Fauna hostil con look podrido, estilo Dead Space.
Destino: Nexus Mods, categoría Creatures.

Doc de diseño y roadmap: [`../proyecto_mod_nms_zombies.md`](../proyecto_mod_nms_zombies.md)

| Doc | Para qué |
|---|---|
| [`MODIFICACIONES.md`](MODIFICACIONES.md) | **Tabla viva**: cada campo que toca el mod, qué hace y sobre qué monstruo |
| [`IDEAS.md`](IDEAS.md) | Mapa de spawn y cola de trabajo |
| [`COMPORTAMIENTO.md`](COMPORTAMIENTO.md) | Conducta: percepción, acecho, ataques, cadencia, separación |
| [`FAUNA_REFERENCE.md`](FAUNA_REFERENCE.md) | Referencia de fauna, arquetipos y tablas |
| [`NEXUS.md`](NEXUS.md) | Publicación y textos de la página |
| [`CHANGELOG.md`](CHANGELOG.md) | Historial del proyecto y del mod 1 |
| [`CHANGELOG-MOD2.md`](CHANGELOG-MOD2.md) | Historial del mod 2 (Infestation), versionado aparte |

## Qué hay en este repo

Solo fuentes propias:

- `work/scripts/` — scripts `.lua` para AMUMSS. El mod real vive aquí.
- `work/palettes/` — paletas de color editadas.
- `docs/` — esta doc, changelog, créditos.

**No** hay assets del juego. Son de Hello Games. Ver `.gitignore`.

## Build

```
1. Editar .lua en work/scripts/
2. Copiarlo a tools/AMUMSS/ModScript/   (AMUMSS solo lee de ahi)
3. Correr tools/AMUMSS/BUILDMOD.bat     modo FULL, rama Experimental
4. Copiar el resultado a:
   C:\Program Files (x86)\Steam\steamapps\common\No Man's Sky\GAMEDATA\MODS\
5. Lanzar juego. Probar en save de pruebas.
6. Si OK → releases/ + anotar en CHANGELOG.md con la version de NMS probada
```

## Entorno verificado

| Cosa | Valor |
|---|---|
| NMS | rama **Experimental**, version 170671 |
| MBINCompiler | 6.45.0.1 |
| AMUMSS | v5.6.2.0W, modo FULL |
| Mods instalados | 87, via Vortex, sin conflicto con fauna |

## Antes de testear

- Backup de saves: `%APPDATA%\HelloGames\NMS` (hay uno en `backups/`).
- Usar save de pruebas, no la partida principal.
- Solo aislar mods si algo se comporta raro — el escaneo dio limpio.

## Estado

Fase 0 cerrada. Siguiente: Fase 1 — primer `.lua` sobre `CREATUREGENERATIONDATA`.
