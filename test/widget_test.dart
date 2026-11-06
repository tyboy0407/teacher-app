import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:teacher_app/app.dart';
import 'package:teacher_app/core/navigation.dart';
import 'package:teacher_app/data/resource_repository.dart';
import 'package:teacher_app/features/resource/resource_detail_page.dart';
import 'package:teacher_app/models/resource.dart';
import 'package:teacher_app/models/resource_draft.dart';
import 'package:teacher_app/models/taxonomy.dart';
import 'package:teacher_app/providers.dart';
import 'package:teacher_app/widgets/favorite_button.dart';
import 'package:teacher_app/widgets/resource_card.dart';

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
    expect(find.text('認-小-1-3-1'), findsOneWidget);
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
        child: const MaterialApp(
          home: ResourceDetailPage(resourceId: 'v1'),
        ),
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
        expect(button.tooltip?.isNotEmpty, isTrue,
            reason: '$page 有沒有名稱的圖示按鈕');
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
          resourceRepositoryProvider
              .overrideWithValue(_FakeVideoRepo(myUploads: [pending])),
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
    await tester.pump(const Duration(milliseconds: 300));
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

    expect(find.text('已送出審核 🎉'), findsOneWidget);
    await tester.tap(find.text('好'));
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
    expect(find.text('已加入本週備課'), findsOneWidget);
    expect(find.byIcon(Icons.playlist_add_check), findsOneWidget);

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

    expect(find.text('共 3 筆資源'), findsOneWidget);
    expect(find.text('安靜排隊救急口令集'), findsOneWidget);
    expect(find.text('清除篩選'), findsOneWidget);
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
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

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
  Future<void> signInWithPassword(
      {required String email, required String password}) async {}

  @override
  Future<void> signUp({required String email, required String password}) async {}

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
  })  : pending = [...pending],
        unpublished = [...unpublished];

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
  Future<List<Resource>> fetchResources(
          {ResourceFilter filter = const ResourceFilter()}) async =>
      [_video];

  @override
  Future<List<Resource>> fetchFeatured() async => [_video];

  @override
  Future<List<Resource>> fetchByIds(List<String> ids) async => [_video];

  @override
  Future<List<String>> fetchTagNames() async => const [];

  @override
  Future<List<Resource>> fetchByIndicator(String indicatorCode) async =>
      const [];

  @override
  Future<String> submitResource(ResourceDraft draft) async => 'fake-id';

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
  Future<void> reviewResource(String id,
      {required bool approve, String? note}) async {
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
