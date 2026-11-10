import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/motion.dart';
import '../core/theme.dart';

/// 簡約時尚版的材料:乾淨的紙片卡、標題短線、貼紙、按壓回饋。
/// 只給資源卡片與區塊標題用;其餘畫面維持安靜。

/// 一張乾淨的紙片:圓角 10、一條細線、幾乎看不見的影子。
/// [tilt] 與 [showTape] 保留給未來想加手作感時用,預設全關。
class PaperCard extends StatelessWidget {
  const PaperCard({
    super.key,
    required this.child,
    this.color = AppColors.chalk,
    this.tilt = 0,
    this.tape,
    this.showTape = false,
    this.margin = EdgeInsets.zero,
    this.radius = 10,
    this.border = true,
  });

  final Widget child;
  final Color color;

  /// 傾斜角度(度);簡約版不用,保留介面
  final double tilt;
  final Color? tape;
  final bool showTape;
  final EdgeInsetsGeometry margin;
  final double radius;

  /// 白底卡片畫細線;有色卡片(便利貼)不畫
  final bool border;

  /// 依 id 決定的微小傾斜;簡約版一律回 0
  static double tiltFor(String id) => 0;

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    Widget card = Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: border ? Border.all(color: AppColors.line) : null,
        boxShadow: const [
          BoxShadow(
            color: AppColors.paperShadow,
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        child: child,
      ),
    );
    if (showTape && tape != null) {
      card = Stack(
        clipBehavior: Clip.none,
        children: [
          card,
          Positioned(
            top: -7,
            left: 18,
            child: ExcludeSemantics(child: Tape(color: tape!)),
          ),
        ],
      );
    }
    if (tilt != 0 && !reduced) {
      card = Transform.rotate(angle: tilt * math.pi / 180, child: card);
    }
    return Padding(padding: margin, child: card);
  }
}

/// 一截半透明紙膠帶(簡約版未使用,保留)
class Tape extends StatelessWidget {
  const Tape({super.key, required this.color, this.width = 44});

  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.07,
      child: Container(
        width: width,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// 區塊標題:文字底下一道短短的杏色線,像書籤的位置記號
class HighlightedTitle extends StatelessWidget {
  const HighlightedTitle(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final textStyle = style ?? Theme.of(context).textTheme.titleLarge;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, style: textStyle),
        const SizedBox(height: 4),
        ExcludeSemantics(
          child: Container(
            width: 28,
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.apricot,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }
}

/// 圓形貼紙:白底、彩色細邊、一個圖示;只貼在詳情頁的封面上
class StickerIcon extends StatelessWidget {
  const StickerIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
    this.tilt = 0,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double tilt;

  @override
  Widget build(BuildContext context) {
    final sticker = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.chalk,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: size / 18),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.5, color: color),
    );
    if (tilt == 0) return sticker;
    return Transform.rotate(angle: tilt * math.pi / 180, child: sticker);
  }
}

/// 按下時微縮 0.985,放開回彈:紙片被手指壓了一下(很輕)
class PressScale extends StatefulWidget {
  const PressScale({super.key, required this.child});

  final Widget child;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed && !reduced ? 0.985 : 1,
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        child: widget.child,
      ),
    );
  }
}
