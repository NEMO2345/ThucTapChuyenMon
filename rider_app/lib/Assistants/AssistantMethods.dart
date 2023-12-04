// ignore_for_file: await_only_futures, prefer_const_constructors, avoid_print, non_constant_identifier_names, unnecessary_brace_in_string_interps, unused_local_variable
import 'dart:convert';
import 'dart:ffi';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:rider_app/Models/allUsers.dart';
import 'package:rider_app/configMaps.dart';
import 'package:http/http.dart' as http;

import '../main.dart';

class AssistantMethods {
  static Future<void> getCurrentUserInfo() async {
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

  static void getCurrentOnlineUserInfo() async {
    User? firebaseUser = await FirebaseAuth.instance.currentUser;
    String? userId = firebaseUser?.uid;

    if (userId != null) {
      DatabaseReference reference =
      FirebaseDatabase.instance.ref().child("users").child(userId);

      DataSnapshot? dataSnapshot;
      try {
        dataSnapshot =
        (await reference.once().timeout(Duration(seconds: 5))) as DataSnapshot?;
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
  static sendNotificationToDriver(String token,BuildContext context, ride_request_id) async {
    DatabaseReference newRequestsRef = FirebaseDatabase.instance.ref().child("Ride Requests");
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('Ride Requests/$ride_request_id').get();
    if (snapshot.exists) {
      print(snapshot.child("dropoff_address"));
      var dropOffAddress = snapshot.child("dropoff_address");
      // Gán thông tin vào hàm sendNotificationToDriver
      Map<String, String> headerMap = {
        'Content-Type': 'application/json',
        'Authorization': serverToken,
      };
      Map notificationMap = {
        'body': 'DropOff Address, ${dropOffAddress.value.toString()}',
        'title': 'New Ride Request'
      };
      Map dataMap = {
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'id': '1',
        'status': 'done',
        'ride_request_id': ride_request_id,
      };
      Map sendNotificationMap = {
        "notification": notificationMap,
        "data": dataMap,
        "priority": "high",
        "to": token,
      };
      var res = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: headerMap,
        body: jsonEncode(sendNotificationMap),
      );
      if (res.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${res.statusCode}');
        print('Response body: ${res.body}');
      }
    } else {
      print('No data available.');
    }
    print(newRequestsRef.onValue.toString());
  }
}
