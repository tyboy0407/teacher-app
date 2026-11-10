import 'package:flutter/material.dart';

import '../core/motion.dart';

/// 載入中的骨架畫面:形狀和真正的卡片一樣,內容到了版面不會跳。
/// 整組骨架共用一個緩慢的呼吸(1.0 → 0.55 透明度);減少動態效果時靜止。
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.count = 4,
    this.horizontal = false,
    this.shrinkWrap = false,
  });

  final int count;
  final bool horizontal;

  /// 放在不可捲動的 Column 裡時用(例如首頁「最新資源」)
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final children = [
      for (var i = 0; i < count; i++)
        horizontal
            ? const FeaturedCardSkeleton()
            : const ResourceCardSkeleton(),
    ];
    final Widget body;
    if (horizontal) {
      body = ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: children.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, index) => children[index],
      );
    } else if (shrinkWrap) {
      body = Column(children: children);
    } else {
      body = ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 4, bottom: 24),
        children: children,
      );
    }
    return DelayedReveal(
      child: _Pulse(child: ExcludeSemantics(child: body)),
    );
  }
}

/// 列表用橫式卡片的骨架(對應 ResourceCard)
class ResourceCardSkeleton extends StatelessWidget {
  const ResourceCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(width: 88, height: 88, radius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 56, height: 18, radius: 6),
                  SizedBox(height: 10),
                  SkeletonBox(width: double.infinity, height: 16),
                  SizedBox(height: 8),
                  SkeletonBox(width: 160, height: 12),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      SkeletonBox(width: 64, height: 18, radius: 999),
                      SizedBox(width: 6),
                      SkeletonBox(width: 48, height: 18, radius: 999),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 首頁精選直式卡片的骨架(對應 FeaturedResourceCard)
class FeaturedCardSkeleton extends StatelessWidget {
  const FeaturedCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            // 和沒有照片的精選卡片一樣矮
            AspectRatio(aspectRatio: 2.6, child: SkeletonBox(radius: 0)),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 56, height: 18, radius: 6),
                    SizedBox(height: 8),
                    SkeletonBox(width: 180, height: 14),
                    SizedBox(height: 6),
                    SkeletonBox(width: 120, height: 14),
                    SizedBox(height: 8),
                    SkeletonBox(width: 80, height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 骨架的一塊灰色
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, this.height, this.radius = 8});

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// 載入很快(快取命中)時不該閃一下骨架:延遲 100ms 後才顯示。
/// 用動畫控制器計時、不用 Timer,畫格推進就會到期。
class DelayedReveal extends StatefulWidget {
  const DelayedReveal({
    super.key,
    required this.child,
    this.delay = const Duration(milliseconds: 100),
  });

  final Widget child;
  final Duration delay;

  @override
  State<DelayedReveal> createState() => _DelayedRevealState();
}

class _DelayedRevealState extends State<DelayedReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: widget.delay,
  )..addStatusListener(_onStatus);

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _clock.forward();
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _clock.isCompleted,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: widget.child,
    );
  }
}

/// 緩慢呼吸:1.0 → 0.55 透明度來回,一組骨架共用一個控制器
class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});

  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final Animation<double> _opacity = Tween(
    begin: 1.0,
    end: 0.55,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (!AppMotion.reduced(context)) _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}
