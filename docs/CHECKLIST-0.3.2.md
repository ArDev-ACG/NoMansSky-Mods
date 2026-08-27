# Checklist de prueba — 0.3.2 y los tres experimentos de aspecto

Lo desplegado el **2026-08-07**, qué mira cada prueba y qué significa cada resultado.

- Save respaldado: `NMS_saves_2026-08-07_0019_antes-032-huevos-en-edificios-y-skin`
- Sigue pendiente **toda** la 0.3.1: [`CHECKLIST-0.3.1.md`](CHECKLIST-0.3.1.md)
- Investigación de fondo: [`ASSETS.md`](ASSETS.md)

## ✅ Jugado el 2026-08-09 — resultado

| Bloque | Veredicto |
|---|---|
| 1 · Huevos en edificios abandonados | ❌ **Sin validar.** No aparecieron huevos, pero **no se visitaron los tres tipos de edificio**. Prueba incompleta, no fallo confirmado |
| 2 · El nido del carguero reacciona | ✅ **Pasa entera** (2.1-2.4) |
| 3 · Cargueros infestados | ✅ **Pasa entera** (3.1-3.3). La misión del carguero **termina**: el mod se queda |
| 4 · Aspecto | ⚠️ **La ruta del DDS carga, el resultado no sirve**: los Horrores salen **blancos**, no con calaveras. 4.2 sin comprobar de cerca, pero se veían más rojos |
| 5 · Piezas de depredador | ✅ **Sin crasheos y sin modelos rotos.** Borrar secciones del descriptor es vía válida |

Detalle prueba a prueba abajo, en cada tabla.

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
| 1.1 | ¿Hay huevos **dentro**? | Hasta 5, colgando donde antes había la planta de tentáculos | ❌ **no se vieron** — falta visitar los tres tipos |
| 1.2 | ¿Se sostienen en el aire raro? | El locator `TENTACLE_` cuelga del techo: el huevo puede quedar flotando. **Si queda feo, la corrección es el locator, no el modelo** | ⬜ depende de 1.1 |
| 1.3 | Romper uno | Sale la oleada de Horrores **dentro del edificio**. Confirma que el spawn es global y no depende del bioma | ⬜ depende de 1.1 |
| 1.4 | ¿Se puede salir? | Espacio cerrado + 16 Horrores puede ser injugable. Si lo es, bajar `EGG_PROB` de 100 a 30-50 antes que tocar nada más | ⬜ depende de 1.1 |
| 1.5 | Escanear un huevo de éstos | Debe dar `UI_FIEND_POD_NAME_L` y servir para la misión `FIENDCORE`, igual que uno de superficie | ⬜ depende de 1.1 |

> **1.1 no es un fallo confirmado.** La prueba pide los **tres** tipos de edificio
> (científico, comercial, guerrero) y solo se vio parte. Antes de tocar el script hay que
> repetirla en los tres. Lo que hay que mirar además: los edificios abandonados que ya
> estaban **generados en el save** pueden traer la versión vieja del L-system cacheada —
> conviene buscar uno en un sistema al que nunca se haya ido.

## 2 · El nido del carguero reacciona

Carguero abandonado, **con `NoDerelictMiniHorrors` desactivado**.

| # | Qué mirar | Esperado | ⬜ |
|---|---|---|---|
| 2.1 | Apuntar con la linterna a un nido, quieto | `AgroTorch` 12 contra `AgroRate` −5 y umbral 15 → debería despertar en ~2 s | ✅ |
| 2.2 | Disparar cerca sin darle | `GunfireAgro` 8, radio 20 m → despierta | ✅ |
| 2.3 | ¿Salen MiniFiends? | Es la línea base vanilla que nunca hemos visto sin el mod de Lenni | ✅ |
| 2.4 | ¿Aparece también el Horror grande? | Con `FreighterSpawnDist` 60 y `Despawn` 150 debería haber más presión de la habitual | ✅ |

> ~~Si 2.1 y 2.2 no hacen nada, la lectura de la escala está mal~~ — **no hizo falta**.
> `AgroTorch` = 12 y `GunfireAgro` = 8 contra `AgroThreshold` 15 / `AgroRate` −5 **son la
> escala correcta**. Deja de ser inferencia: los dos campos que Hello Games dejó a cero
> funcionan con valores del orden del umbral.

## 3 · Cargueros infestados

| # | Qué mirar | Esperado | ⬜ |
|---|---|---|---|
| 3.1 | Entrar a 2-3 cargueros abandonados distintos | Todos con salas infestadas. Ya no debería salir ninguno limpio de tipo TURRETS ni MAZE | ✅ |
| 3.2 | **La misión del carguero termina** | Ésta es la que importa: se convirtieron también los `ValidRoomIDs` de colocación de objetos de misión. Si el registro del capitán o el terminal final no aparecen, **este mod se desinstala** | ✅ **termina** |
| 3.3 | ¿Quedan tipos FLOATERS y SLIME? | Sí: se dejaron a propósito para que no todos los cargueros sean iguales | ✅ |

> **`HorribleTerror_DerelictBugs` se queda.** 3.2 era la condición de desinstalación y
> pasa: convertir los `ValidRoomIDs` de colocación de objetos de misión **no rompe** la
> misión del carguero abandonado.

## 4 · Aspecto — dos vías a la vez, en dos bichos distintos

Están montadas para poder distinguirse **de un vistazo**, sin desinstalar nada.

| # | Bicho | Vía | Esperado | ⬜ |
|---|---|---|---|---|
| 4.1 | **Horror Biológico** (planeta, de los huevos) | textura `.DDS` propia | Lleva calaveras de araña por todo el cuerpo. Si se ven → **la ruta del DDS funciona** y el codificador BC7 propio es válido | ⚠️ **cambia, pero salen BLANCOS** |
| 4.2 | **Horror de carguero** (`FREIGHTERFIEND`) | `gMaterialColourVec4` del material | Rojo carne oscuro. Si se ve → **se puede teñir por material**, sin tocar texturas | 🟡 sin comprobar de cerca, «parecían más rojos» |
| 4.3 | Ninguno de los dos cambia | Entonces el problema es de carga de mods, no de ruta: comprobar que las carpetas siguen en `GAMEDATA\MODS` | ✅ descartado: **sí cambian** |

### Qué significa el blanco de 4.1

Hay que separar dos cosas que la prueba mezclaba:

| Pregunta | Respuesta |
|---|---|
| ¿El juego **carga** un `.DDS` nuestro puesto en `GAMEDATA\MODS`? | ✅ **Sí.** El bicho cambia de aspecto, luego la ruta del asset es válida |
| ¿El `.DDS` que produce `Make-NMSTexture.py` es **legible** como la textura que queríamos? | ❌ **No.** Sale plano blanco, no la foto tileada |

Blanco plano es el síntoma clásico de que la textura llega pero no se muestrea: candidatos
por orden, **sin comprobar ninguno**:

1. **Sin mipmaps.** NMS pide la cadena completa; con un solo nivel muchas veces resuelve a
   blanco en vez de fallar.
2. **Cabecera DX10 / formato mal declarado.** BC7 exige `DDS_HEADER_DXT10` con
   `DXGI_FORMAT_BC7_UNORM`; si el `fourCC` dice otra cosa se lee basura.
3. **El canal que manda no es el difuso.** Las criaturas de NMS usan atlas + recoloreado
   por paleta; puede estar cargándose la textura pero pesando la paleta encima.

Siguiente paso barato para aislarlo: **empaquetar el DDS vanilla tal cual, sin tocar nada**.
Si el bicho sigue saliendo blanco, el fallo es de empaquetado/ruta; si sale normal, el fallo
está en el codificador y hay que atacar los mipmaps primero.

> La textura está **deliberadamente mal alineada** con las UV: es una foto tileada 4×4, no
> un despiece del bicho. La prueba es «¿carga?», no «¿queda bien?».
>
> ⚠️ Sale de `asset/necro/Spider-Skull.jpg`. **No se puede publicar**: es arte de terceros.
> Para Nexus habría que pintar una textura propia sobre el atlas vanilla.

## 5 · ¿Podemos hacer nuestros propios depredadores?

| # | Qué mirar | Esperado | ⬜ |
|---|---|---|---|
| 5.1 | Buscar TREX (los depredadores grandes de cuello largo y dos patas) en varios planetas | **No crashea** al generarlos | ✅ **ninguno crasheó** |
| 5.2 | Comparar el lomo entre varios | De 15 accesorios de lomo quedan 2: deberían repetirse mucho | 🟡 no se comparó pieza a pieza |
| 5.3 | ¿Salen sin lomo o con el modelo roto? | Si pasa, el descriptor **no** tolera huecos y la vía es sesgar, no borrar | ✅ **ninguno salió mal** |

~~**Si 5.1 y 5.2 salen bien**~~ → **5.1 y 5.3 salen bien, que es lo que decidía la vía.**
Borrar secciones de un `.DESCRIPTOR` **no** rompe la generación: el juego tolera huecos, no
hace falta sesgar. La respuesta a «¿sirve dejar solo 4 heads y 5 eyes?» es **sí**, y el
trabajo pasa a ser elegir qué piezas dejar en cada rig. Ver [`ASSETS.md`](ASSETS.md) §3.

Queda 5.2 sin cerrar del todo — que los lomos **se repitan** no se comprobó comparando. Es
consecuencia aritmética de 26 secciones borradas, pero conviene confirmarlo de pasada la
próxima vez que salgan varios TREX juntos.

Nota de la sesión: **la mayoría de los depredadores grandes que salieron eran TREX.** No es
del mod de piezas, es del mod 2: `DANGEROUS` con peso 1000 sesga la selección de arquetipo,
y `GROUNDTABLEPLAYERPREDATORLARGE` es de donde salen.

---

## Orden de desinstalación si algo va mal

~~Ninguno hay que desinstalar.~~ Tras la partida del 2026-08-09:

| Mod | Veredicto |
|---|---|
| `HT_PredatorParts_PRUEBA01` | **Se queda.** No crashea y no deja modelos rotos (5.1, 5.3) |
| `HorribleTerror_DerelictBugs` | **Se queda.** La misión del carguero termina (3.2) |
| `HorribleTerror_NecroSkin` | **Se queda pero no sirve todavía**: carga y pinta blanco (4.1) |
| Infestation 0.3.2 | **Se queda.** Nada de lo suyo falló; lo único sin medir son los huevos de interior |

## Al terminar — hecho

- ✅ Resultados a [`CHANGELOG-MOD2.md`](CHANGELOG-MOD2.md), entrada 0.3.2.
- ✅ `[SIN PROBAR]` retirados de [`MODIFICACIONES.md`](MODIFICACIONES.md) en lo que pasó.
- ✅ Lo que sigue sin medir queda marcado, no borrado: huevos de interior (1.x) y el
  codificador de texturas.

## Lo que queda pendiente de esta tanda

| # | Qué | Por qué no se cerró |
|---|---|---|
| 1.1-1.5 | Huevos dentro de los edificios abandonados | Faltan tipos de edificio por visitar. **Es la prueba principal de 0.3.2 y sigue sin medir** |
| 4.1 | Textura propia del Horror | Carga pero sale blanca. Aislar con el DDS vanilla sin tocar |
| 4.2 | Tinte por material del Horror de carguero | Visto de lejos, no confirmado |
| 5.2 | ¿Se repiten los lomos? | No se comparó pieza a pieza |
