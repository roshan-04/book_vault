import 'package:flutter/material.dart';
import 'package:book_vault/auth/auth_service.dart';
import 'package:book_vault/constants/colors.dart';
import 'package:book_vault/widgets/elevatedButton.dart';
import 'package:book_vault/widgets/forgotPasswordSvg.dart';
import 'package:book_vault/widgets/customTextform.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  final _auth = AuthService();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _next() async {
    if (_email.text.isNotEmpty) {
      try {
        await _auth.sendPasswordResetEmail(_email.text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An email to reset your password has been sent.")),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send email: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address.")),
      );
    }
  }

  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return "Please enter an Email";
    }
    // Updated regular expression to allow alphanumeric characters, dots, and hyphens in local part
    RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._-]+@gec\.ac\.in$');
    // Check if the email matches the required pattern
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email.';
    }
    return null;
  }


  //If the above _validateEmail doesnt work then try below one
  // String? _validateEmail(String? email) {
  //   if (email == null || email.isEmpty ) {
  //     return "Please enter an Email";
  //   }
  //   RegExp emailRegex = RegExp(r'^[\w\.-]+@[\w-]+\.\w{2,3}(\.\w{2,3})?$');
  //   if (!emailRegex.hasMatch(email)) {
  //     return 'Please enter a valid email';
  //   }
  //   return null;
  // }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: kwhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: screenWidth,
                  height: screenHeight / 11,
                  decoration: BoxDecoration(
                    color: kblue_2,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(screenWidth / 5),
                        bottomRight: Radius.circular(screenWidth / 5)
                    )
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),

                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: screenHeight * 0.711,
                    width: screenWidth * 0.85,
                    decoration: BoxDecoration(
                      color: kblue_2, // Background color
                      borderRadius: BorderRadius.circular(screenWidth * 0.13),// Rounded corners
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        SizedBox(height: screenHeight * 0.1),

                        Forgotpasswordsvg(
                                  imagePath: "assets/images/Padlock.svg",
                                  text1: "Forgot Password",
                                  text2: "Enter your registered email",
                                  screenwidth: screenWidth,
                                  screenheight: screenHeight,
                                  svgcolour: kwhite,
                            ),

                        SizedBox(height: screenHeight * 0.065),

                        CustomTextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: _validateEmail,
                          hintText: "Email",
                          hintStyle: TextStyle(
                            color: Colors.black54,
                            fontSize: screenWidth / 24,
                          ),
                          icon: const Icon(
                            Icons.email,
                            color: Colors.black45,
                          ),

                          contentPadding: EdgeInsets.fromLTRB(
                            screenWidth * 0.04,
                            screenHeight * 0.02,
                            screenWidth * 0.04,
                            screenHeight * 0.02,
                          ),

                          borderRadius: screenWidth/10,
                          fillColor: kwhite,
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                          errorStyle: TextStyle(
                              fontSize: screenHeight / 67,
                              height: screenHeight / 1000,
                              color: kwhite // or any other color
                          ),
                          heightfactor: 0.09,
                          widthfactor: 0.72,
                        ),

                        SizedBox(height: screenHeight * 0.015),

                        CustomElevatedButton(
                          onPressed: _next,
                          backgroundColor: kdarkblue,
                          text: "Next",
                          foregroundColor: kwhite,
                          borderRadius: screenWidth * 0.13,
                          width: screenWidth * 0.72,
                          height: screenHeight * 0.075,
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.043,
                            color: kwhite,
                          ),
                        ),
                    ]
                  ),
                 ),
                ),

                SizedBox(height: screenHeight * 0.04),

                Container(
                  width: screenWidth,
                  height: screenHeight / 11,
                  decoration: BoxDecoration(
                      color: kblue_2,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(screenWidth / 5),
                          topRight: Radius.circular(screenWidth / 5)
                      )
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }
}
