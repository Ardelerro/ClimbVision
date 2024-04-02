import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped }

/// A utility class for handling text-to-speech (TTS) functionality using the `flutter_tts` package.
class OutputUtils {

  late FlutterTts _flutterTts;
  
  TtsState? ttsState;

  /// Initializes a new instance of the [OutputUtils] class.
  ///
  /// Initializes the text-to-speech (TTS) engine with default settings.
  OutputUtils() {
    _flutterTts = FlutterTts();

    initTts();
  }

  /// Initializes the text-to-speech (TTS) engine with default settings.
  Future<void> initTts() async {
    _flutterTts = FlutterTts();

    await _flutterTts.setLanguage("en-US");

    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setPitch(0.8);

    _flutterTts.setStartHandler(() {
      ttsState = TtsState.playing;
    });

    _flutterTts.setCompletionHandler(() {
      ttsState = TtsState.stopped;
    });

    _flutterTts.setErrorHandler((msg) {
      ttsState = TtsState.stopped;
    });
  }

  /// Speaks the given text using the initialized text-to-speech (TTS) engine.
  ///
  /// Stops any ongoing speech and then speaks the provided [text].
  ///
  /// The [text] parameter specifies the text to be spoken.
  Future<void> speak(String text) async {
    await _flutterTts.stop();
    
    await _flutterTts.speak(text);
  }

  /// Stops the ongoing speech.
  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
