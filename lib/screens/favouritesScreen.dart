import 'package:book_vault/screens/book_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FavouritesScreen extends StatefulWidget {
  @override
  _FavouriteBooksScreenState createState() => _FavouriteBooksScreenState();
}

class _FavouriteBooksScreenState extends State<FavouritesScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _fetchFavouritedBooks(user!.uid);
    } else {
      print('No user is currently logged in.');
    }
  }

  void _fetchFavouritedBooks(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('favourite')
          .doc(userId)
          .get();

      final favouriteData = snapshot.data() as Map<String, dynamic>;

      List<Future<Map<String, dynamic>>> bookFutures = [];

      for (var bookRef in favouriteData['books']) {
        bookFutures.add(_fetchBookData(bookRef));
      }

      List<Map<String, dynamic>> allBooks = await Future.wait(bookFutures);
      books.addAll(allBooks);
    } catch (e) {
      print('Error fetching favourite books: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _fetchBookData(DocumentReference bookRef) async {
    var booksnapshot = await bookRef.get();
    final bookdata = booksnapshot.data() as Map<String, dynamic>;
    String imageUrl = await FirebaseStorage.instance
        .ref(bookdata['bookimg'])
        .getDownloadURL();

    return {
      'title': bookdata['title'],
      'authorName': bookdata['authorName'],
      'edition': bookdata['edition'],
      'imageUrl': imageUrl,
      'genre': bookdata['genre'],
    };
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Favourited Books', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      )
          : Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: books.isEmpty
            ? Center(
          child: Text(
            'No books favourited :)',
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
            return GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookDetailScreen(book: book),
                  ),
                );
              },
              child: Card(
                margin: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.01),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book['title'] ?? '',
                              style: TextStyle(
                                fontSize: 20 * textScaleFactor,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              'Author: ${book['authorName'] ?? ''}',
                              style: TextStyle(
                                fontSize: 16 * textScaleFactor,
                                color: Colors.blueGrey,
                              ),
                            ),
                            Text(
                              'Edition: ${book['edition'] ?? ''}',
                              style: TextStyle(
                                fontSize: 16 * textScaleFactor,
                                color: Colors.blueGrey,
                              ),
                            ),
                            Text(
                              'Genre: ${book['genre'] ?? ''}',
                              style: TextStyle(
                                fontSize: 16 * textScaleFactor,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Flexible(
                        flex: 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            book['imageUrl'] ?? '',
                            height: screenHeight * 0.15,
                            width: screenWidth * 0.25,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(
                                  Icons.broken_image,
                                  size: screenHeight * 0.15,
                                  color: Colors.grey,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
