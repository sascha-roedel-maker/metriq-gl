-- MetriQ V7.1 backend blueprint (PostgreSQL / Supabase-compatible)
-- IMPORTANT: review with your IT/DPO before production. Do not run against production blindly.

create extension if not exists pgcrypto;

do $$ begin
  create type public.metriq_role as enum ('team','gl','regional','admin');
exception when duplicate_object then null; end $$;

create table if not exists public.metriq_organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.metriq_sites (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.metriq_organizations(id) on delete cascade,
  name text not null,
  contract_model text,
  employees integer not null default 0,
  seats integer not null default 0,
  created_at timestamptz not null default now(),
  unique (organization_id, name)
);

create table if not exists public.metriq_memberships (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.metriq_organizations(id) on delete cascade,
  site_id uuid references public.metriq_sites(id) on delete cascade,
  user_id uuid not null,
  role public.metriq_role not null,
  created_at timestamptz not null default now(),
  unique (organization_id, site_id, user_id)
);

create table if not exists public.metriq_month_snapshots (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.metriq_organizations(id) on delete cascade,
  site_id uuid not null references public.metriq_sites(id) on delete cascade,
  month_key text not null check (month_key ~ '^20[0-9]{2}-(0[1-9]|1[0-2])$'),
  scan_version text not null,
  confidence numeric(5,2),
  conflicts integer not null default 0,
  payload jsonb not null,
  created_by uuid not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (site_id, month_key)
);

create table if not exists public.metriq_audit_events (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.metriq_organizations(id) on delete cascade,
  site_id uuid references public.metriq_sites(id) on delete cascade,
  actor_id uuid not null,
  action text not null,
  detail jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.metriq_integration_events (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.metriq_organizations(id) on delete cascade,
  site_id uuid not null references public.metriq_sites(id) on delete cascade,
  source text not null,
  external_event_id text,
  occurred_at timestamptz not null,
  payload jsonb not null,
  created_at timestamptz not null default now(),
  unique (site_id, source, external_event_id)
);

alter table public.metriq_organizations enable row level security;
alter table public.metriq_sites enable row level security;
alter table public.metriq_memberships enable row level security;
alter table public.metriq_month_snapshots enable row level security;
alter table public.metriq_audit_events enable row level security;
alter table public.metriq_integration_events enable row level security;

create or replace function public.metriq_has_org_access(target_org uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.metriq_memberships m
    where m.organization_id = target_org and m.user_id = auth.uid()
  );
$$;

create or replace function public.metriq_has_site_access(target_site uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.metriq_memberships m
    join public.metriq_sites s on s.organization_id = m.organization_id
    where s.id = target_site
      and m.user_id = auth.uid()
      and (m.site_id is null or m.site_id = target_site)
  );
$$;

create or replace function public.metriq_can_write_site(target_site uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.metriq_memberships m
    join public.metriq_sites s on s.organization_id = m.organization_id
    where s.id = target_site
      and m.user_id = auth.uid()
      and (m.site_id is null or m.site_id = target_site)
      and m.role in ('gl','admin')
  );
$$;

-- Read policies
create policy "org members read org" on public.metriq_organizations
for select using (public.metriq_has_org_access(id));

create policy "members read sites" on public.metriq_sites
for select using (public.metriq_has_site_access(id));

create policy "members read snapshots" on public.metriq_month_snapshots
for select using (public.metriq_has_site_access(site_id));

create policy "members read audit" on public.metriq_audit_events
for select using (site_id is null and public.metriq_has_org_access(organization_id) or public.metriq_has_site_access(site_id));

create policy "members read integration events" on public.metriq_integration_events
for select using (public.metriq_has_site_access(site_id));

-- Write policies (GL/admin only at site level)
create policy "gl admin insert snapshots" on public.metriq_month_snapshots
for insert with check (public.metriq_can_write_site(site_id) and created_by = auth.uid());

create policy "gl admin update snapshots" on public.metriq_month_snapshots
for update using (public.metriq_can_write_site(site_id))
with check (public.metriq_can_write_site(site_id));

create policy "authenticated append audit" on public.metriq_audit_events
for insert with check (actor_id = auth.uid() and (site_id is null and public.metriq_has_org_access(organization_id) or public.metriq_has_site_access(site_id)));

create policy "gl admin insert integration events" on public.metriq_integration_events
for insert with check (public.metriq_can_write_site(site_id));

-- Deliberately no UPDATE/DELETE policies on audit_events: append-only from the client perspective.
