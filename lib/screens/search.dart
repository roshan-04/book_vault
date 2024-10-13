import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_detail_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';

class BookSearchScreen extends StatefulWidget {
  @override
  _BookSearchScreenState createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends State<BookSearchScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;

  // Method to search books in Firestore
  Future<void> searchBooks(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Query to fetch all books
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('book')
          .get();

      // Parsing the documents into a list of books
      List<Map<String, dynamic>> books = snapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      // Filter books based on case-insensitive title search
      List<Map<String, dynamic>> filteredBooks = [];

      for (var book in books) {
        final title = book['title'] ?? '';
        if (title.toLowerCase().contains(query.toLowerCase())) {
          // Fetch the image URL from Firebase Storage
          String imageUrl = await FirebaseStorage.instance
              .ref(book['bookimg']) // Assuming bookimg is the file path in Firebase Storage
              .getDownloadURL();

          // Add the imageUrl to the book data
          book['imageUrl'] = imageUrl;

          filteredBooks.add(book);
        }
      }

      setState(() {
        searchResults = filteredBooks;
      });
    } catch (e) {
      print("Error fetching books: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 30,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Search Books",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search input field
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Enter book title",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 16.0),
              ),
              onChanged: (query) {
                searchBooks(query); // Call searchBooks method on text input
              },
            ),
            SizedBox(height: 20),
            // Display loading spinner while fetching data
            isLoading
                ? Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ))
                : SearchResult(),
          ],
        ),
      ),
    );
  }
  Widget SearchResult () {
    return Expanded(
      // Display the search results in a ListView
      child: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          var book = searchResults[index];
          bool isAvailable = book['availability'] >= 1;

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
