# 教學寶盒(teacher_app)

給台灣幼教老師的教學資源聚合 App——把散落在網路各處的**教具製作教程、教具玩法、成品教玩具、教案、學習單與幼教新知**整理進一個 App,依「成長階段 × 六大領域 × 資源類型」三維分類,備課找素材不用再大海撈針。

**線上試用版:https://tyboy0407.github.io/teacher-app/**(手機瀏覽器直接開;推到 `main` 會由 GitHub Actions 自動重新部署)

## 目前進度:階段 2(帳號與投稿)

- **帳號**:Email 註冊/登入/忘記密碼(Supabase Auth);「我的」頁顯示登入狀態
- **投稿**:第 5 個分頁「發布」——投稿表單(分類 chips、材料/步驟編輯器、照片上傳、課綱指標選擇器、標籤),送出後進入待審
- **審核流**:投稿預設 `pending` 不上架;**管理者在 App 內審核**(「我的 → 審核投稿」:待審清單 → 詳情頁底部「通過並上架 / 退回附原因」,通過前列出審核重點清單),也可在 Supabase 後台改欄位;老師在「發布」頁追蹤狀態、可刪除未核准投稿
- 權限(RLS):訪客只能讀已上架內容;投稿人可讀寫自己的未核准稿件;管理者(`admins` 表,只能從後台指定)可讀全部投稿並透過伺服器端函式審核;圖片只能傳到自己的資料夾

### 階段 1.5 完成項目

- 四個分頁:**首頁**(精選推薦、依領域探索、最新資源)、**資源庫**(關鍵字搜尋 + 類型/年齡/領域/標籤篩選)、**收藏**(存於裝置本地,免帳號)、**我的**
- 資源詳情頁:材料清單、製作步驟、玩法說明/教案內文、難度與時間、示範影片按鈕
- **課綱指標庫**:內建《幼兒園教保活動課程大綱》57 條課程目標、438 條分齡學習指標(解析自官方 PDF);資源可對應指標、詳情頁一鍵複製指標貼進教案、指標反查對應資源(資源庫右上角或「我的 → 課綱指標查詢」)
- 資源類型含「常規救急」(口令、轉換小遊戲),搭配情境標籤(轉換時間/雨天備案/免教具)
- 未連線後端時使用**內建 14 筆示範資料**;接上 Supabase 後改讀雲端內容,可遠端更新

## 技術棧

Flutter · Riverpod · go_router · Supabase(`supabase_flutter`)· shared_preferences

## 執行方式

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=supabase.env.json
```

- Supabase 連線資訊放在 [supabase.env.json](supabase.env.json)(IntelliJ 的 `main.dart` 執行設定已自動帶入);不帶參數執行則使用內建示範資料。建立後端的步驟見 [SUPABASE_SETUP.md](SUPABASE_SETUP.md)

- Windows 桌面版建置需開啟「開發人員模式」(symlink 支援):執行 `start ms-settings:developers`
- App 名稱等基本資訊集中在 [lib/core/constants.dart](lib/core/constants.dart),想改名改這裡即可

## 專案結構

```
lib/
  config/      Supabase 連線設定(--dart-define)
  core/        常數、主題、路由
  models/      Resource 模型、三維分類(taxonomy)、課綱模型(curriculum)
  data/        Repository 介面 + Mock/Supabase 兩套實作、收藏、種子資料、
               課綱資料(curriculum_data,由腳本產生)與查詢服務
  features/    home / library / resource(詳情)/ curriculum(指標查詢)/ favorites / profile
  widgets/     資源卡片、封面、徽章等共用元件
supabase/
  schema.sql       建表 + 索引 + RLS(App 端只能讀取已上架內容)
  schema_v2.sql    帳號與投稿:審核欄位、投稿函式、圖片儲存桶
  schema_v3.sql    管理者名單與 App 內審核函式
  curriculum.sql   課綱課程目標與學習指標(由腳本產生)
  seed.sql         與內建示範資料相同的 14 筆種子內容
scripts/
  build_curriculum.py   解析官方課綱 PDF → 產生課綱資料檔(Dart/SQL/核對清單)
docs/
  content-guidelines.md   內容錄入規範(給錄入內容的老師)
  curriculum-review.md    課綱指標逐條核對清單(含官方 PDF 頁碼)
```

## 三維分類體系

| 維度 | 值 |
|---|---|
| 成長階段 | 幼幼班 2-3歲 / 小班 3-4歲 / 中班 4-5歲 / 大班 5-6歲 / 不限年齡 |
| 發展領域 | 身體動作與健康、認知、語文、社會、情緒、美感(對齊《幼兒園教保活動課程大綱》) |
| 資源類型 | 教具製作、教具玩法、成品教玩具、教案、學習單、文章 |

## 路線圖

| 階段 | 內容 | 狀態 |
|---|---|---|
| 1 只讀資源庫 | 瀏覽、搜尋、篩選、收藏 | ✅ |
| 1.5 課綱指標庫 | 指標對應與反查、常規救急型態、示範影片 | ✅ |
| 2 帳號與投稿 | Email 登入、App 內投稿、審核流 | ✅ 目前 |
| 2.1 互動 | 評論、按讚、收藏雲端同步 | 規劃中 |
| 3 個人化 | 依班級年齡推薦、學習專欄、追蹤老師 | 規劃中 |
| 4 商業化探索 | 材料包、付費內容 | 構想 |
