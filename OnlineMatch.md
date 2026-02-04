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
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '1 day'),
  ended_at timestamptz
);
create index if not exists online_matches_code_idx on public.online_matches (match_code);
create index if not exists online_matches_exp_idx on public.online_matches (expires_at);

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

-- 1日後にマッチとアクションを自動クリーンアップ
create extension if not exists pg_cron;
select cron.schedule(
  'online_match_cleanup',
  '0 * * * *',
  $$ delete from public.online_matches where expires_at < now(); $$
);

-- Realtimeを使うために online_matches / online_actions を有効化すること
```
