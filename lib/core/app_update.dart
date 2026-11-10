import 'package:flutter/foundation.dart';

import 'app_update_stub.dart'
    if (dart.library.js_interop) 'app_update_web.dart'
    as platform;

/// 網頁版的自動更新:瀏覽器(尤其是手機 Safari)會把 main.dart.js 等檔案暫存,
/// 推了新版老師還看到舊畫面。
///
/// 機制:部署時把 commit SHA 用 `--dart-define=BUILD_ID` 編進 App,並在網站
/// 根目錄放一個 `build_id.txt`(建置之後才寫入,所以不在 service worker 的
/// 快取清單裡)。App 開啟、以及從背景回到前景時,用 no-store 抓這個檔案比對;
/// 不一致就清掉 service worker 與快取、重新載入,期間顯示「更新中」。
///
/// 沒有 BUILD_ID(本機開發)或不是網頁版時完全不動作。
class AppUpdater {
  AppUpdater._();

  static final instance = AppUpdater._();

  /// 編進 App 的版本識別(部署時的 commit SHA);本機開發為空字串
  static const buildId = String.fromEnvironment('BUILD_ID');

  static String get shortBuildId =>
      buildId.length > 7 ? buildId.substring(0, 7) : buildId;

  /// 兩次自動檢查之間至少隔這麼久(回到前景時不必每次都打網路)
  static const minInterval = Duration(minutes: 1);

  /// 正在更新中(UI 用它顯示全頁覆蓋)
  final updating = ValueNotifier<bool>(false);

  DateTime? _lastCheck;
  bool _started = false;

  static bool get enabled => kIsWeb && buildId.isNotEmpty;

  /// 遠端版本和目前不同才需要更新;任一邊是空值(抓不到、本機開發)都不更新
  static bool needsUpdate({required String current, required String? remote}) {
    final target = remote?.trim() ?? '';
    return current.isNotEmpty && target.isNotEmpty && target != current;
  }

  /// App 啟動時呼叫一次:馬上檢查,之後每次回到前景再檢查(有間隔)
  void start() {
    if (_started || !enabled) return;
    _started = true;
    check();
    platform.listenVisibility(() {
      final last = _lastCheck;
      if (last == null || DateTime.now().difference(last) >= minInterval) {
        check();
      }
    });
  }

  /// 檢查一次。回傳 true = 已是最新;false = 發現新版本、已開始更新;
  /// null = 無法檢查(離線、未設定 BUILD_ID)。
  Future<bool?> check({bool force = false}) async {
    if (!enabled) return null;
    _lastCheck = DateTime.now();
    final remote = await platform.fetchRemoteBuildId();
    if (remote == null) return null;
    if (!needsUpdate(current: buildId, remote: remote)) return true;
    // 防止無限重新載入:同一個遠端版本只強制更新一次(例如 CDN 還沒同步完時)
    if (!force && platform.readForcedId() == remote) return false;
    platform.writeForcedId(remote);
    updating.value = true;
    await platform.forceReload();
    return false;
  }
}
