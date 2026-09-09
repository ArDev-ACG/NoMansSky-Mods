# Mod 4 — Contenedores: qué se puede y qué no

> ❌ **CERRADO EL 2026-09-05. La idea se descarta y el mod se retira.**
> `MOD4_Contenedores_PRUEBA01` subía el cofre 1 de 50 a 100 casillas con un solo campo. Se
> midió en partida y **el cofre siguió saliendo de 50**. La firma escrita antes de entrar decía
> que, si salía con 50, el layout **viene horneado en la partida** y comprobarlo exigía una
> partida nueva; se decide no gastarla. El mod sale de `GAMEDATA\MODS\` a `MODS_Retirados\`.
>
> **Este documento se queda**, y no por nostalgia: no es la doc de un mod vivo, es el mapa de
> **qué se puede tocar y qué no** en los diez cofres globales, medido sobre los `.pak`. Vale
> igual —o más— ahora que la respuesta es «no se puede».

**Investigación del 2026-08-27.** Todo lo de aquí está **medido** sobre los `.pak` de la
instalación local (NMS 6.45, MBINCompiler 6.45.0.1), no supuesto. Donde no se ha medido, lo
dice.

**Lo que pediste:** que dos contenedores pegados sumen sus espacios (50 + 50 = 100 al abrir
cualquiera de los dos), que no se pueda romper uno si el conjunto está más lleno de lo que
cabría en los que quedan, y poder meter iconos y colores al nombrarlos, con un selector.

**La conclusión corta:** el punto de partida es distinto de lo que parece desde dentro del
juego, dos de las cuatro cosas no se pueden hacer con datos, y la de los iconos **sí**, con un
matiz.

---

## 1 · Los contenedores no son diez cajas: son diez *puertas* a diez cofres globales

Medido en `metadata/reality/tables/basebuildingobjectstable.mbin`. El campo se llama
**`StorageContainerIndex`** y va de **0 a 9**. Y hay **cuatro familias distintas de pieza
construible que apuntan a los MISMOS diez índices**:

| Familia | Dónde se construye | Índices |
|---|---|---|
| `CONTAINER0` … `CONTAINER9` | Base planetaria (`BASE_TECH`) | 0–9 |
| `S_CONTAINER0` … `S_CONTAINER9` | Carguero, legado (`FREIGHT_LEGACY`) | 0–9 |
| `FRE_ROOM_STORE0` … `FRE_ROOM_STORE9` | Sala industrial de carguero (`FREIGHTER_IND`) | 0–9 |
| `B_WALL_CARG0` … `B_WALL_CARG9` | Interior de corveta (`BIGGS_INT`) | 0–9 |

Y el tamaño, medido en `metadata/gamestate/defaultsavedata.mbin`:

```
Chest1Layout  ... Chest10Layout   ->  Slots 50   (los diez, iguales)
ChestMagic / ChestMagic2          ->  Slots 48
CorvetteStorage                   ->  Slots 160
```

> **Esto reencuadra la idea entera.** No es «un contenedor = 50 espacios, dos contenedores =
> dos veces 50 sin hablarse». Es: **la partida tiene DIEZ inventarios de 50, y cada cosa que
> construyes es una puerta a uno de ellos.**
>
> - Construyes `CONTAINER3` en el planeta y `S_CONTAINER3` en el carguero → **es el mismo
>   inventario**. Ya están unidos, y ni siquiera hace falta que estén cerca.
> - Construyes **dos** `CONTAINER3` en la misma base → **comparten los mismos 50**, no suman.
> - El techo de la partida es **10 × 50 = 500** espacios, y es fijo.
>
> O sea que la unión que buscas **ya existe en el juego**, pero va **por número**, no por
> proximidad. Lo que se ve como «no trabajan juntos» son contenedores con **índices
> distintos**.

---

## 2 · Qué se puede tocar, y qué no

Los mods de NMS son **sólo datos**: AMUMSS cambia valores dentro de `.MBIN`. **No hay
scripting en ejecución**, así que todo lo que dependa de una condición viva —cuántos hay
construidos, si están pegados, cuánto hay dentro ahora mismo— no tiene dónde escribirse.

| Lo que pediste | ¿Se puede? | Por qué |
|---|---|---|
| **Más espacios por contenedor** | ✅ **Sí**, un campo × 10 | `ChestNLayout.Slots` en `defaultsavedata.mbin`. De 50 a lo que sea |
| **Que 2 sumen 100 al entrar en cualquiera** | ❌ **No** | El número de cofres es fijo (10) y su tamaño es un campo estático. No existe ningún campo que diga «este contenedor lee además el de al lado» |
| **Limitar la unión a contenedores pegados** | ❌ **No** | Los únicos campos de vecindad de toda la tabla son de **encaje** (`SnappingDistanceOverride`, `SnapRotateBlocked`, `WiringSnapPoint`) y de **red eléctrica** (`LinkNetworkType Power`, `ConnectionDistance 3.0`, `NetworkSubGroup`, `NetworkMask`). Sirven para la energía, no para el inventario. `CompositePartObjectIDs` y `FamilyIDs` son para piezas compuestas y familias del menú de construcción |
| **No poder romper uno si está lleno** | ❌ **No** | Es una condición en tiempo de ejecución. Lo más cerca que hay es `CanPickUp`, que en `CONTAINER0` **ya está en `false`**, y `MinimumDeleteDistance` |
| **Iconos y colores en el nombre** | ✅ **Sí** (ver §3) | |
| **Selector de iconos al escribir** | ❌ **No** | Es interfaz en ejecución |

### Lo único que queda como mod 4 de verdad

**Subir `Slots` de los diez cofres.** Un solo archivo, diez valores.

⚠️ **Y tiene una duda sin medir, que es la misma que la de los extractores:**
`defaultsavedata.mbin` es la **plantilla de partida nueva**. Si el cambio alcanza o no a una
partida ya empezada **no se sabe**, y se comprueba en treinta segundos: cambiar el valor,
arrancar, y **abrir un contenedor que ya existía**. Si sale con más casillas, alcanza a las
partidas viejas; si no, es sólo plantilla y el mod no sirve para tu partida.

---

## 3 · Iconos y colores en el texto: sí, y aquí está la sintaxis

Dos tablas, las dos medidas:

| Tabla | Qué trae | Cómo se escribe |
|---|---:|---|
| `metadata/ui/specialstylesimagesdata.mbin` | **161 iconos** | `<IMG>NOMBRE<>` |
| `metadata/ui/specialstylesdata.mbin` | **81 estilos de color** | `<ESTILO>texto<>` |

**Comprobado en textos reales del juego**, sobre las 14 737 entradas con texto de
`language/nms_loc1_latinamericanspanish.mbin`:

```
No hay tecnologia de escaneo instalada <IMG>SLASH<>
<TITLE>Construye %TECH%<>
%ITEM% Desconectado <IMG>SLASH<> Interferencia planetaria
```

`<IMG>SLASH<>` sale 74 veces y `<TITLE>` 133, así que la sintaxis no es una suposición.

**Iconos que servirían para etiquetar contenedores** (de los 161): `PADLOCK`, `TICK`,
`NOTICK`, `DANGER`, `NANITE`, `UNITS`, `QUICKSILVER`, `FUEL`, `MINERAL`, `METAL`, `FLORA`,
`CATALYST`, `STELLAR`, `EARTH`, `EXOTIC`, `TECHNOLOGY`, `TRADEABLE`, `COMMODITY`, `SALVAGE`,
`BONES`, `POWER`, `GRID`, `PLANET`, `CREATURE`, `BUILDING`, `SENTINEL`, `INVBACKPACK`,
`INVSHIP`, `INVFREIGHT`, `INVGENERAL`, `INVTECH`, `INVCARGO`, `HOT_1`…`HOT_6`,
`PR_0`…`PR_15`, `ACLASS`/`BCLASS`/`CCLASS`/`SCLASS`.

**Colores útiles** (de los 81): `RED`, `GREEN`, `GREY`, `ORANGE_DARK`, `RED_DARK`,
`GREEN_DARK`, `BLUE_DARK`, `HIGHLIGHT`, `TITLE`, `TRA`, `WAR`, `EXP`, `SPECIAL`, `RARE`,
`EXOTIC`, `TECHNOLOGY`.

**Y se pueden añadir iconos PROPIOS.** `specialstylesimagesdata` es una tabla de entradas con
`Name`, `Size`, `UseFontColour` y `Path` a un `.DDS`:

```
Name  = "DUPLICATE"
Path  = "TEXTURES/UI/FONTS/BUILD.DUPLICATE.DDS"
Size  = 32 x 32
```

Añadir una fila apuntando a una textura nuestra es exactamente lo que ya sabemos hacer con
`Make-NMSTexture.py`.

### ⬜ La prueba que hay que hacer primero, y no toca ningún archivo

**Renombrar un contenedor a `<IMG>PADLOCK<> Municion` y ver qué sale.** El nombre lo escribe
el jugador y se guarda en `ChestNInventory.Name`; si ese campo pasa por el mismo renderizador
que el resto del interfaz, el icono **aparece sin modificar nada**. Si sale el texto crudo
`<IMG>PADLOCK<>`, entonces el campo va sin formato y no hay nada que hacer por esa vía.

**Esa prueba decide si la mitad bonita del mod 4 existe o no**, cuesta treinta segundos y se
puede hacer esta misma noche junto a las tres pruebas de malla.

---

## 4 · Lo que queda, en orden

| # | Qué | Estado |
|---|---|---|
| 1 | **Probar `<IMG>PADLOCK<> Municion` como nombre de contenedor.** Sin tocar archivos | ⬜ 30 s en partida |
| 2 | **`MOD4_Contenedores_PRUEBA01` — cofre 1 de 50 a 100 casillas** | 🆕 **construido y desplegado el 27/08, sin medir**. Verificado descompilando el `.MBIN` de `GAMEDATA\MODS`: `Chest1` 100 y los otros nueve en 50. Ningún otro mod de la carpeta escribe `DEFAULTSAVEDATA.MBIN` |
| 3 | Si el paso 1 sale bien: añadir iconos propios a `specialstylesimagesdata` | ⬜ una fila + un `.DDS` |

> ⚠️ **Y una cosa que hay que decir clara sobre el selector de iconos.** Lo que pides —un
> teclado de emojis al escribir el nombre— **no se puede**, y no por falta de datos: ese
> selector sería una **pantalla nueva del interfaz**, y los mods de NMS cambian valores dentro
> de archivos, no dibujan pantallas ni ejecutan código. Lo que sí queda, si la prueba 1 sale
> bien, es **escribir el código a mano** (`<IMG>PADLOCK<> Municion`) y tener la chuleta de los
> 161 nombres a mano en §3.

**Lo de sumar inventarios por adyacencia y lo de bloquear el borrado no entran**: no hay campo
donde escribirlos, y no es cuestión de buscar más — es que los mods de NMS no ejecutan código.
