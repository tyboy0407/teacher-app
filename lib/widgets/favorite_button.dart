import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'bounce_icon_button.dart';

/// 收藏按鈕:按下會彈一下,不跳 SnackBar(收藏是輕量動作,訊息會變噪音)。
class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({
    super.key,
    required this.resourceId,
    this.compact = false,
    this.color,
  });

  final String resourceId;

  /// 卡片上使用的縮小版(只縮圖示,觸控範圍仍 44×44)
  final bool compact;

  /// 未收藏時的圖示顏色(詳情頁封面上需要白色)
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite =
        ref.watch(favoritesProvider).valueOrNull?.contains(resourceId) ?? false;
    return BounceIconButton(
      onPressed: () => ref.read(favoritesProvider.notifier).toggle(resourceId),
      tooltip: isFavorite ? '移除收藏' : '加入收藏',
      compact: compact,
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite
            ? Colors.redAccent
            : (color ?? Theme.of(context).colorScheme.outline),
      ),
    );
  }
}
