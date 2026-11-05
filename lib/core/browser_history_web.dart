import 'package:web/web.dart' as web;

/// 網頁平台:退回瀏覽器歷史的上一筆,讓 go_router 經由 popstate 同步頁面。
bool browserHistoryBack() {
  web.window.history.back();
  return true;
}
