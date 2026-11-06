import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation.dart';
import '../../core/share.dart';
import '../../data/curriculum_service.dart';
import '../../data/prep_summary.dart';
import '../../models/resource.dart';
import '../../providers.dart';
import '../../widgets/chips.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/resource_cover.dart';

/// 本週備課:老師收進來的活動,自動彙整材料採買清單與課綱指標。
class PrepBasketPage extends ConsumerWidget {
  const PrepBasketPage({super.key});

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空備課籃'),
        content: const Text('這週的活動與材料勾選都會清掉,確定嗎?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('清空'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(prepBasketProvider.notifier).clear();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final basket = ref.watch(prepBasketProvider).value ?? const PrepBasket();
    final resourcesAsync = ref.watch(prepBasketResourcesProvider);

    if (basket.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: const Text('本週備課'),
        ),
        body: EmptyState(
          icon: Icons.shopping_basket_outlined,
          title: '備課籃是空的',
          subtitle: '在資源詳情頁點「加入備課」,這裡會自動彙整材料採買清單與課綱指標',
          action: FilledButton.icon(
            onPressed: () => context.go('/library'),
            icon: const Icon(Icons.search),
            label: const Text('去資源庫找素材'),
          ),
        ),
      );
    }

    return resourcesAsync.when(
      skipLoadingOnReload: true,
      loading: () => Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: const Text('本週備課'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: const Text('本週備課'),
        ),
        body: ErrorRetry(
          onRetry: () => ref.invalidate(prepBasketResourcesProvider),
        ),
      ),
      data: (resources) {
        final summary = PrepSummary(resources, basket.ownedMaterials);
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              leading: const AppBackButton(),
              title: const Text('本週備課'),
              actions: [
                IconButton(
                  tooltip: '分享備課摘要',
                  icon: const Icon(Icons.share),
                  onPressed: () => showShareSheet(
                    context,
                    title: '本週備課(${resources.length} 個活動)',
                    text: summary.shareText(),
                  ),
                ),
                IconButton(
                  tooltip: '清空備課籃',
                  icon: const Icon(Icons.delete_sweep_outlined),
                  onPressed: () => _confirmClear(context, ref),
                ),
              ],
              bottom: TabBar(
                tabs: [
                  Tab(text: '活動 ${resources.length}'),
                  Tab(
                    text: summary.materials.isEmpty
                        ? '材料'
                        : '材料 缺 ${summary.missingMaterials.length}',
                  ),
                  Tab(text: '指標 ${summary.indicatorCodes.length}'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _ActivitiesTab(resources: resources),
                _MaterialsTab(summary: summary),
                _IndicatorsTab(summary: summary),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActivitiesTab extends ConsumerWidget {
  const _ActivitiesTab({required this.resources});

  final List<Resource> resources;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
          child: Row(
            children: [
              Icon(Icons.info_outline,
                  size: 14, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                '按住右側把手可拖曳調整活動順序',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
            buildDefaultDragHandles: false,
            itemCount: resources.length,
            onReorderItem: (oldIndex, newIndex) => ref
                .read(prepBasketProvider.notifier)
                .reorder(oldIndex, newIndex),
            itemBuilder: (context, index) {
              final resource = resources[index];
              return Card(
                key: ValueKey(resource.id),
                margin: const EdgeInsets.only(bottom: 10),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  onTap: () => context.push('/resource/${resource.id}'),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: ResourceCover(resource: resource, iconSize: 20),
                    ),
                  ),
                  title: Text(
                    '${index + 1}. ${resource.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        TypeBadge(type: resource.type),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            resource.ages.map((a) => a.label).join('、'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: '移出備課籃',
                        icon: Icon(Icons.remove_circle_outline,
                            color: theme.colorScheme.outline),
                        onPressed: () => ref
                            .read(prepBasketProvider.notifier)
                            .remove(resource.id),
                      ),
                      ReorderableDragStartListener(
                        index: index,
                        child: Icon(Icons.drag_handle,
                            color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MaterialsTab extends ConsumerWidget {
  const _MaterialsTab({required this.summary});

  final PrepSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    if (summary.materials.isEmpty) {
      return const EmptyState(
        icon: Icons.inventory_2_outlined,
        title: '這些活動不需要準備材料',
        subtitle: '免教具的活動最省事 👍',
      );
    }
    final missing = summary.missingMaterials.length;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  missing == 0
                      ? '共 ${summary.materials.length} 項,全部備齊 🎉'
                      : '共 ${summary.materials.length} 項,還缺 $missing 項',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: summary.shoppingListText()),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已複製採買清單')),
                    );
                  }
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('複製採買清單'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
          child: Text(
            '勾掉已經有的,剩下的就是要買的',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        for (final entry in summary.materials.entries)
          CheckboxListTile(
            value: summary.ownedMaterials.contains(entry.key),
            onChanged: (_) => ref
                .read(prepBasketProvider.notifier)
                .toggleMaterial(entry.key),
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              entry.key,
              style: summary.ownedMaterials.contains(entry.key)
                  ? TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: theme.colorScheme.outline,
                    )
                  : null,
            ),
            subtitle: Text(
              '用於:${entry.value.join('、')}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

class _IndicatorsTab extends StatelessWidget {
  const _IndicatorsTab({required this.summary});

  final PrepSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (summary.indicatorCodes.isEmpty) {
      return const EmptyState(
        icon: Icons.rule,
        title: '這些活動還沒對應課綱指標',
        subtitle: '可到「課綱指標查詢」找合適的指標',
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '共 ${summary.indicatorCodes.length} 條,可直接貼進教案',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: summary.indicatorsText()),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('已複製 ${summary.indicatorCodes.length} 條指標'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('複製全部'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        for (final code in summary.indicatorCodes)
          Builder(
            builder: (context) {
              final indicator = CurriculumService.indicator(code);
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (indicator?.domain != null) ...[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: indicator!.domain!.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          code,
                          style: theme.textTheme.labelMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    if (indicator != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        indicator.text,
                        style:
                            theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
