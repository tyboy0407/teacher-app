import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/motion.dart';
import '../../data/theme_catalog.dart';
import '../../models/taxonomy.dart';
import '../../providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/entrance.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/resource_card.dart';
import '../../widgets/skeleton.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(libraryFilterProvider).query,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        ref.read(libraryFilterProvider.notifier).setQuery(value);
      }
    });
  }

  /// 本月行事曆上的主題在前,其餘照目錄順序
  List<ThemeTopic> _orderedThemes() {
    final now = themesForMonth(DateTime.now().month);
    return [...now, ...themeTopics.where((t) => !now.contains(t))];
  }

  void _clearQuery() {
    _debounce?.cancel();
    _searchController.clear();
    ref.read(libraryFilterProvider.notifier).setQuery('');
  }

  /// 目前生效的篩選條件,每一項附上「單獨取消」的動作
  List<_ActiveFilter> _activeFilters(ResourceFilter filter) {
    final notifier = ref.read(libraryFilterProvider.notifier);
    return [
      if (filter.query.trim().isNotEmpty)
        _ActiveFilter('「${filter.query.trim()}」', _clearQuery),
      if (filter.type != null)
        _ActiveFilter(filter.type!.label, () => notifier.setType(null)),
      if (filter.theme != null)
        _ActiveFilter(
          themeByCode(filter.theme!)?.label ?? filter.theme!,
          () => notifier.setTheme(null),
        ),
      for (final age in filter.ages)
        _ActiveFilter(age.label, () => notifier.toggleAge(age)),
      for (final domain in filter.domains)
        _ActiveFilter(domain.label, () => notifier.toggleDomain(domain)),
      for (final tag in filter.tags)
        _ActiveFilter('#$tag', () => notifier.toggleTag(tag)),
    ];
  }

  void _clearAll() {
    _debounce?.cancel();
    _searchController.clear();
    ref.read(libraryFilterProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(libraryFilterProvider);
    final results = ref.watch(libraryResultsProvider);
    final tags = ref.watch(allTagsProvider).valueOrNull ?? const <String>[];
    final notifier = ref.read(libraryFilterProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('資源庫'),
        actions: [
          IconButton(
            icon: const Icon(Icons.rule),
            tooltip: '課綱指標查詢',
            onPressed: () => context.push('/indicators'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onQueryChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: '搜尋教具、教案關鍵字',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: filter.query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: '清除關鍵字',
                        onPressed: _clearQuery,
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          _FilterRow(
            label: '類型',
            children: [
              ChoiceChip(
                label: const Text('全部'),
                selected: filter.type == null,
                onSelected: (_) => notifier.setType(null),
              ),
              ...ResourceType.values.map(
                (type) => ChoiceChip(
                  label: Text(type.label),
                  selected: filter.type == type,
                  onSelected: (_) => notifier.setType(type),
                ),
              ),
            ],
          ),
          _FilterRow(
            label: '主題',
            children: [
              ChoiceChip(
                label: const Text('全部'),
                selected: filter.theme == null,
                onSelected: (_) => notifier.setTheme(null),
              ),
              // 本月的主題排最前面,其餘照目錄順序
              ..._orderedThemes().map(
                (topic) => ChoiceChip(
                  avatar: Icon(topic.icon, size: 16),
                  label: Text(topic.label),
                  selected: filter.theme == topic.code,
                  onSelected: (_) => notifier.setTheme(topic.code),
                ),
              ),
            ],
          ),
          _FilterRow(
            label: '年齡',
            children: AgeStage.values
                .where((age) => age != AgeStage.all)
                .map(
                  (age) => FilterChip(
                    label: Text(age.label),
                    selected: filter.ages.contains(age),
                    onSelected: (_) => notifier.toggleAge(age),
                  ),
                )
                .toList(),
          ),
          _FilterRow(
            label: '領域',
            children: LearningDomain.values
                .map(
                  (domain) => FilterChip(
                    avatar: filter.domains.contains(domain)
                        ? null
                        : Icon(domain.icon, size: 16, color: domain.color),
                    label: Text(domain.label),
                    selected: filter.domains.contains(domain),
                    onSelected: (_) => notifier.toggleDomain(domain),
                  ),
                )
                .toList(),
          ),
          if (tags.isNotEmpty)
            _FilterRow(
              label: '標籤',
              children: tags
                  .map(
                    (tag) => FilterChip(
                      label: Text('#$tag'),
                      selected: filter.tags.contains(tag),
                      onSelected: (_) => notifier.toggleTag(tag),
                    ),
                  )
                  .toList(),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 36,
                  child: Row(
                    children: [
                      AnimatedSwitcher(
                        duration: AppMotion.fast,
                        child: Text(
                          results.hasValue
                              ? '共 ${results.value!.length} 筆資源'
                              : '',
                          key: ValueKey(results.valueOrNull?.length),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (!filter.isEmpty)
                        TextButton.icon(
                          onPressed: _clearAll,
                          icon: const Icon(Icons.filter_alt_off, size: 16),
                          label: const Text('清除篩選'),
                        ),
                    ],
                  ),
                ),
                // 已選條件的摘要:條件列捲出畫面後,老師仍看得到自己篩了什麼,
                // 也能單獨取消某一個(辨識優於回憶)
                if (!filter.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        for (final item in _activeFilters(filter))
                          InputChip(
                            label: Text(item.label),
                            visualDensity: VisualDensity.compact,
                            deleteButtonTooltipMessage: '移除條件 ${item.label}',
                            onDeleted: item.remove,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            // 篩選切換、骨架 → 內容都交叉淡入;每批結果用自己的 key
            child: CrossfadeSwitcher(
              child: results.when(
                data: (resources) => resources.isEmpty
                    ? const EmptyState(
                        key: ValueKey('empty'),
                        icon: Icons.search_off,
                        title: '找不到符合條件的資源',
                        subtitle: '試試換個關鍵字,或放寬篩選條件',
                      )
                    : EntranceWindow(
                        key: ValueKey(identityHashCode(resources)),
                        builder: (context, entrance) => ListView.builder(
                          padding: const EdgeInsets.only(top: 4, bottom: 24),
                          itemCount: resources.length,
                          itemBuilder: (_, index) => StaggeredEntrance(
                            index: index,
                            enabled: entrance,
                            child: ResourceCard(resource: resources[index]),
                          ),
                        ),
                      ),
                loading: () => const SkeletonList(key: ValueKey('loading')),
                error: (_, _) => ErrorRetry(
                  key: const ValueKey('error'),
                  onRetry: () => ref.invalidate(libraryResultsProvider),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveFilter {
  const _ActiveFilter(this.label, this.remove);

  final String label;
  final VoidCallback remove;
}

/// 一列橫向捲動的篩選 chip。右側有一道淡出,告訴老師「後面還有」;
/// 捲到底就消失。
class _FilterRow extends StatefulWidget {
  const _FilterRow({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  State<_FilterRow> createState() => _FilterRowState();
}

class _FilterRowState extends State<_FilterRow> {
  final _controller = ScrollController();
  bool _moreToTheRight = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_update);
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  @override
  void didUpdateWidget(covariant _FilterRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  @override
  void dispose() {
    _controller.removeListener(_update);
    _controller.dispose();
    super.dispose();
  }

  void _update() {
    if (!mounted || !_controller.hasClients) return;
    final position = _controller.position;
    final more =
        position.maxScrollExtent > 0 &&
        position.pixels < position.maxScrollExtent - 1;
    if (more != _moreToTheRight) setState(() => _moreToTheRight = more);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = theme.scaffoldBackgroundColor;
    return SizedBox(
      height: 48,
      child: Stack(
        children: [
          ListView(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    widget.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              ...widget.children.map(
                (chip) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Center(child: chip),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: AppMotion.fast,
                opacity: _moreToTheRight ? 1 : 0,
                child: Container(
                  key: ValueKey('filter-fade-${widget.label}'),
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [background.withValues(alpha: 0), background],
                    ),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 2),
                  child: Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
