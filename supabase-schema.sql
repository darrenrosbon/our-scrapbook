-- Run this once in Supabase: SQL Editor -> New query -> paste -> Run.

-- 1. Memories table
create table if not exists public.memories (
  id          uuid primary key default gen_random_uuid(),
  date        date not null,
  text        text not null default '',
  image_path  text,
  created_at  timestamptz not null default now(),
  user_id     uuid not null default auth.uid() references auth.users (id)
);

create index if not exists memories_date_idx on public.memories (date);

-- 2. Row Level Security: only signed-in users (you two) can touch anything.
alter table public.memories enable row level security;

create policy "members can read"   on public.memories for select to authenticated using (true);
create policy "members can insert" on public.memories for insert to authenticated with check (true);
create policy "members can update" on public.memories for update to authenticated using (true) with check (true);
create policy "members can delete" on public.memories for delete to authenticated using (true);

-- 3. Private photo bucket
insert into storage.buckets (id, name, public)
values ('photos', 'photos', false)
on conflict (id) do nothing;

create policy "members can read photos"   on storage.objects for select to authenticated using (bucket_id = 'photos');
create policy "members can upload photos" on storage.objects for insert to authenticated with check (bucket_id = 'photos');
create policy "members can update photos" on storage.objects for update to authenticated using (bucket_id = 'photos');
create policy "members can delete photos" on storage.objects for delete to authenticated using (bucket_id = 'photos');
