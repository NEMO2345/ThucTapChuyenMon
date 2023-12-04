// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, file_names, await_only_futures

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rider_app/AllScreens/changePasswordScreen.dart';
import 'package:rider_app/Models/allUsers.dart';
import 'package:rider_app/configMaps.dart';
import 'package:rider_app/main.dart';

class ProfileScreen extends StatefulWidget {
  static const String idScreen = "profile";
  

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    getCurrentUserInfo();
  }
  void getCurrentUserInfo() async{
    firebaseUser = await FirebaseAuth.instance.currentUser;

    try {
      DatabaseReference reference = usersRef.child(firebaseUser?.uid ?? "");
      DatabaseEvent event = await reference.once();
      DataSnapshot dataSnapshot = event.snapshot;

      if (dataSnapshot.value != null) {
        userCurrentInfo = Users.fromSnapshot(dataSnapshot);
      }
    } catch (error) {

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Profile',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.orange,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            InkWell(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Column(
                  children: [
                    Image.asset(
                      'images/user_icon.png',
                      width: 120,
                      height: 120,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userCurrentInfo!.name ?? "Ly",
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: "Brand Bold",
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              color: Colors.grey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChangePassword()),
                      );
                    },
                    child: Text(
                      'Change Password',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.email),
              title: Text(
                'Email',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                userCurrentInfo?.email ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            Container(
              height: 1,
              color: Colors.grey,
              margin: EdgeInsets.symmetric(horizontal: 16),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text(
                'Số điện thoại',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                userCurrentInfo?.phone ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            Container(
              height: 1,
              color: Colors.grey,
              margin: EdgeInsets.symmetric(horizontal: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {

              },
              style: ElevatedButton.styleFrom(
                primary: Colors.orange,
                onPrimary: Colors.black,
                textStyle: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontFamily: 'Brand Bold',
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              child: Text('Change Information'),
            ),
          ],
        ),
      ),
    );
  }
}

