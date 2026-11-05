import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher_app/core/browser_navigation.dart';

/// 兩頁的小 App:首頁有「開啟」按鈕推出第二頁,第二頁有「返回」按鈕。
Widget _twoPageApp(GlobalKey<NavigatorState> navigatorKey) {
  return MaterialApp(
    navigatorKey: navigatorKey,
    theme: ThemeData(
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final platform in TargetPlatform.values)
            platform: const WebPageTransitionsBuilder(),
        },
      ),
    ),
    home: const Scaffold(body: Center(child: Text('first page'))),
  );
}

void main() {
  setUp(() {
    BrowserNavigation.suppressTransitions = false;
  });

  test('瀏覽器發起的返回會暫時略過轉場動畫,之後自動恢復', () async {
    BrowserNavigation.onPopState();
    expect(BrowserNavigation.suppressTransitions, isTrue);
    await Future<void>.delayed(
      WebPageTransitionsBuilder.duration + const Duration(milliseconds: 300),
    );
    expect(BrowserNavigation.suppressTransitions, isFalse);
  });

  test('App 自己呼叫 history.back() 時不會略過動畫', () {
    BrowserNavigation.markOwnBack();
    BrowserNavigation.onPopState();
    expect(BrowserNavigation.suppressTransitions, isFalse);
    // 自己的那次用掉之後,下一次瀏覽器發起的返回仍會被略過動畫
    BrowserNavigation.onPopState();
    expect(BrowserNavigation.suppressTransitions, isTrue);
  });

  testWidgets('略過動畫時:彈出的頁面第一個畫格就消失,下層頁面完整可見', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(_twoPageApp(navigatorKey));
    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Center(child: Text('second page'))),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('second page'), findsOneWidget);

    BrowserNavigation.suppressTransitions = true;
    navigatorKey.currentState!.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    // find.text 預設略過 offstage 的 widget:第二頁已經看不見
    expect(find.text('second page'), findsNothing);
    expect(find.text('first page'), findsOneWidget);
    // 下層頁面沒有任何淡入/位移中的轉場包裝
    expect(find.byType(FadeTransition), findsNothing);
    expect(find.byType(SlideTransition), findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets('未略過動畫時:彈出的頁面在動畫中途仍可見', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(_twoPageApp(navigatorKey));
    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Center(child: Text('second page'))),
      ),
    );
    await tester.pumpAndSettle();

    navigatorKey.currentState!.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('second page'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('second page'), findsNothing);
  });
}
