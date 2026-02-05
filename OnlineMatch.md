supabaseを使用します。
あなたはここにsqlEditorを記載して作ってほしいDBを実現します。
```
create table~~

```

ルール；ユーザが初めてオンライン対戦の場合はユーザーネームを決めさせます。12文字以内。すでにDBのその名前があった場合はその名前は使えませんとユーザに知らせます。
ユーザーネームにつき通算の勝敗を管理します。
ユーザ同士が対決する際にはユーザーネームとそのユーザの通算勝敗を見ることができます。
ユーザがアクションするとそのアクションをDBに送信します。反対側のユーザはそのDBを受け取り敵の処理として盤面を動かします。
その後、自分のアクションを入力するとDBにいき、同じことを繰り返していきます。
一ラウンド終わると攻撃と防衛サイドがチェンジされます。
2ラウンド取った方が勝ちになります。
試合がおわった1日後に試合用のDBは消えるようにしたいです。
1日まではリプレイ機能を使って盤面を再現することもできるようにしたいです。

```sql
-- プレイヤープロファイル（12文字制限＋戦績）
create table if not exists public.online_profiles (
  id uuid primary key default gen_random_uuid(),
  username text not null unique check (char_length(username) <= 12),
  win_count integer not null default 0,
  loss_count integer not null default 0,
  created_at timestamptz not null default now()
);

-- マッチメタ（コードで参加、1日で期限切れ）
create table if not exists public.online_matches (
  id uuid primary key default gen_random_uuid(),
  match_code text not null unique,
  host_id uuid references public.online_profiles(id) on delete cascade,
  guest_id uuid references public.online_profiles(id) on delete cascade,
  attacker_id uuid references public.online_profiles(id) on delete set null,
  defender_id uuid references public.online_profiles(id) on delete set null,
  attacker_round_wins integer not null default 0,
  defender_round_wins integer not null default 0,
  status text not null default 'waiting' check (status in ('waiting','active','finished')),
  winner_team text,
  ended_reason text,
  last_action_at timestamptz,
  next_turn_team text,
  started_at timestamptz,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '1 day'),
  ended_at timestamptz
);
create index if not exists online_matches_code_idx on public.online_matches (match_code);
create index if not exists online_matches_exp_idx on public.online_matches (expires_at);

alter table public.online_profiles
  add column if not exists active_match_id uuid
  references public.online_matches(id) on delete set null;

-- アクションログ＋リプレイ用スナップショット
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
create index if not exists online_actions_match_idx on public.online_actions (match_id);
create index if not exists online_actions_revision_idx on public.online_actions (match_id, revision desc);

-- 行動が入ったらマッチ側の最新情報を更新
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

-- 参加/再入室用RPC（1ユーザー1マッチ固定）
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
    -- ランダムマッチを直列化して二重生成を防ぐ
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

-- 戦績更新用のRPC
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

-- タイムアウト判定RPC（手番30秒無操作で即敗北）
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
  if v_match.last_action_at > now() - interval '30 seconds' then
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

-- 退出/キャンセル用RPC（待機中マッチは削除、進行中は即敗北）
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

-- 1日後にマッチとアクションを自動クリーンアップ
create extension if not exists pg_cron;
select cron.schedule(
  'online_match_cleanup',
  '0 * * * *',
  $$ delete from public.online_matches where expires_at < now(); $$
);

-- Realtimeを使うために online_matches / online_actions を有効化すること
```
