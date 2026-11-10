import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/resource.dart';
import 'chips.dart';
import 'cover_hero.dart';
import 'favorite_button.dart';
import 'paper.dart';
import 'resource_cover.dart';

/// 列表用的橫式資源卡片:一張微微歪的紙片,左上角一截紙膠帶
class ResourceCard extends StatelessWidget {
  const ResourceCard({super.key, required this.resource});

  final Resource resource;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PressScale(
      child: PaperCard(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Semantics(
          button: true,
          child: InkWell(
            onTap: () => context.push('/resource/${resource.id}'),
            child: Stack(
              children: [
                Padding(
                  // 右側多留空間給角落的收藏按鈕(44×44 觸控範圍)
                  padding: const EdgeInsets.fromLTRB(12, 14, 48, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CoverHero(
                        resource: resource,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: SizedBox(
                            width: 88,
                            height: 88,
                            child: ResourceCover(
                              resource: resource,
                              iconSize: 26,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TypeBadge(type: resource.type),
                            const SizedBox(height: 6),
                            Text(
                              resource.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                            if (resource.summary.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                resource.summary,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                SmallInfoChip(
                                  icon: Icons.child_care,
                                  label: resource.ages
                                      .map((a) => a.label)
                                      .join('、'),
                                ),
                                ...resource.domains
                                    .take(2)
                                    .map(
                                      (domain) => SmallInfoChip(
                                        dotColor: domain.color,
                                        label: domain.label,
                                      ),
                                    ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: FavoriteButton(resourceId: resource.id, compact: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 首頁「精選推薦」的直式卡片
class FeaturedResourceCard extends StatelessWidget {
  const FeaturedResourceCard({super.key, required this.resource});

  final Resource resource;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 240,
      child: PressScale(
        child: PaperCard(
          margin: const EdgeInsets.only(top: 8, bottom: 6),
          child: Semantics(
            button: true,
            child: InkWell(
              onTap: () => context.push('/resource/${resource.id}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 沒有照片時封面壓矮,把空間還給標題
                  AspectRatio(
                    aspectRatio: resource.hasCover ? 16 / 9 : 2.6,
                    child: ResourceCover(
                      resource: resource,
                      iconSize: resource.hasCover ? 34 : 26,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TypeBadge(type: resource.type),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Text(
                              resource.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                          ),
                          Text(
                            resource.ages.map((a) => a.label).join('、'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
