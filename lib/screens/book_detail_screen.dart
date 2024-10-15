import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:book_vault/widgets/elevatedButton.dart';
import 'confirmationScreen.dart';

class BookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  BookDetailScreen({required this.book});

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool isFavorited = false;
  String? imageUrl;
  String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    _loadImage();
    super.initState();
    _checkIfFavorited();
  }

  Future<void> _loadImage() async {
    try {
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

  Future<void> _toggleFavorite() async {
    DocumentReference userRef = FirebaseFirestore.instance
        .collection('favourite')
        .doc(userId);
    DocumentReference bookRef = FirebaseFirestore.instance
        .collection('book')
        .doc(widget.book['isbn']);

    setState(() {
      isFavorited = !isFavorited;
    });

    DocumentSnapshot userDoc = await userRef.get();
    if (!userDoc.exists) {
      await userRef.set({
        'books': [],
      });
    }

    if (isFavorited) {
      await userRef.update({
        'books': FieldValue.arrayUnion([bookRef]),
        // Add book to favorites
      });
      final snackBar = SnackBar(
        content: Text('Added to favorites'),
        duration: Duration(seconds: 1),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      await userRef.update({
        'books': FieldValue.arrayRemove([bookRef]),
        // Remove book from favorites
      });
      final snackBar = SnackBar(
        content: Text('Removed from favorites'),
        duration: Duration(seconds: 1),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> _checkIfFavorited() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('favourite')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      List<dynamic> favorites = userDoc['books'] ?? [];

      DocumentReference bookRef = FirebaseFirestore.instance
          .collection('book')
          .doc(widget.book['isbn']);

      if (favorites.any((ref) => ref.path == bookRef.path)) {
        setState(() {
          isFavorited = true;
        });
      }
    }
  }

  Future<bool> _borrowBook() async {
    if (widget.book['availability'] >= 1) {

      CollectionReference records = FirebaseFirestore.instance.collection('record');
      CollectionReference fines = FirebaseFirestore.instance.collection('fine');
      CollectionReference staff = FirebaseFirestore.instance.collection('staff');

      DocumentReference studentRef = FirebaseFirestore.instance
            .collection('student')
            .doc(userId);

      DocumentReference bookRef = FirebaseFirestore.instance
              .collection('book')
              .doc(widget.book['isbn']);

      DocumentReference docRef = records.doc();
      DocumentReference fineRef = fines.doc();

      await docRef.set({
        'recordID': docRef.id,
        'borrowdate': "00/00/0000",
        'duedate': "00/00/0000",
        'bookID': bookRef,
        'studentID': studentRef,
      });

      await fineRef.set({
      'fineAMT': 0,
      'fineexcessAMT': 0,
      'finepaydate': FieldValue.serverTimestamp(),
      'recordID': docRef.id
      });

      await FirebaseFirestore.instance.collection('book').doc(widget.book['isbn']).update({
        'availability': FieldValue.increment(-1),
      });

      DocumentReference staffRef = staff.doc('3u6dRZrnMcNXDWwojFht1CXuYv12');
      await staffRef.update({
        'managesREL': FieldValue.arrayUnion([docRef]),
      });
      return true;
    } else {
      // Handle case where the book is not available
      return false;
    }
  }


 @override
  Widget build(BuildContext context) {
   double screenWidth = MediaQuery.of(context).size.width;
   double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
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
                      : CircularProgressIndicator(
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.blue),
                  ), // Show a loader while image is being fetched
                ),
              ),
            ),
            SizedBox(height: 20),
            ButtonRow(screenWidth,screenHeight),
            SizedBox(height: 10),
            Card(
              elevation: 8, // Adds shadow to make the card stand out
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // Rounded corners
              ),
              color: Colors.white, // White background for the card
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.book['title'] ?? 'No Title'}',
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
                        color: Colors.grey[700], // Softer color for better readability
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
                      widget.book['description'] ?? 'No description available.',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 20),
                    CustomElevatedButton(
                      onPressed: () async {
                        bool success = await _borrowBook();
                        String displayText;
                        if (success) {
                          displayText = "Processing Request\nCheck borrowed \nbooks";
                        } else {
                          displayText = "This Book is not \n Available";
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ConfirmationScreen(displayText: displayText)),
                        );
                        await Future.delayed(Duration(seconds: 8));
                        Navigator.pop(context);
                      },
                      text: "Borrow",
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Roboto',
                        color: Colors.white,
                      ),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget ButtonRow(double screenWidth, double screenHeight) {
    return Row(
      children: [
        Spacer(flex: 2),
        ShowPDF(),
        Spacer(flex: 1), // Takes more space to center the button
        HeartButton(), // Heart button aligned to the right
      ],
    );
  }





  Widget ShowPDF(){
    return ElevatedButton(
      onPressed: () {
        // Implement the action to show the PDF
      },
      child: Text(
        "Show PDF",
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        textStyle: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget HeartButton(){
    return IconButton(
      onPressed: _toggleFavorite,
      icon: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isFavorited ? Colors.red : Colors.grey.shade200,
        ),
        padding: EdgeInsets.all(8.0),
        child: Icon(
          Icons.favorite,
          color: isFavorited ?  Colors.white: Colors.red,
          size: 30,
        ),
      ),
    );
  }
}
