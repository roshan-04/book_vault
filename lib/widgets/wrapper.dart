import 'package:book_vault/screens/welcomeScreen.dart';
import 'package:book_vault/screens/userHomeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:book_vault/screens/adminHomeScreen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Error"),
            );
          } else {
            if (snapshot.data == null) {
              return const WelcomeScreen();
            } else {
              // Check the UID
              User? user = snapshot.data;
              if (user?.uid == "3u6dRZrnMcNXDWwojFht1CXuYv12") {
                return AdminHomeScreen(); // Navigate to AdminHomeScreen if the UID matches
              } else {
                return UserHomeScreen(); // Otherwise, go to UserHomeScreen
              }
            }
          }
        },
      ),
    );
  }
}
