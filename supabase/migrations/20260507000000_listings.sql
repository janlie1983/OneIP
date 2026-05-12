-- Asset type enum
create type asset_type as enum (
  'rbf',        -- Ready Built Factory
  'rbw',        -- Ready Built Warehouse
  'land',       -- Industrial Land
  'office'      -- Factory Office
);

-- Listing status enum
create type listing_status as enum (
  'draft',
  'pending_review',
  'active',
  'rented',
  'expired',
  'rejected'
);

-- Main listings table
create table listings (
  id uuid primary key default gen_random_uuid(),

  -- Owner info
  owner_id uuid references auth.users(id) on delete cascade,
  zone_id uuid references industrial_zones(id),

  -- Basic info
  title text not null,
  title_en text,
  description text,
  description_en text,
  asset_type asset_type not null,

  -- Location
  province text not null,
  district text,
  region text not null check (region in ('North','Central','South')),
  address text,
  latitude numeric,
  longitude numeric,

  -- Specifications
  total_area_m2 numeric not null,
  office_area_m2 numeric,
  clear_height_m numeric,
  floor_load_capacity numeric,    -- kg/m2
  number_of_floors int default 1,
  year_built int,

  -- Pricing
  lease_price_usd numeric,        -- USD/m2/year
  lease_price_vnd bigint,         -- VND/m2/month
  min_lease_term_months int,
  is_negotiable boolean default true,

  -- Availability
  available_from date,
  available_area_m2 numeric,
  occupancy_rate numeric,

  -- Utilities & Features
  power_capacity_kva numeric,
  has_3_phase_power boolean default true,
  has_water_supply boolean default true,
  has_wastewater_treatment boolean default false,
  has_fiber_internet boolean default true,
  has_security boolean default true,
  has_canteen boolean default false,
  has_parking boolean default true,
  has_loading_dock boolean default false,
  loading_dock_count int,

  -- Media
  images text[],
  video_url text,
  floor_plan_url text,

  -- Status & Verification
  status listing_status default 'draft',
  is_featured boolean default false,
  is_verified boolean default false,
  verified_by uuid references auth.users(id),
  verified_at timestamptz,
  rejection_reason text,

  -- SEO
  slug text unique,

  -- Metrics
  view_count int default 0,
  inquiry_count int default 0,

  -- Contact (shown to Pro users only)
  contact_name text,
  contact_phone text,
  contact_email text,
  contact_zalo text,

  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Listing inquiries
create table listing_inquiries (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid references listings(id) on delete cascade,
  user_id uuid references auth.users(id),
  name text not null,
  email text not null,
  phone text,
  company text,
  message text,
  required_area_m2 numeric,
  move_in_date date,
  status text default 'new'
    check (status in ('new','contacted','qualified','closed')),
  created_at timestamptz default now()
);

-- Saved/shortlisted listings
create table saved_listings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  listing_id uuid references listings(id) on delete cascade,
  created_at timestamptz default now(),
  unique(user_id, listing_id)
);

-- RLS
alter table listings enable row level security;
alter table listing_inquiries enable row level security;
alter table saved_listings enable row level security;

-- Public can read active listings
create policy "Public read active listings" on listings
  for select using (status = 'active');

-- Owners can manage own listings
create policy "Owners manage own listings" on listings
  for all using (auth.uid() = owner_id);

-- Admins can manage all listings
create policy "Admins manage all listings" on listings
  for all using (
    exists (
      select 1 from profiles
      where id = auth.uid()
      and role in ('super_admin', 'admin', 'moderator')
    )
  );

create policy "Users manage own inquiries" on listing_inquiries
  for all using (auth.uid() = user_id);

create policy "Owners see inquiries for own listings" on listing_inquiries
  for select using (
    exists (
      select 1 from listings
      where id = listing_id
      and owner_id = auth.uid()
    )
  );

create policy "Users manage saved listings" on saved_listings
  for all using (auth.uid() = user_id);

-- Auto-update updated_at
create or replace function update_listing_timestamp()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger listings_updated_at
  before update on listings
  for each row execute function update_listing_timestamp();

-- Auto-generate slug
create or replace function generate_listing_slug()
returns trigger as $$
declare
  base_slug text;
  final_slug text;
  counter int := 0;
begin
  base_slug := lower(regexp_replace(new.title, '[^a-zA-Z0-9]+', '-', 'g'));
  base_slug := trim(both '-' from base_slug);
  final_slug := base_slug || '-' || substring(new.id::text, 1, 8);
  new.slug := final_slug;
  return new;
end;
$$ language plpgsql;

create trigger listings_generate_slug
  before insert on listings
  for each row execute function generate_listing_slug();

-- Increment view count
create or replace function increment_listing_views(listing_id uuid)
returns void as $$
  update listings set view_count = view_count + 1 where id = listing_id;
$$ language sql security definer;

-- SEED: 10 sample listings
insert into listings (
  title, asset_type, province, region,
  total_area_m2, clear_height_m,
  lease_price_usd, min_lease_term_months,
  available_area_m2, available_from,
  has_loading_dock, loading_dock_count,
  power_capacity_kva,
  contact_name, contact_email, contact_phone,
  status, is_featured,
  description
) values
(
  'Nhà xưởng xây sẵn VSIP Bắc Ninh - 5.000m²',
  'rbf', 'Bac Ninh', 'North',
  5000, 9.0,
  55, 24,
  5000, '2026-06-01',
  true, 4, 1000,
  'Nguyễn Văn A', 'contact@vsip.com.vn', '0901234567',
  'active', true,
  'Nhà xưởng xây sẵn tiêu chuẩn quốc tế tại VSIP Bắc Ninh. Phù hợp sản xuất điện tử, linh kiện ô tô.'
),
(
  'Kho vận Deep C Hải Phòng - 10.000m²',
  'rbw', 'Hai Phong', 'North',
  10000, 12.0,
  45, 12,
  10000, '2026-07-01',
  true, 8, 2000,
  'Trần Thị B', 'contact@deepc.vn', '0907654321',
  'active', true,
  'Kho logistics hiện đại gần cảng Hải Phòng. Cầu trục 10 tấn, hệ thống PCCC tự động.'
),
(
  'Nhà xưởng Thăng Long IP Hà Nội - 2.000m²',
  'rbf', 'Hanoi', 'North',
  2000, 8.5,
  75, 36,
  2000, '2026-05-15',
  true, 2, 500,
  'Lê Văn C', 'contact@thanglongip.com', '0912345678',
  'active', false,
  'Nhà xưởng cao cấp trong KCN Thăng Long, cách sân bay Nội Bài 15km.'
),
(
  'Nhà xưởng VSIP Bình Dương - 3.000m²',
  'rbf', 'Binh Duong', 'South',
  3000, 9.0,
  52, 24,
  3000, '2026-06-15',
  true, 3, 750,
  'Phạm Thị D', 'contact@vsipbd.com', '0923456789',
  'active', true,
  'Nhà xưởng xây sẵn tại VSIP Bình Dương, gần TP.HCM 30km.'
),
(
  'Kho Amata Đồng Nai - 5.000m²',
  'rbw', 'Dong Nai', 'South',
  5000, 10.0,
  40, 12,
  5000, '2026-08-01',
  true, 6, 1000,
  'Hoàng Văn E', 'contact@amata.com', '0934567890',
  'active', false,
  'Kho xưởng trong KCN Amata Biên Hòa, thuận tiện logistics đường bộ.'
),
(
  'Đất KCN Phú Mỹ 3 - Vũng Tàu 2ha',
  'land', 'Ba Ria Vung Tau', 'South',
  20000, 0,
  95, 48,
  20000, '2026-06-01',
  false, 0, 0,
  'Nguyễn Thị F', 'contact@phuymy3.com', '0945678901',
  'active', false,
  'Đất công nghiệp trong KCN Phú Mỹ 3, gần cảng nước sâu.'
),
(
  'Nhà xưởng WHA Nghệ An - 5.000m²',
  'rbf', 'Nghe An', 'Central',
  5000, 8.0,
  35, 24,
  5000, '2026-09-01',
  true, 4, 1000,
  'Trần Văn G', 'contact@wha.com', '0956789012',
  'active', false,
  'Nhà xưởng trong KCN WHA Nghệ An, ưu đãi thuế 15 năm.'
),
(
  'Kho Nomura Hải Phòng - 3.000m²',
  'rbw', 'Hai Phong', 'North',
  3000, 11.0,
  50, 12,
  3000, '2026-07-15',
  true, 4, 600,
  'Lê Thị H', 'contact@nomura.com', '0967890123',
  'active', false,
  'Kho hiện đại trong KCN Nomura, cách cảng Hải Phòng 8km.'
),
(
  'Nhà xưởng Long Đức Đồng Nai - 1.500m²',
  'rbf', 'Dong Nai', 'South',
  1500, 7.5,
  42, 24,
  1500, '2026-06-01',
  true, 2, 375,
  'Phạm Văn I', 'contact@longduc.com', '0978901234',
  'active', false,
  'Nhà xưởng vừa và nhỏ phù hợp SME trong KCN Long Đức.'
),
(
  'Văn phòng nhà máy VSIP Quảng Ngãi - 500m²',
  'office', 'Quang Ngai', 'Central',
  500, 4.0,
  25, 12,
  500, '2026-05-01',
  false, 0, 100,
  'Hoàng Thị K', 'contact@vsipqn.com', '0989012345',
  'active', false,
  'Văn phòng nhà máy tiêu chuẩn trong KCN VSIP Quảng Ngãi.'
);
