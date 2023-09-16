// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, deprecated_member_use, avoid_print, prefer_interpolation_to_compose_strings, use_build_context_synchronously, file_names
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
                image: AssetImage("images/logo.png"),
                width: 390.0,
                height: 250.0,
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
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(
                          fontSize: 14.0,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    SizedBox(height: 1.0),
                    TextField(
                      controller: passwordTextEdittingController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(
                          fontSize: 14.0,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(height: 10.0,),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        minimumSize: Size(200.0, 50.0),
                      ),
                      onPressed:(){
                        if(!emailTextEdittingController.text.contains("@")){
                          displayToastMessage("Email address is not Valid.", context);
                        }else if(passwordTextEdittingController.text.isEmpty){
                          displayToastMessage("Password is mandatory.", context);
                        }else{
                         loginAndAuthenticatedUser(context);
                        }
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(fontSize: 18.0,fontFamily: "Brand Bold"),
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
          return ProgressDialog(message: "Authenticating, Please wait,...", );
        }
    );

    final User? firebaseUser = (await _firebaseAuth// "?" is mean that user can be null
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
      final snapshot = await usersRef.child('users/'+firebaseUser.uid).get();
      if (snapshot.exists) {
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
















































