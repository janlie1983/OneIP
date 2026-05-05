create table industrial_zones (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  province text not null,
  region text not null check (region in ('North', 'Central', 'South')),
  total_area_ha numeric,
  available_area_ha numeric,
  lease_price_usd numeric,
  service_fee_usd numeric,
  infra_score int check (infra_score between 1 and 10),
  labor_score int check (labor_score between 1 and 10),
  logistics_score int check (logistics_score between 1 and 10),
  tax_incentive_years int,
  tax_incentive_rate numeric,
  industries_supported text[],
  distance_to_seaport_km numeric,
  distance_to_airport_km numeric,
  distance_to_hanoi_km numeric,
  distance_to_hcm_km numeric,
  developer text,
  developer_nationality text,
  established_year int,
  occupancy_rate numeric,
  min_lease_area_m2 numeric,
  utilities_power_kv text,
  utilities_water boolean default true,
  utilities_wastewater boolean default true,
  fiber_internet boolean default true,
  certifications text[],
  image_url text,
  website text,
  contact_email text,
  is_featured boolean default false,
  is_active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table site_selection_results (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  query_input jsonb not null,
  results jsonb not null,
  created_at timestamptz default now()
);

create table contact_leads (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  zone_id uuid references industrial_zones(id) on delete set null,
  zone_name text not null,
  created_at timestamptz default now()
);

-- RLS
alter table industrial_zones enable row level security;
create policy "Anyone can read active zones" on industrial_zones
  for select using (is_active = true);

alter table site_selection_results enable row level security;
create policy "Users manage own results" on site_selection_results
  for all using (auth.uid() = user_id);

alter table contact_leads enable row level security;
create policy "Anyone can insert leads" on contact_leads
  for insert with check (true);
create policy "Users see own leads" on contact_leads
  for select using (auth.uid() = user_id);

-- Seed data: 10 major industrial zones in Vietnam
insert into industrial_zones (name, province, region, total_area_ha, available_area_ha, lease_price_usd, service_fee_usd, infra_score, labor_score, logistics_score, tax_incentive_years, industries_supported, distance_to_seaport_km, distance_to_airport_km, distance_to_hanoi_km, developer, occupancy_rate, min_lease_area_m2) values
('VSIP Bac Ninh', 'Bac Ninh', 'North', 700, 120, 130, 1.2, 9, 8, 9, 15, ARRAY['Electronics', 'Manufacturing', 'Logistics'], 120, 35, 30, 'VSIP Group', 92, 1000),
('Deep C Hai Phong', 'Hai Phong', 'North', 3400, 450, 115, 1.0, 9, 7, 10, 15, ARRAY['Heavy Industry', 'Port Logistics', 'Manufacturing'], 5, 30, 120, 'Deep C Industrial', 78, 2000),
('Thang Long IP', 'Hanoi', 'North', 274, 30, 155, 1.5, 10, 9, 8, 4, ARRAY['Electronics', 'High-Tech', 'Auto Parts'], 130, 15, 15, 'Sumitomo', 98, 500),
('VSIP Binh Duong', 'Binh Duong', 'South', 2700, 380, 120, 1.1, 9, 9, 8, 10, ARRAY['Manufacturing', 'Consumer Goods', 'Food Processing'], 60, 30, 30, 'VSIP Group', 89, 1000),
('Amata Bien Hoa', 'Dong Nai', 'South', 700, 90, 125, 1.2, 8, 8, 8, 10, ARRAY['Auto Parts', 'Electronics', 'Manufacturing'], 50, 35, 35, 'Amata Corporation', 91, 1000),
('VSIP Quang Ngai', 'Quang Ngai', 'Central', 1090, 600, 85, 0.8, 7, 6, 6, 15, ARRAY['Heavy Industry', 'Petrochemical', 'Manufacturing'], 10, 25, 900, 'VSIP Group', 45, 2000),
('Nomura Hai Phong', 'Hai Phong', 'North', 153, 15, 140, 1.3, 9, 7, 9, 15, ARRAY['Electronics', 'Precision Manufacturing'], 8, 28, 118, 'Nomura', 95, 500),
('Long Duc IP', 'Dong Nai', 'South', 280, 80, 110, 1.0, 7, 8, 7, 10, ARRAY['Garment', 'Footwear', 'Consumer Goods'], 45, 40, 40, 'Sonadezi', 72, 500),
('Phu My 3', 'Ba Ria Vung Tau', 'South', 985, 300, 95, 0.9, 8, 6, 9, 15, ARRAY['Petrochemical', 'Heavy Industry', 'Port Logistics'], 3, 70, 90, 'Sojitz', 62, 5000),
('WHA Nghe An', 'Nghe An', 'Central', 3200, 2800, 70, 0.7, 6, 7, 5, 15, ARRAY['Manufacturing', 'Garment', 'Electronics'], 20, 45, 295, 'WHA Group', 18, 1000);
