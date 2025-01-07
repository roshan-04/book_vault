import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/elevatedButton.dart';  // Custom button widget

class Notice extends StatelessWidget {
  final TextEditingController headingController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[700],  // Deep blue app bar
          title: const Text('Post Notice', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: const Text(
                    "Create Notice",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                const Text(
                  "Fill in the details to post a notice",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),

                // Heading input field
                TextFormField(
                  controller: headingController,
                  decoration: InputDecoration(
                    labelText: "Notice Heading",
                    labelStyle: const TextStyle(color: Colors.black87),
                    prefixIcon: const Icon(Icons.title, color: Colors.blueAccent),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.04,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFE8F0FE),  // Light blue background
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(width: 2.0, color: Colors.blueAccent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),

                // Notice content input field
                TextFormField(
                  controller: contentController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: "Notice Content",
                    labelStyle: const TextStyle(color: Colors.black87),
                    prefixIcon: const Icon(Icons.article, color: Colors.blueAccent),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.04,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFE8F0FE),  // Light blue background
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(width: 2.0, color: Colors.blueAccent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),

                // Submit button
                Center(
                  child: CustomElevatedButton(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue[700],  // Dark blue button
                    onPressed: () {
                      if (headingController.text.isNotEmpty && contentController.text.isNotEmpty) {
                        _submitNotice(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill out all fields')),
                        );
                      }
                    },
                    text: 'Post Notice',
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Submit notice to Firestore
  void _submitNotice(BuildContext context) {
    FirebaseFirestore.instance.collection('notice').add({
      'heading': headingController.text,
      'content': contentController.text,
      'timestamp': FieldValue.serverTimestamp(),
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notice posted successfully!')),
      );
      Navigator.pop(context); // Go back after submitting
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post notice: $error')),
      );
    });
  }
}
