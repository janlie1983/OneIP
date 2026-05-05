create table lease_rates (
  id uuid primary key default gen_random_uuid(),
  zone_name text not null,
  province text not null,
  region text not null check (region in ('North', 'Central', 'South')),
  asset_type text not null check (asset_type in ('factory', 'warehouse', 'land', 'office')),
  price_usd numeric not null,
  price_vnd_million numeric,
  recorded_month date not null,
  source text not null,
  is_verified boolean default false,
  notes text,
  created_at timestamptz default now()
);

create table rate_alerts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  zone_name text,
  province text,
  region text,
  asset_type text,
  threshold_price_usd numeric not null,
  direction text not null check (direction in ('above', 'below')),
  is_active boolean default true,
  last_triggered_at timestamptz,
  created_at timestamptz default now()
);

create table market_insights (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  title_en text,
  content text not null,
  content_en text,
  category text,
  province text,
  published_at timestamptz default now(),
  is_premium boolean default false
);

-- Enable RLS
alter table lease_rates enable row level security;
alter table rate_alerts enable row level security;
alter table market_insights enable row level security;

create policy "Public read lease_rates" on lease_rates for select using (true);
create policy "Users manage own alerts" on rate_alerts for all using (auth.uid() = user_id);
create policy "Public read free insights" on market_insights for select using (not is_premium or auth.uid() is not null);

-- Seed: historical data for major zones
insert into lease_rates (zone_name, province, region, asset_type, price_usd, recorded_month, source, is_verified) values
('VSIP Bac Ninh', 'Bac Ninh', 'North', 'factory', 118, '2024-05-01', 'JLL', true),
('VSIP Bac Ninh', 'Bac Ninh', 'North', 'factory', 120, '2024-06-01', 'JLL', true),
('VSIP Bac Ninh', 'Bac Ninh', 'North', 'factory', 120, '2024-07-01', 'CBRE', true),
('VSIP Bac Ninh', 'Bac Ninh', 'North', 'factory', 122, '2024-08-01', 'CBRE', true),
('VSIP Bac Ninh', 'Bac Ninh', 'North', 'factory', 123, '2024-09-01', 'JLL', true),
('VSIP Bac Ninh', 'Bac Ninh', 'North', 'factory', 125, '2024-10-01', 'JLL', true),
('VSIP Bac Ninh', 'Bac Ninh', 'North', 'factory', 125, '2024-11-01', 'VLI', true),
('VSIP Bac Ninh', 'Bac Ninh', 'North', 'factory', 127, '2024-12-01', 'VLI', true),
('VSIP Bac Ninh', 'Bac Ninh', 'North', 'factory', 128, '2025-01-01', 'JLL', true),
('VSIP Bac Ninh', 'Bac Ninh', 'North', 'factory', 129, '2025-02-01', 'JLL', true),
('VSIP Bac Ninh', 'Bac Ninh', 'North', 'factory', 130, '2025-03-01', 'CBRE', true),
('VSIP Bac Ninh', 'Bac Ninh', 'North', 'factory', 131, '2025-04-01', 'CBRE', true),
('VSIP Bac Ninh', 'Bac Ninh', 'North', 'factory', 132, '2025-05-01', 'VLI', true),
('Deep C Hai Phong', 'Hai Phong', 'North', 'warehouse', 95, '2024-05-01', 'JLL', true),
('Deep C Hai Phong', 'Hai Phong', 'North', 'warehouse', 96, '2024-08-01', 'JLL', true),
('Deep C Hai Phong', 'Hai Phong', 'North', 'warehouse', 98, '2024-11-01', 'CBRE', true),
('Deep C Hai Phong', 'Hai Phong', 'North', 'warehouse', 100, '2025-02-01', 'CBRE', true),
('Deep C Hai Phong', 'Hai Phong', 'North', 'warehouse', 102, '2025-05-01', 'VLI', true),
('VSIP Binh Duong', 'Binh Duong', 'South', 'factory', 108, '2024-05-01', 'JLL', true),
('VSIP Binh Duong', 'Binh Duong', 'South', 'factory', 110, '2024-08-01', 'JLL', true),
('VSIP Binh Duong', 'Binh Duong', 'South', 'factory', 112, '2024-11-01', 'CBRE', true),
('VSIP Binh Duong', 'Binh Duong', 'South', 'factory', 115, '2025-02-01', 'CBRE', true),
('VSIP Binh Duong', 'Binh Duong', 'South', 'factory', 118, '2025-05-01', 'VLI', true),
('Amata Bien Hoa', 'Dong Nai', 'South', 'land', 110, '2024-05-01', 'CBRE', true),
('Amata Bien Hoa', 'Dong Nai', 'South', 'land', 112, '2024-11-01', 'CBRE', true),
('Amata Bien Hoa', 'Dong Nai', 'South', 'land', 115, '2025-05-01', 'JLL', true),
('WHA Nghe An', 'Nghe An', 'Central', 'factory', 65, '2024-05-01', 'VLI', true),
('WHA Nghe An', 'Nghe An', 'Central', 'factory', 67, '2024-11-01', 'VLI', true),
('WHA Nghe An', 'Nghe An', 'Central', 'factory', 70, '2025-05-01', 'VLI', true);

-- Seed market insights
insert into market_insights (title, content, category, province, is_premium) values
('Giá thuê nhà xưởng miền Bắc tăng 8% trong Q1 2025', 'Theo khảo sát của VLI, giá thuê nhà xưởng tại các KCN khu vực Hà Nội và Hải Phòng ghi nhận mức tăng trung bình 8% so với cùng kỳ năm ngoái, chủ yếu do nhu cầu từ các nhà đầu tư Hàn Quốc và Nhật Bản.', 'Market Update', 'Hanoi', false),
('Deep C mở rộng giai đoạn 3 tại Hải Phòng', 'Deep C Industrial Zones thông báo kế hoạch mở rộng thêm 500ha tại Hải Phòng trong năm 2025, dự kiến thu hút thêm 50 doanh nghiệp FDI trong lĩnh vực logistics và sản xuất.', 'Zone News', 'Hai Phong', false),
('Báo cáo đầy đủ: Thị trường KCN Việt Nam H1 2025', 'Báo cáo chi tiết về xu hướng giá thuê, tỷ lệ lấp đầy và dự báo cho 6 tháng cuối năm 2025.', 'Research Report', null, true);
