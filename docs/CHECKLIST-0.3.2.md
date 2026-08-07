# Checklist de prueba — 0.3.2 y los tres experimentos de aspecto

Lo desplegado el **2026-08-07**, qué mira cada prueba y qué significa cada resultado.

- Save respaldado: `NMS_saves_2026-08-07_0019_antes-032-huevos-en-edificios-y-skin`
- Sigue pendiente **toda** la 0.3.1: [`CHECKLIST-0.3.1.md`](CHECKLIST-0.3.1.md)
- Investigación de fondo: [`ASSETS.md`](ASSETS.md)

---

## Qué hay instalado ahora en `GAMEDATA\MODS`

| Mod | Ver | Qué toca | Cambios |
|---|---|---|---:|
| `HorribleTerror_Infestation_4-Hardcore` | **0.3.2** | 11 rutas: ecosistema, globals, **L-systems de edificios abandonados**, **nidos de carguero** | 97 |
| `HorribleTerror_NecroSkin` | 0.1.0 | textura propia del Horror + tinte de material del Horror de carguero | 3 + 1 DDS |
| `HorribleTerror_DerelictBugs` | 0.1.0 | `FREIGHTERDUNGEONSTABLE`: cargueros infestados | 57 |
| `HT_PredatorParts_PRUEBA01` | 0.1.0 | `TREX.DESCRIPTOR`: de 15 opciones de lomo quedan 2 | 26 secciones borradas |

Los cuatro verificados **descompilando desde `GAMEDATA\MODS`**, no desde el delta.

> ⚠️ **Antes de tocar un carguero abandonado: desactivar `NoDerelictMiniHorrors` en
> Vortex.** Escribe los mismos dos `.ENTITY.MBIN` de los nidos y les quita justo lo que
> nosotros encendemos. Con él puesto, la prueba 2 no mide nada.

---

## 1 · Huevos dentro de los edificios abandonados ⭐ la prueba principal

Aterrizar en un edificio abandonado (los tres tipos valen: científico, comercial, guerrero).

| # | Qué mirar | Esperado | ⬜ |
|---|---|---|---|
| 1.1 | ¿Hay huevos **dentro**? | Hasta 5, colgando donde antes había la planta de tentáculos | ⬜ |
| 1.2 | ¿Se sostienen en el aire raro? | El locator `TENTACLE_` cuelga del techo: el huevo puede quedar flotando. **Si queda feo, la corrección es el locator, no el modelo** | ⬜ |
| 1.3 | Romper uno | Sale la oleada de Horrores **dentro del edificio**. Confirma que el spawn es global y no depende del bioma | ⬜ |
| 1.4 | ¿Se puede salir? | Espacio cerrado + 16 Horrores puede ser injugable. Si lo es, bajar `EGG_PROB` de 100 a 30-50 antes que tocar nada más | ⬜ |
| 1.5 | Escanear un huevo de éstos | Debe dar `UI_FIEND_POD_NAME_L` y servir para la misión `FIENDCORE`, igual que uno de superficie | ⬜ |

## 2 · El nido del carguero reacciona

Carguero abandonado, **con `NoDerelictMiniHorrors` desactivado**.

| # | Qué mirar | Esperado | ⬜ |
|---|---|---|---|
| 2.1 | Apuntar con la linterna a un nido, quieto | `AgroTorch` 12 contra `AgroRate` −5 y umbral 15 → debería despertar en ~2 s | ⬜ |
| 2.2 | Disparar cerca sin darle | `GunfireAgro` 8, radio 20 m → despierta | ⬜ |
| 2.3 | ¿Salen MiniFiends? | Es la línea base vanilla que nunca hemos visto sin el mod de Lenni | ⬜ |
| 2.4 | ¿Aparece también el Horror grande? | Con `FreighterSpawnDist` 60 y `Despawn` 150 debería haber más presión de la habitual | ⬜ |

> Si 2.1 y 2.2 no hacen nada, la lectura de la escala está mal: probar `AgroTorch` = 30 y
> `AgroThreshold` = 5 antes de descartar la ruta.

## 3 · Cargueros infestados

| # | Qué mirar | Esperado | ⬜ |
|---|---|---|---|
| 3.1 | Entrar a 2-3 cargueros abandonados distintos | Todos con salas infestadas. Ya no debería salir ninguno limpio de tipo TURRETS ni MAZE | ⬜ |
| 3.2 | **La misión del carguero termina** | Ésta es la que importa: se convirtieron también los `ValidRoomIDs` de colocación de objetos de misión. Si el registro del capitán o el terminal final no aparecen, **este mod se desinstala** | ⬜ |
| 3.3 | ¿Quedan tipos FLOATERS y SLIME? | Sí: se dejaron a propósito para que no todos los cargueros sean iguales | ⬜ |

## 4 · Aspecto — dos vías a la vez, en dos bichos distintos

Están montadas para poder distinguirse **de un vistazo**, sin desinstalar nada.

| # | Bicho | Vía | Esperado | ⬜ |
|---|---|---|---|---|
| 4.1 | **Horror Biológico** (planeta, de los huevos) | textura `.DDS` propia | Lleva calaveras de araña por todo el cuerpo. Si se ven → **la ruta del DDS funciona** y el codificador BC7 propio es válido | ⬜ |
| 4.2 | **Horror de carguero** (`FREIGHTERFIEND`) | `gMaterialColourVec4` del material | Rojo carne oscuro. Si se ve → **se puede teñir por material**, sin tocar texturas | ⬜ |
| 4.3 | Ninguno de los dos cambia | Entonces el problema es de carga de mods, no de ruta: comprobar que las carpetas siguen en `GAMEDATA\MODS` | ⬜ |

> La textura está **deliberadamente mal alineada** con las UV: es una foto tileada 4×4, no
> un despiece del bicho. La prueba es «¿carga?», no «¿queda bien?».
>
> ⚠️ Sale de `asset/necro/Spider-Skull.jpg`. **No se puede publicar**: es arte de terceros.
> Para Nexus habría que pintar una textura propia sobre el atlas vanilla.

## 5 · ¿Podemos hacer nuestros propios depredadores?

| # | Qué mirar | Esperado | ⬜ |
|---|---|---|---|
| 5.1 | Buscar TREX (los depredadores grandes de cuello largo y dos patas) en varios planetas | **No crashea** al generarlos | ⬜ |
| 5.2 | Comparar el lomo entre varios | De 15 accesorios de lomo quedan 2: deberían repetirse mucho | ⬜ |
| 5.3 | ¿Salen sin lomo o con el modelo roto? | Si pasa, el descriptor **no** tolera huecos y la vía es sesgar, no borrar | ⬜ |

**Si 5.1 y 5.2 salen bien, la respuesta a «¿sirve dejar solo 4 heads y 5 eyes?» es que sí**,
y el trabajo pasa a ser elegir qué piezas dejar en cada rig. Ver [`ASSETS.md`](ASSETS.md) §3.

---

## Orden de desinstalación si algo va mal

1. `HT_PredatorParts_PRUEBA01` — el más experimental y el único que puede romper la
   generación de una criatura entera.
2. `HorribleTerror_DerelictBugs` — si la misión del carguero no termina (prueba 3.2).
3. `HorribleTerror_NecroSkin` — cosmético, no rompe nada.
4. Infestation 0.3.2 → volver a `build\_retirado_2026-08-07_infestacion-031\`.

## Al terminar

- Resultados a `CHANGELOG-MOD2.md` (0.3.2) con la versión de NMS.
- Quitar los `[SIN PROBAR]` que pasen en `MODIFICACIONES.md`.
- Lo que se caiga, a la tabla «Retirado» con el motivo.
