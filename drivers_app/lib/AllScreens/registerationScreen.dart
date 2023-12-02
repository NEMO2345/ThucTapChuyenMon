// ignore_for_file: library_private_types_in_public_api, prefer_interpolation_to_compose_strings, use_build_context_synchronously, deprecated_member_use, file_names, prefer_const_constructors, body_might_complete_normally_catch_error, unused_field, prefer_final_fields

import 'package:drivers_app/AllScreens/carInfoScreen.dart';
import 'package:drivers_app/configMaps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:drivers_app/AllScreens/loginScreen.dart';
import 'package:drivers_app/AllWidgets/progressDialog.dart';
import 'package:drivers_app/main.dart';

class RegisterationScreen extends StatefulWidget {
  static const String idScreen = "register";
  const RegisterationScreen({Key? key}) : super(key: key);


  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<RegisterationScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  TextEditingController nameTextEdittingController = TextEditingController();
  TextEditingController emailTextEdittingController = TextEditingController();
  TextEditingController phoneTextEdittingController = TextEditingController();
  TextEditingController passwordTextEdittingController = TextEditingController();
  TextEditingController confirmpasswordTextEdittingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 20.0),
              const Image(
                image: AssetImage("images/BOOKme.png"),
                width: 390.0,
                height: 250.0,
                alignment: Alignment.center,
              ),
              const SizedBox(height: 35.0),
              const Text(
                "Register as a Driver",
                style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 1.0),
                    TextField(
                      controller: nameTextEdittingController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                      ),
                    ),
                    const SizedBox(height: 1.0),
                    TextField(
                      controller: emailTextEdittingController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                      ),
                    ),
                    const SizedBox(height: 1.0),
                    TextField(
                      controller: phoneTextEdittingController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Phone",
                        labelStyle: TextStyle(
                          fontSize: 16.0,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(height: 1.0),
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
                    const SizedBox(height: 1.0),
                    TextField(
                      controller: confirmpasswordTextEdittingController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0,),
                    ElevatedButton(
                      onPressed:(){
                        if(nameTextEdittingController.text.length < 4){
                            displayToastMessage("Name must be at-least 3 characters.", context);
                        }else if(!emailTextEdittingController.text.contains("@")){
                           displayToastMessage("Email address is not Valid.", context);
                        }else if(phoneTextEdittingController.text.isEmpty){
                          displayToastMessage("Phone Number is madatory.", context);
                        } else if(passwordTextEdittingController.text.length < 6){
                          displayToastMessage("Password must be atleast 6 characters.", context);
                        }else if (passwordTextEdittingController.text !=
                          confirmpasswordTextEdittingController.text) {
                          displayToastMessage(
                              "Password incorrect.", context);
                        }
                        else{
                          registerNewUser(context);
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
                        'Register',
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
                  Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
                },
                child: const Text(
                  "Already an Account?  Login here.",
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


  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void registerNewUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context)
        {
          return ProgressDialog(message: "Registering, Please wait,...", );
        }
    );
      final User? firebaseUser = (await _firebaseAuth// "?" is mean that user can be null
          .createUserWithEmailAndPassword(//This function is used for create user
        email: emailTextEdittingController.text,
        password: passwordTextEdittingController.text,
      ).catchError((errMsg){
        Navigator.pop(context);
        displayToastMessage("Error: " + errMsg.toString(), context);
      })).user;

      if (firebaseUser != null) {
        driversRef.child(firebaseUser.uid);
        Map userDateMap = {
          "name": nameTextEdittingController.text.trim(),
          "email": emailTextEdittingController.text.trim(),
          "phone": phoneTextEdittingController.text.trim(),
        };
        driversRef.child(firebaseUser.uid).set(userDateMap);

        currentfirebaseUser = firebaseUser;

        displayToastMessage("Congratulations, your account has been created.", context);

        Navigator.pushNamed(context, CarInfoScreen.idScreen);
      } else {
        Navigator.pop(context);
        displayToastMessage("New User has not been Created.", context);
      }
  }
}

void displayToastMessage(String message, BuildContext context) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.black87,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}



