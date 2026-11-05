# Supabase 連線設定指南

App 預設使用**內建示範資料**,不用任何設定就能跑起來。
想讓內容改成從雲端讀取(可遠端更新、不用改 App),照下面步驟接上 Supabase 即可,全程約 15 分鐘。

## 1. 建立 Supabase 專案

1. 到 [supabase.com](https://supabase.com) 註冊並登入(免費方案即可)
2. 點「New Project」建立專案,地區建議選 `Northeast Asia (Tokyo)`,離台灣最近
3. 資料庫密碼自己設定並保存好(之後很少用到)

## 2. 建立資料表

1. 進入專案後,左側選單點 **SQL Editor**
2. 打開本專案的 [`supabase/schema.sql`](supabase/schema.sql),整份複製貼上 → 按 **Run**
3. 再貼上 [`supabase/curriculum.sql`](supabase/curriculum.sql) 執行,匯入課綱課程目標與學習指標(後台錄入時參照用)
4. 再貼上 [`supabase/schema_v2.sql`](supabase/schema_v2.sql) 執行,啟用**帳號與投稿**(審核欄位、權限、投稿函式、圖片儲存桶)
5. (選用)再貼上 [`supabase/seed.sql`](supabase/seed.sql) 執行,會匯入與 App 內建相同的 14 筆種子內容

> 註冊流程預設會寄 Email 驗證信;測試期想省略,可到 **Authentication → Sign In / Providers → Email** 關閉「Confirm email」。

## 3. 取得連線金鑰

左側選單 **Settings → API**,記下兩個值:

| 名稱 | 位置 |
|---|---|
| Project URL | `https://xxxx.supabase.co` |
| anon public key | API Keys 區塊的 `anon` `public`(新版介面叫 **Publishable key**,`sb_publishable_...` 開頭,兩種都可用) |

> anon key 可以放進 App 沒關係:資料庫開了 Row Level Security,這把鑰匙**只能讀取已上架的資源**,不能寫入。

## 4. 讓 App 連上去

兩個值已寫在專案根目錄的 [`supabase.env.json`](supabase.env.json),換專案時改這個檔案即可:

```json
{
  "SUPABASE_URL": "https://xxxx.supabase.co",
  "SUPABASE_ANON_KEY": "sb_publishable_..."
}
```

執行時用 `--dart-define-from-file` 帶入:

```bash
flutter run -d chrome --dart-define-from-file=supabase.env.json
```

- **IntelliJ / Android Studio**:專案內建的 `main.dart` 執行設定已帶好這個參數,直接按 Run 即可。自己新增執行設定時,在 **Run → Edit Configurations → Additional run args** 貼上 `--dart-define-from-file=supabase.env.json`。
- 也可以逐一指定:`--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
- 不帶參數執行時,App 會自動退回內建示範資料。

連線成功後,「我的」頁面的資料來源會顯示「已連線 Supabase」。

## 5. 日常錄入內容

平常新增/修改內容**不用寫任何程式**:

1. Supabase 左側選單 **Table Editor → resources**
2. 點「Insert row」新增一筆,照下方代碼表填欄位
3. 存檔後,App 下次整理重新載入就會看到(`published` 打勾才會顯示)

### 欄位填寫說明

| 欄位 | 說明 |
|---|---|
| `title` | 標題(必填) |
| `summary` | 一句話簡介,顯示在列表卡片上 |
| `type` | 資源類型代碼,見下表(必填) |
| `age_stages` | 適用年齡代碼,可多選,如 `{k1,k2}` |
| `domains` | 六大領域代碼,可多選,如 `{cognitive}` |
| `indicator_codes` | 對應課綱學習指標代碼,如 `{認-小-1-2-1,認-小-1-2-3}`;代碼可在 App 的「課綱指標查詢」頁或 `curriculum_indicators` 表查到 |
| `materials` | 材料清單,如 `{"鞋盒 1 個","瓶蓋 20 個"}` |
| `steps` | 製作步驟 JSON:`[{"title":"...","description":"..."}]` |
| `content` | 內文(玩法說明/教案內容/文章正文) |
| `difficulty` | 製作難度 1~3(選填) |
| `duration_minutes` | 活動或製作時間,分鐘(選填) |
| `cover_url` | 封面圖網址(選填,見下方圖片上傳) |
| `is_featured` | 打勾 = 出現在首頁「精選推薦」 |
| `published` | 打勾 = 在 App 上架 |

### 代碼對照表

**type(資源類型,單選)**

| 代碼 | 意義 |
|---|---|
| `craft` | 教具製作 |
| `play` | 教具玩法 |
| `product` | 成品教玩具 |
| `lesson_plan` | 教案 |
| `worksheet` | 學習單 |
| `routine` | 常規救急(手指謠、口令、轉換小遊戲) |
| `article` | 文章 |

**age_stages(成長階段,可多選)**

| 代碼 | 意義 |
|---|---|
| `toddler` | 幼幼班 2-3歲 |
| `k1` | 小班 3-4歲 |
| `k2` | 中班 4-5歲 |
| `k3` | 大班 5-6歲 |
| `all` | 不限年齡 |

**domains(六大領域,可多選)**

| 代碼 | 意義 |
|---|---|
| `physical` | 身體動作與健康 |
| `cognitive` | 認知 |
| `language` | 語文 |
| `social` | 社會 |
| `emotional` | 情緒 |
| `aesthetic` | 美感 |

標籤:先在 **tags** 表新增標籤名稱,再到 **resource_tags** 表把資源 id 和標籤 id 建立關聯。

## 6. 上傳圖片(封面)

`resource-images` 儲存桶已由 `schema_v2.sql` 自動建立。管理者手動放圖:

1. 左側選單 **Storage → resource-images** 上傳圖片
2. 點圖片 → **Get URL**,把網址貼到資源的 `cover_url` 欄位

老師在 App 內投稿時,照片會自動上傳到 `resource-images/user-<使用者id>/`。

## 7. 審核老師的投稿

老師在 App「發布」分頁投稿後,內容會以**待審**狀態進資料庫(`published = false`、`review_status = 'pending'`),不會直接上架。審核步驟:

1. **Table Editor → resources**,用篩選條件 `review_status = pending` 找出待審投稿
2. 檢查內容(對照 [docs/content-guidelines.md](docs/content-guidelines.md) 的重點:分類合理、安全提醒有寫、無版權疑慮、照片沒有孩子的臉)
3. **通過**:`review_status` 改為 `approved`,並勾選 `published` → 立即上架
4. **退回**:`review_status` 改為 `rejected`,並在 `review_note` 填退回原因 → 老師會在 App「發布」頁看到原因,可修正後重投

老師本人隨時能在 App 看到自己投稿的狀態(審核中/已上架/未通過)。

## 常見問題

- **App 還是顯示示範資料?** 確認執行指令有帶 `--dart-define`,兩個值都不能空。
- **新增的資源沒出現?** 檢查 `published` 是否打勾;App 目前在重新整理(下拉或重開)後取得新資料。
- **想先下架某筆內容?** 把 `published` 取消勾選即可,不用刪除。
