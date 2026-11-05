import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'browser_history_stub.dart'
    if (dart.library.js_interop) 'browser_history_web.dart';

/// 關閉目前的全螢幕頁(詳情、登入、投稿、指標查詢)。
///
/// 網頁版上一律改走瀏覽器的 history.back():App 自己 pop 會在瀏覽器歷史「新增」
/// 一筆而不是退回一筆,導致之後按瀏覽器/手機的返回鍵又把剛關掉的頁面叫回來。
/// 直接用分享連結開到全螢幕頁(沒有上一頁)時,則回到首頁。
void popPage(BuildContext context) {
  final router = GoRouter.of(context);
  if (!router.canPop()) {
    router.go('/home');
    return;
  }
  if (kIsWeb && browserHistoryBack()) return;
  router.pop();
}

/// AppBar 用的返回鍵,行為同 [popPage]。
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BackButton(onPressed: () => popPage(context));
  }
}
