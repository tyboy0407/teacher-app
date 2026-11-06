import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

/// 目前網頁的根路徑,如 https://xxx.github.io/teacher-app/(不含 #/ 之後的路由)。
String? currentWebBase() {
  final base = Uri.base;
  return Uri(
    scheme: base.scheme,
    host: base.host,
    port: base.hasPort ? base.port : null,
    path: base.path,
  ).toString();
}

/// 手機瀏覽器大多支援 Web Share API,會跳出系統分享面板(含 LINE)。
bool canShareNative() => (web.window.navigator as JSObject).has('share');

Future<bool> shareNative({
  required String title,
  required String text,
  String? url,
}) async {
  if (!canShareNative()) return false;
  try {
    await web.window.navigator
        .share(web.ShareData(title: title, text: text, url: url ?? ''))
        .toDart;
  } catch (_) {
    // 使用者取消分享也會丟 AbortError,視為已處理
  }
  return true;
}
