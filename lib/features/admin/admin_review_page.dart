import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation.dart';
import '../../models/resource.dart';
import '../../providers.dart';
import '../../widgets/chips.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/paper.dart';
import '../../widgets/resource_cover.dart';

/// 管理者:待審投稿清單。點進去是老師看到的詳情頁,底部多一條審核操作列。
class AdminReviewPage extends ConsumerWidget {
  const AdminReviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingReviewsProvider);
    final unpublished =
        ref.watch(unpublishedResourcesProvider).valueOrNull ??
        const <Resource>[];
    return Scaffold(
      appBar: AppBar(leading: const AppBackButton(), title: const Text('審核投稿')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pendingReviewsProvider);
          ref.invalidate(unpublishedResourcesProvider);
          await ref.read(pendingReviewsProvider.future);
        },
        child: pending.when(
          data: (resources) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 8, bottom: 32),
            children: [
              if (resources.isEmpty) ...[
                SizedBox(height: unpublished.isEmpty ? 120 : 24),
                const EmptyState(
                  icon: Icons.task_alt,
                  title: '目前沒有待審投稿',
                  subtitle: '老師送出投稿後會出現在這裡',
                ),
              ] else ...[
                _Hint('共 ${resources.length} 筆待審,依投稿時間先後排列'),
                for (final resource in resources)
                  _PendingCard(resource: resource),
              ],
              if (unpublished.isNotEmpty) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 2),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: HighlightedTitle('已下架(${unpublished.length})'),
                  ),
                ),
                const _Hint('老師們看不到這些內容;點進去可重新上架或刪除'),
                for (final resource in unpublished)
                  _PendingCard(resource: resource, dateSuffix: '下架'),
              ],
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) =>
              ErrorRetry(onRetry: () => ref.invalidate(pendingReviewsProvider)),
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.resource, this.dateSuffix = '投稿'});

  final Resource resource;
  final String dateSuffix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final created = resource.createdAt;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/resource/${resource.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: ResourceCover(resource: resource, iconSize: 26),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TypeBadge(type: resource.type),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${created.year}/${created.month}/${created.day} $dateSuffix',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      resource.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (resource.summary.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          resource.summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
