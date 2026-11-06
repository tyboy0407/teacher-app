import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/theme_catalog.dart';
import '../../models/taxonomy.dart';
import '../../providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/resource_card.dart';

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
    _searchController =
        TextEditingController(text: ref.read(libraryFilterProvider).query);
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

  void _clearQuery() {
    _debounce?.cancel();
    _searchController.clear();
    ref.read(libraryFilterProvider.notifier).setQuery('');
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
              ...themeTopics.map(
                (topic) => ChoiceChip(
                  label: Text(topic.display),
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
            child: SizedBox(
              height: 36,
              child: Row(
                children: [
                  Text(
                    results.hasValue ? '共 ${results.value!.length} 筆資源' : '',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
          ),
          Expanded(
            child: results.when(
              data: (resources) => resources.isEmpty
                  ? const EmptyState(
                      icon: Icons.search_off,
                      title: '找不到符合條件的資源',
                      subtitle: '試試換個關鍵字,或放寬篩選條件',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 24),
                      itemCount: resources.length,
                      itemBuilder: (_, index) =>
                          ResourceCard(resource: resources[index]),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => ErrorRetry(
                onRetry: () => ref.invalidate(libraryResultsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          ...children.map(
            (chip) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(child: chip),
            ),
          ),
        ],
      ),
    );
  }
}
