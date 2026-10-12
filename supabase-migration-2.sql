-- Migration 2: run once in Supabase -> SQL Editor -> New query -> paste -> Run.
-- Adds: multiple photos/videos/voice notes, tags, favorites, stickers, places,
-- comments, and settings (the day we met / started dating).

-- 1. New columns on memories
alter table public.memories
  add column if not exists media    jsonb            not null default '[]'::jsonb,
  add column if not exists tags     text[]           not null default '{}',
  add column if not exists favorite boolean          not null default false,
  add column if not exists sticker  text,
  add column if not exists place    text,
  add column if not exists lat      double precision,
  add column if not exists lng      double precision;

-- Carry existing single photos over into the new media list
update public.memories
set media = jsonb_build_array(jsonb_build_object('type', 'image', 'path', image_path))
where image_path is not null and media = '[]'::jsonb;

-- 2. Comments (both of you can add them under each memory)
create table if not exists public.comments (
  id         uuid primary key default gen_random_uuid(),
  memory_id  uuid not null references public.memories (id) on delete cascade,
  author     text not null,
  body       text not null,
  created_at timestamptz not null default now(),
  user_id    uuid not null default auth.uid() references auth.users (id)
);
create index if not exists comments_memory_idx on public.comments (memory_id);

alter table public.comments enable row level security;
create policy "members can read comments"   on public.comments for select to authenticated using (true);
create policy "members can insert comments" on public.comments for insert to authenticated with check (true);
create policy "members can update comments" on public.comments for update to authenticated using (true) with check (true);
create policy "members can delete comments" on public.comments for delete to authenticated using (true);

-- 3. Settings (day we met, day we started dating)
create table if not exists public.settings (
  key   text primary key,
  value text
);

alter table public.settings enable row level security;
create policy "members can read settings"   on public.settings for select to authenticated using (true);
create policy "members can insert settings" on public.settings for insert to authenticated with check (true);
create policy "members can update settings" on public.settings for update to authenticated using (true) with check (true);
