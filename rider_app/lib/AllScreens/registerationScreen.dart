// ignore_for_file: library_private_types_in_public_api, prefer_interpolation_to_compose_strings, use_build_context_synchronously, deprecated_member_use, body_might_complete_normally_catch_error, file_names, prefer_const_constructors, sort_child_properties_last

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rider_app/AllScreens/loginScreen.dart';
import 'package:rider_app/AllScreens/mainscreen.dart';
import 'package:rider_app/AllWidgets/progressDialog.dart';
import 'package:rider_app/configMaps.dart';
import 'package:rider_app/main.dart';

class RegisterationScreen extends StatefulWidget {
  static const String idScreen = "register";
  const RegisterationScreen({Key? key}) : super(key: key);


  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<RegisterationScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  File? _image;
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
              const SizedBox(height: 16.0),
              const Text(
                "Register as a Rider",
                style: TextStyle(fontSize: 35.0, fontFamily: "Brand Bold"),
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
                      controller: emailTextEdittingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
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
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _uploadImage,
                      child: _image != null
                          ? Image.file(
                        _image!,
                        height: 200.0,
                        width: 200.0,
                        fit: BoxFit.cover,
                      )
                          : Text('Choose your avatar',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

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
                    ),
                    const SizedBox(height: 10.0,),
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
                      onPressed:(){
                        if(nameTextEdittingController.text.length < 4){
                            displayToastMessage("Name must be atleast 3 characters.", context);
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
                        }else{
                          registerNewUser(context);
                        }
                      },
                      child: const Text(
                        "Create Account",
                        style: TextStyle(color: Colors.black,fontSize: 20.0,fontFamily: "Brand Bold"),
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

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void registerNewUser(BuildContext context) async {

    // Upload image to Firebase Storage
    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = storage.ref().child('images/$imageName');
    await ref.putFile(_image!);
    String imageUrl = await ref.getDownloadURL();

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
          "image": imageUrl,
        };
        usersRef.child(firebaseUser.uid).set(userDateMap);

        currentfirebaseUser = firebaseUser;

        displayToastMessage("Congratulations, your account has been created.", context);

        Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
      } else {
        Navigator.pop(context);
        // Xử lý khi không thể tạo người dùng thành công
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


