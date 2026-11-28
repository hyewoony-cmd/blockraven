-- Blockhaven: shared island for multiplayer (run AFTER setup.sql)
-- Supabase → SQL Editor → New query → paste → Run. Safe to run more than once.
--
-- world_docs holds the shared island:
--   id = 'meta'          → { seed, epoch, t0 }   (which island, and when its day started)
--   id = 'c0' … 'c15'    → { epoch, e }          (blocks changed in each 16×16 chunk, "x,y,z,b;…")
-- Players, chat, swings and punches travel over Supabase Realtime (no table needed).

create table if not exists public.world_docs (
  id         text primary key check (id = 'meta' or id ~ '^c([0-9]|1[0-5])$'),
  data       jsonb not null check (pg_column_size(data) < 200000),
  updated_at timestamptz not null default now(),
  updated_by uuid default auth.uid()
);

-- Who may start a fresh island ("Generate a new world" in the shared world).
create table if not exists public.world_admins (
  user_id uuid primary key references auth.users(id) on delete cascade
);

alter table public.world_docs   enable row level security;
alter table public.world_admins enable row level security;

create or replace function public.is_world_admin()
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.world_admins where user_id = (select auth.uid()));
$$;
revoke execute on function public.is_world_admin() from public, anon;
grant  execute on function public.is_world_admin() to authenticated;

drop policy if exists "world read"         on public.world_docs;
drop policy if exists "world insert"       on public.world_docs;
drop policy if exists "world update"       on public.world_docs;
drop policy if exists "world delete admin" on public.world_docs;
drop policy if exists "admins read own"    on public.world_admins;

-- Every logged-in player sees the island and can build on it; only admins change 'meta' or wipe chunks.
create policy "world read" on public.world_docs
  for select to authenticated using (true);
create policy "world insert" on public.world_docs
  for insert to authenticated with check (id <> 'meta' or (select public.is_world_admin()));
create policy "world update" on public.world_docs
  for update to authenticated
  using (id <> 'meta' or (select public.is_world_admin()))
  with check (id <> 'meta' or (select public.is_world_admin()));
create policy "world delete admin" on public.world_docs
  for delete to authenticated using ((select public.is_world_admin()));

create policy "admins read own" on public.world_admins
  for select to authenticated using ((select auth.uid()) = user_id);

grant select, insert, update, delete on public.world_docs to authenticated;
grant select on public.world_admins to authenticated;

-- First island, so the game works before any admin exists.
insert into public.world_docs (id, data)
values ('meta', jsonb_build_object('seed', floor(random() * 1e9)::int, 'epoch', 1, 't0', extract(epoch from now())))
on conflict (id) do nothing;

-- Send row changes to connected players.
do $$
begin
  if not exists (select 1 from pg_publication_tables
                 where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'world_docs') then
    alter publication supabase_realtime add table public.world_docs;
  end if;
end $$;

-- To make someone an admin (replace USERNAME with their in-game username):
-- insert into public.world_admins (user_id)
--   select id from auth.users where email = 'USERNAME@players.blockhaven.game'
--   on conflict do nothing;

-- Admin-only: put items in another player's gift box (the in-game /give ITEM COUNT PLAYER command).
create or replace function public.admin_give(target text, item int, n int)
returns boolean language plpgsql security definer set search_path = '' as $$
declare found_row boolean;
begin
  if not public.is_world_admin() then raise exception 'admins only' using errcode = '42501'; end if;
  if item < 1 or item > 999 or n < 1 or n > 999 then raise exception 'bad item or count' using errcode = '22023'; end if;
  update public.players
     set gift = gift || jsonb_build_object(item::text, coalesce((gift->>item::text)::int, 0) + n)
   where username = lower(target);
  get diagnostics found_row = row_count;
  return found_row;
end $$;
revoke execute on function public.admin_give(text, int, int) from public, anon;
grant execute on function public.admin_give(text, int, int) to authenticated;
