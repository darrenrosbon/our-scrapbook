-- Migration 4: run once in Supabase -> SQL Editor -> New query -> paste -> Run.
-- Safety net: every time a memory, comment, reaction, list, list item or setting is
-- UPDATED or DELETED, the previous version of that row is saved to row_history.
-- If a bug (or a slip) ever damages data, you can look the old row up and put it back.

create table if not exists public.row_history (
  id          bigint generated always as identity primary key,
  table_name  text        not null,
  op          text        not null,         -- 'UPDATE' or 'DELETE'
  row_data    jsonb       not null,         -- the row as it was BEFORE the change
  changed_at  timestamptz not null default now()
);
create index if not exists row_history_lookup on public.row_history (table_name, changed_at desc);

-- You two can read the history. Nobody can write to it through the website:
-- only the trigger below can, and it can't be edited or erased from the API.
alter table public.row_history enable row level security;
create policy "members can read history" on public.row_history for select to authenticated using (true);

create or replace function public.log_row_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.row_history (table_name, op, row_data) values (tg_table_name, tg_op, to_jsonb(old));
  if tg_op = 'DELETE' then return old; end if;
  return new;
end;
$$;

do $$
declare t text;
begin
  foreach t in array array['memories', 'comments', 'reactions', 'lists', 'list_items', 'settings'] loop
    execute format('drop trigger if exists %I on public.%I', 'trg_history_' || t, t);
    execute format(
      'create trigger %I after update or delete on public.%I for each row execute function public.log_row_change()',
      'trg_history_' || t, t);
  end loop;
end $$;
