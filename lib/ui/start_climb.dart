import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:processing/image_processing.dart';
import 'package:flutter/services.dart';


late List<CameraDescription> cameras;

class StartClimb extends StatelessWidget {
  const StartClimb({super.key});

  
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
  
      home: CameraApp(),
    );
  }
}

class CameraApp extends StatefulWidget {
  const CameraApp({Key? key}) : super(key: key);

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController _controller;
  late ImageProcessing _imageProcessing;
  late bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print("access was denied");
            break;
          default:
            print(e.description);
            break;
        }
      }
    });

    _imageProcessing = ImageProcessing(cameraController: _controller);

    // Start listening for voice commands when the state is initialized
    _startListening();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            child: CameraPreview(_controller),
          ),
          Container(
            alignment: const AlignmentDirectional(0.0, 0.0),
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4F2683),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                            _imageProcessing.next(); // Start speech recognition
                          },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    child: const Text(
                      'Start Speech Recognition',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4F2683),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Modify _startListening method to continuously listen for voice commands
  void _startListening() async {
    _isListening = true;
    await _imageProcessing.processEvent();
    if (mounted) setState(() {});
  }
}