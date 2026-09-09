<#
.SYNOPSIS
    Respalda las partidas de No Man's Sky antes de probar un mod.

.DESCRIPTION
    Copia %APPDATA%\HelloGames\NMS a backups\NMS_saves_<fecha>_<hora>\.
    Cada backup es una carpeta con marca de tiempo: nunca sobreescribe uno anterior.

    Los mods de fauna no deberian corromper un save, pero un save de NMS guarda
    estado del universo generado. Si algo sale mal se pierde progreso real, y
    restaurar cuesta segundos frente a rehacer horas de juego.

.PARAMETER Etiqueta
    Texto corto que se añade al nombre de la carpeta para saber a que prueba
    corresponde. Ej: -Etiqueta "antes-densidad-x3"

.PARAMETER Conservar
    Cuantos backups mantener. Los mas viejos se borran. Por defecto 15.
    Poner 0 para no borrar ninguno.

.EXAMPLE
    .\Backup-NMSSave.ps1 -Etiqueta "antes-densidad-x3"
#>
param(
    [string]$Etiqueta = "",
    [int]$Conservar = 15
)

$ErrorActionPreference = "Stop"

$origen  = Join-Path $env:APPDATA "HelloGames\NMS"
$destRaiz = Join-Path $PSScriptRoot "..\backups"

if (-not (Test-Path $origen)) {
    Write-Error "No se encontraron partidas en: $origen"
    exit 1
}

# Aviso si el juego esta abierto: puede estar escribiendo el save justo ahora
$nms = Get-Process -Name "NMS" -ErrorAction SilentlyContinue
if ($nms) {
    Write-Warning "No Man's Sky esta ABIERTO. El save puede estar a medio escribir."
    Write-Warning "Recomendado: salir al menu principal o cerrar el juego antes de respaldar."
}

$stamp = Get-Date -Format "yyyy-MM-dd_HHmm"
$nombre = if ($Etiqueta) { "NMS_saves_${stamp}_$Etiqueta" } else { "NMS_saves_$stamp" }
$destino = Join-Path $destRaiz $nombre

New-Item -ItemType Directory -Force -Path $destino | Out-Null
Copy-Item -Path "$origen\*" -Destination $destino -Recurse -Force

$archivos = (Get-ChildItem $destino -Recurse -File).Count
$peso = (Get-ChildItem $destino -Recurse -File | Measure-Object -Property Length -Sum).Sum

Write-Output "Backup creado: $nombre"
Write-Output ("  {0} archivos, {1:N1} MB" -f $archivos, ($peso/1MB))

# Rotacion: conservar solo los N mas recientes
if ($Conservar -gt 0) {
    $viejos = Get-ChildItem $destRaiz -Directory |
              Where-Object { $_.Name -like "NMS_saves_*" } |
              Sort-Object Name -Descending |
              Select-Object -Skip $Conservar
    foreach ($v in $viejos) {
        Remove-Item $v.FullName -Recurse -Force
        Write-Output "  Rotado (borrado): $($v.Name)"
    }
}

$total = (Get-ChildItem $destRaiz -Directory | Where-Object { $_.Name -like "NMS_saves_*" }).Count
Write-Output "Backups guardados: $total"
