// ignore_for_file: await_only_futures

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:drivers_app/Models/allUsers.dart';
import 'package:drivers_app/configMaps.dart';
import 'package:flutter_geofire/flutter_geofire.dart';

class AssistantMethods {
  static void getCurrentOnlineUserInfo() async {
    User? firebaseUser = await FirebaseAuth.instance.currentUser;
    String? userId = firebaseUser?.uid;

    if (userId != null) {
      DatabaseReference reference =
      FirebaseDatabase.instance.ref().child("users").child(userId);

      reference.once().then((DatabaseEvent snapshot) {
        DataSnapshot? dataSnapshot = snapshot.snapshot;

        if (dataSnapshot?.value != null) {
          userCurrentInfo = Users.fromSnapshot(dataSnapshot);
        }
      });
    }
  }
  static Future<void> disablehomeTabLiveLocationUpdates() async {
    homeTabPageStreamSubscription!.pause();
    Geofire.removeLocation(currentfirebaseUser!.uid);
  }
  // static void enablehomeTabLiveLocationUpdates() {
  //   homeTabPageStreamSubscription!.resume();
  //   DatabaseReference driverRef = FirebaseDatabase.instance
  //       .ref().child('availableDrivers').child(currentfirebaseUser!.uid);
  //
  //   driverRef.child('latitude').once().then((DataSnapshot snapshot) {
  //     double latitude = snapshot.value as double;
  //
  //     driverRef.child('longitude').once().then((DataSnapshot snapshot) {
  //       double longitude = snapshot.value as double;
  //       Geofire.setLocation(currentfirebaseUser!.uid, latitude, longitude);
  //     } as FutureOr Function(Object value));
  //   } as FutureOr Function(Object value));
  // }
}