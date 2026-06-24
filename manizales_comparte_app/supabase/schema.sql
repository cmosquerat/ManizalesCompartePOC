-- ============================================================================
-- Manizales Comparte — Esquema del catálogo de aliados (panel de comerciantes)
-- ----------------------------------------------------------------------------
-- Proyecto: osyscedwjcpgikqsloes
-- Cómo aplicar:
--   Supabase Dashboard → SQL Editor → New query → pega TODO este archivo → Run.
-- Es idempotente: puedes correrlo varias veces sin romper nada.
--
-- Modelo de negocio (1 Fermín = $1.000 COP, el comercio absorbe el descuento):
--   · El comercio publica productos/promociones y decide su precio en Fermines.
--   · La app turista (anónima) lee negocios/productos/promos activos.
--   · Al canjear, la app turista inserta una fila en `redemptions` (la venta).
--   · Cada comercio solo ve/edita lo suyo (RLS por owner_id = auth.uid()).
-- ============================================================================

create extension if not exists "pgcrypto";

-- ---------- Tipo de negocio ----------
do $$ begin
  create type business_type as enum ('cafe','restaurante','hotel','tour','tienda');
exception when duplicate_object then null; end $$;

-- ============================================================================
-- TABLAS
-- ============================================================================

create table if not exists public.businesses (
  id                       text primary key default ('biz_' || substr(replace(gen_random_uuid()::text,'-',''),1,10)),
  owner_id                 uuid references auth.users(id) on delete set null,
  nombre                   text not null,
  tipo                     business_type not null default 'cafe',
  descripcion              text not null default '',
  foto                     text,            -- URL de Storage (https) o ruta de asset (assets/...)
  logo                     text,
  lat                      double precision not null default 5.07,
  lng                      double precision not null default -75.51,
  direccion                text not null default '',
  sector                   text not null default '',
  horarios                 text not null default '',
  telefono                 text not null default '',
  instagram                text not null default '',
  rating                   int  not null default 45,   -- 0..50 (4.5 = 45)
  rating_count             int  not null default 0,
  descuento_base_fermines  int  not null default 10,   -- % de descuento base
  activo                   boolean not null default true,
  created_at               timestamptz not null default now()
);

create table if not exists public.products (
  id              text primary key default ('prod_' || substr(replace(gen_random_uuid()::text,'-',''),1,10)),
  business_id     text not null references public.businesses(id) on delete cascade,
  nombre          text not null,
  descripcion     text not null default '',
  foto            text,
  precio_cop      int  not null default 0,
  precio_fermines int  not null default 0,   -- 1F = $1.000 (default = round(precio_cop/1000))
  stock           int  not null default 0,
  destacado       boolean not null default false,
  activo          boolean not null default true,
  created_at      timestamptz not null default now()
);

create table if not exists public.promotions (
  id           text primary key default ('promo_' || substr(replace(gen_random_uuid()::text,'-',''),1,10)),
  business_id  text not null references public.businesses(id) on delete cascade,
  titulo       text not null,
  descripcion  text not null default '',
  condiciones  text not null default '',
  vigencia     text not null default '',
  foto         text,
  activa       boolean not null default true,
  created_at   timestamptz not null default now()
);

create table if not exists public.redemptions (
  id             text primary key default ('red_' || substr(replace(gen_random_uuid()::text,'-',''),1,10)),
  business_id    text not null references public.businesses(id) on delete cascade,
  product_id     text references public.products(id) on delete set null,
  user_name      text not null default 'Invitado',
  product_name   text not null default '',
  total_fermines int  not null default 0,
  total_cop      int  not null default 0,
  origen         text not null default 'turista',  -- 'turista' | 'local'
  created_at     timestamptz not null default now()
);

create index if not exists idx_products_business    on public.products(business_id);
create index if not exists idx_promotions_business  on public.promotions(business_id);
create index if not exists idx_redemptions_business on public.redemptions(business_id);
create index if not exists idx_businesses_owner     on public.businesses(owner_id);

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================

alter table public.businesses  enable row level security;
alter table public.products    enable row level security;
alter table public.promotions  enable row level security;
alter table public.redemptions enable row level security;

-- ---- businesses ----
drop policy if exists "read businesses"   on public.businesses;
drop policy if exists "insert business"   on public.businesses;
drop policy if exists "update business"   on public.businesses;
drop policy if exists "delete business"   on public.businesses;

create policy "read businesses" on public.businesses
  for select using (activo = true or owner_id = auth.uid());
create policy "insert business" on public.businesses
  for insert to authenticated with check (owner_id = auth.uid());
create policy "update business" on public.businesses
  for update to authenticated using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy "delete business" on public.businesses
  for delete to authenticated using (owner_id = auth.uid());

-- ---- products ----
drop policy if exists "read products"  on public.products;
drop policy if exists "write products" on public.products;

create policy "read products" on public.products
  for select using (
    activo = true
    or exists (select 1 from public.businesses b
               where b.id = products.business_id and b.owner_id = auth.uid())
  );
create policy "write products" on public.products
  for all to authenticated
  using (exists (select 1 from public.businesses b
                 where b.id = products.business_id and b.owner_id = auth.uid()))
  with check (exists (select 1 from public.businesses b
                      where b.id = products.business_id and b.owner_id = auth.uid()));

-- ---- promotions ----
drop policy if exists "read promotions"  on public.promotions;
drop policy if exists "write promotions" on public.promotions;

create policy "read promotions" on public.promotions
  for select using (
    activa = true
    or exists (select 1 from public.businesses b
               where b.id = promotions.business_id and b.owner_id = auth.uid())
  );
create policy "write promotions" on public.promotions
  for all to authenticated
  using (exists (select 1 from public.businesses b
                 where b.id = promotions.business_id and b.owner_id = auth.uid()))
  with check (exists (select 1 from public.businesses b
                      where b.id = promotions.business_id and b.owner_id = auth.uid()));

-- ---- redemptions ----
-- La app turista es anónima: puede INSERTAR un canje. Solo el dueño lo LEE.
drop policy if exists "insert redemption" on public.redemptions;
drop policy if exists "read redemptions"  on public.redemptions;

create policy "insert redemption" on public.redemptions
  for insert to anon, authenticated with check (true);
create policy "read redemptions" on public.redemptions
  for select to authenticated
  using (exists (select 1 from public.businesses b
                 where b.id = redemptions.business_id and b.owner_id = auth.uid()));

-- ============================================================================
-- STORAGE — bucket público para fotos de negocios / productos / promociones
-- ============================================================================

insert into storage.buckets (id, name, public)
values ('business-media','business-media', true)
on conflict (id) do nothing;

drop policy if exists "media public read"   on storage.objects;
drop policy if exists "media auth upload"    on storage.objects;
drop policy if exists "media auth update"    on storage.objects;
drop policy if exists "media auth delete"    on storage.objects;

create policy "media public read" on storage.objects
  for select using (bucket_id = 'business-media');
create policy "media auth upload" on storage.objects
  for insert to authenticated with check (bucket_id = 'business-media');
create policy "media auth update" on storage.objects
  for update to authenticated using (bucket_id = 'business-media');
create policy "media auth delete" on storage.objects
  for delete to authenticated using (bucket_id = 'business-media');

-- ============================================================================
-- SEED — catálogo showcase (6 negocios reales de Manizales)
-- Fermines reescalados a 1F = $1.000 (precio_fermines = round(precio_cop/1000)).
-- owner_id queda NULL = demo gestionado por la Fundación. Un comerciante real
-- crea SU propio negocio desde la app (queda con owner_id = su cuenta).
-- ============================================================================

insert into public.businesses
  (id, nombre, tipo, descripcion, foto, logo, lat, lng, direccion, sector, horarios, telefono, instagram, rating, rating_count, descuento_base_fermines)
values
  ('biz_sombrerero','El Sombrerero','cafe','Café Brunch & Cócteles en Av. Santander. Ambiente acogedor, repostería de autor y cafés de origen. A pasos de Estadio Palogrande.','assets/fotos/el_sombrerero.jpg','assets/images/Logo_positivo.svg',5.0625,-75.5070,'Av. Santander #75a-113','Av. Santander','Dom–Mié 10AM–9PM · Jue 10AM–11PM · Vie–Sáb 10AM–11:30PM','+57 302 8658932','@el_sombrerero_manizales',45,202,15),
  ('biz_tazzioli','Café Tazzioli','cafe','Café de origen con vista a la Plaza de Bolívar y la Catedral. Repostería artesanal y métodos de extracción especializados.','assets/fotos/tazzioli.jpg','assets/images/Logo_positivo.svg',5.0690,-75.5172,'Plaza de Bolívar, Centro Histórico','Centro Histórico','Lun–Sáb 7AM–8PM · Dom 9AM–6PM','+57 310 4445566','@cafetazzioli',47,318,12),
  ('biz_termales','Hotel Termales del Ruiz','hotel','Aguas termales naturales con vista al Nevado del Ruiz. Spa, hospedaje y experiencias de bienestar en plena cordillera.','assets/fotos/termales_ruiz.jpg','assets/images/Logo_positivo.svg',4.9430,-75.3760,'Vía al Nevado del Ruiz Km 38','Nevado','24 h · Spa 8AM–9PM','+57 320 7891122','@termalesdelruiz',46,540,10),
  ('biz_lasuiza','Restaurante La Suiza','restaurante','Cocina típica del Paisaje Cultural Cafetero con toques de autor. Bandeja paisa, trucha del Ruiz y postres caldenses.','assets/fotos/la_suiza.png','assets/images/Logo_positivo.svg',5.0640,-75.5095,'Av. Santander con Cll 60','Av. Santander','Lun–Dom 11AM–10PM','+57 311 5677788','@restaurantelasuiza',44,186,20),
  ('biz_venecia','Hacienda Venecia','tour','Finca cafetera tradicional. Tour del café, hospedaje rural y experiencias auténticas del PCC.','assets/fotos/hacienda_venecia.jpg','assets/images/Logo_positivo.svg',5.0080,-75.6210,'Vía Chinchiná Km 12','Chinchiná','Tours 8AM y 1PM · Hospedaje permanente','+57 314 2233445','@haciendavenecia',48,720,15),
  ('biz_carretero','Hotel Carretero','hotel','Hotel boutique en el sector Cable, cerca de Estadio Palogrande y restaurantes de la zona rosa.','assets/fotos/hotel_carretero.jpg','assets/images/Logo_positivo.svg',5.0635,-75.5110,'Cra. 23 con Cll 64','Cable','24 h','+57 318 9988776','@hotelcarretero',43,142,12)
on conflict (id) do nothing;

insert into public.products
  (id, business_id, nombre, descripcion, precio_cop, precio_fermines, stock, destacado)
values
  ('prod_somb_01','biz_sombrerero','Cappuccino del Sombrerero','Café de origen Caldas, leche cremada al vapor, espuma firme y cacao.',8000,8,40,true),
  ('prod_somb_02','biz_sombrerero','Torta de amapola','Especialidad de la casa: torta de amapola con glaseado de limón y miel.',14000,14,12,true),
  ('prod_somb_03','biz_sombrerero','Torta de chocolate','Torta húmeda de chocolate con ganache de cacao colombiano 70%.',14000,14,8,false),
  ('prod_somb_04','biz_sombrerero','Bastilla','Bastilla de pollo con almendras y especias. Plato de la casa.',32000,32,6,false),
  ('prod_somb_05','biz_sombrerero','Brunch del Sombrerero','Huevos benedictinos, pan brioche, fruta, café o jugo. Ideal para empezar el día.',38000,38,10,true),
  ('prod_somb_06','biz_sombrerero','Cóctel de la casa','Cóctel firmado con aguardiente caldense, frutos rojos y hierba de limón.',26000,26,20,false),
  ('prod_tazz_01','biz_tazzioli','Café de origen 250g','Café especial tostado en Manizales. Bolsa 250g.',28000,28,25,true),
  ('prod_tazz_02','biz_tazzioli','V60 + postre','Café V60 servido en barra + postre del día.',18000,18,15,false),
  ('prod_tazz_03','biz_tazzioli','Cappuccino artesanal','Espresso doble con leche cremada. Vista a la Plaza de Bolívar.',8000,8,50,false),
  ('prod_tazz_04','biz_tazzioli','Brunch dominical','Huevos, croissant, fruta, café o jugo. Solo domingos.',32000,32,12,false),
  ('prod_term_01','biz_termales','Pase Spa medio día','Piscinas termales, sauna y turco por 4 horas.',95000,95,30,true),
  ('prod_term_02','biz_termales','Noche estándar + termales','Habitación doble + acceso ilimitado al complejo termal.',380000,380,8,true),
  ('prod_term_03','biz_termales','Suite vista al Nevado','Habitación premium con balcón privado y vista directa al Ruiz.',520000,520,4,false),
  ('prod_term_04','biz_termales','Cena gourmet montaña','Menú de 3 tiempos con productos del páramo. Reserva 24h antes.',75000,75,20,false),
  ('prod_term_05','biz_termales','Masaje de relajación 60 min','Masaje terapéutico con piedras volcánicas calientes.',110000,110,12,false),
  ('prod_suiza_01','biz_lasuiza','Bandeja paisa','Frijoles, arroz, carne molida, chicharrón, chorizo, huevo, plátano, aguacate.',32000,32,20,true),
  ('prod_suiza_02','biz_lasuiza','Trucha del Ruiz','Trucha al ajillo con papa criolla y patacón. Especialidad caldense.',38000,38,12,false),
  ('prod_suiza_03','biz_lasuiza','Sancocho de gallina','Sancocho tradicional con yuca, plátano, mazorca y arroz blanco.',28000,28,18,false),
  ('prod_suiza_04','biz_lasuiza','Postre paisa del día','Manjar blanco, arroz con leche o brevas con queso.',12000,12,25,false),
  ('prod_ven_01','biz_venecia','Tour del café — finca','Recorrido completo por finca cafetera, degustación y almuerzo típico.',195000,195,15,true),
  ('prod_ven_02','biz_venecia','Hospedaje rural 1 noche','Habitación en casa principal de la hacienda, desayuno con café recién tostado.',290000,290,6,true),
  ('prod_ven_03','biz_venecia','Paquete tour + noche + cena','Experiencia completa: tour, almuerzo, hospedaje y cena con vista al cafetal.',450000,450,4,false),
  ('prod_ven_04','biz_venecia','Cata de cafés especiales','Cata guiada de 6 microlotes con barista certificado. 2 horas.',45000,45,16,false),
  ('prod_carr_01','biz_carretero','Noche habitación estándar','Habitación doble en el corazón del sector Cable. Wi-Fi, TV y desayuno básico.',220000,220,14,true),
  ('prod_carr_02','biz_carretero','Noche + desayuno gourmet','Habitación + desayuno tipo brunch en restaurante aliado.',255000,255,14,false),
  ('prod_carr_03','biz_carretero','Suite Cable boutique','Suite con jacuzzi privado, vista a la zona rosa y minibar incluido.',350000,350,3,false),
  ('prod_carr_04','biz_carretero','Late checkout hasta 3PM','Quédate 4 horas extra el día de salida. Ideal después del FraileTour.',25000,25,30,false)
on conflict (id) do nothing;

insert into public.promotions
  (id, business_id, titulo, descripcion, condiciones, vigencia)
values
  ('promo_somb_01','biz_sombrerero','2x1 en cappuccinos los miércoles','Lleva un amigo y comparte café paisa. Aplica con Fermines.','Miércoles 10AM–2PM · 1 canje por usuario · Hasta agotar existencias','Vigente hasta 2026-07-31'),
  ('promo_somb_02','biz_sombrerero','20% extra para Caminantes Nivel 3+','Bonificación adicional para usuarios con 30+ tapas capturadas.','Aplica todos los días · Verificación automática en la app','Permanente'),
  ('promo_somb_03','biz_sombrerero','Pack Brunch + Cóctel','Brunch del Sombrerero + cóctel de la casa con descuento en Fermines.','Vie–Sáb desde 11AM','Vigente hasta 2026-06-30'),
  ('promo_somb_04','biz_sombrerero','Después de la tapa: -25% en torta','Si capturaste el Oso de Anteojos o la Reserva Río Blanco hoy, lleva tu torta con 25% off.','Mismo día de la captura · Mostrar en app','Permanente'),
  ('promo_term_01','biz_termales','Dormida + spa: -20% Lunes a Jueves','Noche estándar + termales con 20% off entre semana. Termales abiertos 24h.','Lun–Jue · No aplica feriados · Mínimo 1 noche','Vigente hasta 2026-08-31'),
  ('promo_term_02','biz_termales','Pase Spa con Fermines: 2x1 antes de 11AM','Lleva un acompañante gratis al spa si entras antes de las 11AM.','Aplica todos los días · Llegada antes 11AM','Permanente'),
  ('promo_carr_01','biz_carretero','Combo Cable: noche + cóctel en El Sombrerero','Hospedaje + cóctel cortesía en café aliado a 3 cuadras.','Vie–Dom · Reserva mínimo 2 noches','Vigente hasta 2026-09-30'),
  ('promo_carr_02','biz_carretero','-15% para Coleccionistas (Nivel 3+)','Si capturaste 30+ tapas, accedes a noche con descuento permanente.','Verificación automática en la app','Permanente'),
  ('promo_ven_01','biz_venecia','Paquete coffee lover: tour + cata','Tour completo + cata de microlotes con descuento en Fermines.','Reserva 48h antes · Cupos limitados','Vigente hasta 2026-12-31'),
  ('promo_ven_02','biz_venecia','Hospedaje rural: 3 noches por precio de 2','Quédate 3 noches en la hacienda y paga solo 2. Incluye tour del café.','Lun–Jue · No aplica festivos','Vigente hasta 2026-07-15'),
  ('promo_suiza_01','biz_lasuiza','Almuerzo paisa: bandeja + bebida + postre','Combo completo con descuento del 15% en Fermines.','Lun–Sáb 12PM–3PM','Permanente'),
  ('promo_tazz_01','biz_tazzioli','Tinto + bocadillo veleño','Combo más manizaleño imposible. Solo en barra.','Lun–Vie 7AM–10AM · 1 por persona','Permanente')
on conflict (id) do nothing;

-- ============================================================================
-- DEMO (opcional): vincular un negocio semilla a TU cuenta de comerciante
-- para poder editarlo desde el panel. Primero regístrate en la app con tu
-- email; luego descomenta y corre esto cambiando el email:
--
--   update public.businesses
--   set owner_id = (select id from auth.users where email = 'comerciante@ejemplo.com')
--   where id = 'biz_sombrerero';
-- ============================================================================
