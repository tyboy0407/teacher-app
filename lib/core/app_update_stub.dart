/// 非網頁平台:沒有瀏覽器快取的問題,全部不動作。
Future<String?> fetchRemoteBuildId() async => null;

Future<void> forceReload() async {}

void listenVisibility(void Function() onVisible) {}

String? readForcedId() => null;

void writeForcedId(String id) {}
