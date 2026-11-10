import 'package:flutter/material.dart';

import '../models/resource.dart';

/// 投稿審核狀態小標籤:審核中 / 未通過 / 已上架 / 已下架
class ReviewStatusChip extends StatelessWidget {
  const ReviewStatusChip({super.key, required this.resource});

  final Resource resource;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (resource.reviewStatus) {
      'pending' => ('審核中', Colors.orange),
      'rejected' => ('未通過', Colors.red),
      _ => resource.published ? ('已上架', Colors.green) : ('已下架', Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
