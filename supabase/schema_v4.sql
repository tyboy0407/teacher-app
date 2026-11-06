-- =============================================================
-- 教學寶盒 資料庫 v4 — 主題/節慶標籤
-- 使用方式:先執行過 schema.sql、schema_v2.sql、schema_v3.sql,再於 SQL Editor 貼上整份執行
-- =============================================================

-- 1. resources.themes:主題/節慶代碼(見 lib/data/theme_catalog.dart),可多選
alter table public.resources
  add column if not exists themes text[] not null default '{}';

create index if not exists resources_themes_idx on public.resources using gin (themes);

-- 2. 投稿函式加入 themes 欄位(其餘與 v2 相同)
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
    title, summary, type, age_stages, domains, indicator_codes, themes,
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
    coalesce((select array_agg(x) from jsonb_array_elements_text(payload->'themes') as t(x)), '{}'),
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

-- 3. 示範內容的主題(與 App 內建種子資料相同;沒跑過 seed.sql 的話這段不會影響任何列)
update public.resources set themes = '{colors_shapes,recycling}' where title = '瓶蓋顏色分類盒';
update public.resources set themes = '{emotions}' where title = '情緒臉譜轉盤';
update public.resources set themes = '{emotions,recycling}' where title = '寶特瓶冷靜瓶';
update public.resources set themes = '{ocean}' where title = '注音符號釣魚組';
update public.resources set themes = '{colors_shapes}' where title = '彩虹米感官箱';
update public.resources set themes = '{plants,spring}' where title = '「小種子長大了」主題教案';
update public.resources set themes = '{animals}' where title = '動物運動會律動教案';
update public.resources set themes = '{colors_shapes}' where title = '形狀配對學習單';
update public.resources set themes = '{emotions}' where title = '我的心情日記學習單';
update public.resources set themes = '{colors_shapes}' where title = '磁性積木挑選與玩法';
update public.resources set themes = '{my_body}' where title = '平衡步道';
update public.resources set themes = '{school_start}' where title = '學習區佈置的五個原則';
update public.resources set themes = '{school_start}' where title = '安靜排隊救急口令集';
update public.resources set themes = '{school_start}' where title = '「請你跟我這樣做」轉換小遊戲';
