import 'package:flutter/material.dart';
import 'package:processing/ui/help.dart';
import 'package:processing/ui/start_climb.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Title widget using Text
          Container(
            alignment: const AlignmentDirectional(0.0, -1.0),
            padding: const EdgeInsets.fromLTRB(10, 50, 10, 16),
            child: const Column(
              children: [ Text(
                  'CLIMB VISION',
                  style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4F2683),
              ),),
              ],
            ),
          ),

          Container(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Opacity(
                opacity: 0.1,
                child: Image.asset(
                  'assets/mustangLogo.jpeg',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Buttons
          Container(
            alignment: const AlignmentDirectional(0.0, -1.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {// Handle button press
                      // Navigate to the Help component
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CameraApp()),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF4F2683)),
                    ),
                    child: const Text(
                      'START CLIMB',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle button press
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF4F2683)),
                    ),
                    child: const Text(
                      'AUDIO TESTING',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () { // Handle button press
                      // Navigate to the Help component
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Help()),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF4F2683)),
                    ),
                    child: const Text(
                      'HELP',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
}
