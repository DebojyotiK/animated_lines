class LineStyle {
  final double? radius;
  final bool isClockwise;
  final bool isCurved;

  LineStyle.curved({
    this.radius,
    this.isClockwise = true,
  }) : isCurved = true;

  LineStyle.straight()
      : isCurved = false,
        isClockwise = false,
        this.radius = null;
}
