# Manizales Comparte — Imagen de Marca

> Guía rápida de identidad visual para el desarrollo de **Manizales Comparte App**.

---

## Logo

El logo de Manizales Comparte combina el colibrí, el nevado, las letras de la marca y el mirador de Chipre en una composición que representa naturaleza, cultura y ciudad.

| Variante | Archivo | Uso |
|---|---|---|
| Positivo (fondo claro) | `Logo_positivo.svg` | Fondos blancos o claros |
| Negativo (fondo oscuro) | `logo_negativo.svg` | Fondos oscuros, fotos, degradados |

### Elementos del logo

| Elemento | Archivo | Descripción |
|---|---|---|
| Colibrí | `colobri_positivo.svg` | Símbolo de biodiversidad y agilidad. Puede usarse solo como ícono de la app. |
| Nevado | `nevado_positivo.svg` | Representación del Nevado del Ruiz, identidad del paisaje caldense. |
| Chipre | `chiprepositivo.svg` | Mirador y torre de Chipre, punto icónico de la ciudad. |
| Letras | `letras_positivo.svg` | Logotipo tipográfico "Manizales Comparte". |

---

## Paleta de colores

Cinco colores institucionales extraídos del manual de identidad:

| Color | HEX | Muestra | Uso sugerido en la app |
|---|---|---|---|
| Gris | `#98999C` | ![#98999C](https://via.placeholder.com/20/98999C/98999C) | Textos secundarios, bordes, fondos neutros |
| Rojo | `#E6323C` | ![#E6323C](https://via.placeholder.com/20/E6323C/E6323C) | Acciones principales, alertas, botón CTA, acento primario |
| Amarillo | `#FFD122` | ![#FFD122](https://via.placeholder.com/20/FFD122/FFD122) | Fermines (moneda virtual), highlights, badges, estrellas |
| Verde | `#88BE4C` | ![#88BE4C](https://via.placeholder.com/20/88BE4C/88BE4C) | Éxito, confirmaciones, Ecosistema Social, naturaleza |
| Turquesa | `#52B9AA` | ![#52B9AA](https://via.placeholder.com/20/52B9AA/52B9AA) | Enlaces, información, mapas, tours, elementos secundarios |

### Implementación en Flutter (theme.dart)

```dart
class AppColors {
  static const Color gris      = Color(0xFF98999C);
  static const Color rojo      = Color(0xFFE6323C);
  static const Color amarillo  = Color(0xFFFFD122);
  static const Color verde     = Color(0xFF88BE4C);
  static const Color turquesa  = Color(0xFF52B9AA);

  static const Color blanco    = Color(0xFFFFFFFF);
  static const Color negro     = Color(0xFF1D1D1B);
}
```

---

## Tipografías

Dos familias tipográficas complementarias:

| Fuente | Estilo | Uso en la app |
|---|---|---|
| **Metropolis** | Sans-serif geométrica, moderna | Cuerpo de texto, botones, navegación, UI general |
| **Sailor** | Display con personalidad, decorativa | Títulos principales, splash screen, headers de sección, nombre de tapas |

### Implementación en Flutter (pubspec.yaml)

```yaml
flutter:
  fonts:
    - family: Metropolis
      fonts:
        - asset: assets/fonts/Metropolis/Metropolis-Regular.otf
        - asset: assets/fonts/Metropolis/Metropolis-Medium.otf
          weight: 500
        - asset: assets/fonts/Metropolis/Metropolis-Bold.otf
          weight: 700
        - asset: assets/fonts/Metropolis/Metropolis-Light.otf
          weight: 300
    - family: Sailor
      fonts:
        - asset: assets/fonts/Sailor/Sailor-Regular.otf
```

### Escala tipográfica sugerida

| Elemento | Fuente | Tamaño | Peso |
|---|---|---|---|
| Título hero | Sailor | 32 sp | Regular |
| Título de sección | Sailor | 24 sp | Regular |
| Subtítulo | Metropolis | 18 sp | Bold (700) |
| Cuerpo | Metropolis | 16 sp | Regular (400) |
| Caption / etiquetas | Metropolis | 12 sp | Medium (500) |
| Botón | Metropolis | 14 sp | Bold (700) |

---

## Fotos de las tapas artísticas

Las siguientes fotografías están disponibles en la carpeta `fotos/` y corresponden a las tapas de servicios públicos intervenidas con arte en Manizales:

| Archivo | Obra | Artista |
|---|---|---|
| `NIÑA INDIGENA EMBERA (1).jpg` | Niña indígena embera | Luis Guillermo Vallejo Vargas |
| `ATARDECER EN LA CUMBRE.jpg` | Atardecer en la cumbre | Oscar Álvarez Echeverry |
| `IGLESIA DE CHIPRE.jpg` | Iglesia de Chipre | Cristian Camilo Agudelo |
| `TORRE DE CHIPRE.jpg` | Torre de Chipre | Daniel Winogrand Yontef |
| `MONTAÑA MAGICA.jpg` | Montaña mágica | Olga Lucía Hurtado |
| `PLAZA DE TOROS.jpg` | Plaza de Toros | José Miguel Valencia |
| `FERIA DE MANIZALES.jpg` | Feria de Manizales | Carlos Alberto Valencia |
| `REPUBLICANO Y MELANCOLICO (1).jpg` | Republicano y melancólico | Juan Manuel Salgado |
| `VISTA DESDE LAS NUBES.jpg` | Vista desde las nubes | Mateo Álvarez |
| `CASTILLO DE OSAKA.jpg` | Castillo de Osaka | Dpto. Construcción de Osaka |
| `CATEDRAL BASILICA DE MANIZALES.jpg` | Catedral Basílica | Luis Fernando Echeverri |
| `PASADO, PRESENTE Y FUTURO.jpg` | Pasado, presente y futuro | Daniel Wegner |
| `ORO ROJO.jpg` | Oro rojo | Alejandro Álvarez |
| `SIEMPRE INMACULADA.jpg` | Siempre inmaculada | José Ocampo |
| `PRIMER CABLE.jpg` | Primer Cable | Luz Elena Restrepo |
| `EL ARRIERO.jpg` | El arriero | Nicolás Robledo |

Cada tapa es una obra circular pintada a mano sobre las tapas de alcantarillado de Aguas de Manizales. Representan hitos históricos, culturales y naturales de la ciudad y el Paisaje Cultural Cafetero.

---

## Estructura de assets del proyecto

```
ManizalesCompartePOC/
├── Logo_positivo.svg          # Logo principal fondo claro
├── logo_negativo.svg          # Logo principal fondo oscuro
├── colobri_positivo.svg       # Colibrí (ícono de app)
├── nevado_positivo.svg        # Nevado del Ruiz
├── chiprepositivo.svg         # Mirador de Chipre
├── letras_positivo.svg        # Logotipo tipográfico
├── MANUAL DE IDENTIDAD (1).pdf
└── fotos/
    ├── ATARDECER EN LA CUMBRE.jpg
    ├── CASTILLO DE OSAKA.jpg
    ├── CATEDRAL BASILICA DE MANIZALES.jpg
    ├── EL ARRIERO.jpg
    ├── FERIA DE MANIZALES.jpg
    ├── IGLESIA DE CHIPRE.jpg
    ├── MONTAÑA MAGICA.jpg
    ├── NIÑA INDIGENA EMBERA (1).jpg
    ├── ORO ROJO.jpg
    ├── PASADO, PRESENTE Y FUTURO.jpg
    ├── PLAZA DE TOROS.jpg
    ├── PRIMER CABLE.jpg
    ├── REPUBLICANO Y MELANCOLICO (1).jpg
    ├── SIEMPRE INMACULADA.jpg
    ├── TORRE DE CHIPRE.jpg
    └── VISTA DESDE LAS NUBES.jpg
```

---

## Reglas de uso

1. **No deformar** el logo. Mantener siempre las proporciones originales.
2. **Área de protección:** dejar un margen mínimo equivalente a la altura del colibrí alrededor del logo.
3. **Fondo mínimo de contraste:** usar la versión positiva sobre fondos claros y la negativa sobre fondos oscuros.
4. **Colores institucionales:** no sustituir los colores de la paleta por tonos aproximados.
5. **Tipografías:** usar exclusivamente Metropolis y Sailor. No reemplazar por fuentes del sistema.
6. **Fotos de tapas:** siempre acreditar al artista cuando se muestren en la app o materiales.

---

*Basado en el Manual de Identidad de Manizales Comparte (2025).*
