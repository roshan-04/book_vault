import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadBook extends StatefulWidget {
  const UploadBook({super.key});

  @override
  State<UploadBook> createState() => _UploadBookState();
}

class _UploadBookState extends State<UploadBook> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _availabilityController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _editionController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _publisherController = TextEditingController();

  File? _pickedImage;
  String? _imageUrl;
  String? _pdfUrl;
  bool _isLoading = false;

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No image selected")),
      );
    }
  }

  Future<String?> uploadFile(File file, String directory) async {
    try {
      setState(() {
        _isLoading = true;
      });

      String fileName = file.path.split('/').last;

      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('$directory/$fileName');

      final metadata = firebase_storage.SettableMetadata(
        contentType: directory == 'pdf' ? 'application/pdf' : 'image/png',
        customMetadata: {'picked-file-path': file.path},
      );
      firebase_storage.UploadTask uploadTask = ref.putFile(file, metadata);
      await uploadTask.whenComplete(() => null);
      return '$directory/$fileName';
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading file: $e")),
      );
      return null;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> addBookDetails() async {
    if (_pdfUrl == null || _imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please upload both PDF and Image")),
      );
      return;
    }
    CollectionReference books = FirebaseFirestore.instance.collection('book');

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    await books.doc(_isbnController.text).set({
      'title': _titleController.text,
      'authorName': _authorController.text,
      'availability': int.tryParse(_availabilityController.text) ?? 0,
      'bookimg': _imageUrl,
      'bookpdf': _pdfUrl,
      'department': _departmentController.text,
      'description': _descriptionController.text,
      'edition': _editionController.text,
      'genre': _genreController.text,
      'isbn': _isbnController.text,
      'publisherName': _publisherController.text,
    }).then((value) async {
      DocumentReference userRef = FirebaseFirestore.instance.collection('staff').doc(user.uid);
      await userRef.update({
        'booksadded': FieldValue.arrayUnion([books.doc(_isbnController.text)])
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Book details uploaded successfully")),
      );
      Navigator.pop(context, true);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload book details: $error")),
      );
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
          "Upload Book",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade500, Colors.blue.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              ListView(
                children: [
                  _buildTextField(_titleController, "Title"),
                  SizedBox(height: 12),
                  _buildTextField(_authorController, "Author Name"),
                  SizedBox(height: 12),
                  _buildTextField(_availabilityController, "Availability", inputType: TextInputType.number),
                  SizedBox(height: 12),
                  _buildTextField(_departmentController, "Department"),
                  SizedBox(height: 12),
                  _buildTextField(_descriptionController, "Description"),
                  SizedBox(height: 12),
                  _buildTextField(_editionController, "Edition"),
                  SizedBox(height: 12),
                  _buildTextField(_genreController, "Genre"),
                  SizedBox(height: 12),
                  _buildTextField(_isbnController, "ISBN"),
                  SizedBox(height: 12),
                  _buildTextField(_publisherController, "Publisher Name"),
                  SizedBox(height: 17),
                  _buildElevatedButton("Select Image", pickImage),
                  SizedBox(height: 17),
                  _buildElevatedButton("Select PDF", () async {
                    final path = await FlutterDocumentPicker.openDocument();
                    if (path != null) {
                      File file = File(path);
                      String? pdfUrl = await uploadFile(file, 'pdf');
                      setState(() {
                        _pdfUrl = pdfUrl;
                      });
                    }
                  }),
                  SizedBox(height: 17),
                  _buildElevatedButton("Upload Book Details", () async {
                    if (_pickedImage != null) {
                      String? imageUrl = await uploadFile(_pickedImage!, 'bookimgs');
                      setState(() {
                        _imageUrl = imageUrl;
                      });
                    }
                    await addBookDetails();
                  }),
                ],
              ),
              if (_isLoading)
                Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.blue.shade400),
        ),
      ),
      style: TextStyle(color: Colors.white),
    );
  }

  Widget _buildElevatedButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(vertical: 15),
      ),
      child: Text(text, style: TextStyle(color: Colors.white)),
    );
  }
}
