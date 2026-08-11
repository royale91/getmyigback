-- ═══════════════════════════════════════════════════════════════
--  Get My IG Back · Supabase setup
--  Run once: Supabase dashboard → SQL Editor → New query → paste → Run
-- ═══════════════════════════════════════════════════════════════

-- 1) Cases table -------------------------------------------------
create table if not exists public.cases (
  id         uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  status     text not null default 'unpaid',
  name  text, email text, phone text, handle text,
  files jsonb default '[]'::jsonb,
  data  jsonb default '{}'::jsonb
);

alter table public.cases enable row level security;

-- Anyone can submit a case (the public intake form)
drop policy if exists "public can insert cases" on public.cases;
create policy "public can insert cases" on public.cases
  for insert to anon, authenticated with check (true);

-- Only logged-in admins can read / update cases
drop policy if exists "admins can read cases" on public.cases;
create policy "admins can read cases" on public.cases
  for select to authenticated using (true);

drop policy if exists "admins can update cases" on public.cases;
create policy "admins can update cases" on public.cases
  for update to authenticated using (true) with check (true);

-- 2) Private storage bucket for uploaded photos / documents ------
insert into storage.buckets (id, name, public)
  values ('case-files', 'case-files', false)
  on conflict (id) do nothing;

-- Anyone can upload into the bucket (from the intake form)
drop policy if exists "public can upload files" on storage.objects;
create policy "public can upload files" on storage.objects
  for insert to anon, authenticated with check (bucket_id = 'case-files');

-- Only logged-in admins can read the files (via signed URLs)
drop policy if exists "admins can read files" on storage.objects;
create policy "admins can read files" on storage.objects
  for select to authenticated using (bucket_id = 'case-files');
