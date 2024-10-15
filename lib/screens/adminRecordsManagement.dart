import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'recordReviewScreen.dart';
import 'package:book_vault/constants/colors.dart';
class AdminBorrowedBooksScreen extends StatefulWidget {
  @override
  _AdminBorrowedBooksScreenState createState() => _AdminBorrowedBooksScreenState();
}

class _AdminBorrowedBooksScreenState extends State<AdminBorrowedBooksScreen> {
  List<Map<String, dynamic>> records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPendingRecords();
  }

  void _fetchPendingRecords() async {
    setState(() {
      records.clear();
      _isLoading = true; // Optionally set loading state to true
    });

    final snapshot = await FirebaseFirestore.instance
        .collection('staff')
        .doc('3u6dRZrnMcNXDWwojFht1CXuYv12')
        .get();

    final staffData = snapshot.data() as Map<String, dynamic>;

    List<Future<Map<String, dynamic>>> recordFutures = [];

    for (var recordRef in staffData['managesREL']) {
      recordFutures.add(_fetchRecordAndBookData(recordRef));
    }

    List<Map<String, dynamic>> allRecords = await Future.wait(recordFutures);

    setState(() {
      records.addAll(allRecords);
      _isLoading = false;
    });
  }

  Future<Map<String, dynamic>> _fetchRecordAndBookData(DocumentReference recordRef) async {
    // Fetch the record data from the record collection
    var recordSnapshot = await recordRef.get();
    final recordData = recordSnapshot.data() as Map<String, dynamic>;

    // Fetch the book data from the book collection using the bookID reference
    var bookRef = recordData['bookID'] as DocumentReference;
    var bookSnapshot = await bookRef.get();
    final bookData = bookSnapshot.data() as Map<String, dynamic>;

    var studentRef = recordData['studentID'] as DocumentReference;
    var studentSnapshot = await studentRef.get();
    final studentData = studentSnapshot.data() as Map<String, dynamic>;

    String imageUrl = await FirebaseStorage.instance
        .ref(bookData['bookimg'])
        .getDownloadURL();

    return {
      'recordRef': recordRef,
      'title': bookData['title'],
      'imageUrl': imageUrl,
      'fname': studentData['firstName'],
      'lname': studentData['lastName'],
      'rollno': studentData['rollNo'],
      'dept': studentData['dept']
    };
  }


  void _navigateToReviewScreen(DocumentReference record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewRecordScreen(record: record),
      ),
    );
  }

  void _deleteRecord(DocumentReference? recordRef) async {
    if (recordRef == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: Record reference is null.'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show spinner during the deletion process
    setState(() {
      _isLoading = true;
    });

    try {

      String recordID = recordRef.id;

      // Step 1: Get the borrow documents associated with the recordRef
      final borrowQuerySnapshot = await FirebaseFirestore.instance
          .collection('borrows')
          .where('recordID', isEqualTo: recordRef)
          .get();

      // Step 2: Fetch the record document to get the associated student reference
      final recordSnapshot = await recordRef.get();
      final recordData = recordSnapshot.data() as Map<String, dynamic>?;

      if (recordData == null || !recordData.containsKey('studentID')) {
        throw Exception('Student ID not found in record data.');
      }

      final studentRef = recordData['studentID'] as DocumentReference;

      // Step 3: Remove the borrow documents and update borrowsREL
      if (borrowQuerySnapshot.docs.isNotEmpty) {
        for (var borrowDoc in borrowQuerySnapshot.docs) {
          // Delete each borrow document
          await borrowDoc.reference.delete();
        }
      }

      // Step 4: Update the student's borrowsREL array to remove the record reference
      await studentRef.update({
        'borrowsREL': FieldValue.arrayRemove([borrowQuerySnapshot.docs.first.reference]) // Adjust if necessary
      });

      final fineQuerySnapshot = await FirebaseFirestore.instance
          .collection('fine')
          .where('recordID', isEqualTo: recordID)
          .get();

      if (fineQuerySnapshot.docs.isNotEmpty) {
        for (var fineDoc in fineQuerySnapshot.docs) {
          await fineDoc.reference.delete();
        }
      }

      await recordRef.delete();
      final staffDocRef = FirebaseFirestore.instance
          .collection('staff')
          .doc('3u6dRZrnMcNXDWwojFht1CXuYv12');
      await staffDocRef.update({
        'managesREL': FieldValue.arrayRemove([recordRef])
      });

      // Re-fetch records to update the list
      _fetchPendingRecords();
      //_fetchRecordAndBookData();

      // Show success Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Record deleted successfully.'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting record: $e'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Hide spinner after process is done
      setState(() {
        _isLoading = false;
      });
    }
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
          'Pending Borrow Records',
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
        child: records.isEmpty
            ? Center(
          child: Text(
            'No pending records found.',
            style: TextStyle(
              fontSize: 20 * textScaleFactor,
              color: Colors.blueGrey,
            ),
          ),
        )
            : ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];

            return Card(
              margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TopPart(textScaleFactor, screenHeight, screenWidth, record),
                    SizedBox(height: screenHeight * 0.005),
                    ButtonRow(screenWidth, record)
                  ],
                )
              ),
            );
          },
        ),
      ),
    );
  }
  Widget ButtonRow(double screenWidth, final record) {
    return  Row(
      children: [
        SizedBox(width: screenWidth * 0.16),
        ElevatedButton(
          onPressed: () => _navigateToReviewScreen(record['recordRef']),
          child: Text(
            'Review',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
            ),
          ),
          style: ElevatedButton.styleFrom(
              backgroundColor: kblue_2
          ),
        ),
        SizedBox(width: screenWidth * 0.07),
        ElevatedButton(
          onPressed: () => _deleteRecord(record['recordRef']),
          child: Text(
            'Delete',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
            ),
          ),
          style: ElevatedButton.styleFrom(
              backgroundColor: kdarkblue
          ),
        ),
      ],
    );
  }
  
  Widget TopPart(double textScaleFactor, double screenHeight, double screenWidth, final record) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
            flex: 3,
            child: TextPart(textScaleFactor, screenHeight, record)
        ),
        SizedBox(width: screenWidth * 0.02),
        Flexible(
          flex: 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              record['imageUrl'] ?? '',
              height: screenHeight * 0.19,
              width: screenWidth * 0.33,
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
    );
  }
  
  Widget TextPart(double textScaleFactor, double screenHeight, final record) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            record['title'] ?? '',
            style: TextStyle(
              fontSize: 20 * textScaleFactor,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            'Name: ${record['fname'] ?? ''} ${record['lname'] ?? ''}',
            style: TextStyle(
              fontSize: 16 * textScaleFactor,
              color: Colors.blueGrey,
            ),
          ),
          SizedBox(height: screenHeight * 0.008),
          Text(
            'Department: ${record['dept'] ?? ''}',
            style: TextStyle(
              fontSize: 16 * textScaleFactor,
              color: Colors.blueGrey,
            ),
          ),
          SizedBox(height: screenHeight * 0.008),
          Text(
            'Roll no: ${record['rollno'] ?? ''}',
            style: TextStyle(
              fontSize: 16 * textScaleFactor,
              color: Colors.blueGrey,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
        ]
    );
  }
}
