-- Migration 3: run once in Supabase -> SQL Editor -> New query -> paste -> Run.
-- Adds: time capsules, songs, reactions, lists, and live updates (for notifications).

-- 1. New columns on memories
alter table public.memories
  add column if not exists unlock_date date,   -- time capsule: hidden until this date
  add column if not exists song        jsonb;  -- {title, artist, art, preview, url}

-- 2. Reactions (one row per person per emoji per memory)
create table if not exists public.reactions (
  id         uuid primary key default gen_random_uuid(),
  memory_id  uuid not null references public.memories (id) on delete cascade,
  author     text not null,
  emoji      text not null,
  created_at timestamptz not null default now(),
  user_id    uuid not null default auth.uid() references auth.users (id),
  unique (memory_id, author, emoji)
);
create index if not exists reactions_memory_idx on public.reactions (memory_id);

-- 3. Lists ("places we want to go", "things I love about you", ...)
create table if not exists public.lists (
  id         uuid primary key default gen_random_uuid(),
  title      text not null,
  created_at timestamptz not null default now(),
  user_id    uuid not null default auth.uid() references auth.users (id)
);

create table if not exists public.list_items (
  id         uuid primary key default gen_random_uuid(),
  list_id    uuid not null references public.lists (id) on delete cascade,
  text       text not null,
  done       boolean not null default false,
  author     text,
  created_at timestamptz not null default now(),
  user_id    uuid not null default auth.uid() references auth.users (id)
);
create index if not exists list_items_list_idx on public.list_items (list_id);

-- 4. Row Level Security: only signed-in users (you two)
alter table public.reactions  enable row level security;
alter table public.lists      enable row level security;
alter table public.list_items enable row level security;

do $$
declare t text;
begin
  foreach t in array array['reactions', 'lists', 'list_items'] loop
    execute format('create policy "members can read"   on public.%I for select to authenticated using (true)', t);
    execute format('create policy "members can insert" on public.%I for insert to authenticated with check (true)', t);
    execute format('create policy "members can update" on public.%I for update to authenticated using (true) with check (true)', t);
    execute format('create policy "members can delete" on public.%I for delete to authenticated using (true)', t);
  end loop;
end $$;

-- 5. Live updates: lets the site notice when the other person adds something
do $$
declare t text;
begin
  foreach t in array array['memories', 'comments', 'reactions', 'lists', 'list_items'] loop
    begin
      execute format('alter publication supabase_realtime add table public.%I', t);
    exception when duplicate_object then null;
    end;
  end loop;
end $$;
