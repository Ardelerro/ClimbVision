import 'package:processing/command.dart';
import 'package:processing/process.dart';
import 'package:processing/utils/hold.dart';
import 'package:processing/utils/person.dart';
import 'package:tuple/tuple.dart';

/// A helper class for decoding and processing commands.
class CommandHelper {
  final Process _process;

  /// Constructs a new [CommandHelper] instance.
  ///
  /// The [_process] parameter is required and should not be null.
  CommandHelper(this._process);

  /// Decodes the input command string and returns the command and color.
  ///
  /// This method parses the input string to determine the command and extract
  /// any color parameter associated with it. It returns a tuple containing
  /// the decoded command and the extracted color, if any.
  Tuple2<Command, String?> decodeCommand(String input) {
    if (input.toLowerCase().contains('distance')) {
      List<String> parts = input.toLowerCase().split(' ');
      if (parts.length == 2) {
        String color = parts[1];
        return Tuple2(Command.getDistance, color);
      } else {
        return const Tuple2(Command.getDistance, null);
      }
    } else if (input.toLowerCase().contains('repeat')) {
      return const Tuple2(Command.repeat, null);
    } else if (input.toLowerCase().contains('help')) {
      return const Tuple2(Command.help, null);
    } else if (input.toLowerCase().contains('stop')) {
      return const Tuple2(Command.stop, null);
    } else {
      return const Tuple2(Command.unknown, null);
    }
  }

  /// Processes the input command.
  ///
  /// This method decodes the input command using [decodeCommand], then executes
  /// the corresponding action based on the decoded command. For 'getDistance'
  /// command, it calls [Process.commandFromDistanceAndColor] with the provided
  /// color parameter. For 'repeat' command, it calls [Process.repeat]. For
  /// 'help' command, it calls [Process.help]. For unknown commands, it does
  /// nothing.
  ///
  /// The [input] parameter specifies the command string to _process.
  void processCommand(String input,
      [Person? person,
      List<Hold>? holds,
      double? distanceThreshold,
      String? color]) async {
    final tuple = decodeCommand(input);
    Command command = tuple.item1;
    String inColor = tuple.item2 ?? "";
    print(command);
    switch (command) {
      case Command.stop:
        await _process.stop();
        break;
      case Command.getDistance:
        if (color != null) {
          if (holds == null || person == null || distanceThreshold == null) {
            print("lollll");
            return;
          }
          await _process.commandFromDistanceAndColor(
            person,
            holds,
            distanceThreshold,
            inColor,
          );
          _process.prevCommand = command;
        } else {
          print("Color parameter is missing for getDistance command.");
        }
        break;

      case Command.repeat:
        await _process.repeat(person, holds, distanceThreshold, color);
        break;

      case Command.help:
        await _process.help();
        _process.prevCommand = command;
        break;

      case Command.unknown:
        // Handle unknown command
        break;

      default:
        break;
    }
  }
}
