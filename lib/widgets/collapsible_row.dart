import 'package:flutter/material.dart';

import '../core/motion.dart';

/// 列表項目的收合/展開動畫:移除時 200ms 收起並淡出(不是瞬間消失),
/// 復原時反向展開。系統開啟「減少動態效果」時直接切換。
///
/// 用法:父層維護「正在移除」的 id;項目的 [removing] 變為 true 時開始收合,
/// 收合完成呼叫 [onCollapsed],父層再真正把資料移除。[appearing] 為 true 的
/// 項目第一次建構時從 0 展開(復原時用)。
class CollapsibleRow extends StatefulWidget {
  const CollapsibleRow({
    super.key,
    required this.child,
    this.removing = false,
    this.appearing = false,
    this.onCollapsed,
  });

  final Widget child;
  final bool removing;
  final bool appearing;
  final VoidCallback? onCollapsed;

  @override
  State<CollapsibleRow> createState() => _CollapsibleRowState();
}

class _CollapsibleRowState extends State<CollapsibleRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.normal,
    value: widget.appearing ? 0 : 1,
  );
  late final Animation<double> _size = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.standard,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (widget.appearing) {
      if (AppMotion.reduced(context)) {
        _controller.value = 1;
      } else {
        _controller.forward();
      }
    }
    if (widget.removing) _collapse();
  }

  @override
  void didUpdateWidget(covariant CollapsibleRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.removing && !oldWidget.removing) _collapse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _collapse() {
    if (AppMotion.reduced(context)) {
      _controller.value = 0;
      widget.onCollapsed?.call();
      return;
    }
    _controller.reverse().whenComplete(() {
      if (mounted) widget.onCollapsed?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _size,
      alignment: Alignment.topCenter,
      child: FadeTransition(opacity: _controller, child: widget.child),
    );
  }
}
