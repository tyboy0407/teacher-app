import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/curriculum_service.dart';
import '../../models/resource.dart';
import '../../models/taxonomy.dart';
import '../../providers.dart';
import '../../widgets/chips.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/favorite_button.dart';
import '../../widgets/resource_cover.dart';

class ResourceDetailPage extends ConsumerWidget {
  const ResourceDetailPage({super.key, required this.resourceId});

  final String resourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourceAsync = ref.watch(resourceByIdProvider(resourceId));
    return resourceAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorRetry(
          onRetry: () => ref.invalidate(resourceByIdProvider(resourceId)),
        ),
      ),
      data: (resource) {
        if (resource == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
              icon: Icons.search_off,
              title: '找不到這筆資源',
              subtitle: '它可能已經下架了',
            ),
          );
        }
        return _DetailView(resource: resource);
      },
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({required this.resource});

  final Resource resource;

  String get _contentTitle {
    switch (resource.type) {
      case ResourceType.craft:
        return '延伸與備註';
      case ResourceType.play:
        return '玩法說明';
      case ResourceType.product:
        return '挑選與玩法';
      case ResourceType.lessonPlan:
        return '教案內容';
      case ResourceType.worksheet:
        return '內容與使用建議';
      case ResourceType.routine:
        return '玩法與口令';
      case ResourceType.article:
        return '內文';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 210,
            pinned: true,
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.all(6),
              child: CircleAvatar(
                backgroundColor: Colors.black26,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  tooltip: '返回',
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 20),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 6, 10, 6),
                child: CircleAvatar(
                  backgroundColor: Colors.black26,
                  child: FavoriteButton(
                    resourceId: resource.id,
                    compact: true,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: ResourceCover(resource: resource, iconSize: 56),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      TypeBadge(type: resource.type),
                      if (resource.difficulty != null)
                        SmallInfoChip(
                          label: '難度 ${'★' * resource.difficulty!}',
                        ),
                      if (resource.durationMinutes != null)
                        SmallInfoChip(
                          icon: Icons.schedule,
                          label: '${resource.durationMinutes} 分鐘',
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    resource.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ...resource.ages.map(
                        (age) => SmallInfoChip(
                          icon: Icons.child_care,
                          label: age.fullLabel,
                        ),
                      ),
                      ...resource.domains.map(
                        (domain) => SmallInfoChip(
                          dotColor: domain.color,
                          label: domain.label,
                        ),
                      ),
                      ...resource.tags.map(
                        (tag) => SmallInfoChip(label: '#$tag'),
                      ),
                    ],
                  ),
                  if (resource.videoUrl != null &&
                      resource.videoUrl!.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: () => launchUrl(
                          Uri.parse(resource.videoUrl!),
                          mode: LaunchMode.externalApplication,
                        ),
                        icon: const Icon(Icons.play_circle_outline),
                        label: const Text('觀看示範影片'),
                      ),
                    ),
                  ],
                  if (resource.summary.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        resource.summary,
                        style:
                            theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                      ),
                    ),
                  ],
                  if (resource.indicatorCodes.isNotEmpty)
                    _IndicatorSection(codes: resource.indicatorCodes),
                  if (resource.materials.isNotEmpty)
                    _Section(
                      title: '材料清單',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: resource.materials
                            .map(
                              (material) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 18,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        material,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(height: 1.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  if (resource.steps.isNotEmpty)
                    _Section(
                      title: '製作步驟',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < resource.steps.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor:
                                        theme.colorScheme.primaryContainer,
                                    child: Text(
                                      '${i + 1}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: theme
                                            .colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          resource.steps[i].title,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w600),
                                        ),
                                        if (resource
                                            .steps[i].description.isNotEmpty)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 2),
                                            child: Text(
                                              resource.steps[i].description,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
                                                height: 1.5,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  if (resource.content.isNotEmpty)
                    _Section(
                      title: _contentTitle,
                      child: Text(
                        resource.content,
                        style:
                            theme.textTheme.bodyMedium?.copyWith(height: 1.7),
                      ),
                    ),
                  if (resource.sourceName != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      '資料來源:${resource.sourceName}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 對應課綱學習指標區塊:顯示代碼與全文,一鍵複製後可直接貼進教案。
class _IndicatorSection extends StatelessWidget {
  const _IndicatorSection({required this.codes});

  final List<String> codes;

  String get _copyText {
    return codes.map((code) {
      final indicator = CurriculumService.indicator(code);
      return indicator == null ? code : '${indicator.code} ${indicator.text}';
    }).join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '對應課綱學習指標',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: _copyText));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('已複製 ${codes.length} 條指標,可直接貼進教案'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('複製'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final code in codes)
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
                  child: indicator == null
                      ? Text(code, style: theme.textTheme.bodyMedium)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (indicator.domain != null) ...[
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: indicator.domain!.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  indicator.code,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  indicator.age?.label ?? '',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              indicator.text,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(height: 1.4),
                            ),
                          ],
                        ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
