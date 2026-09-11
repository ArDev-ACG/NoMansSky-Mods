<#
.SYNOPSIS
    Empaqueta para Nexus SIN publicar el .lua. Mallas y conducta.

.DESCRIPTION
    Hermano de Package-Release.ps1, y aparte a proposito. Lo que hace distinto:

      - SIN Source\. Lo que se entrega son los binarios ya construidos. El .lua
        es la receta -que archivo del vanilla se injerta, el bind, el reparto de
        peso, y en el Infestation la MOD_DESCRIPTION entera, que son 25 KB de
        razonamiento- y esa se queda en casa.
      - SIN .pak. NMS 6.x carga la carpeta.
      - README propio: beta, fallos conocidos y creditos por mod.
      - Entrega .MBIN, nunca el .EXML de CreatedMODS. Ver la nota de abajo.

    Limite honesto, escrito para que nadie se confie: los .GEOMETRY y los .DDS
    que si viajan SON los modelos. Cualquiera con MBINCompiler y NMSDK los
    importa a Blender. Quitar el .lua esconde el metodo, no la malla.

.NOTES
    DOS TRAMPAS QUE ESTE SCRIPT ESQUIVA, y las dos estan en los releases del
    mod 1 que ya se subieron.

    1) ModBackups APLANA GLOBALS\. El .MBIN de un global sale en la RAIZ de
       ModBackups\<mod>\, no en ModBackups\<mod>\GLOBALS\. Comprobado el
       2026-09-05 contra GAMEDATA\MODS\HorribleTerror_Infestation_4-Hardcore, que
       es lo que el juego carga: mismo md5, distinta ruta. Empaquetar la carpeta
       tal cual manda GCCREATUREGLOBALS.MBIN a la raiz del mod y el juego no lo
       lee. Este script lo devuelve a GLOBALS\.

    2) El .EXML de CreatedMODS es un DELTA, no un archivo. Lleva marcas
       "!# CHANGED" al final de cada linea cambiada -34 en el GCCREATUREGLOBALS
       del release 2.1.0- y eso no es XML valido. Los mods de terceros que si
       cargan con .EXML lo llevan LIMPIO, sin una sola marca (comprobado contra
       Asteroid Ribbons). Aqui solo viajan .MBIN, que es lo que esta verificado
       funcionando en la instalacion local.

    Los binarios salen de ModBackups, que es de donde se despliega. Verificado
    por md5 contra GAMEDATA\MODS el 2026-09-05: identicos en los cuatro mods de
    malla y en el Infestation Hardcore.

.PARAMETER Grupo
    Que tanda se empaqueta: "models" o "infestation". Sale a
    releases\<Grupo>-<Version>\. En ingles, como todo lo que ve el jugador.

.PARAMETER Version
    Version del release. Cada mod versiona aparte: los modelos van por 0.1.0 y
    el Infestation por 0.9.0.

.PARAMETER Origen
    Carpeta con las carpetas de mod. Por defecto tools\AMUMSS\ModBackups.

.PARAMETER Solo
    Empaqueta solo los mods cuyo nombre de release este en esta lista.

.EXAMPLE
    .\Package-SinFuente.ps1 -Grupo models      -Version 0.1.0
    .\Package-SinFuente.ps1 -Grupo infestation -Version 0.9.0
#>
param(
    [Parameter(Mandatory=$true)][ValidateSet("models","infestation")][string]$Grupo,
    [Parameter(Mandatory=$true)][string]$Version,
    [string]$Origen,
    [string[]]$Solo = @(),
    [string]$VersionNMS = "170671 (Public branch)"
)

$ErrorActionPreference = "Stop"

# --- bloques de convivencia, que es lo unico que cambia de raiz entre tandas ---
$MEZCLA_INDEPENDIENTE = @"
Each creature is its own download and each one writes its own files, so you can
install one, some, or all of them side by side.

Two rules:
  - Never keep two versions of the SAME creature. Delete the old folder first.
  - Any other mod that replaces the same creature's model will conflict. The
    game loads one and ignores the other, silently, with no error.

Nothing here changes behaviour, spawn rates or damage, so it sits fine on top
of gameplay mods.
"@

$MEZCLA_INFESTATION = @"
*** PICK ONE GAMEPLAY FILE. THERE ARE TWO. ***

  Infested            - the full thing. They hunt you.
  Infested - Easy     - more horrors in the world, none of the hunting.

They edit the same game files. Installing both means one silently overrides
the other, and nothing will tell you which one won.

To switch: DELETE the old folder first, then extract the other one.

*** Do NOT install either one alongside "More Aggressive Predators". ***
This mod already contains that one, and they write the same files.

Both DO combine with the creature model mods: those only change how things
look, and touch none of these files.

More aggression levels are coming between these two. Same rule will apply:
install one, delete the old folder first.
"@

# --- que se publica -----------------------------------------------------------
# Carpeta de AMUMSS -> nombre de release + textos del README.
# El nombre de release NO lleva el ordinal de prueba: es el nombre que el jugador
# va a tener extraido en GAMEDATA\MODS, y renombrarlo en una version futura le
# dejaria las dos carpetas peleandose. Ver docs\NEXUS.md.
$MODS = @(
    @{
        grupo   = "models"
        carpeta = "HT_CryWolf_PRUEBA07"
        release = "infestedCryWolf"
        titulo  = "Cry Wolf"
        mezcla  = $MEZCLA_INDEPENDIENTE
        que     = @"
Replaces the model of the big horror that erupts out of the ground eggs on
infested planets - the one that chases you across the surface - with a
long-necked quadruped built by hand in Blender.

Model swap only. Nothing about how it behaves, how many show up or how hard it
hits is touched.
"@
        fallos  = @"
  - The legs swing less than they should. The mesh hangs off the hip joint, so
    the lower leg follows the body instead of planting on the ground. It reads
    as a stiff walk. Being worked on for the next version.
  - It is taller than the creature it replaces, so it can clip into low
    scenery.
"@
        creditos = @"
  Model: "Cry Wolf Game Character" (https://skfb.ly/6VFUz) by SkinRender,
  licensed under Creative Commons Attribution
  (http://creativecommons.org/licenses/by/4.0/).
  Remeshed, re-textured and re-rigged for No Man's Sky.
"@
    }
    @{
        grupo   = "models"
        carpeta = "HT_WarriorBug_PRUEBA05"
        release = "infestedWarriorBug"
        titulo  = "Warrior Bug"
        mezcla  = $MEZCLA_INDEPENDIENTE
        que     = @"
Replaces the model of the smaller brood that the big horror spawns while it
fights you - the ones that pour out around it - with an armoured insect built
by hand in Blender.

Model swap only. Nothing about how it behaves, how many show up or how hard it
hits is touched.
"@
        fallos  = @"
  - The legs swing less than they should. The mesh hangs off the hip joint, so
    the lower leg follows the body instead of planting on the ground. First
    thing on the list for the next version.
  - The skin reads flatter than intended under some lighting. Raising the
    texture resolution did not fix it, so it is a material problem and it is
    still open.
"@
        creditos = @"
  Model: "Warrior bug from 'Starship Troopers'" (https://skfb.ly/o87nr) by
  wtf_fox, licensed under Creative Commons Attribution
  (http://creativecommons.org/licenses/by/4.0/).
  Remeshed, re-textured and re-rigged for No Man's Sky.
"@
    }
    @{
        grupo   = "models"
        carpeta = "HT_ScuttlerMesh_PRUEBA17"
        release = "infestedSkullCrawler"
        titulo  = "Skull Crawler"
        mezcla  = $MEZCLA_INDEPENDIENTE
        que     = @"
Replaces the model of the biological horror that nests inside abandoned
freighters - the one waiting for you in the dark corridors - with an original
creature built by hand in Blender.

Model swap only. Nothing about how it behaves, how many show up or how hard it
hits is touched.
"@
        fallos  = @"
  - None reported. This is the most finished of the four: the glowing eye is
    off and the back is clean. If you see anything, say so.
"@
        creditos = @"
  Model: original work by AldrichDDD. Not derived from any third-party asset.
"@
    }
    @{
        grupo   = "models"
        carpeta = "HT_EggMesh_PRUEBA05"
        release = "infestedMarkerEgg"
        titulo  = "Marker Egg"
        mezcla  = $MEZCLA_INDEPENDIENTE
        que     = @"
Replaces the model of the eggs you find on infested planets - the ones that
crack open and bring the horrors down on you - with a carved standing monolith.

Model swap only. The eggs still hatch, still count as a crime when you break
them, and still call the same thing down on your head.
"@
        fallos  = @"
  - None reported. It is a static prop and it is scaled to the egg it replaces.
    If it ever floats or sinks into the ground, that is worth a report.
"@
        creditos = @"
  Model: "Marker 1" (https://skfb.ly/6SzLo) by username11420, licensed under
  Creative Commons Attribution-ShareAlike
  (http://creativecommons.org/licenses/by-sa/4.0/).
  Remeshed and re-textured for No Man's Sky. Because the original is
  ShareAlike, the model and texture files in THIS download stay under
  CC BY-SA 4.0: you may reuse and adapt them as long as you credit and
  share alike.
"@
    }

    # DOS entregas de conducta, y nada mas. Decidido el 06/09.
    #
    # La fuerte va SIN etiqueta de nivel en el nombre de carpeta
    # -infested, no ...Hardcore- para que los niveles que
    # lleguen despues se instalen encima sin renombrar nada. La Easy si lleva
    # su nombre: nace siendo un extremo y ahi se queda.
    #
    # Desde la 0.9.2 se publican los cuatro. El 2-Normal y el 3-Dificil llevaban
    # desde el 18/08 congelados en 0.6.4 y 0.5.0 -sin el interes de la 0.9.0, sin
    # las palancas de la 0.8.0 y sin el drenaje de aggro de la 0.7.0- y se pusieron
    # al dia escalados: cada numero suyo queda entre el Easy y el fuerte. Siguen
    # SIN jugarse, y eso va dicho en KNOWN ISSUES de sus dos README.
    @{
        grupo   = "infestation"
        carpeta = "HorribleTerror_Infestation_4-Hardcore"
        release = "infested"
        titulo  = "Infested"
        mezcla  = $MEZCLA_INFESTATION
        que     = @"
Seeds the galaxy with biological horrors, and makes everything that already
hunts you hunt a lot harder.

Twenty times the horror eggs and the sand worm nests, so infested worlds
actually feel infested. Predators come in packs of 5-7, spot you at 80 m and
chase you to 150 m instead of losing interest. The horrors themselves see you
at 120 m, spawn brood while they are fighting you, pounce three times further
and from higher ground, spit constantly, and their brood hits as hard as the
parent does. The nests inside abandoned freighters react to your torch and to
your gunfire, and breaking one calls horrors down on you.

Almost every planet rolls hostile, and on a hostile planet every ground
species comes from the tables that hunt you. There is nowhere quiet.

This is the one that gets played and tested. If it is too much, there is an
Easy file - see INSTALLING MORE THAN ONE below.

This mod CONTAINS the "More Aggressive Predators" mod. Do not install both.
"@
        fallos  = @"
  - This build is tuned HIGH, on purpose. It is the hard end of what is
    coming: more aggression levels will land between this and Easy, and what
    people report here is what decides where they land.
  - Horrors still break off and walk away, and it happens the moment they roar.
    The roar is what spawns their brood, so the two are connected. Not solved -
    it is the next thing being worked on.
  - FPS. This is the part that costs something: up to 70 live creatures against
    vanilla's 40, 24 of them engaged at once, spawning brood every 5 seconds.
    If your frame rate drops, that is where it is going - the Easy file costs
    almost nothing by comparison.
"@
        creditos = ""
    }
    @{
        grupo   = "infestation"
        carpeta = "HorribleTerror_Infestation_1-Facil"
        release = "infestedEasy"
        titulo  = "Infested - Easy"
        mezcla  = $MEZCLA_INFESTATION
        que     = @"
The same world, without the teeth.

Twice the horror eggs, twice the sand worm nests and twice the ground fauna,
so there is actually something out there to run into. Predators arrive in twos
instead of alone and notice you at 45 m instead of 40, and the game keeps 45
creatures alive at once instead of 40.

That is the whole list. It does NOT touch how the horrors behave: no brood
spawned mid-fight, no extra reach on the pounce, no faster attacks, no waking
nests inside freighters, and the warning markers on your HUD stay exactly
where vanilla puts them.

*** And the important one: it does NOT change which planets are hostile. ***

That is deliberate, and it is the lesson from the first release of the
predator mod. Planet hostility is not "how many dangerous creatures spawn" -
it decides whether the WHOLE planet is a predator world, with every ground
species drawn from the tables that hunt you. Pushing that number meant people
loaded a save and found the planet they were standing on had turned against
them. Easy leaves it at the vanilla roll. The world you are already in stays
the world you left.

Take this one if you want more to run into, not more to run from.

This mod CONTAINS the "More Aggressive Predators" mod. Do not install both.
"@
        fallos  = @"
  - This is the light end on purpose. If you want horrors that hunt you, spawn
    brood mid-fight and wake up when you shine a torch at their nest, that is
    the other file, not this one.
  - Straight answer: this exact build has NOT been played in a real save. It
    was built from the same script as the full version, and what it does and
    does not touch has been verified file by file - but nobody has spent an
    evening inside it. The full version is the one that gets played. If
    something here is off, you will be the first to see it, so please say so.
  - More aggression levels are coming between this file and the full one, and
    what gets reported here is what decides where they land.
"@
        creditos = ""
    }
    @{
        grupo   = "infestation"
        carpeta = "HorribleTerror_Infestation_2-Normal"
        release = "infestedNormal"
        titulo  = "Infested - Normal"
        mezcla  = $MEZCLA_INFESTATION
        que     = @"
The step above Easy: the world starts biting, but it still lets go.

Five times the horror eggs and the sand worm nests. Predators arrive in twos,
notice you at 50 m, keep coming until they are down to a quarter health, and
60% of them hunt you instead of the local fauna. The horrors see you at 65 m,
hatch out of an egg almost together instead of trickling, pounce twice as far
and from half a metre up, and spit every 0.9 seconds.

Eight of them can be on you at once, and all eight actually swing - on the old
build only three did and the rest circled. They remember being shot for 20
seconds and follow you to 180 m before they give up, and if you break line of
sight they come back to you after 15 seconds instead of 30.

What it does NOT do: no brood spawned mid-fight, no constant spitting, the HUD
markers stay where vanilla puts them, and the nests inside abandoned freighters
stay asleep. Those are the full version.

This mod CONTAINS the "More Aggressive Predators" mod. Do not install both.
"@
        fallos  = @"
  - Straight answer: this exact build has NOT been played in a real save. It is
    built from the same script as the full version, with every number scaled
    down and checked to sit between Easy and the full one, but nobody has spent
    an evening inside it. Report anything that feels wrong and it gets fixed.
  - Where it lands between Easy and the full version is a first guess. If it
    feels closer to one end than it should, say which end.
  - FPS: 50 live creatures against vanilla's 40, eight engaged at once. It
    costs more than Easy and much less than the full version.
"@
        creditos = ""
    }
    @{
        grupo   = "infestation"
        carpeta = "HorribleTerror_Infestation_3-Dificil"
        release = "infestedHard"
        titulo  = "Infested - Hard"
        mezcla  = $MEZCLA_INFESTATION
        que     = @"
The full world, one step short of the full teeth.

Twenty times the horror eggs and the sand worm nests, same as the full version.
Almost every planet rolls hostile, predators come in packs of 3-5, never run,
and spot you at 60 m. The horrors see you at 70 m, carry no HUD marker, hatch
out of an egg in one wave, hit 3-5 times per flurry, spit without waiting for
an opening, pounce 2.4 times further and clear 0.7 m of height - a rock is no
longer cover.

Twelve can be engaged with you and all twelve swing. They remember being shot
for 35 seconds, follow you to 220 m, lose interest at 120 m instead of 80, and
come back to you after 8 seconds instead of 30. The wave no longer switches
itself off halfway through the fight.

What the full version still has over this one: the horrors multiply while they
fight you, their brood hits as hard as the parent, the predator markers come
off your HUD, and the nests inside abandoned freighters wake up to your torch.

This mod CONTAINS the "More Aggressive Predators" mod. Do not install both.
"@
        fallos  = @"
  - Straight answer: this exact build has NOT been played in a real save.
    Every number in it was checked to sit between Normal and the full version,
    but nobody has played an evening of it. If something is off you will be the
    first to see it.
  - Almost every planet rolls hostile here, same as the full version. That
    changes the planet you are already standing on when you load a save. If you
    do not want that, take Normal.
  - FPS: 60 live creatures against vanilla's 40 and twelve engaged at once.
    Between Normal and the full version, and closer to the full version.
"@
        creditos = ""
    }
)

# basura de AMUMSS + todo lo replicable
$BASURA = @("*.lua", "AMUMSS_v*.txt", "*.log", "*.EXML", "*.MXML", "REPORT*.txt", "_REPORT_*", "*.bak", "Thumbs.db", "desktop.ini")

$readmeTpl = @'
===============================================================================
  SOMETHING LIVES HERE - {TITULO}
  Version {VERSION}   *** BETA ***
===============================================================================

WHAT THIS IS
------------
{QUE}

This is a BETA. KNOWN ISSUES below is written honestly, and it includes what
has NOT been tested yet.

INSTALL
-------
1. Extract the folder "{MOD}" into:

      No Man's Sky\GAMEDATA\MODS\

   The folders that were inside the zip should end up under:

      GAMEDATA\MODS\{MOD}\

2. Restart the game. Mods only load at startup - alt-tabbing out and back in
   will not apply them.

To uninstall, delete that folder and restart.

INSTALLING MORE THAN ONE
------------------------
{MEZCLA}

KNOWN ISSUES
------------
{FALLOS}

This is a beta and the point of it is to find the rest. If you see something
wrong, post it in the Posts tab: what you saw and where you were. Screenshots
help more than anything else.

Tested on No Man's Sky {NMS}.

CREDITS
-------
  Mod by AldrichDDD.
{CREDITOS}
  AMUMSS         - HolterPhylo
  MBINCompiler   - monkeyman192
  NMSDK          - monkeyman192
  Blender        - Blender Foundation

No Man's Sky (c) Hello Games. This mod is not affiliated with or endorsed by
Hello Games, and redistributes none of their assets.
'@

if (-not $Origen) { $Origen = Join-Path $PSScriptRoot "AMUMSS\ModBackups" }
$destino = Join-Path $PSScriptRoot "..\releases\$Grupo-$Version"

if (-not (Test-Path $Origen)) { Write-Error "No existe $Origen"; exit 1 }
New-Item -ItemType Directory -Force -Path $destino | Out-Null

$hechos = 0
foreach ($mod in $MODS) {

    if ($mod.grupo -ne $Grupo) { continue }
    if ($Solo.Count -gt 0 -and $Solo -notcontains $mod.release) { continue }

    $src = Join-Path $Origen $mod.carpeta
    if (-not (Test-Path $src)) {
        Write-Warning "No existe $src - se salta $($mod.release)"
        continue
    }

    $stage = Join-Path $env:TEMP "htpack_$($mod.release)"
    if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $stage | Out-Null

    $copiado = Join-Path $stage $mod.release
    Copy-Item $src -Destination $copiado -Recurse

    foreach ($patron in $BASURA) {
        Get-ChildItem $copiado -Filter $patron -Recurse -Force -File | Remove-Item -Force
    }

    # Trampa 1: ModBackups deja los globals en la RAIZ, y el juego los quiere en
    # GLOBALS\. Ningun archivo de mod de NMS vive legitimamente en la raiz de la
    # carpeta, asi que todo .MBIN suelto ahi es un global aplanado.
    $sueltos = @(Get-ChildItem $copiado -File -Filter *.MBIN)
    if ($sueltos.Count -gt 0) {
        $globals = Join-Path $copiado "GLOBALS"
        New-Item -ItemType Directory -Force -Path $globals | Out-Null
        foreach ($g in $sueltos) {
            Move-Item $g.FullName (Join-Path $globals $g.Name)
            Write-Output ("  GLOBALS\ <- " + $g.Name)
        }
    }

    # Red de seguridad. Si dentro de la carpeta instalable queda algo que no sea
    # un binario del juego, no se empaqueta: es justo asi como se cuela un .lua,
    # un log con rutas locales o un informe con el nombre de la maquina.
    $sobra = Get-ChildItem $copiado -Recurse -File |
             Where-Object { $_.Extension -notin @(".MBIN", ".PC", ".DDS") }
    if ($sobra) {
        $sobra | ForEach-Object { Write-Output ("  sobra: " + $_.FullName) }
        Write-Error "Hay archivos que no son binarios del juego en $($mod.release). No se empaqueta."
        exit 1
    }

    $bloqueCreditos = ""
    if ($mod.creditos.Trim().Length -gt 0) {
        $bloqueCreditos = "`r`n" + $mod.creditos.TrimEnd() + "`r`n"
    }

    $readme = $readmeTpl.Replace('{TITULO}', $mod.titulo).Replace('{VERSION}', $Version)
    $readme = $readme.Replace('{MOD}', $mod.release).Replace('{QUE}', $mod.que.Trim())
    $readme = $readme.Replace('{MEZCLA}', $mod.mezcla.Trim())
    $readme = $readme.Replace('{FALLOS}', $mod.fallos.TrimEnd()).Replace('{CREDITOS}', $bloqueCreditos)
    $readme = $readme.Replace('{NMS}', $VersionNMS)
    # ascii a proposito: -Encoding utf8 de PS 5.1 mete BOM y en un README.txt se
    # ve como basura en algunos editores
    Set-Content -Path (Join-Path $stage "README.txt") -Value $readme -Encoding ascii

    $zip = Join-Path $destino "$($mod.release)_v$Version.zip"
    if (Test-Path $zip) { Remove-Item $zip -Force }
    # Ni Compress-Archive ni ZipFile::CreateFromDirectory sirven aqui: los dos
    # escriben el nombre de entrada con "\", y fuera de Windows eso no separa
    # carpetas. El zip se extrae como archivos planos con las barras dentro del
    # nombre. La spec (APPNOTE 4.4.17.1) manda "/", asi que se nombra a mano.
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $raiz = (Resolve-Path $stage).Path.TrimEnd('\') + '\'
    $zf = [System.IO.Compression.ZipFile]::Open($zip, 'Create')
    try {
        foreach ($f in Get-ChildItem $stage -Recurse -File) {
            $rel = $f.FullName.Substring($raiz.Length).Replace('\', '/')
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
                $zf, $f.FullName, $rel, 'Optimal') | Out-Null
        }
    } finally { $zf.Dispose() }

    $mb = [math]::Round((Get-Item $zip).Length / 1MB, 2)
    $n  = (Get-ChildItem $copiado -Recurse -File).Count
    Write-Output ("{0,-36} -> {1,-44} {2,7} MB  ({3} archivos)" -f $mod.carpeta, (Split-Path $zip -Leaf), $mb, $n)

    Remove-Item $stage -Recurse -Force
    $hechos++
}

if ($hechos -eq 0) { Write-Error "No se empaqueto nada. Revisa -Grupo y -Solo."; exit 1 }

Write-Output ""
Write-Output "$hechos paquetes en: releases\$Grupo-$Version\"
