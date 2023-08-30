import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rider_app/AllScreens/loginScreen.dart';
import 'package:rider_app/AllScreens/mainscreen.dart';
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
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 20.0),
              Image(
                image: AssetImage("images/logo.png"),
                width: 390.0,
                height: 250.0,
                alignment: Alignment.center,
              ),
              SizedBox(height: 35.0),
              Text(
                "Register as a Rider",
                style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [

                    SizedBox(height: 1.0),
                    TextField(
                      controller: nameTextEdittingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Name",
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
                      controller: phoneTextEdittingController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Phone",
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
                        primary: Colors.yellow,
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        minimumSize: Size(200.0, 50.0),
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
                      child: Text(
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
                child: Text(
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
      final User? firebaseUser = (await _firebaseAuth
          .createUserWithEmailAndPassword(
        email: emailTextEdittingController.text,
        password: passwordTextEdittingController.text,
      ).catchError((errMsg){
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
        displayToastMessage("Congratultions, your account has been created.", context);

        Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
      } else {
        // Xử lý khi không thể tạo người dùng thành công
        displayToastMessage("New User has not been Created.", context);
      }
  }
}

displayToastMessage(String message, BuildContext context){
  Fluttertoast.showToast(msg: message);
}



