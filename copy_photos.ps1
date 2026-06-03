
$photos = Get-ChildItem "photos/*.jpg" | Select-Object -ExpandProperty Name
$a_pool = $photos | Where-Object { $_ -like "a*.jpg" -and $_ -notlike "extra*" }
$p_pool = $photos | Where-Object { $_ -like "p*.jpg" -and $_ -notlike "extra*" }
$extra_a = 1..10 | ForEach-Object { "extra_a$_.jpg" }
$extra_p = 1..10 | ForEach-Object { "extra_p$_.jpg" }

$a_full_pool = $a_pool + $extra_a
$p_full_pool = $p_pool + $extra_p

function Normalizar-Nombre($nombre) {
    $n = $nombre.Normalize("FormD")
    $n = $n -replace "[\u0300-\u036f]", ""
    $n = $n -replace "[.,'´`\""]", ""
    $n = $n -replace "ª", "a"
    $n = $n -replace "[ ]+", "_"
    $n = $n -replace "[^a-z0-9_]", ""
    return $n.ToLower()
}

$files = @("administrativo.html", "comercio.html", "bachillerato.html", "eso.html", "fpb.html", "informatica.html")

foreach ($file in $files) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        
        # Extract Profesores
        if ($content -match "const profesoresRaw = \[(.*?)\];") {
            $profsJson = $matches[1]
            $profs = $profsJson -split "\}," | ForEach-Object { 
                if ($_ -match "nombre: '(.*?)'") { $matches[1] }
            }
            
            $i = 0
            foreach ($p in $profs) {
                if ($p) {
                    $norm = Normalizar-Nombre $p
                    $photo = $p_full_pool[$i % $p_full_pool.Count]
                    if (Test-Path "photos/$photo") {
                        Copy-Item "photos/$photo" "profesores/$norm.jpg" -Force
                    } elseif (Test-Path "profesores/$photo") {
                        Copy-Item "profesores/$photo" "profesores/$norm.jpg" -Force
                    }
                    $i++
                }
            }
        }
        
        # Extract Alumnos
        if ($content -match "const alumnosRaw = \[(.*?)\];") {
            $alumnosJson = $matches[1]
            $alumnos = $alumnosJson -split "\}," | ForEach-Object { 
                if ($_ -match "nombre: '(.*?)', apellidos: '(.*?)'") { 
                    $nombre = $matches[1]
                    $apellidos = $matches[2]
                    "$nombre $apellidos"
                }
            }
            
            $i = 0
            foreach ($a in $alumnos) {
                if ($a) {
                    $norm = Normalizar-Nombre $a
                    $photo = $a_full_pool[$i % $a_full_pool.Count]
                    if (Test-Path "photos/$photo") {
                        Copy-Item "photos/$photo" "alumnos/$norm.jpg" -Force
                    } elseif (Test-Path "alumnos/$photo") {
                        Copy-Item "alumnos/$photo" "alumnos/$norm.jpg" -Force
                    }
                    $i++
                }
            }
        }
    }
}
