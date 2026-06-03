
$template = Get-Content 'index-ejemplo-principal.html' -Raw
$files = @('administrativo.html', 'comercio.html', 'bachillerato.html', 'eso.html', 'fpb.html', 'informatica.html')

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

$extraPIndex = 1
$extraAIndex = 1

foreach ($f in $files) {
    if (-not (Test-Path $f)) { 
        Write-Host "File $f not found, skipping."
        continue 
    }
    
    $targetContent = Get-Content $f -Raw
    
    # Extract data
    $ciclo = ""
    if ($targetContent -match '<div class="ciclo">(.*?)</div>') {
        $ciclo = $Matches[1]
    }
    
    $profsRaw = ""
    if ($targetContent -match 'const profesoresRaw = (\[.*?\]);') {
        $profsRaw = $Matches[1]
    }
    
    $alumnosRaw = ""
    if ($targetContent -match 'const alumnosRaw = (\[.*?\]);') {
        $alumnosRaw = $Matches[1]
    }
    
    # Prepare new content from template
    $newContent = $template
    
    # Update title
    $newContent = [System.Text.RegularExpressions.Regex]::Replace($newContent, '<title>.*?</title>', "<title>Orla Académica - $ciclo</title>")
    
    # Update ciclo div
    $cicloDiv = '<div class="ciclo">' + $ciclo + '</div>'
    $newContent = [System.Text.RegularExpressions.Regex]::Replace($newContent, '<div class="ciclo">.*?</div>', $cicloDiv)
    
    # Update promocion
    $newContent = $newContent.Replace('PROMOCIÃ“N', 'PROMOCIÓN')
    
    # Update Data blocks using string replacement for simplicity where possible or escaped regex
    $profSearch = 'const profesoresRaw = \[.*?\s*\];'
    $profReplace = 'const profesoresRaw = ' + $profsRaw + ';'
    $newContent = [System.Text.RegularExpressions.Regex]::Replace($newContent, $profSearch, $profReplace, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    
    $alSearch = 'const alumnosRaw = \[.*?\s*\];'
    $alReplace = 'const alumnosRaw = ' + $alumnosRaw + ';'
    $newContent = [System.Text.RegularExpressions.Regex]::Replace($newContent, $alSearch, $alReplace, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    
    # Write updated file
    [System.IO.File]::WriteAllText((Get-Item $f).FullName, $newContent, [System.Text.Encoding]::UTF8)
    Write-Host "Synced $f"
    
    # Image checking
    $profRegex = "nombre:\s*['""](.*?)['""]"
    $profMatches = [System.Text.RegularExpressions.Regex]::Matches($profsRaw, $profRegex)
    foreach ($m in $profMatches) {
        $n = $m.Groups[1].Value
        $norm = Normalize-Name $n
        if (-not (Test-Path "profesores/$norm.jpg")) {
            Write-Host "Providing missing profesor image for $n ($norm)"
            $extraFile = "profesores/extra_p$extraPIndex.jpg"
            if (Test-Path $extraFile) {
                Copy-Item $extraFile "profesores/$norm.jpg"
                $extraPIndex = ($extraPIndex % 10) + 1
            }
        }
    }
    
    $alRegex = "nombre:\s*['""](.*?)['""]\s*,\s*apellidos:\s*['""](.*?)['""]"
    $alMatches = [System.Text.RegularExpressions.Regex]::Matches($alumnosRaw, $alRegex)
    foreach ($m in $alMatches) {
        $n = $m.Groups[1].Value
        $a = $m.Groups[2].Value
        $fullName = "$n $a"
        $norm = Normalize-Name $fullName
        if (-not (Test-Path "alumnos/$norm.jpg")) {
            Write-Host "Providing missing alumno image for $fullName ($norm)"
            $extraFile = "alumnos/extra_a$extraAIndex.jpg"
            if (Test-Path $extraFile) {
                Copy-Item $extraFile "alumnos/$norm.jpg"
                $extraAIndex = ($extraAIndex % 10) + 1
            }
        }
    }
}
