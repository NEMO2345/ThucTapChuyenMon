// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, file_names

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rider_app/Models/allUsers.dart';
import 'package:rider_app/configMaps.dart';

class ProfileScreen extends StatefulWidget {
  static const String idScreen = "profile";
  

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Users userCurrentInfo;
  String uName = "";
  String uPhone = "";
  String uEmail = "";
  @override
  void initState() {
    super.initState();
    getUserInfor();
  }
  void getUserInfor() async {
    final DatabaseReference usersRef = FirebaseDatabase.instance.ref();
    final snapshot = await usersRef.child('users').child(firebaseUser!.uid).get()
        .then((value) => {
      uName = (value.child("name").value as String?)!,
      uEmail = (value.child("email").value as String?)!,
      uPhone = (value.child("phone").value as String?)!,
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 20.0),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30.0,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Profile",
                style: TextStyle(
                  fontSize: 30.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Signatra',
                ),
              ),
            ),
            SizedBox(
              height: 20,
              width: double.infinity,
              child: Divider(
                color: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Name: $uName",
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                  fontFamily: 'Brand-Regular',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Phone: $uPhone", // Sử dụng thông tin người dùng từ biến userCurrentInfo
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                  fontFamily: 'Brand-Regular',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Email: $uEmail", // Sử dụng thông tin người dùng từ biến userCurrentInfo
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                  fontFamily: 'Brand-Regular',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

