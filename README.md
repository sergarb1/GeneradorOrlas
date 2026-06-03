# 🎓 Generador de Orlas Interactivas

Generador automático de **orlas académicas interactivas** en HTML/CSS/JS puro. Crea orlas completas con fotografías, nombres, cargos y diplomas personalizados — **sin servidor, sin base de datos, 100% frontend**.

---

<div align="center">

## 🎯 ¡PRUÉBALO AHORA MISMO!  👈👈

```
               👇                          👇                          👇
          https://sergarb1.github.io/GeneradorOrlas/
               👆                          👆                          👆
```

[![🌐 Abrir GitHub Pages](https://img.shields.io/badge/🌐_ABRIR_GITHUB_PAGES-2c482b?style=for-the-badge&logo=githubpages&logoColor=white)](https://sergarb1.github.io/GeneradorOrlas/)
[![📁 Ver docs/ local](https://img.shields.io/badge/📁_Ver_docs_📂-8b6239?style=for-the-badge)](docs/index.html)
[![📸 Normalizador Fotos](https://img.shields.io/badge/📸_Normalizador_Fotos-5a7a4b?style=for-the-badge)](normalizador-fotos.html)

> 👆 **Haz clic en el badge de arriba — todas las orlas funcionando en vivo**

</div>

---

## 📖 ¿Qué es y para qué sirve?

Este proyecto permite a cualquier centro educativo generar sus propias orlas de final de curso de forma profesional, sin necesidad de conocimientos técnicos avanzados ni herramientas de diseño gráfico.

### ¿Qué incluye cada orla?

| Elemento | Descripción |
|----------|-------------|
| 🧑‍🏫 **Profesorado** | Foto, nombre y cargo de cada docente |
| 👨‍🎓 **Alumnado** | Foto, nombre y apellidos de cada estudiante |
| 🖱️ **Fichas interactivas** | Clic en cualquier persona para ver sus datos |
| 📜 **Diplomas** | Diploma personalizado con superpoder aleatorio |
| ▶️ **Modo recorrido** | Pase de diapositivas automático |
| 🔍 **Buscador** | Encuentra a cualquier persona al instante |
| 🖨️ **Impresión PDF** | Imprime la orla directamente desde el navegador |

---

## ✨ Características detalladas

### 🖱️ Interactividad total
Cada persona en la orla es un elemento interactivo. Al hacer clic se abre un modal con su foto ampliada, nombre, cargo (si es profesor) y un **superpoder aleatorio** generado para la ocasión. Ideal para presentaciones en clase o eventos de graduación.

### ▶️ Modo Recorrido automático
Activa el modo recorrido y la orla irá mostrando cada persona una a una, como un pase de diapositivas. Incluye:
- Barra de progreso visual
- Intervalo ajustable entre personas
- Botón de pausa/reanudar
- Animación de confeti al completar el recorrido

### 🔍 Buscador instantáneo
Escribe en el campo de búsqueda y filtra al instante tanto profesorado como alumnado. Ideal para orlas con muchos estudiantes.

### 📜 Diploma personalizado
Cada persona puede recibir un **diploma único** con:
- Su nombre completo
- Un superpoder generado aleatoriamente (existen más de 30 distintos)
- Un diseño elegante con marco decorativo
- Listo para imprimir

### 🌓 Modo oscuro / claro
Alterna entre ambos temas con un botón. El modo se recuerda aunque recargues la página.

### 🖨️ Impresión optimizada
Pulsa el botón de imprimir y obtendrás un **PDF en horizontal** con solo la orla visible (sin botones, modales ni elementos de interfaz). Perfecto para imprimir y enmarcar.

### ⌨️ Atajos de teclado

| Tecla | Acción |
|-------|--------|
| `→` / `↓` | Siguiente persona en el recorrido |
| `←` / `↑` | Persona anterior |
| `ESC` | Cerrar modal o detener recorrido |
| `F` | Abrir buscador |

### 📱 Diseño responsive
Las orlas se adaptan a cualquier tamaño de pantalla: móvil, tablet o escritorio. Las fichas, fotos y textos se reajustan automáticamente.

---

## 📁 Estructura del proyecto

```
GeneradorOrlas/
│
├── 🎨 PLANTILLAS Y ORLAS
├── index-ejemplo-principal.html  # Plantilla principal / orla SMR
├── informatica.html            # DAM — 25 alumnos
├── administrativo.html         # Gestión Administrativa — 25 alumnos
├── asistenciadireccion.html    # Asistencia a la Dirección — 12 alumnos
├── bachillerato.html           # Bachillerato — 30 alumnos
├── comercio.html               # Comercio — 25 alumnos
├── eso.html                    # 4º ESO — 28 alumnos
├── fpb.html                    # FP Básica — 21 alumnos
├── menu.html                   # Panel de navegación entre orlas
│
├── 🔧 HERRAMIENTAS
├── normalizador-fotos.html      # Normalizador gráfico (HTML/JS, navegador)
├── normalizar-fotos.py          # Normalizador por línea de comandos (Python + OpenCV)
├── normalizar-fotos.ps1         # Normalizador por línea de comandos (ImageMagick)
├── requirements.txt             # Dependencias Python (pip install -r)
├── ejecutar-normalizador.ps1    # Instala y ejecuta la versión Python
│
├── 🖼️ RECURSOS GRÁFICOS
├── layout.png                  # Fondo común para todas las orlas
├── photos/                     # Pool de fotografías fuente (a1.jpg … p6.jpg)
├── profesores/                 # Carpeta para fotos del profesorado
├── alumnos/                    # Carpeta para fotos del alumnado
│
├── 📄 DOCUMENTACIÓN Y SITIO WEB
├── docs/                       # Sitio publicado en GitHub Pages
│   ├── index.html              # Página principal del proyecto
│   └── orlas/                  # Copia de las orlas para GitHub Pages
│
├── ⚙️ SCRIPTS POWERSHELL
├── update_orlas.ps1              # Genera todas las orlas desde cero
├── sync_all.ps1                  # Sincroniza diseño entre todas las orlas
├── check_missing.ps1             # Verifica qué fotos faltan
├── copy_photos.ps1               # Distribuye fotos desde el pool
│
└── README.md                     # Este archivo
```

---

## 🔥 Normalizador de Fotos

**`normalizador-fotos.html`** es una herramienta visual que prepara automáticamente las fotografías para las orlas: las recorta en cuadrado, centra el rostro y las unifica al mismo tamaño.

### 🤔 ¿Por qué es necesario?

En una orla todas las fotos deben verse uniformes: mismo tamaño, misma composición, rostro centrado. Con fotos de diferentes fuentes (móviles, cámaras, redes sociales) es difícil lograr consistencia manualmente. Esta herramienta lo hace automático en lote.

### 🧠 Cómo funciona internamente

1. **Carga masiva** — Arrastra todas las fotos que quieras (JPG, PNG, WebP) o selecciónalas con el selector de archivos.
2. **Detección facial** — Usa la API nativa `FaceDetector` de Chromium (Chrome, Edge, Brave, Opera) para localizar el rostro en cada imagen. Es una API del navegador, no necesita librerías externas ni conexión a internet.
3. **Recorte inteligente** — Calcula el encuadre óptimo alrededor del rostro con un margen configurable (por defecto 30%). Si el rostro está cerca del borde, desplaza el encuadre para no salirse de la imagen.
4. **Redimensionado** — Escala el recorte al tamaño de salida (por defecto 600×600 px) usando `imageSmoothingQuality: 'high'` para máxima calidad.
5. **Previsualización** — Muestra cada foto Original vs Normalizada lado a lado.
6. **Descarga** — Individual por foto o todas juntas (usando File System Access API si está disponible, o descarga secuencial).

### 📐 Parámetros configurables

| Parámetro | Valor por defecto | Rango | Descripción |
|-----------|------------------|-------|-------------|
| Tamaño de salida | 600×600 px | 100–2000 px | Resolución de la foto normalizada |
| Margen facial | 30% | 0–100% | Espacio extra alrededor del rostro |

### 🦊 Compatibilidad con navegadores

| Navegador | Detección facial | Funcionamiento |
|-----------|:----------------:|:--------------:|
| Chrome / Edge | ✅ API nativa | Completo |
| Brave / Opera | ✅ API nativa | Completo |
| Firefox | ❌ No soportado | Fallback: centrado automático |
| Safari | ❌ No soportado | Fallback: centrado automático |

> En navegadores sin `FaceDetector`, la herramienta funciona igual pero centra la imagen tomando el centro geométrico (asume que el rostro está aproximadamente centrado).

---

## 🐍 Normalizador de Fotos (Python + OpenCV)

**`normalizar-fotos.py`** es una versión por línea de comandos que usa **OpenCV** para la detección facial, con dos motores:

| Motor | Precisión | Velocidad | Descripción |
|-------|:---------:|:---------:|-------------|
| **Haar Cascade** | ⚠️ Básica | 🚀 Rápido | Integrado en OpenCV, no necesita descargas |
| **DNN (SSD + ResNet)** | ✅ Alta | ⚡ Medio | Se descarga automáticamente (~20 MB) la primera vez |

### Instalación

```bash
pip install -r requirements.txt
```

### Uso

```bash
python normalizar-fotos.py
python normalizar-fotos.py --input ./profesores --size 800
python normalizar-fotos.py --input ./alumnos --format png --detector dnn
python normalizar-fotos.py --input ./fotos --dry-run --verbose
```

### Lanzador automático (Windows)

```powershell
.\ejecutar-normalizador.ps1
.\ejecutar-normalizador.ps1 -Input ./profesores -Detector dnn -Verbose
.\ejecutar-normalizador.ps1 -DryRun
```

Este script crea un entorno virtual en `.venv/`, instala dependencias, descarga el modelo DNN y ejecuta el normalizador.

### Parámetros

| Parámetro | Defecto | Descripción |
|-----------|---------|-------------|
| `--input` | `./alumnos` | Carpeta con fotos originales |
| `--output` | `{input}_normalizadas` | Carpeta de salida |
| `--size` | `600` | Tamaño del cuadrado en px |
| `--format` | `jpg` | `jpg`, `png` o `webp` |
| `--quality` | `95` | Calidad (solo JPEG/WebP) |
| `--detector` | `auto` | `haar`, `dnn` o `auto` |
| `--margen` | `0.3` | Margen facial (0.0–1.0) |
| `--workers` | `4` | Hilos en paralelo |
| `--dry-run` | — | Vista previa sin procesar |

---

## 🖥️ Normalizador de Fotos (ImageMagick)

**`normalizar-fotos.ps1`** usa **ImageMagick** para centros geométrico en lote — no tiene detección facial, pero es la opción más rápida si todas las fotos ya están bien encuadradas.

```powershell
.\normalizar-fotos.ps1
.\normalizar-fotos.ps1 -InputDir ./profesores -Size 800 -Verbose
.\normalizar-fotos.ps1 -InputDir ./fotos -DryRun
```

Requiere [ImageMagick](https://imagemagick.org/script/download.php) instalado.

---

## 🛠️ Guía completa: Cómo crear tu propia orla

### Paso 1: Elige una plantilla base

Parte de cualquiera de los archivos HTML existentes. El más recomendado es `index-ejemplo-principal.html` (usado como plantilla central). Si tu ciclo tiene un número de alumnos similar a alguno de los ejemplos, puedes usar ese como base.

**Relación tamaño/número de alumnos:**
- Hasta 12 alumnos → orlas tipo `asistenciadireccion.html`
- 15–20 alumnos → orlas tipo `smr.html` (17 alumnos)
- 21–25 alumnos → orlas tipo `informatica.html` (25 alumnos)
- 26–30 alumnos → orlas tipo `eso.html` (28 alumnos) o `bachillerato.html` (30 alumnos)

### Paso 2: Prepara las fotografías

Coloca las fotos en las carpetas `profesores/` y `alumnos/` con el nombre normalizado:

```
profesores/maria_garcia_lopez.jpg
alumnos/juan_perez_martinez.jpg
```

**Formato recomendado:**
- Formato: JPG (mejor relación calidad/peso)
- Tamaño: mínimo 300×300 px, recomendado 600×600 px
- Orientación: cuadrado o vertical (se recortará a cuadrado)
- Fondo: liso o con fondo neutro (mejor resultado visual)

> 💡 **Usa `normalizador-fotos.html`** antes de empezar: abres la herramienta, arrastras todas las fotos, pulsas "Procesar todo" y descargas el resultado. Todas saldrán con el mismo tamaño y la cara centrada.

Si una foto no existe, el sistema muestra automáticamente un **círculo con la inicial** de la persona como placeholder.

### Paso 3: Configura los datos

Busca en el HTML los arrays `profesoresRaw` y `alumnosRaw` y edítalos:

```javascript
// Profesorado: cada entrada necesita nombre y cargo
const profesoresRaw = [
  { nombre: 'María García López', cargo: 'Tutora' },
  { nombre: 'Juan Pérez Martínez', cargo: 'Profesor de Matemáticas' },
  { nombre: 'Ana López Ruiz',     cargo: 'Jefa de Estudios' }
];

// Alumnado: cada entrada necesita nombre y apellidos
// El nombre debe coincidir con el archivo de foto en alumnos/
const alumnosRaw = [
  { nombre: 'Ana',   apellidos: 'Gómez Ruiz' },
  { nombre: 'Luis',  apellidos: 'Sánchez López' },
  { nombre: 'Laura', apellidos: 'Martínez Pérez' }
];
```

**Reglas de nomenclatura para fotos:**
- El nombre del archivo debe coincidir con los datos: `nombre_apellido1_apellido2.jpg`
- Todo en minúsculas, espacios reemplazados por guiones bajos
- El HTML busca automáticamente: `alumnos/ana_gomez_ruiz.jpg`

### Paso 4: Personaliza el diseño

**Colores:** modifica las variables CSS en el bloque `:root`:

```css
:root {
  --bg-body: #f3f0e9;       /* Fondo general */
  --bg-orla: #fefcf5;       /* Fondo de la orla */
  --accent: #2c482b;        /* Color de acento principal */
  --accent-alt: #8b6239;    /* Color de acento secundario */
  --text-main: #2c2c2c;     /* Color del texto */
  --text-light: #6b5a45;    /* Color del texto secundario */
}
```

**Fondo:** Reemplaza `layout.png` por tu propia imagen de fondo.
- Resolución recomendada: **1920×1080 px**
- La imagen debe tener una zona central despejada para el contenido
- Si no usas fondo, comenta o elimina la línea `background: url('layout.png') ...`

**Tipografías:** Las orlas usan Google Fonts: **Cinzel** (títulos), **Cormorant Garamond** (textos) y **Great Vibes** (nombres de alumnos). Puedes cambiarlas editando el enlace a Google Fonts en el `<head>` y los `font-family` en el CSS.

### Paso 5: Actualiza el texto del ciclo

```html
<div class="ciclo">CICLO FORMATIVO DE GRADO MEDIO</div>
<div class="promocion">PROMOCIÓN 2024-2026</div>
```

Cambia también el `<title>` de la página y el título principal si lo deseas.

### Paso 6: Distribución de los alumnos

El sistema distribuye automáticamente los alumnos en filas usando flex-wrap. El número de alumnos por fila y el tamaño de las fotos se ajusta según la cantidad total:

| Alumnos | Ancho por alumno | Foto | Gap vertical |
|---------|:----------------:|:----:|:------------:|
| < 12 | 11 cqw | 6.5 cqw | 1 cqw |
| 12–20 | 10 cqw | 5.5 cqw | 0.6 cqw |
| 21–25 | 8.5 cqw | 4.8 cqw | 0.5 cqw |
| > 25 | 7.5 cqw | 4 cqw | 0.4 cqw |

> El sistema evita que la última fila se quede con un solo alumno (huérfano), ajustando márgenes para que quede simétrica.

### Paso 7: Abre en el navegador

No necesitas servidor. Simplemente abre el archivo `.html` directamente en Chrome o Edge con doble clic. Todo funciona 100% en el navegador.

---

## 🤖 Automatización con PowerShell

El proyecto incluye scripts PowerShell para automatizar tareas repetitivas:

```powershell
# 🔨 Generar todas las orlas desde cero
# Crea nombres ficticios, asigna fotos y genera los HTML completos
.\update_orlas.ps1

# 🔄 Sincronizar diseño
# Aplica los cambios de la plantilla a todas las orlas
# Mantiene los datos (profesoresRaw, alumnosRaw) de cada una
.\sync_all.ps1

# 🔍 Verificar fotos faltantes
# Comprueba qué fotos no existen y se mostrarán como placeholder
.\check_missing.ps1

# 📋 Copiar fotos desde el pool
# Distribuye las fotos genéricas de photos/ a los directorios
.\copy_photos.ps1
```

### ¿Qué hace update_orlas.ps1?

Este script automatiza la creación completa de orlas de ejemplo:
1. Genera nombres y apellidos ficticios combinando listas predefinidas
2. Asigna fotografías del pool `photos/` (imágenes genéricas)
3. Crea los arrays `profesoresRaw` y `alumnosRaw` en cada HTML
4. Configura títulos, ciclos y promociones para cada especialidad
5. Genera los archivos HTML listos para abrir en el navegador

### ¿Qué hace sync_all.ps1?

Sincroniza el diseño visual entre todas las orlas:
1. Lee la estructura CSS y JavaScript de `index-ejemplo-principal.html` (plantilla base)
2. Extrae solo los datos de cada orla (`profesoresRaw`, `alumnosRaw`, título, ciclo)
3. Reconstruye cada orla con el diseño actualizado y sus datos originales

---

## 🌍 Cómo publicar en GitHub Pages

1. **Sube el proyecto a GitHub:**
   ```bash
   git init
   git add .
   git commit -m "Inicializar generador de orlas"
   git remote add origin https://github.com/tu-usuario/GeneradorOrlas.git
   git push -u origin main
   ```

2. **Activa GitHub Pages:**
   - Ve a Settings → Pages de tu repositorio
   - Selecciona la rama `main` y la carpeta `/docs`
   - Guarda. En unos segundos tu sitio estará en `https://tu-usuario.github.io/GeneradorOrlas/`

3. **Actualiza los enlaces en `docs/index.html`** si cambia la URL.

---

## ⚙️ Requisitos del sistema

| Componente | Requisito |
|------------|-----------|
| Navegador | Chrome, Edge, Brave, Opera (recomendado) |
| Firefox / Safari | Funcional, sin detección facial nativa |
| Servidor web | No necesario (funciona en `file://`) |
| Conexión a internet | Solo para Google Fonts (opcional) |
| Sistema operativo | Windows, macOS, Linux |

---

## ❓ Preguntas frecuentes

**¿Puedo usar fotos en vertical o apaisadas?**
Sí, el `normalizador-fotos.html` las recorta a cuadrado automáticamente centrando el rostro.

**¿Cuántos alumnos caben en una orla?**
El sistema está probado desde 5 hasta 50 alumnos. Con más de 35 las fotos se vuelven muy pequeñas; se recomienda dividir en dos orlas.

**¿Se puede imprimir?**
Sí, pulsa el botón de imprimir y se generará un PDF en horizontal con solo la orla visible.

**¿Funciona sin internet?**
Sí, excepto las tipografías de Google Fonts (que se pueden descargar e incluir localmente).

**¿Puedo cambiar los superpoderes de los diplomas?**
Sí, busca el array `superpoderes` en el JavaScript y añade o modifica los que quieras.

**¿Cómo añado más profesores?**
Añade más entradas al array `profesoresRaw` y sus fotos en `profesores/`.

---

## ⚠️ Aviso importante

**Todos los nombres, apellidos y datos personales** que aparecen en las orlas de ejemplo son **completamente ficticios**, generados algorítmicamente combinando nombres y apellidos comunes de forma aleatoria.

**Todas las fotografías** son imágenes genéricas de archivo o placeholders. Cualquier parecido con la realidad es mera coincidencia.

Este proyecto es una **herramienta de ejemplo y plantilla** para que cada centro educativo pueda adaptarlo con sus propios datos oficiales.

---

## 📄 Licencia

**Creative Commons Attribution-ShareAlike 4.0 (CC BY-SA 4.0)**

© 2026 **Sergi García Barea**

Puedes usar, modificar y distribuir este proyecto libremente, siempre que:
- **Atribuyas** la autoría original a Sergi García Barea
- **Compartas** las modificaciones bajo la misma licencia

[![CC BY-SA 4.0](https://img.shields.io/badge/Licencia-CC_BY--SA_4.0-2c482b?style=for-the-badge)](https://creativecommons.org/licenses/by-sa/4.0/)
