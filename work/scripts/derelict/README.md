# `derelict` — cargueros abandonados infestados

Dos scripts en la carpeta, y **solo uno se despliega a la vez**: los dos escriben
`METADATA\REALITY\TABLES\FREIGHTERDUNGEONSTABLE.MBIN`, así que el segundo que cargue el
juego gana en silencio.

| Script | Qué convierte | Estado |
|---|---|---|
| `HorribleTerror_DerelictBugs.lua` | **Todo**: barracones, carga, enfermería y las tres ramas | ❌ **Retirado el 2026-08-11.** Rompía la puerta de «seguridad adicional» y dejaba el proceso colgado al salir |
| `HT_DerelictBugs_PRUEBA02.lua` | **Solo los barracones.** Carga, enfermería y ramas quedan vanilla | ✅ **Construido el 2026-08-11** (24 cambios, 0 errores, 0 `[NOTICE]`) y ✅ **desplegado y verificado el 2026-08-12**. ⬜ Sin probar en partida |

El diagnóstico que llevó a la media conversión está en
[`../../../docs/PENDIENTES.md`](../../../docs/PENDIENTES.md) §N3.

---

## Qué hace la PRUEBA 02 y qué deja quieto

La conversión completa tocaba tres superficies distintas de la tabla a la vez y no se sabe
cuál rompe. Ésta toca **una familia de salas y dos superficies**:

| Superficie | PRUEBA 02 | Por qué |
|---|---|---|
| `RoomId` de `MainRoomTypes` | ✅ `R_BARR` → `R_BUG_BARR`, `R_S_BARR` → `R_S_BUG_BARR` | Es el cambio que se quiere de verdad |
| `RoomID` de `GcRoomCountRule` | ✅ igual | **Tiene que ir con el anterior.** Es el `Min`/`Max` del generador: si la sala ya no se genera y la regla la sigue pidiendo, la generación no puede terminar |
| `ValidRoomIDs` de `GcQuestItemPlacementRule` | ✅ solo el `R_BARR` | Dónde caen los objetos de misión. Si se deja pidiendo una sala que ya no existe, el objeto no tiene sitio |
| `BranchRoomTypes` | ❌ **intacto** | Aquí estaba la colisión: `B_MEDI` → `B_BUG_MED`, un ID que **ya existe en vanilla** |
| Familias `CARG` y `MEDI` | ❌ **intactas** | Media conversión: si la puerta abre, el mod se recupera a trozos |

**El desempate que da:** si con solo los barracones la puerta abre y el juego cierra, el
mecanismo sirve y lo que rompía está en `MEDI`/`CARG`/ramas. Si vuelve a romperse, rompe el
mecanismo entero y la vía se cierra sin más pruebas.

## Dos trampas de AMUMSS que salieron del log del 2026-08-06

**1 · Los nombres de propiedad no distinguen mayúsculas.** La clave `RoomID` reemplaza
también los `RoomId` de `MainRoomTypes`. En el script viejo las dos claves estaban puestas y
la segunda no hacía nada:

```
Looking for >>> ["RoomId"] ... matching "R_BARR"
>>> [NOTICE] NO Replacement done.
```

**2 · Mezclar en una `VALUE_CHANGE_TABLE` propiedades que colisionan así levanta un aviso**,
seis veces en el script viejo:

```
[NOTICE] In next section of your script, some VALUE_CHANGE_TABLE "property" are duplicates,
         other are not ... could lead to unreliable replacements, please split into two
         MXML_CHANGE_TABLE sub-tables instead
```

Por eso la PRUEBA 02 va en **tres sub-tablas de una clave cada una**. El aviso no llegó a
hacer daño —el log lista cada intercambio y todos son los buscados— pero deja el build
limpio y el conteo predecible.

> ⚠️ **Lo que `PENDIENTES.md` llamaba «18 cambios, 0 warnings» eran 18 `[NOTICE]`.** El mod
> completo hizo **57 cambios**. El conteo está en la línea `>>>>> N CHANGE(s) made` del
> `_build_*.log`, no en el resumen final.

## Construir

```
tools\Build-Tiers.ps1 -Carpeta derelict
```

Construye **los dos** `.lua` de la carpeta, uno por pasada. El del mod retirado se
reconstruye igual; da lo mismo mientras no se copie a `GAMEDATA\MODS`.

**El conteo es la verificación.** Esperado en `_build_HT_DerelictBugs_PRUEBA02.log`:

| Sub-tabla | Cambios |
|---|---:|
| `R_BARR` → `RoomID` (4 `RoomId` + 4 `RoomID`) | 8 |
| `R_BARR` → `ValidRoomIDs` | 8 |
| `R_S_BARR` → `RoomID` (4 + 4) | 8 |
| **`>>>>> N CHANGE(s) made`** | **24** |

Y **0 `[NOTICE]`**. Si sale alguno de «duplicates», la sub-tabla no quedó separada.

> ⚠️ **Corregido el 2026-08-12.** Aquí decía: «comprobar en el `.EXML` del build que no
> aparece ni un `R_BUG_MEDI`, `R_BUG_CARG`, `B_BUG_BARR` ni `B_BUG_MED`». **Esa comprobación
> no sirve, por dos motivos a la vez:**
>
> 1. **El `.EXML` del build es un informe de cambios, no la tabla.** Son 159 líneas con
>    marcas `!# CHANGED`, frente a las 1512 de la tabla de verdad. Un ID que no se toca no
>    sale ahí **nunca**, así que el «no aparece» se cumple siempre y no demuestra nada.
> 2. **Esos cuatro IDs existen en vanilla.** La familia `BUG` es de Hello Games. Buscarlos
>    en la tabla real da acierto tanto si el mod está bien como si está mal.
>
> La comprobación buena es **contar contra el vanilla como línea base** — abajo.

## Desplegar

1. `HorribleTerror_DerelictBugs` **fuera** de `GAMEDATA\MODS` — sigue en
   [`../../../build/_retirado_2026-08-11_derelictbugs/`](../../../build/_retirado_2026-08-11_derelictbugs/).
2. Copiar el `.MBIN` de `tools\AMUMSS\ModBackups\HT_DerelictBugs_PRUEBA02\` a
   `GAMEDATA\MODS\HT_DerelictBugs_PRUEBA02\`, **conservando** `METADATA\REALITY\TABLES\`.
3. Verificar descompilando el MBIN ya copiado. Construir no es desplegar.
4. **Reiniciar NMS.** Los mods solo se leen al arrancar. Se abre **por Steam**: estos mods
   no los gestiona Vortex.

### Cómo se verifica de verdad — contra el vanilla

Sacar la tabla original y descompilar las dos, para contar sobre el mismo formato:

```
tools\AMUMSS\MODBUILDER\hgpaktool.exe -U -f "*freighterdungeonstable*" -O ext "<NMS>\GAMEDATA\PCBANKS"
tools\AMUMSS\MODBUILDER\MBINCompiler.exe <la copia de GAMEDATA\MODS>
```

Contando `"<ID>"` con las comillas incluidas, para que `R_BUG_BARR` no se cuele dentro de
`R_S_BUG_BARR`:

| Token | Vanilla | PRUEBA 02 | Mod completo |
|---|---:|---:|---:|
| `R_BUG_BARR` | 10 | **26** (+16) | 26 |
| `R_S_BUG_BARR` | 6 | **14** (+8) | 16 |
| `R_BUG_MEDI` | 4 | **4** — intacto | 11 |
| `R_BUG_CARG` | 4 | **4** — intacto | 10 |
| `B_BUG_BARR` | 2 | **2** — intacto | 6 |
| `B_BUG_MED` | 1 | **1** — intacto | 3 |

**+16 y +8 son los 24 cambios del log.** Las cuatro filas «intacto» son la prueba de que la
media conversión se quedó donde debía: si alguna sube, el script se comió `MEDI`, `CARG` o
las ramas y la prueba deja de separar nada.

Comprobado así el **2026-08-12**: cuadra fila por fila.

## Cómo se lee la prueba

El derelict tiene que ser **nuevo y en otro sistema**: el bug se reproduce en derelicts
frescos, no está grabado en el save.

| Al entrar | Lectura |
|---|---|
| La puerta abre **y** el juego cierra normal | El mecanismo sirve. Recuperar `CARG` y `MEDI` de a una, dejando las ramas fuera |
| La puerta se atasca **o** el juego se queda colgado al salir | Rompe la conversión en sí, con una sola familia y sin colisiones de ID. **Vía cerrada** |

La primera sala es la que importa: con el mod completo salía variante `R_BUG_*` y era la que
se rompía.
