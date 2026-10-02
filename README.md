# No Man's Sky mods

Horror creature mods for [No Man's Sky](https://www.nomanssky.com/), built with AMUMSS (Lua scripts)
and custom meshes made in Blender + NMSDK.

| Mod | Status | Notes |
|---|---|---|
| **Predators** | Released | Vanilla predators chase, keep up and hit. Behaviour only. [docs](docs/MOD1-PREDATORS.md) |
| **Infestation** | In development | Includes Predators and seeds the world with Fiend eggs, sandworms and nests. [docs](docs/MOD2-INFESTATION.md) |
| **Creature models** | Beta | Xenodog, Cry Wolf, Warrior Bug, Facehugger Egg, Marker Egg, Skull Crawler. [docs](docs/NEXUS-MODELOS.md) |

Closed experiments (galaxy map on foot, containers, corvette bacta tank, extractors) are kept in `docs/` for reference.

## Layout

- `work/scripts/` - AMUMSS Lua scripts, one folder per mod.
- `tools/` - Python / PowerShell tools for meshes, weights and packaging.
- `docs/` - design notes, changelogs and model sheets. Start at [docs/README.md](docs/README.md).
- `BLENDER/` - Blender workflow notes.

No game files are included: unpack your own copy with AMUMSS / MBINCompiler.

## Licence

All rights reserved, except files derived from the Creative Commons models credited in
[LICENSE](LICENSE), which keep their licence. Not affiliated with Hello Games.
