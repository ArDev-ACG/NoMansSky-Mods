<#
.SYNOPSIS
    Deja GAMEDATA\MODS con un solo .pak para probar el mod aislado, y lo revierte.

.DESCRIPTION
    Los 87 mods del setup los despliega Vortex por hardlink dentro de
    GAMEDATA\MODS, junto con su manifiesto vortex.deployment.json. Borrar o
    mover archivos sueltos de ahi descuadra a Vortex.

    En vez de eso se renombra la carpeta entera a _MODS_VORTEX_OFF y se crea
    una MODS nueva con el pak a probar. El rename no rompe los hardlinks y el
    manifiesto viaja dentro, asi que Vortex sigue coherente al restaurar.

    IMPORTANTE: no abrir Vortex mientras esta aislado. Si Vortex despliega o
    purga sin ver su carpeta, va a rehacer el deploy y hay que restaurar a mano.

.PARAMETER Mod
    Que instalar: el zip de release, o la carpeta del mod ya extraida.
    NO un .pak: NMS 6.x carga carpetas con EXML, y los .pak que genera AMUMSS
    son PSAR del flujo pre-6.x. El juego los ignora en silencio.

.PARAMETER Restaurar
    Deshace el aislamiento: borra la MODS de prueba y devuelve la de Vortex.

.EXAMPLE
    .\Aislar-Mods.ps1 -Mod "..\releases\1.0.0\HorribleTerror_Predators_4-Hardcore_v1.0.0.zip"
    .\Aislar-Mods.ps1 -Restaurar
#>
param(
    [string]$Mod = "",
    [switch]$Restaurar,
    [string]$GameData = "C:\Program Files (x86)\Steam\steamapps\common\No Man's Sky\GAMEDATA"
)

$ErrorActionPreference = "Stop"

$mods     = Join-Path $GameData "MODS"
$guardado = Join-Path $GameData "_MODS_VORTEX_OFF"

# El juego mapea los pak al arrancar y los deja abiertos: tocarlos en caliente
# no cambia nada y puede fallar por archivo en uso.
$nms = Get-Process -Name "NMS" -ErrorAction SilentlyContinue
if ($nms) {
    Write-Error "No Man's Sky esta ABIERTO (PID $($nms.Id)). Cerralo antes: los mods solo se leen al arrancar."
    exit 1
}

if ($Restaurar) {
    if (-not (Test-Path $guardado)) {
        Write-Output "No hay aislamiento activo: $guardado no existe. Nada que hacer."
        exit 0
    }
    if (Test-Path $mods) {
        # Chequeo de seguridad: la MODS de prueba no deberia tener el manifiesto
        # de Vortex. Si lo tiene, es la real y borrarla seria destructivo.
        if (Test-Path (Join-Path $mods "vortex.deployment.json")) {
            Write-Error "MODS actual contiene vortex.deployment.json: es el deploy real, no una carpeta de prueba. Abortado."
            exit 1
        }
        Remove-Item $mods -Recurse -Force
    }
    Rename-Item -Path $guardado -NewName "MODS"
    $n = (Get-ChildItem $mods -Directory).Count
    Write-Output "Restaurado. MODS de Vortex de vuelta ($n carpetas de mod)."
    exit 0
}

if (-not $Mod) { Write-Error "Falta -Mod (o usa -Restaurar)."; exit 1 }

$Mod = (Resolve-Path $Mod).Path
if ([IO.Path]::GetExtension($Mod) -eq ".pak") {
    Write-Error "Es un .pak. NMS 6.x no los carga: pasa el zip de release o la carpeta extraida."
    exit 1
}

if (Test-Path $guardado) {
    Write-Error "Ya hay un aislamiento activo ($guardado). Corre -Restaurar primero."
    exit 1
}

Rename-Item -Path $mods -NewName "_MODS_VORTEX_OFF"
New-Item -ItemType Directory -Path $mods | Out-Null

if (Test-Path $Mod -PathType Container) {
    Copy-Item -Path $Mod -Destination $mods -Recurse
} else {
    Expand-Archive -Path $Mod -DestinationPath $mods -Force
}

# El juego lee GAMEDATA\MODS\<mod>\GLOBALS|METADATA. Si los EXML quedan colgando
# en la raiz de MODS, no carga nada y no avisa: falla igual que un pak.
$raiz = Get-ChildItem $mods -Directory
if ($raiz.Count -ne 1 -or (Get-ChildItem $mods -File)) {
    Write-Warning "Layout raro en MODS. Se espera UNA carpeta de mod y nada suelto:"
    Get-ChildItem $mods | ForEach-Object { Write-Warning "  $($_.Name)" }
}

Write-Output "Aislado. MODS contiene solo:"
Get-ChildItem $mods -Recurse -File | ForEach-Object {
    Write-Output ("  {0}" -f $_.FullName.Substring($mods.Length + 1))
}
Write-Output ""
Write-Output "Los 87 mods de Vortex estan en: $guardado"
Write-Output "NO abrir Vortex hasta correr:  .\Aislar-Mods.ps1 -Restaurar"
