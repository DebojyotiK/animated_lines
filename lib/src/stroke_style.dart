class StrokeStyle {
  final double dashLength;
  final double gapLength;
  final bool isPlain;

  StrokeStyle.plain()
      : dashLength = 0,
        gapLength = 0,
        isPlain = true;

  StrokeStyle.dashed({
    this.dashLength = 5,
    this.gapLength = 5,
  }) : isPlain = false;

  @override
  bool operator ==(Object other) {
    return other is StrokeStyle &&
        other.runtimeType == runtimeType &&
        other.isPlain == isPlain &&
        other.dashLength == dashLength &&
        other.gapLength == gapLength;
  }

  @override
  int get hashCode => super.hashCode;
}
