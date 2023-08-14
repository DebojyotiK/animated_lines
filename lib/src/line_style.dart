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

  @override
  bool operator ==(Object other) {
    return other is LineStyle &&
        other.runtimeType == runtimeType &&
        other.isCurved == isCurved &&
        other.isClockwise == isClockwise &&
        other.radius == radius;
  }

  @override
  int get hashCode => super.hashCode;
}
