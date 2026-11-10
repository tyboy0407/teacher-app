import 'package:flutter/material.dart';

/// 可逆的動作不問「確定嗎?」,直接做,然後給 5 秒的「復原」。
/// (不可逆的動作,例如永久刪除,仍走確認對話框。)
void showUndoSnackBar(
  BuildContext context, {
  required String message,
  required VoidCallback onUndo,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(label: '復原', onPressed: onUndo),
      ),
    );
}
