// ignore_for_file: library_private_types_in_public_api, prefer_interpolation_to_compose_strings, use_build_context_synchronously, deprecated_member_use, body_might_complete_normally_catch_error, file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rider_app/AllScreens/loginScreen.dart';
import 'package:rider_app/AllScreens/mainscreen.dart';
import 'package:rider_app/AllWidgets/progressDialog.dart';
import 'package:rider_app/main.dart';

class RegisterationScreen extends StatefulWidget {
  static const String idScreen = "register";
  const RegisterationScreen({Key? key}) : super(key: key);


  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<RegisterationScreen> {

  TextEditingController nameTextEdittingController = TextEditingController();
  TextEditingController emailTextEdittingController = TextEditingController();
  TextEditingController phoneTextEdittingController = TextEditingController();
  TextEditingController passwordTextEdittingController = TextEditingController();
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
                image: AssetImage("images/logoBookMe.png"),
                width: 390.0,
                height: 250.0,
                alignment: Alignment.center,
              ),
              const SizedBox(height: 35.0),
              const Text(
                "Register as a Rider",
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
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Name",
                        labelStyle: TextStyle(
                          fontSize: 14.0,
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
                      controller: emailTextEdittingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(
                          fontSize: 14.0,
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
                      controller: phoneTextEdittingController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Phone",
                        labelStyle: TextStyle(
                          fontSize: 14.0,
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
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(
                          fontSize: 14.0,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14.0),

                    ),

                    const SizedBox(height: 10.0,),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xFF00CCFF),
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        minimumSize: const Size(200.0, 50.0),
                      ),
                      onPressed:(){
                        if(nameTextEdittingController.text.length < 4){
                            displayToastMessage("Name must be atleast 3 characters.", context);
                        }else if(!emailTextEdittingController.text.contains("@")){
                           displayToastMessage("Email address is not Valid.", context);
                        }else if(phoneTextEdittingController.text.isEmpty){
                          displayToastMessage("Phone Number is madatory.", context);
                        } else if(passwordTextEdittingController.text.length < 6){
                          displayToastMessage("Password must be atleast 6 characters.", context);
                        }else{
                          registerNewUser(context);
                        }
                      },
                      child: const Text(
                        "Create Account",
                        style: TextStyle(fontSize: 18.0,fontFamily: "Brand Bold"),
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
        // Xử lý thành công, ví dụ: chuyển hướng tới màn hình tiếp theo
        usersRef.child(firebaseUser.uid);
        Map userDateMap = {
          "name": nameTextEdittingController.text.trim(),
          "email": emailTextEdittingController.text.trim(),
          "phone": phoneTextEdittingController.text.trim(),
        };
        usersRef.child(firebaseUser.uid).set(userDateMap);
        displayToastMessage("Congratulations, your account has been created.", context);

        Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
      } else {
        Navigator.pop(context);
        // Xử lý khi không thể tạo người dùng thành công
        displayToastMessage("New User has not been Created.", context);
      }
  }
}

displayToastMessage(String message, BuildContext context){
  Fluttertoast.showToast(msg: message);
}



