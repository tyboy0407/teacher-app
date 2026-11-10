import 'package:flutter_test/flutter_test.dart';
import 'package:teacher_app/core/app_update.dart';

void main() {
  group('AppUpdater.needsUpdate', () {
    test('遠端版本不同才需要更新', () {
      expect(AppUpdater.needsUpdate(current: 'abc', remote: 'def'), isTrue);
      expect(AppUpdater.needsUpdate(current: 'abc', remote: 'abc'), isFalse);
      expect(
        AppUpdater.needsUpdate(current: 'abc', remote: ' abc\n'),
        isFalse,
        reason: '檔案尾端的換行不算差異',
      );
    });

    test('抓不到遠端或本機沒有 BUILD_ID 時不更新', () {
      expect(AppUpdater.needsUpdate(current: 'abc', remote: null), isFalse);
      expect(AppUpdater.needsUpdate(current: 'abc', remote: ''), isFalse);
      expect(AppUpdater.needsUpdate(current: '', remote: 'def'), isFalse);
    });
  });

  test('測試環境(非網頁、無 BUILD_ID)下檢查直接回 null、不動作', () async {
    expect(AppUpdater.enabled, isFalse);
    expect(await AppUpdater.instance.check(), isNull);
    expect(AppUpdater.instance.updating.value, isFalse);
  });
}
