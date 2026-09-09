<#
.SYNOPSIS
    Construye todas las configuraciones de un mod en una pasada y reporta el conteo
    de cambios de cada una.

.DESCRIPTION
    Corre BUILDMOD.bat una vez por cada .lua de work\scripts\<Carpeta>\, dejando
    solo uno en ModScript\ cada vez, y archiva la salida de cada build.

    POR QUE UNO A LA VEZ: las configuraciones de un mod tocan los mismos archivos.
    Construirlas por separado es la forma verificada de que cada una salga contra
    fuentes vanilla limpias.

    POR QUE ARCHIVA: AMUMSS vacia CreatedMODS al empezar cada build, asi que cuatro
    builds seguidas dejan solo la ultima. Package-Release.ps1 lee de CreatedMODS, de
    modo que sin archivar no se puede empaquetar mas de una configuracion.

    EL CONTEO ES LA VERIFICACION. "0 [ERROR] detected" no prueba que el mod haga lo
    correcto: un script con la logica mal reporta 0 errores igual. Lo que delata un
    fallo es que el numero de cambios no sea el esperado, y hay que comprobarlo en
    TODAS las configuraciones: el bug de cascada del mod 2 solo aparecia en Normal,
    las otras tres daban el numero correcto con el mismo script defectuoso.

    Tres requisitos del entorno, todos aprendidos a la mala (ver proyecto §10c):

      1. chcp 850 antes de llamar a BUILDMOD.bat. Con la pagina de codigos en 65001
         AMUMSS aborta con "Bad Active Code Page Detected".
      2. NoDefaultCurrentDirectoryInExePath NO puede estar en el entorno. Si esta,
         cmd.exe no resuelve ejecutables por nombre desnudo desde el directorio
         actual, que es como AMUMSS invoca todo. La build muere con
         "[BUG] attempt to compare nil with number", que no apunta a la causa.
      3. Ningun proceso puede tener el directorio actual dentro de CreatedMODS, o
         AMUMSS aborta con "Problem Cleaning folder 'CreatedMods'".

.PARAMETER Carpeta
    Subcarpeta de work\scripts\ con los .lua a construir. Ej: "infestacion".

.PARAMETER Destino
    Donde archivar las salidas. Por defecto build\<Carpeta>_<fecha>\.

.EXAMPLE
    .\Build-Tiers.ps1 -Carpeta infestacion
#>
param(
    [Parameter(Mandatory=$true)][string]$Carpeta,
    [string]$Destino = ""
)

$ErrorActionPreference = "Stop"

$repo = Resolve-Path (Join-Path $PSScriptRoot "..")
$amu  = Join-Path $PSScriptRoot "AMUMSS"
$src  = Join-Path $repo "work\scripts\$Carpeta"
$ms   = Join-Path $amu "ModScript"

if (-not (Test-Path $src)) {
    Write-Error "No existe $src"
    exit 1
}

$scripts = Get-ChildItem $src -Filter *.lua | Sort-Object Name
if ($scripts.Count -eq 0) {
    Write-Error "No hay .lua en $src"
    exit 1
}

if ($Destino -eq "") {
    $Destino = Join-Path $repo ("build\{0}_{1}" -f $Carpeta, (Get-Date -Format "yyyy-MM-dd"))
}
New-Item -ItemType Directory -Force -Path $Destino | Out-Null

# Requisito 2: la variable rompe la resolucion de ejecutables de AMUMSS.
Remove-Item env:NoDefaultCurrentDirectoryInExePath -ErrorAction SilentlyContinue

# Requisito 3: si este proceso esta dentro de CreatedMODS, AMUMSS no puede limpiarla.
Set-Location $repo

$opts = "-DEV_MODE F -GameVersion P -CombineModPak N -CopyToGamefolder NONE " +
        "-UseExtraFilesInPAK N -UseLuaScriptInPak N -SOUND N -UseColors N " +
        "-AutoUpdateMBinCompiler N"

$nombres = $scripts | ForEach-Object { $_.BaseName }
Write-Host ""
Write-Host "Construyendo $($scripts.Count) configuraciones de '$Carpeta'"
Write-Host "Archivando en: $Destino"
Write-Host ""

$resultados = @()

foreach ($s in $scripts) {
    # Solo el .lua del turno en ModScript: los demas colisionarian. Se borran TODOS,
    # no solo los de esta carpeta: un .lua olvidado de otra sesion se construye tambien
    # y contamina el conteo agregado (paso con el mod 3, ver CHANGELOG-MOD3.md).
    Get-ChildItem $ms -Filter *.lua | Remove-Item -Force
    Copy-Item $s.FullName $ms -Force

    $log = Join-Path $Destino ("_build_{0}.log" -f $s.BaseName)
    # Requisito 1: chcp 850.
    cmd /c "chcp 850 >nul & call ""$amu\BUILDMOD.bat"" $opts" | Out-File -FilePath $log -Encoding utf8

    $salida = Join-Path $amu "CreatedMODS\$($s.BaseName)"
    if (Test-Path $salida) {
        $archivo = Join-Path $Destino $s.BaseName
        if (Test-Path $archivo) { Remove-Item $archivo -Recurse -Force }
        Copy-Item $salida $Destino -Recurse -Force
    }

    $reporte = Join-Path $amu "REPORT.lua"
    $porArchivo = @()
    if (Test-Path $reporte) {
        Copy-Item $reporte (Join-Path $Destino ("_REPORT_{0}.lua" -f $s.BaseName)) -Force
        $m = (Select-String -Path $reporte -Pattern "\[(\d+) CHANGE\(s\) made\]" -AllMatches).Matches
        if ($m) { $porArchivo = $m | ForEach-Object { [int]$_.Groups[1].Value } }
    }

    $errores = 0
    if (Test-Path $log) {
        $e = Select-String -Path $log -Pattern "(\d+) \[ERROR\] detected"
        if ($e) { $errores = [int]$e.Matches[0].Groups[1].Value }
    }

    $resultados += [pscustomobject]@{
        Config     = $s.BaseName
        PorArchivo = ($porArchivo -join " + ")
        Total      = ($porArchivo | Measure-Object -Sum).Sum
        Errores    = $errores
        Construido = (Test-Path $salida)
    }
}

Write-Host ""
$resultados | Format-Table -AutoSize
Write-Host "Compara los totales contra la tabla del README de la carpeta del mod."
Write-Host "Si alguno no cuadra, NO se despliega: lee el EXML delta primero."
Write-Host ""
