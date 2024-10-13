import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Add Firebase storage import

class BookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  BookDetailScreen({required this.book});

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool isFavorited = false;
  String? imageUrl; // To store the image URL

  @override
  void initState() {
    super.initState();
    _loadImage(); // Fetch image on screen load
  }

  Future<void> _loadImage() async {
    try {
      // Get the download URL from Firebase Storage
      String url = await FirebaseStorage.instance
          .ref(widget.book['bookimg'])
          .getDownloadURL();
      setState(() {
        imageUrl = url;
      });
    } catch (e) {
      print('Error loading image: $e');
    }
  }

  void toggleFavorite() {
    setState(() {
      isFavorited = !isFavorited;
    });

    final snackBar = SnackBar(
      content: Text(
          isFavorited ? 'Added to favorites' : 'Removed from favorites'),
      duration: Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
          widget.book['title'] ?? 'Book Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imageUrl != null
                      ? Image.network(
                    imageUrl!,
                    height: 200,
                    width: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.book, size: 100),
                  )
                      : CircularProgressIndicator(), // Show a loader while image is being fetched
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Implement the action to show the PDF
                },
                child: Text(
                  "Show PDF",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 7),
              child: Card(
                elevation: 5, // Adds shadow to make the card stand out
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Rounded corners
                ),
                color: Colors.white, // White background for the card
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  // Padding inside the card
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Title: ${widget.book['title'] ?? 'No Title'}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto', // Use Roboto font
                          color: Colors.black87, // Slightly softer black
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Author: ${widget.book['authorName'] ?? 'Unknown'}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Roboto', // Roboto font
                          color: Colors
                              .grey[700], // Softer color for better readability
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Genre: ${widget.book['genre'] ?? 'Unknown'}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Roboto',
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Edition: ${widget.book['edition'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Roboto',
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'ISBN: ${widget.book['isbn']}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Roboto',
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Availability:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        widget.book['availability'] >= 1
                            ? 'Available'
                            : 'Not Available',
                        style: TextStyle(
                          fontSize: 18,
                          color: widget.book['availability'] >= 1
                              ? Colors.green
                              : Colors.red,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      SizedBox(height: 13),
                      Text(
                        'Description:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        widget.book['description'] ??
                            'No description available.',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 20),

                      // Additional buttons for borrowing or favorite functionality
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue, Colors.lightBlueAccent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                // Implement your borrow logic here
                              },
                              child: Text(
                                "Borrow",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Roboto',
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                // Button with gradient background
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.red, Colors.redAccent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                // Implement your favorite logic here
                              },
                              child: Text(
                                "Favorite",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Roboto',
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                // Button with gradient background
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
