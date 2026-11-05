import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/resource.dart';

/// 資源封面:有圖片網址就顯示圖片,否則用領域色漸層 + 類型圖示當佔位封面。
class ResourceCover extends StatelessWidget {
  const ResourceCover({super.key, required this.resource, this.iconSize = 40});

  final Resource resource;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final url = resource.coverUrl;
    if (url != null && url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (context, _) =>
            Container(color: Theme.of(context).colorScheme.surfaceContainerHighest),
        errorWidget: (context, _, _) => _PlaceholderCover(
          resource: resource,
          iconSize: iconSize,
        ),
      );
    }
    return _PlaceholderCover(resource: resource, iconSize: iconSize);
  }
}

class _PlaceholderCover extends StatelessWidget {
  const _PlaceholderCover({required this.resource, required this.iconSize});

  final Resource resource;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final base = resource.domains.isNotEmpty
        ? resource.domains.first.color
        : Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            base.withValues(alpha: .82),
            base.withValues(alpha: .5),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        resource.type.icon,
        size: iconSize,
        color: Colors.white.withValues(alpha: .9),
      ),
    );
  }
}
