import 'dart:math';

class Hold {
  Point<double> location;
  String color;

  Hold(this.location, this.color);

  bool sameColor(String color){
    return this.color == color;
  }
}