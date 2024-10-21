import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class RemoveBook extends StatefulWidget {
  const RemoveBook({super.key});

  @override
  _RemoveBookState createState() => _RemoveBookState();
}

class _RemoveBookState extends State<RemoveBook> {
  final TextEditingController isbnController = TextEditingController();
  bool isLoading = false;

  Future<void> removeBook(String isbn) async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('book')
          .where('isbn', isEqualTo: isbn)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot bookDoc = querySnapshot.docs.first;
        String? bookImgPath = bookDoc['bookimg'];
        String? bookPdfPath = bookDoc['bookpdf'];

        if (bookImgPath != null && bookPdfPath != null) {
          try { // Delete Image
            await firebase_storage.FirebaseStorage.instance.ref(bookImgPath).delete();
          } catch(e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error deleting book Image: ${e.toString()}')),
            );
          }

          try { // Delete Pdf
            await firebase_storage.FirebaseStorage.instance.ref(bookPdfPath).delete();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error deleting book PDF: ${e.toString()}')),
            );
          }

          await FirebaseFirestore.instance.collection('book').doc(bookDoc.id).delete(); // Delete Collection

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Book successfully removed.')),
          );
        } else {
          String missingDetails = '';
          if (bookImgPath == null && bookPdfPath == null) {
            missingDetails = 'Both book image and PDF are missing.';
          } else if (bookImgPath == null) {
            missingDetails = 'Book image is missing.';
          } else if (bookPdfPath == null) {
            missingDetails = 'Book PDF is missing.';
          }

          _showNotFoundDialog(missingDetails);
        }
      } else {
        _showNotFoundDialog('No book found with the provided ISBN. Please check and try again.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showNotFoundDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Book Not Found'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Retry'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                isbnController.clear();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text("Remove Book"),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      "Remove Book",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    const Text(
                      "Enter the ISBN to remove the book.",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    TextFormField(
                      controller: isbnController,
                      decoration: InputDecoration(
                        labelText: "ISBN",
                        prefixIcon: const Icon(
                          Icons.book,
                          color: Colors.black45,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015,
                          horizontal: screenWidth * 0.04,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
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
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    ElevatedButton(
                      onPressed: () {
                        String isbn = isbnController.text.trim();
                        if (isbn.isNotEmpty) {
                          removeBook(isbn);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid ISBN.')),
                          );
                        }
                      },
                      child: const Text('Remove Book'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015,
                          horizontal: screenWidth * 0.1,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}