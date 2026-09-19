# Cómo se sube un mod a Nexus — reglas comunes

**Esto vale para todos los mods del repo.** Los textos y capturas de cada página viven aparte:
[`NEXUS.md`](NEXUS.md) es la del mod 1 y [`NEXUS-BETA.md`](NEXUS-BETA.md) la de la beta. Aquí
está sólo lo que **no cambia de un mod a otro**, y cada ficha de mod enlaza a este archivo en su
sección de subida.

> **Se lee entero antes de comprimir nada.** Las trampas de §1 no dan error: dan un zip que
> parece bien y un mod que no carga, o que carga a medias y el jugador no se entera.

---

## 1 · Las trampas que ya nos costaron un release

### 1.1 · El `.EXML` de `CreatedMODS` es un delta, no un archivo

**Nunca se sube lo que hay en `CreatedMODS`.** AMUMSS deja ahí un `.EXML` con marcas
`!# ADDED` y `!# CHANGED` al final de cada línea que tocó. Eso **no es XML válido** y el juego
no lo lee. Los mods de terceros que sí cargan con `.EXML` lo llevan limpio, sin una sola marca
(comprobado contra `Asteroid Ribbons`).

**Lo que se entrega es el `.MBIN` de `ModBackups`**, que es lo mismo que el juego carga
(verificado por md5 contra `GAMEDATA\MODS`).

> Esto volvió a pasar el **2026-09-16**, ya con la regla escrita: se desplegaron el mod 6 y la
> infestación copiando `CreatedMODS` tal cual, y los archivos salieron con 5 y 39 marcas `!#`
> respectivamente. Se detectó al releer este mismo aviso. **Comprobación de un segundo:**
> `grep -c '!#' <archivo>` tiene que decir **0**.

### 1.2 · Un `.MBIN` construido contra la versión anterior del juego **cierra el juego**

**Esto costó el release `models-0.1.0` entero.** Lo reportó un jugador el 2026-09-17: tres
de los cuatro mods de malla cerraban el juego al empezar partida nueva. La causa era que
sus `.SCENE.MBIN` se construyeron contra **6.45** y el juego ya iba por **7.02**, y entre
medias `TkSceneNodeData` ganó un campo (`InstanceTransforms`). El juego lee los campos
donde ya no están y **se cierra sin decir nada**.

**No basta con que las rutas no hayan cambiado**, que es lo que se miró en la 2.1.1: lo que
importa es si la **plantilla** de cada archivo cambió. Se ve en la cabecera, sin entrar al
juego:

- bytes `0x18`/`0x19` = major/minor de NMS con el que se construyó (`06 2d` = 6.45,
  `07 02` = 7.02)
- bytes `0x10..0x17` = hash de la plantilla. Si difiere del que trae un `.MBIN` vanilla de
  la versión actual, **ese archivo ya no se puede leer**

**Comprobación de un segundo, y es la que manda:** pasarle el archivo al `MBINCompiler` de
la versión del juego. Si dice **«File not recognized. You may need to use an older (or
newer) version of MBINCompiler»**, el juego tampoco lo va a leer. Vale para todos los
`.MBIN` del zip, no sólo para los de malla.

**El arreglo** es recompilar el `.MXML` que quedó en `work/models/` con el `MBINCompiler`
nuevo, y en los `.MATERIAL` partir del vanilla de la versión actual y ponerle encima sólo
nuestras rutas `Map`. Detalle completo en [`MODELOS/README.md`](MODELOS/README.md) §0.1.1.

> ⚠️ **Un `.MBIN` válido no basta.** Los `.GEOMETRY` no tienen plantilla que caducar y aun así
> 7.x los rompió: **cambió el formato del stream de vértices** y las mallas salen traslúcidas,
> sin un solo error. Eso no lo caza el `MBINCompiler`; se mira con
> [`../tools/Repack-NMSVertex.py`](../tools/Repack-NMSVertex.py), que además lo arregla. Ver
> `MODELOS/README.md` §0.1.1 segunda vuelta.

### 1.3 · `ModBackups` aplana `GLOBALS\`

El `.MBIN` de cualquier global sale en la **raíz** de `ModBackups\<mod>\`, no en
`ModBackups\<mod>\GLOBALS\`. Empaquetar la carpeta tal cual manda `GCCREATUREGLOBALS.MBIN` a la
raíz del mod y **el juego no lo lee**. Hay que devolverlo a `GLOBALS\`.
`Package-SinFuente.ps1` ya lo hace; a mano hay que acordarse.

### 1.4 · Renombrar la carpeta de un mod ya publicado

**No se hace.** Quien actualice extrayendo el zip nuevo se queda con **las dos carpetas** —la
vieja no se borra sola—, las dos escriben los mismos archivos, y NMS carga una y descarta la
otra **sin avisar**. El jugador sigue jugando la versión vieja creyendo que actualizó.

El **título de la página sí** se puede cambiar: Nexus lo trata como metadato. En 2.1.0 el mod 1
pasó a *More Aggressive Predators* sin tocar una sola carpeta.

Los mods que **aún no se han publicado** nacen con el nombre bueno y no arrastran nada.

### 1.5 · `ModBackups` se queda viejo cuando un binario se arregla a mano

**Encontrado el 2026-09-18, empaquetando la `models-0.1.2`.** `ModBackups` es lo que AMUMSS
escribió la última vez que se construyó el mod, y **no se entera de nada que se arregle
después**. El repack de vértices de la `0.1.1` —el que quitó las siluetas translúcidas— se
aplicó al zip y a `GAMEDATA\MODS`, pero **no** a `ModBackups`. Medido:

| | `.GEOMETRY.DATA.MBIN.PC` del cryWolf |
|---|---:|
| zip `models-0.1.1` | **468 852 B** — stride 16, `sem11` |
| `ModBackups` | 513 252 B — stride 20, `sem2`/`sem3` |

La diferencia son **exactamente 4 bytes por vértice**. Reempaquetar desde `ModBackups` habría
vuelto a publicar el fallo que ese release arregló, sin un solo aviso.

**La regla:** antes de reempaquetar algo que ya se publicó, **comparar por md5 contra el zip
anterior y contra `GAMEDATA\MODS`**. Manda lo que está desplegado y probado en partida, no lo
que dejó AMUMSS.

### 1.6 · Una carpeta de `ModBackups` acumula los mods construidos después

De la misma tanda. `ModBackups\HT_CryWolf_PRUEBA07` contiene hoy **los tres bichos**: su
`FIEND.*`, más el `BUGFIEND.*` del warrior bug y el `FREIGHTERFIEND.*` del skull crawler, más
seis `.lua` de otros mods. El zip de la `0.1.1` está limpio, así que se contaminó **después**
de empaquetarlo.

`Package-SinFuente.ps1` copia la carpeta entera y sólo filtra `.lua`, `.txt`, logs y `.MXML`:
**los `.MBIN` y `.DDS` ajenos sí viajarían**. Un jugador que instalara sólo el cry wolf se
llevaría además, en silencio, el modelo de los otros dos.

**La regla:** listar el contenido del zip antes de subir; tiene que ser **sólo los archivos de
ese bicho**. La `0.1.2` se empaquetó desde un origen limpio montado aparte, con `-Origen`, y
`ModBackups` no se tocó.

---

## 2 · El zip con barras invertidas — el fallo de los que no usan Windows

**Lo reportó un jugador en el `Infested V0.9.0`**, y es el único fallo del repo que encontró
alguien de fuera antes que nosotros.

**Qué pasaba.** El zip guardaba sus rutas internas con **`\`** como separador en vez de **`/`**.
Windows lo traga; Linux y buena parte de las herramientas no-Windows **no reconocen `\` como
separador de carpetas**. Resultado: al extraer no se creaba ni una carpeta y salía todo plano,
con las barras dentro del nombre del archivo:

```
infested\METADATA\SIMULATION\...     <- UN nombre de archivo larguísimo, no una ruta
```

Y un mod sin estructura de carpetas **no lo carga NMS**, así que para ese jugador el mod
simplemente no existía. No hay error ni aviso: se extrae «bien» y no pasa nada.

**Por qué pasaba.** Tanto `Compress-Archive` como `ZipFile::CreateFromDirectory` escriben el
nombre de entrada con `\`. La spec de zip (**APPNOTE 4.4.17.1**) manda `/`.

**Cómo está arreglado.** Los dos scripts de §4 **ya no usan ninguno de los dos**: abren el zip y
nombran cada entrada a mano, forzando `/`. Está en `Package-Release.ps1` y en
`Package-SinFuente.ps1`, con el comentario y la cita de la APPNOTE al lado para que a nadie le
tiente «simplificarlo» a `Compress-Archive`:

```powershell
$rel = $f.FullName.Substring($raiz.Length).Replace('\', '/')
[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zf, $f.FullName, $rel, 'Optimal')
```

> ⛔ **La regla, y no tiene excepción: el zip lo hace el script, nunca «Enviar a → Carpeta
> comprimida» del Explorador ni `Compress-Archive`.** Si hay que rehacer un zip a mano, vale
> 7-Zip, WinRAR o el `zip` de Linux: los tres escriben separadores estándar.

**Cómo se comprueba antes de subir** — mira los nombres de dentro sin extraer nada:

```bash
python -c "import zipfile,sys; n=[x for x in zipfile.ZipFile(sys.argv[1]).namelist() if '\\\\' in x]; print('MAL:',n[:5]) if n else print('OK: separadores correctos')" mimod.zip
```

**Y si hay que arreglar un zip ya subido:** extraerlo en Windows (o con 7-Zip) y volver a
comprimir desde la carpeta extraída con 7-Zip, WinRAR o `zip`. Eso produce un archivo que se
extrae bien en Windows **y** en Linux.

> 📏 **Auditados los 26 zips de `releases\` el 2026-09-17: los 26 salen limpios**, incluido el
> `infested_v0.9.0.zip`. O sea que **la copia local del 0.9.0 no es la que falló**: o se
> reconstruyó después del arreglo, o lo que se subió a Nexus se comprimió por otra vía. La
> consecuencia práctica es la que importa: **que el zip esté bien en `releases\` no demuestra
> que el que está colgado en Nexus lo esté**. Para los que ya están publicados, la comprobación
> es descargarlos de Nexus y pasarles el comando de arriba.

---

## 3 · Qué va dentro del zip

- **Una carpeta instalable, con el nombre exacto** que va a quedar en `GAMEDATA\MODS\`
- **`.MBIN`, nunca `.EXML`** — §1.1
- **`GLOBALS\` en su sitio** — §1.2
- **Un `.lua` por zip**, el de esa configuración y ninguno más. Hasta la 1.1.0 iban los cuatro
  tiers en cada zip, y eso invita al jugador a construirse el que no instaló
- **Los `.lua` se publican sin comentarios.** `Package-Release.ps1` aborta si encuentra alguno,
  diciendo archivo y línea. La explicación de un mod vive en `docs\`, no en el fuente. Escape:
  `-PermitirComentarios`
- **Nada de basura de AMUMSS**: `AMUMSS_v*.txt`, `*.log`, `_REPORT_*`, `*.bak`, `Thumbs.db`,
  `desktop.ini`. El script los borra del stage antes de comprimir
- **Un `README.txt`** con instalación, desinstalación y el aviso de no instalar dos tiers a la
  vez

## 4 · Con qué se empaqueta

| Script | Cuándo |
|---|---|
| [`../tools/Package-Release.ps1`](../tools/Package-Release.ps1) | Release normal, **con** el `.lua` dentro |
| [`../tools/Package-SinFuente.ps1`](../tools/Package-SinFuente.ps1) | Cuando el `.lua` se queda en casa — mallas y conducta. Trae README propio y esquiva las trampas §1.1 y §1.2 |

**Límite honesto, y va escrito para que nadie se confíe:** los `.GEOMETRY` y los `.DDS` que sí
viajan **son** los modelos. Cualquiera con MBINCompiler y NMSDK los importa a Blender. Quitar el
`.lua` esconde el método, no la malla.

## 5 · Vortex

**No hay que hacer nada.** El layout de §3 es exactamente el que Vortex espera.

## 6 · Antes de dar a publicar

- [ ] **Los separadores de dentro del zip son `/`** — la comprobación de §2. Es la única que
      falla en silencio y en una máquina que no es la tuya
- [ ] El zip lo hizo el script, no el Explorador ni `Compress-Archive`
- [ ] **Ni un `.MBIN` del zip está construido contra una versión vieja del juego** — la
      comprobación de §1.2. Es la que cerró el juego a un jugador en la `models-0.1.0`
- [ ] `grep -c '!#'` da **0** en todos los archivos del zip
- [ ] No hay ni un `.EXML` donde debería haber `.MBIN`
- [ ] Los globals están en `GLOBALS\`, no en la raíz
- [ ] La carpeta se llama igual que en la versión anterior, si ya estaba publicada
- [ ] Ni un `.lua` con comentarios, ni basura de AMUMSS
- [ ] Las capturas salen de la carpeta del mod (`Capturas Mod N\`) y están en el orden que
      manda la página
- [ ] Los permisos y créditos que tocan: los del mod 1 **no** valen para los mods con modelos
      de terceros, ahí mandan las licencias CC — ver [`credits.md`](credits.md)
