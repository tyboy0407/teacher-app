/// 非網頁平台:沒有瀏覽器歷史可退,由呼叫端改走 GoRouter.pop()。
bool browserHistoryBack() => false;

/// 非網頁平台:沒有 popstate 事件。
void installPopStateListener(void Function() onPopState) {}
