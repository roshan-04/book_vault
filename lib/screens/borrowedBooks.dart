import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class BorrowedBooksScreen extends StatefulWidget {
  @override
  _BorrowedBooksScreenState createState() => _BorrowedBooksScreenState();
}

class _BorrowedBooksScreenState extends State<BorrowedBooksScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _fetchBorrowedBooks(user!.uid);
    } else {
      print('No user is currently logged in.');
    }
  }

  void _fetchBorrowedBooks(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('student')
        .doc(userId)
        .get();

    final studentData = snapshot.data() as Map<String, dynamic>;

    List<Future<Map<String, dynamic>>> borrowFutures = [];

    for (var borrowRef in studentData['borrowsREL']) {
      borrowFutures.add(_fetchBorrowAndBookData(borrowRef));
    }

    List<Map<String, dynamic>> allBooks = await Future.wait(borrowFutures);

    books.addAll(allBooks);

    setState(() {
      _isLoading = false;
    });
  }

  Future<Map<String, dynamic>> _fetchBorrowAndBookData(DocumentReference borrowRef) async {
    var borrowsnapshot = await borrowRef.get();
    final borrowsdata = borrowsnapshot.data() as Map<String, dynamic>;

    var bookFuture = borrowsdata['ISBNID'].get();
    var recordFuture = borrowsdata['recordID'].get();

    var booksnapshot = await bookFuture;
    var recordsnapshot = await recordFuture;

    final bookdata = booksnapshot.data() as Map<String, dynamic>;
    final recordsdata = recordsnapshot.data() as Map<String, dynamic>;

    String recordID = recordsdata['recordID'];

    final fineQuerySnapshot = await FirebaseFirestore.instance
        .collection('fine')
        .where('recordID', isEqualTo: recordID)
        .get();

    double finedata = 0.0; // Default to double

    if (fineQuerySnapshot.docs.isNotEmpty) {
      var fineDoc = fineQuerySnapshot.docs[0];
      finedata = fineDoc.data()?['fineAMT'] ?? 0.0; // No need to cast
    }

    String imageUrl = await FirebaseStorage.instance
        .ref(bookdata['bookimg'])
        .getDownloadURL();

    return {
      'title': bookdata['title'],
      'borrowDate': recordsdata['borrowdate'], // Ensure this is also correct type
      'dueDate': recordsdata['duedate'], // Ensure this is also correct type
      'imageUrl': imageUrl,
      'fine': finedata,
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
        title: Text(
          'Borrowed Books',
          style: TextStyle(color: Colors.white),
        ),
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
            'No borrowed books found.',
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

            return Card(
              margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
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
                            'Borrowed: ${book['borrowDate'] ?? ''}',
                            style: TextStyle(
                              fontSize: 16 * textScaleFactor,
                              color: Colors.blueGrey,
                            ),
                          ),
                          Text(
                            'Due Date: ${book['dueDate'] ?? ''}',
                            style: TextStyle(
                              fontSize: 16 * textScaleFactor,
                              color: Colors.blueGrey,
                            ),
                          ),
                          Text(
                            'Total Fine: ${book['fine'] ?? ''}',
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
                          errorBuilder: (context, error, stackTrace) => Icon(
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
            );
          },
        ),
      ),
    );
  }
}
