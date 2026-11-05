import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
