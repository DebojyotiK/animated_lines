import 'package:flutter/material.dart';

import 'constants.dart';
import 'line_style.dart';
import 'single_arched_line_painter.dart';
import 'single_line_painter.dart';
import 'single_straight_line_painter.dart';
import 'stroke_style.dart';

class LineInfoWrapper extends ChangeNotifier {
  final Offset source;
  final Offset destination;
  final Color backgroundLineColor;
  final Color progressLineColor;
  AnimationController? _animationController;
  final int animationCount;
  final LineStyle lineStyle;
  final StrokeStyle strokeStyle;
  final double strokeWidth;
  bool _isAnimating = false;
  bool get isAnimating => _isAnimating;
  VoidCallback? _onComplete;

  late double _progress;

  double get progress => _progress;

  late Animation<double> _progressAnimation;

  Animation<double> get progressAnimation => _progressAnimation;

  int _animationCount = 0;

  final bool showArrow;

  late SingleLinePainter _painter;

  SingleLinePainter get painter => _painter;

  LineInfoWrapper({
    required this.source,
    required this.destination,
    required this.backgroundLineColor,
    required this.progressLineColor,
    required AnimationController animationController,
    required this.animationCount,
    required this.strokeWidth,
    required this.showArrow,
    required this.lineStyle,
    required this.strokeStyle,
    required double defaultRadius,
    double progress = 0,
    bool isAnimating = false,
  })  : _progress = progress,
        _isAnimating = isAnimating,
        _animationController = animationController {
    if (lineStyle.isCurved) {
      _painter = SingleArchedLinePainter(
        this,
        defaultRadius,
      );
    } else {
      _painter = SingleStraightLinePainter(this);
    }
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _progressAnimation = Tween(
      begin: MIN_VALUE,
      end: MAX_VALUE,
    ).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.linear,
      ),
    )
      ..addStatusListener(_statusListener)
      ..addListener(_updateProgressListener);
  }

  void _updateProgressListener() {
    setProgress(_progressAnimation.value);
  }

  void _statusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (animationCount < 0) {
        _configureDurationAndReplay(_painter.animationDuration(), 0);
      } else if (_animationCount < animationCount - 1) {
        _animationCount++;
        _configureDurationAndReplay(_painter.animationDuration(), 0);
      } else {
        _isAnimating = false;
        if (_onComplete != null) {
          _onComplete!();
        }
      }
    }
  }

  void _configureDurationAndReplay(
    Duration duration,
    double minValue,
  ) {
    _animationController?.duration = duration;
    _animationController?.forward(from: minValue);
  }

  void animate({
    VoidCallback? onComplete,
  }) {
    _onComplete = onComplete;
    _isAnimating = true;
    double totalSpan = (MAX_VALUE - MIN_VALUE);
    double fromValue = (_progress - MIN_VALUE) / totalSpan;
    Duration totalDuration = _painter.animationDuration();
    Duration remainingDuration = totalDuration * ((MAX_VALUE - progress) / totalSpan);
    _configureDurationAndReplay(
      remainingDuration,
      fromValue,
    );
  }

  void stopAnimation() {
    _isAnimating = false;
    _animationController?.stop(canceled: false);
  }

  void resetAnimation() {
    stopAnimation();
    _progress = MIN_VALUE;
  }

  void setProgress(double value) {
    bool shouldNotify = _progress != value;
    if (shouldNotify) {
      _progress = value;
      if(hasListeners){
        notifyListeners();
      }
    }
  }

  void dispose(){
    super.dispose();
    bool isAnimating = _isAnimating;
    stopAnimation();
    _isAnimating = isAnimating;
    _animationController?.removeStatusListener(_statusListener);
    _animationController?.removeListener(_updateProgressListener);
    _animationController?.dispose();
    _animationController = null;
  }
}
