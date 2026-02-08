# Online Match (Supabase SQL)

SQL Editor に **そのままコピペ** して実行してください。  
既存テーブルがあっても **安全に再実行できる**ようにしています。

注意:
- `online_profiles.username` に重複があるとユニーク制約の作成で失敗します。重複を解消してから再実行してください。
- Realtime を使うために **Supabase の Table Editor で `online_matches` / `online_actions` を Realtime ON** にしてください。

```sql
-- Extensions
create extension if not exists pgcrypto;
create extension if not exists pg_cron;

-- Online profiles
create table if not exists public.online_profiles (
  id uuid primary key default gen_random_uuid(),
  username text not null,
  win_count integer not null default 0,
  loss_count integer not null default 0,
  active_match_id uuid,
  created_at timestamptz not null default now()
);

alter table public.online_profiles
  add column if not exists active_match_id uuid;

-- 12文字制限 + ユニーク
do $$
begin
  if not exists (
    select 1 from pg_constraint
     where conname = 'online_profiles_username_len'
  ) then
    alter table public.online_profiles
      add constraint online_profiles_username_len
      check (char_length(username) <= 12);
  end if;
end $$;

create unique index if not exists online_profiles_username_uq
  on public.online_profiles (username);

-- Matches
create table if not exists public.online_matches (
  id uuid primary key default gen_random_uuid(),
  match_code text not null,
  host_id uuid,
  guest_id uuid,
  attacker_id uuid,
  defender_id uuid,
  attacker_round_wins integer not null default 0,
  defender_round_wins integer not null default 0,
  status text not null default 'waiting',
  winner_team text,
  ended_reason text,
  last_action_at timestamptz,
  next_turn_team text,
  started_at timestamptz,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '1 day'),
  ended_at timestamptz
);

alter table public.online_matches
  add column if not exists winner_team text;
alter table public.online_matches
  add column if not exists ended_reason text;
alter table public.online_matches
  add column if not exists last_action_at timestamptz;
alter table public.online_matches
  add column if not exists next_turn_team text;
alter table public.online_matches
  add column if not exists started_at timestamptz;
alter table public.online_matches
  add column if not exists ended_at timestamptz;

create unique index if not exists online_matches_code_uq
  on public.online_matches (match_code);
create index if not exists online_matches_exp_idx
  on public.online_matches (expires_at);

-- Actions
create table if not exists public.online_actions (
  id bigserial primary key,
  match_id uuid references public.online_matches(id) on delete cascade,
  revision integer not null,
  round_index integer not null default 1,
  actor_id uuid references public.online_profiles(id),
  team text check (team in ('attacker','defender')),
  payload jsonb not null,
  created_at timestamptz not null default now()
);
create index if not exists online_actions_match_idx
  on public.online_actions (match_id);
create index if not exists online_actions_revision_idx
  on public.online_actions (match_id, revision desc);

-- Action insert -> update match meta
create or replace function public.update_match_from_action()
returns trigger
language plpgsql
as $$
begin
  update public.online_matches
     set last_action_at = new.created_at,
         next_turn_team = (new.payload->'state'->>'turnTeam'),
         status = case when status = 'waiting' then 'active' else status end,
         started_at = coalesce(started_at, new.created_at)
   where id = new.match_id;
  return new;
end;
$$;

drop trigger if exists trg_online_actions_update_match on public.online_actions;
create trigger trg_online_actions_update_match
after insert on public.online_actions
for each row execute function public.update_match_from_action();

-- Win/Loss update
create or replace function public.increment_profile_stats(profile_id uuid, did_win boolean)
returns void
language plpgsql
security definer
as $$
begin
  if did_win then
    update public.online_profiles set win_count = win_count + 1 where id = profile_id;
  else
    update public.online_profiles set loss_count = loss_count + 1 where id = profile_id;
  end if;
end;
$$;

-- Match enter (atomic join / create)
create or replace function public.online_match_enter(
  p_profile_id uuid,
  p_match_code text default null,
  p_is_host boolean default false,
  p_is_random boolean default false
)
returns public.online_matches
language plpgsql
security definer
as $$
declare
  v_match public.online_matches;
  v_existing_id uuid;
begin
  select active_match_id into v_existing_id
    from public.online_profiles
   where id = p_profile_id;

  if v_existing_id is not null then
    select * into v_match from public.online_matches
     where id = v_existing_id
       and status in ('waiting','active')
       and expires_at > now();
    if found then
      return v_match;
    else
      update public.online_profiles set active_match_id = null where id = p_profile_id;
    end if;
  end if;

  if p_is_random then
    -- prevent double-create by locking
    perform pg_advisory_xact_lock(hashtext('online_match_random'));

    select * into v_match from public.online_matches
     where status = 'waiting'
       and guest_id is null
       and expires_at > now()
     order by created_at
     for update skip locked
     limit 1;

    if found then
      update public.online_matches
         set guest_id = p_profile_id,
             defender_id = coalesce(defender_id, p_profile_id),
             status = 'active',
             started_at = coalesce(started_at, now()),
             last_action_at = coalesce(last_action_at, now()),
             next_turn_team = coalesce(next_turn_team, 'attacker')
       where id = v_match.id
       returning * into v_match;
    else
      insert into public.online_matches(
        match_code, host_id, guest_id, attacker_id, defender_id, status, expires_at
      ) values (
        (select string_agg(substr('ABCDEFGHJKMNPQRSTUVWXYZ23456789', (random()*31+1)::int, 1), '')
           from generate_series(1,6)),
        p_profile_id, null, p_profile_id, null, 'waiting', now() + interval '1 day'
      ) returning * into v_match;
    end if;
  else
    if p_is_host then
      insert into public.online_matches(
        match_code, host_id, guest_id, attacker_id, defender_id, status, expires_at
      ) values (
        p_match_code, p_profile_id, null, p_profile_id, null, 'waiting', now() + interval '1 day'
      ) returning * into v_match;
    else
      select * into v_match from public.online_matches
       where match_code = p_match_code
         and expires_at > now()
       for update;
      if not found then
        raise exception 'match_not_found';
      end if;
      if v_match.guest_id is not null and v_match.guest_id <> p_profile_id then
        raise exception 'match_full';
      end if;
      update public.online_matches
         set guest_id = p_profile_id,
             defender_id = coalesce(defender_id, p_profile_id),
             status = 'active',
             started_at = coalesce(started_at, now()),
             last_action_at = coalesce(last_action_at, now()),
             next_turn_team = coalesce(next_turn_team, 'attacker')
       where id = v_match.id
       returning * into v_match;
    end if;
  end if;

  update public.online_profiles
     set active_match_id = v_match.id
   where id = p_profile_id;

  return v_match;
end;
$$;

-- Forfeit / cancel
create or replace function public.online_match_leave(
  p_profile_id uuid
) returns void
language plpgsql
security definer
as $$
declare
  v_match public.online_matches;
  v_match_id uuid;
  v_team text;
  v_winner_team text;
begin
  select active_match_id into v_match_id
    from public.online_profiles
   where id = p_profile_id;

  if v_match_id is null then
    return;
  end if;

  select * into v_match from public.online_matches
   where id = v_match_id
   for update;

  if not found then
    update public.online_profiles set active_match_id = null where id = p_profile_id;
    return;
  end if;

  if v_match.status = 'finished' then
    update public.online_profiles set active_match_id = null
     where id in (v_match.attacker_id, v_match.defender_id);
    return;
  end if;

  if v_match.status = 'waiting'
     and v_match.guest_id is null
     and v_match.host_id = p_profile_id then
    delete from public.online_matches where id = v_match.id;
    update public.online_profiles set active_match_id = null where id = p_profile_id;
    return;
  end if;

  v_team := case
    when v_match.attacker_id = p_profile_id then 'attacker'
    when v_match.defender_id = p_profile_id then 'defender'
    else null
  end;

  if v_team is null then
    update public.online_profiles set active_match_id = null where id = p_profile_id;
    return;
  end if;

  v_winner_team := case when v_team = 'attacker' then 'defender' else 'attacker' end;

  update public.online_matches
     set status = 'finished',
         winner_team = v_winner_team,
         ended_reason = 'abandon',
         attacker_round_wins = case when v_winner_team = 'attacker' then 2 else attacker_round_wins end,
         defender_round_wins = case when v_winner_team = 'defender' then 2 else defender_round_wins end,
         ended_at = now()
   where id = v_match.id;

  update public.online_profiles set active_match_id = null
   where id in (v_match.attacker_id, v_match.defender_id);

  if v_match.attacker_id is not null and v_match.defender_id is not null then
    if v_winner_team = 'attacker' then
      perform public.increment_profile_stats(v_match.attacker_id, true);
      perform public.increment_profile_stats(v_match.defender_id, false);
    else
      perform public.increment_profile_stats(v_match.defender_id, true);
      perform public.increment_profile_stats(v_match.attacker_id, false);
    end if;
  end if;
end;
$$;

-- 2m no action -> forfeit
create or replace function public.online_match_check_timeout(
  p_match_id uuid
) returns public.online_matches
language plpgsql
security definer
as $$
declare
  v_match public.online_matches;
  v_timeout_team text;
  v_winner_team text;
begin
  select * into v_match from public.online_matches where id = p_match_id for update;
  if not found then
    raise exception 'match_not_found';
  end if;
  if v_match.status <> 'active' then
    return v_match;
  end if;
  if v_match.attacker_id is null or v_match.defender_id is null then
    return v_match;
  end if;
  if v_match.last_action_at is null then
    return v_match;
  end if;
  if v_match.last_action_at > now() - interval '2 minutes' then
    return v_match;
  end if;

  v_timeout_team := v_match.next_turn_team;
  if v_timeout_team is null then
    return v_match;
  end if;
  v_winner_team := case when v_timeout_team = 'attacker' then 'defender' else 'attacker' end;

  update public.online_matches
     set status = 'finished',
         winner_team = v_winner_team,
         ended_reason = 'abandon',
         attacker_round_wins = case when v_winner_team = 'attacker' then 2 else attacker_round_wins end,
         defender_round_wins = case when v_winner_team = 'defender' then 2 else defender_round_wins end,
         ended_at = now()
   where id = v_match.id
   returning * into v_match;

  update public.online_profiles set active_match_id = null
   where id in (v_match.attacker_id, v_match.defender_id);

  if v_winner_team = 'attacker' then
    perform public.increment_profile_stats(v_match.attacker_id, true);
    perform public.increment_profile_stats(v_match.defender_id, false);
  else
    perform public.increment_profile_stats(v_match.defender_id, true);
    perform public.increment_profile_stats(v_match.attacker_id, false);
  end if;

  return v_match;
end;
$$;

-- Cleanup (1 day)
do $$
begin
  if not exists (select 1 from cron.job where jobname = 'online_match_cleanup') then
    perform cron.schedule(
      'online_match_cleanup',
      '0 * * * *',
      'delete from public.online_matches where expires_at < now();'
    );
  end if;
end $$;
```
