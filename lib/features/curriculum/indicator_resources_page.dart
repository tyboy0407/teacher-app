import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation.dart';
import '../../data/curriculum_service.dart';
import '../../providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/resource_card.dart';

/// 指標反查:列出對應某條課綱學習指標的所有資源。
class IndicatorResourcesPage extends ConsumerWidget {
  const IndicatorResourcesPage({super.key, required this.indicatorCode});

  final String indicatorCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final indicator = CurriculumService.indicator(indicatorCode);
    final goal =
        indicator == null ? null : CurriculumService.goal(indicator.goalCode);
    final results = ref.watch(indicatorResourcesProvider(indicatorCode));

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(indicatorCode),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (indicator == null)
                    Text(
                      '查無此指標代碼',
                      style: theme.textTheme.bodyMedium,
                    )
                  else ...[
                    Row(
                      children: [
                        if (indicator.domain != null) ...[
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: indicator.domain!.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            '${indicator.domain?.label ?? ''}領域,'
                            '${indicator.age?.fullLabel ?? ''}',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      indicator.text,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    if (goal != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '課程目標 ${goal.code} ${goal.title}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '對應資源',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: results.when(
              data: (resources) => resources.isEmpty
                  ? const EmptyState(
                      icon: Icons.link_off,
                      title: '還沒有對應這條指標的資源',
                      subtitle: '之後錄入內容時,在指標欄位填入這個代碼即可建立連結',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 24),
                      itemCount: resources.length,
                      itemBuilder: (_, index) =>
                          ResourceCard(resource: resources[index]),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => ErrorRetry(
                onRetry: () =>
                    ref.invalidate(indicatorResourcesProvider(indicatorCode)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
