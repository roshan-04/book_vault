import 'package:book_vault/widgets/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");
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


// import 'package:book_vault/screens/userHomeScreen.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// import 'package:firebase_core/firebase_core.dart';

// import 'package:book_vault/screens/welcomeScreen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   if(kIsWeb) {
//     await Firebase.initializeApp(options: FirebaseOptions(
//         apiKey: "AIzaSyCGl9uHngFZE6sBAof7pZjdFTFqa4uhRAI",
//         authDomain: "book-vault-29cd7.firebaseapp.com",
//         projectId: "book-vault-29cd7",
//         storageBucket: "book-vault-29cd7.appspot.com",
//         messagingSenderId: "517870828399",
//         appId: "1:517870828399:web:2a0eeac2c929c1a5fb869a"
//       )
//     );
//   } else {
//     Firebase.initializeApp();
//   }
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: "BookVault",
//       home: UserHomeScreen(),
//     );
//   }
// }


