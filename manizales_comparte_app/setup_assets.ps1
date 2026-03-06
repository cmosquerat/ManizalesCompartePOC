# Script para copiar y renombrar assets al proyecto Flutter
# Ejecutar desde la carpeta manizales_comparte_app/

# Crear directorios
New-Item -ItemType Directory -Force -Path "assets/images"
New-Item -ItemType Directory -Force -Path "assets/fotos"

# Copiar SVGs
Copy-Item "../Logo_positivo.svg" "assets/images/"
Copy-Item "../logo_negativo.svg" "assets/images/"
Copy-Item "../colobri_positivo.svg" "assets/images/"
Copy-Item "../nevado_positivo.svg" "assets/images/"
Copy-Item "../chiprepositivo.svg" "assets/images/"
Copy-Item "../letras_positivo.svg" "assets/images/"

# Copiar y renombrar fotos (nombres seguros para web, sin tildes ni espacios)
$renameMap = @{
    "NIÑA INDIGENA EMBERA (1).jpg"          = "nina_indigena_embera.jpg"
    "ATARDECER EN LA CUMBRE.jpg"            = "atardecer_en_la_cumbre.jpg"
    "IGLESIA DE CHIPRE.jpg"                 = "iglesia_de_chipre.jpg"
    "TORRE DE CHIPRE.jpg"                   = "torre_de_chipre.jpg"
    "MONTAÑA MAGICA.jpg"                    = "montana_magica.jpg"
    "PLAZA DE TOROS.jpg"                    = "plaza_de_toros.jpg"
    "FERIA DE MANIZALES.jpg"                = "feria_de_manizales.jpg"
    "REPUBLICANO Y MELANCOLICO (1).jpg"     = "republicano_y_melancolico.jpg"
    "VISTA DESDE LAS NUBES.jpg"             = "vista_desde_las_nubes.jpg"
    "CASTILLO DE OSAKA.jpg"                 = "castillo_de_osaka.jpg"
    "CATEDRAL BASILICA DE MANIZALES.jpg"    = "catedral_basilica_de_manizales.jpg"
    "PASADO, PRESENTE Y FUTURO.jpg"         = "pasado_presente_y_futuro.jpg"
    "ORO ROJO.jpg"                          = "oro_rojo.jpg"
    "SIEMPRE INMACULADA.jpg"                = "siempre_inmaculada.jpg"
    "PRIMER CABLE.jpg"                      = "primer_cable.jpg"
    "EL ARRIERO.jpg"                        = "el_arriero.jpg"
}

foreach ($entry in $renameMap.GetEnumerator()) {
    $src = "../fotos/$($entry.Key)"
    $dst = "assets/fotos/$($entry.Value)"
    if (Test-Path $src) {
        Copy-Item $src $dst
        Write-Host "OK: $($entry.Value)"
    } else {
        Write-Host "SKIP: $($entry.Key) no encontrado"
    }
}

Write-Host ""
Write-Host "Assets copiados correctamente!"
Write-Host "Ahora ejecuta: flutter pub get"
