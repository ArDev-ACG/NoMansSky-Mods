# Horrible Terror — Depredadores · 4 configuraciones

Mod de dificultad independiente. Sube la agresividad y la presencia de los
depredadores que cazan al jugador.

## ⚠️ Instala UNA sola

Las cuatro escriben **los mismos 4 archivos**. Tener dos activas hace que una pise a
la otra en silencio — no rompe el juego, pero acabas sin saber cuál está mandando.

Lo mismo aplica al construir: si dejas las cuatro en `ModScript\`, AMUMSS genera
cuatro mods que colisionan. **Solo una en `ModScript\` a la vez.**

## Las cuatro

| Parámetro | Vanilla | 1 Fácil | 2 Normal | 3 Difícil | 4 Hardcore |
|---|---:|---:|---:|---:|---:|
| Densidad terrestre | ×1 | ×2 | ×5 | ×20 | ×20 |
| Peso `DANGEROUS` | 1 | 3 | 10 | 1000 | 1000 |
| → % planetas hostiles | 9% | 23% | 50% | 99% | 99% |
| Manada min/max | 1/1 | 1/2 | 2/3 | 3/5 | 5/7 |
| Percepción (m) | 40 | 45 | 50 | 60 | 80 |
| Huye al % de vida | 40 | 30 | 15 | 0 | 0 |
| % depredadores hostiles | 0.5 | 0.6 | 0.75 | 1.0 | 1.0 |
| Tope criaturas a la vez | 40 | 45 | 50 | 60 | 70 |
| Distancia de aburrimiento | 80 | 80 | 80 | 80 | 150 |

**Fácil** — vanilla con un empujón. Los depredadores siguen retirándose heridos y
van casi solos. Para quien quiere algo de tensión sin cambiar cómo se juega.

**Normal** — la mitad de los planetas son hostiles, parejas o tríos, y aguantan más
antes de huir. Punto de equilibrio.

**Difícil** — casi todo planeta es hostil, manadas de 3 a 5, y **nunca huyen**.
Cambia cómo aterrizas: mirar antes de bajar deja de ser opcional.

**Hardcore** — manadas de 5 a 7, te detectan a 80 m y te persiguen 150. Con el tope
de criaturas a 70. Pensado para quien ya jugó Difícil y lo encontró manejable.

## Cómo cambiar de configuración

1. Vaciar `tools\AMUMSS\ModScript\` de cualquier `HorribleTerror_Predators_*.lua`.
2. Copiar ahí **una** de las cuatro.
3. Correr `BUILDMOD.bat` (F / P / N / N).
4. Verificar el conteo de cambios y el EXML delta.
5. Borrar de `GAMEDATA\MODS\` la carpeta `HorribleTerror_Predators_*` anterior.
6. Copiar la nueva.
7. **Reiniciar NMS** — los mods solo se cargan al arrancar.

El paso 5 no es opcional. Si dejas dos, colisionan.

## Conteo esperado por build

| Config | Cambios |
|---|---:|
| Fácil / Normal / Difícil | 13 |
| Hardcore | 14 |

Desglose: 5 en `CREATUREGENERATIONDATA` (4 densidad + 1 peso), 2 × 2 en las tablas
`PLAYERPREDATOR`, y 4 en `GCCREATUREGLOBALS` (5 en Hardcore, que además toca
`BoredomDistance`).

Si el número no cuadra, **parar y leer el delta** antes de desplegar. Un
`0 [ERROR] detected` no prueba que el mod haga lo correcto — ya nos pasó.

## Archivos que toca

```
METADATA\SIMULATION\ECOSYSTEM\CREATUREGENERATIONDATA.MBIN
METADATA\SIMULATION\ECOSYSTEM\GROUND\GROUNDTABLEPLAYERPREDATORMED.MBIN
METADATA\SIMULATION\ECOSYSTEM\GROUND\GROUNDTABLEPLAYERPREDATORLARGE.MBIN
GLOBALS\GCCREATUREGLOBALS.MBIN
```

Ninguno lo tocan los otros 87 mods instalados (comprobado). Compatible con el mod de
paletas (`HorribleTerror_RedFauna`) y con el futuro de monstruos, que van a otras
rutas.

## Si hay que aflojar

Estos parámetros **se multiplican entre sí**, no se suman. Orden para bajar
dificultad sin saltar de tier:

1. `PCT_HOSTILE` — el que más rinde y no cuesta rendimiento.
2. `PACK_MAX` — tamaño de manada.
3. `MAX_CREATURE` — el único con coste de FPS real; si el juego se arrastra, este.
4. `DENSITY_MULT` — **el último**. Ya está topado por `MaxEcosystemCreatures`, así
   que bajarlo hace menos de lo que parece.

## Notas de diseño

`PlayerPredatorBoredomDistance` solo lo toca Hardcore. Los otros tres lo dejan en el
80 de vanilla en vez de reescribirlo con el mismo valor: un cambio nulo ensucia el
EXML delta y hace más difícil leer qué tocó el mod de verdad.

En Difícil y Hardcore la percepción sube (60, 80) pero el aburrimiento no acompaña en
Difícil, así que el margen para escapar se estrecha de 40 m a 20. Hardcore lo
compensa subiendo el aburrimiento a 150 — ahí la intención es justo la contraria: que
escapar cueste.
