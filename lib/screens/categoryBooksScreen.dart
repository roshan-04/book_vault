import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'book_detail_screen.dart';

class CategoryBooksScreen extends StatefulWidget {
  final String department;

  const CategoryBooksScreen({Key? key, required this.department}) : super(key: key);

  @override
  _CategoryBooksScreenState createState() => _CategoryBooksScreenState();
}

class _CategoryBooksScreenState extends State<CategoryBooksScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> books = [];

  Future<void> fetchBooks() async {
    try {
      final querySnapshot = await _firestore
          .collection('book')
          .where('department', isEqualTo: widget.department)
          .get();

      final bookList = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {
        books = bookList;
      });
    } catch (e) {
      print('Error fetching books: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBooks(); // Fetch books when the screen is initialized
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        title: Text('Books in ${widget.department}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: books.isEmpty
          ? Center(
        child: Text(
          'No books :)',
          style: TextStyle(
            fontSize: 20 * textScaleFactor,
            color: Colors.blueGrey,
          ),
        ),
      )
          : ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          bool isAvailable = book['availability'] >= 1;
          //this is the code from the project only
          return InkWell(
              onTap: () {
                // Navigate to the BookDetailScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookDetailScreen(book: book),
                  ),
                );
              },
              child: Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Expanded widget for the image to take up more space
                      Container(
                        width: 120, // Increased image size for a more prominent display
                        height: 150,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            book['imageUrl'] ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.book, size: 50),
                          ),
                        ),
                      ),
                      SizedBox(width: 16), // Space between image and text
                      // Expanded widget for the text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book['title'] ?? 'No Title',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18, // Larger font for the title
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('Author: ${book['authorName'] ?? 'Unknown'}'),
                            Text('Genre: ${book['genre'] ?? 'Unknown'}'),
                            Text('Edition: ${book['edition'] ?? 'N/A'}'),
                            SizedBox(height: 8),
                            Text(
                              isAvailable ? 'Available' : 'Not Available',
                              style: TextStyle(
                                color: isAvailable ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
          );
        },
      ),
    );
  }
}
