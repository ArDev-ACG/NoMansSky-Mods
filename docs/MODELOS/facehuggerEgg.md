# facehuggerEgg — `FIENDEGG` · **construido, sin probar en partida**

**Qué es.** El huevo cerrado de *"Facehugger Egg"* (`xenoEgg`), 3 MB, un solo par
de texturas D/N de 1024².

**A quién sustituye.** `FIENDEGG`, los huevos del suelo infestado. **Releva al
[markerEgg](markerEgg.md)**: los dos escriben los mismos archivos y no pueden
estar puestos a la vez.

| | |
|---|---|
| Rig | ninguno — prop estático |
| Nodo de malla | `FiendEgg` |
| Malla | **3 064 triángulos, 1 881 vértices. Sin decimar** (el presupuesto de 6000 no llega a morder) |
| `giro` | `(-90, 0)` |
| `alto` | **0.761688 m** |
| Fuente | `asset/Modelos Descomprimidos/facehugger-egg/source/xenoEgg.fbx` |
| `.blend` | `BLENDER/proyectos/facehuggeregg.blend` → `facehuggeregg_nms.blend` |
| Injerto | `work/models/facehuggereggmesh/` |
| Build | `work/scripts/malla/HT_FacehuggerEgg_PRUEBA01.lua` — AMUMSS, 0 errores |
| Desplegado | `GAMEDATA\MODS\HT_FacehuggerEgg_PRUEBA01\`, verificado descompilando el MBIN |

## Cómo se hizo

Vía corta, la misma del marker: **sin piel, sin pesos, sin `Weight-`, `Skin-` ni
atlas**. `Decimate-` → `Export-` → `Graft-` → `Check-`.

**El `alto` se midió, no se eligió.** `AABBMAXY 0.708496` menos `AABBMINY
-0.053192` del nodo `FiendEgg` vanilla = **0.761688**. Escala uniforme 0.8267.

**Se injertó contra el vanilla de 7.0, no contra el de 6.45.** Y hubo que
hacerlo: el `FIENDEGG.SCENE.MBIN` de agosto **ya no descompila** con el
compilador 7.00 (`File not recognized`). El vanilla reextraído está guardado en
`work/models/vanilla_7.0_fiendegg/`. Detalle en
[`../COSMOS-ASSETS.md`](../COSMOS-ASSETS.md) §1.

## Las dos herramientas que este modelo arregló

**1. El assert de UV de `Export-NMSMesh.py` era dependiente del tamaño.** Saltó
con 1,11 % de aristas largas contra un tope del 0,1 %. Pero el 0,1 % se calibró
contra el warrior bug, de 108 000 triángulos, donde permite **324** aristas
sueltas; en una malla de 3 064 permite **9**. El huevo trae 102, que en el
warrior bug habrían pasado sin mirarlas. Las dos señales que **no** dependen del
tamaño decían que la malla está bien: la arista UV más larga mide 0,174 —cabe en
una celda del atlas de 0,25— y correlaciona **0,825** con la arista en 3D. Y la
malla no se decimó, así que tampoco es el colapso. Se añadió `tope_uv` por
modelo; el resto sigue en 0,1.

**2. `Check-NMSGraft.py` daba un falso «el juego cierra al usarlo».** Exigía una
entrada de `MeshBaseSkinMat` por malla, y **el `FIENDEGG` vanilla trae ese array
vacío**: es un prop estático, cero nodos `JOINT`, stride 8. Ahora ese chequeo
solo corre si hay huesos. El marker, que es el mismo caso, lleva publicado desde
agosto sin cerrar nada.

## Qué falta comprobar en partida

Tres cosas, y las tres están escritas en la descripción del `.lua`:

- **El ancho.** 1,113 contra 0,643 del vanilla: **1,7 veces más ancho a la misma
  altura**. Puede clavarse en el decorado o solaparse con el huevo de al lado.
- **El giro en Y**, que se dejó en **0**. El huevo es casi de revolución y el
  volcado no distingue el frente; lo único que lo distingue es por dónde abre.
  Si abre hacia el lado equivocado, eso es lo que se toca.
- **La altura de apoyo.** Nuestra base se apoya en `Y = 0` y la vanilla se hunde
  5 cm (`AABBMINY -0.053`). Puede quedar flotando.

**Prueba:** arrancar NMS **por Steam** (Vortex solo gestiona los mods de
terceros) y buscar un planeta infestado. Backup de partida ya hecho:
`NMS_saves_2026-09-13_2306`.
