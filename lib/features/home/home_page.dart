import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../data/prep_summary.dart';
import '../../data/theme_catalog.dart';
import '../../models/taxonomy.dart';
import '../../providers.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/resource_card.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/entrance.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(featuredResourcesProvider);
    final latest = ref.watch(latestResourcesProvider);

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
              _ChalkboardHeader(onSearchTap: () => context.go('/library')),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: _PrepBasketCard(),
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
                        avatar: Icon(topic.icon, size: 18),
                        label: Text(topic.label),
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
                height: 212,
                child: featured.when(
                  data: (resources) => EntranceWindow(
                    builder: (context, entrance) => ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: resources.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (_, index) => StaggeredEntrance(
                        index: index,
                        enabled: entrance,
                        maxAnimated: 3,
                        child: FeaturedResourceCard(resource: resources[index]),
                      ),
                    ),
                  ),
                  loading: () => const SkeletonList(count: 3, horizontal: true),
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
                          avatar: Icon(
                            domain.icon,
                            size: 18,
                            color: domain.color,
                          ),
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
                data: (resources) => EntranceWindow(
                  builder: (context, entrance) => Column(
                    children: [
                      for (var i = 0; i < resources.length; i++)
                        StaggeredEntrance(
                          index: i,
                          enabled: entrance,
                          child: ResourceCard(resource: resources[i]),
                        ),
                    ],
                  ),
                ),
                loading: () => const SkeletonList(count: 3, shrinkWrap: true),
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

/// 首頁開頭的黑板:問候語依時段、今天的日期、搜尋框。整個 App 唯一大膽的區塊。
class _ChalkboardHeader extends StatelessWidget {
  const _ChalkboardHeader({required this.onSearchTap});

  final VoidCallback onSearchTap;

  static const _weekdays = ['一', '二', '三', '四', '五', '六', '日'];

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return '老師早安';
    if (hour < 17) return '老師午安';
    return '老師晚安';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: const BoxDecoration(
        color: AppColors.chalkboard,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${now.month} 月 ${now.day} 日 星期${_weekdays[now.weekday - 1]}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.chalk.withValues(alpha: .72),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _greeting,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.chalk,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 16),
          _SearchEntry(onTap: onSearchTap),
        ],
      ),
    );
  }
}

/// 首頁的備課籃入口:一張蠟筆黃便利貼,顯示這週收了幾個活動、還缺幾項材料。
class _PrepBasketCard extends ConsumerWidget {
  const _PrepBasketCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final basket =
        ref.watch(prepBasketProvider).valueOrNull ?? const PrepBasket();
    final resources = ref.watch(prepBasketResourcesProvider).valueOrNull;
    final String subtitle;
    if (basket.isEmpty) {
      subtitle = '把要用的教具、教案加進來,材料和課綱指標會自動整理好';
    } else if (resources == null) {
      subtitle = '整理材料與指標中…';
    } else {
      final summary = PrepSummary(resources, basket.ownedMaterials);
      final missing = summary.missingMaterials.length;
      final parts = <String>[
        if (summary.materials.isNotEmpty)
          missing == 0 ? '材料都備齊了' : '還缺 $missing 項材料',
        if (summary.indicatorCodes.isNotEmpty)
          '對應 ${summary.indicatorCodes.length} 條指標',
      ];
      subtitle = parts.isEmpty ? '點進去整理材料與指標' : parts.join(',');
    }
    return Card(
      color: AppColors.crayonYellow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        onTap: () => context.push('/prep'),
        leading: const Icon(
          Icons.push_pin_outlined,
          color: AppColors.crayonYellowDeep,
        ),
        title: Text(
          basket.isEmpty ? '本週備課' : '本週備課:${basket.ids.length} 個活動',
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppColors.crayonYellowDeep,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.crayonYellowDeep,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.crayonYellowDeep,
        ),
      ),
    );
  }
}

class _SearchEntry extends StatelessWidget {
  const _SearchEntry({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // 粉筆白的搜尋框,嵌在黑板裡
    return Material(
      color: AppColors.chalk,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              const Icon(Icons.search, size: 20, color: AppColors.inkSoft),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '找教具、教案、文章',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
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
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
