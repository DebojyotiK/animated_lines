import 'package:flutter/material.dart';

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
  final AnimationController animationController;
  final int animationCount;
  final LineStyle lineStyle;
  final StrokeStyle strokeStyle;
  final double strokeWidth;
  bool _isAnimating = false;
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
    required this.animationController,
    required this.animationCount,
    required this.strokeWidth,
    required this.showArrow,
    required this.lineStyle,
    required this.strokeStyle,
    required double progress,
    required double defaultRadius,
  }) : _progress = progress {
    if(lineStyle.isCurved){
      _painter = SingleArchedLinePainter(
        this,
        defaultRadius,
      );
    }
    else{
      _painter = SingleStraightLinePainter(this);
    }
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _progressAnimation = Tween(
      begin: 0.0,
      end: 1.5,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.linear,
      ),
    )
      ..addStatusListener(_statusListener)
      ..addListener(_updateProgressListener);
  }

  void _updateProgressListener() {
    updateProgress(_progressAnimation.value);
  }

  void _statusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (animationCount < 0) {
        animationController.forward(from: 0);
      } else if (_animationCount < animationCount - 1) {
        animationController.forward(from: 0);
        _animationCount++;
      } else {
        _isAnimating = false;
        if (_onComplete != null) {
          _onComplete!();
        }
      }
    } else if (status == AnimationStatus.dismissed) {
      _isAnimating = false;
    }
  }


  void animate({VoidCallback? onComplete}) {
    _onComplete = onComplete;
    _isAnimating = true;
    _animationCount = 0;
    animationController.duration = _painter.animationDuration();
    animationController.forward(from: 0);
  }

  void stopAnimation() {
    animationController.stop(canceled: false);
  }

  void updateProgress(double value) {
    bool shouldNotify = _progress != value;
    if (shouldNotify) {
      _progress = value;
      notifyListeners();
    }
  }

  void dispose(){
    stopAnimation();
    animationController.removeStatusListener(_statusListener);
    animationController.removeListener(_updateProgressListener);
    animationController.dispose();
  }
}
