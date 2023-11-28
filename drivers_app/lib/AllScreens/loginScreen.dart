// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, deprecated_member_use, avoid_print, prefer_interpolation_to_compose_strings, use_build_context_synchronously, file_names, body_might_complete_normally_catch_error
import 'package:drivers_app/configMaps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:drivers_app/AllScreens/registerationScreen.dart';
import 'package:drivers_app/AllWidgets/progressDialog.dart';
import 'mainscreen.dart';

class LoginScreen extends StatefulWidget {
  static const String idScreen = "login";

  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;
  bool _obscurePassword = true;
  TextEditingController emailTextEdittingController = TextEditingController();
  TextEditingController passwordTextEdittingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 45.0),
              Image(
                image: AssetImage("images/BOOKme.png"),
                // width: 330.0,
                // height: 270.0,
                alignment: Alignment.center,
              ),
              SizedBox(height: 35.0),
              Text(
                "Login as a Driver",
                style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(height: 1.0),
                    TextField(
                      controller: emailTextEdittingController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                      ),
                    ),
                    SizedBox(height: 1.0),
                    TextField(
                      controller: passwordTextEdittingController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (value) {
                            setState(() {
                              rememberMe = value!;
                            });
                          },
                        ),
                        Text('Save Account'),
                        Spacer(),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                          if(!emailTextEdittingController.text.contains("@")){
                            displayToastMessage("Email address is not Valid.", context);
                          }else if(passwordTextEdittingController.text.isEmpty){
                            displayToastMessage("Password is mandatory.", context);
                          }else{
                            loginAndAuthenticatedUser(context);
                          }
                        },
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
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed:()
                {
                  Navigator.pushNamedAndRemoveUntil(context, RegisterationScreen.idScreen, (route) => false);
                },
                child: Text(
                  "Do not have an Account?  Register here.",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  final DatabaseReference usersRef = FirebaseDatabase.instance.ref();
// Usage:
// Replace with the desired name
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  void loginAndAuthenticatedUser(BuildContext context) async {

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context)
        {
          return ProgressDialog(message: "Authenticating. Please wait,...", );
        }
    );

    final User? firebaseUser = (await _firebaseAuth
        .signInWithEmailAndPassword(
        email: emailTextEdittingController.text,
        password: passwordTextEdittingController.text,
    ).catchError((errMsg){
      Navigator.pop(context);
      //print("Error: $errMsg");
      displayToastMessage(" Error: " + errMsg.toString(), context);
    })).user;
    if (firebaseUser != null)
    {
      final snapshot = await usersRef.child('drivers/'+firebaseUser.uid).get();
      if (snapshot.exists) {
            currentfirebaseUser = firebaseUser;
            Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
            displayToastMessage("You are logged-in now.", context);
      } else {
        Navigator.pop(context);
        _firebaseAuth.signOut();
        displayToastMessage("No record exists for this user. Please create a new account", context);
      }

    }
    else {
      Navigator.pop(context);
      displayToastMessage("Error Occured. Can not be Sign-in", context);
    }
  }
}
















































