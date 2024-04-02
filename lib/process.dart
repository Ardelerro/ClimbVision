import 'dart:math';

import 'package:processing/command.dart';
import 'package:processing/output_utils.dart';
import 'package:processing/utils/hold.dart';
import 'package:processing/utils/person.dart';

/// A class responsible for processing commands related to person's position and holds.
class Process {
  Command prevCommand = Command.waiting;

  /// A singleton instance of OutputUtils to handle text-to-speech functionality.
  final OutputUtils _outputUtils = OutputUtils();
  static const double distanceScaleFactor = 100.0;

  static const String helpOutput = "ClimbVision will tell you the distance and direction of holds based on your position. TO get started, click the start climb button, and say next to get the next set of holds. You can also say 'repeat' to repeat the last command, 'help' to get help, or 'stop' to stop the current command.";

  /// Constructs a new [Process] instance.
  Process();

  /// Speaks the provided [text] using text-to-speech (TTS).
  ///
  /// The [text] parameter specifies the text to be spoken.
  Future<void> speak(String text) async {
    print("abcjdkbcskjdbcjwbhdchjbjk");
    await _outputUtils.speak(text);
  }

  /// Determine distance and direction from the person's position to holds.
  ///
  /// This method calculates the distance and clock direction from the [person]'s center to each of the
  /// [holds] based on the provided parameters. If the distance to a hold is within the given threshold
  /// and the hold's color matches the provided color, it speaks the command asynchronously.
  Future<void> commandFromDistanceAndColor(Person person, List<Hold> holds,
      double distanceThreshold, String color) async {
    prevCommand = Command.getDistance;
    Point<double>? center = person.calculateCenter();

    if (center == null) {
      print("Person's center cannot be calculated.");
      return;
    }
    print(holds);

    int count = 1;
    String output = ""; // Collecting output to speak coherently
    for (Hold hold in holds) {
      double distance = calculateDistance(center, hold.location);
      int clockDirection = _calculateClockDirection(center, hold.location);
      if (distance <= distanceThreshold && hold.color == color) {
        output +=
            "Hold $count: $clockDirection o'clock at around $distance meters. ... ";
      }
      count++;
    }
    if (output.isNotEmpty) {
      await speak(output); // Speak all commands together
    } else {
      await speak("No holds found within the given threshold.");
    }
    print(output);
  }

  Future<void> help() async {
    await speak(helpOutput);
    await Future.delayed(const Duration(seconds: 5));
  }

  /// Repeats the previous command or displays help if needed.
  ///
  /// The [person], [holds], [distanceThreshold], and [color] parameters are optional and used
  /// when repeating the 'getDistance' command.
  Future<void> repeat(
      [Person? person,
      List<Hold>? holds,
      double? distanceThreshold,
      String? color]) async {
    print(prevCommand);
    switch (prevCommand) {
      case Command.repeat:
        await help();
        break;

      case Command.help:
        await help();
        break;

      case Command.getDistance:
        if (person != null &&
            holds != null &&
            distanceThreshold != null &&
            color != null) {
          await commandFromDistanceAndColor(
              person, holds, distanceThreshold, color);
        }
        break;
      default:
    }
  }

  /// Setter for the previous command.
  set command(Command command) => prevCommand = command;

  /// Calculates the distance between two points.
  static double calculateDistance(Point<double> from, Point<double> to) {
    return ((sqrt(pow(to.x - from.x, 2) + pow(to.y - from.y, 2)) /
                distanceScaleFactor)
            .floorToDouble() /
        10);
  }

  /// Calculates the clock direction from one point to another.
  int _calculateClockDirection(Point<double> from, Point<double> to) {
    double dx = to.x - from.x;
    double dy = to.y - from.y;

    double angle = atan2(dy, dx);
    if (angle < 0) {
      angle += 2 * pi;
    }

    double hourAngle = (angle * 6 / pi + 3) % 12;
    int clockDirection = (hourAngle + 1).toInt();
    return clockDirection;
  }

  Future<void> stop() async {
    await _outputUtils.stop();
  }
}
