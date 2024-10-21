import 'package:flutter/material.dart';
import 'package:book_vault/constants/colors.dart';
import '../widgets/myDrawerHeader.dart';
import 'adminProfileScreen.dart';
import 'notice.dart';
import 'removeBook.dart';
import 'logInScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'UploadPdf.dart';

class AdminHomeScreen extends StatefulWidget {
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String name = '';

  Stream<List<Map<String, dynamic>>> _fetchStaffData() async* {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('staff')
          .doc(user.uid)
          .snapshots()
          .listen((doc) async* {
        List<Map<String, dynamic>> fetchedBooks = [];

        if (doc.exists) {
          for (var bookRef in doc['booksadded']) {
            final bookDoc = await bookRef.get();
            if (bookDoc.exists) {
              String? imageUrl;
              String? bookTitle = bookDoc['title'];
              try {
                imageUrl = await FirebaseStorage.instance
                    .ref(bookDoc['bookimg'])
                    .getDownloadURL();
              } catch (e) {
                imageUrl = null;
              }
              fetchedBooks.add({
                'title': bookTitle,
                'imageUrl': imageUrl ?? '',
              });
            }
          }
          yield fetchedBooks;
          setState(() {
            name = "${doc['firstName']} ${doc['lastName']}";
          });
        }
      });
    } else {
      yield [];
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(context),
      appBar: CustomAppbar(_scaffoldKey),
      body: SafeArea(
        child: GreetingCard(screenWidth, name),
      ),
    );
  }

  Widget CustomLayoutBuilder() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _fetchStaffData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading books'));
        }

        List<Map<String, dynamic>> books = snapshot.data ?? [];

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _calculateCrossAxisCount(MediaQuery.of(context).size.width),
            crossAxisSpacing: 10,
            mainAxisSpacing: 5,
          ),
          itemCount: books.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return BookCard(
              title: books[index]['title'],
              imageUrl: books[index]['imageUrl'],
            );
          },
        );
      },
    );
  }

  int _calculateCrossAxisCount(double screenWidth) {
    if (screenWidth > 600 && screenWidth < 900) {
      return 3;
    } else if (screenWidth >= 900) {
      return 4;
    } else {
      return 2;
    }
  }

  Widget GreetingCard(double screenWidth, String name) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(screenWidth * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenWidth * 0.01),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Namaste\n' + name,
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.03),
                    Text(
                      'Welcome to Your Library\nExplore, and borrow books!',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: ClipRRect(
                  child: Container(
                    height: screenWidth * 0.3,
                    child: Image.asset(
                      'assets/images/userHomepage.png',
                      height: screenWidth * 0.2,
                      width: screenWidth * 0.2,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.06),
          Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.01),
            child: Text(
              'Books Added',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 16),
          CustomLayoutBuilder(),
        ],
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  const BookCard({
    Key? key,
    required this.title,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;

    return Card(
      color: Colors.blue[300],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.04)),
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: screenWidth * 0.02, horizontal: screenWidth * 0.025),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: screenWidth * 0.3,
                      )
                    : Icon(
                        Icons.broken_image,
                        size: screenWidth * 0.3,
                        color: Colors.white,
                      ),
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: orientation == Orientation.landscape
                    ? screenWidth * 0.03
                    : screenWidth * 0.04,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

Widget CustomDrawer(BuildContext context) {
  return Drawer(
    child: SingleChildScrollView(
      child: Column(
        children: [
          MyHeaderDrawer(),
          buildDrawerItem(context, AdminProfileScreen(), Icons.person, "Profile"),
          buildDrawerItem(context, UploadBook(), Icons.add_card, "Upload Book"),
          buildDrawerItem(context, RemoveBook(), Icons.account_balance_wallet_rounded, "Remove Book"),
          buildDrawerItem(context, Notice(), Icons.file_copy, "Notice"),
          buildDrawerItem(context, LogInScreen(), Icons.logout, "Log Out", logout: true),
        ],
      ),
    ),
  );
}

Widget buildDrawerItem(BuildContext context, Widget destination, IconData icon, String title, {bool logout = false}) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colors.blue,
      ),
      child: ListTile(
        onTap: () async {
          if (logout) {
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => destination),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destination),
            );
          }
        },
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
}

PreferredSizeWidget CustomAppbar(GlobalKey<ScaffoldState> scaffoldKey) {
  return AppBar(
    backgroundColor: kblue_2,
    leading: IconButton(
      icon: Icon(Icons.menu, color: kwhite, size: 30),
      onPressed: () {
        scaffoldKey.currentState!.openDrawer();
      },
    ),
    actions: <Widget>[
      IconButton(
        icon: Icon(Icons.search, color: kwhite, size: 30),
        onPressed: () {
          // Search action
        },
      ),
    ],
  );
}