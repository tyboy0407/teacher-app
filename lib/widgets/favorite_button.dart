import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({
    super.key,
    required this.resourceId,
    this.compact = false,
    this.color,
  });

  final String resourceId;

  /// 卡片上使用的縮小版
  final bool compact;

  /// 未收藏時的圖示顏色(詳情頁封面上需要白色)
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite =
        ref.watch(favoritesProvider).valueOrNull?.contains(resourceId) ?? false;
    return IconButton(
      onPressed: () => ref.read(favoritesProvider.notifier).toggle(resourceId),
      tooltip: isFavorite ? '移除收藏' : '加入收藏',
      // 圖示縮小,但觸控範圍維持 44×44(不用 compact 密度,它會把觸控範圍壓到 40)
      padding: compact ? EdgeInsets.zero : null,
      constraints: compact
          ? const BoxConstraints(minWidth: 44, minHeight: 44)
          : null,
      iconSize: compact ? 20 : null,
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite
            ? Colors.redAccent
            : (color ?? Theme.of(context).colorScheme.outline),
      ),
    );
  }
}
