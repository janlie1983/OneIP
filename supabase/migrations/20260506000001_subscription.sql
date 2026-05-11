-- 1. Plan enum
create type subscription_plan as enum (
  'free', 'pro', 'enterprise'
);

-- 2. Payment provider enum
create type payment_provider as enum (
  'stripe', 'vnpay'
);

-- 3. Subscription status enum
create type subscription_status as enum (
  'active', 'cancelled', 'expired', 'past_due', 'trialing'
);

-- 4. Plans config table (source of truth for pricing)
create table plans (
  id uuid primary key default gen_random_uuid(),
  name subscription_plan not null unique,
  price_usd numeric not null default 0,
  price_vnd bigint not null default 0,
  billing_period text default 'monthly',
  max_checklists int default 1,
  max_alerts int default 2,
  max_seats int default 1,
  has_pdf_export boolean default false,
  has_real_time_data boolean default false,
  has_market_report boolean default false,
  has_api_access boolean default false,
  features_vi text[],
  features_en text[],
  is_active boolean default true,
  created_at timestamptz default now()
);

-- 5. Seed plans
insert into plans (
  name, price_usd, price_vnd,
  max_checklists, max_alerts, max_seats,
  has_pdf_export, has_real_time_data, has_market_report,
  features_vi, features_en
) values
(
  'free', 0, 0,
  1, 2, 1, false, false, false,
  ARRAY[
    'Tìm kiếm KCN cơ bản',
    'Xem top 3 kết quả',
    'Dữ liệu giá thuê (trễ 30 ngày)',
    '1 checklist giấy phép',
    '2 price alerts'
  ],
  ARRAY[
    'Basic KCN search',
    'View top 3 results',
    'Lease data (30-day delay)',
    '1 permit checklist',
    '2 price alerts'
  ]
),
(
  'pro', 29, 699000,
  -1, -1, 1, true, true, true,
  ARRAY[
    'Tìm kiếm KCN không giới hạn',
    'Xem đầy đủ tất cả kết quả',
    'Dữ liệu giá thuê thời gian thực',
    'Checklist không giới hạn',
    'Price alerts không giới hạn',
    'Xuất PDF báo cáo',
    'Báo cáo thị trường đầy đủ',
    'So sánh tối đa 5 KCN'
  ],
  ARRAY[
    'Unlimited KCN search',
    'Full results access',
    'Real-time lease data',
    'Unlimited checklists',
    'Unlimited price alerts',
    'PDF export',
    'Full market reports',
    'Compare up to 5 zones'
  ]
),
(
  'enterprise', 99, 2490000,
  -1, -1, 10, true, true, true,
  ARRAY[
    'Tất cả tính năng Pro',
    'Tối đa 10 tài khoản team',
    'API access',
    'Báo cáo tùy chỉnh',
    'Hỗ trợ ưu tiên 24/7',
    'Onboarding riêng'
  ],
  ARRAY[
    'All Pro features',
    'Up to 10 team seats',
    'API access',
    'Custom reports',
    'Priority 24/7 support',
    'Dedicated onboarding'
  ]
);

-- 6. Subscriptions table
create table subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  plan subscription_plan not null default 'free',
  status subscription_status not null default 'active',
  payment_provider payment_provider,
  stripe_customer_id text,
  stripe_subscription_id text,
  vnpay_transaction_id text,
  amount_usd numeric,
  amount_vnd bigint,
  current_period_start timestamptz,
  current_period_end timestamptz,
  cancel_at_period_end boolean default false,
  cancelled_at timestamptz,
  trial_end timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- 7. Payment history
create table payment_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  subscription_id uuid references subscriptions(id),
  plan subscription_plan not null,
  amount_usd numeric,
  amount_vnd bigint,
  payment_provider payment_provider not null,
  provider_transaction_id text,
  status text not null check (status in ('pending','success','failed','refunded')),
  metadata jsonb,
  created_at timestamptz default now()
);

-- 8. RLS
alter table plans enable row level security;
alter table subscriptions enable row level security;
alter table payment_history enable row level security;

create policy "Public read plans" on plans
  for select using (is_active = true);

create policy "Users read own subscription" on subscriptions
  for select using (auth.uid() = user_id);

create policy "Users read own payments" on payment_history
  for select using (auth.uid() = user_id);

-- 9. Auto-create free subscription on new user
create or replace function on_new_user_subscription()
returns trigger as $$
begin
  insert into subscriptions (user_id, plan, status)
  values (new.id, 'free', 'active');
  return new;
end;
$$ language plpgsql security definer;

create trigger create_free_subscription
  after insert on auth.users
  for each row execute function on_new_user_subscription();

-- 10. Function: get user's current plan
create or replace function get_user_plan(user_id uuid)
returns subscription_plan as $$
  select plan from subscriptions
  where user_id = $1
  and status = 'active'
  order by created_at desc
  limit 1;
$$ language sql security definer;

-- 11. Update profiles: sync plan field
create or replace function sync_profile_plan()
returns trigger as $$
begin
  update profiles
  set plan = new.plan::text,
      plan_expires_at = new.current_period_end
  where id = new.user_id;
  return new;
end;
$$ language plpgsql security definer;

create trigger sync_plan_to_profile
  after insert or update on subscriptions
  for each row execute function sync_profile_plan();
