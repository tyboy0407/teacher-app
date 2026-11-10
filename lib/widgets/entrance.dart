import 'package:flutter/material.dart';

import '../core/motion.dart';

/// 列表第一次出現時,前幾張卡片依序淡入、上移 12px(每張間隔 40ms)。
/// 這是「定向」用的動態:告訴老師內容剛到;不是裝飾,所以只在
/// [EntranceWindow] 開著的那一小段時間內播,之後捲回來不再播。
///
/// 延遲用動畫曲線的 [Interval] 實作、不用 Timer:畫格推進就會完成,
/// 測試的 pumpAndSettle 才等得到。
class StaggeredEntrance extends StatefulWidget {
  const StaggeredEntrance({
    super.key,
    required this.index,
    required this.child,
    this.enabled = true,
    this.maxAnimated = 6,
  });

  final int index;
  final Widget child;
  final bool enabled;

  /// 只有前幾張需要進場;後面的使用者還沒看到
  final int maxAnimated;

  static const stagger = Duration(milliseconds: 40);
  static const offset = 12.0;

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final bool _animates =
      widget.enabled && widget.index < widget.maxAnimated;
  AnimationController? _controller;
  Animation<double>? _curve;
  bool _reduced = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    if (!_animates) return;
    final delay = StaggeredEntrance.stagger * widget.index;
    final total = AppMotion.slow + delay;
    _controller = AnimationController(vsync: this, duration: total);
    _curve = CurvedAnimation(
      parent: _controller!,
      curve: Interval(
        delay.inMilliseconds / total.inMilliseconds,
        1,
        curve: AppMotion.enter,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started || !_animates) return;
    _started = true;
    _reduced = AppMotion.reduced(context);
    if (_reduced) {
      _controller!.value = 1;
    } else {
      _controller!.forward();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_animates || _reduced) return widget.child;
    return AnimatedBuilder(
      animation: _curve!,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _curve!.value,
        child: Transform.translate(
          offset: Offset(0, StaggeredEntrance.offset * (1 - _curve!.value)),
          child: child,
        ),
      ),
    );
  }
}

/// 進場動畫的「時間窗」:掛上後只開 [window] 這麼久,之後建構的卡片
/// (例如捲下去再捲回來)不再播進場。用動畫控制器計時,不用 Timer。
class EntranceWindow extends StatefulWidget {
  const EntranceWindow({
    super.key,
    required this.builder,
    this.window = const Duration(milliseconds: 800),
  });

  final Widget Function(BuildContext context, bool enabled) builder;
  final Duration window;

  @override
  State<EntranceWindow> createState() => _EntranceWindowState();
}

class _EntranceWindowState extends State<EntranceWindow>
    with SingleTickerProviderStateMixin {
  // 不用 late final 延遲建立:減少動態效果時建構階段用不到它,
  // 會拖到 dispose 才建立而出錯
  late final AnimationController _clock;
  bool _reduced = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(vsync: this, duration: widget.window)
      ..addStatusListener(_onStatus);
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _reduced = AppMotion.reduced(context);
    if (!_reduced) _clock.forward();
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, !_reduced && !_clock.isCompleted);
}

/// 內容換掉時交叉淡入(篩選切換、骨架 → 內容),不是整塊閃一下。
class CrossfadeSwitcher extends StatelessWidget {
  const CrossfadeSwitcher({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.reduced(context) ? Duration.zero : AppMotion.fast,
      switchInCurve: AppMotion.enter,
      switchOutCurve: AppMotion.exit,
      // 兩邊都要撐滿(ListView 需要有邊界的高度),不用預設的置中堆疊
      layoutBuilder: (current, previous) =>
          Stack(fit: StackFit.expand, children: [...previous, ?current]),
      child: child,
    );
  }
}
