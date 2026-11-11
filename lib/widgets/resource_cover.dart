import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/resource.dart';
import 'paper.dart';
import 'resource_image.dart';

/// 資源封面:有圖片網址就顯示圖片,否則用領域色調出來的淡色塊。
/// 列表卡片上放一個小圖示(資源類型);詳情頁([sticker] 為真)放一張圓形貼紙。
class ResourceCover extends StatelessWidget {
  const ResourceCover({
    super.key,
    required this.resource,
    this.iconSize = 40,
    this.sticker = false,
  });

  final Resource resource;
  final double iconSize;
  final bool sticker;

  @override
  Widget build(BuildContext context) {
    final url = resource.coverUrl;
    final tint = _TintCover(
      resource: resource,
      iconSize: iconSize,
      sticker: sticker,
    );
    if (url != null && url.isNotEmpty) {
      return ResourceImage(url: url, fallback: tint);
    }
    return tint;
  }
}

class _TintCover extends StatelessWidget {
  const _TintCover({
    required this.resource,
    required this.iconSize,
    required this.sticker,
  });

  final Resource resource;
  final double iconSize;
  final bool sticker;

  @override
  Widget build(BuildContext context) {
    final domain = resource.domains.isNotEmpty ? resource.domains.first : null;
    final hue = domain?.color ?? AppColors.sage;
    // 同色系的淡色塊:底色往領域色靠一點點,六個領域看得出差別但都很安靜
    final tint = Color.lerp(AppColors.paper, hue, 0.14)!;
    return Container(
      color: tint,
      alignment: sticker ? Alignment.bottomRight : Alignment.center,
      padding: sticker ? EdgeInsets.all(iconSize * 0.3) : EdgeInsets.zero,
      child: sticker
          ? StickerIcon(
              icon: resource.type.icon,
              color: hue,
              size: iconSize * 1.4,
            )
          : Icon(resource.type.icon, size: iconSize, color: hue),
    );
  }
}
