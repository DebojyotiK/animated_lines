import 'dart:math';

import 'package:animated_lines/animated_lines.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animated Line Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AnimatedLinesExample(title: 'Animated Line Example'),
    );
  }
}

class AnimatedLinesExample extends StatefulWidget {
  final String title;

  const AnimatedLinesExample({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  State<AnimatedLinesExample> createState() => _AnimatedLinesExampleState();
}

class _AnimatedLinesExampleState extends State<AnimatedLinesExample> with TickerProviderStateMixin {
  bool _arePointsInitialized = false;
  final List<LineInfo> _lines = [];
  late double _maxRadius;
  late double _containerWidth;
  late double _containerHeight;
  late Offset _profilePoint;
  late Offset _groceryPoint;
  late Offset _homePoint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  for (var e in _lines) {
                    e.animate();
                  }
                },
                child: const Text("Animate"),
              ),
              TextButton(
                onPressed: () {
                  for (var e in _lines) {
                    e.stopAnimation();
                  }
                },
                child: const Text("Stop Animation"),
              ),
            ],
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (p0, p1) {
                _containerWidth = p1.maxWidth;
                _containerHeight = p1.maxHeight;
                _initializeObjects(_containerWidth, _containerHeight);
                return AnimatedLinesContainer(
                  lines: _lines,
                  child: !_arePointsInitialized
                      ? Container()
                      : Stack(
                          children: [
                            _profileIcon(),
                            _groceryIcon(),
                            _homeIcon(),
                          ],
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileIcon() {
    return Positioned(
      top: _profilePoint.dy,
      left: _profilePoint.dx,
      child: Transform.translate(
        offset: const Offset(-30, -60),
        child: Image.asset(
          "assets/profile.png",
          width: 60,
        ),
      ),
    );
  }

  Widget _groceryIcon() {
    return Positioned(
      top: _groceryPoint.dy,
      left: _groceryPoint.dx,
      child: Transform.translate(
        offset: const Offset(-30, -60),
        child: Image.asset(
          "assets/grocery.png",
          width: 60,
        ),
      ),
    );
  }

  Widget _homeIcon() {
    return Positioned(
      top: _homePoint.dy,
      left: _homePoint.dx,
      child: Transform.translate(
        offset: const Offset(-30, 0),
        child: Image.asset(
          "assets/house.png",
          width: 60,
        ),
      ),
    );
  }

  void _initializeObjects(double width, double height) {
    if (!_arePointsInitialized) {
      Offset center = Offset(width / 2, height / 2);
      _maxRadius = sqrt(pow(MediaQuery.of(context).size.width, 2) + pow(MediaQuery.of(context).size.height, 2)) * 0.2;
      _profilePoint = center + Offset(-width / 4, -height / 8);
      _groceryPoint = center + Offset(width / 4, -height / 8);
      _homePoint = center + Offset(0, height / 8);
      _createLines();
      _arePointsInitialized = true;
    }
  }

  void _createLines() {
    //Create a Dashed Straight line between home and profile
    const straightLineBottomLeftGap = Offset(-10, 0);
    const straightLineTopLeftGap = Offset(-10, 5);
    _lines.add(LineInfo(
      source: _homePoint + straightLineBottomLeftGap,
      destination: _profilePoint + straightLineTopLeftGap,
      progressLineColor: Colors.green,
      lineStyle: LineStyle.straight(),
      strokeStyle: StrokeStyle.dashed(),
      animationCount: 4,
      onAnimationComplete: () {
        debugPrint("Animation Complete for line between Home and Profile");
      },
    ));

    //Create a Curved dashed line between profile and Grocery
    const curvedLineTopLeftGap = Offset(10, -5);
    const curvedLineTopRightGap = Offset(-10, -5);
    _lines.add(LineInfo(
      source: _profilePoint + curvedLineTopLeftGap,
      destination: _groceryPoint + curvedLineTopRightGap,
      progressLineColor: Colors.lightGreen,
      lineStyle: LineStyle.curved(radius: _maxRadius),
      strokeStyle: StrokeStyle.dashed(
        dashLength: 10,
        gapLength: 5,
      ),
    ));

    //Create a Curved plane line between Grocery and Profile
    const curvedLineBottomRightGap = Offset(-10, 5);
    const curvedLineBottomLeftGap = Offset(10, 5);
    _lines.add(LineInfo(
      source: _groceryPoint + curvedLineBottomRightGap,
      destination: _profilePoint + curvedLineBottomLeftGap,
      progressLineColor: Colors.pink,
      lineStyle: LineStyle.curved(radius: _maxRadius),
      strokeStyle: StrokeStyle.plain(),
    ));

    //Create a Plain Straight line between Grocery and home
    const straightLineBottomRightGap = Offset(10, 0);
    const straightLineTopRightGap = Offset(5, 5);
    _lines.add(LineInfo(
      source: _groceryPoint + straightLineTopRightGap,
      destination: _homePoint + straightLineBottomRightGap,
      progressLineColor: Colors.lightBlue,
      lineStyle: LineStyle.straight(),
      strokeStyle: StrokeStyle.plain(),
    ));
  }
}
