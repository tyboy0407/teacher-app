import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 顯示資源的圖片,網址有三種:
/// - `asset:assets/lessons/xxx.svg`:App 內建的插圖(範本教案),離線也看得到
/// - `https://…/xxx.svg`:網路上的向量圖
/// - 其他 `https://…`:老師投稿的照片
///
/// 一律填滿父層給的空間([fit] 預設裁切填滿);載入失敗顯示 [fallback]。
class ResourceImage extends StatelessWidget {
  const ResourceImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.fallback,
  });

  final String url;
  final BoxFit fit;
  final Widget? fallback;

  static const assetScheme = 'asset:';

  static bool isBundled(String? url) =>
      url != null && url.startsWith(assetScheme);

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
    final onError = fallback ?? placeholder;

    if (url.startsWith(assetScheme)) {
      final path = url.substring(assetScheme.length);
      if (path.toLowerCase().endsWith('.svg')) {
        return SizedBox.expand(
          child: SvgPicture.asset(
            path,
            fit: fit,
            placeholderBuilder: (_) => placeholder,
            errorBuilder: (_, _, _) => onError,
          ),
        );
      }
      return SizedBox.expand(
        child: Image.asset(path, fit: fit, errorBuilder: (_, _, _) => onError),
      );
    }

    if (url.split('?').first.toLowerCase().endsWith('.svg')) {
      return SizedBox.expand(
        child: SvgPicture.network(
          url,
          fit: fit,
          placeholderBuilder: (_) => placeholder,
          errorBuilder: (_, _, _) => onError,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      placeholder: (_, _) => placeholder,
      errorWidget: (_, _, _) => onError,
    );
  }
}
