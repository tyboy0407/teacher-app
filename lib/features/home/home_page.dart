import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/prep_summary.dart';
import '../../data/theme_catalog.dart';
import '../../models/taxonomy.dart';
import '../../providers.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/resource_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(featuredResourcesProvider);
    final latest = ref.watch(latestResourcesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(featuredResourcesProvider);
            ref.invalidate(latestResourcesProvider);
            await Future.wait([
              ref.read(featuredResourcesProvider.future),
              ref.read(latestResourcesProvider.future),
            ]);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '老師,您好 👋',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '今天想找什麼教學靈感呢?',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SearchEntry(onTap: () => context.go('/library')),
                    const SizedBox(height: 12),
                    const _PrepBasketCard(),
                  ],
                ),
              ),
              _SectionHeader('本月主題(${DateTime.now().month} 月)'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final topic in themesForMonth(DateTime.now().month))
                      ActionChip(
                        label: Text(topic.display),
                        onPressed: () {
                          ref
                              .read(libraryFilterProvider.notifier)
                              .showTheme(topic.code);
                          context.go('/library');
                        },
                      ),
                    ActionChip(
                      avatar: const Icon(Icons.more_horiz, size: 18),
                      label: const Text('更多主題'),
                      onPressed: () {
                        ref.read(libraryFilterProvider.notifier).reset();
                        context.go('/library');
                      },
                    ),
                  ],
                ),
              ),
              const _SectionHeader('精選推薦'),
              SizedBox(
                height: 236,
                child: featured.when(
                  data: (resources) => ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: resources.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (_, index) =>
                        FeaturedResourceCard(resource: resources[index]),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => ErrorRetry(
                    onRetry: () => ref.invalidate(featuredResourcesProvider),
                  ),
                ),
              ),
              const _SectionHeader('依領域探索'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: LearningDomain.values
                      .map(
                        (domain) => ActionChip(
                          avatar:
                              Icon(domain.icon, size: 18, color: domain.color),
                          label: Text(domain.label),
                          onPressed: () {
                            ref
                                .read(libraryFilterProvider.notifier)
                                .showDomain(domain);
                            context.go('/library');
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
              const _SectionHeader('最新資源'),
              latest.when(
                data: (resources) => Column(
                  children: resources
                      .map((resource) => ResourceCard(resource: resource))
                      .toList(),
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => ErrorRetry(
                  onRetry: () => ref.invalidate(latestResourcesProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 首頁的備課籃入口:顯示這週收了幾個活動、還缺幾項材料。
class _PrepBasketCard extends ConsumerWidget {
  const _PrepBasketCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final basket = ref.watch(prepBasketProvider).value ?? const PrepBasket();
    final resources = ref.watch(prepBasketResourcesProvider).value;
    final String subtitle;
    if (basket.isEmpty) {
      subtitle = '把要用的教具、教案加進來,自動彙整材料與課綱指標';
    } else if (resources == null) {
      subtitle = '${basket.ids.length} 個活動';
    } else {
      final summary = PrepSummary(resources, basket.ownedMaterials);
      final missing = summary.missingMaterials.length;
      subtitle = [
        '${resources.length} 個活動',
        if (summary.materials.isNotEmpty)
          missing == 0 ? '材料已備齊' : '還缺 $missing 項材料',
        if (summary.indicatorCodes.isNotEmpty)
          '${summary.indicatorCodes.length} 條指標',
      ].join(' · ');
    }
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: ListTile(
        onTap: () => context.push('/prep'),
        leading: Icon(
          Icons.shopping_basket_outlined,
          color: theme.colorScheme.onPrimaryContainer,
        ),
        title: Text(
          basket.isEmpty ? '本週備課' : '本週備課:${basket.ids.length} 個活動',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _SearchEntry extends StatelessWidget {
  const _SearchEntry({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.search, size: 20, color: scheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '搜尋教具、教案、文章…',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
