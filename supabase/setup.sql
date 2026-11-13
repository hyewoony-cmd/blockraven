-- Blockhaven: player characters table
-- Run this once in Supabase → SQL Editor → New query → paste → Run.

create table if not exists public.players (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  username   text unique not null,
  inv        jsonb not null default '{}'::jsonb,                    -- { itemId: count }
  hot        jsonb not null default '[0,0,0,0,0,0,0,0,0]'::jsonb,   -- 9 hotbar slots
  hp         real  not null default 10,
  pos        jsonb,                                                 -- [x, y, z]
  updated_at timestamptz not null default now()
);

-- Row-level security: every player can only see and change their own character.
alter table public.players enable row level security;

drop policy if exists "players read own"   on public.players;
drop policy if exists "players insert own" on public.players;
drop policy if exists "players update own" on public.players;

create policy "players read own" on public.players
  for select to authenticated using ((select auth.uid()) = user_id);

create policy "players insert own" on public.players
  for insert to authenticated with check ((select auth.uid()) = user_id);

create policy "players update own" on public.players
  for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

grant select, insert, update on public.players to authenticated;
