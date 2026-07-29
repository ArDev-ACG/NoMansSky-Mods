# NMS Mod — Zombies / Monstruos

Mod para No Man's Sky. Fauna hostil con look podrido, estilo Dead Space.
Destino: Nexus Mods, categoría Creatures.

Doc de diseño y roadmap: [`../proyecto_mod_nms_zombies.md`](../proyecto_mod_nms_zombies.md)

## Qué hay en este repo

Solo fuentes propias:

- `work/scripts/` — scripts `.lua` para AMUMSS. El mod real vive aquí.
- `work/palettes/` — paletas de color editadas.
- `docs/` — esta doc, changelog, créditos.

**No** hay assets del juego. Son de Hello Games. Ver `.gitignore`.

## Build

```
1. Editar .lua en work/scripts/
2. Correr tools/AMUMSS/BUILDMOD.bat  (formato "combined")
3. Copiar .pak resultante a:
   C:\Program Files (x86)\Steam\steamapps\common\No Man's Sky\GAMEDATA\PCBANKS\MODS\
4. Lanzar juego. Probar en save de pruebas.
5. Si OK → releases/ + anotar en CHANGELOG.md
```

## Antes de testear

- Vaciar `PCBANKS\MODS` de mods ajenos (mover, no borrar).
- Confirmar que no existe `DISABLEMODS.TXT` en `PCBANKS`.
- Backup de saves: `%APPDATA%\HelloGames\NMS`.

## Estado

Fase 0 — setup. Ver roadmap en el doc de diseño.
