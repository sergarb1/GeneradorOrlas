<#
.SYNOPSIS
  Instala dependencias y ejecuta el normalizador de fotos Python.

.DESCRIPTION
  - Verifica que Python 3.8+ está instalado
  - Crea un entorno virtual (venv) en .venv/
  - Instala opencv-python y dependencias
  - Descarga el modelo DNN de detección facial
  - Ejecuta el normalizador con los argumentos indicados

.EXAMPLE
  .\ejecutar-normalizador.ps1
  .\ejecutar-normalizador.ps1 -Input ./alumnos -Size 600 -Detector dnn
  .\ejecutar-normalizador.ps1 -Input ./profesores -Format png -Verbose
  .\ejecutar-normalizador.ps1 -DryRun
  .\ejecutar-normalizador.ps1 -Reinstalar
#>

param(
    [string]$Input = "",
    [string]$Output = "",
    [int]$Size = 0,
    [string]$Format = "",
    [int]$Quality = 0,
    [string]$Detector = "",
    [float]$Margen = -1,
    [int]$Workers = 0,
    [switch]$DryRun,
    [switch]$Verbose,
    [switch]$Reinstalar,
    [switch]$NoVenv
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$VenvDir = Join-Path $ScriptDir ".venv"
$Requirements = Join-Path $ScriptDir "requirements.txt"
$PythonScript = Join-Path $ScriptDir "normalizar-fotos.py"

# ── 1. Comprobar Python ──────────────────────────────
Write-Host "`n🔍 Comprobando Python..." -ForegroundColor Cyan
try {
    $pyVersion = & python --version 2>&1
    if ($LASTEXITCODE -ne 0) { throw "python no disponible" }
    Write-Host "  ✓ $pyVersion" -ForegroundColor Green
} catch {
    try {
        $pyVersion = & python3 --version 2>&1
        if ($LASTEXITCODE -ne 0) { throw "python3 no disponible" }
        $global:PythonCmd = "python3"
        Write-Host "  ✓ $pyVersion" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ Python no está instalado o no está en el PATH." -ForegroundColor Red
        Write-Host ""
        Write-Host "  Descárgalo desde: https://www.python.org/downloads/" -ForegroundColor Yellow
        Write-Host "  IMPORTANTE: Marca 'Add Python to PATH' durante la instalación." -ForegroundColor Yellow
        pause
        exit 1
    }
}

if (-not $global:PythonCmd) { $global:PythonCmd = "python" }

# ── 2. Crear / activar entorno virtual ───────────────
if (-not $NoVenv) {
    if (-not (Test-Path (Join-Path $VenvDir "Scripts" "python.exe"))) {
        Write-Host "  📦 Creando entorno virtual en $VenvDir ..." -ForegroundColor Cyan
        & $global:PythonCmd -m venv $VenvDir
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  ⚠  Error al crear el entorno virtual. Usando Python del sistema." -ForegroundColor Yellow
            $NoVenv = $true
        }
    } else {
        Write-Host "  ✓ Entorno virtual encontrado" -ForegroundColor Green
    }
}

if (-not $NoVenv) {
    $pythonExe = Join-Path $VenvDir "Scripts" "python.exe"
    $pipExe = Join-Path $VenvDir "Scripts" "pip.exe"
    if (-not (Test-Path $pythonExe)) {
        Write-Host "  ⚠  No se encontró python.exe en el entorno virtual." -ForegroundColor Yellow
        $NoVenv = $true
    }
}

if ($NoVenv) {
    $pythonExe = "python"
    $pipExe = "pip"
}

# ── 3. Instalar dependencias ─────────────────────────
if ($Reinstalar -or -not (Test-Path (Join-Path $VenvDir "Scripts" "opencv"))) {
    Write-Host "  📥 Instalando dependencias..." -ForegroundColor Cyan
    & $pipExe install -r $Requirements --quiet
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Dependencias instaladas" -ForegroundColor Green
    } else {
        Write-Host "  ⚠  Error instalando dependencias. Intenta manualmente:" -ForegroundColor Yellow
        Write-Host "     $pipExe install -r $Requirements"
    }
} else {
    Write-Host "  ✓ Dependencias ya instaladas (usa -Reinstalar para forzar)" -ForegroundColor DarkGray
}

# ── 4. Construir argumentos ──────────────────────────
$argsList = @()

if ($Input)     { $argsList += "--input"; $argsList += "`"$Input`"" }
if ($Output)    { $argsList += "--output"; $argsList += "`"$Output`"" }
if ($Size -gt 0)   { $argsList += "--size"; $argsList += "$Size" }
if ($Format)    { $argsList += "--format"; $argsList += $Format }
if ($Quality -gt 0) { $argsList += "--quality"; $argsList += "$Quality" }
if ($Detector)  { $argsList += "--detector"; $argsList += $Detector }
if ($Margen -ge 0)  { $argsList += "--margen"; $argsList += "$Margen" }
if ($Workers -gt 0) { $argsList += "--workers"; $argsList += "$Workers" }
if ($DryRun)    { $argsList += "--dry-run" }
if ($Verbose)   { $argsList += "--verbose" }

# ── 5. Ejecutar ──────────────────────────────────────
Write-Host ""
Write-Host "🚀 Ejecutando normalizador..." -ForegroundColor Cyan

$cmd = "& `"$pythonExe`" `"$PythonScript`" $($argsList -join ' ')"
if ($Verbose) {
    Write-Host "  Comando: $cmd" -ForegroundColor DarkGray
}
Write-Host ""

Invoke-Expression $cmd

if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ Proceso completado" -ForegroundColor Green
} else {
    Write-Host "  ⚠  El proceso terminó con código $LASTEXITCODE" -ForegroundColor Yellow
}

Write-Host ""
pause
