import 'package:flutter/material.dart';

import '../models/taxonomy.dart';

/// 資源類型小徽章
class TypeBadge extends StatelessWidget {
  const TypeBadge({super.key, required this.type});

  final ResourceType type;

  @override
  Widget build(BuildContext context) {
    // 像學習區的小名牌:方角標籤,和圓形膠囊的年齡/領域資訊區分開
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type.label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: scheme.onPrimaryContainer),
      ),
    );
  }
}

/// 卡片與詳情頁上的小資訊膠囊(年齡、領域、標籤共用)
class SmallInfoChip extends StatelessWidget {
  const SmallInfoChip({
    super.key,
    required this.label,
    this.icon,
    this.dotColor,
  });

  final String label;
  final IconData? icon;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: scheme.onSurfaceVariant),
            const SizedBox(width: 3),
          ],
          if (dotColor != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
