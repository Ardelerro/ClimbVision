// ignore_for_file: prefer_const_constructors

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:processing/ui/home_page.dart';
import 'package:processing/ui/start_climb.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

@override
  Widget build(BuildContext context) {

  return MaterialApp(
   home: const HomePage(),
  );
}
}
//void main() => runApp(const MyApp());
/*
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in a Flutter IDE). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TTS Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('TTS Demo'),
        ),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                //OutputUtils().speak("Hello, world!");
                //processEvent();
                next();
              },
              child: const Text('Speak'),
            ),
            ElevatedButton(
              onPressed: () async {
                OutputUtils().speak("Hello, world!");
                repeat();
              },
              child: const Text('Repeat'),
            ),
            ElevatedButton(
              onPressed: () async {
                OutputUtils().speak("Hello, world!");
                help();
              },
              child: const Text('Help'),
            ),
          ],
        ),
      ),
    );
  }


}



/*
List<CameraDescription> cameras = []; // List to store available cameras

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras(); // Get available cameras
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Climbing Hold Detection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  final Cv2 _cv2 = Cv2();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await _cameraController.initialize();
    if (!mounted) return;
    setState(() {
      _isCameraInitialized = true;
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Climbing Hold Detection'),
      ),
      body: Stack(
        children: [
          CameraPreview(_cameraController), // Display camera preview
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  _processImage(); // Call function to process image
                },
                child: Text('Detect Holds'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processImage() async {
    if (!_cameraController.value.isInitialized) {
      return;
    }

    // Capture image from camera
    final XFile cameraImage =
        await _cameraController.takePicture(); // You may need to use takePicture() for a still image
    Uint8List imageBytes = await cameraImage.readAsBytes();

    imglib.Image image = imglib.decodeImage(imageBytes)!;
    imglib.Image image2 = imglib.grayscale(image);
    imglib.Image image3 = imglib.sobel(image2);
    /*
    Uint8List? imgGray = await Cv2.cvtColor(pathString: cameraImage.path, outputType: Cv2.COLOR_RGB2GRAY);

    if (imgGray == null) {
      
    }

    final XFile wtf = imgli
    */
    //Uint8List? edges = await Cv2.sobel(pathString: pathString, depth: depth, dx: dx, dy: dy).
    // Convert CameraImage to OpenCV Mat
    
    final img = await OpenCVHelper.matFromImageData(
      width: cameraImage.width,
      height: cameraImage.height,
      imgFormat: OpenCVImageFormat.BGRA,
      imageData: cameraImage.planes.map((plane) {
        return plane.bytes;
      }).toList(),
    );

    // Perform edge detection and color segmentation here using OpenCV functions

    // Display processed image (edges and segmented holds)
    // You may need to convert processed image back to Flutter Image format

    // Dispose OpenCV resources
    img.release();
  }
}
*/
*/