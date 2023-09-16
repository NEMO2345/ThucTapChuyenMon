// ignore_for_file: await_only_futures

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rider_app/Models/allUsers.dart';
import 'package:rider_app/configMaps.dart';

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
          userCurrentInfo = Users.fromSnapshot(dataSnapshot!);
        }
      });
    }
  }
}