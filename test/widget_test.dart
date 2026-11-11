import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:teacher_app/app.dart';
import 'package:teacher_app/core/app_update.dart';
import 'package:teacher_app/core/browser_navigation.dart';
import 'package:teacher_app/core/navigation.dart';
import 'package:teacher_app/data/curriculum_service.dart';
import 'package:teacher_app/data/seed_lessons.dart';
import 'package:teacher_app/data/resource_repository.dart';
import 'package:teacher_app/features/resource/resource_detail_page.dart';
import 'package:teacher_app/models/resource.dart';
import 'package:teacher_app/models/resource_draft.dart';
import 'package:teacher_app/models/taxonomy.dart';
import 'package:teacher_app/providers.dart';
import 'package:teacher_app/widgets/animated_checkmark.dart';
import 'package:teacher_app/widgets/collapsible_row.dart';
import 'package:teacher_app/widgets/entrance.dart';
import 'package:teacher_app/widgets/skeleton.dart';
import 'package:teacher_app/widgets/favorite_button.dart';
import 'package:teacher_app/widgets/resource_card.dart';
import 'package:teacher_app/widgets/resource_image.dart';

Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: TeacherApp()));
  await tester.pumpAndSettle();
}

/// 到資源庫用關鍵字搜尋後點進詳情頁(列表是延遲建構,直接找舊資源會找不到)
Future<void> openDetailBySearch(WidgetTester tester, String keyword) async {
  await tester.tap(find.text('資源庫'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), keyword);
  await tester.pump(const Duration(milliseconds: 400)); // 搜尋防抖
  await tester.pumpAndSettle();
  await tester.tap(find.byType(ResourceCard).first);
  await tester.pumpAndSettle();
}

/// 投稿表單的「送出審核」在延遲建構的清單底部:先捲到建出來,再確保進入可視範圍
Future<void> tapSubmit(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.text('送出審核'),
    400,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(find.text('送出審核'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('送出審核'));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('啟動後顯示首頁與四個分頁', (tester) async {
    await pumpApp(tester);

    expect(find.text('首頁'), findsOneWidget);
    expect(find.text('資源庫'), findsOneWidget);
    expect(find.text('收藏'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
    expect(find.text('精選推薦'), findsOneWidget);

    // 「最新資源」在測試視窗的畫面外,捲動後驗證
    await tester.dragUntilVisible(
      find.text('最新資源'),
      find.byType(ListView).first,
      const Offset(0, -200),
    );
    expect(find.text('最新資源'), findsOneWidget);
  });

  testWidgets('切到資源庫可看到搜尋框與篩選列', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('資源庫'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('教具製作'), findsWidgets);
    expect(find.text('常規救急'), findsWidgets);
    expect(find.text('小班'), findsWidgets);
    expect(find.textContaining('筆資源'), findsOneWidget);
  });

  testWidgets('點卡片進入詳情頁並顯示材料清單', (tester) async {
    await pumpApp(tester);
    await openDetailBySearch(tester, '瓶蓋');

    expect(find.text('瓶蓋顏色分類盒'), findsOneWidget);
    expect(find.text('材料清單'), findsOneWidget);
    expect(find.text('製作步驟'), findsOneWidget);
    // 課綱指標區塊
    expect(find.text('對應課綱學習指標'), findsOneWidget);
    expect(find.textContaining('認-小-1-3-1'), findsOneWidget);
  });

  testWidgets('課綱指標查詢可反查到對應資源', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('課綱指標查詢'));
    await tester.pumpAndSettle();

    // 展開課程目標「身-1-2 模仿各種用具的操作」
    await tester.tap(find.textContaining('身-1-2 ').first);
    await tester.pumpAndSettle();
    // 點指標「身-幼-1-2-2 模仿抓、握的精細動作」
    await tester.tap(find.text('模仿抓、握的精細動作').first);
    await tester.pumpAndSettle();

    // 反查到掛了這條指標的資源
    expect(find.text('瓶蓋顏色分類盒'), findsOneWidget);
  });

  testWidgets('有影片的資源顯示觀看示範影片按鈕', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          resourceRepositoryProvider.overrideWithValue(_FakeVideoRepo()),
        ],
        child: const MaterialApp(home: ResourceDetailPage(resourceId: 'v1')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('觀看示範影片'), findsOneWidget);
  });

  testWidgets('手機尺寸 375×812 各頁面不溢版', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpApp(tester);

    // 首頁往下捲(經過精選、領域、最新資源)
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();

    // 發布(未連線引導)
    await tester.tap(find.text('發布'));
    await tester.pumpAndSettle();

    // 資源庫
    await tester.tap(find.text('資源庫'));
    await tester.pumpAndSettle();

    // 詳情頁:含材料清單與製作步驟的教具,整頁捲到底
    await tester.tap(find.byType(ResourceCard).first);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // 收藏(空狀態)與我的
    await tester.tap(find.text('收藏'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
  });

  testWidgets('大字級(1.3 倍)手機尺寸各頁面不溢版', (tester) async {
    // 老師常把手機字體調大;版面要撐得住系統字級放大
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpApp(tester);
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('資源庫'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ResourceCard).first);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
  });

  testWidgets('無障礙:圖示按鈕都有名稱,觸控範圍至少 44pt', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await pumpApp(tester);

    Future<void> check(String page) async {
      for (final element in find.byType(IconButton).evaluate()) {
        final button = element.widget as IconButton;
        expect(button.tooltip?.isNotEmpty, isTrue, reason: '$page 有沒有名稱的圖示按鈕');
        final size = element.size!;
        expect(size.width, greaterThanOrEqualTo(44), reason: '$page 按鈕太窄');
        expect(size.height, greaterThanOrEqualTo(44), reason: '$page 按鈕太矮');
      }
    }

    await check('首頁');
    await tester.tap(find.text('資源庫'));
    await tester.pumpAndSettle();
    await check('資源庫');
    await tester.tap(find.byType(ResourceCard).first);
    await tester.pumpAndSettle();
    await check('詳情頁');
  });

  testWidgets('收藏與加入備課的按鈕按下會彈一下,動畫不阻擋狀態切換', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('資源庫'));
    await tester.pumpAndSettle();

    // 卡片上的愛心:按下後動畫進行中就已切換狀態
    // (不用 byIcon 找:「情緒」領域的篩選 chip 也是愛心圖示)
    final button = find.byType(FavoriteButton).first;
    await tester.tap(button);
    await tester.pump(); // 動畫的零幀
    await tester.pump(const Duration(milliseconds: 60));
    expect(
      find.descendant(of: button, matching: find.byIcon(Icons.favorite)),
      findsOneWidget,
    );
    final scale = tester.widget<ScaleTransition>(
      find.descendant(of: button, matching: find.byType(ScaleTransition)),
    );
    expect(scale.scale.value, greaterThan(1.0), reason: '按下後應放大中');
    await tester.pumpAndSettle();
    expect(scale.scale.value, 1.0, reason: '動畫結束回到原尺寸');
  });

  testWidgets('收藏頁點掉愛心:卡片收合消失,5 秒內可復原', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('資源庫'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FavoriteButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('收藏'));
    await tester.pumpAndSettle();
    expect(find.byType(ResourceCard), findsOneWidget);

    await tester.tap(find.byType(FavoriteButton).first);
    await tester.pump(); // 開始收合
    await tester.pump(const Duration(milliseconds: 80));
    final row = tester.widget<CollapsibleRow>(find.byType(CollapsibleRow));
    expect(row.removing, isTrue, reason: '移除後應先播收合動畫,不是瞬間消失');
    await tester.pumpAndSettle();
    expect(find.text('還沒有收藏任何資源'), findsOneWidget);
    expect(find.text('復原'), findsOneWidget);

    await tester.tap(find.text('復原'));
    await tester.pumpAndSettle();
    expect(find.byType(ResourceCard), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ResourceCard),
        matching: find.byIcon(Icons.favorite),
      ),
      findsOneWidget,
    );
  });

  testWidgets('備課籃:移出與清空不再跳確認框,都可復原', (tester) async {
    await pumpApp(tester);
    await openDetailBySearch(tester, '瓶蓋');
    await tester.tap(find.byIcon(Icons.playlist_add));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    // 先回首頁,搜尋 helper 才能用「資源庫」分頁標籤切頁(資源庫頁本身也有同名標題)
    await tester.tap(find.text('首頁'));
    await tester.pumpAndSettle();
    // 清掉上一條「已加入」提示,別擋住等一下要點的卡片
    ScaffoldMessenger.of(tester.element(find.text('首頁'))).clearSnackBars();
    await tester.pumpAndSettle();
    await openDetailBySearch(tester, '情緒臉譜');
    await tester.tap(find.byIcon(Icons.playlist_add));
    await tester.pumpAndSettle();
    await tester.tap(find.text('查看'));
    await tester.pumpAndSettle();
    expect(find.text('活動 2'), findsOneWidget);

    // 從「⋮」選單移出第一個活動:直接移出 + 復原
    await tester.tap(find.byTooltip('更多動作').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('移出備課籃'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('活動 1'), findsOneWidget);
    expect(find.textContaining('已移出'), findsOneWidget);
    await tester.tap(find.text('復原'));
    await tester.pumpAndSettle();
    expect(find.text('活動 2'), findsOneWidget);
    expect(find.textContaining('1. '), findsOneWidget);
    expect(find.textContaining('瓶蓋'), findsWidgets);

    // 清空:直接清空 + 整籃復原
    await tester.tap(find.byTooltip('清空備課籃'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('備課籃是空的'), findsOneWidget);
    await tester.tap(find.text('復原'));
    await tester.pumpAndSettle();
    expect(find.text('活動 2'), findsOneWidget);
  });

  testWidgets('列表載入:100ms 後顯示骨架,內容到了卡片依序進場', (tester) async {
    final repo = _FakeVideoRepo(delay: const Duration(milliseconds: 400));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [resourceRepositoryProvider.overrideWithValue(repo)],
        child: const TeacherApp(),
      ),
    );
    await tester.pump();
    // 用資源庫頁看(首頁的「最新資源」在測試視窗畫面外,卡片不會被建構)
    await tester.tap(find.text('資源庫'));
    await tester.pump();
    // 剛開始不閃骨架(快取命中時才不會閃一下)
    expect(find.byType(SkeletonList), findsWidgets);
    final reveal = tester.widget<Visibility>(
      find.descendant(
        of: find.byType(SkeletonList).first,
        matching: find.byType(Visibility),
      ),
    );
    expect(reveal.visible, isFalse);
    await tester.pump(const Duration(milliseconds: 150));
    expect(
      tester
          .widget<Visibility>(
            find
                .descendant(
                  of: find.byType(SkeletonList).first,
                  matching: find.byType(Visibility),
                )
                .first,
          )
          .visible,
      isTrue,
      reason: '超過 100ms 就該看到骨架',
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // 內容到了:骨架消失,第一張卡片從透明開始進場
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(find.byType(ResourceCard), findsWidgets);
    final entrance = tester.widget<StaggeredEntrance>(
      find.ancestor(
        of: find.byType(ResourceCard).first,
        matching: find.byType(StaggeredEntrance),
      ),
    );
    expect(entrance.enabled, isTrue);
    final opacityNow = tester
        .widget<Opacity>(
          find
              .descendant(
                of: find.byWidget(entrance),
                matching: find.byType(Opacity),
              )
              .first,
        )
        .opacity;
    expect(opacityNow, lessThan(1.0), reason: '進場動畫應從透明開始');
    await tester.pumpAndSettle();
    expect(find.byType(SkeletonList), findsNothing);
  });

  testWidgets('減少動態效果:卡片直接完整顯示,不播進場', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final repo = _FakeVideoRepo(delay: const Duration(milliseconds: 200));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [resourceRepositoryProvider.overrideWithValue(repo)],
        child: const TeacherApp(),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('資源庫'));
    await tester.pump(); // 頁面建起來,資料才開始抓
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();
    expect(find.byType(ResourceCard), findsWidgets);
    expect(
      find.ancestor(
        of: find.byType(ResourceCard).first,
        matching: find.byType(Opacity),
      ),
      findsNothing,
      reason: '減少動態效果時不該有進場用的 Opacity',
    );
    await tester.pumpAndSettle();
  });

  testWidgets('封面共享元素轉場:卡片與詳情頁共用同一個 Hero,瀏覽器返回時關閉', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('資源庫'));
    await tester.pumpAndSettle();
    final cardHero = tester.widget<Hero>(
      find.descendant(
        of: find.byType(ResourceCard).first,
        matching: find.byType(Hero),
      ),
    );
    await tester.tap(find.byType(ResourceCard).first);
    await tester.pumpAndSettle();
    final detailHero = tester.widget<Hero>(
      find.descendant(
        of: find.byType(ResourceDetailPage),
        matching: find.byType(Hero),
      ),
    );
    expect(detailHero.tag, cardHero.tag);

    // 瀏覽器發起的返回:HeroMode 關閉,不播飛行
    BrowserNavigation.suppressTransitions = true;
    await tester.pump();
    final mode = tester.widget<HeroMode>(
      find.descendant(
        of: find.byType(ResourceDetailPage),
        matching: find.byType(HeroMode),
      ),
    );
    expect(mode.enabled, isFalse);
    BrowserNavigation.suppressTransitions = false;
    await tester.pump();
  });

  testWidgets('首頁最新資源點進詳情頁:精選與最新重複的資源不會有重複 Hero', (tester) async {
    await pumpApp(tester);
    await tester.dragUntilVisible(
      find.text('最新資源'),
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ResourceCard).first);
    await tester.pumpAndSettle();
    expect(find.byType(ResourceDetailPage), findsOneWidget);
  });

  testWidgets('詳情頁:底部操作列有一顆寬的「加入本週備課」主按鈕', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await pumpApp(tester);
    await openDetailBySearch(tester, '瓶蓋');

    final primary = find.widgetWithText(FilledButton, '加入本週備課');
    expect(primary, findsOneWidget);
    // 主按鈕比次要的圖示按鈕寬得多
    final primaryWidth = tester.getSize(primary).width;
    final shareWidth = tester.getSize(find.byTooltip('分享')).width;
    expect(primaryWidth, greaterThan(shareWidth * 3));
    // 老師不是管理者:封面上沒有重複的分享/收藏按鈕
    expect(find.byIcon(Icons.share), findsOneWidget);

    await tester.tap(primary);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, '已在備課籃,移出'), findsOneWidget);
    expect(find.byType(Badge), findsOneWidget);
  });

  testWidgets('資源庫:已選條件顯示為可單獨移除的摘要', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('資源庫'));
    await tester.pumpAndSettle();
    expect(find.byType(InputChip), findsNothing);

    await tester.tap(find.widgetWithText(FilterChip, '小班'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, '認知'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(InputChip, '小班'), findsOneWidget);
    expect(find.widgetWithText(InputChip, '認知'), findsOneWidget);
    expect(find.text('清除篩選'), findsOneWidget);

    await tester.tap(find.byTooltip('移除條件 小班'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(InputChip, '小班'), findsNothing);
    expect(find.widgetWithText(InputChip, '認知'), findsOneWidget);
    // 篩選列上的 chip 也同步取消
    final ageChip = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, '小班'),
    );
    expect(ageChip.selected, isFalse);
  });

  testWidgets('資源庫:篩選列右側有「還有更多」的淡出提示', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await pumpApp(tester);
    await tester.tap(find.text('資源庫'));
    await tester.pumpAndSettle();
    // 主題有 26 個,一定超出手機寬度
    final fade = tester.widget<AnimatedOpacity>(
      find.ancestor(
        of: find.byKey(const ValueKey('filter-fade-主題')),
        matching: find.byType(AnimatedOpacity),
      ),
    );
    expect(fade.opacity, 1.0);
    // 年齡只有四個,放得下,不該有提示
    final ageFade = tester.widget<AnimatedOpacity>(
      find.ancestor(
        of: find.byKey(const ValueKey('filter-fade-年齡')),
        matching: find.byType(AnimatedOpacity),
      ),
    );
    expect(ageFade.opacity, 0.0);
  });

  testWidgets('詳情頁:指標以文字為主,點代碼可看課程目標', (tester) async {
    await pumpApp(tester);
    await openDetailBySearch(tester, '瓶蓋');
    final code = find.textContaining('認-小-1-3-1');
    await tester.ensureVisible(code.first);
    await tester.pumpAndSettle();
    await tester.tap(code.first);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('課程目標'), findsWidgets);
    expect(find.textContaining('代碼怎麼讀'), findsOneWidget);
    await tester.tap(find.text('知道了'));
    await tester.pumpAndSettle();
  });

  testWidgets('備課籃材料依活動分組,共用材料只列一次並附註', (tester) async {
    await pumpApp(tester);
    await openDetailBySearch(tester, '瓶蓋');
    await tester.tap(find.widgetWithText(FilledButton, '加入本週備課'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    ScaffoldMessenger.of(tester.element(find.text('首頁'))).clearSnackBars();
    await tester.tap(find.text('首頁'));
    await tester.pumpAndSettle();
    await openDetailBySearch(tester, '彩虹米');
    await tester.tap(find.widgetWithText(FilledButton, '加入本週備課'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('查看'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('材料'));
    await tester.pumpAndSettle();
    // 兩個活動各自成組
    expect(find.text('瓶蓋顏色分類盒'), findsOneWidget);
    expect(find.text('彩虹米感官箱'), findsOneWidget);
    expect(find.textContaining('用於:'), findsNothing);
    // 每項材料只出現一次
    final checkboxes = find.byType(CheckboxListTile).evaluate().length;
    final unique = find
        .byType(CheckboxListTile)
        .evaluate()
        .map((e) {
          final tile = e.widget as CheckboxListTile;
          return (tile.title as Text).data;
        })
        .toSet()
        .length;
    expect(checkboxes, unique);
  });

  testWidgets('資源庫:搜尋框在標題列,頁面不再重複「資源庫」字樣', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('資源庫'));
    await tester.pumpAndSettle();
    // 只剩分頁標籤那一個「資源庫」
    expect(find.text('資源庫'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(TextField),
      ),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField), '瓶蓋');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('共 1 筆資源'), findsOneWidget);
  });

  testWidgets('發現新版本時顯示全頁「更新中」', (tester) async {
    await pumpApp(tester);
    expect(find.textContaining('更新中'), findsNothing);
    AppUpdater.instance.updating.value = true;
    addTearDown(() => AppUpdater.instance.updating.value = false);
    await tester.pump();
    expect(find.text('有新版本,更新中…'), findsOneWidget);
    expect(find.text('幾秒後會自動重新載入'), findsOneWidget);
  });

  testWidgets('範本教案:詳情頁顯示參考來源與「不是原文轉載」的說明', (tester) async {
    await pumpApp(tester);
    await openDetailBySearch(tester, '玉米');
    expect(find.text('摸摸看,是玉米!'), findsWidgets);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(find.textContaining('參考來源:農業部食農教育'), findsOneWidget);
    expect(find.text('本篇是參考後重新設計的內容,不是原文轉載。'), findsOneWidget);
    expect(find.text('開啟原始資料'), findsOneWidget);
  });

  test('範本教案資料:每篇都有來源、指標不超過 3 條、內容含教學目標', () {
    expect(seedLessons.length, 10);
    for (final lesson in seedLessons) {
      expect(lesson.type, ResourceType.lessonPlan);
      expect(lesson.sourceName, isNotNull, reason: lesson.title);
      expect(
        lesson.indicatorCodes.length,
        inInclusiveRange(1, 3),
        reason: lesson.title,
      );
      for (final code in lesson.indicatorCodes) {
        expect(
          CurriculumService.indicator(code),
          isNotNull,
          reason: '${lesson.title} 的指標 $code 不存在',
        );
      }
      expect(lesson.content, contains('教學目標'), reason: lesson.title);
      expect(lesson.content, contains('小提醒'), reason: lesson.title);
    }
  });

  testWidgets('範本教案:詳情頁有「活動流程」三張圖示與說明', (tester) async {
    await pumpApp(tester);
    await openDetailBySearch(tester, '年獸');
    await tester.scrollUntilVisible(
      find.text('活動流程'),
      300,
      scrollable: find.descendant(
        of: find.byType(CustomScrollView),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('活動流程'), findsOneWidget);
    expect(find.text('製作步驟'), findsNothing);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('引起動機'), findsOneWidget);
    expect(find.textContaining('年獸最怕哪三樣東西'), findsOneWidget);
    // 封面 + 流程圖示都用內建插圖
    expect(find.byType(ResourceImage), findsWidgets);
  });

  test('範本教案資料:每篇都有內建封面與三張流程圖,檔案存在', () {
    for (final lesson in seedLessons) {
      expect(
        ResourceImage.isBundled(lesson.coverUrl),
        isTrue,
        reason: lesson.title,
      );
      expect(lesson.steps.length, 3, reason: lesson.title);
      final urls = [lesson.coverUrl!, ...lesson.steps.map((s) => s.imageUrl!)];
      for (final url in urls) {
        final path = url.substring(ResourceImage.assetScheme.length);
        expect(File(path).existsSync(), isTrue, reason: '缺檔 $path');
        expect(File(path).readAsStringSync(), startsWith('<svg'));
      }
    }
  });

  testWidgets('收藏後出現在收藏頁', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('資源庫'));
    await tester.pumpAndSettle();

    // 在第一張卡片上點愛心
    await tester.tap(find.byType(FavoriteButton).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('收藏'));
    await tester.pumpAndSettle();

    expect(find.text('還沒有收藏任何資源'), findsNothing);
    expect(find.byType(ResourceCard), findsWidgets);
  });

  testWidgets('未連線時發布頁顯示連線引導', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('發布'));
    await tester.pumpAndSettle();

    expect(find.text('投稿功能需要連線雲端'), findsOneWidget);
  });

  testWidgets('登入後發布頁顯示我的投稿與審核狀態', (tester) async {
    final pending = Resource(
      id: 'p1',
      title: '待審教具',
      type: ResourceType.craft,
      createdAt: DateTime(2026, 8, 15),
      reviewStatus: 'pending',
      published: false,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          resourceRepositoryProvider.overrideWithValue(
            _FakeVideoRepo(myUploads: [pending]),
          ),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepo()),
        ],
        child: const TeacherApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('發布'));
    await tester.pumpAndSettle();

    expect(find.text('待審教具'), findsOneWidget);
    expect(find.text('審核中'), findsOneWidget);
    expect(find.text('新增投稿'), findsOneWidget);
  });

  Future<void> openUploadForm(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          resourceRepositoryProvider.overrideWithValue(_FakeVideoRepo()),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepo()),
        ],
        child: const TeacherApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('發布'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('新增投稿'));
    await tester.pumpAndSettle();
  }

  testWidgets('投稿表單:缺必填會被擋下', (tester) async {
    await openUploadForm(tester);

    // 填了標題但沒選年齡
    await tester.enterText(find.byType(TextFormField).first, '測試教具');
    await tapSubmit(tester);
    await tester.pumpAndSettle(); // 會先捲回年齡區塊再顯示錯誤
    expect(find.text('請選擇適用年齡'), findsOneWidget);
  });

  testWidgets('投稿表單:填妥後可送出', (tester) async {
    await openUploadForm(tester);

    // 標題與分類 chips 都在首屏,先選完再捲到送出鈕
    await tester.enterText(find.byType(TextFormField).first, '測試教具');
    await tester.tap(find.widgetWithText(FilterChip, '小班'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilterChip, '認知'));
    await tester.pump();
    await tapSubmit(tester);
    await tester.pumpAndSettle();

    // 整頁成功畫面:勾勾、說明、兩個下一步
    expect(find.text('送出了!'), findsOneWidget);
    expect(find.byType(AnimatedCheckmark), findsOneWidget);
    expect(find.textContaining('「測試教具」已進入審核'), findsOneWidget);
    await tester.tap(find.text('回到我的投稿'));
    await tester.pumpAndSettle();
    expect(find.text('我的投稿'), findsOneWidget);
  });

  final pendingForReview = Resource(
    id: 'p1',
    title: '待審教具',
    summary: '一個等待審核的教具',
    type: ResourceType.craft,
    createdAt: DateTime(2026, 8, 15),
    reviewStatus: 'pending',
    published: false,
  );

  testWidgets('投稿表單:送出失敗給「重試」,內容保留,重試成功進成功頁', (tester) async {
    final repo = _FakeVideoRepo()..submitFails = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          resourceRepositoryProvider.overrideWithValue(repo),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepo()),
        ],
        child: const TeacherApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('發布'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('新增投稿'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '測試教具');
    await tester.tap(find.widgetWithText(FilterChip, '小班'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, '認知'));
    await tester.pumpAndSettle();
    await tapSubmit(tester);
    await tester.pumpAndSettle();
    expect(find.text('重試'), findsOneWidget);
    expect(find.text('送出了!'), findsNothing);
    // 表單是延遲建構的清單,標題在頂端:捲回去確認內容還在
    await tester.scrollUntilVisible(
      find.text('測試教具'),
      -300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('測試教具'), findsOneWidget, reason: '填好的內容要保留');

    repo.submitFails = false;
    await tester.tap(find.text('重試'));
    await tester.pumpAndSettle();
    expect(find.text('送出了!'), findsOneWidget);

    // 再投一篇:換一張乾淨的表單
    await tester.tap(find.text('再投一篇'));
    await tester.pumpAndSettle();
    expect(find.text('新增投稿'), findsOneWidget);
    expect(find.text('測試教具'), findsNothing);
  });

  testWidgets('投稿表單:缺年齡時錯誤顯示在該區塊下方並捲到該處', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          resourceRepositoryProvider.overrideWithValue(_FakeVideoRepo()),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepo()),
        ],
        child: const TeacherApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('發布'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('新增投稿'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '測試教具');
    await tapSubmit(tester);
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing, reason: '錯誤不再用提示條');
    final error = find.text('請選擇適用年齡');
    expect(error, findsOneWidget);
    final y = tester.getTopLeft(error).dy;
    expect(y, inInclusiveRange(0, 812), reason: '應已捲到錯誤區塊');

    // 選了年齡,錯誤就消失
    await tester.tap(find.widgetWithText(FilterChip, '小班'));
    await tester.pumpAndSettle();
    expect(find.text('請選擇適用年齡'), findsNothing);
  });

  testWidgets('已登入但管理者查詢失敗:詳情頁與我的頁仍正常顯示', (tester) async {
    // 線上曾發生:schema_v3 未執行 → is_admin 回 404。登入狀態早已載入時,
    // 管理者查詢第一次建構就失敗、沒有舊值可退,AsyncValue.value 會重新丟出錯誤
    // → 詳情頁整頁灰色。這裡先進「發布」讓登入狀態就緒,再開詳情頁重現該路徑。
    final repo = _FakeVideoRepo(adminCheckFails: true);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          resourceRepositoryProvider.overrideWithValue(repo),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepo()),
        ],
        child: const TeacherApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('發布'));
    await tester.pumpAndSettle();
    expect(find.text('我的投稿'), findsOneWidget);

    await tester.tap(find.text('資源庫'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ResourceCard).first);
    await tester.pumpAndSettle();
    expect(find.byType(ErrorWidget), findsNothing);
    expect(find.byIcon(Icons.share), findsOneWidget);
    expect(find.text('通過並上架'), findsNothing);

    popPage(tester.element(find.byIcon(Icons.share)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    expect(find.byType(ErrorWidget), findsNothing);
    expect(find.text('審核投稿'), findsNothing);
  });

  testWidgets('管理者:我的頁有審核入口,通過後投稿離開待審清單', (tester) async {
    // 用手機尺寸跑,順便確認審核清單與底部操作列不溢版
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final repo = _FakeVideoRepo(pending: [pendingForReview], admin: true);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          resourceRepositoryProvider.overrideWithValue(repo),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepo()),
        ],
        child: const TeacherApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    expect(find.text('審核投稿'), findsOneWidget);
    expect(find.text('待審 1 筆'), findsOneWidget);

    await tester.tap(find.text('審核投稿'));
    await tester.pumpAndSettle();
    expect(find.text('待審教具'), findsOneWidget);

    await tester.tap(find.text('待審教具'));
    await tester.pumpAndSettle();
    expect(find.text('通過並上架'), findsOneWidget);
    expect(find.text('退回'), findsOneWidget);

    await tester.tap(find.text('通過並上架'));
    await tester.pumpAndSettle();
    expect(find.text('上架前請確認:'), findsOneWidget);
    await tester.tap(find.text('確定通過'));
    await tester.pumpAndSettle();

    expect(repo.reviewed, [('p1', true, null)]);
    expect(find.text('目前沒有待審投稿'), findsOneWidget);
  });

  testWidgets('管理者:退回必須填原因,原因會送到後端', (tester) async {
    final repo = _FakeVideoRepo(pending: [pendingForReview], admin: true);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          resourceRepositoryProvider.overrideWithValue(repo),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepo()),
        ],
        child: const TeacherApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('審核投稿'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('待審教具'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, '退回'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '缺少安全提醒');
    await tester.tap(find.widgetWithText(FilledButton, '退回'));
    await tester.pumpAndSettle();

    expect(repo.reviewed, [('p1', false, '缺少安全提醒')]);
  });

  testWidgets('加入備課籃後,備課頁彙整活動、材料與指標', (tester) async {
    await pumpApp(tester);
    await openDetailBySearch(tester, '瓶蓋');

    await tester.tap(find.byIcon(Icons.playlist_add));
    await tester.pumpAndSettle();
    // 第一次進籃:說明備課頁會幫忙整理;按鈕角落出現數字徽章
    expect(find.textContaining('已加入本週備課'), findsOneWidget);
    expect(find.textContaining('整理材料'), findsOneWidget);
    expect(find.byIcon(Icons.playlist_add_check), findsOneWidget);
    expect(find.byType(Badge), findsOneWidget);
    expect(
      find.descendant(of: find.byType(Badge), matching: find.text('1')),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('本週備課'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('本週備課'));
    await tester.pumpAndSettle();

    expect(find.text('1. 瓶蓋顏色分類盒'), findsOneWidget);
    await tester.tap(find.textContaining('材料 缺'));
    await tester.pumpAndSettle();
    expect(find.text('各色瓶蓋 20~30 個'), findsOneWidget);

    // 勾掉一項「我有了」,缺的數量減一
    await tester.tap(find.text('各色瓶蓋 20~30 個'));
    await tester.pumpAndSettle();
    expect(find.textContaining('還缺 5 項'), findsOneWidget);

    await tester.tap(find.textContaining('指標 '));
    await tester.pumpAndSettle();
    expect(find.text('認-小-1-3-1'), findsOneWidget);
  });

  testWidgets('首頁有本月主題,資源庫可依主題篩選', (tester) async {
    await pumpApp(tester);
    expect(find.textContaining('本月主題'), findsOneWidget);

    await tester.tap(find.text('資源庫'));
    await tester.pumpAndSettle();

    // 主題列是橫向捲動,「開學適應」排在最前面、不用捲就看得到
    await tester.tap(find.text('開學適應'));
    await tester.pumpAndSettle();

    expect(find.text('共 4 筆資源'), findsOneWidget); // 3 筆原有 + 範本教案「我的心情天氣」
    expect(find.text('清除篩選'), findsOneWidget);
    // 最新的排最前面;舊資源在清單下方(延遲建構),捲到才看得到
    expect(find.text('我的心情天氣'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('安靜排隊救急口令集'),
      300,
      scrollable: find.descendant(
        of: find.byType(EntranceWindow),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('安靜排隊救急口令集'), findsOneWidget);
  });

  testWidgets('詳情頁分享面板:LINE 排第一,複製的文字含標題與連結', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await pumpApp(tester);
    await openDetailBySearch(tester, '瓶蓋');

    await tester.tap(find.byIcon(Icons.share));
    await tester.pumpAndSettle();
    expect(find.text('分享到 LINE'), findsOneWidget);
    expect(find.text('複製文字'), findsOneWidget);

    await tester.tap(find.text('複製文字'));
    await tester.pumpAndSettle();
    expect(copied, contains('瓶蓋顏色分類盒'));
    expect(copied, contains('#/resource/seed-001'));
  });

  testWidgets('管理者:已上架內容可下架,刪除需確認且會回到上一頁', (tester) async {
    final repo = _FakeVideoRepo(admin: true);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          resourceRepositoryProvider.overrideWithValue(repo),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepo()),
        ],
        child: const TeacherApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('資源庫'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ResourceCard).first);
    await tester.pumpAndSettle();
    expect(find.text('下架'), findsOneWidget);
    expect(find.text('刪除'), findsOneWidget);
    expect(find.text('通過並上架'), findsNothing);

    // 下架:確認對話框 → 送出 unpublish
    await tester.tap(find.text('下架'));
    await tester.pumpAndSettle();
    expect(find.textContaining('下架後老師們會看不到'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '下架').last);
    await tester.pumpAndSettle();
    expect(repo.moderated, [('v1', ModerationAction.unpublish)]);
    expect(find.text('已下架'), findsOneWidget);

    // 刪除:取消不會送出;確認後送出 delete 並離開詳情頁
    await tester.tap(find.text('刪除'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(repo.moderated.length, 1);

    await tester.tap(find.text('刪除'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('永久刪除'));
    await tester.pumpAndSettle();
    expect(repo.moderated.last, ('v1', ModerationAction.delete));
    expect(find.text('刪除'), findsNothing);
    expect(find.byType(ResourceCard), findsWidgets);
  });

  testWidgets('管理者:審核頁列出已下架內容,點進去可重新上架', (tester) async {
    final hidden = Resource(
      id: 'h1',
      title: '下架中的教案',
      type: ResourceType.lessonPlan,
      createdAt: DateTime(2026, 8, 10),
      published: false,
    );
    final repo = _FakeVideoRepo(admin: true, unpublished: [hidden]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          resourceRepositoryProvider.overrideWithValue(repo),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepo()),
        ],
        child: const TeacherApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('審核投稿'));
    await tester.pumpAndSettle();
    expect(find.text('目前沒有待審投稿'), findsOneWidget);
    expect(find.text('已下架(1)'), findsOneWidget);

    await tester.tap(find.text('下架中的教案'));
    await tester.pumpAndSettle();
    expect(find.textContaining('這筆內容已下架'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '重新上架'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '重新上架').last);
    await tester.pumpAndSettle();
    expect(repo.moderated, [('h1', ModerationAction.publish)]);
  });

  testWidgets('非管理者看不到審核入口與審核列', (tester) async {
    final repo = _FakeVideoRepo(pending: [pendingForReview]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          resourceRepositoryProvider.overrideWithValue(repo),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepo()),
        ],
        child: const TeacherApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    expect(find.text('審核投稿'), findsNothing);

    await tester.tap(find.text('資源庫'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ResourceCard).first);
    await tester.pumpAndSettle();
    expect(find.text('下架'), findsNothing);
    expect(find.text('刪除'), findsNothing);
  });
}

/// 永遠已登入的假帳號服務
class _FakeAuthRepo implements AuthRepository {
  static const _user = AppUser(id: 'u1', email: 'teacher@test.dev');

  @override
  bool get isAvailable => true;

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> authStateChanges() => Stream<AppUser?>.value(_user);

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signUp({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() async {}
}

/// 測影片按鈕、投稿與審核流程用的假資料來源
class _FakeVideoRepo implements ResourceRepository {
  _FakeVideoRepo({
    this.myUploads = const [],
    List<Resource> pending = const [],
    List<Resource> unpublished = const [],
    this.admin = false,
    this.adminCheckFails = false,
    this.delay = Duration.zero,
  }) : pending = [...pending],
       unpublished = [...unpublished];

  /// 模擬網路慢:列表要等這麼久才回來
  final Duration delay;

  final List<Resource> myUploads;
  final List<Resource> pending;
  final List<Resource> unpublished;
  final bool admin;

  /// 管理者處置紀錄:(id, 動作)
  final moderated = <(String, ModerationAction)>[];

  /// 模擬後端還沒建立 is_admin 函式(rpc 回 404)
  final bool adminCheckFails;

  /// 審核紀錄:(id, 是否通過, 退回原因)
  final reviewed = <(String, bool, String?)>[];

  static final _video = Resource(
    id: 'v1',
    title: '測試影片資源',
    type: ResourceType.play,
    videoUrl: 'https://www.youtube.com/watch?v=demo',
    createdAt: DateTime(2026, 8, 1),
  );

  @override
  Future<Resource?> fetchById(String id) async =>
      [...pending, ...unpublished].where((r) => r.id == id).firstOrNull ??
      _video;

  @override
  Future<List<Resource>> fetchResources({
    ResourceFilter filter = const ResourceFilter(),
  }) async {
    await Future<void>.delayed(delay);
    return [_video];
  }

  @override
  Future<List<Resource>> fetchFeatured() async {
    await Future<void>.delayed(delay);
    return [_video];
  }

  @override
  Future<List<Resource>> fetchByIds(List<String> ids) async => [_video];

  @override
  Future<List<String>> fetchTagNames() async => const [];

  @override
  Future<List<Resource>> fetchByIndicator(String indicatorCode) async =>
      const [];

  /// 模擬送出失敗(網路問題);可在測試中途改回 false 驗證「重試」
  bool submitFails = false;

  @override
  Future<String> submitResource(ResourceDraft draft) async {
    if (submitFails) throw Exception('network');
    return 'fake-id';
  }

  @override
  Future<List<Resource>> fetchMyUploads() async => myUploads;

  @override
  Future<void> deleteMyUpload(String id) async {}

  @override
  Future<String> uploadImage(Uint8List bytes, String filename) async =>
      'https://example.com/fake.jpg';

  @override
  Future<bool> isAdmin() async {
    if (adminCheckFails) throw Exception('404 function is_admin not found');
    return admin;
  }

  @override
  Future<List<Resource>> fetchPendingReviews() async => List.of(pending);

  @override
  Future<void> reviewResource(
    String id, {
    required bool approve,
    String? note,
  }) async {
    reviewed.add((id, approve, note));
    pending.removeWhere((r) => r.id == id);
  }

  @override
  Future<List<Resource>> fetchUnpublished() async => List.of(unpublished);

  @override
  Future<void> moderateResource(String id, ModerationAction action) async {
    moderated.add((id, action));
    if (action == ModerationAction.delete) {
      unpublished.removeWhere((r) => r.id == id);
    }
  }
}
