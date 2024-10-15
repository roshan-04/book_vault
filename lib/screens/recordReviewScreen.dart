import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:book_vault/widgets/elevatedButton.dart';

class ReviewRecordScreen extends StatefulWidget {
  final DocumentReference record;

  ReviewRecordScreen({required this.record});

  @override
  _ReviewRecordScreenState createState() => _ReviewRecordScreenState();
}

class _ReviewRecordScreenState extends State<ReviewRecordScreen> {
  final _fineAmtController = TextEditingController();
  final _fineExcessAmtController = TextEditingController();
  final _finePayDateController = TextEditingController();
  final _borrowDateController = TextEditingController();
  final _dueDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  void _fetchInitialData() async {
    // Fetch initial data from the record document
    final recordSnapshot = await widget.record.get();
    final recordData = recordSnapshot.data() as Map<String, dynamic>;

    // Set initial values in the text fields
    _borrowDateController.text = recordData['borrowdate'] ?? '';
    _dueDateController.text = recordData['duedate'] ?? '';
  }

  Future<void> _updateRecord() async {
    final String borrowDate = _borrowDateController.text;
    final String dueDate = _dueDateController.text;
    final double fineAmt = double.tryParse(_fineAmtController.text) ?? 0.0;
    final double fineExcessAmt = double.tryParse(_fineExcessAmtController.text) ?? 0.0;
    final DateTime finePayDate = DateTime.tryParse(_finePayDateController.text) ?? DateTime.now();

    // Step 1: Update the borrowDate and dueDate in the record document
    await widget.record.update({
      'borrowdate': borrowDate,
      'duedate': dueDate,
    });

    // Step 2: Search for the fine document with the same recordID
    var fineQuerySnapshot = await FirebaseFirestore.instance
        .collection('fine')
        .where('recordID', isEqualTo: widget.record.id)
        .get();

    if (fineQuerySnapshot.docs.isNotEmpty) {
      // Update the existing fine document
      for (var fineDoc in fineQuerySnapshot.docs) {
        await fineDoc.reference.update({
          'fineAMT': fineAmt,
          'fineexcessAMT': fineExcessAmt,
          'finepaydate': finePayDate,
        });
      }
    }

    // Fetch the record data as a Map<String, dynamic>
    final recordData = (await widget.record.get()).data() as Map<String, dynamic>;

    // Access the bookID and studentID
    DocumentReference bookRef = recordData['bookID'] as DocumentReference;
    DocumentReference studentRef = recordData['studentID'] as DocumentReference;

    // Step 3: Create a new borrows document
    DocumentReference newBorrowsDoc = await FirebaseFirestore.instance.collection('borrows').add({
      'ISBNID': bookRef,
      'recordID': widget.record,
    });

    // Step 4: Update the student's borrowsREL array
    await studentRef.update({
      'borrowsREL': FieldValue.arrayUnion([newBorrowsDoc]),
    });

    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Record updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Optionally pop the screen after updating
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: screenWidth*0.065,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
            'Review Record',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth  * 0.055),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Record details:',
              style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenHeight * 0.03),
            TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: _borrowDateController,
                decoration: InputDecoration(
                  labelText: "Borrowed on",
                  labelStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: screenWidth * 0.037,
                  ),
                  prefixIcon: const Icon(
                    Icons.add_card_rounded,
                    color: Colors.black45,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.015,
                    horizontal: screenWidth * 0.04,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFf1f5f9),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      width: 2.0,
                      color: Colors.blueAccent,
                    ),
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
              ),
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.black,
              ),
            ),

            SizedBox(height: screenHeight * 0.025),

            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _dueDateController,
              decoration: InputDecoration(
                labelText: 'Due on',
                labelStyle: TextStyle(
                  color: Colors.black87,
                  fontSize: screenWidth * 0.037,
                ),
                prefixIcon: const Icon(
                  Icons.add_card_rounded,
                  color: Colors.black45,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.015,
                  horizontal: screenWidth * 0.04,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFf1f5f9),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    width: 2.0,
                    color: Colors.blueAccent,
                  ),
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
              ),
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.black,
              ),
            ),

            SizedBox(height: screenHeight * 0.025),

            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _fineAmtController,
              decoration: InputDecoration(
                labelText: 'Fine Amount',
                labelStyle: TextStyle(
                  color: Colors.black87,
                  fontSize: screenWidth * 0.037,
                ),
                prefixIcon: const Icon(
                  Icons.add,
                  color: Colors.black45,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.015,
                  horizontal: screenWidth * 0.04,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFf1f5f9),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    width: 2.0,
                    color: Colors.blueAccent,
                  ),
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
              ),
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.black,
              ),
            ),

            SizedBox(height: screenHeight * 0.025),

            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _fineExcessAmtController,
              decoration: InputDecoration(
                labelText: 'Excess Fine Amount',
                labelStyle: TextStyle(
                  color: Colors.black87,
                  fontSize: screenWidth * 0.037,
                ),
                prefixIcon: const Icon(
                  Icons.add,
                  color: Colors.black45,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.015,
                  horizontal: screenWidth * 0.04,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFf1f5f9),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    width: 2.0,
                    color: Colors.blueAccent,
                  ),
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
              ),
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.black,
              ),
            ),

            SizedBox(height: screenHeight * 0.025),

            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _finePayDateController,
              decoration: InputDecoration(
                labelText: 'Fine Pay Date (YYYY-MM-DD)',
                labelStyle: TextStyle(
                  color: Colors.black87,
                  fontSize: screenWidth * 0.037,
                ),
                prefixIcon: const Icon(
                  Icons.access_time,
                  color: Colors.black45,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.015,
                  horizontal: screenWidth * 0.04,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFf1f5f9),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    width: 2.0,
                    color: Colors.blueAccent,
                  ),
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
              ),
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.black,
              ),
            ),

            SizedBox(height: screenHeight * 0.025),
            CustomElevatedButton(
              onPressed:  _updateRecord,
              text:  'OK',
              textStyle: TextStyle(
                fontSize: screenWidth * 0.05,
                fontFamily: 'Roboto',
                color: Colors.white,
              ),
              borderRadius: screenWidth * 0.03,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }


  @override
  void dispose() {
    _fineAmtController.dispose();
    _fineExcessAmtController.dispose();
    _finePayDateController.dispose();
    _borrowDateController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }
}
