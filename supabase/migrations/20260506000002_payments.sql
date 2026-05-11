create table pending_payments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id),
  payment_type text not null check (payment_type in ('subscription', 'ppv')),
  plan text,
  content_id text,
  amount_vnd bigint not null,
  transfer_code text not null unique,
  status text default 'pending' check (status in ('pending','success','expired')),
  qr_url text,
  expires_at timestamptz not null,
  created_at timestamptz default now()
);

alter table pending_payments enable row level security;
create policy "Users read own payments" on pending_payments
  for select using (auth.uid() = user_id);
create policy "Service role full access" on pending_payments
  for all using (true);
