import 'package:book_vault/screens/book_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:book_vault/constants/colors.dart';
import '../widgets/myDrawerHeader.dart';
import 'adminProfileScreen.dart';
import 'addBook.dart';
import 'notice.dart';
import 'removeBook.dart';
import 'logInScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'adminRecordsManagement.dart';

class AdminHomeScreen extends StatefulWidget {
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreen();
}

class _AdminHomeScreen extends State<AdminHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> books = [];
  String name = '';

  Future<void> _fetchStaffData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('staff')
            .doc(user.uid) // or use 'prNo' if stored separately
            .get();

        if (userData.exists) {
          String? imageUrl;
          String? bookTitle;
          List<Map<String, dynamic>> fetchedBooks = [];

          // Assuming 'booksadded' is a list of document references in Firestore
          for (var bookRef in userData['booksadded']) {
            final bookDoc = await bookRef.get(); // Get the book document
            if (bookDoc.exists) {
              imageUrl = await FirebaseStorage.instance
                  .ref(bookDoc['bookimg']) // Get image URL from Firebase Storage
                  .getDownloadURL();

              bookTitle = bookDoc['title']; // Get book title from the document

              fetchedBooks.add({
                'title': bookTitle,
                'imageUrl': imageUrl,
              });
            }
          }

          setState(() {
            books = fetchedBooks;
            name = "${userData['firstName']} ${userData['lastName']}";
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      // Handle error, show a message if necessary
    }
  }


  @override
  void initState() {
    super.initState();
    _fetchStaffData(); // Fetch user data when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(context),
      appBar: CustomAppbar(_scaffoldKey),
      body:
      SafeArea(
        child: GreetingCard(screenWidth,name),
      ),
    );
  }



  Widget CustomLayoutBuilder() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2; // Default for smaller screens
        if (constraints.maxWidth > 600 && constraints.maxWidth < 900) {
          crossAxisCount = 3; // Medium screens
        } else if (constraints.maxWidth >= 900) {
          crossAxisCount = 4; // Large screens
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 5,
          ),
          itemCount: books.length, // Number of cards = number of books
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(), // Prevent scroll issues
          itemBuilder: (context, index) {
            return BookCard(
                title: books[index]['title'], // Book title
                imageUrl: books[index]['imageUrl'], // Book image URL
            );
          },
        );
      },
    );
  }


  Widget GreetingCard(double screenWidth, String name) {
    return SingleChildScrollView(

      padding: EdgeInsets.all( screenWidth * 0.06 ),
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
                      'Namaste\n'+name,
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
                          fit: BoxFit.cover
                      ),
                    )
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.06),
          Padding(
            padding: EdgeInsets.only(left: screenWidth*0.01),
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
        color: Colors.blue[300], // Adjust color as needed
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.04)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical:screenWidth * 0.02, horizontal: screenWidth * 0.025), // Adjust padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(screenWidth * 0.02), // Rounded image corners
                  child: Image.network(
                    imageUrl, // Load image from URL
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: screenWidth * 0.3,
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
                      : screenWidth * 0.04, // Adjust text size
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis, // Prevent overflow
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

    );
  }
}


Widget CustomDrawer (BuildContext context) {
  return Drawer(
    child: SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            MyHeaderDrawer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8,vertical: 10),
              child:Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.blue,
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminProfileScreen(),
                      ),
                    );
                  },
                  leading: Icon(Icons.person, color: Colors.white),
                  title: Text(
                    "Profile",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8,vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color:Colors.blue,
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddBook(),
                      ),
                    );
                  },
                  leading: Icon(Icons.add_card, color: Colors.white),
                  title: Text(
                    "Add Book",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8,vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color:Colors.blue,
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RemoveBook(),
                      ),
                    );
                  },
                  leading: Icon(Icons.account_balance_wallet_rounded, color: Colors.white),
                  title: Text(
                    "Remove Book",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8,vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color:  Colors.blue,
                ),
                child: ListTile(
                  leading: Icon(Icons.settings, color: Colors.white),
                  title: Text(
                    "Settings",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8,vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color:Colors.blue,
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Notice(),
                      ),
                    );
                  },
                  leading: Icon(Icons.file_copy, color: Colors.white),
                  title: Text(
                    "Notice",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8,vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color:Colors.blue,
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminBorrowedBooksScreen(),
                      ),
                    );
                  },
                  leading: Icon(Icons.file_copy_outlined, color: Colors.white),
                  title: Text(
                    "Records",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8,vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color:  Colors.blue,
                ),
                child: ListTile(
                  leading: Icon(Icons.logout,color: Colors.white),
                  title: Text(
                    "Log Out",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LogInScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


PreferredSizeWidget CustomAppbar(GlobalKey<ScaffoldState> scaffoldKey) {
  return AppBar(
      backgroundColor: kblue_2,

      leading: IconButton(
        icon: Icon(Icons.menu, color: kwhite, size: 30,),
        onPressed: () {
          scaffoldKey.currentState!.openDrawer();
        },
      ),
  );
}
