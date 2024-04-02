
import 'package:flutter/material.dart';
import 'package:processing/command_helper.dart';
import 'package:processing/process.dart';

class Help extends StatelessWidget {
  const Help({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Process process = Process();
    CommandHelper commandHelper = CommandHelper(process);

    commandHelper.processCommand('help');

    return Scaffold(
      body: Stack(
        children: [
          Container(
            
            alignment: const AlignmentDirectional(0.0, -1.0),
            color: const Color(0xFF4F2683),

            padding: const EdgeInsets.fromLTRB(10, 50, 10, 16),
              child: const Column(
                  
                children:[
                  
                  Text('HELP',
                    style: TextStyle( color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w700
                      ),
                    ),
                ],
              ),
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
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
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
              ],
              ),
          ),  

          Container(
            alignment: const AlignmentDirectional(0.0, 0.0),
             padding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  Text('This is where all resourses for using the app will appear once added',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  ),
              ],
            ),
          )
      ],

     

    
      ),
    );
  }
}
