-- ============================================================================
-- Migración v2 — canje completo, % Fermines vs plata, límites, QR
-- Idempotente. Aplicar sobre el esquema v1 ya existente.
-- ============================================================================

-- 1) Negocio: fuera descuento base; entra límite de canjes por día (0 = ilimitado)
alter table public.businesses drop column if exists descuento_base_fermines;
alter table public.businesses add column if not exists max_canjes_dia int not null default 0;

-- 2) Producto: % pagable con Fermines (resto en plata real) + tope diario
alter table public.products add column if not exists fermin_percent int not null default 100;
alter table public.products add column if not exists max_por_dia int not null default 0;

-- precio_fermines = parte en Fermines (1F=$1.000) = round(precio_cop * %/100 / 1000)
update public.products
  set precio_fermines = round(precio_cop * fermin_percent / 100.0 / 1000.0);

-- 3) Intenciones de canje (el turista genera; el comercio valida por código/QR)
create table if not exists public.canje_intents (
  id           text primary key default ('cnj_' || substr(replace(gen_random_uuid()::text,'-',''),1,12)),
  code         text not null,
  business_id  text not null references public.businesses(id) on delete cascade,
  product_id   text references public.products(id) on delete set null,
  product_name text not null default '',
  fermines     int  not null default 0,
  cop_real     int  not null default 0,
  status       text not null default 'pending',   -- pending | done | expired
  created_at   timestamptz not null default now(),
  consumed_at  timestamptz
);
create index if not exists idx_canje_business_code on public.canje_intents(business_id, code);

alter table public.canje_intents enable row level security;

drop policy if exists "insert intent"       on public.canje_intents;
drop policy if exists "read intents owner"   on public.canje_intents;
drop policy if exists "update intents owner" on public.canje_intents;

-- El turista (anónimo) crea la intención.
create policy "insert intent" on public.canje_intents
  for insert to anon, authenticated with check (true);
-- Solo el dueño del negocio la lee y la valida.
create policy "read intents owner" on public.canje_intents
  for select to authenticated
  using (exists (select 1 from public.businesses b
                 where b.id = canje_intents.business_id and b.owner_id = auth.uid()));
create policy "update intents owner" on public.canje_intents
  for update to authenticated
  using (exists (select 1 from public.businesses b
                 where b.id = canje_intents.business_id and b.owner_id = auth.uid()));
