-- Migration 6: run once in Supabase -> SQL Editor -> New query -> paste -> Run.
-- Lists can be plain lists or tick-off (checklist) lists. Safe to run again: it only does
-- anything the first time, so it never overrides lists you've since switched to plain.

do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'lists' and column_name = 'checklist'
  ) then
    -- new lists default to a plain list (no tick boxes)
    alter table public.lists add column checklist boolean not null default false;
    -- lists that already exist had tick boxes, so they stay tick-off lists
    -- (switch any of them to plain with the "Tick boxes" switch on the list)
    update public.lists set checklist = true;
  end if;
end $$;
