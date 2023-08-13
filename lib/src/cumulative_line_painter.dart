import 'package:flutter/material.dart';

import 'line_info_wrapper.dart';

class CumulativeLinePainter extends CustomPainter {
  final List<LineInfoWrapper> lineInfos;

  CumulativeLinePainter(this.lineInfos);

  @override
  void paint(Canvas canvas, Size size) {
    for (var e in lineInfos) {
      e.painter.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}
