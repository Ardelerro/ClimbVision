import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:processing/command_helper.dart';
import 'package:processing/process.dart';
import 'package:processing/utils/hold.dart';
import 'package:processing/utils/person.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:path_provider/path_provider.dart';

import 'package:gallery_saver/gallery_saver.dart';

/// A class responsible for image processing.
class ImageProcessing {
  final CameraController _cameraController;
  late Timer _timeoutTimer;

  // Add a duration for timeout (in seconds)
  final int _timeoutDuration = 2;

  /// Constructs an [ImageProcessing] instance with the provided [cameraController].
  ImageProcessing({required CameraController cameraController})
      : _cameraController = cameraController {
    _initSpeech();
  }

  final CommandHelper _commandHelper = CommandHelper(Process());

  /// Thresholds the given [image] based on the [thresholdValue].
  img.Image threshold(img.Image image, int thresholdValue) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        img.Pixel pixel = image.getPixel(x, y);
        num luminance = img.getLuminance(pixel);
        if (luminance > thresholdValue) {
          image.setPixel(x, y, img.ColorFloat16.rgb(255, 255, 255)); // White
        } else {
          image.setPixel(x, y, img.ColorFloat16.rgb(0, 0, 0)); // Black
        }
      }
    }
    return image;
  }

  /// Extracts holds from the binary [image] around the specified [center].
  List<Hold> extractHolds(img.Image binaryImage, Point<double> center) {
    List<Hold>? holds = [];

    holds = connectedComponents(binaryImage, center);
    if (holds == null) {
      return [];
    }

    return holds;
  }

  /// Finds connected components in the binary [edgeImage] around the specified [from] point.
  List<Hold>? connectedComponents(img.Image edgeImage, Point<double> from) {
    final int width = edgeImage.width;
    final int height = edgeImage.height;

    List<List<int>> whites = [];

    int loops = 0;
    for (var i = 0; i < loops; i++) {
      for (var x = 1; x < height - 1; x++) {
        for (var y = 1; y < width - 1; y++) {
          if (edgeImage.getPixel(y, x).r == 255 &&
              edgeImage.getPixel(y, x).g == 255 &&
              edgeImage.getPixel(y, x).b == 255) {
            whites.add([y, x]);
          }
        }
      }
      for (var i = 0; i < whites.length; i++) {
        edgeImage.setPixelRgb(
            whites[i].first + 1, whites[i].last, 255, 255, 255);
        edgeImage.setPixelRgb(
            whites[i].first, whites[i].last + 1, 255, 255, 255);
        edgeImage.setPixelRgb(
            whites[i].first - 1, whites[i].last, 255, 255, 255);
        edgeImage.setPixelRgb(
            whites[i].first, whites[i].last - 1, 255, 255, 255);
      }
    }
    for (var x = 1; x < height - 1; x++) {
      for (var y = 1; y < width - 1; y++) {
        if (edgeImage.getPixel(y, x).r == 255 &&
            edgeImage.getPixel(y, x).g == 255 &&
            edgeImage.getPixel(y, x).b == 255) {
          whites.add([y, x]);
        }
      }
    }
    List<List<Point<int>>> holds = findConnectedRegions(edgeImage);

    List<Point<double>> centers = [];
    for (var region in holds) {
      if (region.length >= 300 && region.length <= 3000) {
        Point<double> center = calculateCenter(region);
        bool addCenter = true;
        for (var existingCenter in centers) {
          // Check if the current center is too close to any existing center
          if ((existingCenter.x - center.x).abs() < 120 &&
              (existingCenter.y - center.y).abs() < 120) {
            // Merge the center to the middle of existing center and new center
            center = Point((existingCenter.x + center.x) / 2,
                (existingCenter.y + center.y) / 2);
            centers[centers.indexOf(existingCenter)] =
                center; // Update existing center
            addCenter = false;
            break;
          }
        }
        if (addCenter) {
          centers.add(center);
        }
      }
    }

    // Output the center locations
    print("Holds: ${holds.length}");
    print("Centers ${centers.length}");

    for (var center in centers) {
      print("Center: (${center.x}, ${center.y})");
    }

    for (var center in centers) {
      drawSquare(edgeImage, center.x.toInt(), center.y.toInt(), 20, 255, 0, 0);
    }
    return centers.map((center) => Hold(center, "red")).toList();
  }

  void writeFile(img.Image edgeImage) async {
    final directory = await getApplicationDocumentsDirectory();
    print(directory.path);
    File('${directory.path}/edge.png')
        .writeAsBytesSync(img.encodePng(edgeImage));
  }

  /// Draws a square with the specified [color] around the given [center] point.
  void drawSquare(img.Image image, int centerX, int centerY, int size,
      int colorR, int colorG, int colorB) {
    int startX = centerX - size ~/ 2;
    int endX = centerX + size ~/ 2;
    int startY = centerY - size ~/ 2;
    int endY = centerY + size ~/ 2;

    startX = startX.clamp(0, image.width - 1);
    endX = endX.clamp(0, image.width - 1);
    startY = startY.clamp(0, image.height - 1);
    endY = endY.clamp(0, image.height - 1);

    for (int y = startY; y <= endY; y++) {
      for (int x = startX; x <= endX; x++) {
        image.setPixel(x, y, img.ColorInt16.rgb(colorR, colorG, colorB));
      }
    }
  }

  /// Finds connected regions in the given [image].
  List<List<Point<int>>> findConnectedRegions(img.Image image) {
    Set<Point<int>> visited = {};
    List<List<Point<int>>> regions = [];
    for (var x = 0; x < image.width; x++) {
      for (var y = 0; y < image.height; y++) {
        if (image.getPixel(x, y).r == 255 &&
            image.getPixel(x, y).g == 255 &&
            image.getPixel(x, y).b == 255 &&
            !visited.contains(Point(x, y))) {
          List<Point<int>> region = [];
          floodFill(image, x, y, visited, region);
          regions.add(region);
        }
      }
    }
    return regions;
  }

  /// Performs a flood fill starting from the specified [x], [y] coordinates in the given [image].
  void floodFill(img.Image image, int x, int y, Set<Point<int>> visited,
      List<Point<int>> region) {
    if (x < 0 || x >= image.width || y < 0 || y >= image.height) {
      return;
    }
    if (image.getPixel(x, y).r != 255 ||
        image.getPixel(x, y).g != 255 ||
        image.getPixel(x, y).b != 255) {
      return;
    }
    Point<int> point = Point(x, y);
    if (visited.contains(point)) {
      return;
    }
    visited.add(point);
    region.add(point);
    floodFill(image, x + 1, y, visited, region);
    floodFill(image, x - 1, y, visited, region);
    floodFill(image, x, y + 1, visited, region);
    floodFill(image, x, y - 1, visited, region);
  }

  /// Calculates the center point of the given list of [points].
  Point<double> calculateCenter(List<Point<int>> points) {
    int sumX = 0;
    int sumY = 0;
    for (Point point in points) {
      sumX += point.x.toInt();
      sumY += point.y.toInt();
    }
    return Point<double>(
        sumX / (points.length + 1), sumY / (points.length + 1));
  }

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  /// Initializes the speech recognition.
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    if (_speechEnabled) {
      _startTimeout();
    }
  }

  /// Starts listening for speech input.
  Future<void> _startListening() async {
    if (_speechEnabled) {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenOptions: SpeechListenOptions(listenMode: ListenMode.confirmation),
      );
      // Restart the timeout timer
      _cancelTimeout();
      _startTimeout();
    }
  }

  /// Stops the active speech recognition session.
  Future<void> _stopListening() async {
    if (_speechEnabled) {
      await _speechToText.stop();
    }
  }

  // Start a timer to handle timeout
  void _startTimeout() {
    _timeoutTimer = Timer(Duration(seconds: _timeoutDuration), () async {
      if (_speechEnabled) {
        await _stopListening();
        await _startListening();
        _startTimeout();
      }
    });
  }

  // Cancel the timeout timer
  void _cancelTimeout() {
    _timeoutTimer.cancel();
  }

  /// Callback for the speech recognition result.
  void _onSpeechResult(SpeechRecognitionResult result) {
    _cancelTimeout(); // Cancel the timeout timer when a result is received
    _lastWords = result.recognizedWords;

    print(_lastWords);
    switch (_lastWords.toLowerCase()) {
      case 'repeat':
        _stopListening();
        print("repeat");
        repeat();
        return;
      case 'next':
        _stopListening();
        print("next");
        next();
        return;
      case 'distance':
        _stopListening();
        print('distance');
        distance();
        return;
      case 'help':
        _stopListening();
        print('help');
        help();
        break;
      case 'stop':
        _commandHelper.processCommand("stop");
        break;
    }
    _startListening();
  }

  /// Processes an event.
  Future<void> processEvent() async {
    _startListening();
  }

  String mainColor = "white";

  /// Initiates the distance command.
  void distance() async {
    Person person =
        Person([const Point<double>(10, 20), const Point<double>(30, 40)]);
    List<Hold> holds = [
      Hold(const Point<double>(15, 25), "red"),
      Hold(const Point<double>(35, 45), "red")
    ];
    _commandHelper.processCommand(
        "distance red", person, holds, 100000, mainColor);
  }

  /// Initiates the repeat command.
  void repeat() {
    Person person =
        Person([const Point<double>(10, 20), const Point<double>(30, 40)]);
    List<Hold> holds = [
      Hold(const Point<double>(15, 25), "red"),
      Hold(const Point<double>(35, 45), "red")
    ];

    _commandHelper.processCommand("repeat", person, holds, 10000, mainColor);
  }

  /// Initiates the help command.
  void help() {
    _commandHelper.processCommand("help");
  }

  /// Initiates the next command.
  void next() async {
        Directory tempDir = await getTemporaryDirectory();
    final XFile imageFile = await _cameraController.takePicture();

    img.Image? image = img.decodeImage(File(imageFile.path).readAsBytesSync());
    if (image == null) {
      return;
    }
    img.Image maxLuminance =
        img.luminanceThreshold(image.clone(), threshold: 0.7);
    maxLuminance = img.gaussianBlur(maxLuminance, radius: 20);
    maxLuminance = img.luminanceThreshold(maxLuminance, threshold: 0.7);

    List<Point<int>> points = [];
    for (int y = 0; y < maxLuminance.height; y++) {
      for (int x = 0; x < maxLuminance.width; x++) {
        if (maxLuminance.getPixel(x, y).r == 255 &&
            maxLuminance.getPixel(x, y).g == 255 &&
            maxLuminance.getPixel(x, y).b == 255) {
          points.add(Point(x, y));
        } else {
          continue;
        }
      }
    }
    Point<double> center = calculateCenter(points);
    print(points.length);
    drawSquare(maxLuminance, center.x.toInt(), center.y.toInt(), 20, 255, 0, 0);
    File tempFile = File('${tempDir.path}/edge_image.png');
    await tempFile.writeAsBytes(img.encodePng(maxLuminance));

    await GallerySaver.saveImage(tempFile.path);
    img.Image grayScale = img.grayscale(image);
    img.Image blur = img.gaussianBlur(grayScale, radius: 4);

    tempFile = File('${tempDir.path}/edge_image.png');
    await tempFile.writeAsBytes(img.encodePng(blur));

    await GallerySaver.saveImage(tempFile.path);

    img.Image edgeDetectedImage = img.sobel(blur, amount: 15);

    //edgeDetectedImage = img.gaussianBlur(edgeDetectedImage, radius: 3);

    edgeDetectedImage =
        img.luminanceThreshold(edgeDetectedImage, threshold: 0.25);

    List<Hold> holds = extractHolds(edgeDetectedImage, center);

    tempFile = File('${tempDir.path}/edge_image.png');
    await tempFile.writeAsBytes(img.encodePng(edgeDetectedImage));

    await GallerySaver.saveImage(tempFile.path);

    print(holds.length);

    Person person = Person([Point(center.x.toDouble(), center.y.toDouble())]);

    String color = 'red';
    _commandHelper.processCommand(
        "distance $color", person, holds, 50000000, mainColor);
    print("processed");
  }
}
