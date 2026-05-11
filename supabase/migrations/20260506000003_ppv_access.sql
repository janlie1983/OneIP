create table ppv_access (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  content_id text not null,
  expires_at timestamptz not null,
  created_at timestamptz default now(),
  unique(user_id, content_id)
);

alter table ppv_access enable row level security;

create policy "Users read own ppv access" on ppv_access
  for select using (auth.uid() = user_id);

create policy "Service role full access" on ppv_access
  for all using (true);
