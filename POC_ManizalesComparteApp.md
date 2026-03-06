# Manizales Comparte App — Prueba de Concepto (POC)

> **Plataforma:** Flutter (iOS & Android)
> **Versión del documento:** 1.0
> **Fecha:** Marzo 2026
> **Estado:** POC — Fase de validación

---

## 1. Visión del producto

**Manizales Comparte App** es la extensión digital de la **Fundación Manizales Comparte**. Su propósito es triple:

1. **Monetizar** la experiencia turística y cultural de Manizales de forma sostenible.
2. **Captar fondos** para causas benéficas (Fundación Pequeño Corazón, Ecosistema Social).
3. **Gamificar** la exploración de la ciudad a través de una moneda virtual propia: **los Fermines**.

La app convierte al visitante y al ciudadano en agente activo: recorre la ciudad, descubre las tapas artísticas, consume en aliados, participa en acciones sociales y acumula Fermines que se traducen en descuentos reales y en impacto social.

---

## 2. Identidad de marca

| Elemento | Valor |
|---|---|
| **Colores primarios** | `#E6323C` (rojo) · `#FFD122` (amarillo) · `#88BE4C` (verde) · `#52B9AA` (turquesa) · `#98999C` (gris) |
| **Tipografías** | **Metropolis** (UI / cuerpo) · **Sailor** (display / títulos) |
| **Logo** | `Logo_positivo.svg` (fondo claro) · `logo_negativo.svg` (fondo oscuro) |
| **Elementos gráficos** | Colibrí (`colobri_positivo.svg`) · Nevado (`nevado_positivo.svg`) · Chipre (`chiprepositivo.svg`) · Letras (`letras_positivo.svg`) |

---

## 3. Los Fermines — Moneda virtual

### 3.1 Qué son

Los **Fermines** son la moneda virtual del ecosistema Manizales Comparte. No tienen valor de cambio real, pero funcionan como puntos de fidelización canjeables por descuentos y beneficios en la red de aliados.

### 3.2 Cómo se obtienen

| Canal | Descripción | Fermines estimados |
|---|---|---|
| **Recarga directa** | El usuario compra Fermines con dinero real (pasarela de pagos). Cada compra destina un % a causas benéficas. | Según monto recargado |
| **Caza de Tapas** (gamificación) | Al estilo Pokémon GO: el usuario se acerca físicamente a una tapa artística, escanea el QR o la detecta por geolocalización y la "captura" en su colección digital. | 5–50 por tapa |
| **Acciones benéficas** | Participar en jornadas de voluntariado del Ecosistema Social (Cuidarte, Imaginarte, Salvarte, Desarmarte). | 20–100 por acción |
| **Referidos** | Invitar amigos a la app. | 10 por referido activo |
| **Retos y logros** | Completar rutas, visitar todas las estaciones de un sector, repetir un tour. | Variable |

### 3.3 Cómo se gastan

| Uso | Descripción |
|---|---|
| **Descuentos en tours** | Aplicar Fermines como descuento parcial en FraileTour, CoffeTour, Colonizadores, Arrieros, Fundadores. |
| **Descuentos en restaurantes aliados** | Menús especiales, platos del día o porcentaje de descuento en establecimientos asociados. |
| **Descuentos en hoteles y servicios turísticos** | Noches, upgrades o experiencias cortesía en hoteles y operadores aliados. |
| **Tienda del Arte** | Canjear Fermines por tapitas de colección y productos exclusivos. |
| **Donación** | Convertir Fermines en donaciones directas a la Fundación Pequeño Corazón u otras causas. |

### 3.4 Modelo económico simplificado

```
Usuario compra Fermines ($COP) 
  ├── 70% → Valor real del Fermín (respaldo para descuentos)
  ├── 20% → Fondo benéfico (Fundación Pequeño Corazón / Ecosistema Social)
  └── 10% → Operación de la plataforma
```

Los aliados (restaurantes, hoteles, tours) aceptan Fermines porque reciben tráfico cualificado y visibilidad en la app. El costo del descuento lo absorben como inversión en marketing.

---

## 4. Módulos del POC

### 4.1 Onboarding y autenticación

- Registro con email, Google o Apple.
- Perfil de usuario: nombre, foto, ciudad de origen (turista vs. local).
- Tutorial interactivo que explica los Fermines y la mecánica de tapas.

### 4.2 Mapa interactivo — Caza de Tapas

El corazón de la gamificación. Inspirado en Pokémon GO pero con las **tapas artísticas de servicios públicos** de Manizales.

**Funcionalidades:**

- Mapa en tiempo real con la ubicación de las 150+ tapas artísticas.
- Geofencing: al acercarse a una tapa (~15 metros), se activa la posibilidad de "capturarla".
- Captura mediante escaneo de QR o proximidad GPS.
- Cada tapa capturada muestra:
  - Nombre de la obra y artista.
  - Historia y contexto cultural.
  - Audio-guía.
  - Galería de imágenes.
- Colección personal: el usuario ve qué tapas ha descubierto y cuáles le faltan.
- Rutas sugeridas por sector:
  - **Chipre:** Colonizadores, Torre de Chipre, Iglesia de Chipre, Atardecer en la cumbre.
  - **Centro Histórico:** Catedral, Plaza de Bolívar, Castillo de Osaka, Republicano y melancólico.
  - **Avenida Santander:** Cementerio San Esteban, Oso de anteojos, Mariposas, Yarumos.
  - **Milán:** El buey, Aves, Siempre campeones.
- Logros y badges al completar sectores.

### 4.3 Experiencias turísticas (Tours)

Catálogo de tours con reserva y pago (parcial o total con Fermines):

| Tour | Duración | Precio base | Incluye |
|---|---|---|---|
| **FraileTour** | ~7 horas | $215.000 COP | Transporte, guía, permisos, refrigerio, seguro |
| **CoffeTour** | ~6 horas | $195.000 COP | Recorrido en finca, degustaciones, almuerzo, guía, seguro |
| **Colonizadores** | ~3 horas | $130.000 COP | Guía, experiencias interactivas, actividad artística, seguro |
| **Los Arrieros** | ~5 horas | $350.000 COP | Tapas criollas, degustaciones, música, guías, seguro |
| **Los Fundadores** | ~4 horas | $230.000 COP | Guía especializado, teatro, experiencias vivenciales, seguro |

**Funcionalidades:**

- Detalle de cada tour con fotos, descripción e incluidos.
- Calendario de disponibilidad.
- Reserva y pago (pasarela COP + opción de aplicar Fermines).
- Confirmación y recordatorio push.
- Valoración y reseña post-tour.

### 4.4 Red de aliados (Restaurantes, Hoteles, Servicios)

- Directorio de aliados con filtros (categoría, distancia, descuento disponible).
- Ficha del aliado: fotos, menú/servicios, ubicación en mapa, porcentaje de descuento con Fermines.
- QR de canje: el usuario presenta un QR dinámico en el establecimiento para aplicar su descuento.
- Sistema de validación para el comercio aliado (app o portal web).

### 4.5 Ecosistema Social

Sección dedicada a las iniciativas sociales de la fundación:

| Programa | Descripción |
|---|---|
| **Cuidarte** | Embellecimiento colaborativo de espacios públicos con voluntariado y kit especial. |
| **Imaginarte** | Convocatoria artística para llevar historias a las tapas de alcantarillado. |
| **Salvarte** | Acompañamiento y atención especializada (Fundación Pequeño Corazón). |
| **Desarmarte** | Entrega voluntaria de armas a cambio de beneficios para familias. |

**Funcionalidades:**

- Calendario de actividades de voluntariado.
- Inscripción directa desde la app.
- Registro de participación y asignación automática de Fermines.
- Contador de impacto: "Con tu aporte hemos ayudado a X corazones".

### 4.6 Tienda del Arte

- Catálogo de tapitas de colección y productos exclusivos.
- Compra con COP, Fermines o mixto.
- Carrito, checkout y seguimiento de envío.
- Productos destacados: Tapita Catedral, Tapita Chipre, Tapita Once Caldas, Tapita Colonizadores, Tapita Recinto del Pensamiento ($22.000 COP c/u).

### 4.7 Wallet de Fermines

- Balance actual de Fermines.
- Historial de transacciones (ganados, gastados, donados).
- Recarga con pasarela de pagos (PSE, tarjetas, Nequi, Daviplata).
- Transferencia de Fermines entre usuarios.
- Resumen de impacto social generado.

---

## 5. Arquitectura técnica (POC)

### 5.1 Stack tecnológico

| Capa | Tecnología |
|---|---|
| **Frontend** | Flutter (Dart) — iOS y Android desde un solo codebase |
| **Estado** | Riverpod o Bloc |
| **Backend** | Firebase (Auth, Firestore, Cloud Functions, Storage) |
| **Mapas** | Google Maps SDK para Flutter + geofencing |
| **Pagos** | Wompi o MercadoPago (pasarela colombiana) |
| **Notificaciones** | Firebase Cloud Messaging (FCM) |
| **Analytics** | Firebase Analytics + Crashlytics |
| **QR** | `mobile_scanner` (lectura) + `qr_flutter` (generación) |

### 5.2 Arquitectura de alto nivel

```
┌─────────────────────────────────────────────┐
│              Flutter App (Dart)              │
│  ┌─────────┐ ┌──────────┐ ┌──────────────┐  │
│  │  Mapas  │ │  Wallet  │ │  Tours/Shop  │  │
│  │  + GPS  │ │ Fermines │ │  + Aliados   │  │
│  └────┬────┘ └────┬─────┘ └──────┬───────┘  │
│       │           │              │           │
│  ┌────┴───────────┴──────────────┴────────┐  │
│  │         Capa de Repositorios           │  │
│  └────────────────┬───────────────────────┘  │
└───────────────────┼──────────────────────────┘
                    │
        ┌───────────┴───────────┐
        │   Firebase Backend    │
        │  ┌─────────────────┐  │
        │  │   Firestore     │  │
        │  │   (datos/tapas/ │  │
        │  │    users/txns)  │  │
        │  ├─────────────────┤  │
        │  │  Cloud Functions│  │
        │  │  (lógica Fermín │  │
        │  │   + validación) │  │
        │  ├─────────────────┤  │
        │  │  Auth + Storage │  │
        │  └─────────────────┘  │
        │                       │
        │  ┌─────────────────┐  │
        │  │ Pasarela Pagos  │  │
        │  │ (Wompi/MP)      │  │
        │  └─────────────────┘  │
        └───────────────────────┘
```

### 5.3 Modelo de datos principal (Firestore)

```
users/
  {uid}/
    - displayName, email, photoUrl, city, role
    - ferminesBalance: number
    - capturedTapas: [tapaId, ...]
    - createdAt, lastLogin

tapas/
  {tapaId}/
    - name: "Catedral"
    - artist: "Luis Fernando Echeverri"
    - location: GeoPoint
    - address: "Cra. 22 #24-13"
    - sector: "Centro Histórico"
    - imageUrls: [...]
    - audioGuideUrl: string
    - history: string
    - ferminesReward: 20
    - qrCode: string

tours/
  {tourId}/
    - name, description, price, duration
    - includes: [...]
    - imageUrls: [...]
    - availableDates: [...]
    - maxCapacity: number

allies/
  {allyId}/
    - name, category, description
    - location: GeoPoint
    - address, phone, website
    - discountPercent: number
    - imageUrls: [...]

transactions/
  {txnId}/
    - userId, type (earn|spend|recharge|donate)
    - amount: number
    - source: string (tapa_capture|volunteer|purchase|tour|ally)
    - referenceId: string
    - timestamp

socialActions/
  {actionId}/
    - program: "cuidarte" | "imaginarte" | "salvarte" | "desarmarte"
    - title, description, date, location
    - ferminesReward: number
    - participants: [uid, ...]
```

---

## 6. Flujos principales del POC

### 6.1 Caza de Tapas (flujo core)

```
1. Usuario abre la app → Ve el mapa con tapas cercanas (pins)
2. Camina hacia una tapa → Pin se activa (geofence ~15m)
3. Escanea QR de la tapa física O confirma proximidad GPS
4. App muestra animación de "Tapa capturada" 🎉
5. Se despliega ficha: obra, artista, historia, audio-guía
6. Fermines acreditados al wallet (+20)
7. Tapa se marca como capturada en la colección
8. Si completó un sector → Badge desbloqueado + bonus de Fermines
```

### 6.2 Recarga y uso de Fermines

```
1. Usuario va a Wallet → Toca "Recargar"
2. Selecciona monto ($10.000 = 100 Fermines, $50.000 = 550 Fermines...)
3. Paga por pasarela (PSE/tarjeta/Nequi)
4. Fermines acreditados al instante
5. En un restaurante aliado:
   a. Abre "Mis descuentos" → Selecciona aliado
   b. Genera QR de canje con X Fermines
   c. Mesero escanea → Descuento aplicado
   d. Fermines debitados del wallet
```

### 6.3 Reserva de tour

```
1. Usuario navega catálogo de tours
2. Selecciona tour → Ve detalle, fechas, precio
3. Toca "Reservar" → Selecciona fecha y personas
4. Checkout: elige pagar 100% COP, 100% Fermines o mixto
5. Pago procesado → Confirmación + push + email
6. Día del tour → Check-in con QR en la app
7. Post-tour → Invitación a reseña + Fermines bonus
```

---

## 7. Pantallas clave del POC (wireframes descriptivos)

| # | Pantalla | Descripción |
|---|---|---|
| 1 | **Splash / Onboarding** | Logo animado del colibrí + slides explicativos de Fermines y tapas. |
| 2 | **Home** | Mapa como elemento central, balance de Fermines arriba, barra de navegación inferior (Mapa, Tours, Aliados, Social, Perfil). |
| 3 | **Mapa de Tapas** | Google Maps con pins personalizados (tapa icono). Filtro por sector. Indicador de tapas cercanas. |
| 4 | **Ficha de Tapa** | Bottom sheet con imagen de la obra, nombre, artista, audio-guía, historia. Botón "Capturar". |
| 5 | **Mi Colección** | Grid de tapitas capturadas (coloridas) y por capturar (silueta gris). Progreso por sector. |
| 6 | **Catálogo de Tours** | Cards horizontales con foto, nombre, precio y duración. Filtro por tipo. |
| 7 | **Detalle de Tour** | Hero image, descripción, incluye, precio, selector de fecha, botón reservar. |
| 8 | **Directorio de Aliados** | Lista con filtros. Card: foto, nombre, categoría, descuento %, distancia. |
| 9 | **Wallet** | Balance prominente, botones Recargar / Donar / Historial. Gráfico de Fermines ganados vs. gastados. |
| 10 | **Ecosistema Social** | Cards de programas (Cuidarte, Imaginarte, Salvarte, Desarmarte). Próximas actividades. Impacto acumulado. |
| 11 | **Tienda del Arte** | Grid de productos con foto, nombre, precio COP y precio Fermines. |
| 12 | **Perfil** | Foto, stats (tapas capturadas, tours realizados, Fermines donados), badges, configuración. |

---

## 8. Gamificación y retención

### 8.1 Sistema de niveles

| Nivel | Nombre | Requisito | Beneficio |
|---|---|---|---|
| 1 | **Caminante** | Crear cuenta | Acceso básico |
| 2 | **Explorador** | 10 tapas capturadas | 5% extra en recargas |
| 3 | **Arriero** | 30 tapas + 1 tour | 10% extra + badge exclusivo |
| 4 | **Colonizador** | 80 tapas + 3 tours + 1 acción social | 15% extra + acceso a eventos VIP |
| 5 | **Manjolero de Corazón** | 150 tapas + 5 tours + 3 acciones sociales | 20% extra + tapita física de regalo |

### 8.2 Logros (Badges)

- **Primer paso:** Captura tu primera tapa.
- **Ruta de Chipre:** Todas las tapas del sector Chipre.
- **Centro Histórico completo:** Todas las tapas del centro.
- **Avenida del Arte:** Todas las tapas de la Av. Santander.
- **Corazón solidario:** Participa en una acción social.
- **Cafetero de alma:** Completa el CoffeTour.
- **Guardián del páramo:** Completa el FraileTour.
- **Coleccionista:** Compra 3+ tapitas en la Tienda del Arte.
- **Embajador:** Refiere 5+ amigos.

### 8.3 Eventos especiales

- **Ferias de Manizales:** Tapas temporales con doble recompensa.
- **Retos semanales:** "Captura 5 tapas esta semana y gana 100 Fermines bonus".
- **Temporadas:** Temáticas alineadas con fechas clave de la ciudad.

---

## 9. Alianzas estratégicas

### 9.1 Modelo para restaurantes

- El restaurante ofrece un descuento (ej. 10–20%) a usuarios que paguen con Fermines.
- A cambio, recibe visibilidad premium en la app (listing destacado, push notifications, banner).
- El costo del descuento lo absorbe el restaurante como inversión en marketing.
- Reportes mensuales de tráfico y conversiones generadas.

### 9.2 Modelo para hoteles y operadores turísticos

- Ofrecen beneficios (upgrade, late checkout, experiencia adicional) canjeables con Fermines.
- Paquetes combinados: hotel + tour + tapas con precio especial en Fermines.
- Co-branding en la app y en material físico del hotel.

### 9.3 Modelo para la Fundación

- Cada recarga destina un 20% al fondo benéfico.
- Los usuarios pueden donar Fermines directamente.
- Las acciones de voluntariado generan Fermines → incentivo para participar.
- Transparencia: dashboard público de fondos recaudados y destino.

---

## 10. Alcance del POC (MVP)

### Incluido en el POC

- [x] Autenticación (email + Google).
- [x] Mapa con 10–15 tapas de prueba (sector Centro Histórico y Chipre).
- [x] Captura de tapas por QR + geolocalización.
- [x] Ficha de tapa con info, imagen y audio.
- [x] Wallet de Fermines (balance + historial).
- [x] Recarga simulada de Fermines (sin pasarela real).
- [x] Catálogo de 2–3 tours (sin reserva real).
- [x] Directorio de 3–5 aliados de prueba.
- [x] Colección de tapas del usuario.
- [x] Perfil básico con estadísticas.

### Fuera del POC (fases posteriores)

- [ ] Pasarela de pagos real (Wompi / MercadoPago).
- [ ] Reserva y pago de tours funcional.
- [ ] Tienda del Arte con e-commerce completo.
- [ ] QR de canje en aliados (validación bidireccional).
- [ ] Panel administrativo para aliados.
- [ ] Ecosistema Social con inscripción a voluntariados.
- [ ] Sistema de niveles y badges completo.
- [ ] Notificaciones push geolocalizadas.
- [ ] Eventos temporales y retos semanales.
- [ ] Modo offline para el mapa.
- [ ] Soporte multiidioma (español + inglés).
- [ ] Analytics avanzado y dashboards de impacto.

---

## 11. Estructura del proyecto Flutter

```
manizales_comparte_app/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── config/
│   │   ├── theme.dart              # Colores (#E6323C, #FFD122...), tipografías
│   │   ├── routes.dart
│   │   └── constants.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── map/                    # Mapa + caza de tapas
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── tapas/                  # Colección + fichas
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── tours/                  # Catálogo + detalle
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── allies/                 # Directorio de aliados
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── wallet/                 # Fermines
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── social/                 # Ecosistema Social
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── shop/                   # Tienda del Arte
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   └── profile/
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   ├── shared/
│   │   ├── widgets/
│   │   ├── models/
│   │   ├── services/
│   │   └── utils/
│   └── l10n/                       # Localización
├── assets/
│   ├── images/
│   │   ├── logo_positivo.svg
│   │   ├── logo_negativo.svg
│   │   ├── colibri_positivo.svg
│   │   ├── nevado_positivo.svg
│   │   └── chipre_positivo.svg
│   ├── audio/                      # Audio-guías de tapas
│   ├── fonts/
│   │   ├── Metropolis/
│   │   └── Sailor/
│   └── data/
│       └── tapas_seed.json         # Datos semilla de tapas
├── test/
├── pubspec.yaml
└── README.md
```

---

## 12. Dependencias clave (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.x

  # Firebase
  firebase_core: ^latest
  firebase_auth: ^latest
  cloud_firestore: ^latest
  firebase_storage: ^latest
  firebase_messaging: ^latest
  firebase_analytics: ^latest

  # Maps & Location
  google_maps_flutter: ^latest
  geolocator: ^latest
  geocoding: ^latest

  # QR
  mobile_scanner: ^latest
  qr_flutter: ^latest

  # UI
  flutter_svg: ^latest
  cached_network_image: ^latest
  shimmer: ^latest
  lottie: ^latest

  # Navigation
  go_router: ^latest

  # Storage
  shared_preferences: ^latest
  hive: ^latest

  # Networking
  dio: ^latest

  # Utils
  intl: ^latest
  url_launcher: ^latest
  share_plus: ^latest
```

---

## 13. Métricas de éxito del POC

| Métrica | Objetivo |
|---|---|
| Tapas capturadas por sesión | >= 3 en promedio |
| Tiempo promedio en app | >= 8 minutos |
| Tasa de retorno (7 días) | >= 30% |
| Fermines recargados (simulado) | >= 50% de usuarios prueban la recarga |
| NPS de testers | >= 40 |
| Tours consultados | >= 2 por usuario |
| Bugs críticos | 0 |

---

## 14. Cronograma estimado del POC

| Semana | Actividad |
|---|---|
| **1–2** | Setup del proyecto Flutter + Firebase. Autenticación. Tema y navegación base. |
| **3–4** | Mapa interactivo + geofencing. Seed de tapas (10–15). Captura por QR/GPS. |
| **5–6** | Ficha de tapa (info, imagen, audio). Colección del usuario. Wallet de Fermines (balance + historial). |
| **7–8** | Catálogo de tours + detalle. Directorio de aliados. Perfil con estadísticas. |
| **9** | Pulido de UI/UX. Testing interno. |
| **10** | Testing con usuarios reales (5–10 personas). Iteración. Demo. |

---

## 15. Riesgos y mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Precisión GPS insuficiente para detectar tapas | Media | Alto | Combinar geofencing con escaneo QR como fallback. Radio de 15m. |
| Baja adopción de Fermines | Media | Alto | Onboarding con Fermines de bienvenida (50 gratis). Descuentos atractivos desde el inicio. |
| Pocos aliados al lanzamiento | Alta | Medio | Empezar con aliados cercanos a la ruta de tapas. Ofrecer primeros 3 meses sin costo. |
| Fraude en captura de tapas | Baja | Medio | Validación doble (GPS + QR). Cooldown entre capturas. Detección de patrones anómalos. |
| Rendimiento del mapa con muchos pins | Baja | Medio | Clustering de marcadores. Carga por viewport. |

---

## 16. Tapas incluidas en el POC (seed data)

Las siguientes tapas se incluirán como datos semilla para la prueba de concepto:

| # | Obra | Artista | Ubicación | Sector |
|---|---|---|---|---|
| 1 | Niña indígena embera | Luis Guillermo Vallejo Vargas | Monumento a los Colonizadores | Chipre |
| 2 | Atardecer en la cumbre | Oscar Álvarez Echeverry | Av. Doce de Octubre | Chipre |
| 3 | Torre de Chipre | Daniel Winogrand Yontef | Mirador Torre de Chipre | Chipre |
| 4 | Catedral | Luis Fernando Echeverri | Cra. 22 #24-13 | Centro Histórico |
| 5 | Castillo de Osaka | Dpto. Construcción de Osaka | Plaza de Bolívar | Centro Histórico |
| 6 | Feria de Manizales | Carlos Alberto Valencia | Cra 23 con Cll 15 | Centro Histórico |
| 7 | Republicano y melancólico | Juan Manuel Salgado | Alcaldía de Manizales | Centro Histórico |
| 8 | Pasado, presente y futuro | Daniel Wegner | Centro Cultural Banco de la República | Centro Histórico |
| 9 | Primer Cable | Luz Elena Restrepo | Cra. 23 con calle 32 | Fundadores |
| 10 | Barranquero coronado | Amalia Low Nakayama | Cra. 23 con calle 33 | Fundadores |
| 11 | Oso de anteojos | Luis Fernando Echeverri | Av. Santander con calle 50 | Av. Santander |
| 12 | Reserva Natural Río Blanco | Muralista SEPC | Av. Santander con calle 55 | Av. Santander |
| 13 | Cien años Cable Aéreo | Xilonen Castaño | Parque de Bolívar, Villamaría | Villamaría |

---

*Documento generado para la Fundación Manizales Comparte. Todos los derechos reservados.*
*"De tapa en tapa, Manizales te cuenta su historia"*
