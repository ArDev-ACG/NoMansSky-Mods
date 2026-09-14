# Modelos

Una ficha por malla que hemos metido al juego: **qué es**, **a quién sustituye**,
**cómo se hizo** y **qué salió mal**. La receta general —los once pasos y por qué
cada uno— vive en [`../RECETA-PIEL.md`](../RECETA-PIEL.md); aquí sólo va lo que
cambia de un modelo a otro.

Los parámetros de verdad están en `tools/Export-NMSMesh.py` (`MODELOS`) y en
`tools/Weight-NMSMesh.py`. Si una ficha y el `.py` no coinciden, **manda el `.py`**.

## Los que están publicados — `releases/models-0.1.0`

| Ficha | Sustituye a | Rig | Dónde sale en el juego |
|---|---|---|---|
| [skullCrawler](skullCrawler.md) | `FREIGHTERFIEND` | `SPIDERRIG` | el horror de los cargueros abandonados |
| [cryWolf](cryWolf.md) | `FIEND` | `SPIDERRIG` | el horror grande que sale del huevo en planetas infestados |
| [warriorBug](warriorBug.md) | `BUGFIEND` | `ARTHROPOD` | las crías que el horror grande escupe en combate |
| [markerEgg](markerEgg.md) | `FIENDEGG` | — (estático) | los huevos del suelo infestado |

## Los retirados — sirvieron para aprender, no se publicaron

| Ficha | Ocupaba | Por qué se retiró |
|---|---|---|
| [necromorph](necromorph.md) | `FIEND` | bípedo sobre rig de araña; lo sustituyó el cry wolf, que es cuadrúpedo |
| [zombie](zombie.md) | `BUGFIEND` | lo mismo; lo sustituyó el warrior bug |

## Lo siguiente

| Modelo | Entra como | Estado |
|---|---|---|
| `xeno-cuadripedo` | `FIEND` — releva al cry wolf | pendiente. El asset es **`.glb` con animación**, no FBX |
| `facehugger-egg` | `FIENDEGG` — releva al marker | pendiente |
| `xeno-raven`, `facehugger01`, `monster-eggs`, `alien-egg`, `xenomorph-egg` | sin asignar | en `asset/Modelos 3D` |

## Las capturas

`img/*.png`, rendereadas con `BLENDER_WORKBENCH` desde el `.blend` final de cada
modelo. **Son el estado del `.blend` el 2026-09-13, no necesariamente el del MBIN
publicado**: varios `.blend` se guardaron en una prueba intermedia y la altura que
miden no es la de `alto` en `Export-NMSMesh.py`. Para la geometría que corre de
verdad hay que descompilar el MBIN de `GAMEDATA\MODS`.
