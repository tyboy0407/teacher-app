import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/resource.dart';
import 'paper.dart';

/// 資源封面:有圖片網址就顯示圖片,否則用領域的便利貼色當色紙,
/// 角落貼一張圓形貼紙(資源類型圖示)。
class ResourceCover extends StatelessWidget {
  const ResourceCover({super.key, required this.resource, this.iconSize = 40});

  final Resource resource;

  /// 貼紙大小的基準(貼紙直徑約為它的 1.3 倍)
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final url = resource.coverUrl;
    if (url != null && url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (context, _) => Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        errorWidget: (context, _, _) =>
            _StickyCover(resource: resource, iconSize: iconSize),
      );
    }
    return _StickyCover(resource: resource, iconSize: iconSize);
  }
}

class _StickyCover extends StatelessWidget {
  const _StickyCover({required this.resource, required this.iconSize});

  final Resource resource;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final domain = resource.domains.isNotEmpty ? resource.domains.first : null;
    final paper =
        domain?.sticky ?? Theme.of(context).colorScheme.primaryContainer;
    final ink = domain?.color ?? Theme.of(context).colorScheme.primary;
    final sticker = iconSize * 1.3;
    return Container(
      color: paper,
      child: Stack(
        children: [
          // 色紙上的細點,像有紋路的紙
          Positioned.fill(
            child: ExcludeSemantics(
              child: CustomPaint(
                painter: _DotsPainter(ink.withValues(alpha: .10)),
              ),
            ),
          ),
          Positioned(
            right: sticker * 0.18,
            bottom: sticker * 0.18,
            child: StickerIcon(
              icon: resource.type.icon,
              color: ink,
              size: sticker,
            ),
          ),
        ],
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  const _DotsPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const gap = 14.0;
    for (var y = gap / 2; y < size.height; y += gap) {
      for (var x = gap / 2; x < size.width; x += gap) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotsPainter oldDelegate) => oldDelegate.color != color;
}
