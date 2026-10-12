-- Migration 5: run once in Supabase -> SQL Editor -> New query -> paste -> Run.
-- Records who (Rashmika or Darren) added each memory. Purely additive and safe to re-run.

alter table public.memories
  add column if not exists author text;
