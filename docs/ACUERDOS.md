# Acuerdos

**Decisiones ya aprobadas en partida. No se tocan sin que lo pidas.**

Existe por un fallo concreto: la `HT_ScuttlerMesh_PRUEBA14` reinjertó el nodo de malla sobre
el `.SCENE` **vanilla** y con eso resucitó el `AttackLight` que la `PRUEBA13` había dejado
muerto. El SkrullCrawler volvió a salir con el ojo encendido y nadie se enteró hasta verlo en
el juego, **dos pruebas después**. La causa no fue el descuido: fue que el acuerdo vivía en un
paso a mano y nada lo comprobaba.

**Por eso cada fila dice tres cosas: qué se acordó, dónde vive ahora, y quién lo comprueba.**
Un acuerdo cuyo «quién lo comprueba» sea *nadie* es un acuerdo que se va a perder.

Actualizado: **2026-08-27**.

---

## 1 · Los que ya tienen guarda

| # | Qué se acordó | Por qué | Dónde vive | Quién lo comprueba |
|---|---|---|---|---|
| **A1** | El **`AttackLight` va apagado**: `FALLOFF` 0, `INTENSITY` 0, `RADIUS` 0.0001 y `COL` 0,0,0 — los valores de `Light_pointLight1`, la luz inerte que el propio vanilla trae en esa escena | Es un punto de luz de 360° colgado de la mandíbula, amarillo verdoso puro (0.861, 1.0, 0.0) con radio 4,47. El bicho vanilla es rojo oscuro y se lo traga; nuestras pieles tienen blancos y rojos claros y lo devuelven, así que el Horror sale dorado y con el ojo encendido. Aprobado en la `PRUEBA13` | `apagar_luces()` en [`../tools/Graft-NMSScene.py`](../tools/Graft-NMSScene.py), dentro del injerto | `_revisar_acordados()` en [`../tools/Check-NMSGraft.py`](../tools/Check-NMSGraft.py) → bloque **ACUERDOS PERDIDOS** y **salida 1** |
| **A2** | El **techo de 16 bits**: `VertexCount` ≤ 65 536 con `Indices16Bit=1` | NMSDK exportó 69 261 vértices con la bandera puesta y sin una queja. Son índices que dan la vuelta | El presupuesto de triángulos en `tools/Decimate-NMSMesh.py` | `Check-NMSGraft.py`, salida 1 |
| **A3** | **Ningún índice del `.SCENE` fuera de su array del `.GEOMETRY`** | Con los índices pasados el juego cierra sin avisar. Pasó en la `PRUEBA05` | El injerto | `Check-NMSGraft.py`, salida 1 |
| **A4** | **Las aristas de UV no cruzan más del 10 % del atlas** | El index buffer que NMSDK escribía era el de *antes* de partir los vértices de costura: 6 537 vértices muertos en el SkrullCrawler y la piel a remolinos | El parche de `mesh_parser` en [`../tools/Export-NMSMesh.py`](../tools/Export-NMSMesh.py) | El propio `Export-NMSMesh.py`, con un `assert` que revienta el export |
| **A5** | **Los pesos cuelgan de la columna** y **ninguna punta de miembro se lleva más de la mitad del tronco**, y el **reparto va pareado izquierda/derecha** | Son los tres números que separaron los dos pesados malos (`PRUEBA12`, 82 % en dos puntas con `RootJNT` al 0,4 %; `PRUEBA14`, `LFirstLeg3JNT` 12,1 % contra `RFirstLeg3JNT` 0,0 %) | [`../tools/Weight-NMSMesh.py`](../tools/Weight-NMSMesh.py) | Tres `assert` medidos **contra el propio vanilla en la misma corrida** |

---

## 2 · Los que viven en una constante, y hay que leerlos antes de tocarla

**Ninguno de estos tiene guarda automática.** Cambiar el número es cambiar el acuerdo.

| # | Qué se acordó | Por qué | Dónde vive |
|---|---|---|---|
| **B1** | El **necromorfo mide 3,62 m**, o sea **el doble** del AABB del `FIEND` vanilla (1,8098) | La `HT_FiendMesh_PRUEBA01` se midió a la altura del vanilla y **«se veía enano»**: el FIEND es bajo pero mide 5 m de largo. Rehecho a 3,62 y redesplegado | `alto` en `MODELOS["necromorph"]`, [`../tools/Export-NMSMesh.py`](../tools/Export-NMSMesh.py) |
| **B2** | El **zombie mide 2,43 m** | Misma razón; el `ArthropodThorax` vanilla sólo mide 0,84 | `alto` en `MODELOS["zombie"]` |
| **B3** | El **pesado NO reescala el esqueleto** en esos dos: `escala_piel = 1.0` | Los `JointBindings` se copian del vanilla en `Patch-NMSGraft.py`, así que **en partida nuestros vértices se leen en el espacio del vanilla, sin reescalar**. Casar contra un rig hinchado es casar contra huesos que en partida están en otro sitio. Con ×2,0008 `RootJNT` se llevaba el 63,7 % | `escala_piel` en `MODELOS`, [`../tools/Weight-NMSMesh.py`](../tools/Weight-NMSMesh.py) |
| **B4** | El **tope de reparto es ABSOLUTO (85 %)** en el necromorfo y el zombie, y relativo al vanilla sólo en el SkrullCrawler | Un bípedo cuelga casi entero de la columna; una araña reparte la masa entre cabeza y ocho patas. El `FIEND` pone su máximo en `RootJNT` con el **20,4 %** y el `ARTHROPOD` en `head_C0_0_jnt` con el **31,4 %**: el tope relativo **no lo puede pasar ningún pesado de un bípedo, ni el bueno** | `tope_reparto` en `MODELOS` |
| **B4b** | El **necromorfo y el zombie llevan mapa a mano región → hueso**, y con él el tope de punta se sustituye por «el reparto no se separa más de 5 puntos del mapa» | Copiar del vecino más cercano sólo vale entre dos bichos del mismo tipo de animal. La piel del vanilla cabe entera en la **mitad de abajo** de las dos mallas, así que nuestros brazos y nuestra cabeza no tenían cerca más que cuerpo: un solo hueso con el 79,5 % y el 80,1 % | `regiones` en `MODELOS`, [`../tools/Weight-NMSMesh.py`](../tools/Weight-NMSMesh.py). El mapa sale de `--volcar-huesos`, **no se adivina** |
| **B5** | El **`gMasksMap` se INVIERTE, no se atenúa** | El asset entrega `roughness` (alto = áspero = mate) y el shader lee ese canal como **brillo** (alto = mojado). `255 − 173,6 = 81` contra los **85** del vanilla. Atenuar dejaría las grietas brillantes y los bultos mates: el mismo mapa del revés, sólo que más flojo | `--invertir` de `Make-NMSTexture.py`, y el hueco de UV retenido a 0 aparte |
| **B6** | **Triángulos: necromorfo 30 000, zombie 36 000** | `M-CONFETI`. A 5 999 la textura salía a confetti porque estos atlas vienen **horneados por triángulo** | `tools/Decimate-NMSMesh.py` |
| **B7** | Las texturas del zombie van a **rutas propias** (`ZOMBIE.BASE*.DDS`), no a las del `ARTHROPOD` | `ARTHROPODTHORAX01.BASE*.DDS` las comparte **toda la fauna artrópodo del juego**. Lo que se reapunta es el material, que sí es exclusivo del `BUGFIEND` | El `.lua` y `tools/Set-NMSSampler.py` |
| **B8** | El **`.DESCRIPTOR` del `BUGFIEND` va recortado a una entrada**, `_Arthropod_1` sin hijos | Con los diez nodos MESH borrados por el injerto, el descriptor completo cerraba el juego al parir el Horror | `work/models/zombiemesh/BUGFIEND.DESCRIPTOR.MBIN` |
| **B9** | El **nido del techo enciende `IncreaseFiendWanted`**, y la `PRUEBA03` escribe **también** los otros dos campos del `Infestation` (`AgroTorch` 12, `GunfireAgro` 8) | Los dos mods escriben el mismo `MEDIUMHANGSLIME.ENTITY.MBIN` y **el que carga después gana entero y en silencio**. Resuelto por superconjunto: los dos escriben el MISMO MBIN | `HT_CeilingPlague_PRUEBA03.lua` y los cuatro `Infestation` |

---

## 3 · Los de forma, que no son técnicos pero también se pierden

| # | Qué |
|---|---|
| **C1** | `MOD_AUTHOR` es **`AldrichDDD`**, no el usuario de git |
| **C2** | Los `.lua` van **sin comentarios de código**: la explicación va a `docs/` y al `MOD_DESCRIPTION` |
| **C3** | Los nombres de release van en **camelCase y en inglés**, un `.lua` por zip; se traduce sólo al empaquetar |
| **C4** | Cada mod **versiona aparte**: uno nuevo arranca en 0.1.0 aunque reutilice otro |
| **C5** | El `.EXML` de `CreatedMODS` es un **informe**: lo que despliega son los `.MBIN` de `ModBackups` |

---

## 4 · Cómo se añade uno

1. Se mide en partida y se aprueba.
2. Se mueve **fuera del paso a mano**: a un `tools/*.py` que lo haga solo.
3. Se le pone guarda en `Check-NMSGraft.py` si el acuerdo se puede leer del `.SCENE` o del
   `.GEOMETRY`, o un `assert` en el guion que lo produce si no.
4. Se anota aquí, con el número que lo justifica.

> **Un acuerdo sin el paso 3 va a la sección 2, y la sección 2 hay que leerla entera antes de
> tocar cualquier constante.**
