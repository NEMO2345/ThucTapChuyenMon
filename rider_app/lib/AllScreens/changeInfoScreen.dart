// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, deprecated_member_use, must_be_immutable, file_names, library_private_types_in_public_api, unused_field, prefer_final_fields, unrelated_type_equality_checks, non_constant_identifier_names, avoid_print
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rider_app/AllScreens/registerationScreen.dart';
import 'package:rider_app/Models/allUsers.dart';
import 'package:rider_app/configMaps.dart';
import 'package:rider_app/main.dart';



class ChangeInfo extends StatefulWidget {

  @override
  _ChangeInfoState createState() => _ChangeInfoState();
}


class _ChangeInfoState extends State<ChangeInfo> {

  TextEditingController nameTextEdittingController = TextEditingController();
  TextEditingController emailTextEdittingController = TextEditingController();
  TextEditingController phoneTextEdittingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUserInfo();
  }
  void getCurrentUserInfo() async{
    firebaseUser =  FirebaseAuth.instance.currentUser;
    try {
      DatabaseReference reference = usersRef.child(firebaseUser?.uid ?? "");
      DatabaseEvent event = await reference.once();
      DataSnapshot dataSnapshot = event.snapshot;

      if (dataSnapshot.value != null) {
        userCurrentInfo = Users.fromSnapshot(dataSnapshot);
      }
    } catch (error) {
      print("Error: $error");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Change Information',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.orange,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 15),
        children: [
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
                    userCurrentInfo?.name ?? "Ly",
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
          Container(
            height: 1,
            color: Colors.grey,
            margin: EdgeInsets.symmetric(horizontal: 16),
          ),
          SizedBox(height: 10.0),
          TextField(
            controller: nameTextEdittingController,
            decoration: InputDecoration(
              labelText: 'Enter a new username',
              prefixIcon: Icon(Icons.man),
            ),
          ),
          SizedBox(height: 10.0),
          TextField(
            controller: emailTextEdittingController,
            decoration: InputDecoration(
              labelText: 'Enter a new email',
              prefixIcon: Icon(Icons.email),
            ),
          ),
          TextField(
            controller: phoneTextEdittingController,
            decoration: InputDecoration(
              labelText: 'Enter a new phone',
              prefixIcon: Icon(Icons.phone),
            ),
          ),
          SizedBox(height: 10.0),
          SizedBox(height: 30),
          Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    changeInfo();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    textStyle: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontFamily: 'Brand Bold',
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: Colors.yellow,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text('Update'),
                ),
                SizedBox(width: 55),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    onPrimary: Colors.white,
                    textStyle: TextStyle(
                      fontSize: 15,
                      fontFamily: 'Brand Bold',
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Cancel'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  void changeInfo() {
    String newName = nameTextEdittingController.text;
    String newEmail = emailTextEdittingController.text;
    String newPhone = phoneTextEdittingController.text;
      usersRefUpdate.update({
        "email": newEmail,
        "name": newName,
        "phone": newPhone,
      }).then((value) {
        displayToastMessage("Update Successfully.", context);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      }).catchError((error) {
        displayToastMessage("Error + $error", context  );
      });
  }
}

