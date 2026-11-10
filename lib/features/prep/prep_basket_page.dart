import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation.dart';
import '../../core/share.dart';
import '../../core/undo.dart';
import '../../data/curriculum_service.dart';
import '../../data/prep_summary.dart';
import '../../models/resource.dart';
import '../../providers.dart';
import '../../widgets/chips.dart';
import '../../widgets/collapsible_row.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/resource_cover.dart';

/// 本週備課:老師收進來的活動,自動彙整材料採買清單與課綱指標。
class PrepBasketPage extends ConsumerWidget {
  const PrepBasketPage({super.key});

  /// 清空是可逆的:直接清掉,5 秒內可整籃復原(含材料勾選)
  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(prepBasketProvider.notifier);
    final snapshot =
        ref.read(prepBasketProvider).valueOrNull ?? const PrepBasket();
    await notifier.clear();
    if (!context.mounted) return;
    showUndoSnackBar(
      context,
      message: '已清空備課籃(${snapshot.ids.length} 個活動)',
      onUndo: () => notifier.replace(snapshot),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final basket =
        ref.watch(prepBasketProvider).valueOrNull ?? const PrepBasket();
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
                  onPressed: () => _clear(context, ref),
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

class _ActivitiesTab extends ConsumerStatefulWidget {
  const _ActivitiesTab({required this.resources});

  final List<Resource> resources;

  @override
  ConsumerState<_ActivitiesTab> createState() => _ActivitiesTabState();
}

class _ActivitiesTabState extends ConsumerState<_ActivitiesTab> {
  /// 正在播收合動畫的活動;動畫結束才真正移出籃子
  final _removing = <String>{};

  /// 剛復原、要播展開動畫的活動
  String? _appearing;

  void _startRemove(String id) => setState(() => _removing.add(id));

  void _finishRemove(Resource resource, int index) {
    final notifier = ref.read(prepBasketProvider.notifier);
    notifier.remove(resource.id);
    setState(() {
      _removing.remove(resource.id);
      _appearing = null;
    });
    showUndoSnackBar(
      context,
      message: '已移出「${resource.title}」',
      onUndo: () {
        setState(() => _appearing = resource.id);
        notifier.insertAt(resource.id, index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final resources = widget.resources;
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                '按住右側把手拖曳,或點右側的「更多動作」調整順序',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
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
              return CollapsibleRow(
                key: ValueKey(resource.id),
                removing: _removing.contains(resource.id),
                appearing: _appearing == resource.id,
                onCollapsed: () => _finishRemove(resource, index),
                child: Card(
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
                        // 拖曳之外也能用選單調整順序(無障礙:不能只靠拖曳)
                        PopupMenuButton<_ActivityAction>(
                          tooltip: '更多動作',
                          icon: Icon(
                            Icons.more_vert,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          onSelected: (action) {
                            final notifier = ref.read(
                              prepBasketProvider.notifier,
                            );
                            switch (action) {
                              case _ActivityAction.moveUp:
                                notifier.reorder(index, index - 1);
                              case _ActivityAction.moveDown:
                                notifier.reorder(index, index + 1);
                              case _ActivityAction.remove:
                                _startRemove(resource.id);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: _ActivityAction.moveUp,
                              enabled: index > 0,
                              child: const ListTile(
                                leading: Icon(Icons.arrow_upward),
                                title: Text('上移'),
                              ),
                            ),
                            PopupMenuItem(
                              value: _ActivityAction.moveDown,
                              enabled: index < resources.length - 1,
                              child: const ListTile(
                                leading: Icon(Icons.arrow_downward),
                                title: Text('下移'),
                              ),
                            ),
                            const PopupMenuItem(
                              value: _ActivityAction.remove,
                              child: ListTile(
                                leading: Icon(Icons.remove_circle_outline),
                                title: Text('移出備課籃'),
                              ),
                            ),
                          ],
                        ),
                        ReorderableDragStartListener(
                          index: index,
                          child: Semantics(
                            label: '拖曳調整順序',
                            child: SizedBox(
                              width: 44,
                              height: 44,
                              child: Icon(
                                Icons.drag_handle,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

enum _ActivityAction { moveUp, moveDown, remove }

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
        subtitle: '免教具的活動最省事',
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
                      ? '共 ${summary.materials.length} 項,全部備齊'
                      : '共 ${summary.materials.length} 項,還缺 $missing 項',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: summary.shoppingListText()),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('已複製採買清單')));
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
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        // 依活動分組:組標題寫一次活動名,組內只列材料;同一材料只在第一次出現的
        // 活動下列出,附註還有哪些活動也用到
        ..._groupedMaterials(context, ref, theme),
      ],
    );
  }
}

extension on _MaterialsTab {
  List<Widget> _groupedMaterials(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    final shown = <String>{};
    final widgets = <Widget>[];
    for (final resource in summary.resources) {
      final items = resource.materials.where(shown.add).toList();
      if (items.isEmpty) continue;
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 2),
          child: Text(
            resource.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
      for (final material in items) {
        final owned = summary.ownedMaterials.contains(material);
        final others = (summary.materials[material] ?? const [])
            .where((title) => title != resource.title)
            .toList();
        widgets.add(
          CheckboxListTile(
            value: owned,
            onChanged: (_) =>
                ref.read(prepBasketProvider.notifier).toggleMaterial(material),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            title: Text(
              material,
              style: owned
                  ? TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: theme.colorScheme.outline,
                    )
                  : null,
            ),
            subtitle: others.isEmpty
                ? null
                : Text(
                    '也用於:${others.join('、')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        );
      }
    }
    return widgets;
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
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
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
                      content: Text('已複製 ${summary.indicatorCodes.length} 條指標'),
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
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    if (indicator != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        indicator.text,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ),
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
