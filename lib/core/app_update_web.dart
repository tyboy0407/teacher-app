import 'dart:js_interop';

import 'package:web/web.dart' as web;

const _forcedKey = 'app_update_forced';

/// 用 no-store 抓網站根目錄的 build_id.txt(加時間戳避免任何中介快取)
Future<String?> fetchRemoteBuildId() async {
  try {
    final url = Uri.base
        .resolve('build_id.txt')
        .replace(
          queryParameters: {'t': '${DateTime.now().millisecondsSinceEpoch}'},
        )
        .toString();
    final response = await web.window
        .fetch(url.toJS, web.RequestInit(cache: 'no-store'))
        .toDart;
    if (!response.ok) return null;
    final text = (await response.text().toDart).toDart;
    return text.trim();
  } catch (_) {
    return null;
  }
}

/// 清掉 service worker 與所有快取、重抓入口檔案,然後重新載入
Future<void> forceReload() async {
  try {
    final registrations =
        (await web.window.navigator.serviceWorker.getRegistrations().toDart)
            .toDart;
    for (final registration in registrations) {
      await registration.unregister().toDart;
    }
  } catch (_) {
    // 沒有 service worker(例如非 https)就略過
  }
  try {
    final keys = (await web.window.caches.keys().toDart).toDart;
    for (final key in keys) {
      await web.window.caches.delete(key.toDart).toDart;
    }
  } catch (_) {}
  // 入口檔案用 reload 模式重抓,順便更新瀏覽器的 HTTP 快取
  for (final file in [
    'flutter_bootstrap.js',
    'main.dart.js',
    'flutter.js',
    'version.json',
    'index.html',
  ]) {
    try {
      await web.window
          .fetch(
            Uri.base.resolve(file).toString().toJS,
            web.RequestInit(cache: 'reload'),
          )
          .toDart;
    } catch (_) {}
  }
  web.window.location.reload();
}

/// 分頁回到前景時呼叫(手機從背景切回 App)
void listenVisibility(void Function() onVisible) {
  web.document.addEventListener(
    'visibilitychange',
    ((web.Event _) {
      if (web.document.visibilityState == 'visible') onVisible();
    }).toJS,
  );
}

String? readForcedId() {
  try {
    return web.window.localStorage.getItem(_forcedKey);
  } catch (_) {
    return null;
  }
}

void writeForcedId(String id) {
  try {
    web.window.localStorage.setItem(_forcedKey, id);
  } catch (_) {}
}
