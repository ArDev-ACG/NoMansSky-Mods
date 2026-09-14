# Cosmos (7.0) — qué assets nuevos hay y cuáles nos sirven

Medido el **2026-09-13** contra la instalación real, no leído de las notas de parche.
Método abajo, para repetirlo en la siguiente actualización.

| | |
|---|---|
| Antes | `filenames-6.45-2026-08-27.json` — NMS 170671, rama Public |
| Después | `filenames.json` — NMS **178763 (7.0 Cosmos)** |
| Archivos | 184 823 → **194 531**. **+20 759 nuevos, −11 051 retirados** |

---

## 1 · Lo primero, porque decide si hay que rehacer trabajo

**Los cuatro nodos que tocamos no cambiaron de nombre.**

| Rig | Archivos nuevos | Archivos retirados | |
|---|---|---|---|
| `SPIDERRIG` (`FIEND`, `FREIGHTERFIEND`) | **0** | 0 | esqueleto igual: 765 `InvBindMatrix` |
| `ARTHROPOD` (`BUGFIEND`) | **0** | 0 | sin medir por dentro |
| `RARERESOURCE\GROUND\FIENDEGG` | 0 | 0 |
| `DIPLORIG` | 13 (`diplo` + 7 `.ANIM`) | 0 | el único rig con archivos nuevos |

O sea: **la [receta de piel](RECETA-PIEL.md) sigue valiendo tal cual** y los cuatro
modelos publicados no hay que replantearlos. El único rig que Hello Games tocó es
el del diplo.

> ⚠️ **El diff es por nombre de archivo, y el nombre no basta.** Comprobado el
> mismo día sobre el `FIENDEGG`, que es el único de los cuatro del que
> guardábamos el vanilla de 6.45 (`work/models/eggmesh/`):
>
> | Archivo | 6.45 | 7.0 Cosmos | |
> |---|---:|---:|---|
> | `FIENDEGG.SCENE.MBIN` | 1 711 B | **1 859 B** | distinto |
> | `FIENDEGG.GEOMETRY.MBIN.PC` | 5 266 B | **2 129 B** | distinto |
> | `FIENDEGG.GEOMETRY.DATA.MBIN.PC` | 14 913 B | 14 913 B | mismo tamaño, **hash distinto** |
>
> Y no es cosmético: **el `.SCENE` de 6.45 ya no descompila** con el compilador
> 7.00 —`File not recognized`— así que injertar sobre la copia vieja no es que
> quede desactualizado, es que **falla**. El huevo del 13/09 hubo que
> reinjertarlo contra el vanilla reextraído de los PAK de hoy, que está guardado
> en `work/models/vanilla_7.0_fiendegg/`.
>
> **De los otros tres no se puede decir lo mismo ni lo contrario: no guardábamos
> su vanilla de 6.45.** Lo único medido es que el esqueleto del `FIEND` no ha
> cambiado de tamaño —765 `InvBindMatrix` en el vanilla de Cosmos y los mismos
> 765 en nuestro injerto de agosto—, que es la señal que importa para la piel.
>
> **La lección, y es una regla nueva:** extraer y guardar el vanilla de cada
> nodo que tocamos **antes** de cada actualización de NMS, junto a la
> instantánea de `filenames.json`. Sin esa copia no hay diff de contenido
> posible, solo de nombres.

---

## 2 · Estaciones abandonadas / Puestos Infestados

Familia de rutas **nueva entera**, no reaprovechada. **258 archivos** bajo
`space/poi/hulkinfested`:

| Ruta | Qué es |
|---|---|
| `models/space/poi/hulkinfested/` (85) | el casco infestado: `buildinga`, `buildingc`, `slimeroom`, `toxictank`, `landingpadlid`, `ballooncover`, `ballooncoversocket`, `doorsocket`, `outpostslime`, `anims/` |
| `textures/space/poi/hulkinfested/` (67) | sus texturas |
| `models/space/poi/outpost/parts/slime*` (52) | las piezas del outpost normal ya engoopadas: `slimemainroom`, `slimemainroof`, `slimerooftall`, `slimeroofcap`/`capb`, `slimesattanks`, `slimesatsolar`, `slimesatroof`, `slimeuntenna`, `slimeunderpillar`, `slimeunderbox`, `slimeunderring` |
| `models/space/poi/abandonedbase/` | base abandonada |
| `models/effects/space/slimeoutpostatmospherics` (16), `slimeoutpostgoo`, `slimepartcloud` | la atmósfera y la masa viral |
| `textures/ui/hud/icons/spacepoi` (+`/selected`) | los iconos nuevos del HUD |

En el juego: los puestos infestados llevan masa viral que hay que apartar con la
**Bobina de Gravitino** para llegar a los **sacos de patógeno** y las **fibras
gelatinosas**. Limpiar el puesto lo deja reclamable.

---

## 3 · Los horrores biológicos — `physicsprops/slime/` (132 archivos)

Esto es lo que nos interesa. **Malla + `.SCENE` + `.ENTITY` + `.ANIM` propios**,
no variantes del `FIENDEGG`:

| Grupo | Nodos |
|---|---|
| **Huevos** | `fleshegg`, `flesheggsmall`, `flesheggmed`, `flesheggbig`, `miniegg`, `smallegg`, `springegg` |
| **Nidos y cáscaras** | `eggnest`, `nestcombined`, `nestcover`, `shellcover`, `shellcombined` |
| **Bichos** | `starslime`, `starslimemini`, `armouredslime`, `tricell`, `perldril` |
| **Procedural** | `slimeproc` (`.descriptor.mbin` + `physicscomponent`) |
| **Anims** | `flesheggstart` / `twitch` / `detach`, `socketsmall`/`med`/`big` × (`start`/`idle`/`detach`), `springegg`, `armouredslime`, `shellcover`, `starslime`, `tricell` |
| **Efectos** | `explosion/flesheggpopout`, `explosion/flesheggexplosion`, `space/flesheggspurt`, `space/flesheggdetach` |

**Materiales repetidos** en casi todos: `outerslimescrolldispmat`,
`innerfleshdispmat`, `pillarslimemat`, `lambert1`. El `springegg` trae además
`distslimescrolldispmat` **y su variante `_skinned`** — o sea que ese sí lleva
huesos.

### Qué abre esto para el mod

1. **Un `FIENDEGG` con hueso ya existe en vanilla.** `springegg` tiene material
   `_skinned` y `.ANIM` propia. Hasta ahora el [markerEgg](MODELOS/markerEgg.md)
   era estático porque el `FIENDEGG` lo es; el `springegg` es un sitio donde una
   malla nuestra **sí** podría moverse.
2. **Hay tres tamaños de huevo de carne** (`small`/`med`/`big`) con el mismo juego
   de materiales. Un solo asset nuestro remallado a tres escalas cubre los tres.
3. **`eggnest` / `nestcombined`** es exactamente lo que pide el
   `monster-eggs.zip` (racimo sobre roca), que no cabía en un `FIENDEGG` suelto.
4. **Sin rig de criatura nuevo**, así que nada de esto obliga a rehacer la receta.

---

## 4 · Cómo se midió, para repetirlo

```bash
# 1. Lista de todo lo que hay en los PAK de hoy
cd <scratchpad>
python tools/AMUMSS/MODBUILDER/HGPAK/HGPAKTool/hgpaktool.py -L     "C:/Program Files (x86)/Steam/steamapps/common/No Man's Sky/GAMEDATA/PCBANKS"

# 2. Diferencia contra la instantánea anterior
python - <<'PY'
import json
carga = lambda p: {x.lower() for v in json.load(open(p, encoding='utf-8')).values()
                   if isinstance(v, list) for x in v}
viejo, nuevo = carga("filenames-6.45-2026-08-27.json"), carga("filenames.json")
open("nuevos.txt","w",encoding='utf-8').write("\n".join(sorted(nuevo-viejo)))
open("borrados.txt","w",encoding='utf-8').write("\n".join(sorted(viejo-nuevo)))
PY
```

**Guardar la instantánea vieja antes de cada actualización de NMS.** Sin ella el
diff no existe: `filenames.json` se sobrescribe y no hay contra qué comparar.
El `filenames-<compilador>-<fecha>.json` de la raíz es esa instantánea.

## Fuentes de fuera

- [Cosmos Update — nomanssky.com](https://www.nomanssky.com/cosmos-update/)
- [Patch notes 7.0 — Shacknews](https://www.shacknews.com/article/150668/no-mans-sky-cosmos-update-7-patch-notes)
