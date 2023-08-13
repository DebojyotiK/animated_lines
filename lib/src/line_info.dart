import 'package:flutter/material.dart';

import 'line_info_wrapper.dart';
import 'line_style.dart';
import 'stroke_style.dart';

final Map<LineInfo, LineInfoWrapper> rel = <LineInfo, LineInfoWrapper>{};

class LineInfo {
  final Offset source;
  final Offset destination;
  final Color backgroundLineColor;
  final Color progressLineColor;
  final int animationCount;
  final LineStyle lineStyle;
  final StrokeStyle strokeStyle;
  final double strokeWidth;
  final bool showArrow;
  final double progress;
  VoidCallback? onAnimationComplete;

  LineInfo({
    required this.source,
    required this.destination,
    required this.lineStyle,
    required this.strokeStyle,
    this.progressLineColor = Colors.green,
    this.backgroundLineColor = Colors.black,
    this.animationCount = -1,
    this.strokeWidth = 4.0,
    this.showArrow = true,
    this.progress = 0,
    this.onAnimationComplete,
  });

  LineInfoWrapper? getWrapper() {
    return rel[this];
  }

  void createWrapper(
    AnimationController controller,
    double defaultRadius,
  ) {
    LineInfoWrapper wrapper = LineInfoWrapper(
      source: source,
      destination: destination,
      strokeWidth: strokeWidth,
      progressLineColor: progressLineColor,
      backgroundLineColor: backgroundLineColor,
      animationCount: animationCount,
      animationController: controller,
      progress: progress,
      showArrow: showArrow,
      lineStyle: lineStyle,
      strokeStyle: strokeStyle,
      defaultRadius: defaultRadius,
    );
    rel[this] = wrapper;
  }

  void animate() {
    LineInfoWrapper? wrapper = rel[this];
    wrapper?.animate(onComplete: onAnimationComplete);
  }

  void stopAnimation() {
    LineInfoWrapper? wrapper = rel[this];
    wrapper?.stopAnimation();
  }
}
