
$files = @('index-ejemplo-principal.html', 'administrativo.html', 'comercio.html', 'bachillerato.html', 'eso.html', 'fpb.html', 'informatica.html')

function Normalize-Name($name) {
    $normalized = $name.Normalize([System.Text.NormalizationForm]::FormD)
    $sb = New-Object System.Text.StringBuilder
    foreach ($c in $normalized.ToCharArray()) {
        if ([System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($c) -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$sb.Append($c)
        }
    }
    $res = $sb.ToString().Replace('.', '').Replace(',', '').Replace("'", '').Replace('´', '').Replace('`', '').Replace('"', '').Replace('ª', 'a').ToLower()
    $res = [System.Text.RegularExpressions.Regex]::Replace($res, '\s+', '_')
    $res = [System.Text.RegularExpressions.Regex]::Replace($res, '[^a-z0-9_]', '')
    return $res
}

$missingProfs = @{}
$missingAlums = @{}

foreach ($f in $files) {
    if (-not (Test-Path $f)) { continue }
    $content = Get-Content $f -Raw
    
    # Extract profesoresRaw
    if ($content -match 'const profesoresRaw = (\[.*?\]);') {
        $raw = $Matches[1]
        $names = [System.Text.RegularExpressions.Regex]::Matches($raw, "nombre:\s*['\""](.*?)['\""]") | ForEach-Object { $_.Groups[1].Value }
        foreach ($n in $names) {
            $norm = Normalize-Name $n
            if (-not (Test-Path "profesores/$norm.jpg")) {
                $missingProfs[$n] = $norm
            }
        }
    }
    
    # Extract alumnosRaw
    if ($content -match 'const alumnosRaw = (\[.*?\]);') {
        $raw = $Matches[1]
        $matches = [System.Text.RegularExpressions.Regex]::Matches($raw, "nombre:\s*['\""](.*?)['\""],\s*apellidos:\s*['\""](.*?)['\""]")
        foreach ($m in $matches) {
            $n = $m.Groups[1].Value
            $a = $m.Groups[2].Value
            $fullName = "$n $a"
            $norm = Normalize-Name $fullName
            if (-not (Test-Path "alumnos/$norm.jpg")) {
                $missingAlums[$fullName] = $norm
            }
        }
    }
}

Write-Host "--- MISSING PROFESORES ---"
foreach ($k in $missingProfs.Keys) { Write-Host "$k -> $($missingProfs[$k])" }
Write-Host "--- MISSING ALUMNOS ---"
foreach ($k in $missingAlums.Keys) { Write-Host "$k -> $($missingAlums[$k])" }
