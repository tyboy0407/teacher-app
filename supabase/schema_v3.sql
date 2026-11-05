-- =============================================================
-- 教學寶盒 資料庫 v3 — 管理者與 App 內審核
-- 使用方式:先執行過 schema.sql 與 schema_v2.sql,再於 SQL Editor 貼上整份執行
-- =============================================================

-- 1. 管理者名單:在這張表裡的帳號可在 App 內審核投稿
create table if not exists public.admins (
  user_id uuid primary key references auth.users (id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.admins enable row level security;

-- 使用者只能看到自己是否為管理者(App 用來決定要不要顯示審核入口)
drop policy if exists "read own admin row" on public.admins;
create policy "read own admin row"
on public.admins for select
to authenticated
using (user_id = auth.uid());

-- 2. is_admin():目前登入者是否為管理者
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (select 1 from public.admins where user_id = auth.uid());
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

-- 3. 管理者可讀取全部投稿(含待審與被退回的)
drop policy if exists "admin read all" on public.resources;
create policy "admin read all"
on public.resources for select
to authenticated
using (public.is_admin());

-- 4. 審核函式:通過(上架)或退回(附原因);身分檢查在伺服器端
create or replace function public.review_resource(
  resource_id uuid,
  decision text,
  note text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception '只有管理者可以審核';
  end if;

  if decision = 'approve' then
    update public.resources
    set review_status = 'approved', published = true, review_note = null
    where id = resource_id;
  elsif decision = 'reject' then
    if note is null or btrim(note) = '' then
      raise exception '退回時必須填寫原因';
    end if;
    update public.resources
    set review_status = 'rejected', published = false, review_note = btrim(note)
    where id = resource_id;
  else
    raise exception '未知的審核動作:%', decision;
  end if;

  if not found then
    raise exception '找不到這筆投稿';
  end if;
end;
$$;

revoke all on function public.review_resource(uuid, text, text) from public;
grant execute on function public.review_resource(uuid, text, text) to authenticated;

-- 5. 指定第一位管理者:把下面的信箱換成你在 App 註冊的帳號後執行
-- insert into public.admins (user_id)
-- select id from auth.users where email = 'you@example.com'
-- on conflict do nothing;
