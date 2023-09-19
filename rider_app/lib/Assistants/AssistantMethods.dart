// ignore_for_file: await_only_futures, prefer_const_constructors

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rider_app/Models/allUsers.dart';
import 'package:rider_app/configMaps.dart';

import 'package:firebase_database/firebase_database.dart';

class AssistantMethods {
  static void getCurrentOnlineUserInfo() async {
    User? firebaseUser = await FirebaseAuth.instance.currentUser;
    String? userId = firebaseUser?.uid;

    if (userId != null) {
      DatabaseReference reference =
      FirebaseDatabase.instance.ref().child("users").child(userId);

      DataSnapshot? dataSnapshot;
      try {
        dataSnapshot = (await reference.once().timeout(Duration(seconds: 5))) as DataSnapshot?;
      } catch (e) {
        print("Error: $e");
      }

      if (dataSnapshot != null) {
        Map<String, dynamic>? dataSnapshotValue =
        dataSnapshot.value as Map<String, dynamic>?;

        if (dataSnapshotValue != null) {
          userCurrentInfo = Users.fromSnapshot(dataSnapshot);
        }
      }
    }
  }
}