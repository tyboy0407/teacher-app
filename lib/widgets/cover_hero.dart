import 'package:flutter/material.dart';

import '../core/browser_navigation.dart';
import '../core/motion.dart';
import '../models/resource.dart';

/// 封面的共享元素轉場:卡片上的小封面飛到詳情頁的大封面,給「這就是剛剛那張」
/// 的空間連續感。
///
/// 兩種情況關掉:瀏覽器發起的返回(Safari 側滑、返回鍵)——那時整個轉場都不播,
/// 飛行動畫會閃;以及系統開啟「減少動態效果」。
///
/// 同一畫面上同一個 tag 只能有一個 Hero,所以只有列表卡片(ResourceCard)和
/// 詳情頁用它;首頁「精選推薦」的直式卡片可能和「最新資源」重複,不用。
class CoverHero extends StatelessWidget {
  const CoverHero({super.key, required this.resource, required this.child});

  final Resource resource;
  final Widget child;

  static String tagFor(Resource resource) => 'cover-${resource.id}';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: BrowserNavigation.transitionsSuppressed,
      builder: (context, suppressed, _) => HeroMode(
        enabled: !suppressed && !AppMotion.reduced(context),
        child: Hero(tag: tagFor(resource), child: child),
      ),
    );
  }
}
