
import 'package:book_vault/constants/colors.dart';
import 'package:book_vault/screens/adminHomeScreen.dart';
import 'package:book_vault/widgets/customTextform.dart';
import 'package:book_vault/widgets/elevatedButton.dart';
import 'package:book_vault/widgets/portrait_mode_wrapper.dart';
import 'package:book_vault/widgets/customBookVaultSvg.dart';
import 'package:book_vault/auth/auth_service.dart';
import 'package:book_vault/screens/userHomeScreen.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:book_vault/screens/signUpScreen.dart';
import 'package:book_vault/screens/forgotPassword.dart';
import 'package:cloud_firestore/cloud_firestore.dart';




class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LogInScreen> {

  final AuthService _auth = AuthService();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;

  void goToSignup(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SignUpScreen()),
  );

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ForgotPasswordScreen(),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Login Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        );
      },
    );
  }

  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return "Please enter an Email";
    }
    RegExp emailRegex = RegExp(r'^[\w\.-]+@[\w-]+\.\w{2,3}(\.\w{2,3})?$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return "Enter Password";
    }
    return null;
  }

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog("Please fill all fields.");
      return;
    }

    if (!_isValidEmail(email) || !email.endsWith("@gec.ac.in")) {
      _showErrorDialog("Please enter a valid email address.");
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      final user = await _auth.loginUserWithEmailAndPassword(email, password);

      if (user != null) {
        log("User Logged In");

        // Check if the user exists in the "student" collection
        final firestore = FirebaseFirestore.instance;
        final studentDoc = await firestore.collection('student').doc(user.uid).get();
        final staffDoc = await firestore.collection('staff').doc(user.uid).get();

        if (studentDoc.exists) {
          // User is a student
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login Successful! Welcome Student.')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UserHomeScreen()),
          );
        } else if (staffDoc.exists) {
          // User is staff
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login Successful! Welcome Staff.')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminHomeScreen()),
          );
        } else {
          // User is not found in either collection
          _showErrorDialog("User not found in the system.");
        }
      } else {
        // Handle the case where user is null after login attempt
        _showErrorDialog("Password or Email entered is incorrect.");
      }
    } catch (e) {
      log("Login error: ${e.toString()}");
      _showErrorDialog("An unexpected error occurred: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator in case of error too
      });
    }
  }


  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return PortraitModeWrapper(
      child: SafeArea(
      child: Scaffold(
        body: OrientationBuilder(
          builder: (context, orientation) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: screenHeight,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          height: screenHeight,
                          width: screenWidth,
                          color: kwhite,
                          child: CustomBookVaultWidget(
                            padding: EdgeInsets.only(top: screenHeight * 0.067),
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            imagePath: 'assets/images/BookVault-1.svg',
                            text: "Your gateway to Literary Treasures",
                            svgcolour: kblack,
                          ),
                        ),
                        Positioned(
                          top: screenHeight * 0.40,
                          child: Container(
                            height: screenHeight * 0.65,
                            width: screenWidth,
                            decoration: BoxDecoration(
                              color: kblue_2,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular( screenWidth * 0.16 ),
                                topRight: Radius.circular(screenWidth * 0.16),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only( top: screenHeight * 0.08 ),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [

                                      CustomTextFormField(
                                        controller: _emailController,
                                        hintText: 'Email',
                                        validator: _validateEmail,
                                        keyboardType: TextInputType.emailAddress,
                                        fillColor: kwhite,
                                        screenWidth: screenWidth,
                                        screenHeight: screenHeight,
                                        contentPadding: EdgeInsets.fromLTRB(
                                          screenWidth * 0.05,
                                          screenWidth * 0.04,
                                          0.0,
                                          screenWidth * 0.057,
                                        ),
                                        hintStyle: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        errorStyle: TextStyle(
                                          fontSize: screenHeight / 68,
                                          height: screenHeight / 1000,
                                          color: kwhite, // or any other color
                                        ),
                                        widthfactor: 0.8,
                                        heightfactor: 0.09,
                                        borderRadius: screenWidth/10,
                                      ),

                                    SizedBox(height: screenHeight * 0.02 ),

                                    CustomTextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscureText,
                                      screenWidth: screenWidth,
                                      screenHeight: screenHeight,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      validator: _validatePassword,
                                      contentPadding: EdgeInsets.fromLTRB(
                                        screenWidth * 0.05,
                                        screenWidth * 0.04,
                                        screenWidth / 10,
                                        screenWidth * 0.057,
                                      ),
                                      fillColor: kwhite,
                                      hintText: 'Password',
                                      hintStyle: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: screenWidth * 0.04,
                                      ),
                                      suffixIcon: IconButton(
                                          icon: Icon(
                                             color: kdarkblue,
                                            _obscureText ? Icons.visibility_off : Icons.visibility,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscureText = !_obscureText;
                                            });
                                          },
                                      ),
                                      errorStyle: TextStyle(
                                          fontSize: screenHeight / 68,
                                          height: screenHeight / 1000,
                                          color: kwhite
                                      ),
                                      widthfactor: 0.8,
                                      heightfactor: 0.09,
                                      borderRadius: screenWidth/10,
                                    ),

                                    SizedBox(height: screenHeight * 0.02 ),

                                    _isLoading
                                        ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(kdarkblue),
                                    ) // Show loading indicator
                                        : CustomElevatedButton(
                                      onPressed: _login,
                                      backgroundColor: kblack,
                                      foregroundColor: kwhite,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.004,
                                        vertical: screenHeight * 0.005,
                                      ),
                                      borderRadius: screenWidth /10,
                                      text: 'Log In',
                                      textStyle: TextStyle(
                                        fontSize: screenWidth * 0.045,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      height: screenHeight * 0.07,
                                      width: screenWidth * 0.8,
                                    ),

                                    SizedBox(height:screenHeight * 0.02 ),

                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: EdgeInsets.only(right: screenWidth/10),
                                        child: InkWell(
                                          onTap: () => _showForgotPasswordDialog(context),
                                          child: Text(
                                            'Forgot Password?',
                                            style: TextStyle(
                                              color: kwhite,
                                              fontSize: screenWidth * 0.04 ,
                                              fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height:screenHeight * 0.08 ),

                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "  Don't have an account? ",
                                            style: TextStyle(
                                              color: kwhite,
                                              fontSize:  screenWidth * 0.04 ,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () => goToSignup(context),
                                            child: Text(
                                              'Sign Up',
                                              style: TextStyle(
                                                color: kwhite,
                                                fontSize:  screenWidth * 0.04 ,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    )
    );
  }
}
