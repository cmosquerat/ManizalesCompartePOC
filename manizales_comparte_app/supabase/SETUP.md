# Panel de comerciantes + Supabase — Puesta en marcha

Catálogo de aliados (negocios, productos, promociones y canjes) conectado a
Supabase, con panel de comerciante real (login + CRUD + fotos) y la app turista
leyendo en vivo. **Modelo:** 1 Fermín = $1.000 COP; el comercio absorbe el
descuento (no hay reembolso).

## 1. Crear el esquema (una sola vez)

1. Abre el proyecto en Supabase → **SQL Editor** → **New query**.
2. Pega TODO el contenido de [`schema.sql`](./schema.sql) y dale **Run**.
   - Crea tablas, índices, políticas **RLS**, el bucket de Storage
     `business-media` (público) y los **datos semilla** (6 negocios reales con
     productos/promos, Fermines ya reescalados a 1F = $1.000).
   - Es idempotente: puedes re-ejecutarlo sin romper nada.

## 2. Activar el registro de comerciantes (demo)

Por defecto Supabase exige **confirmación de correo**, lo que bloquea el
flujo registrarse → entrar de inmediato. Para la demo:

- Supabase → **Authentication → Sign In / Providers → Email** →
  **desactiva "Confirm email"** → Save.

(En producción déjalo activo; la app ya muestra el mensaje "confirma tu correo".)

## 3. Vincular un negocio semilla a tu cuenta (opcional)

Los 6 negocios semilla quedan sin dueño (demo de la Fundación). Para **editar
uno desde el panel**:

1. Entra a la app → Perfil → "Modo comerciante" → **regístrate** con tu correo.
2. En el SQL Editor corre (cambiando el correo):
   ```sql
   update public.businesses
   set owner_id = (select id from auth.users where email = 'tucorreo@ejemplo.com')
   where id = 'biz_sombrerero';
   ```
3. Vuelve a entrar al panel: ya aparece "El Sombrerero" en *mis negocios*.

> Alternativa sin SQL: en el panel usa **"Registrar mi negocio"** y creas uno
> nuevo desde cero (queda con tu cuenta como dueña automáticamente).

## 4. Correr la app

```bash
flutter pub get
flutter run -d chrome
```

Credenciales: van por defecto en `lib/config/supabase_config.dart`. Para apuntar
a otro proyecto sin tocar código:

```bash
flutter run -d chrome ^
  --dart-define=SUPABASE_URL=https://XXXX.supabase.co ^
  --dart-define=SUPABASE_ANON_KEY=sb_publishable_XXX
```

## Cómo está cableado

- `lib/config/supabase_config.dart` — URL + publishable key + nombre del bucket.
- `lib/services/catalog_repository.dart` — lectura/escritura y subida de fotos.
- `lib/providers/app_state.dart` — fuente única: carga el catálogo (fallback a
  datos semilla si Supabase no responde), maneja la sesión del comerciante y el CRUD.
- `lib/screens/business_mode/` — panel: login, gate, formulario de negocio,
  editores de producto/promoción (con foto), tabs de canje y reportes.
- App turista (`map_screen`, `business_detail_screen`) lee de `AppState`, no de mock.

## Qué falta / siguiente fase

- Las **acciones sociales** (Cuidarte, Imaginarte…) siguen gestionadas por la
  Fundación (mock), no por comerciantes. Un panel para ellas es fase siguiente.
- Wallet/Fermines del turista sigue en memoria (no se migró a Supabase).
- QR real de canje (hoy el "Validar canje" simula el escaneo pero ya **persiste**
  el canje en Supabase).
