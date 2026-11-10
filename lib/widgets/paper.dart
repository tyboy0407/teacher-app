import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/motion.dart';
import '../core/theme.dart';

/// 「便利貼拼貼」的材料:紙片卡、紙膠帶、螢光筆標題、貼紙、按壓回饋。
/// 這些只給資源卡片與區塊標題用;其餘畫面維持安靜。

/// 一張貼在板上的紙片:小圓角、硬陰影(2px 偏移不模糊)、微微歪一點、
/// 左上角一截紙膠帶。[tilt] 用資源 id 決定,同一張卡片每次都歪同一邊。
class PaperCard extends StatelessWidget {
  const PaperCard({
    super.key,
    required this.child,
    this.color = AppColors.chalk,
    this.tilt = 0,
    this.tape = AppColors.tapeYellow,
    this.showTape = true,
    this.margin = EdgeInsets.zero,
    this.radius = 8,
  });

  final Widget child;
  final Color color;

  /// 傾斜角度(度),建議 -1 ~ 1
  final double tilt;
  final Color tape;
  final bool showTape;
  final EdgeInsetsGeometry margin;
  final double radius;

  /// 依 id 決定的微小傾斜(-0.8° ~ 0.8°),列表看起來像手貼的,但不會亂
  static double tiltFor(String id) => ((id.hashCode % 5) - 2) * 0.4;

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    Widget card = Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.paperShadow,
            offset: Offset(2, 3),
            blurRadius: 0,
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
    if (showTape) {
      card = Stack(
        clipBehavior: Clip.none,
        children: [
          card,
          Positioned(
            top: -7,
            left: 18,
            child: ExcludeSemantics(child: Tape(color: tape)),
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

/// 一截半透明紙膠帶,邊緣略帶鋸齒感(用兩端的小切角模擬)
class Tape extends StatelessWidget {
  const Tape({super.key, this.color = AppColors.tapeYellow, this.width = 44});

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

/// 區塊標題底下一道歪歪的螢光筆:像老師在講義上畫重點
class HighlightedTitle extends StatelessWidget {
  const HighlightedTitle(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final textStyle = style ?? Theme.of(context).textTheme.titleLarge;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -3,
          right: -6,
          bottom: 1,
          height: 11,
          child: ExcludeSemantics(
            child: Transform.rotate(
              angle: -0.012,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.highlighter,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
        Text(text, style: textStyle),
      ],
    );
  }
}

/// 圓形貼紙:白底、彩色粗邊、一個圖示,貼在封面角落
class StickerIcon extends StatelessWidget {
  const StickerIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
    this.tilt = 8,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double tilt;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: tilt * math.pi / 180,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.chalk,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: size / 14),
          boxShadow: const [
            BoxShadow(
              color: AppColors.paperShadow,
              offset: Offset(1, 2),
              blurRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: size * 0.5, color: color),
      ),
    );
  }
}

/// 按下時微縮 0.97,放開回彈:紙片被手指壓了一下
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
        scale: _pressed && !reduced ? 0.97 : 1,
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        child: widget.child,
      ),
    );
  }
}
