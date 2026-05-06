-- 1. Create role enum
create type user_role as enum (
  'super_admin',
  'admin',
  'moderator',
  'property_owner',
  'broker',
  'corporate',
  'sme',
  'guest'
);

-- 2. Update profiles table to add role + extra fields
alter table profiles
  add column if not exists role user_role not null default 'guest',
  add column if not exists role_selected_at timestamptz,
  add column if not exists is_verified boolean default false,
  add column if not exists verified_at timestamptz,
  add column if not exists verified_by uuid references auth.users(id),
  add column if not exists kyc_status text default 'none'
    check (kyc_status in ('none','pending','approved','rejected')),
  add column if not exists phone text,
  add column if not exists avatar_url text,
  add column if not exists bio text,
  add column if not exists company_name text,
  add column if not exists company_size text,
  add column if not exists tax_code text;

-- 3. Role permissions table
create table role_permissions (
  id uuid primary key default gen_random_uuid(),
  role user_role not null,
  permission text not null,
  created_at timestamptz default now(),
  unique(role, permission)
);

-- 4. Seed permissions
insert into role_permissions (role, permission) values
-- Super Admin: everything
('super_admin', 'manage_users'),
('super_admin', 'manage_listings'),
('super_admin', 'manage_platform'),
('super_admin', 'view_billing'),
('super_admin', 'impersonate_user'),
('super_admin', 'view_analytics'),

-- Admin: verify users, moderate content
('admin', 'verify_users'),
('admin', 'manage_listings'),
('admin', 'view_analytics'),
('admin', 'manage_kyc'),

-- Moderator: content only
('moderator', 'moderate_listings'),
('moderator', 'flag_content'),

-- Property Owner: own listings
('property_owner', 'create_listing'),
('property_owner', 'manage_own_listings'),
('property_owner', 'view_inquiries'),
('property_owner', 'view_analytics_own'),

-- Broker: listings + search
('broker', 'create_listing'),
('broker', 'manage_own_listings'),
('broker', 'view_inquiries'),
('broker', 'search_listings'),
('broker', 'view_contact_full'),

-- Corporate: full search + contact
('corporate', 'search_listings'),
('corporate', 'view_contact_full'),
('corporate', 'save_shortlist'),
('corporate', 'view_market_report'),
('corporate', 'set_price_alert'),
('corporate', 'multi_seat'),

-- SME: basic search
('sme', 'search_listings'),
('sme', 'view_contact_full'),
('sme', 'save_shortlist'),

-- Guest: limited
('guest', 'search_listings');

-- 5. RLS policy update for profiles
drop policy if exists "Users can view own profile" on profiles;
drop policy if exists "Users can update own profile" on profiles;

create policy "Users can view own profile" on profiles
  for select using (auth.uid() = id);

create policy "Users can update own profile" on profiles
  for update using (auth.uid() = id)
  with check (auth.uid() = id);

create policy "Admins can view all profiles" on profiles
  for select using (
    exists (
      select 1 from profiles p
      where p.id = auth.uid()
      and p.role in ('super_admin', 'admin', 'moderator')
    )
  );

-- 6. Function: check if user has permission
create or replace function has_permission(user_id uuid, permission_name text)
returns boolean as $$
  select exists (
    select 1
    from profiles p
    join role_permissions rp on rp.role = p.role
    where p.id = user_id
    and rp.permission = permission_name
  );
$$ language sql security definer;

-- 7. Function: auto-set role timestamp
create or replace function on_role_updated()
returns trigger as $$
begin
  if old.role is distinct from new.role then
    new.role_selected_at = now();
  end if;
  return new;
end;
$$ language plpgsql;

create trigger profiles_role_updated
  before update on profiles
  for each row execute function on_role_updated();
