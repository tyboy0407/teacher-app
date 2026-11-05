-- =============================================================
-- 教學寶盒(Teacher_app)資料庫結構 — 階段 1
-- 使用方式:Supabase Dashboard → SQL Editor → 貼上整份執行
-- =============================================================

-- 資源主表:教具製作 / 教具玩法 / 成品教玩具 / 教案 / 學習單 / 文章 共用一張表
create table if not exists public.resources (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  title text not null,
  summary text not null default '',
  -- 資源類型代碼:craft | play | product | lesson_plan | worksheet | routine | article
  type text not null check (type in ('craft', 'play', 'product', 'lesson_plan', 'worksheet', 'routine', 'article')),
  -- 適用成長階段代碼:toddler(幼幼班) k1(小班) k2(中班) k3(大班) all(不限年齡)
  age_stages text[] not null default '{}',
  -- 六大領域代碼:physical cognitive language social emotional aesthetic
  domains text[] not null default '{}',
  -- 對應課綱學習指標代碼,如 {認-中-1-1-1};代碼定義見 curriculum.sql
  indicator_codes text[] not null default '{}',
  cover_url text,
  image_urls text[] not null default '{}',
  video_url text,
  -- 材料清單(教具製作類)
  materials text[] not null default '{}',
  -- 製作步驟:[{"title": "...", "description": "..."}]
  steps jsonb not null default '[]'::jsonb,
  -- 內文:玩法說明 / 教案內容 / 文章正文等
  content text not null default '',
  source_name text,
  source_url text,
  -- 製作難度 1~3
  difficulty smallint check (difficulty between 1 and 3),
  duration_minutes int,
  is_featured boolean not null default false,
  published boolean not null default true
);

create index if not exists resources_type_idx on public.resources (type);
create index if not exists resources_created_at_idx on public.resources (created_at desc);
create index if not exists resources_age_stages_idx on public.resources using gin (age_stages);
create index if not exists resources_domains_idx on public.resources using gin (domains);
create index if not exists resources_indicator_codes_idx on public.resources using gin (indicator_codes);

-- 主題標籤(感官探索、節慶、情緒教育……)
create table if not exists public.tags (
  id uuid primary key default gen_random_uuid(),
  name text not null unique
);

create table if not exists public.resource_tags (
  resource_id uuid not null references public.resources (id) on delete cascade,
  tag_id uuid not null references public.tags (id) on delete cascade,
  primary key (resource_id, tag_id)
);

-- 資源更新時自動刷新 updated_at
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists resources_set_updated_at on public.resources;
create trigger resources_set_updated_at
before update on public.resources
for each row execute function public.set_updated_at();

-- Row Level Security:
-- App 端(anon key)只能「讀取」已上架(published = true)的資源;
-- 寫入一律透過 Dashboard 的 Table Editor(service role,不受 RLS 限制)。
alter table public.resources enable row level security;
alter table public.tags enable row level security;
alter table public.resource_tags enable row level security;

drop policy if exists "public read published resources" on public.resources;
create policy "public read published resources"
on public.resources for select
to anon, authenticated
using (published);

drop policy if exists "public read tags" on public.tags;
create policy "public read tags"
on public.tags for select
to anon, authenticated
using (true);

drop policy if exists "public read resource_tags" on public.resource_tags;
create policy "public read resource_tags"
on public.resource_tags for select
to anon, authenticated
using (true);
