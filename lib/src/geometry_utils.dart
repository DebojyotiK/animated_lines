import 'dart:math';
import 'dart:ui';

final double theta90 = _radians(90);
final double theta180 = _radians(180);
final double theta270 = _radians(270);
final double theta360 = _radians(360);

double _radians(double degrees) {
  return pi * degrees / 180;
}

abstract class GeometryUtils {
  static double getThetaBetweenTwoPointsOnCircle(
    double distanceBetweenPoints,
    double radius,
  ) {
    double theta = acos(1 - pow(distanceBetweenPoints, 2) / (2 * pow(radius, 2)));
    return theta;
  }

  static Offset getCenter(
    Offset sourcePoint,
    Offset destinationPoint,
    double radius,
    bool isClockwise,
  ) {
    late Offset centerPoint;
    if (sourcePoint == destinationPoint) return destinationPoint;
    if ((sourcePoint-destinationPoint).dx.abs() < 0.000005) {
      return _getCenterForSameX(
        sourcePoint,
        destinationPoint,
        radius,
        isClockwise,
      );
    }
    else if ((sourcePoint-destinationPoint).dy.abs() < 0.000005) {
      return _getCenterForSameY(
        sourcePoint,
        destinationPoint,
        radius,
        isClockwise,
      );
    }
    List<Offset> offsets = _getPossibleCentersForPointsOnCircle(
      sourcePoint,
      destinationPoint,
      radius,
    );
    if (destinationPoint.dy > sourcePoint.dy) {
      if (!isClockwise) {
        //Choose the right point
        centerPoint = offsets.last;
      } else {
        centerPoint = offsets.first;
      }
    } else {
      if (isClockwise) {
        //Choose the right point
        centerPoint = offsets.last;
      } else {
        centerPoint = offsets.first;
      }
    }
    return centerPoint;
  }

  static Offset _getCenterForSameX(
    Offset sourcePoint,
    Offset destinationPoint,
    double radius,
    bool isClockwise,
  ) {
    double distanceBetweenTwoPoints = (sourcePoint - destinationPoint).distance;
    double base = sqrt((pow(radius, 2) - pow(distanceBetweenTwoPoints / 2, 2)));
    double y = (destinationPoint.dy - sourcePoint.dy) / 2.0 + sourcePoint.dy;
    if (destinationPoint.dy > sourcePoint.dy) {
      if (!isClockwise) {
        //Choose the right point
        return Offset(sourcePoint.dx + base, y);
      } else {
        return Offset(sourcePoint.dx - base, y);
      }
    } else {
      if (isClockwise) {
        //Choose the right point
        return Offset(sourcePoint.dx + base, y);
      } else {
        return Offset(sourcePoint.dx - base, y);
      }
    }
  }

  static Offset _getCenterForSameY(
    Offset sourcePoint,
    Offset destinationPoint,
    double radius,
    bool isClockwise,
  ) {
    double distanceBetweenTwoPoints = (sourcePoint - destinationPoint).distance;
    double base = sqrt((pow(radius, 2) - pow(distanceBetweenTwoPoints / 2, 2)));
    double x = (destinationPoint.dx - sourcePoint.dx) / 2.0 + sourcePoint.dx;
    if (destinationPoint.dx > sourcePoint.dx) {
      if (!isClockwise) {
        //Choose the top point
        return Offset(x, sourcePoint.dy - base);
      } else {
        return Offset(x, sourcePoint.dy + base);
      }
    } else {
      if (isClockwise) {
        //Choose the top point
        return Offset(x, sourcePoint.dy - base);
      } else {
        return Offset(x, sourcePoint.dy + base);
      }
    }
  }

  static List<Offset> _getPossibleCentersForPointsOnCircle(
    Offset point1,
    Offset point2,
    double radius,
  ) {
    double a = point1.dx;
    double b = point1.dy;
    double c = point2.dx;
    double d = point2.dy;
    double k = (d - b);
    double l = (pow(a, 2) + pow(b, 2) - (pow(c, 2) + pow(d, 2))).toDouble();
    double m = 2 * (a - c);
    double r = (pow(m, 2) + 4 * pow(k, 2)).toDouble();
    double s = 2 * (2 * k * l - 2 * m * k * c - d * pow(m, 2)).toDouble();
    double t = pow(m, 2) * (pow(c, 2) + pow(d, 2) - pow(radius, 2)) + pow(l, 2) - 2 * c * m * l;
    double y1 = (-s + sqrt((pow(s, 2)) - 4 * r * t)) / (2 * r);
    double y2 = (-s - sqrt((pow(s, 2)) - 4 * r * t)) / (2 * r);
    getX(double y) {
      return (2 * y * k + pow(a, 2) + pow(b, 2) - (pow(c, 2) + pow(d, 2))) / (m);
    }

    double x1 = getX(y1);
    double x2 = getX(y2);
    var offsets = [
      Offset(x1, y1),
      Offset(x2, y2),
    ];
    if(x1 < x2){
      return offsets;
    }
    else{
      return offsets.reversed.toList();
    }
  }

  static double getResolvedRadius(
    Offset point1,
    Offset point2,
    double radius,
  ) {
    if ((point1 - point2).distance > 2 * radius) {
      radius = ((point1 - point2).distance / 2).ceilToDouble();
    }
    return radius;
  }

  static double getThetaForPointOnCircumference(
    Offset point,
    Offset center,
    double radius,
  ) {
    var theta = asin((point.dy - center.dy).abs() / radius);
    theta = thetaToClockwiseTheta(point, center, theta);
    return theta;
  }

  static double thetaToClockwiseTheta(
    Offset point,
    Offset center,
    double theta,
  ) {
    if (point.dx > center.dx && point.dy < center.dy) {
      theta = theta360 - 1 * theta;
    } else if (point.dx > center.dx && point.dy > center.dy) {
      theta = theta;
    } else if (point.dx < center.dx && point.dy > center.dy) {
      theta = theta180 - theta;
    } else if (point.dx < center.dx && point.dy < center.dy) {
      theta = theta180 + theta;
    }
    return theta;
  }
}
