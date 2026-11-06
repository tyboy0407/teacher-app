import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';
import 'share_stub.dart' if (dart.library.js_interop) 'share_web.dart';

/// 資源的公開網址:網頁版用目前網站的根路徑,其他平台用正式站網址。
String resourceShareUrl(String resourceId) =>
    '${currentWebBase() ?? appWebUrl}#/resource/$resourceId';

/// 分享面板:台灣老師的社群在 LINE 群,所以 LINE 永遠排第一;
/// 其次是系統分享(手機瀏覽器)與複製文字。
Future<void> showShareSheet(
  BuildContext context, {
  required String title,
  required String text,
  String? url,
}) async {
  final fullText = url == null || url.isEmpty ? text : '$text\n$url';
  final theme = Theme.of(context);
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF06C755),
              child: Icon(Icons.chat_bubble, color: Colors.white, size: 20),
            ),
            title: const Text('分享到 LINE'),
            subtitle: const Text('傳到老師群組或個人'),
            onTap: () {
              Navigator.of(sheetContext).pop();
              launchUrl(
                Uri.parse(
                  'https://line.me/R/share?text=${Uri.encodeComponent(fullText)}',
                ),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          if (canShareNative())
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.ios_share)),
              title: const Text('其他方式分享'),
              subtitle: const Text('開啟手機的分享面板'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                shareNative(title: title, text: text, url: url);
              },
            ),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.copy)),
            title: const Text('複製文字'),
            subtitle: const Text('貼到任何地方'),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              await Clipboard.setData(ClipboardData(text: fullText));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已複製,可以貼上了')),
                );
              }
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
