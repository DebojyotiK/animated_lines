import 'dart:math';

import 'package:flutter/material.dart';

import 'constants.dart';
import 'geometry_utils.dart';
import 'line_info_wrapper.dart';
import 'single_line_painter.dart';

class SingleArchedLinePainter implements SingleLinePainter {
  final LineInfoWrapper wrapper;
  late double _v1Angle, _thetaBetweenV1V2, _distanceBetweenPoints, _v2AcuteAngle;
  late Offset _center;
  late double _resolvedRadius;

  SingleArchedLinePainter(
    this.wrapper,
    double defaultRadius,
  ) {
    _initializeMetrics(defaultRadius);
  }

  void _initializeMetrics(double defaultRadius) {
    _resolvedRadius = GeometryUtils.getResolvedRadius(
      wrapper.source,
      wrapper.destination,
      wrapper.lineStyle.radius ?? defaultRadius,
    );
    _center = GeometryUtils.getCenter(
      wrapper.source,
      wrapper.destination,
      _resolvedRadius,
      wrapper.lineStyle.isClockwise,
    );

    _v1Angle = GeometryUtils.getThetaForPointOnCircumference(
      wrapper.source,
      _center,
      _resolvedRadius,
    );
    _v2AcuteAngle = asin((wrapper.destination.dy - _center.dy).abs() / _resolvedRadius);
    _thetaBetweenV1V2 = GeometryUtils.getThetaBetweenTwoPointsOnCircle(
      (wrapper.source - wrapper.destination).distance,
      _resolvedRadius,
    );
    _distanceBetweenPoints = _resolvedRadius * _thetaBetweenV1V2;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawArcForCurrentSet(canvas, size);
  }

  @override
  Duration animationDuration() {
    int duration = _distanceBetweenPoints * 15000 ~/ 1024;
    return Duration(milliseconds: duration);
  }

  void _drawArcForCurrentSet(
    Canvas canvas,
    Size size,
  ) {
    var startAngle = _v1Angle;
    var endSweepAngle = _thetaBetweenV1V2 * (wrapper.lineStyle.isClockwise ? 1 : -1);
    var sweepProgressAngle = endSweepAngle * wrapper.progress;

    canvas.saveLayer(null, Paint());

    //Draw Arrow;
    if (wrapper.showArrow) {
      _drawArrow(wrapper, canvas);
      double arrowWidth = _arrowWidth(wrapper);
      double arrowTheta = theta360 * arrowWidth / (2 * pi * _resolvedRadius);
      endSweepAngle -= 0.5 * arrowTheta * (endSweepAngle / endSweepAngle.abs());
    }

    if(wrapper.strokeStyle.isPlain){
      //Draw plain arc
      _drawPlainBackgroundArc(
        wrapper,
        _center,
        startAngle,
        endSweepAngle,
        canvas,
        size,
      );
    }
    else{
      //Draw dashed arc
      _drawDashedBackgroundArc(
        wrapper,
        _center,
        startAngle,
        endSweepAngle,
        canvas,
        size,
      );
    }

    _drawProgressArc(
      wrapper,
      _center,
      startAngle,
      sweepProgressAngle,
      canvas,
      size,
    );

    canvas.restore();
  }

  void _drawArrow(
    LineInfoWrapper lineInfo,
    Canvas canvas,
  ) {
    canvas.save();
    Offset point = lineInfo.destination;
    double arrowWidth = _arrowWidth(lineInfo);
    double arrowCanvasWidth = 2.0 * arrowWidth;
    double arrowHeight = arrowWidth / arrowAspectRatio;
    double dx = point.dx - arrowCanvasWidth / 2;
    double dy = point.dy - arrowHeight / 2;
    canvas.translate(dx, dy);
    double rotationTheta = 0;
    double acuteTheta = _v2AcuteAngle;
    if (point.dx > _center.dx) {
      if (point.dy < _center.dy) {
        rotationTheta = theta90 + acuteTheta;
      } else {
        rotationTheta = theta90 - acuteTheta;
      }
    } else {
      if (point.dy < _center.dy) {
        rotationTheta = theta270 - acuteTheta;
      } else {
        rotationTheta = theta270 + acuteTheta;
      }
    }
    rotationTheta = -1 * rotationTheta;
    if (lineInfo.lineStyle.isClockwise) {
      rotationTheta = theta180 + rotationTheta;
    }
    _drawRotatedArrow(
      lineInfo: lineInfo,
      arrowWidth: arrowWidth,
      angle: rotationTheta,
      canvas: canvas,
    );
    canvas.translate(-dx, -dy);
    canvas.restore();
  }

  void _drawRotatedArrow({
    required LineInfoWrapper lineInfo,
    required double arrowWidth,
    required Canvas canvas,
    required double angle,
  }) {
    double arrowCanvasWidth = 2.0 * arrowWidth;
    double arrowHeight = arrowWidth / arrowAspectRatio;
    final double r = sqrt(arrowCanvasWidth * arrowCanvasWidth + arrowHeight * arrowHeight) / 2;
    final alpha = atan(arrowHeight / arrowCanvasWidth);
    final beta = alpha + angle;
    final shiftY = r * sin(beta);
    final shiftX = r * cos(beta);
    final translateX = arrowCanvasWidth / 2 - shiftX;
    final translateY = arrowHeight / 2 - shiftY;
    canvas.translate(translateX, translateY);
    canvas.rotate(angle);
    Path trianglePath = Path();
    trianglePath.moveTo(0, 0);
    trianglePath.lineTo(arrowWidth, arrowHeight / 2);
    trianglePath.lineTo(0, arrowHeight.toDouble());
    trianglePath.close();
    Paint paint = Paint();
    paint.style = PaintingStyle.fill;
    paint.color = lineInfo.backgroundLineColor;
    paint.strokeJoin = StrokeJoin.round;
    canvas.drawPath(trianglePath, paint);
  }

  void _drawDashedBackgroundArc(
    LineInfoWrapper lineInfo,
    Offset center,
    double startAngle,
    double sweepAngle,
    Canvas canvas,
    Size size,
  ) {
    double radius = _resolvedRadius;
    double endAngle = startAngle + sweepAngle;
    bool drawLine = true;
    double dashAngle = asin(lineInfo.strokeStyle.dashLength / radius);
    double gapAngle = asin(lineInfo.strokeStyle.gapLength / radius);
    double incrementalStartAngle = startAngle;
    final arcRect = Rect.fromCenter(
      center: center,
      width: 2 * radius,
      height: 2 * radius,
    );

    Paint dashPaint = _dashPaint(lineInfo);

    Paint gapPaint = _gapPaint();

    int multiplier = 1;
    if (endAngle < startAngle) {
      multiplier = -1;
    }
    while (multiplier * incrementalStartAngle < multiplier * endAngle) {
      double sweepAngle = multiplier * (drawLine ? dashAngle : gapAngle);
      if (multiplier * (incrementalStartAngle + sweepAngle) > multiplier * endAngle) {
        sweepAngle = endAngle - incrementalStartAngle;
      }
      Paint resolvedPaint = drawLine ? dashPaint : gapPaint;
      canvas.drawArc(
        arcRect,
        incrementalStartAngle,
        sweepAngle,
        false,
        resolvedPaint,
      );
      incrementalStartAngle += sweepAngle;
      drawLine = !drawLine;
    }
  }

  void _drawPlainBackgroundArc(
    LineInfoWrapper lineInfo,
    Offset center,
    double startAngle,
    double sweepAngle,
    Canvas canvas,
    Size size,
  ) {
    double radius = _resolvedRadius;
    var arcRect = Rect.fromCenter(
      center: center,
      width: 2 * radius,
      height: 2 * radius,
    );

    Paint dashPaint = _dashPaint(lineInfo);

    canvas.drawArc(
      arcRect,
      startAngle,
      sweepAngle,
      false,
      dashPaint,
    );
  }

  void _drawProgressArc(
    LineInfoWrapper lineInfo,
    Offset center,
    double startAngle,
    double sweepAngle,
    Canvas canvas,
    Size size,
  ) {
    double radius = _resolvedRadius;
    var arcRect = Rect.fromCenter(
      center: center,
      width: 2 * radius,
      height: 2 * radius,
    );

    Paint dashPaint = Paint();
    dashPaint.strokeWidth = _arrowWidth(lineInfo) / arrowAspectRatio;
    dashPaint.color = lineInfo.progressLineColor;
    dashPaint.style = PaintingStyle.stroke;
    dashPaint.blendMode = BlendMode.srcIn;

    canvas.drawArc(
      arcRect,
      startAngle,
      sweepAngle,
      false,
      dashPaint,
    );
  }

  double _arrowWidth(LineInfoWrapper lineInfo) => lineInfo.strokeWidth * 3;

  Paint _gapPaint() {
    Paint gapPaint = Paint();
    gapPaint.color = Colors.transparent;
    gapPaint.style = PaintingStyle.stroke;
    return gapPaint;
  }

  Paint _dashPaint(LineInfoWrapper lineInfo) {
    Paint dashPaint = Paint();
    dashPaint.strokeWidth = lineInfo.strokeWidth;
    dashPaint.color = lineInfo.backgroundLineColor;
    dashPaint.style = PaintingStyle.stroke;
    return dashPaint;
  }

}
