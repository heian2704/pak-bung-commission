-- Pak Bung Commission — database schema
-- Run this once in Supabase: Dashboard → SQL Editor → New query → paste → Run.

create extension if not exists "pgcrypto";

create table if not exists public.commissions (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  date       date not null,
  sale       numeric(14,2) not null check (sale >= 0),
  rate       numeric(6,3)  not null check (rate >= 0 and rate <= 100),
  comm       numeric(14,2) not null check (comm >= 0),
  note       text not null default '',
  created_at timestamptz not null default now()
);

-- Each user can only see and touch their own rows
alter table public.commissions enable row level security;

drop policy if exists "sel own" on public.commissions;
drop policy if exists "ins own" on public.commissions;
drop policy if exists "upd own" on public.commissions;
drop policy if exists "del own" on public.commissions;

create policy "sel own" on public.commissions for select using (auth.uid() = user_id);
create policy "ins own" on public.commissions for insert with check (auth.uid() = user_id);
create policy "upd own" on public.commissions for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "del own" on public.commissions for delete using (auth.uid() = user_id);

create index if not exists commissions_user_date_idx on public.commissions (user_id, date desc, created_at desc);
