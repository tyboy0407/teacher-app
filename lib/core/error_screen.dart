import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 頁面建構失敗時的畫面。Flutter 在 release 模式預設只顯示一塊灰色,使用者
/// 無法回報任何資訊;改成有說明、有錯誤摘要的畫面,方便截圖回報。
/// 開發模式維持 Flutter 原本的紅底錯誤畫面(資訊最完整)。
void installFriendlyErrorScreen() {
  if (kDebugMode) return;
  ErrorWidget.builder = (details) => _ErrorScreen(details: details);
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.details});

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    final message = details.exceptionAsString();
    return Material(
      color: const Color(0xFFF5F6F2),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.construction,
                size: 40,
                color: Color(0xFF2F5D50),
              ),
              const SizedBox(height: 12),
              const Text(
                '這一頁出了點問題',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2A26),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '請先返回上一頁再試一次;若一直發生,把這個畫面截圖傳給我們。',
                style: TextStyle(fontSize: 14, color: Color(0xFF5B6660)),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFDCE2DB)),
                ),
                child: Text(
                  message,
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5B6660),
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
