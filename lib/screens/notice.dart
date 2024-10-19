import 'package:flutter/material.dart';

import '../widgets/elevatedButton.dart';

class Notice extends StatelessWidget {
  const Notice({super.key});

  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 30,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            "Notices",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blueAccent,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text(
                  "Notices",
                  style: TextStyle(fontSize: 32,color: Colors.black, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: screenHeight * 0.02),
                const Text(
                  "Add a notice to be displayed to the students.",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: "Heading",
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                    prefixIcon: const Icon(
                      Icons.add_box_sharp,
                      color: Colors.black45,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.015,
                      horizontal: screenWidth * 0.04,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFf1f5f9),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 2.0,
                        color: Colors.blueAccent,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 2.0,
                        color: Colors.redAccent,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: "Write the Notice here",
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                    prefixIcon: const Icon(
                      Icons.add_box_sharp,
                      color: Colors.black45,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.015,
                      horizontal: screenWidth * 0.04,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFf1f5f9),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 2.0,
                        color: Colors.blueAccent,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 2.0,
                        color: Colors.redAccent,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),
                CustomElevatedButton(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  onPressed: () {},
                  text: 'Post',
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}