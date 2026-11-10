/// 非網頁平台:沒有瀏覽器網址與 Web Share API。
String? currentWebBase() => null;

bool canShareNative() => false;

Future<bool> shareNative({
  required String title,
  required String text,
  String? url,
}) async => false;
