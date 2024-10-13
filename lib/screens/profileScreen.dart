import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String firstName = '';
  String lastName = '';
  String email = '';
  String prNumber = '';
  String mobileNumber = '';
  String department = '';
  String rollno = '';

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('student')
            .doc(user.uid)
            .get();

        if (userData.exists) {
          setState(() {
            firstName = "${userData['firstName']}";
            lastName = "${userData['lastName']}";
            email = "${userData['email']}";
            prNumber = "${userData['prNo']}";
            mobileNumber = "${userData['mobile']}";
            department = "${userData['dept']}";
            rollno = "${userData['rollNo']}";
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          "${firstName}'s Profile",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        // Add a gradient background
        decoration: BoxDecoration(
          color:  Colors.blueAccent,
        ),
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.025),
              child: Center(
                child: Container(
                  height: screenWidth * 0.55,
                  width: screenWidth * 0.65,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15,
                        offset: Offset(0, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(screenWidth * 0.08)),
                    image: DecorationImage(
                      image: AssetImage('assets/images/profile2.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            _buildProfileField('First Name', firstName, textScaleFactor),
            SizedBox(height: screenHeight * 0.02),
            _buildProfileField('Last Name', lastName, textScaleFactor),
            SizedBox(height: screenHeight * 0.02),
            _buildProfileField('Email', email, textScaleFactor),
            SizedBox(height: screenHeight * 0.02),
            _buildProfileField('Department', department, textScaleFactor),
            SizedBox(height: screenHeight * 0.02),
            _buildProfileField('Roll No', rollno, textScaleFactor),
            SizedBox(height: screenHeight * 0.02),
            _buildProfileField('PR Number', prNumber, textScaleFactor),
            SizedBox(height: screenHeight * 0.02),
            _buildProfileField('Mobile Number', mobileNumber, textScaleFactor),
            SizedBox(height: screenHeight * 0.03),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value, double textScaleFactor) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16 * textScaleFactor,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18 * textScaleFactor,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
