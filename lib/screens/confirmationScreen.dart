import 'dart:async';
import 'package:flutter/material.dart';

class ConfirmationScreen extends StatelessWidget {
  final String displayText;

  const ConfirmationScreen({Key? key, required this.displayText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          TopContainer(screenWidth, screenHeight),
          Expanded(child: MiddleContainer(screenWidth, screenHeight, displayText)),
          BottomContainer(screenWidth, screenHeight),
        ],
      ),
    );
  }
}


class MiddleContainer extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final String displayText; // Add displayText parameter

  const MiddleContainer(this.screenWidth, this.screenHeight, this.displayText);

  @override
  _MiddleContainerState createState() => _MiddleContainerState();
}

class _MiddleContainerState extends State<MiddleContainer> {
  String _displayText = "";
  late int _currentIndex; // Declare current index as late variable

  @override
  void initState() {
    super.initState();
    _currentIndex = 0; // Initialize current index
    _startTypewriterAnimation();
  }

  void _startTypewriterAnimation() {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (_currentIndex < widget.displayText.length) {
        setState(() {
          _displayText += widget.displayText[_currentIndex];
          _currentIndex++;
        });
      } else {
        timer.cancel(); // Stop the timer when the full text is displayed
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(widget.screenWidth * 0.08),
      child: Container(
        width: widget.screenWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(widget.screenWidth * 0.13)),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_empty, color: Colors.white, size: widget.screenWidth * 0.1),
              SizedBox(width: 8),
              Expanded( // Use Expanded to prevent overflow
                child: SingleChildScrollView( // Allow scrolling if necessary
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    _displayText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: widget.screenWidth * 0.07,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget TopContainer(double screenWidth, double screenHeight) {
  return Container(
    height: screenHeight * 0.11,
    width: screenWidth,
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(screenWidth * 0.16),
        bottomRight: Radius.circular(screenWidth * 0.16),
      ),
    ),
  );
}

Widget BottomContainer(double screenWidth, double screenHeight) {
  return Container(
    height: screenHeight * 0.11,
    width: screenWidth,
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(screenWidth * 0.16),
        topRight: Radius.circular(screenWidth * 0.16),
      ),
    ),
  );
}
