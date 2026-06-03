
# Pool of photos
$student_photos = @()
for ($i=1; $i -le 25; $i++) { $student_photos += "photos/a$i.jpg" }
for ($i=1; $i -le 10; $i++) { $student_photos += "alumnos/extra_a$i.jpg" }

$prof_photos = @()
for ($i=1; $i -le 6; $i++) { $prof_photos += "photos/p$i.jpg" }
for ($i=1; $i -le 10; $i++) { $prof_photos += "profesores/extra_p$i.jpg" }

# Fictional names pool
$first_names = @("Alejandro","Beatriz","Carlos","Daniela","Eduardo","Fatima","Gabriel","Hugo","Irene","Juan","Kevin","Laura","Marcos","Nuria","Oscar","Patricia","Quique","Rosa","Saul","Tania","Urbano","Vera","Wilson","Xavi","Yara","Zoe","Andres","Blanca","Cesar","Diana","Emilio","Fabiola","German","Hilda","Iker","Julia","Lola","Mario","Olga","Pedro","Sonia","Tomas","Ursula","Victor")
$last_names = @("Garcia","Martinez","Lopez","Sanchez","Rodriguez","Perez","Gomez","Fernandez","Moreno","Jimenez","Ruiz","Alvarez","Vazquez","Castro","Solis","Ramos","Delgado","Navarro","Torres","Gil","Vila","Soria","Cano","Vara","Mendoza","Rivas","Belmonte")

function Get-FictionalName($index) {
    $fn = $first_names[$index % $first_names.Length]
    $ln1 = $last_names[($index * 7) % $last_names.Length]
    $ln2 = $last_names[($index * 13) % $last_names.Length]
    return "$fn $ln1 $ln2"
}

function Normalizar-Nombre($nombre) {
    # Use FormD for normalization
    $n = $nombre.Normalize([System.Text.NormalizationForm]::FormD)
    $sb = New-Object System.Text.StringBuilder
    foreach ($c in $n.ToCharArray()) {
        if ([System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($c) -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$sb.Append($c)
        }
    }
    $res = $sb.ToString()
    $res = $res -replace "[.,'´`\""]",""
    $res = $res -replace "ª","a"
    $res = $res -replace "\s+","_"
    $res = $res -replace "[^a-z0-9_]",""
    return $res.ToLower()
}

$files = @(
    @{ Path="administrativo.html"; Title="Gestion Administrativa"; Ciclo="GESTION ADMINISTRATIVA"; Profs=6; Alums=25 },
    @{ Path="comercio.html"; Title="Actividades Comerciales"; Ciclo="ACTIVIDADES COMERCIALES"; Profs=6; Alums=25 },
    @{ Path="bachillerato.html"; Title="Bachillerato"; Ciclo="BACHILLERATO DE CIENCIAS Y TECNOLOGIA"; Profs=10; Alums=30 },
    @{ Path="eso.html"; Title="ESO"; Ciclo="4o EDUCACION SECUNDARIA OBLIGATORIA"; Profs=12; Alums=28 },
    @{ Path="fpb.html"; Title="FP Basica"; Ciclo="FP BASICA - INFORMATICA Y COMUNICACIONES"; Profs=6; Alums=20 },
    @{ Path="informatica.html"; Title="Informatica"; Ciclo="DESARROLLO DE APLICACIONES MULTIPLATAFORMA"; Profs=8; Alums=25 }
)

        # Use the latest index-ejemplo-principal.html as template
        $template = Get-Content -Path "index-ejemplo-principal.html" -Raw

foreach ($file in $files) {
    Write-Host "Processing $($file.Path)..."
    
    $profsRaw = @()
    for ($i=0; $i -lt $file.Profs; $i++) {
        $name = Get-FictionalName ($i + 100)
        $cargo = if ($i -eq 0) { "Director/a" } elseif ($i -eq 1) { "Jefe/a de Estudios" } else { "Profesor/a" }
        $profsRaw += "{ nombre: '$name', cargo: '$cargo' }"
        
        $photo_src = $prof_photos[$i % $prof_photos.Length]
        $dest_name = (Normalizar-Nombre $name) + ".jpg"
        Copy-Item -Path $photo_src -Destination "profesores/$dest_name" -Force
    }
    
    $alumsRaw = @()
    for ($i=0; $i -lt $file.Alums; $i++) {
        $name_full = Get-FictionalName ($i + 200)
        $parts = $name_full -split " "
        $pila = $parts[0]
        $apellidos = "$($parts[1]) $($parts[2])"
        $alumsRaw += "{ nombre: '$pila', apellidos: '$apellidos' }"
        
        $photo_src = $student_photos[$i % $student_photos.Length]
        $dest_name = (Normalizar-Nombre $name_full) + ".jpg"
        Copy-Item -Path $photo_src -Destination "alumnos/$dest_name" -Force
    }
    
    $profsJS = "[" + ($profsRaw -join ", ") + "]"
    $alumsJS = "[" + ($alumsRaw -join ", ") + "]"
    
    $new_content = $template
    # Update Title
    $new_content = $new_content.Replace('<title>Orla Académica - IES Serra Perenxisa</title>', "<title>Orla Académica - $($file.Title)</title>")
    # Update Ciclo
    $new_content = $new_content.Replace('<div class="ciclo">TÉCNICO EN SISTEMAS MICROINFORMÁTICOS Y REDES</div>', "<div class=`"ciclo`">$($file.Ciclo)</div>")
    # Update profesoresRaw
    $new_content = [regex]::Replace($new_content, 'const profesoresRaw = \[[\s\S]*?\];', "const profesoresRaw = $profsJS;")
    # Update alumnosRaw
    $new_content = [regex]::Replace($new_content, 'const alumnosRaw = \[[\s\S]*?\];', "const alumnosRaw = $alumsJS;")
    
    [System.IO.File]::WriteAllText($file.Path, $new_content)
}
