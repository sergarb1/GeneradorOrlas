"""
Normalizador de fotos para orlas — versión OpenCV
==================================================
Detecta rostros con OpenCV, centra y recorta a cuadrado,
redimensiona al tamaño deseado y guarda en lote.

Instalación rápida:
    pip install -r requirements.txt
    python normalizar-fotos.py

La primera vez que uses --detector dnn descargará automáticamente
el modelo de ~20 MB.

Uso:
    python normalizar-fotos.py
    python normalizar-fotos.py --input ./alumnos --output ./normalizadas --size 600
    python normalizar-fotos.py --input ./fotos --dry-run --verbose
    python normalizar-fotos.py --format png --detector dnn
"""

import argparse
import os
import sys
import cv2
import numpy as np
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed

# ─────────────────────────────────────────────────────
# Configuración
# ─────────────────────────────────────────────────────
EXTENSIONES = ('.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tif', '.tiff', '.webp')

# URLs del modelo DNN (OpenCV face detector)
DNN_MODEL_URL = "https://github.com/opencv/opencv_3rdparty/raw/dnn_samples_face_detector_20170830/opencv_face_detector_uint8.pb"
DNN_CONFIG_URL = "https://raw.githubusercontent.com/opencv/opencv/master/samples/dnn/face_detector/opencv_face_detector.pbtxt"

DNN_MODEL_DIR = Path.home() / '.cache' / 'opencv-face-detector'
DNN_MODEL_PATH = DNN_MODEL_DIR / 'opencv_face_detector_uint8.pb'
DNN_CONFIG_PATH = DNN_MODEL_DIR / 'opencv_face_detector.pbtxt'


def descargar_modelo_dnn(verbose=False):
    """Descarga el modelo DNN de detección facial si no existe."""
    if DNN_MODEL_PATH.exists():
        if verbose:
            print(f"  ✓ Modelo DNN ya descargado: {DNN_MODEL_PATH}")
        return True

    DNN_MODEL_DIR.mkdir(parents=True, exist_ok=True)
    import urllib.request

    print(f"  ↓ Descargando modelo DNN de detección facial (~20 MB)...")
    print(f"    De: {DNN_MODEL_URL}")
    print(f"    A:  {DNN_MODEL_DIR}")
    print()

    try:
        def _progreso(bloques, tam_bloque, total):
            if total > 0:
                pct = min(bloques * tam_bloque / total * 100, 100)
                barra = '█' * int(pct / 5) + '░' * (20 - int(pct / 5))
                print(f"\r    [{barra}] {pct:.0f}%", end='', flush=True)

        print("    [0%]", end='', flush=True)
        urllib.request.urlretrieve(DNN_MODEL_URL, str(DNN_MODEL_PATH), _progreso)
        print()

        print("    Descargando configuración...")
        urllib.request.urlretrieve(DNN_CONFIG_URL, str(DNN_CONFIG_PATH))

        print(f"  ✓ Modelo DNN descargado correctamente")
        return True

    except Exception as e:
        print(f"\n  ⚠  Error descargando modelo DNN: {e}")
        print(f"     Puedes descargarlo manualmente desde:")
        print(f"     {DNN_MODEL_URL}")
        print(f"     {DNN_CONFIG_URL}")
        print(f"     Y colocarlos en: {DNN_MODEL_DIR}")
        return False


# ─────────────────────────────────────────────────────
# Detección facial
# ─────────────────────────────────────────────────────
def detectar_rostro_haar(img_gray, face_cascade):
    """Detecta rostros usando Haar Cascade (rápido, integrado en OpenCV)."""
    faces = face_cascade.detectMultiScale(
        img_gray,
        scaleFactor=1.1,
        minNeighbors=5,
        minSize=(60, 60),
        flags=cv2.CASCADE_SCALE_IMAGE
    )
    if len(faces) > 0:
        x, y, w, h = max(faces, key=lambda f: f[2] * f[3])
        return x, y, w, h
    return None


def detectar_rostro_dnn(img, face_dnn):
    """Detecta rostros usando DNN (más preciso, basado en Single-Shot Detector)."""
    h, w = img.shape[:2]
    blob = cv2.dnn.blobFromImage(img, 1.0, (300, 300), [104, 117, 123],
                                 swapRB=False, crop=False)
    face_dnn.setInput(blob)
    detections = face_dnn.forward()

    best = None
    best_conf = 0
    for i in range(detections.shape[2]):
        confidence = detections[0, 0, i, 2]
        if confidence > 0.5 and confidence > best_conf:
            best_conf = confidence
            box = detections[0, 0, i, 3:7] * np.array([w, h, w, h])
            x1, y1, x2, y2 = box.astype(int)
            best = (x1, y1, x2 - x1, y2 - y1)

    return best


# ─────────────────────────────────────────────────────
# Recorte y procesado
# ─────────────────────────────────────────────────────
def recorte_inteligente(img, face_box, margen=0.3):
    """Calcula el recorte cuadrado centrado en el rostro o en el centro de la imagen."""
    h, w = img.shape[:2]
    cx, cy = w // 2, h // 2
    size = min(w, h)

    if face_box:
        fx, fy, fw, fh = face_box
        cx = fx + fw // 2
        cy = fy + fh // 2
        tam_rostro = max(fw, fh)
        margen_px = int(tam_rostro * margen)
        size = min(max(tam_rostro + margen_px * 2, int(size * 0.35)), min(w, h))

    x = max(0, cx - size // 2)
    y = max(0, cy - size // 2)
    if x + size > w:
        x = w - size
    if y + size > h:
        y = h - size

    return img[y:y + size, x:x + size]


def procesar_imagen(ruta_in, ruta_out, size, fmt, quality, face_cascade, face_dnn, verbose):
    """Procesa una imagen: detecta rostro, recorta, redimensiona y guarda."""
    try:
        img = cv2.imread(str(ruta_in))
        if img is None:
            return False, f"No se pudo leer: {ruta_in.name}"

        img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

        # Detectar rostro con DNN primero, luego Haar como fallback
        face_box = None
        if face_dnn is not None:
            face_box = detectar_rostro_dnn(img, face_dnn)
        if face_box is None and face_cascade is not None:
            face_box = detectar_rostro_haar(img_gray, face_cascade)

        if face_box:
            metodo = "DNN" if (face_dnn and detectar_rostro_dnn(img, face_dnn)) else "Haar"
            if verbose:
                print(f"  • {ruta_in.name:40s} → rostro detectado ({metodo})")
        else:
            if verbose:
                print(f"  • {ruta_in.name:40s} → centrado automático")

        recortada = recorte_inteligente(img, face_box, args.margen)
        final = cv2.resize(recortada, (size, size), interpolation=cv2.INTER_LANCZOS4)

        params = []
        if fmt in ('jpg', 'jpeg'):
            params = [cv2.IMWRITE_JPEG_QUALITY, quality]
        elif fmt == 'png':
            params = [cv2.IMWRITE_PNG_COMPRESSION, 3]
        elif fmt == 'webp':
            params = [cv2.IMWRITE_WEBP_QUALITY, quality]

        cv2.imwrite(str(ruta_out), final, params)
        return True, None

    except Exception as e:
        return False, str(e)


# ─────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────
def main():
    parser = argparse.ArgumentParser(
        description="Normaliza fotos para orlas: detecta rostro, recorta cuadrado, redimensiona.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=f"""
Ejemplos:
  %(prog)s --input ./alumnos --output ./normalizadas
  %(prog)s --input ./fotos --size 800 --format png
  %(prog)s --input ./alumnos --dry-run --verbose
  %(prog)s --input ./profesores --detector dnn --quality 98
  %(prog)s --detector dnn --margen 0.4 --size 600

La primera vez que uses --detector dnn descargará automáticamente
el modelo (~20 MB) a: {DNN_MODEL_DIR}
        """
    )
    parser.add_argument('--input', '-i', default='./alumnos',
                        help='Carpeta con fotos originales (defecto: ./alumnos)')
    parser.add_argument('--output', '-o', default='',
                        help='Carpeta de salida (defecto: {input}_normalizadas)')
    parser.add_argument('--size', '-s', type=int, default=600,
                        help='Tamaño del cuadrado de salida en px (defecto: 600)')
    parser.add_argument('--format', '-f', choices=['jpg', 'png', 'webp'], default='jpg',
                        help='Formato de salida (defecto: jpg)')
    parser.add_argument('--quality', '-q', type=int, default=95,
                        help='Calidad JPEG/WebP 1-100 (defecto: 95)')
    parser.add_argument('--detector', '-d', choices=['haar', 'dnn', 'auto'], default='auto',
                        help='Detector facial (defecto: auto)')
    parser.add_argument('--margen', '-m', type=float, default=0.3,
                        help='Margen adicional alrededor del rostro 0.0-1.0 (defecto: 0.3)')
    parser.add_argument('--workers', '-w', type=int, default=4,
                        help='Número de hilos paralelos (defecto: 4)')
    parser.add_argument('--dry-run', '-n', action='store_true',
                        help='Solo mostrar lo que se haría, sin procesar')
    parser.add_argument('--verbose', '-v', action='store_true',
                        help='Mostrar información detallada')

    global args
    args = parser.parse_args()

    input_path = Path(args.input).resolve()
    if not input_path.exists():
        print(f"❌ La carpeta de origen no existe: {input_path}")
        sys.exit(1)

    output_path = Path(args.output).resolve() if args.output else \
        input_path.parent / f"{input_path.stem}_normalizadas"

    fmt = args.format.lower().replace('jpg', 'jpeg')

    # ── Reunir archivos ──────────────────────────────
    files = sorted([f for f in input_path.iterdir() if f.suffix.lower() in EXTENSIONES])
    if not files:
        print(f"⚠  No se encontraron imágenes en: {input_path}")
        sys.exit(0)

    # ── Inicializar detectores ───────────────────────
    face_cascade = None
    face_dnn = None

    if args.detector in ('haar', 'auto'):
        cascade_path = cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
        if os.path.exists(cascade_path):
            face_cascade = cv2.CascadeClassifier(cascade_path)
            if args.verbose:
                print(f"  ✓ Haar cascade frontalface cargado")
        else:
            print(f"  ⚠  No se encontró Haar cascade: {cascade_path}")

    if args.detector in ('dnn', 'auto'):
        if DNN_MODEL_PATH.exists() or descargar_modelo_dnn(args.verbose):
            try:
                face_dnn = cv2.dnn.readNetFromTensorflow(str(DNN_MODEL_PATH), str(DNN_CONFIG_PATH))
                if args.verbose:
                    print(f"  ✓ DNN detector cargado (SSD + ResNet)")
            except Exception as e:
                print(f"  ⚠  Error cargando modelo DNN: {e}")

    if face_cascade is None and face_dnn is None:
        print("  ⚠  No hay detector facial disponible. Se usará centrado automático.")
        print("     Prueba: pip install --upgrade opencv-python opencv-contrib-python")

    # ── Mostrar resumen ──────────────────────────────
    detector_nombre = "DNN + Haar" if (face_dnn and face_cascade) else \
                      "DNN (SSD+ResNet)" if face_dnn else \
                      "Haar Cascade" if face_cascade else \
                      "Ninguno (centrado automático)"

    print(f"\n{'='*56}")
    print(f"  NORMALIZADOR DE FOTOS (OpenCV)")
    print(f"{'='*56}")
    print(f"  Origen:     {input_path}")
    print(f"  Destino:    {output_path}")
    print(f"  Tamaño:     {args.size}×{args.size} px")
    print(f"  Formato:    {fmt.upper()}")
    if fmt != 'png':
        print(f"  Calidad:    {args.quality}%")
    print(f"  Detector:   {detector_nombre}")
    print(f"  Margen:     {args.margen:.0%}")
    print(f"  Archivos:   {len(files)}")
    print(f"  Hilos:      {args.workers}")
    print()

    if args.dry_run:
        print("═══ MODO VISTA PREVIA (dry-run) ═══")
        print()
        for f in files:
            out_name = f.stem + '.' + fmt.replace('jpeg', 'jpg')
            extra = f"  [{f.stat().st_size / 1024:.0f} KB]"
            print(f"  • {f.name:40s} → {out_name:40s} {extra}")
        print(f"\nDestino: {output_path}")
        sys.exit(0)

    # ── Crear directorio de salida ───────────────────
    output_path.mkdir(parents=True, exist_ok=True)

    # ── Procesar ─────────────────────────────────────
    ok = 0
    errors = 0
    total = len(files)

    def procesar_una(f):
        out_name = f.stem + '.' + fmt.replace('jpeg', 'jpg')
        out_file = output_path / out_name
        return procesar_imagen(f, out_file, args.size, fmt, args.quality,
                               face_cascade, face_dnn, args.verbose)

    with ThreadPoolExecutor(max_workers=args.workers) as executor:
        futuros = {executor.submit(procesar_una, f): f for f in files}
        for i, futuro in enumerate(as_completed(futuros), 1):
            f = futuros[futuro]
            exito, error = futuro.result()
            if exito:
                ok += 1
            else:
                errors += 1
                print(f"\n  ❌ {f.name}: {error}")
            pct = int(i / total * 100)
            barra = '█' * (pct // 5) + '░' * (20 - pct // 5)
            print(f"\r  Progreso: [{barra}] {i}/{total} ({pct}%)", end='', flush=True)
    print()

    # ── Resumen ──────────────────────────────────────
    print(f"\n{'='*56}")
    print(f"  PROCESO COMPLETADO")
    print(f"{'='*56}")
    print(f"  ✅ Correctas: {ok}" if ok > 0 else f"  ✅ Correctas: 0")
    if errors:
        print(f"  ❌ Errores:   {errors}")
    print(f"  📁 Destino:   {output_path}")
    print()

    if ok > 0:
        total_bytes = sum(f.stat().st_size for f in output_path.iterdir() if f.is_file())
        if total_bytes > 1024 * 1024:
            print(f"  Tamaño total: {total_bytes / 1024 / 1024:.1f} MB")
        else:
            print(f"  Tamaño total: {total_bytes / 1024:.0f} KB")
        print(f"  Promedio:    {total_bytes / ok / 1024:.0f} KB por foto")


if __name__ == '__main__':
    main()
