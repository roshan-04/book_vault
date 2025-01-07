import 'package:book_vault/widgets/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart'; // Import Firebase App Check
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");

    // Initialize Firebase App Check with Debug provider for development
    FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug, // Use Debug provider for Android
      appleProvider: AppleProvider.debug,     // Use Debug provider for iOS
    );

    print("Firebase App Check initialized successfully");

  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "BookVault",
      home: Wrapper(),
    );
  }
}
