import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:book_vault/auth/auth_service.dart';
import 'userHomeScreen.dart';
import 'dart:developer';
import 'logInScreen.dart';
import 'adminHomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = AuthService();
  bool _isLoading = false;
  bool _isObscurePassword = true;
  bool _isObscureConfirmPassword = true;
  String? _password;
  String? _selectedDepartment;
  String? _selectedUserType;
  bool _showForm = false;

  final _fname = TextEditingController();
  final _lname = TextEditingController();
  final _email = TextEditingController();
  final _passwrd = TextEditingController();
  final _cpasswrd = TextEditingController();
  final _mobile = TextEditingController();
  final _rollno = TextEditingController();
  final _prno = TextEditingController();
  final _designation = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _fname.dispose();
    _lname.dispose();
    _email.dispose();
    _passwrd.dispose();
    _cpasswrd.dispose();
    _mobile.dispose();
    _rollno.dispose();
    _prno.dispose();
  }

  // Validators for each field
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a name';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    RegExp emailRegex = RegExp(r'^[\w\.-]+@[\w-]+\.\w{2,3}(\.\w{2,3})?$');
    if (value == null || !emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    _password = value; // Store password value
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _password) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateMobileNumber(String? value) {
    if (value == null || value.isEmpty || value.length < 10) {
      return 'Please enter a valid mobile number';
    }
    return null;
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    }
    return null;
  }

  String? _validateDepartment(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a department';
    }
    return null;
  }

  String? _validateDesignation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a department';
    }
    return null;
  }

  String? _validateUser(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a user';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Bluebox(screenWidth, screenHeight),
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: Column(
                    children: [
                      Signuptext(screenWidth, screenHeight),
                      SizedBox(height: screenHeight * 0.03),

                      // Dropdown to select between USER or STAFF
                      DropdownButtonFormField<String>(
                        value: _selectedUserType,
                        items: ['USER', 'STAFF'].map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedUserType = newValue;
                            _showForm = true;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Select User Type",
                          filled: true,
                          fillColor: const Color(0xFFf1f5f9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: _validateUser,
                      ),

                      SizedBox(height: screenHeight * 0.01),

                      // Conditional display of the form based on user type selection
                      if (_showForm)
                        _selectedUserType == 'USER'
                            ? _buildUserForm(
                                screenWidth, screenHeight) // User form
                            : _buildStaffForm(screenWidth, screenHeight),
                      // Staff form
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserForm(double screenWidth, double screenHeight) {
    return Column(
      children: [
        SizedBox(height: screenHeight * 0.03),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateName,
          controller: _fname,
          decoration: InputDecoration(
            labelText: "First Name",
            labelStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
            prefixIcon: const Icon(
              Icons.person,
              color: Colors.black45,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.015,
              horizontal: screenWidth * 0.04,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFf1f5f9),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                width: 2.0,
                color: Colors.blueAccent,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateName,
          controller: _lname,
          decoration: InputDecoration(
            labelText: "Last Name",
            labelStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
            prefixIcon: const Icon(
              Icons.person,
              color: Colors.black45,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.015,
              horizontal: screenWidth * 0.04,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFf1f5f9),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                width: 2.0,
                color: Colors.blueAccent,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateEmail,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: "Email",
            labelStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
            prefixIcon: const Icon(
              Icons.email,
              color: Colors.black45,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.015,
              horizontal: screenWidth * 0.04,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFf1f5f9),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                width: 2.0,
                color: Colors.blueAccent,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                width: 2.0,
                color: Colors.redAccent,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validatePassword,
          controller: _passwrd,
          obscureText: _isObscurePassword,
          decoration: InputDecoration(
            labelText: "Password",
            labelStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
            prefixIcon: const Icon(
              Icons.lock,
              color: Colors.black45,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isObscurePassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.black45,
              ),
              onPressed: () {
                setState(() {
                  _isObscurePassword = !_isObscurePassword;
                });
              },
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.015,
              horizontal: screenWidth * 0.04,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFf1f5f9),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                width: 2.0,
                color: Colors.blueAccent,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateConfirmPassword,
          controller: _cpasswrd,
          obscureText: _isObscureConfirmPassword,
          decoration: InputDecoration(
            labelText: "Confirm Password",
            labelStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
            prefixIcon: const Icon(
              Icons.lock,
              color: Colors.black45,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isObscureConfirmPassword
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: Colors.black45,
              ),
              onPressed: () {
                setState(() {
                  _isObscureConfirmPassword = !_isObscureConfirmPassword;
                });
              },
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.015,
              horizontal: screenWidth * 0.04,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFf1f5f9),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                width: 2.0,
                color: Colors.blueAccent,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateMobileNumber,
          controller: _mobile,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: "Mobile Number",
            labelStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
            prefixIcon: const Icon(
              Icons.phone,
              color: Colors.black45,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.015,
              horizontal: screenWidth * 0.04,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFf1f5f9),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                width: 2.0,
                color: Colors.blueAccent,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateNumber,
          controller: _rollno,
          decoration: InputDecoration(
            labelText: "Roll Number",
            labelStyle: TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.confirmation_number,
              color: Colors.black45,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.015,
              horizontal: screenWidth * 0.04,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Color(0xFFf1f5f9),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 2.0,
                color: Colors.blueAccent,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateNumber,
          controller: _prno,
          decoration: InputDecoration(
            labelText: "University PR Number",
            labelStyle: TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.card_membership,
              color: Colors.black45,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.015,
              horizontal: screenWidth * 0.04,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Color(0xFFf1f5f9),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 2.0,
                color: Colors.blueAccent,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        DropdownButtonFormField<String>(
          value: _selectedDepartment,
          validator: _validateDepartment,
          decoration: InputDecoration(
            labelText: "Department",
            labelStyle: TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.015,
              horizontal: screenWidth * 0.04,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: [
            DropdownMenuItem(value: "CSE", child: Text("Computer Engineering")),
            DropdownMenuItem(
                value: "IT", child: Text("Information Technology")),
            DropdownMenuItem(
                value: "ENE", child: Text("Electrical and Electronics")),
            DropdownMenuItem(
                value: "ETC", child: Text("Electronics and Telecommunication")),
            DropdownMenuItem(
                value: "MECH", child: Text("Mechanical Engineering")),
            DropdownMenuItem(value: "CE", child: Text("Civil Engineering")),
            DropdownMenuItem(
                value: "VLSI", child: Text("Very Large Scale Integration")),
            DropdownMenuItem(value: "MIN", child: Text("Mining Engineering")),
            DropdownMenuItem(
                value: "SCI", child: Text("Science and humanities")),
          ],
          onChanged: (value) {
            setState(() {
              _selectedDepartment = value; // Update the selected department
            });
          },
        ),
        SizedBox(height: screenHeight * 0.03),
        _isLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ) // Show loading indicator
            : Container(
                height: screenHeight * 0.06,
                width: screenWidth,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromRGBO(16, 115, 255, 1.0),
                      Color.fromRGBO(23, 212, 255, 1.0),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      BorderRadius.all(Radius.circular(screenWidth * 0.07)),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.all(0),
                  ),
                  onPressed: _signup,
                  child: Ink(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(16, 115, 255, 1.0),
                          Color.fromRGBO(23, 212, 255, 1.0),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        'Next',
                        style: TextStyle(
                          fontSize: screenWidth / 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        SizedBox(height: screenHeight * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Already have an account?",
              style: TextStyle(fontSize: 16),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LogInScreen()),
                );
              },
              child: Text(
                "Log In",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStaffForm(double screenWidth, double screenHeight) {
    return Column(
      children: [
        SizedBox(height: screenHeight * 0.03),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateName,
          controller: _fname,
          decoration: InputDecoration(
            labelText: "First Name",
            labelStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
            prefixIcon: const Icon(
              Icons.person,
              color: Colors.black45,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.015,
              horizontal: screenWidth * 0.04,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFf1f5f9),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                width: 2.0,
                color: Colors.blueAccent,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateName,
          controller: _lname,
          decoration: InputDecoration(
            labelText: "Last Name",
            labelStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
            prefixIcon: const Icon(
              Icons.person,
              color: Colors.black45,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.015,
              horizontal: screenWidth * 0.04,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFf1f5f9),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                width: 2.0,
                color: Colors.blueAccent,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateEmail,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: "Email",
            labelStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
            prefixIcon: const Icon(
              Icons.email,
              color: Colors.black45,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.015,
              horizontal: screenWidth * 0.04,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFf1f5f9),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                width: 2.0,
                color: Colors.blueAccent,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                width: 2.0,
                color: Colors.redAccent,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validatePassword,
          controller: _passwrd,
          obscureText: _isObscurePassword,
          decoration: InputDecoration(
            labelText: "Password",
            labelStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
            prefixIcon: const Icon(
              Icons.lock,
              color: Colors.black45,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isObscurePassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.black45,
              ),
              onPressed: () {
                setState(() {
                  _isObscurePassword = !_isObscurePassword;
                });
              },
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.015,
              horizontal: screenWidth * 0.04,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFf1f5f9),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                width: 2.0,
                color: Colors.blueAccent,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateConfirmPassword,
          controller: _cpasswrd,
          obscureText: _isObscureConfirmPassword,
          decoration: InputDecoration(
            labelText: "Confirm Password",
            labelStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
            prefixIcon: const Icon(
              Icons.lock,
              color: Colors.black45,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isObscureConfirmPassword
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: Colors.black45,
              ),
              onPressed: () {
                setState(() {
                  _isObscureConfirmPassword = !_isObscureConfirmPassword;
                });
              },
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.015,
              horizontal: screenWidth * 0.04,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFf1f5f9),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                width: 2.0,
                color: Colors.blueAccent,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateMobileNumber,
          controller: _mobile,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: "Mobile Number",
            labelStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
            prefixIcon: const Icon(
              Icons.phone,
              color: Colors.black45,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.015,
              horizontal: screenWidth * 0.04,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFf1f5f9),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                width: 2.0,
                color: Colors.blueAccent,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateDesignation,
          controller: _designation,
          decoration: InputDecoration(
            labelText: "Designation",
            labelStyle: TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.confirmation_number,
              color: Colors.black45,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.015,
              horizontal: screenWidth * 0.04,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Color(0xFFf1f5f9),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 2.0,
                color: Colors.blueAccent,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        _isLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ) // Show loading indicator
            : Container(
                height: screenHeight * 0.06,
                width: screenWidth,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromRGBO(16, 115, 255, 1.0),
                      Color.fromRGBO(23, 212, 255, 1.0),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      BorderRadius.all(Radius.circular(screenWidth * 0.07)),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.all(0),
                  ),
                  onPressed: _signup,
                  child: Ink(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(16, 115, 255, 1.0),
                          Color.fromRGBO(23, 212, 255, 1.0),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        'Next',
                        style: TextStyle(
                          fontSize: screenWidth / 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        SizedBox(height: screenHeight * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Already have an account?",
              style: TextStyle(fontSize: 16),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LogInScreen()),
                );
              },
              child: Text(
                "Log In",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  goToLogin(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LogInScreen()),
      );

  goToHome(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserHomeScreen()),
      );

  goToStaff(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminHomeScreen()),
      );

  _signup() async {
    final email = _email.text.trim();
    final password = _passwrd.text.trim();
    final fname = _fname.text.trim();
    final lname = _lname.text.trim();
    final mobile = _mobile.text.trim();
    final rollno = _rollno.text.trim();
    final prno = _prno.text.trim();
    final dept = _selectedDepartment;
    final desig = _designation.text.trim();

    if (fname.isEmpty || email.isEmpty || password.isEmpty) {
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
      final user = await _auth.createUserWithEmailAndPassword(email, password);

      setState(() {
        _isLoading = false; // Hide loading indicator
      });

      if (user != null) {
        log("User Created Successfully");

        final firestore = FirebaseFirestore.instance;

        if (_selectedUserType.toString() == 'USER') {
          await firestore.collection('student').doc(user.uid).set({
            'firstName': fname,
            'lastName': lname,
            'email': email,
            'mobile': mobile,
            'rollNo': rollno,
            'prNo': prno,
            'dept': dept,
            'password': password,
            'createdAt': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Signup Successful!')), // Success message
          );

          goToHome(context);
        }

        if (_selectedUserType.toString() == 'STAFF') {
          await firestore.collection('staff').doc(user.uid).set({
            'firstName': fname,
            'lastName': lname,
            'email': email,
            'mobile': mobile,
            'password': password,
            'designation': desig,
            'createdAt': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signup Successful!')),
          );
          goToStaff(context);
        }
      } else {
        _showErrorDialog("Signup failed. Please try again.");
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });

      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          _showErrorDialog("The email address is already in use.");
        } else if (e.code == 'weak-password') {
          _showErrorDialog("The password provided is too weak.");
        } else if (e.code == 'invalid-email') {
          _showErrorDialog("The email address is not valid.");
        } else {
          _showErrorDialog("Signup failed: ${e.message}");
        }
      } else {
        _showErrorDialog("An unexpected error occurred. Please try again.");
      }
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Signup Error"),
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
}

Widget Bluebox(double screenWidth, double screenHeight) {
  return Container(
      width: screenWidth,
      height: screenHeight / 2.3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(screenWidth / 10),
            bottomRight: Radius.circular(screenWidth / 10)),
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(16, 115, 255, 1.0),
            Color.fromRGBO(23, 212, 255, 1.0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
            top: screenHeight / 40,
            bottom: screenHeight / 35,
            left: screenWidth / 30,
            right: screenWidth / 30),
        child: Signupimage(screenWidth, screenHeight),
      ));
}

Widget Signupimage(double screenWidth, double screenHeight) {
  return ClipRRect(
    borderRadius: BorderRadius.all(Radius.circular(screenWidth / 10)),
    child: Image.asset(
      "assets/images/creadentailImages/signup.jpeg",
      height: screenHeight * 0.4,
      width: screenWidth * 0.4,
      fit: BoxFit.cover,
    ),
  );
}

Widget Signuptext(double screenWidth, double screenHeight) {
  return Column(
    children: [
      SizedBox(height: screenHeight * 0.001),
      Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.04),
          child: Text(
            "Sign Up",
            style: TextStyle(
              color: Colors.black,
              fontSize: screenWidth / 15.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      SizedBox(height: screenHeight * 0.013),
      Text(
        "Fill in the details below to create an account.",
        style: TextStyle(
          color: Colors.black54,
          fontSize: screenWidth / 24,
        ),
      ),
    ],
  );
}
