-- =============================================================
-- 教學寶盒 範本教案(由 scripts/build_lesson_seeds.py 產生)
-- 使用方式:先執行過 schema.sql ~ schema_v5.sql,再於 SQL Editor 貼上整份執行。
-- 可重複執行:同標題的教案已存在就跳過,不會重複新增。
-- 內容為參考公開教案後重新設計的原創內容,來源記在 source_name / source_url。
-- =============================================================

insert into public.resources
  (title, summary, type, age_stages, domains, indicator_codes, themes,
   content, duration_minutes, is_featured, source_name, source_url,
   cover_url, steps, published, review_status, created_at)
select
  '摸摸看,是玉米!',
  '從神秘箱開始,用摸、看、剝、印認識玉米,最後用玉米滾出一張畫。',
  'lesson_plan',
  array['k1']::text[],
  array['cognitive', 'aesthetic']::text[],
  array['認-小-2-2-2', '美-小-2-2-1']::text[],
  array['food', 'plants']::text[],
  '活動名稱:摸摸看,是玉米!
適用年齡:小班(3-4 歲)
活動時間:約 40 分鐘

一、教學目標
1. 能用摸、看、聞說出玉米的兩種特徵。
2. 能比較不同顏色的玉米哪裡一樣、哪裡不一樣。
3. 樂於用玉米和玉米鬚進行拓印創作。

二、教學資源
神秘箱(紙箱挖一個手伸得進去的洞)、帶葉玉米 2~3 根、黃白紫三色玉米各 1 根、廣告顏料、圖畫紙、濕抹布、海報紙。

三、引起動機(8 分鐘)
請 3~4 位孩子把手伸進神秘箱摸一摸:是硬的還是軟的?滑滑的還是一粒一粒的?先不說答案,讓全班猜。揭曉後傳下去,每個人都摸一下、聞一下。

四、發展活動(22 分鐘)
1. 剝玉米:兩人一組一起剝開外葉,找到「玉米鬚」,數一數剝了幾片葉子。
2. 比一比:把三種顏色的玉米排在一起,問「哪裡一樣?哪裡不一樣?」老師把孩子說的話畫在海報上(顏色、大小、粒粒怎麼排)。
3. 玉米拓印:用半截玉米沾顏料在紙上滾,用玉米鬚當刷子,看看會印出什麼花紋。

五、綜合活動(10 分鐘)
作品圍成一圈欣賞,請孩子指著自己的畫說一句「我的玉米印出來像……」。最後一起想:吃過哪些玉米做的東西?

六、延伸活動
把玉米粒泡水放在窗邊,每天看一次有沒有發芽;點心時間安排水煮玉米,連結「我們今天摸過的玉米」。

小提醒:乾玉米粒對小班仍有誤食、塞進鼻孔的風險,操作時老師要在旁邊,活動後清點收回。對玉米過敏的孩子只參與觀察與拓印,不參與試吃。',
  40,
  true,
  '農業部食農教育教學資源平臺〈食時好玉米〉(真愛國際教育機構,幼兒園小班)',
  'https://fae.moa.gov.tw/files/TeachingPlan/732/A01_1.pdf',
  'asset:assets/lessons/seed-101-cover.svg',
  '[{"title": "引起動機", "description": "神秘箱摸一摸:硬的還是軟的?一粒一粒的是什麼?", "image": "asset:assets/lessons/seed-101-1.svg"}, {"title": "發展活動", "description": "剝玉米、比顏色,再用玉米滾顏料印出花紋。", "image": "asset:assets/lessons/seed-101-2.svg"}, {"title": "綜合活動", "description": "作品掛起來一起欣賞,說說自己印出來像什麼。", "image": "asset:assets/lessons/seed-101-3.svg"}]'::jsonb,
  true,
  'approved',
  timestamptz '2026-11-10 09:00:00+08'
where not exists (
  select 1 from public.resources where title = '摸摸看,是玉米!'
);

-- 已經新增過的舊版本:補上封面與流程圖示(不覆蓋之後換上的實拍照片)
update public.resources
set cover_url = 'asset:assets/lessons/seed-101-cover.svg',
    steps = '[{"title": "引起動機", "description": "神秘箱摸一摸:硬的還是軟的?一粒一粒的是什麼?", "image": "asset:assets/lessons/seed-101-1.svg"}, {"title": "發展活動", "description": "剝玉米、比顏色,再用玉米滾顏料印出花紋。", "image": "asset:assets/lessons/seed-101-2.svg"}, {"title": "綜合活動", "description": "作品掛起來一起欣賞,說說自己印出來像什麼。", "image": "asset:assets/lessons/seed-101-3.svg"}]'::jsonb
where title = '摸摸看,是玉米!'
  and (cover_url is null or cover_url like 'asset:%');

insert into public.resources
  (title, summary, type, age_stages, domains, indicator_codes, themes,
   content, duration_minutes, is_featured, source_name, source_url,
   cover_url, steps, published, review_status, created_at)
select
  '大海裡有誰?',
  '從一本海洋圖畫書出發,討論海裡的動物和我們的關係,合作畫出一片班級的海。',
  'lesson_plan',
  array['k2', 'k3']::text[],
  array['language', 'aesthetic', 'cognitive']::text[],
  array['語-中-2-6-2', '美-中-2-2-2', '認-中-2-2-3']::text[],
  array['ocean', 'animals']::text[],
  '活動名稱:大海裡有誰?
適用年齡:中班、大班(4-6 歲)
活動時間:約 50 分鐘

一、教學目標
1. 能說出三種住在海裡的動物,並描述其中一種的樣子。
2. 能想像「如果我是那隻海洋動物」會有什麼感覺、想做什麼。
3. 能和同伴一起用線條與色彩完成一張大海報。

二、教學資源
一本海洋主題的圖畫書(例如以鯊魚或海龜為主角的故事)、全開藍色海報紙 2 張、蠟筆、白板與白板筆、海浪聲音檔(選用)。

三、引起動機(10 分鐘)
播放海浪聲,請孩子閉上眼睛猜「這是哪裡的聲音?」。接著問:去過海邊嗎?看到什麼?把孩子說的動物畫或寫在白板上。

四、發展活動(25 分鐘)
1. 共讀圖畫書,停在主角遇到困難的那一頁,問:「如果你是牠,現在心裡是什麼感覺?你會怎麼做?」請 2~3 位孩子用動作演出來。
2. 討論:海裡的動物需要什麼才能好好生活?(乾淨的水、食物、安全的家)垃圾掉進海裡會怎麼樣?
3. 分成兩組,每組一張藍色海報:每個人畫一種自己最喜歡的海洋動物,再一起加上海草、石頭和波浪。

五、綜合活動(15 分鐘)
兩組交換參觀,用「我看到……」說出對方海報上的一個發現。最後全班約定一件「保護大海」做得到的小事(例如垃圾不落地、少用吸管),寫在海報角落。

六、延伸活動
把海報貼在語文區當背景,放入海洋動物圖卡讓孩子說故事;戶外教學去海邊或水族館前,拿出海報回顧「我們想找到誰」。

小提醒:中班以畫為主、老師代筆寫字;大班可以請孩子自己仿寫動物名稱。討論海洋垃圾時著重「我們可以做什麼」,避免讓孩子覺得害怕或自責。',
  50,
  false,
  '臺灣海洋教育中心 幼兒園海洋教育教案〈我知道的大海〉(中大班)',
  'https://tmec.ntou.edu.tw/var/file/16/1016/attach/85/pta_35102_2264817_96315.pdf',
  'asset:assets/lessons/seed-102-cover.svg',
  '[{"title": "引起動機", "description": "聽海浪聲,閉上眼睛猜猜這是哪裡。", "image": "asset:assets/lessons/seed-102-1.svg"}, {"title": "發展活動", "description": "共讀海洋圖畫書:如果你是牠,會有什麼感覺?", "image": "asset:assets/lessons/seed-102-2.svg"}, {"title": "綜合活動", "description": "分組在藍色海報上畫出班級的大海,互相參觀。", "image": "asset:assets/lessons/seed-102-3.svg"}]'::jsonb,
  true,
  'approved',
  timestamptz '2026-11-09 09:00:00+08'
where not exists (
  select 1 from public.resources where title = '大海裡有誰?'
);

-- 已經新增過的舊版本:補上封面與流程圖示(不覆蓋之後換上的實拍照片)
update public.resources
set cover_url = 'asset:assets/lessons/seed-102-cover.svg',
    steps = '[{"title": "引起動機", "description": "聽海浪聲,閉上眼睛猜猜這是哪裡。", "image": "asset:assets/lessons/seed-102-1.svg"}, {"title": "發展活動", "description": "共讀海洋圖畫書:如果你是牠,會有什麼感覺?", "image": "asset:assets/lessons/seed-102-2.svg"}, {"title": "綜合活動", "description": "分組在藍色海報上畫出班級的大海,互相參觀。", "image": "asset:assets/lessons/seed-102-3.svg"}]'::jsonb
where title = '大海裡有誰?'
  and (cover_url is null or cover_url like 'asset:%');

insert into public.resources
  (title, summary, type, age_stages, domains, indicator_codes, themes,
   content, duration_minutes, is_featured, source_name, source_url,
   cover_url, steps, published, review_status, created_at)
select
  '是誰咬了大餅?',
  '用一塊缺了一口的大餅當線索,邊猜邊說故事,練習大聲問問題和重述情節。',
  'lesson_plan',
  array['k1']::text[],
  array['language', 'cognitive']::text[],
  array['語-小-1-5-2', '語-小-2-7-1', '認-小-2-3-2']::text[],
  array['animals', 'food']::text[],
  '活動名稱:是誰咬了大餅?
適用年齡:小班(3-4 歲)
活動時間:約 30 分鐘

一、教學目標
1. 能聽懂故事,說出故事裡出現了哪些動物。
2. 能比較不同缺口的形狀,猜猜是誰咬的。
3. 願意大聲說出「是你咬了我的大餅嗎?」這句話。

二、教學資源
圖畫書《誰咬了我的大餅》、厚紙板做的大餅 1 個(剪出一個半圓形缺口)、小紙餅 5 個(分別剪出尖尖的、兩個門牙的、鋸齒的、大大的缺口)、小豬手偶、小鳥、兔子、狐狸、鱷魚、河馬圖卡。

三、引起動機(5 分鐘)
老師拿著小豬手偶和缺了一口的大餅:「小豬做了一塊好大的餅,睡醒發現被咬了一口!是誰咬的呢?」讓孩子摸摸缺口,說說它是什麼形狀。

四、發展活動(18 分鐘)
1. 共讀故事:每翻到一種動物就先停下來,全班一起幫小豬問:「是你咬了我的大餅嗎?」
2. 比牙印:拿出小紙餅,把缺口和大餅的缺口疊在一起比,「一樣嗎?哪裡不一樣?」請孩子輪流上來比對。
3. 我來演:請孩子抽一張動物圖卡,學那個動物的聲音回答「不是我!你看我咬的是這樣」。

五、綜合活動(7 分鐘)
看著圖卡的順序,全班一起把故事再說一次(老師說前半句,孩子接後半句)。最後揭曉結尾,問:「原來是誰咬的?你有沒有猜到?」

六、延伸活動
把紙餅和圖卡放進語文區,讓孩子自己配對、自己說故事;點心時間咬一口餅乾,看看自己的牙印像誰。

小提醒:小班不必要求說完整句子,敢開口最重要;害羞的孩子可以先和老師一起說、或用手偶代替自己說。',
  30,
  false,
  '北京開放大學學前教育優秀案例〈小班語言領域《誰咬了我的大餅》〉(付佳)',
  'https://fmp.ouchn.edu.cn/webroot/vod/jiaoyusizheng/%E5%B0%8F%E7%8F%AD%E8%AF%AD%E8%A8%80%E6%95%99%E8%82%B2%E6%B4%BB%E5%8A%A8%E3%80%8A%E8%B0%81%E5%92%AC%E4%BA%86%E6%88%91%E7%9A%84%E5%A4%A7%E9%A5%BC%E3%80%8B%E8%AE%BE%E8%AE%A1%E6%96%B9%E6%A1%88%EF%BC%88%E5%8C%97%E4%BA%AC%E5%88%86%E9%83%A8%E4%BB%98%E4%BD%B3).pdf',
  'asset:assets/lessons/seed-103-cover.svg',
  '[{"title": "引起動機", "description": "小豬的大餅被咬了一口!是誰咬的?", "image": "asset:assets/lessons/seed-103-1.svg"}, {"title": "發展活動", "description": "把缺口疊在一起比一比,每種動物的牙印都不一樣。", "image": "asset:assets/lessons/seed-103-2.svg"}, {"title": "綜合活動", "description": "看著圖卡的順序,全班一起把故事再說一次。", "image": "asset:assets/lessons/seed-103-3.svg"}]'::jsonb,
  true,
  'approved',
  timestamptz '2026-11-08 09:00:00+08'
where not exists (
  select 1 from public.resources where title = '是誰咬了大餅?'
);

-- 已經新增過的舊版本:補上封面與流程圖示(不覆蓋之後換上的實拍照片)
update public.resources
set cover_url = 'asset:assets/lessons/seed-103-cover.svg',
    steps = '[{"title": "引起動機", "description": "小豬的大餅被咬了一口!是誰咬的?", "image": "asset:assets/lessons/seed-103-1.svg"}, {"title": "發展活動", "description": "把缺口疊在一起比一比,每種動物的牙印都不一樣。", "image": "asset:assets/lessons/seed-103-2.svg"}, {"title": "綜合活動", "description": "看著圖卡的順序,全班一起把故事再說一次。", "image": "asset:assets/lessons/seed-103-3.svg"}]'::jsonb
where title = '是誰咬了大餅?'
  and (cover_url is null or cover_url like 'asset:%');

insert into public.resources
  (title, summary, type, age_stages, domains, indicator_codes, themes,
   content, duration_minutes, is_featured, source_name, source_url,
   cover_url, steps, published, review_status, created_at)
select
  '我的心情天氣',
  '用晴天、下雨、打雷來說自己的心情,認識開心、難過、生氣,並練習一個讓自己舒服一點的方法。',
  'lesson_plan',
  array['k1', 'k2']::text[],
  array['emotional', 'social']::text[],
  array['情-小-1-2-1', '情-小-2-1-2', '情-中-2-1-1']::text[],
  array['emotions', 'weather', 'school_start']::text[],
  '活動名稱:我的心情天氣
適用年齡:小班、中班(3-5 歲)
活動時間:約 30 分鐘(之後可變成每天晨圈的 3 分鐘例行活動)

一、教學目標
1. 能從表情和動作看出開心、難過、生氣三種心情。
2. 能用表情、動作或一句話說出自己現在的心情。
3. 知道一個讓自己舒服一點的方法(深呼吸、抱抱偶、到安靜角)。

二、教學資源
天氣圖卡 3 張(太陽=開心、下雨=難過、打雷=生氣)、小鏡子數面、每人一個名字夾、心情天氣板(貼在牆上的三格海報)、一隻柔軟的抱抱偶。

三、引起動機(5 分鐘)
老師不說話,做出三種表情(笑、嘟嘴低頭、皺眉叉腰),請孩子猜「老師現在的心情是什麼天氣?」猜對了就把對應的圖卡貼上白板。

四、發展活動(18 分鐘)
1. 照鏡子:每人拿小鏡子,跟著老師的口令做出太陽臉、下雨臉、打雷臉,看看自己的眉毛和嘴巴怎麼變。
2. 什麼時候會這樣?老師說小情境(玩具被拿走、媽媽來接我、積木倒了),孩子跑到對應的天氣圖卡前面站好。提醒:同一件事每個人的天氣可以不一樣。
3. 打雷的時候怎麼辦?一起練習「聞花香、吹蠟燭」的深呼吸三次,再介紹安靜角和抱抱偶:心裡打雷的時候可以去那裡,等天氣變好再回來。

五、綜合活動(7 分鐘)
每個人把自己的名字夾夾到心情天氣板上,願意的孩子說一句「我今天是……,因為……」。老師只接納、不評論。

六、延伸活動
每天早上進教室先夾心情天氣;發生衝突時,先請雙方指出自己的天氣再談事情。

小提醒:不要追問不想說的孩子,也不要說「不可以生氣」——生氣可以,打人不可以。剛入學還在適應的孩子,下雨臉會很多,這是正常的。',
  30,
  true,
  '臺北市立育航幼兒園 孫慧如〈三歲幼兒情緒教育起步走〉',
  'https://www.yhkg.tp.edu.tw/static/pdf/tar/%E4%B8%89%E6%AD%B2%E5%B9%BC%E5%85%92%E6%83%85%E7%B7%92%E6%95%99%E8%82%B2%E8%B5%B7%E6%AD%A5%E8%B5%B0.pdf',
  'asset:assets/lessons/seed-104-cover.svg',
  '[{"title": "引起動機", "description": "老師做表情,猜猜現在是什麼天氣:晴天、下雨還是打雷?", "image": "asset:assets/lessons/seed-104-1.svg"}, {"title": "發展活動", "description": "照鏡子做出太陽臉、下雨臉、打雷臉,再練習深呼吸。", "image": "asset:assets/lessons/seed-104-2.svg"}, {"title": "綜合活動", "description": "把名字夾到心情天氣板上,說說今天的心情。", "image": "asset:assets/lessons/seed-104-3.svg"}]'::jsonb,
  true,
  'approved',
  timestamptz '2026-11-07 09:00:00+08'
where not exists (
  select 1 from public.resources where title = '我的心情天氣'
);

-- 已經新增過的舊版本:補上封面與流程圖示(不覆蓋之後換上的實拍照片)
update public.resources
set cover_url = 'asset:assets/lessons/seed-104-cover.svg',
    steps = '[{"title": "引起動機", "description": "老師做表情,猜猜現在是什麼天氣:晴天、下雨還是打雷?", "image": "asset:assets/lessons/seed-104-1.svg"}, {"title": "發展活動", "description": "照鏡子做出太陽臉、下雨臉、打雷臉,再練習深呼吸。", "image": "asset:assets/lessons/seed-104-2.svg"}, {"title": "綜合活動", "description": "把名字夾到心情天氣板上,說說今天的心情。", "image": "asset:assets/lessons/seed-104-3.svg"}]'::jsonb
where title = '我的心情天氣'
  and (cover_url is null or cover_url like 'asset:%');

insert into public.resources
  (title, summary, type, age_stages, domains, indicator_codes, themes,
   content, duration_minutes, is_featured, source_name, source_url,
   cover_url, steps, published, review_status, created_at)
select
  '謝謝你,抱一個',
  '找出身邊每天幫助我們的人,做一張感謝小卡親手送出去,練習把謝謝說出口。',
  'lesson_plan',
  array['k2']::text[],
  array['social', 'emotional', 'language']::text[],
  array['社-中-3-3-1', '社-中-2-2-2', '社-中-3-3-2']::text[],
  array['family', 'community']::text[],
  '活動名稱:謝謝你,抱一個
適用年齡:中班(4-5 歲)
活動時間:約 40 分鐘

一、教學目標
1. 能說出一位幫助過自己的人,以及他幫了什麼忙。
2. 能用圖畫和一句話做一張感謝小卡。
3. 願意親手把卡片送出去,並說出「謝謝你」。

二、教學資源
園內工作人員的照片或圖卡(廚房阿姨、司機叔叔、警衛、清潔人員、護理師)、對摺小卡紙每人 1 張、蠟筆、貼紙、信封(選用)。

三、引起動機(8 分鐘)
玩「是誰幫了我?」:老師描述一件事(中午的飯菜熱熱的、教室地板亮亮的、早上校門口有人說早安),孩子猜是誰做的,猜對就翻開那個人的照片。

四、發展活動(22 分鐘)
1. 說一說:兩人一組輪流說「我想謝謝……,因為他……」。老師巡迴,幫說不出原因的孩子回想具體的事。
2. 做小卡:封面畫那個人或他做的事,內頁由老師代筆寫下孩子說的那句話,孩子自己簽名或蓋手印。
3. 練習送卡片:在教室裡先演一次——走過去、看著對方、雙手遞出、說「謝謝你」。想抱抱的要先問「我可以抱你嗎?」

五、綜合活動(10 分鐘)
全班一起出發送卡片(事先和對方約好時間)。回教室後圍圈分享:他收到的時候表情怎麼樣?你心裡是什麼感覺?

六、延伸活動
在教室設一個「謝謝信箱」,孩子隨時可以畫小紙條謝謝同學,每週五打開唸出來;要給家人的小卡帶回家,隔天分享家人的反應。

小提醒:抱抱一定要對方同意,不想抱可以改成擊掌或揮手。事先確認每一位被感謝的人都有空,避免有孩子的卡片送不出去。',
  40,
  false,
  '臺北市立萬華幼兒園 主題活動設計〈感恩的季節〉(余秋圜)',
  'https://www-ws.gov.taipei/001/Upload/public/Attachment/33128394047.pdf',
  'asset:assets/lessons/seed-105-cover.svg',
  '[{"title": "引起動機", "description": "是誰幫了我?從照片找出每天照顧我們的人。", "image": "asset:assets/lessons/seed-105-1.svg"}, {"title": "發展活動", "description": "畫一張感謝小卡,老師幫忙寫下想說的話。", "image": "asset:assets/lessons/seed-105-2.svg"}, {"title": "綜合活動", "description": "親手把卡片送出去,看著對方說「謝謝你」。", "image": "asset:assets/lessons/seed-105-3.svg"}]'::jsonb,
  true,
  'approved',
  timestamptz '2026-11-06 09:00:00+08'
where not exists (
  select 1 from public.resources where title = '謝謝你,抱一個'
);

-- 已經新增過的舊版本:補上封面與流程圖示(不覆蓋之後換上的實拍照片)
update public.resources
set cover_url = 'asset:assets/lessons/seed-105-cover.svg',
    steps = '[{"title": "引起動機", "description": "是誰幫了我?從照片找出每天照顧我們的人。", "image": "asset:assets/lessons/seed-105-1.svg"}, {"title": "發展活動", "description": "畫一張感謝小卡,老師幫忙寫下想說的話。", "image": "asset:assets/lessons/seed-105-2.svg"}, {"title": "綜合活動", "description": "親手把卡片送出去,看著對方說「謝謝你」。", "image": "asset:assets/lessons/seed-105-3.svg"}]'::jsonb
where title = '謝謝你,抱一個'
  and (cover_url is null or cover_url like 'asset:%');

insert into public.resources
  (title, summary, type, age_stages, domains, indicator_codes, themes,
   content, duration_minutes, is_featured, source_name, source_url,
   cover_url, steps, published, review_status, created_at)
select
  '春聯小畫家',
  '認識春聯上的吉祥話,用紅紙和粗筆寫畫一張自己的春聯,貼在教室一起迎新年。',
  'lesson_plan',
  array['k3']::text[],
  array['language', 'aesthetic', 'social']::text[],
  array['語-大-1-7-1', '美-大-2-2-2', '社-大-1-6-3']::text[],
  array['lunar_new_year']::text[],
  '活動名稱:春聯小畫家
適用年齡:大班(5-6 歲)
活動時間:約 45 分鐘

一、教學目標
1. 能認出「春」「福」等常見的春聯文字,並說出它的祝福意思。
2. 能運用線條和色彩,寫畫一張自己的春聯。
3. 樂於參與過年的佈置活動,知道除舊佈新的意思。

二、教學資源
真的春聯 3~4 張(春、福、滿、大吉大利)、紅色斗方紙每人 1 張、黑色與金色粗蠟筆或水彩筆、舊報紙、紙膠帶、字卡。

三、引起動機(8 分鐘)
把春聯貼在白板上:「你在哪裡看過這個?上面的字你認識哪一個?」介紹每個字的祝福意思。再把「福」倒過來貼,請孩子猜為什麼有人倒著貼(福「到」了)。

四、發展活動(27 分鐘)
1. 空中寫字:伸出手指跟著老師在空中寫大大的「春」,感覺筆畫從哪裡開始。
2. 我想祝福誰:每人想一個要祝福的人和一句吉祥話,選一個最想寫的字,或把祝福畫成圖(魚=年年有餘、橘子=大吉大利)。
3. 寫畫春聯:在斗方紙上用粗筆寫字或畫圖,再用金色筆加上邊框花紋。不要求筆順正確,重點是大膽下筆。

五、綜合活動(10 分鐘)
一人一句介紹自己的春聯要送給誰。全班決定教室哪裡要貼,一起動手佈置。

六、延伸活動
帶一張回家貼在自己的房門,拍照帶回來分享;語文區放字卡和紅紙,讓孩子繼續寫。

小提醒:水彩會滴,桌面先鋪報紙、袖子捲起來;不想寫字的孩子用畫的也可以,老師幫忙在旁邊寫上他說的吉祥話。',
  45,
  false,
  '教育大市集〈歡喜過新年〉(高雄市忠孝國小附設幼兒園 翁意婷、黃秀珠、阮玉文)',
  'https://market.cloud.edu.tw/resources/web/1649752',
  'asset:assets/lessons/seed-106-cover.svg',
  '[{"title": "引起動機", "description": "認識春聯上的字;「福」為什麼要倒著貼?", "image": "asset:assets/lessons/seed-106-1.svg"}, {"title": "發展活動", "description": "在紅紙上用粗筆寫一個字,或把祝福畫成圖。", "image": "asset:assets/lessons/seed-106-2.svg"}, {"title": "綜合活動", "description": "一起把春聯貼在教室,介紹要送給誰。", "image": "asset:assets/lessons/seed-106-3.svg"}]'::jsonb,
  true,
  'approved',
  timestamptz '2026-11-05 09:00:00+08'
where not exists (
  select 1 from public.resources where title = '春聯小畫家'
);

-- 已經新增過的舊版本:補上封面與流程圖示(不覆蓋之後換上的實拍照片)
update public.resources
set cover_url = 'asset:assets/lessons/seed-106-cover.svg',
    steps = '[{"title": "引起動機", "description": "認識春聯上的字;「福」為什麼要倒著貼?", "image": "asset:assets/lessons/seed-106-1.svg"}, {"title": "發展活動", "description": "在紅紙上用粗筆寫一個字,或把祝福畫成圖。", "image": "asset:assets/lessons/seed-106-2.svg"}, {"title": "綜合活動", "description": "一起把春聯貼在教室,介紹要送給誰。", "image": "asset:assets/lessons/seed-106-3.svg"}]'::jsonb
where title = '春聯小畫家'
  and (cover_url is null or cover_url like 'asset:%');

insert into public.resources
  (title, summary, type, age_stages, domains, indicator_codes, themes,
   content, duration_minutes, is_featured, source_name, source_url,
   cover_url, steps, published, review_status, created_at)
select
  '年獸來了!',
  '把年獸的故事演出來:用身體變年獸、用鍋蓋和鈴鼓把牠趕跑,認識紅色、鞭炮和守歲的由來。',
  'lesson_plan',
  array['k2', 'k3']::text[],
  array['aesthetic', 'language', 'physical']::text[],
  array['美-中-2-2-6', '語-中-2-1-1', '美-中-2-2-3']::text[],
  array['lunar_new_year']::text[],
  '活動名稱:年獸來了!
適用年齡:中班、大班(4-6 歲)
活動時間:約 40 分鐘

一、教學目標
1. 能用肢體動作演出年獸走路、害怕、逃跑的樣子。
2. 能和同伴分配角色,一起演出一段故事。
3. 能跟著鼓聲的快慢和強弱改變動作。

二、教學資源
年獸故事圖卡或圖畫書、鈴鼓、手鼓、鍋蓋或響板、紅色絲巾或皺紋紙條、大塊紅布 1 條。

三、引起動機(8 分鐘)
關燈、壓低聲音說故事:很久以前有一隻怪獸叫「年」,每到冬天最後一個晚上就下山……說到年獸害怕三樣東西時停下來,讓孩子猜是什麼(紅色、火光、很大的聲音)。

四、發展活動(22 分鐘)
1. 變身年獸:鼓聲慢而重是年獸大步走,鼓聲快是年獸跑,鼓聲停就定格。請孩子想想年獸的手和臉是什麼樣子。
2. 村民準備:另一半孩子當村民,討論要用什麼嚇跑年獸,分配誰揮紅絲巾、誰敲鍋蓋、誰搖鈴鼓。
3. 演出來:年獸從教室一邊出場,村民躲好;老師喊「年獸來了!」村民一起發出聲音、揮紅布,年獸做出害怕的樣子逃回山上。兩組交換角色再演一次。

五、綜合活動(10 分鐘)
圍圈討論:當年獸的時候身體是什麼感覺?聽到很大的聲音時你想做什麼?最後連回生活:所以過年我們會貼紅色的春聯、放鞭炮、晚上不睡覺守歲。

六、延伸活動
在扮演區放紅布和樂器讓孩子自己演;美勞區用紙盤做年獸面具。

小提醒:對大聲音敏感的孩子先當「點燈的人」(拿手電筒),或站在離樂器遠一點的位置。追逐的範圍先用膠帶貼出來,提醒年獸只能逃、不能撞人。',
  40,
  false,
  '教育大市集〈歡喜過新年〉(高雄市忠孝國小附設幼兒園 翁意婷、黃秀珠、阮玉文)',
  'https://market.cloud.edu.tw/resources/web/1649752',
  'asset:assets/lessons/seed-107-cover.svg',
  '[{"title": "引起動機", "description": "關燈說故事:年獸最怕哪三樣東西?", "image": "asset:assets/lessons/seed-107-1.svg"}, {"title": "發展活動", "description": "跟著鼓聲變身年獸:慢慢走、快快跑、定格。", "image": "asset:assets/lessons/seed-107-2.svg"}, {"title": "綜合活動", "description": "村民揮紅布、敲鍋蓋,一起把年獸趕回山上。", "image": "asset:assets/lessons/seed-107-3.svg"}]'::jsonb,
  true,
  'approved',
  timestamptz '2026-11-04 09:00:00+08'
where not exists (
  select 1 from public.resources where title = '年獸來了!'
);

-- 已經新增過的舊版本:補上封面與流程圖示(不覆蓋之後換上的實拍照片)
update public.resources
set cover_url = 'asset:assets/lessons/seed-107-cover.svg',
    steps = '[{"title": "引起動機", "description": "關燈說故事:年獸最怕哪三樣東西?", "image": "asset:assets/lessons/seed-107-1.svg"}, {"title": "發展活動", "description": "跟著鼓聲變身年獸:慢慢走、快快跑、定格。", "image": "asset:assets/lessons/seed-107-2.svg"}, {"title": "綜合活動", "description": "村民揮紅布、敲鍋蓋,一起把年獸趕回山上。", "image": "asset:assets/lessons/seed-107-3.svg"}]'::jsonb
where title = '年獸來了!'
  and (cover_url is null or cover_url like 'asset:%');

insert into public.resources
  (title, summary, type, age_stages, domains, indicator_codes, themes,
   content, duration_minutes, is_featured, source_name, source_url,
   cover_url, steps, published, review_status, created_at)
select
  '校門口的交通小調查',
  '到校門口數一數經過的車,用貼紙做成統計圖,討論哪一種最多、為什麼。',
  'lesson_plan',
  array['k3']::text[],
  array['cognitive', 'social']::text[],
  array['認-大-1-1-4', '認-大-2-1-5', '社-大-1-5-1']::text[],
  array['vehicles', 'community']::text[],
  '活動名稱:校門口的交通小調查
適用年齡:大班(5-6 歲)
活動時間:約 50 分鐘(戶外觀察 15 分鐘)

一、教學目標
1. 能用點數的方式,記錄經過校門口的交通工具數量。
2. 能把記錄整理成圖表,比較哪一種最多、哪一種最少。
3. 能說出社區裡的交通工具和自己生活的關係。

二、教學資源
記錄板與記錄單每組 1 份(印有汽車、機車、公車、腳踏車、貨車的圖,旁邊留空格畫記號)、鉛筆、圓點貼紙、全開海報紙(畫好五欄)、計時器。

三、引起動機(8 分鐘)
問:「你今天是怎麼來學校的?」請孩子站到對應的圖卡後面排成一排,比比看哪一排最長。接著提出問題:「那校門口經過最多的是什麼車?我們怎麼知道?」

四、發展活動(30 分鐘)
1. 分工:四人一組,一人負責看一種車,看到就在記錄單上畫一條線;第四個人當計時員。
2. 出發觀察:在校門口內側的安全區域站定,觀察 10 分鐘。老師提醒只記「經過」的車,停著的不算。
3. 做統計圖:回教室後,各組把自己的線條數一數,換成圓點貼紙貼到全班的大海報上,一欄一種車,從下往上貼。

五、綜合活動(12 分鐘)
看著海報討論:哪一欄最高?和早上「我們怎麼來學校」的隊伍一樣嗎?為什麼機車這麼多、公車這麼少?如果換成放學時間,會不會不一樣?

六、延伸活動
換一個時間再調查一次,把兩張圖表貼在一起比較;在積木區蓋出校門口的馬路,用小車子重現調查的結果。

小提醒:全程待在校門內側或人行道內側,每組配一位大人;出發前先約定「眼睛看車、腳不離開線」。數量超過 10 的組別,老師帶著五個一數。',
  50,
  false,
  '教育部《幼兒園教保活動課程—課程發展參考實例》〈生活中的交通工具〉',
  null,
  'asset:assets/lessons/seed-108-cover.svg',
  '[{"title": "引起動機", "description": "你今天怎麼來學校?站到圖卡後面排排看。", "image": "asset:assets/lessons/seed-108-1.svg"}, {"title": "發展活動", "description": "到校門口分組記錄:看到一輛就畫一條線。", "image": "asset:assets/lessons/seed-108-2.svg"}, {"title": "綜合活動", "description": "把記錄換成圓點貼紙,做成全班的統計圖。", "image": "asset:assets/lessons/seed-108-3.svg"}]'::jsonb,
  true,
  'approved',
  timestamptz '2026-11-03 09:00:00+08'
where not exists (
  select 1 from public.resources where title = '校門口的交通小調查'
);

-- 已經新增過的舊版本:補上封面與流程圖示(不覆蓋之後換上的實拍照片)
update public.resources
set cover_url = 'asset:assets/lessons/seed-108-cover.svg',
    steps = '[{"title": "引起動機", "description": "你今天怎麼來學校?站到圖卡後面排排看。", "image": "asset:assets/lessons/seed-108-1.svg"}, {"title": "發展活動", "description": "到校門口分組記錄:看到一輛就畫一條線。", "image": "asset:assets/lessons/seed-108-2.svg"}, {"title": "綜合活動", "description": "把記錄換成圓點貼紙,做成全班的統計圖。", "image": "asset:assets/lessons/seed-108-3.svg"}]'::jsonb
where title = '校門口的交通小調查'
  and (cover_url is null or cover_url like 'asset:%');

insert into public.resources
  (title, summary, type, age_stages, domains, indicator_codes, themes,
   content, duration_minutes, is_featured, source_name, source_url,
   cover_url, steps, published, review_status, created_at)
select
  '我長大了!',
  '比一比小時候和現在的自己,找出一件「我現在會做了」的事,做成成長小書的一頁。',
  'lesson_plan',
  array['k1', 'k2']::text[],
  array['social', 'physical', 'language']::text[],
  array['社-小-1-1-1', '社-小-1-1-2', '身-小-1-1-1']::text[],
  array['my_body', 'family']::text[],
  '活動名稱:我長大了!
適用年齡:小班、中班(3-5 歲)
活動時間:約 35 分鐘(活動前一週請家長提供一張嬰兒時期的照片)

一、教學目標
1. 能指出並說出自己身體的部位,比較小時候和現在哪裡不一樣。
2. 能說出一件自己現在會做、小時候不會做的事。
3. 能欣賞自己和同伴的成長。

二、教學資源
每人一張嬰兒時期的照片、嬰兒的小襪子或小衣服 1~2 件、全身鏡、身高尺或一條長紙條、A4 圖畫紙每人 1 張、蠟筆。

三、引起動機(8 分鐘)
玩「猜猜這是誰?」:老師隨機抽出嬰兒照,全班猜是哪位同學。再拿出嬰兒小襪子,請一位孩子試穿:「穿得下嗎?為什麼?」

四、發展活動(20 分鐘)
1. 身體比一比:看著鏡子和照片,說說手、腳、頭髮、牙齒哪裡變了。老師帶著唱身體部位的兒歌,摸到哪裡唱到哪裡。
2. 量一量:每個人靠著牆上的紙條畫下自己的身高,寫上名字,看看自己到哪裡。
3. 我會了:輪流說並做出來「我現在會自己……」(穿鞋、扣扣子、溜滑梯、用湯匙)。說不出來的孩子,請同學幫他想。

五、綜合活動(7 分鐘)
在圖畫紙上畫「我現在會做的一件事」,老師在旁邊寫下孩子的話,貼上嬰兒照,就是成長小書的第一頁。

六、延伸活動
學期末再量一次身高,在同一條紙條上畫新的線;請家長在聯絡簿寫一句「我發現孩子長大的地方」,晨圈時唸給孩子聽。

小提醒:有些孩子沒有嬰兒時期的照片(領養、寄養或照片遺失),事前個別詢問家長,可以改用「剛入學時的照片」或由老師幫他畫一張,避免孩子在活動中落單。',
  35,
  false,
  '教育部《幼兒園教保活動課程—課程發展參考實例》〈期待我長大〉',
  null,
  'asset:assets/lessons/seed-109-cover.svg',
  '[{"title": "引起動機", "description": "猜猜這張嬰兒照是誰?小襪子還穿得下嗎?", "image": "asset:assets/lessons/seed-109-1.svg"}, {"title": "發展活動", "description": "靠著牆量身高,比比小時候和現在哪裡不一樣。", "image": "asset:assets/lessons/seed-109-2.svg"}, {"title": "綜合活動", "description": "畫下「我現在會做的一件事」,做成成長小書。", "image": "asset:assets/lessons/seed-109-3.svg"}]'::jsonb,
  true,
  'approved',
  timestamptz '2026-11-02 09:00:00+08'
where not exists (
  select 1 from public.resources where title = '我長大了!'
);

-- 已經新增過的舊版本:補上封面與流程圖示(不覆蓋之後換上的實拍照片)
update public.resources
set cover_url = 'asset:assets/lessons/seed-109-cover.svg',
    steps = '[{"title": "引起動機", "description": "猜猜這張嬰兒照是誰?小襪子還穿得下嗎?", "image": "asset:assets/lessons/seed-109-1.svg"}, {"title": "發展活動", "description": "靠著牆量身高,比比小時候和現在哪裡不一樣。", "image": "asset:assets/lessons/seed-109-2.svg"}, {"title": "綜合活動", "description": "畫下「我現在會做的一件事」,做成成長小書。", "image": "asset:assets/lessons/seed-109-3.svg"}]'::jsonb
where title = '我長大了!'
  and (cover_url is null or cover_url like 'asset:%');

insert into public.resources
  (title, summary, type, age_stages, domains, indicator_codes, themes,
   content, duration_minutes, is_featured, source_name, source_url,
   cover_url, steps, published, review_status, created_at)
select
  '雪花定格舞',
  '冬天或下雨天在教室裡動起來:跟著音樂當雪花飄、音樂一停就結冰,練平衡也練煞車。',
  'lesson_plan',
  array['k2', 'k3']::text[],
  array['physical', 'aesthetic']::text[],
  array['身-中-1-1-2', '身-中-2-1-2', '美-中-2-2-3']::text[],
  array['winter', 'weather']::text[],
  '活動名稱:雪花定格舞
適用年齡:中班、大班(4-6 歲)
活動時間:約 25 分鐘

一、教學目標
1. 能跟著音樂的快慢做出旋轉、飄落、滑行等動作。
2. 音樂停止時能馬上停住,維持平衡三秒鐘。
3. 能在團體活動中注意自己和別人的距離。

二、教學資源
一首有快有慢的輕音樂、可以隨時暫停的播放器、白色絲巾或面紙每人 1 張(選用)、地板膠帶(貼出活動範圍)。

三、引起動機(5 分鐘)
請孩子搓搓手、摸摸臉:「冬天身體哪裡最冷?」再問:「雪花從天上掉下來是怎麼動的?」請兩三位孩子示範,全班模仿。

四、發展活動(15 分鐘)
1. 雪花飄:音樂開始,每個人是一片雪花,在範圍內慢慢轉、輕輕飄。老師口頭提示「風變大了」(加快)、「風停了」(變慢)。
2. 結冰了:音樂一停,全部定格。第一輪雙腳站好;第二輪單腳站;第三輪要結成「很高的冰」或「很矮的冰」。
3. 雪花找朋友:音樂停的時候,老師喊一個數字,那麼多片雪花要靠在一起變成一個大雪球(不能推擠)。

五、綜合活動(5 分鐘)
音樂變得很慢,雪花慢慢落到地上、躺平融化。躺著摸摸胸口:「心臟跳得快不快?身體現在是冷的還是熱的?」

六、延伸活動
把絲巾往上丟、在落地前接住;戶外有落葉的日子,改成「落葉定格舞」。

小提醒:旋轉容易頭暈,每次轉不超過三圈就換方向;活動前把桌椅靠邊,襪子會滑的孩子請他脫掉襪子。',
  25,
  false,
  'Good2Know Network〈Cold Weather Activities: Indoor Movement Ideas for Young Children〉',
  'https://good2knownetwork.org/cold-weather-activities-indoor-movement-ideas-for-young-children/',
  'asset:assets/lessons/seed-110-cover.svg',
  '[{"title": "引起動機", "description": "搓搓手:冬天哪裡最冷?雪花是怎麼飄的?", "image": "asset:assets/lessons/seed-110-1.svg"}, {"title": "發展活動", "description": "音樂響起當雪花飄,音樂一停就結冰定格。", "image": "asset:assets/lessons/seed-110-2.svg"}, {"title": "綜合活動", "description": "雪花慢慢落地融化,躺著摸摸自己的心跳。", "image": "asset:assets/lessons/seed-110-3.svg"}]'::jsonb,
  true,
  'approved',
  timestamptz '2026-11-01 09:00:00+08'
where not exists (
  select 1 from public.resources where title = '雪花定格舞'
);

-- 已經新增過的舊版本:補上封面與流程圖示(不覆蓋之後換上的實拍照片)
update public.resources
set cover_url = 'asset:assets/lessons/seed-110-cover.svg',
    steps = '[{"title": "引起動機", "description": "搓搓手:冬天哪裡最冷?雪花是怎麼飄的?", "image": "asset:assets/lessons/seed-110-1.svg"}, {"title": "發展活動", "description": "音樂響起當雪花飄,音樂一停就結冰定格。", "image": "asset:assets/lessons/seed-110-2.svg"}, {"title": "綜合活動", "description": "雪花慢慢落地融化,躺著摸摸自己的心跳。", "image": "asset:assets/lessons/seed-110-3.svg"}]'::jsonb
where title = '雪花定格舞'
  and (cover_url is null or cover_url like 'asset:%');

-- 標籤
insert into public.tags (name) values
  ('主題課程'),
  ('免教具'),
  ('口語表達'),
  ('合作創作'),
  ('品格教育'),
  ('大肌肉'),
  ('小組活動'),
  ('律動'),
  ('情緒教育'),
  ('感官探索'),
  ('感恩'),
  ('戲劇扮演'),
  ('推理遊戲'),
  ('數學'),
  ('文字探索'),
  ('晨圈活動'),
  ('海洋教育'),
  ('班級經營'),
  ('環境佈置'),
  ('生命教育'),
  ('社區探索'),
  ('節慶'),
  ('繪本'),
  ('自我認識'),
  ('親師合作'),
  ('雨天備案'),
  ('食農教育')
on conflict (name) do nothing;

insert into public.resource_tags (resource_id, tag_id)
select r.id, t.id
from (
  values
    ('摸摸看,是玉米!', '食農教育'),
    ('摸摸看,是玉米!', '感官探索'),
    ('摸摸看,是玉米!', '主題課程'),
    ('大海裡有誰?', '海洋教育'),
    ('大海裡有誰?', '繪本'),
    ('大海裡有誰?', '合作創作'),
    ('是誰咬了大餅?', '繪本'),
    ('是誰咬了大餅?', '口語表達'),
    ('是誰咬了大餅?', '推理遊戲'),
    ('我的心情天氣', '情緒教育'),
    ('我的心情天氣', '晨圈活動'),
    ('我的心情天氣', '班級經營'),
    ('謝謝你,抱一個', '品格教育'),
    ('謝謝你,抱一個', '感恩'),
    ('謝謝你,抱一個', '小組活動'),
    ('春聯小畫家', '節慶'),
    ('春聯小畫家', '文字探索'),
    ('春聯小畫家', '環境佈置'),
    ('年獸來了!', '節慶'),
    ('年獸來了!', '戲劇扮演'),
    ('年獸來了!', '律動'),
    ('校門口的交通小調查', '數學'),
    ('校門口的交通小調查', '社區探索'),
    ('校門口的交通小調查', '主題課程'),
    ('我長大了!', '自我認識'),
    ('我長大了!', '生命教育'),
    ('我長大了!', '親師合作'),
    ('雪花定格舞', '律動'),
    ('雪花定格舞', '大肌肉'),
    ('雪花定格舞', '雨天備案'),
    ('雪花定格舞', '免教具')
) as pair(title, tag)
join public.resources r on r.title = pair.title
join public.tags t on t.name = pair.tag
on conflict do nothing;
