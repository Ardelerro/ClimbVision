import 'dart:math';

class Person {
  List<Point<double>> limbCoordinates;

  Person(this.limbCoordinates);

  Point<double>? calculateCenter() {
    if (limbCoordinates.isEmpty) {
      return null;
    }

    double totalX = 0.0;
    double totalY = 0.0;

    for (Point<double> point in limbCoordinates) {
      totalX += point.x;
      totalY += point.y;
    }

    double centerX = totalX / limbCoordinates.length;
    double centerY = totalY / limbCoordinates.length;

    return Point(centerX, centerY);
  }
}