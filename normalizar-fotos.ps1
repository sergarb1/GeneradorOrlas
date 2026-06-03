<#
.SYNOPSIS
  Normaliza fotos para orlas usando ImageMagick.
  Recorta a cuadrado centrado, redimensiona, unifica formato.

.DESCRIPTION
  Procesa todas las imágenes de una carpeta y las guarda en otra,
  recortándolas a un cuadrado centrado del tamaño indicado.
  Requiere ImageMagick (comando 'magick').

.PARAMETER InputDir
  Carpeta con las fotos originales.
  Valor por defecto: .\alumnos

.PARAMETER OutputDir
  Carpeta donde guardar las fotos normalizadas.
  Por defecto crea una carpeta con sufijo _normalizadas.

.PARAMETER Size
  Tamaño del cuadrado de salida en píxeles.
  Valor por defecto: 600

.PARAMETER Quality
  Calidad JPEG (1-100). Solo aplica a salida JPEG.
  Valor por defecto: 95

.PARAMETER Format
  Formato de salida: jpg, png, webp.
  Valor por defecto: jpg

.PARAMETER DryRun
  Muestra lo que haría sin procesar nada.

.PARAMETER Verbose
  Muestra información detallada de cada foto.

.EXAMPLE
  # Procesa todas las fotos de .\alumnos y las guarda en .\alumnos_normalizadas\
  .\normalizar-fotos.ps1

.EXAMPLE
  # Procesa fotos de una carpeta específica
  .\normalizar-fotos.ps1 -InputDir "C:\Fotos\Alumnos" -OutputDir "C:\Fotos\Listas" -Size 800

.EXAMPLE
  # Vista previa sin procesar
  .\normalizar-fotos.ps1 -InputDir .\fotos -DryRun

.EXAMPLE
  # Salida en PNG sin pérdida
  .\normalizar-fotos.ps1 -InputDir .\fotos -Format png
#>

param(
    [string]$InputDir = ".\alumnos",
    [string]$OutputDir = "",
    [int]$Size = 600,
    [int]$Quality = 95,
    [ValidateSet("jpg","png","webp")]
    [string]$Format = "jpg",
    [switch]$DryRun,
    [switch]$Verbose
)

# ---- Comprobar ImageMagick ----
$magickCmd = "magick"
try {
    $null = Get-Command $magickCmd -ErrorAction Stop
} catch {
    Write-Error "ImageMagick no está instalado o no está en el PATH."
    Write-Error "Descárgalo desde: https://imagemagick.org/script/download.php"
    Write-Error "Asegúrate de marcar 'Install legacy utilities (e.g. convert)' durante la instalación."
    exit 1
}

# ---- Resolver rutas ----
$inputPath = Resolve-Path $InputDir -ErrorAction Stop
if (-not $OutputDir) {
    $OutputDir = Join-Path $inputPath ".." "$(Split-Path $inputPath -Leaf)_normalizadas"
}
$outputPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputDir)

# ---- Extensiones de imagen ----
$extensions = @('*.jpg','*.jpeg','*.png','*.gif','*.bmp','*.tif','*.tiff','*.webp')

# ---- Recopilar archivos ----
$files = Get-ChildItem -LiteralPath $inputPath -Include $extensions -File
if ($files.Count -eq 0) {
    Write-Warning "No se encontraron imágenes en: $inputPath"
    exit 0
}

Write-Host "`n══════════════════════════════════════════════" -ForegroundColor DarkGreen
Write-Host "  NORMALIZADOR DE FOTOS (ImageMagick)" -ForegroundColor Green
Write-Host "══════════════════════════════════════════════" -ForegroundColor DarkGreen
Write-Host ""
Write-Host "  Origen:     $inputPath" -ForegroundColor Cyan
Write-Host "  Destino:    $outputPath" -ForegroundColor Cyan
Write-Host "  Tamaño:     ${Size}×${Size} px" -ForegroundColor Cyan
Write-Host "  Formato:    $Format" -ForegroundColor Cyan
if ($Format -eq "jpg") { Write-Host "  Calidad:    $Quality%" -ForegroundColor Cyan }
Write-Host "  Archivos:   $($files.Count)" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "═══ MODO VISTA PREVIA (DryRun) ═══" -ForegroundColor Yellow
    Write-Host "Se procesarían estos archivos:" -ForegroundColor Yellow
    foreach ($f in $files) {
        $outName = "$([System.IO.Path]::GetFileNameWithoutExtension($f.Name)).$Format"
        $msg = "  • $($f.Name) → $outName"
        if ($Verbose) {
            $msg += "  [$($f.Length / 1KB -as [int]) KB, $($f.Directory.Name)]"
        }
        Write-Host $msg
    }
    Write-Host ""
    Write-Host "Destino: $outputPath" -ForegroundColor Yellow
    Write-Host "Comando: magick INPUT -resize `"${Size}x${Size}^`" -gravity center -extent ${Size}x${Size} -quality $Quality OUTPUT"
    exit 0
}

# ---- Crear directorio de salida ----
if (-not (Test-Path -LiteralPath $outputPath)) {
    New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
    Write-Host "  Creado directorio: $outputPath" -ForegroundColor DarkGray
}

# ---- Procesar ----
$total = $files.Count
$ok = 0
$errors = 0
$i = 0

foreach ($file in $files) {
    $i++
    $outName = "$([System.IO.Path]::GetFileNameWithoutExtension($file.Name)).$Format"
    $outFile = Join-Path $outputPath $outName

    # Construir comando
    $args = @(
        $file.FullName,
        "-resize", "${Size}x${Size}^",
        "-gravity", "center",
        "-extent", "${Size}x${Size}",
        "-quality", "$Quality",
        $outFile
    )

    # Barra de progreso simple
    $pct = [Math]::Round(($i / $total) * 100)
    Write-Progress -Activity "Normalizando fotos..." -Status "$i de $total — $($file.Name)" -PercentComplete $pct

    try {
        if ($Verbose) { Write-Host "  [$i/$total] $($file.Name) → $outName" -ForegroundColor Gray }
        & $magickCmd $args 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $outFile)) {
            throw "ImageMagick devolvió código $LASTEXITCODE"
        }
        $ok++
    } catch {
        Write-Warning "  Error en '$($file.Name)': $_"
        $errors++
    }
}

Write-Progress -Activity "Normalizando fotos..." -Completed
Write-Host ""

# ---- Resumen ----
Write-Host "══════════════════════════════════════════════" -ForegroundColor DarkGreen
Write-Host "  PROCESO COMPLETADO" -ForegroundColor Green
Write-Host "══════════════════════════════════════════════" -ForegroundColor DarkGreen
Write-Host ""
Write-Host "  ✅ Correctas: $ok" -ForegroundColor $(if ($ok -gt 0) { "Green" } else { "Gray" })
if ($errors -gt 0) { Write-Host "  ❌ Errores:   $errors" -ForegroundColor Red }
Write-Host "  📁 Destino:   $outputPath" -ForegroundColor Cyan
Write-Host ""

# ---- Estadísticas ----
if ($ok -gt 0 -and $Verbose) {
    $totalBytes = (Get-ChildItem -LiteralPath $outputPath -File | Measure-Object -Property Length -Sum).Sum
    $totalSize = if ($totalBytes -gt 1MB) { "$([Math]::Round($totalBytes / 1MB, 1)) MB" } else { "$([Math]::Round($totalBytes / 1KB)) KB" }
    Write-Host "  Tamaño total: $totalSize" -ForegroundColor DarkGray
    Write-Host "  Promedio: $([Math]::Round($totalBytes / $ok / 1KB)) KB por foto" -ForegroundColor DarkGray
}
