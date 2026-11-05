-- =============================================================
-- 教學寶盒 資料庫 v2 — 階段 2:帳號與上傳
-- 使用方式:先執行過 schema.sql,再於 SQL Editor 貼上整份執行
-- =============================================================

-- 1. resources 投稿相關欄位
alter table public.resources
  add column if not exists created_by uuid references auth.users (id) on delete set null;
alter table public.resources
  add column if not exists review_status text not null default 'approved'
  check (review_status in ('pending', 'approved', 'rejected'));
alter table public.resources
  add column if not exists review_note text;

create index if not exists resources_created_by_idx on public.resources (created_by);
create index if not exists resources_review_status_idx on public.resources (review_status);

-- 2. RLS:讀取改為「已上架 或 本人投稿」;投稿人可新增/修改/刪除自己未核准的稿件
drop policy if exists "public read published resources" on public.resources;
drop policy if exists "read published or own" on public.resources;
create policy "read published or own"
on public.resources for select
to anon, authenticated
using (published or created_by = auth.uid());

drop policy if exists "insert own pending" on public.resources;
create policy "insert own pending"
on public.resources for insert
to authenticated
with check (
  created_by = auth.uid()
  and published = false
  and review_status = 'pending'
);

drop policy if exists "update own unapproved" on public.resources;
create policy "update own unapproved"
on public.resources for update
to authenticated
using (created_by = auth.uid() and review_status <> 'approved')
with check (
  created_by = auth.uid()
  and published = false
  and review_status in ('pending', 'rejected')
);

drop policy if exists "delete own unapproved" on public.resources;
create policy "delete own unapproved"
on public.resources for delete
to authenticated
using (created_by = auth.uid() and review_status <> 'approved');

-- 3. 投稿函式:一次寫入資源 + 標籤(security definer,繞過 tags 表的寫入限制)
create or replace function public.submit_resource(payload jsonb)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  new_id uuid;
  tag_name text;
begin
  if auth.uid() is null then
    raise exception '請先登入';
  end if;

  insert into public.resources (
    title, summary, type, age_stages, domains, indicator_codes,
    cover_url, image_urls, video_url, materials, steps, content,
    difficulty, duration_minutes,
    created_by, published, review_status
  ) values (
    payload->>'title',
    coalesce(payload->>'summary', ''),
    payload->>'type',
    coalesce((select array_agg(x) from jsonb_array_elements_text(payload->'age_stages') as t(x)), '{}'),
    coalesce((select array_agg(x) from jsonb_array_elements_text(payload->'domains') as t(x)), '{}'),
    coalesce((select array_agg(x) from jsonb_array_elements_text(payload->'indicator_codes') as t(x)), '{}'),
    nullif(payload->>'cover_url', ''),
    coalesce((select array_agg(x) from jsonb_array_elements_text(payload->'image_urls') as t(x)), '{}'),
    nullif(payload->>'video_url', ''),
    coalesce((select array_agg(x) from jsonb_array_elements_text(payload->'materials') as t(x)), '{}'),
    coalesce(payload->'steps', '[]'::jsonb),
    coalesce(payload->>'content', ''),
    (payload->>'difficulty')::smallint,
    (payload->>'duration_minutes')::int,
    auth.uid(), false, 'pending'
  ) returning id into new_id;

  for tag_name in
    select jsonb_array_elements_text(coalesce(payload->'tags', '[]'::jsonb))
  loop
    tag_name := btrim(tag_name);
    if tag_name <> '' then
      insert into public.tags (name) values (tag_name)
      on conflict (name) do nothing;

      insert into public.resource_tags (resource_id, tag_id)
      select new_id, t.id from public.tags t where t.name = tag_name
      on conflict do nothing;
    end if;
  end loop;

  return new_id;
end;
$$;

revoke all on function public.submit_resource(jsonb) from public;
grant execute on function public.submit_resource(jsonb) to authenticated;

-- 4. 圖片儲存桶與政策:公開讀取;登入者只能傳到自己的 user-<uid>/ 資料夾
insert into storage.buckets (id, name, public)
values ('resource-images', 'resource-images', true)
on conflict (id) do nothing;

drop policy if exists "public read resource images" on storage.objects;
create policy "public read resource images"
on storage.objects for select
to anon, authenticated
using (bucket_id = 'resource-images');

drop policy if exists "upload to own folder" on storage.objects;
create policy "upload to own folder"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'resource-images'
  and (storage.foldername(name))[1] = 'user-' || auth.uid()::text
);

drop policy if exists "delete own images" on storage.objects;
create policy "delete own images"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'resource-images'
  and (storage.foldername(name))[1] = 'user-' || auth.uid()::text
);
