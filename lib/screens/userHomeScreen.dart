import 'package:flutter/material.dart';
import 'package:book_vault/constants/colors.dart';
import '../widgets/myDrawerHeader.dart';
import 'borrowedBooks.dart';
import 'profileScreen.dart';
import 'package:book_vault/screens/logInScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'favouritesScreen.dart';
import 'search.dart';
import 'categoryBooksScreen.dart';

class UserHomeScreen extends StatefulWidget {
  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String name = '';

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('student')
            .doc(user.uid) // or use 'prNo' if stored separately
            .get();

        if (userData.exists) {
          setState(() {
            // Update the name and borrowedBooks list
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
    _fetchUserData(); // Fetch user data when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(context),
      appBar: CustomAppbar(context,_scaffoldKey),
      body:
          SafeArea(
            child: GreetingCard(screenWidth,name),
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
                          builder: (context) => ProfileScreen(),
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
                            builder: (context) => BorrowedBooksScreen(),
                          ),
                        );
                      },
                      leading: Icon(Icons.add_card, color: Colors.white),
                      title: Text(
                        "Borrowed",
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
                            builder: (context) => FavouritesScreen(),
                          ),
                        );
                      },
                      leading: Icon(Icons.favorite, color: Colors.white),
                      title: Text(
                        "Favourites",
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


PreferredSizeWidget CustomAppbar(BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
  return AppBar(
    backgroundColor: kblue_2,

    leading: IconButton(
        icon: Icon(Icons.menu, color: kwhite, size: 30,),
        onPressed: () {
          scaffoldKey.currentState!.openDrawer();
        },
    ),
      actions: <Widget>[
        IconButton(
            icon: Icon(Icons.search, color: kwhite,size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookSearchScreen(),
                ),
              );
            },
        ),
      ]
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
            'Categories',
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

Widget CustomLayoutBuilder() {
  return LayoutBuilder(
    builder: (context, constraints) {
      int crossAxisCount = 2;
      if (constraints.maxWidth > 600 && constraints.maxWidth < 900) {
        crossAxisCount = 3;
      } else if (constraints.maxWidth >= 900) {
        crossAxisCount = 4;
      }

      return GridView.count(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          CategoryCard(
            title: 'MECH',
            booksCount: 16,
            iconPath: 'assets/images/mechdept.png',
          ),
          CategoryCard(
            title: 'COMP',
            booksCount: 22,
            iconPath: 'assets/images/compdept.png',
          ),
          CategoryCard(
            title: 'CIVIL',
            booksCount: 10,
            iconPath: 'assets/images/civildept.png',
          ),
          CategoryCard(
            title: 'ENE',
            booksCount: 18,
            iconPath: 'assets/images/enedept.png',
          ),
          CategoryCard(
            title: 'ETC',
            booksCount: 18,
            iconPath: 'assets/images/etcdept.png',
          ),
          CategoryCard(
            title: 'IT',
            booksCount: 10,
            iconPath: 'assets/images/ITdept.png',
          ),
          CategoryCard(
            title: 'MINING',
            booksCount: 18,
            iconPath: 'assets/images/miningdept.png',
          ),
          CategoryCard(
            title: 'SCI',
            booksCount: 18,
            iconPath: 'assets/images/scidept.png',
          ),
        ],
      );
    },
  );
}

class CategoryCard extends StatelessWidget {
  final String title;
  final int booksCount;
  final String iconPath;

  const CategoryCard({
    Key? key,
    required this.title,
    required this.booksCount,
    required this.iconPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;

    return GestureDetector(
      onTap: () {
        // Navigate to a new screen to display books of the selected category
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryBooksScreen(department: title),
          ),
        );
      },
      child: Card(
        color: kblue_3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
        ),
        child: Padding(
          padding: EdgeInsets.all(orientation == Orientation.landscape
              ? screenWidth * 0.001
              : screenWidth * 0.01), // Reduce padding to prevent overflow
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenWidth * 0.02),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth / 30),
                  child: Container(
                    height: screenWidth * 0.5, // Reduce image size for better fit
                    width: screenWidth * 0.5,
                    child: ClipRRect(
                      borderRadius:
                      BorderRadius.circular(screenWidth * 0.02), // Adjust this value for the roundness of corners
                      child: Image.asset(
                        iconPath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenWidth * 0.007), // Adjust spacing
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: orientation == Orientation.landscape
                      ? screenWidth * 0.025
                      : screenWidth * 0.045, // Adjust text size for fit
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis, // Prevent overflow
                ),
              ),
              SizedBox(height: screenWidth * 0.005),
              Text(
                '$booksCount books',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: orientation == Orientation.landscape
                      ? screenWidth * 0.023
                      : screenWidth * 0.036, // Adjust text size for fit
                  overflow: TextOverflow.ellipsis, // Prevent overflow
                ),
              ),
              SizedBox(height: screenWidth * 0.01),
            ],
          ),
        ),
      ),
    );
  }
}
