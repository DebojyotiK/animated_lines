import 'dart:math';

import 'package:flutter/material.dart';

import 'cumulative_line_painter.dart';
import 'line_info.dart';
import 'line_info_wrapper.dart';

class AnimatedLinesContainer extends StatefulWidget {
  final List<LineInfo> lines;
  final Widget child;

  AnimatedLinesContainer({
    Key? key,
    required List<LineInfo> lines,
    required this.child,
  })  : lines = List.from(lines),
        super(key: key);

  @override
  State<AnimatedLinesContainer> createState() => _AnimatedLinesContainerState();
}

class _AnimatedLinesContainerState extends State<AnimatedLinesContainer> with TickerProviderStateMixin {
  late double _maxRadius;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Size screenSize = MediaQuery.of(context).size;
      _maxRadius = sqrt(pow(screenSize.width, 2) + pow(screenSize.height, 2)) * 0.2;
      for (var e in widget.lines) {
        _initWrapper(e);
      }
      _refreshView();
    });
  }

  void _refreshView() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    List<LineInfoWrapper> wrappers = _getWrappers();
    return ClipRect(
      child: CustomPaint(
        foregroundPainter: CumulativeLinePainter(wrappers),
        child: widget.child,
      ),
    );
  }

  List<LineInfoWrapper> _getWrappers() {
    List<LineInfoWrapper> wrappers = [];
    for (var e in widget.lines) {
      LineInfoWrapper? wrapper = e.getWrapper();
      if (wrapper != null) {
        wrappers.add(wrapper);
      }
    }
    return wrappers;
  }

  @override
  void didUpdateWidget(covariant AnimatedLinesContainer oldWidget) {
    var oldLines = oldWidget.lines;
    var currentLines = widget.lines;
    for (var e in currentLines) {
      if (!oldLines.contains(e)) {
        _initWrapper(e);
      }
    }
    for (var e in oldLines) {
      if (!currentLines.contains(e)) {
        _destroyWrapper(e);
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    for (var e in widget.lines) {
      _destroyWrapper(e);
    }
    super.dispose();
  }

  void _initWrapper(LineInfo e) {
    e.createWrapper(
      AnimationController(vsync: this),
      _maxRadius,
    );
    e.getWrapper()?.addListener(_refreshView);
  }

  void _destroyWrapper(LineInfo e) {
    LineInfoWrapper? wrapper = e.getWrapper();
    wrapper?.removeListener(_refreshView);
    wrapper?.dispose();
  }
}
