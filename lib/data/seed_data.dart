import '../models/resource.dart';
import '../models/taxonomy.dart';

/// 內建示範資料:未連線 Supabase 時的資料來源。
/// 內容與 supabase/seed.sql 相同,修改時請兩邊同步。
final List<Resource> seedResources = [
  Resource(
    id: 'seed-001',
    title: '瓶蓋顏色分類盒',
    summary: '用回收鞋盒和瓶蓋做的顏色分類教具,訓練顏色辨識與手眼協調。',
    type: ResourceType.craft,
    ages: const [AgeStage.toddler, AgeStage.k1],
    domains: const [LearningDomain.cognitive, LearningDomain.physical],
    tags: const ['顏色認知', '回收材料', '分類配對'],
    themes: const ['colors_shapes', 'recycling'],
    indicatorCodes: const ['認-小-1-3-1', '身-幼-1-2-2', '身-小-2-2-2'],
    materials: const [
      '鞋盒或厚紙盒 1 個',
      '各色瓶蓋 20~30 個',
      '六色色紙',
      '白膠或雙面膠',
      '剪刀',
      '美工刀(大人使用)',
    ],
    steps: const [
      ResourceStep(
        title: '準備分類格',
        description: '在鞋盒內用厚紙板隔出 6 格,每格底部貼上一種顏色的色紙。',
      ),
      ResourceStep(
        title: '開投入口(選用)',
        description: '在盒蓋割出 6 個圓形投入口,口緣貼上對應顏色,增加投擲樂趣。',
      ),
      ResourceStep(title: '收集瓶蓋', description: '洗淨晾乾各色瓶蓋,每種顏色至少準備 4 個。'),
      ResourceStep(title: '示範玩法', description: '示範拿起瓶蓋、說出顏色、放入對應格子,再讓孩子自己操作。'),
    ],
    content:
        '延伸玩法:可以加入小夾子,讓孩子改用夾的方式放瓶蓋,增加精細動作難度;'
        '也可以把顏色換成形狀,變成形狀分類盒。',
    difficulty: 1,
    durationMinutes: 30,
    isFeatured: true,
    createdAt: DateTime(2026, 8, 10, 9),
  ),
  Resource(
    id: 'seed-002',
    title: '情緒臉譜轉盤',
    summary: '和孩子一起認識開心、生氣、難過、害怕等情緒,晨圈分享的好幫手。',
    type: ResourceType.craft,
    ages: const [AgeStage.k2, AgeStage.k3],
    domains: const [LearningDomain.emotional, LearningDomain.social],
    tags: const ['情緒教育', '晨圈活動'],
    themes: const ['emotions'],
    indicatorCodes: const ['情-中-1-1-1', '情-大-1-1-2'],
    materials: const ['圓形厚紙板 1 張', '雙腳釘 1 個', '箭頭形紙板 1 支', '彩色筆', '護貝膜(選用)'],
    steps: const [
      ResourceStep(
        title: '畫出情緒分區',
        description: '把圓形紙板均分成 6 區,分別畫上開心、生氣、難過、害怕、驚訝、平靜的臉譜。',
      ),
      ResourceStep(title: '製作指針', description: '剪一支箭頭形紙板,用雙腳釘固定在圓心,確認可以順暢轉動。'),
      ResourceStep(title: '護貝加固', description: '常用教具建議護貝或貼上透明膠帶,延長使用壽命。'),
    ],
    content:
        '使用方式:晨圈時間讓孩子轉動指針,說一說「我今天的心情」並分享原因;'
        '也可以由老師描述情境,請孩子把指針轉到對應的情緒。',
    difficulty: 1,
    durationMinutes: 40,
    isFeatured: true,
    createdAt: DateTime(2026, 8, 8, 9),
  ),
  Resource(
    id: 'seed-003',
    title: '寶特瓶冷靜瓶',
    summary: '搖一搖、看亮片慢慢落下,幫助孩子在情緒高漲時安定下來。',
    type: ResourceType.craft,
    ages: const [AgeStage.toddler, AgeStage.k1, AgeStage.k2],
    domains: const [LearningDomain.emotional],
    tags: const ['情緒安撫', '感官探索'],
    themes: const ['emotions', 'recycling'],
    materials: const ['小型透明寶特瓶 1 個', '亮片與亮粉', '透明膠水', '溫水', '熱熔膠(封蓋用,大人操作)'],
    steps: const [
      ResourceStep(title: '調配比例', description: '瓶中倒入約三分之一透明膠水、三分之二溫水,攪拌均勻。'),
      ResourceStep(
        title: '加入亮片',
        description: '放入亮片與亮粉,蓋緊搖勻,測試落下速度;落太快就再補一點膠水。',
      ),
      ResourceStep(title: '封緊瓶蓋', description: '用熱熔膠封住瓶蓋防止孩子打開,完成。'),
    ],
    content:
        '使用時機:孩子情緒激動時,邀請他搖一搖冷靜瓶,一起看亮片落下、做三次深呼吸,'
        '等亮片都落到瓶底,再說說剛剛發生什麼事。',
    difficulty: 1,
    durationMinutes: 20,
    createdAt: DateTime(2026, 8, 6, 9),
  ),
  Resource(
    id: 'seed-004',
    title: '注音符號釣魚組',
    summary: '用磁鐵釣竿釣注音魚卡,邊玩邊熟悉注音符號。',
    type: ResourceType.play,
    ages: const [AgeStage.k3],
    domains: const [LearningDomain.language],
    tags: const ['注音', '識字遊戲', '小組活動'],
    themes: const ['ocean'],
    materials: const ['注音符號魚形卡(護貝)', '迴紋針', '磁鐵釣竿'],
    content:
        '基本玩法:\n'
        '一、老師唸出注音,孩子釣出正確的魚卡。\n'
        '二、孩子釣到魚卡後唸出符號,再想一個開頭是這個音的詞。\n\n'
        '進階玩法:兩人限時比賽釣魚,結束後輪流唸出手上的符號;'
        '也可以換成數字卡、形狀卡,變化成不同主題。\n\n'
        '小提醒:迴紋針務必固定牢靠並定期檢查,避免脫落造成誤食風險。',
    durationMinutes: 20,
    createdAt: DateTime(2026, 8, 4, 9),
  ),
  Resource(
    id: 'seed-005',
    title: '彩虹米感官箱',
    summary: '把白米染成彩虹色,打造孩子玩不膩的感官探索箱。',
    type: ResourceType.craft,
    ages: const [AgeStage.toddler, AgeStage.k1],
    domains: const [LearningDomain.cognitive, LearningDomain.aesthetic],
    tags: const ['感官探索', '顏色認知'],
    themes: const ['colors_shapes'],
    materials: const ['白米 3~5 杯', '食用色素', '夾鏈袋', '白醋少許', '大收納箱', '杯子、湯匙、漏斗等工具'],
    steps: const [
      ResourceStep(title: '染色', description: '每袋米加入幾滴色素與少許白醋,封緊袋口搓揉均勻。'),
      ResourceStep(title: '晾乾', description: '把米平鋪在烘焙紙上,晾乾一個晚上。'),
      ResourceStep(title: '佈置感官箱', description: '倒入收納箱,放進杯子、湯匙、漏斗和小玩偶,即完成。'),
    ],
    content:
        '引導語舉例:「你聽,米流下來的聲音像什麼?」鼓勵孩子倒、舀、抓、藏寶。'
        '收拾也是活動的一部分,請孩子一起把米掃回箱子裡。',
    difficulty: 2,
    durationMinutes: 60,
    createdAt: DateTime(2026, 8, 2, 9),
  ),
  Resource(
    id: 'seed-006',
    title: '「小種子長大了」主題教案',
    summary: '從繪本出發,帶孩子種下種子、觀察發芽,認識植物的生長。',
    type: ResourceType.lessonPlan,
    ages: const [AgeStage.k1],
    domains: const [LearningDomain.cognitive, LearningDomain.language],
    tags: const ['植物', '生命教育', '主題課程'],
    themes: const ['plants', 'spring'],
    indicatorCodes: const ['認-小-1-2-1', '認-小-1-2-3'],
    content:
        '活動名稱:小種子長大了\n'
        '適用年齡:小班(3-4 歲)\n'
        '活動時間:約 40 分鐘(後續持續觀察兩週)\n\n'
        '一、教學目標\n'
        '1. 能說出種子發芽需要水和陽光。\n'
        '2. 願意動手種植並持續照顧。\n'
        '3. 能用簡單詞彙描述觀察到的變化。\n\n'
        '二、引起動機(10 分鐘)\n'
        '共讀繪本《小種籽》,討論:種子睡在土裡,需要什麼才能長大?\n\n'
        '三、發展活動(20 分鐘)\n'
        '1. 每人發一個布丁盒、培養土與綠豆種子。\n'
        '2. 引導孩子鬆土、放入種子、輕輕覆土、澆水。\n'
        '3. 貼上名字貼紙,放到窗邊的「小小農場」區。\n\n'
        '四、綜合活動(10 分鐘)\n'
        '畫下「我的種子現在的樣子」,老師協助記錄日期,之後每週觀察記錄一次。\n\n'
        '五、延伸活動\n'
        '搭配歌曲做生長律動:蹲下(種子)→ 慢慢站起(發芽)→ 張開手臂(長出葉子)。',
    durationMinutes: 40,
    isFeatured: true,
    createdAt: DateTime(2026, 7, 30, 9),
  ),
  Resource(
    id: 'seed-007',
    title: '動物運動會律動教案',
    summary: '不需任何教具的大肌肉活動,學小動物走路、跳躍、爬行。',
    type: ResourceType.lessonPlan,
    ages: const [AgeStage.toddler, AgeStage.k1],
    domains: const [LearningDomain.physical, LearningDomain.aesthetic],
    tags: const ['律動', '大肌肉', '免教具', '雨天備案'],
    themes: const ['animals'],
    indicatorCodes: const ['身-幼-1-1-2', '身-小-2-1-1'],
    content:
        '活動名稱:動物運動會\n'
        '適用年齡:幼幼班~小班\n'
        '活動時間:20 分鐘\n\n'
        '一、教學目標\n'
        '1. 練習走、跑、跳、爬等基本動作。\n'
        '2. 願意跟著音樂與指令變換動作。\n\n'
        '二、活動流程\n'
        '1. 暖身(5 分鐘):跟著音樂拍手、踏步。\n'
        '2. 動物模仿(10 分鐘):老師抽動物圖卡,孩子模仿——兔子雙腳跳、大象甩鼻子慢慢走、'
        '小鳥張開翅膀跑、烏龜手腳著地慢慢爬、青蛙蹲跳。\n'
        '3. 緩和(5 分鐘):變成小貓咪,輕輕伸懶腰、躺下休息。\n\n'
        '三、小提醒\n'
        '場地先淨空並提醒孩子保持距離;可以讓孩子輪流抽卡,當一次小老師。',
    durationMinutes: 20,
    createdAt: DateTime(2026, 7, 28, 9),
  ),
  Resource(
    id: 'seed-008',
    title: '形狀配對學習單',
    summary: '圓形、三角形、正方形的連連看與著色練習,附延伸活動建議。',
    type: ResourceType.worksheet,
    ages: const [AgeStage.k1, AgeStage.k2],
    domains: const [LearningDomain.cognitive],
    tags: const ['形狀', '學習單'],
    themes: const ['colors_shapes'],
    indicatorCodes: const ['認-小-1-1-1'],
    content:
        '內容說明:學習單共兩頁——第一頁為形狀與生活物品連連看'
        '(圓形-時鐘、三角形-三明治、正方形-窗戶);'
        '第二頁為形狀著色(圓形塗紅色、三角形塗黃色、正方形塗藍色)。\n\n'
        '使用建議:\n'
        '一、先進行實物觀察:請孩子在教室裡找一找「圓圓的東西」。\n'
        '二、完成學習單後,延伸玩「形狀踩踩樂」:地上貼大型形狀,老師喊名稱、孩子跳上去。\n\n'
        '(檔案下載功能將於第二階段開放,目前內容供老師參考自行製作。)',
    createdAt: DateTime(2026, 7, 26, 9),
  ),
  Resource(
    id: 'seed-009',
    title: '我的心情日記學習單',
    summary: '讓大班孩子每天圈選心情臉譜、畫下事件,練習覺察與表達情緒。',
    type: ResourceType.worksheet,
    ages: const [AgeStage.k3],
    domains: const [LearningDomain.emotional, LearningDomain.language],
    tags: const ['情緒教育', '書寫前準備'],
    themes: const ['emotions'],
    content:
        '內容說明:表格式一週心情記錄,每天圈選一個心情臉譜(開心/平靜/難過/生氣),'
        '並在空格畫下「今天發生的一件事」。\n\n'
        '使用建議:\n'
        '一、固定在放學前 10 分鐘進行,養成回顧的習慣。\n'
        '二、週五小組分享:「這週我最開心的一天」。\n'
        '三、老師可以從記錄中留意需要關心的孩子,主動關懷。',
    createdAt: DateTime(2026, 7, 24, 9),
  ),
  Resource(
    id: 'seed-010',
    title: '磁性積木挑選與玩法',
    summary: '建構類經典教玩具,怎麼挑、怎麼帶孩子玩出空間概念。',
    type: ResourceType.product,
    ages: const [AgeStage.k2, AgeStage.k3],
    domains: const [LearningDomain.cognitive, LearningDomain.aesthetic],
    tags: const ['建構遊戲', '空間概念'],
    themes: const ['colors_shapes'],
    indicatorCodes: const ['認-大-1-1-1', '認-中-2-3-1'],
    content:
        '挑選重點:\n'
        '一、磁力適中——太弱作品容易垮,太強小手拆不開。\n'
        '二、邊角圓滑,並通過 ST 安全玩具或 CNS 檢驗標章。\n'
        '三、基礎幾何片(三角形、正方形)數量要足,比特殊造型片實用。\n\n'
        '玩法建議:\n'
        '中班——平面拼圖:拼出房子、魚、火箭的輪廓。\n'
        '大班——立體挑戰:蓋出「能站住的高塔」「有屋頂的房子」,'
        '過程中引導討論:為什麼會倒?怎麼放比較穩?\n\n'
        '收納小技巧:依形狀分盒收納,請孩子當「分類小幫手」。',
    isFeatured: true,
    createdAt: DateTime(2026, 7, 22, 9),
  ),
  Resource(
    id: 'seed-011',
    title: '平衡步道',
    summary: '訓練平衡感與動作計畫的感覺統合教具,附課堂使用方式。',
    type: ResourceType.product,
    ages: const [AgeStage.all],
    domains: const [LearningDomain.physical],
    tags: const ['感覺統合', '大肌肉'],
    themes: const ['my_body'],
    indicatorCodes: const ['身-幼-2-1-1', '身-小-2-1-1'],
    content:
        '挑選重點:防滑底座、承重足夠,並且可以自由組合高低與彎直路線。\n\n'
        '使用方式:\n'
        '一、基本走:雙手平舉走完步道。\n'
        '二、變化走:倒著走、踮腳走、端著沙包走。\n'
        '三、組合關卡:搭配呼拉圈(跳)、桌子(鑽),組成小小體能循環。\n\n'
        '安全提醒:一次一人上道、周圍鋪好軟墊,老師站在側邊隨時保護。',
    createdAt: DateTime(2026, 7, 20, 9),
  ),
  Resource(
    id: 'seed-012',
    title: '學習區佈置的五個原則',
    summary: '學習區(角落)規劃的實用心法,新手老師快速上手。',
    type: ResourceType.article,
    ages: const [AgeStage.all],
    domains: const [LearningDomain.social, LearningDomain.cognitive],
    tags: const ['環境佈置', '學習區', '新手老師'],
    themes: const ['school_start'],
    content:
        '開學前佈置教室,學習區怎麼規劃才會真的被孩子用起來?分享五個原則:\n\n'
        '一、動靜分區\n'
        '積木區、扮演區等熱鬧的區域放在一起;圖書區、益智區放在安靜角落,中間用矮櫃區隔。\n\n'
        '二、材料看得見、拿得到\n'
        '使用開放式層架,材料盒貼上照片標籤,孩子自己拿、自己收——秩序感是佈置出來的。\n\n'
        '三、數量寧少勿多\n'
        '每區先放少量材料,觀察孩子的興趣再逐步加入新材料,保持新鮮感。\n\n'
        '四、留白與彈性\n'
        '保留一塊空地毯讓作品可以延伸;學習區不是開學佈置完就不動,要跟著主題課程更新。\n\n'
        '五、把孩子的作品放進環境\n'
        '孩子的畫、共同創作放在視線高度展示。教室是「我們的」,歸屬感自然就長出來。',
    isFeatured: true,
    createdAt: DateTime(2026, 8, 12, 9),
  ),
  Resource(
    id: 'seed-013',
    title: '安靜排隊救急口令集',
    summary: '孩子開始躁動時的口令與回應合集,收服轉換時間的小混亂。',
    type: ResourceType.routine,
    ages: const [AgeStage.all],
    domains: const [LearningDomain.social],
    tags: const ['轉換時間', '免教具', '班級經營'],
    themes: const ['school_start'],
    indicatorCodes: const ['社-小-2-3-2', '社-中-2-3-2'],
    content:
        '使用心法:口令要「少而固定」,全班熟了才有效;音量放低反而更快安靜。\n\n'
        '常用口令(老師說—孩子答):\n'
        '一、小眼睛—看老師。\n'
        '二、小嘴巴—閉起來。\n'
        '三、小耳朵—豎起來。\n'
        '四、一二三—木頭人!\n'
        '五、五四三二一—我把嘴巴閉起來。\n\n'
        '進階變化:\n'
        '用「悄悄話模式」下指令,孩子要很專心才聽得到;'
        '或改用拍手節奏(老師拍一段、孩子拍回一樣的),不用開口就能收心。',
    createdAt: DateTime(2026, 8, 14, 9),
  ),
  Resource(
    id: 'seed-014',
    title: '「請你跟我這樣做」轉換小遊戲',
    summary: '免準備的經典模仿遊戲,把排隊、收拾前的空檔變成專注練習。',
    type: ResourceType.routine,
    ages: const [AgeStage.all],
    domains: const [LearningDomain.social, LearningDomain.physical],
    tags: const ['轉換時間', '免教具', '大團體'],
    themes: const ['school_start'],
    indicatorCodes: const ['身-幼-1-1-2', '社-小-2-3-2'],
    content:
        '基本玩法:\n'
        '老師說「請你跟我這樣做」,一邊做動作(拍手、摸肩、比愛心),'
        '孩子回「我會跟你這樣做」並模仿。動作由大變小、速度由快變慢,'
        '最後停在「手放腿上、嘴巴閉起來」,自然完成收心。\n\n'
        '變化版:\n'
        '一、慢動作版:所有動作放到最慢,孩子要忍住不笑。\n'
        '二、無聲版:老師不說話只做動作,考驗觀察力。\n'
        '三、小老師版:請一位孩子出來當領袖,增加參與感。\n\n'
        '小提醒:結尾動作固定同一套,孩子聽到開頭就知道「要準備下一件事了」。',
    createdAt: DateTime(2026, 8, 13, 9),
  ),
];
