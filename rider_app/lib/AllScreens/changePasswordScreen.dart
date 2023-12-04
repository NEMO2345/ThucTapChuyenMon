// ignore_for_file: use_build_context_synchronously, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_final_fields, prefer_const_constructors, deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:rider_app/AllScreens/loginScreen.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePassword> {
  TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> forgotPassword() async {
    setState(() {
      _isLoading = true;
    });

    var forgotEmail = _emailController.text.trim();

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(
        email: forgotEmail,
        actionCodeSettings: auth.ActionCodeSettings(
          url: 'https://flutter-thu2.firebaseapp.com/__/auth/action?mode=action&oobCode=code',
          handleCodeInApp: true,
          androidPackageName: 'com.phamthily.riderapp',
          androidMinimumVersion: '21',
        ),
      )
          .then((value) {
        displayToastMessage("Email has been sent, please check", context);
        Navigator.of(context).pushNamed(LoginScreen.idScreen);
      });
    } on FirebaseAuthException catch (e) {
      displayToastMessage("Error: $e", context);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void displayToastMessage(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.orange,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email),
                labelText: 'Please enter your email to change your password',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.transparent,
                onPrimary: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                  side: BorderSide(
                    color: Colors.orange,
                    width: 2,
                  ),
                ),
                backgroundColor: Colors.white,
              ),
              onPressed: _isLoading ? null : () async {
                await forgotPassword();
              },
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text(
                "Send Email",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontFamily: "Brand Bold",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}