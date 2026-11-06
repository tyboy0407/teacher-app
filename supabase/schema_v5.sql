-- =============================================================
-- 教學寶盒 資料庫 v5 — 管理者下架 / 重新上架 / 刪除
-- 使用方式:先執行過 schema.sql ~ schema_v4.sql,再於 SQL Editor 貼上整份執行
-- =============================================================

-- 管理者對「已上架」內容的處置;身分檢查在伺服器端,一般老師呼叫會被拒絕。
--   unpublish : 下架(不公開,資料保留;其他老師的收藏/備課籃會暫時找不到它)
--   publish   : 重新上架
--   delete    : 永久刪除(連同標籤關聯,無法復原)
create or replace function public.moderate_resource(
  resource_id uuid,
  action text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception '只有管理者可以執行這個動作';
  end if;

  if action = 'unpublish' then
    update public.resources set published = false where id = resource_id;
  elsif action = 'publish' then
    update public.resources
    set published = true, review_status = 'approved', review_note = null
    where id = resource_id;
  elsif action = 'delete' then
    delete from public.resources where id = resource_id;
  else
    raise exception '未知的動作:%', action;
  end if;

  if not found then
    raise exception '找不到這筆資源';
  end if;
end;
$$;

revoke all on function public.moderate_resource(uuid, text) from public;
grant execute on function public.moderate_resource(uuid, text) to authenticated;
