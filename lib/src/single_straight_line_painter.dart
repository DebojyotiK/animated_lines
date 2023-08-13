import 'dart:math';

import 'package:flutter/material.dart';

import 'constants.dart';
import 'geometry_utils.dart';
import 'line_info_wrapper.dart';
import 'single_line_painter.dart';

class SingleStraightLinePainter implements SingleLinePainter {
  final LineInfoWrapper wrapper;
  late double _distanceBetweenPoints, _lineClockwiseAngle, _lineTheta;
  late int _multiplier;

  SingleStraightLinePainter(this.wrapper) {
    _initializeMetrics();
  }

  void _initializeMetrics() {
    _distanceBetweenPoints = (wrapper.source - wrapper.destination).distance;
    double theta = asin((wrapper.destination.dy - wrapper.source.dy).abs() / _distanceBetweenPoints);
    _lineTheta = atan((wrapper.destination.dy - wrapper.source.dy) / (wrapper.destination.dx - wrapper.source.dx));
    _lineClockwiseAngle = GeometryUtils.thetaToClockwiseTheta(wrapper.destination, wrapper.source, theta);
    _multiplier = _getMultiplier(wrapper);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawLineForCurrentSet(canvas, size);
  }

  @override
  Duration animationDuration() {
    int duration = _distanceBetweenPoints * 15000 ~/ 1024;
    return Duration(milliseconds: duration);
  }

  void _drawLineForCurrentSet(
    Canvas canvas,
    Size size,
  ) {

    var intermediateProgressDistance = _distanceBetweenPoints * wrapper.progress;

    canvas.saveLayer(null, Paint());

    //Draw Arrow;
    if (wrapper.showArrow) {
      _drawArrow(wrapper, canvas);
    }

    if (wrapper.strokeStyle.isPlain) {
      //Draw Masked Line
      _drawPlainBackgroundLine(
        wrapper,
        canvas,
        size,
      );
    } else {
      //Draw Masked Line
      _drawDashedBackgroundLine(
        wrapper,
        canvas,
        size,
      );
    }

    _drawProgressLine(
      wrapper,
      canvas,
      size,
      intermediateProgressDistance,
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
    double rotationAngle = _lineClockwiseAngle;
    if(lineInfo.source.dx == lineInfo.destination.dx && lineInfo.destination.dy < lineInfo.source.dy){
      rotationAngle += theta180;
    } else if(lineInfo.source.dy == lineInfo.destination.dy && lineInfo.destination.dx < lineInfo.source.dx){
      rotationAngle += theta180;
    }
    _drawRotatedArrow(
      lineInfo: lineInfo,
      arrowWidth: arrowWidth,
      angle: rotationAngle,
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

  void _drawDashedBackgroundLine(
    LineInfoWrapper lineInfo,
    Canvas canvas,
    Size size,
  ) {
    bool drawLine = true;
    double currentDistance = 0;
    Offset lastOffset = lineInfo.source;
    Paint dashPaint = Paint();
    dashPaint.strokeWidth = lineInfo.strokeWidth;
    dashPaint.color = lineInfo.backgroundLineColor;
    dashPaint.style = PaintingStyle.stroke;

    Paint gapPaint = Paint();
    gapPaint.color = Colors.transparent;
    gapPaint.style = PaintingStyle.stroke;

    var totalLineDistance = _distanceBetweenPoints - _arrowWidth(lineInfo);
    while (currentDistance < totalLineDistance) {
      double stepDistance = (drawLine ? lineInfo.strokeStyle.dashLength : lineInfo.strokeStyle.gapLength);
      if ((currentDistance + stepDistance) > totalLineDistance) {
        stepDistance = totalLineDistance - currentDistance;
      }
      Paint resolvedPaint = drawLine ? dashPaint : gapPaint;
      currentDistance += stepDistance;
      double nextX = lineInfo.source.dx + currentDistance * _multiplier * cos(_lineTheta);
      double nextY = lineInfo.source.dy + currentDistance * _multiplier * sin(_lineTheta);
      Offset newOffset = Offset(nextX, nextY);
      canvas.drawLine(lastOffset, newOffset, resolvedPaint);
      lastOffset = newOffset;
      drawLine = !drawLine;
    }
  }

  void _drawPlainBackgroundLine(
    LineInfoWrapper lineInfo,
    Canvas canvas,
    Size size,
  ) {
    Offset lastOffset = lineInfo.source;
    Paint dashPaint = Paint();
    dashPaint.strokeWidth = lineInfo.strokeWidth;
    dashPaint.color = lineInfo.backgroundLineColor;
    dashPaint.style = PaintingStyle.stroke;
    var totalLineDistance = _distanceBetweenPoints - _arrowWidth(lineInfo);
    double nextX = lineInfo.source.dx + totalLineDistance * _multiplier * cos(_lineTheta);
    double nextY = lineInfo.source.dy + totalLineDistance * _multiplier * sin(_lineTheta);
    Offset newOffset = Offset(nextX, nextY);
    canvas.drawLine(lastOffset, newOffset, dashPaint);
  }

  int _getMultiplier(LineInfoWrapper lineInfo) {
    int multiplier = 1;
    if (lineInfo.destination.dx < lineInfo.source.dx) {
      multiplier = -1;
    }
    return multiplier;
  }

  void _drawProgressLine(
    LineInfoWrapper lineInfo,
    Canvas canvas,
    Size size,
    double intermediateProgressDistance,
  ) {
    Paint dashPaint = Paint();
    dashPaint.strokeWidth = _arrowWidth(lineInfo) / arrowAspectRatio;
    dashPaint.color = lineInfo.progressLineColor;
    dashPaint.style = PaintingStyle.stroke;
    dashPaint.blendMode = BlendMode.srcIn;
    double nextX = lineInfo.source.dx + intermediateProgressDistance * _multiplier * cos(_lineTheta);
    double nextY = lineInfo.source.dy + intermediateProgressDistance * _multiplier * sin(_lineTheta);
    Offset newOffset = Offset(nextX, nextY);
    canvas.drawLine(lineInfo.source, newOffset, dashPaint);
  }

  double _arrowWidth(LineInfoWrapper lineInfo) => lineInfo.strokeWidth * 3;
}
