# `HT_PredatorParts` — podar el árbol de piezas del `TREXRIG`

Mod de prueba, se versiona aparte. Cambia **qué piezas puede montar** un depredador
procedural borrando opciones de su `.DESCRIPTOR`. No pinta, no toca números: quita ramas.

| Script | Qué cambia | Estado |
|---|---|---|
| `../pruebas/HT_PredatorParts_PRUEBA01.lua` | 26 lomos, **con** `CREATE_HOES` | ✅ Jugado el 2026-08-09, nada crasheó. **Retirado el 2026-08-12** — su efecto real no era el documentado |
| `HT_PredatorParts_PRUEBA02.lua` | + 6 ramas de cabeza, **con** `CREATE_HOES` | ✅ Construido el 2026-08-12. ❌ **Deja ranuras huecas.** No se despliega, queda como testigo |
| `HT_PredatorParts_PRUEBA03.lua` | lo mismo **sin** `CREATE_HOES` | ✅ **Construido, desplegado y verificado el 2026-08-12.** ⬜ Sin probar en partida |

**Los tres escriben `TREX.DESCRIPTOR.MBIN`: no puede haber dos desplegados.** La PRUEBA03
contiene a las otras dos.

## El árbol, mapeado entero

Sacado del MXML vanilla con un recorrido recursivo, no leyendo el XML plano. **Corrige dos
cosas que `../../../docs/ASSETS.md` §3 daba por buenas.**

```
_TREX_ (2)
 ├ _TREX_3XRARE ─ rama aparte, el "alien" completo (13 descriptores, intacta)
 └ _TREX_4
     ├ _HEAD_ (8)  BIRDREX · LIZ · RHINO · CROC · TREX · RAT · TOUCANA · ALIEN
     ├ _BODY_ (4)  BIRDREX · RAT · TREX · HOLESXRARE
     └ _TAIL_ (5)  TREX · BIRDREX · RAT · TOUCAN · ALIENXRARE
```

1. **`_HEAD_` no tiene una opción: tiene 8**, colgadas directas de `_TREX_4`. El doc decía
   que las cabezas estaban repartidas como hojas de `_CHACC_`, `_REXHEADJ_`, `_REAR_` y
   `_THACC_`. Es al revés: **ésas son las ramas que cuelgan de cada cabeza**, sus accesorios.
   Cabeza, cuerpo y cola son **tres ranuras independientes**, y podar es mucho más simple de
   lo que estaba escrito.
2. **`_RATBACK_` tiene 14 hojas, no 15.** La «15ª» que el doc avisaba de no borrar
   (`_BODY_TREX`) es **hermana en `_BODY_`**, no está dentro de la lista. El aviso sobraba.

Total vanilla: **172 descriptores**. Coincide con el conteo del doc, que era lo único
correcto de esa sección.

## 🔓 El hallazgo: `CREATE_HOES` era el que rompía la poda

`ASSETS.md` daba la PRUEBA01 por verificada así: «`_RATBACK_`: 15 opciones → **2**».
**Falso.** Descompilado el MBIN construido y recorrido el árbol:

| | Vanilla | PRUEBA02 (con `CREATE_HOES`) | PRUEBA03 (sin él) |
|---|---:|---|---:|
| `_HEAD_` | 8 | **8 entradas: 2 con `Id` + 6 huecas** | **2** |
| `_RATBACK_` | 14 | **14: 1 + 13 huecas** | **1** |
| `_REXBACK_` | 14 | **14: 1 + 13 huecas** | **1** |
| Descriptores | 172 | 123 | **91** |

El manual de AMUMSS lo dice con todas las letras y nadie lo había leído hasta el final:

> `REMOVE = "SECTION"` … *it is strongly suggested to also use `CREATE_HOES = "TRUE"`,
> **to preserve the Head as a HOES***, otherwise it may not be possible to create a valid EXML.

O sea: **el flag conserva a propósito la cabecera de la sección borrada.** El
`TkResourceDescriptorData` se queda como cascarón sin `Id`, sin `Name` y sin `Children`, y la
lista **no encoge**. Los hijos sí se van, arrastrados por el `Children` del padre — por eso
en la PRUEBA02 bajaron 49 descriptores (los accesorios de las 6 cabezas) y ni uno de los
padres.

**Y el aviso del manual no aplica aquí:** sin `CREATE_HOES` el MBIN se construyó, MBINCompiler
lo recompila y lo vuelve a descompilar sin un error. Los bloques `TkResourceDescriptorData`
son autocontenidos; quitarles cabecera y cierre deja el XML válido.

### Por qué importa y qué invalida

Con cascarones, el resultado real de la PRUEBA01 **no era** «sale siempre el mismo lomo»: era
**13 ranuras vacías de 14**. Que el 09/08 no crasheara nada sigue siendo un dato bueno —
`[Inferencia]` una ranura hueca se salta y el bicho sale sin esa pieza— pero **no probó lo que
el doc dice que probó**. La PRUEBA03 es la primera que de verdad concentra la elección.

## Qué se dejó y por qué

De las 8 cabezas quedan **`_HEAD_TREX`** (la de dientes, con sus `_TRTEETH_` y `_REXSET_`) y
**`_HEAD_ALIEN`** (el blob con `_EYES_`, `_ANTENNAS_` y `_MOUTHW_`/`_MOUTHF_`) — las dos más
monstruosas. Caen con ellas 49 accesorios de las otras seis.

**Cambiar la selección es editar una lista de strings**, `CABEZAS`, y reconstruir. `_BODY_` y
`_TAIL_` se dejan intactos a propósito: una variable por prueba.

## Construir y desplegar

```
tools\Build-Tiers.ps1 -Carpeta predadores
```

**Esperado: 0 cambios y 0 errores en las dos configuraciones.** Aquí el conteo del REPORT
**no sirve de verificación**: los `REMOVE` no cuentan como CHANGE. La verificación es
descompilar y **contar descriptores** — 91 en la PRUEBA03.

Desplegado el 2026-08-12 copiando el `.MBIN` de
`tools\AMUMSS\ModBackups\HT_PredatorParts_PRUEBA03\` a
`GAMEDATA\MODS\HT_PredatorParts_PRUEBA03\`, y **retirando `HT_PredatorParts_PRUEBA01`**, que
escribía el mismo archivo. Verificado descompilando desde `GAMEDATA\MODS`: 91 descriptores,
`_HEAD_` con `_HEAD_TREX` y `_HEAD_ALIEN`, `_RATBACK_` y `_REXBACK_` con una hoja cada uno.

**NMS se arranca desde Steam** — estos mods no los gestiona Vortex, y solo se leen al arrancar.

## ✅ Probado en partida el 2026-08-12 — la PRUEBA03 pasa

Palabras del usuario: *«in game solo encontré depredadores con cabezas de (reptil, dinosaurio
o lagarto), no sabría si son la misma que buscábamos pero **no salieron ninguna otra** y no
encontré errores en las mallas o que crasheara o se bugeara»*.

| Pregunta | Respuesta |
|---|---|
| ¿Los depredadores salen bien montados? | ✅ **Sí.** Cero mallas rotas, cero crashes, cero bugs |
| ¿Se repiten las cabezas? | ✅ **Sí, y es el punto.** Ninguna cabeza fuera del grupo que dejamos |
| ¿Aguanta borrar un subárbol entero? | ✅ **Sí.** Los 49 accesorios caen sin secuela |

**Esto es lo que la PRUEBA01 nunca demostró.** Con `CREATE_HOES` quedaban 13 ranuras huecas
de 14 y «no crashea» era todo lo que se podía concluir. Sin el flag, de 172 descriptores a
91, y **la concentración se ve en pantalla**: la poda del descriptor queda validada de punta
a punta como palanca de aspecto.

### Un fleco: falta ver el blob

Se dejaron dos cabezas, `_HEAD_TREX` (dientes) y `_HEAD_ALIEN` (blob). Lo descrito —reptil,
dinosaurio, lagarto— **suena todo a `_HEAD_TREX`**; del blob no se informa.

Dos lecturas, y no hace falta decidir hoy:

1. Los tres nombres son **la misma cabeza** vista a distintos tamaños y ángulos. Lo más
   probable: `_HEAD_LIZ` y `_HEAD_CROC` están borradas, así que un «lagarto» avistado solo
   puede ser la de dientes.
2. `_HEAD_ALIEN` sale menos, o no salió en esa muestra.

**No es un fallo**: la prueba pedía que no apareciera ninguna de las seis borradas, y ninguna
apareció. Queda anotado por si al ampliar la poda conviene saber si el blob llega a montarse.

## Lo que esta vía **no** alcanza

`FIEND`, `FREIGHTERFIEND` y `MINIFIEND` son **un descriptor, una pieza**: no tienen ranuras
que podar. De la familia solo **`BUGFIEND`** tiene descriptor propio (rig `ARTHROPOD`).

Para cambiarles el modelo de verdad quedan dos caminos, y ninguno es éste:

| Camino | ¿Blender? | Estado |
|---|---|---|
| `ReferencePaths` — apuntar un nodo a un `.SCENE` vanilla de otro rig | **No** | ⬜ sin probar, y **degradado el 12/08**: aunque resolviera, la malla llegaría sin pesar contra el esqueleto de destino |
| Malla propia | **Sí, Blender + NMSDK** | ⛔ **Cerrado el 12/08 con la doc oficial.** NMSDK sí genera `.GEOMETRY.MBIN.PC`, pero **no exporta mallas con pesos de hueso** — y toda criatura es `_F02_SKINNED` |

> ⚠️ **Corregido el 2026-08-12.** Este apartado decía que el bloqueo era «MBINCompiler no
> genera `.GEOMETRY.MBIN.PC`». Eso es cierto de MBINCompiler pero **no era el bloqueo**: NMSDK
> sí lo genera. El muro está una capa más adentro, en el nodo `Joint` — *«currently the ability
> to export scenes with these types of animations is not possible»*. Detalle en
> [`../../../docs/ASSETS.md`](../../../docs/ASSETS.md) §4.2.

Bajar un modelo prefabricado **no ahorra el paso caro** y ahora se sabe que ni siquiera lo
alcanza: un OBJ/FBX seguiría necesitando pesarse contra el esqueleto, que es justo lo que la
herramienta no exporta. Lo que ahorra es esculpir, que nunca fue el cuello de botella — y
añade un problema de licencia para Nexus.

**Consecuencia práctica para este mod:** sobre criaturas, las dos palancas de aspecto que
funcionan son **podar el descriptor** (esto, visto el 12/08) y **teñir el material** (el
`BUGFIEND` verde del 11/08). Ninguna necesita Blender. Blender queda para **objetos
estáticos** — huevos, nidos, props.
