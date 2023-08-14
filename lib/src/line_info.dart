import 'package:flutter/material.dart';

import 'constants.dart';
import 'line_info_wrapper.dart';
import 'line_style.dart';
import 'stroke_style.dart';


class LineInfo {

  Offset get source => _source;
  Offset _source;

  Offset get destination => _destination;
  Offset _destination;

  Color get backgroundLineColor => _backgroundLineColor;
  Color _backgroundLineColor;

  Color get progressLineColor => _progressLineColor;
  Color _progressLineColor;

  int get animationCount => _animationCount;
  int _animationCount;

  LineStyle get lineStyle => _lineStyle;
  LineStyle _lineStyle;

  StrokeStyle get strokeStyle => _strokeStyle;
  StrokeStyle _strokeStyle;

  double get strokeWidth => _strokeWidth;
  double _strokeWidth;
  
  double _initialProgressInAnimatorRange;
  double get progress => _getNormalizedProgress();

  bool get showArrow => _showArrow;
  bool _showArrow;

  VoidCallback? onAnimationComplete;
  LineInfoWrapper? _wrapper;

  bool _needRebuild = false;
  bool get needRebuild => _needRebuild;

  LineInfo({
    required Offset source,
    required Offset destination,
    required LineStyle lineStyle,
    required StrokeStyle strokeStyle,
    Color progressLineColor = Colors.green,
    Color backgroundLineColor = Colors.black,
    int animationCount = -1,
    double strokeWidth = 4.0,
    bool showArrow = true,
    double progress = 0,
    this.onAnimationComplete,
  })  : _source = source,
        _destination = destination,
        _lineStyle = lineStyle,
        _strokeStyle = strokeStyle,
        _progressLineColor = progressLineColor,
        _backgroundLineColor = backgroundLineColor,
        _animationCount = animationCount,
        _strokeWidth = strokeWidth,
        _showArrow = showArrow,
        _initialProgressInAnimatorRange = _getProgressInAnimatorRange(progress);

  void update({
    Offset? source,
    Offset? destination,
    LineStyle? lineStyle,
    StrokeStyle? strokeStyle,
    Color? progressLineColor,
    Color? backgroundLineColor,
    int? animationCount,
    double? strokeWidth,
    bool? showArrow,
    double? progress,
  }) {
    var oldSource = _source;
    _source = source ?? _source;
    var oldDestination = _destination;
    _destination = destination ?? _destination;
    var oldLineStyle = _lineStyle;
    _lineStyle = lineStyle ?? _lineStyle;
    var oldStrokeStyle = _strokeStyle;
    _strokeStyle = strokeStyle ?? _strokeStyle;
    var oldProgressLineColor = _progressLineColor;
    _progressLineColor = progressLineColor ?? _progressLineColor;
    var oldBackgroundLineColor = _backgroundLineColor;
    _backgroundLineColor = backgroundLineColor ?? _backgroundLineColor;
    var oldAnimationCount = _animationCount;
    _animationCount = animationCount ?? _animationCount;
    var oldStrokeWidth = _strokeWidth;
    _strokeWidth = strokeWidth ?? _strokeWidth;
    var oldShowArrow = _showArrow;
    _showArrow = showArrow ?? _showArrow;
    //Stop Animation so that animation doesnot update progress values.But Capture the state
    bool wasAnimating = _wrapper?.isAnimating ?? false;
    _wrapper?.stopAnimation();
    var currentProgressValue = _wrapper?.progress ?? MIN_VALUE;
    _initialProgressInAnimatorRange = (progress != null ? _getProgressInAnimatorRange(progress) : null) ?? currentProgressValue;
    _wrapper?.setProgress(_initialProgressInAnimatorRange);
    _needRebuild = !(oldSource == _source &&
        oldDestination == _destination &&
        oldLineStyle == _lineStyle &&
        oldStrokeStyle == _strokeStyle &&
        oldProgressLineColor == _progressLineColor &&
        oldBackgroundLineColor == _backgroundLineColor &&
        oldAnimationCount == _animationCount &&
        oldStrokeWidth == _strokeWidth &&
        oldShowArrow == _showArrow &&
        currentProgressValue == _initialProgressInAnimatorRange);
    //Restore the state
    if (wasAnimating) {
      _wrapper?.animate(onComplete: onAnimationComplete);
    }
  }

  LineInfoWrapper? getWrapper() {
    return _wrapper;
  }

  LineInfoWrapper createWrapper(
    AnimationController controller,
    double defaultRadius,
    bool isAnimating,
    double lastProgress,
  ) {
    _wrapper = LineInfoWrapper(
      source: source,
      destination: destination,
      strokeWidth: strokeWidth,
      progressLineColor: progressLineColor,
      backgroundLineColor: backgroundLineColor,
      animationCount: animationCount,
      showArrow: showArrow,
      lineStyle: lineStyle,
      strokeStyle: strokeStyle,
      progress: lastProgress,
      defaultRadius: defaultRadius,
      isAnimating: isAnimating,
      animationController: controller,
    );
    _needRebuild = false;
    return _wrapper!;
  }

  void animate() {
    _wrapper?.animate(onComplete: onAnimationComplete);
  }

  void stopAnimation() {
    _wrapper?.stopAnimation();
  }

  void resetAnimation(){
    _wrapper?.resetAnimation();
  }

  @override
  bool operator ==(Object other) {
    bool isEquals = other is LineInfo &&
        other.runtimeType == runtimeType &&
        other.source == source &&
        other.destination == destination &&
        other.lineStyle == lineStyle &&
        other.strokeStyle == strokeStyle &&
        other.progressLineColor == progressLineColor &&
        other.backgroundLineColor == backgroundLineColor &&
        other.animationCount == animationCount &&
        other.strokeWidth == strokeWidth &&
        other.showArrow == showArrow &&
        other._initialProgressInAnimatorRange == _initialProgressInAnimatorRange;
    return isEquals;
  }

  @override
  int get hashCode => super.hashCode;

  static double _getProgressInAnimatorRange(double progress){
    return (MAX_VALUE - MIN_VALUE) * progress + MIN_VALUE;
  }

  double _getNormalizedProgress(){
    return (_wrapper?.progress ?? MIN_VALUE - MIN_VALUE)/(MAX_VALUE - MIN_VALUE);
  }
}
