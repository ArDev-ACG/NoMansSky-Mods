<#
.SYNOPSIS
    Empaqueta los mods construidos en zips listos para subir a Nexus.

.DESCRIPTION
    Genera un .zip por configuracion en releases\<version>\. Cada zip lleva:

        <nombreDelMod>\        <- la carpeta que se copia a GAMEDATA\MODS\
        <nombreDelMod>.pak     <- el .pak de AMUMSS (opcional, ver nota)
        Source\<nombreDelMod>.lua  <- SOLO el fuente de esta configuracion
        README.txt             <- instrucciones de instalacion

    NOMBRES. Las carpetas de AMUMSS vienen del MOD_FILENAME del .lua, que esta en
    espanol y con ordinal de tier (HorribleTerror_Predators_1-Facil). En el release
    se traducen a camelCase e ingles (horribleTerrorPredatorsEasy). La traduccion
    ocurre SOLO al empaquetar: los .lua de work\scripts y su MOD_FILENAME no se
    tocan, asi que renombrar un release nunca obliga a redesplegar lo que ya esta
    en GAMEDATA\MODS. Ver Convert-ToReleaseName y -Nombres.

    UN SOLO .lua POR ZIP. Cada configuracion lleva su fuente y nada mas. Meter los
    cuatro tiers en cada zip (como hacia 1.1.0) invita a que el jugador construya
    el que no instalo.

    SIN COMENTARIOS. Antes de empaquetar nada se revisan los .lua que irian a
    Source\ y se aborta si alguno trae comentarios. La explicacion de un mod vive
    en docs\, no en el fuente que se publica. Para saltarse la revision:
    -PermitirComentarios.

    FORMATO DE INSTALACION. NMS 6.x carga mods como CARPETAS descomprimidas dentro
    de GAMEDATA\MODS\. Verificado en la instalacion local: los 87 mods instalados
    son carpetas y no hay ni un solo .pak.

    NOTA SOBRE EL .pak. Los .pak que genera AMUMSS son PSARC: sus magic bytes son
    50 53 41 52 ("PSAR"), mientras que los paks vanilla de NMS 6.45 son 48 47 50 41
    ("HGPA"). Son formatos distintos. Se incluyen porque se pidieron expresamente,
    pero la carpeta es lo que instala el jugador y el README lo deja claro. Para
    omitirlos: -SinPak.

.PARAMETER Version
    Version del release, ej. "1.2.0". Crea releases\<Version>\.

.PARAMETER Origen
    Carpeta que contiene las carpetas de mod. Por defecto tools\AMUMSS\CreatedMODS.
    AMUMSS vacia CreatedMODS en cada build, asi que para empaquetar varios tiers
    conviene apuntar a un archivado de build\ (ver Build-Tiers.ps1).

.PARAMETER Fuentes
    Carpeta con los .lua. De ahi sale el fuente de cada mod, emparejado por nombre
    de carpeta. Ej. work\scripts\dificultad.

.PARAMETER Paks
    Carpeta donde buscar <NombreDelMod>.pak.
    Por defecto tools\AMUMSS\ModBackups\________________BuildHistory.

.PARAMETER Nombres
    Hashtable para forzar el nombre de release de un mod concreto, cuando la
    traduccion automatica no acierta. Clave = nombre de la carpeta de AMUMSS.

        -Nombres @{ "MOD3_MapaGalactico_PRUEBA01" = "horribleTerrorGalacticMap" }

.PARAMETER SinPak
    No incluye el .pak en el zip.

.PARAMETER PermitirComentarios
    Empaqueta aunque los .lua traigan comentarios.

.PARAMETER TituloMod
    Nombre legible del mod para el README. Ej. "Horrible Terror - Aggressive Predators".

.PARAMETER Incompatibilidad
    Frase del README que dice con que choca el mod. Cambiala por mod.

.PARAMETER VersionNMS
    Build de NMS contra la que se probo, para el README.

.EXAMPLE
    .\Package-Release.ps1 -Version 1.2.0 -Fuentes ..\work\scripts\dificultad `
        -TituloMod "Horrible Terror - Aggressive Predators"
#>
param(
    [Parameter(Mandatory=$true)][string]$Version,
    [string]$Origen,
    [string]$Fuentes,
    [string]$Paks,
    [hashtable]$Nombres = @{},
    [switch]$SinPak,
    [switch]$PermitirComentarios,
    [string]$TituloMod = "Horrible Terror",
    [string]$Incompatibilidad = "Incompatible with anything else that edits creature spawn density, archetype`nweights or predator globals.",
    [string]$VersionNMS = "170671 (Public branch)"
)

$ErrorActionPreference = "Stop"

# --- traduccion de nombres -----------------------------------------------------
# token en espanol (sin acentos, minusculas) -> token en ingles. Un mod nuevo que
# traiga una palabra sin entrada aqui pasa tal cual: si sale mal, usa -Nombres.
$DICCIONARIO = @{
    "facil"         = "Easy"
    "normal"        = "Normal"
    "dificil"       = "Hard"
    "hardcore"      = "Hardcore"
    "ht"            = "HorribleTerror"
    "depredadores"  = "Predators"
    "infestacion"   = "Infestation"
    "mapagalactico" = "GalacticMap"
    "mapa"          = "Map"
    "dificultad"    = "Difficulty"
    "piel"          = "Skin"
    "horda"         = "Horde"
    "hordas"        = "Hordes"
    "huevo"         = "Egg"
    "huevos"        = "Eggs"
    "prueba"        = "Test"
    "pruebas"       = "Tests"
    "mod"           = "Mod"
}

function Remove-Acentos {
    param([string]$Texto)
    $d = $Texto.Normalize([System.Text.NormalizationForm]::FormD)
    $sb = New-Object System.Text.StringBuilder
    foreach ($c in $d.ToCharArray()) {
        $cat = [System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($c)
        if ($cat -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$sb.Append($c)
        }
    }
    $sb.ToString()
}

function Convert-ToReleaseName {
    <#
        HorribleTerror_Predators_1-Facil  ->  horribleTerrorPredatorsEasy
        HorribleTerror_DerelictBugs       ->  horribleTerrorDerelictBugs
        MOD3_MapaGalactico_PRUEBA01       ->  mod3GalacticMapTest01

        Corta por _ y -, tira el ordinal del tier, traduce lo que este en el
        diccionario, respeta el CamelCase que ya venga bien, y pega todo junto
        con la primera letra en minuscula.
    #>
    param([string]$Nombre)

    $partes = @()
    foreach ($token in ($Nombre -split '[_\-]')) {
        if ([string]::IsNullOrWhiteSpace($token)) { continue }
        if ($token -match '^\d+$') { continue }   # el "1" de "1-Facil"

        $palabra = $token
        $sufijo  = ""
        if ($token -match '^(.*?)(\d+)$') {
            $palabra = $Matches[1]
            $sufijo  = $Matches[2]
        }

        $clave = (Remove-Acentos $palabra).ToLowerInvariant()
        if ($DICCIONARIO.ContainsKey($clave)) {
            $palabra = $DICCIONARIO[$clave]
        } elseif ($palabra -cmatch '^[A-Z0-9]+$') {
            # ALLCAPS sin entrada en el diccionario: PRUEBA -> Prueba
            $palabra = $palabra.Substring(0,1).ToUpperInvariant() + $palabra.Substring(1).ToLowerInvariant()
        } else {
            # ya viene en CamelCase (DerelictBugs, NecroSkin): se respeta
            $palabra = $palabra.Substring(0,1).ToUpperInvariant() + $palabra.Substring(1)
        }

        $partes += ($palabra + $sufijo)
    }

    $unido = -join $partes
    if ($unido.Length -eq 0) { return $Nombre }
    $unido.Substring(0,1).ToLowerInvariant() + $unido.Substring(1)
}

function Get-ComentariosLua {
    # Vacia las cadenas antes de buscar "--", para no marcar un guion doble que
    # viva dentro de un valor de AMUMSS.
    param([string]$Ruta)
    $hallazgos = @()
    $n = 0
    foreach ($linea in (Get-Content $Ruta)) {
        $n++
        $limpia = $linea -replace '"[^"]*"', '""'
        $limpia = $limpia -replace "'[^']*'", "''"
        if ($limpia -match '--') {
            $hallazgos += ("  {0}:{1}  {2}" -f (Split-Path $Ruta -Leaf), $n, $linea.Trim())
        }
    }
    ,$hallazgos
}
# ------------------------------------------------------------------------------

if (-not $Origen) { $Origen = Join-Path $PSScriptRoot "AMUMSS\CreatedMODS" }
if (-not $Paks)   { $Paks   = Join-Path $PSScriptRoot "AMUMSS\ModBackups\________________BuildHistory" }
$destino = Join-Path $PSScriptRoot "..\releases\$Version"

if (-not (Test-Path $Origen)) {
    Write-Error "No existe $Origen. Corre BUILDMOD.bat o Build-Tiers.ps1 primero."
    exit 1
}

$mods = Get-ChildItem $Origen -Directory
if ($mods.Count -eq 0) {
    Write-Error "No hay carpetas de mod en $Origen."
    exit 1
}

$rutaFuentes = $null
if ($Fuentes) {
    $rutaFuentes = $Fuentes
    if (-not [System.IO.Path]::IsPathRooted($rutaFuentes)) {
        $rutaFuentes = Join-Path $PSScriptRoot $Fuentes
    }
    if (-not (Test-Path $rutaFuentes)) {
        Write-Warning "No existe $rutaFuentes - los zips van sin Source\"
        $rutaFuentes = $null
    }
}

# --- revision de comentarios, antes de empaquetar nada -------------------------
if ($rutaFuentes -and -not $PermitirComentarios) {
    $sucios = @()
    foreach ($mod in $mods) {
        $lua = Join-Path $rutaFuentes "$($mod.Name).lua"
        if (Test-Path $lua) { $sucios += (Get-ComentariosLua $lua) }
    }
    if ($sucios.Count -gt 0) {
        Write-Output "Comentarios en los .lua que irian a Source\:"
        $sucios | ForEach-Object { Write-Output $_ }
        Write-Output ""
        Write-Error "Los .lua se publican sin comentarios. Mueve la explicacion a docs\ o usa -PermitirComentarios."
        exit 1
    }
}

New-Item -ItemType Directory -Force -Path $destino | Out-Null

# --- plantilla del README ------------------------------------------------------
$readmeTpl = @'
===============================================================================
  {TITULO}
  Version {VERSION} - configuration installed: {TIER}
===============================================================================

INSTALL
-------
1. Extract the folder "{MOD}" into:

      No Man's Sky\GAMEDATA\MODS\

   You should end up with:

      GAMEDATA\MODS\{MOD}\GLOBALS\...
      GAMEDATA\MODS\{MOD}\METADATA\...

2. Restart the game. Mods are only loaded at startup - alt-tabbing out and
   back in will not apply them.

INSTALL ONE CONFIGURATION ONLY
------------------------------
All configurations edit the same game files. Installing two means one silently
overrides the other, and you will not get an error telling you so.

To switch: DELETE the old folder first, then extract the new one.

WHAT IS IN THIS ZIP
-------------------
  {MOD}\
      The mod. This is the part you install.
{PAKBLOCK}
  Source\
      The .lua build script for THIS configuration, for modders and for anyone
      who wants to check exactly what is changed. The other configurations ship
      their own script in their own zip.

  README.txt
      This file.

VORTEX
------
Install one file through Vortex as usual. If you already have another tier
installed, remove it in Vortex first, otherwise Vortex will report a file
conflict.

COMPATIBILITY
-------------
Shipped as partial EXML patches: each file only declares the specific properties
it changes, not the whole file. Any mod touching a different part of those files
should coexist.

{INCOMPAT}

Tested against No Man's Sky {NMS}.

BUILDING IT YOURSELF
--------------------
Drop the .lua from Source\ into AMUMSS's ModScript\ folder and run BUILDMOD.bat
in FULL mode. The folder it produces is named after MOD_FILENAME inside the
script, which is not always the folder name shipped here - rename it if you
care.

CREDITS
-------
  AMUMSS         - HolterPhylo
  MBINCompiler   - monkeyman192

No assets from Hello Games are redistributed. These are partial EXML patches
containing only modified values.
'@
# ------------------------------------------------------------------------------

# basura que AMUMSS deja dentro de la carpeta del mod y no debe viajar al jugador
$BASURA = @("*.lua", "AMUMSS_v*.txt", "*.log", "REPORT*.txt", "_REPORT_*", "*.bak", "Thumbs.db", "desktop.ini")

foreach ($mod in $mods) {

    if ($Nombres.ContainsKey($mod.Name)) {
        $release = $Nombres[$mod.Name]
    } else {
        $release = Convert-ToReleaseName $mod.Name
    }

    $stage = Join-Path $env:TEMP "htpack_$release"
    if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $stage | Out-Null

    # 1) la carpeta del mod, ya con el nombre de release
    $copiado = Join-Path $stage $release
    Copy-Item $mod.FullName -Destination $copiado -Recurse

    foreach ($patron in $BASURA) {
        Get-ChildItem $copiado -Filter $patron -Recurse -Force -File | Remove-Item -Force
    }

    # 2) el .pak, renombrado igual que la carpeta
    $pakMsg = "sin pak"
    $bloquePak = ""
    if (-not $SinPak) {
        $pak = Join-Path $Paks "$($mod.Name).pak"
        if (Test-Path $pak) {
            Copy-Item $pak -Destination (Join-Path $stage "$release.pak")
            $pakMsg = "pak"
            $bloquePak = @"

  $release.pak
      Legacy single-file build produced by AMUMSS. NMS 6.x loads the unpacked
      folder above, so you do NOT need this file. It is included for reference
      and for older setups only.

"@
        } else {
            Write-Warning "No se encontro $pak - el zip de $release va sin .pak"
        }
    }

    # 3) Source\ con SOLO el .lua de esta configuracion
    $nLua = 0
    if ($rutaFuentes) {
        $lua = Join-Path $rutaFuentes "$($mod.Name).lua"
        if (Test-Path $lua) {
            $src = Join-Path $stage "Source"
            New-Item -ItemType Directory -Force -Path $src | Out-Null
            Copy-Item $lua -Destination (Join-Path $src "$release.lua")
            $nLua = 1
        } else {
            Write-Warning "No existe $lua - el zip de $release va sin Source\"
        }
    }

    # 4) README.txt
    # El tier sale del nombre de release si viene en ingles, y del nombre de la
    # carpeta de AMUMSS si el release conserva el nombre espanol (-Nombres).
    $tier = "single"
    if ($release -cmatch '(Easy|Normal|Hardcore|Hard)$') {
        $tier = $Matches[1]
    } elseif ((Remove-Acentos $mod.Name) -cmatch '(?i)(Facil|Normal|Hardcore|Dificil)$') {
        $tier = @{
            "facil" = "Easy"; "normal" = "Normal"; "dificil" = "Hard"; "hardcore" = "Hardcore"
        }[$Matches[1].ToLowerInvariant()]
    }
    $readme = $readmeTpl.Replace('{TITULO}', $TituloMod).Replace('{VERSION}', $Version)
    $readme = $readme.Replace('{TIER}', $tier).Replace('{MOD}', $release)
    $readme = $readme.Replace('{PAKBLOCK}', $bloquePak)
    $readme = $readme.Replace('{INCOMPAT}', $Incompatibilidad).Replace('{NMS}', $VersionNMS)
    $readmePath = Join-Path $stage "README.txt"
    # ascii a proposito: el texto es ASCII puro y -Encoding utf8 de PS 5.1 mete BOM,
    # que en un README.txt se ve como basura en algunos editores
    Set-Content -Path $readmePath -Value $readme -Encoding ascii

    # 5) comprimir el CONTENIDO del stage, no el stage
    $zip = Join-Path $destino "${release}_v$Version.zip"
    if (Test-Path $zip) { Remove-Item $zip -Force }
    Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zip -CompressionLevel Optimal

    $kb = [math]::Round((Get-Item $zip).Length / 1KB, 1)
    $n  = (Get-ChildItem $copiado -Recurse -File).Count
    Write-Output ("{0,-30} -> {1,-46} {2,7} KB  ({3} EXML, {4} lua, {5})" -f $mod.Name, (Split-Path $zip -Leaf), $kb, $n, $nLua, $pakMsg)

    Remove-Item $stage -Recurse -Force
}

Write-Output ""
Write-Output "Paquetes en: releases\$Version\"
