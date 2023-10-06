// ignore_for_file: await_only_futures, prefer_const_constructors, avoid_print, non_constant_identifier_names, unnecessary_brace_in_string_interps

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rider_app/Models/allUsers.dart';
import 'package:rider_app/configMaps.dart';
import 'package:http/http.dart' as http;

class AssistantMethods {
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

  static sendNotificationToDriver(String token, context, String ride_request_id) async {
    DatabaseReference newRequestsRef = FirebaseDatabase.instance.ref().child("Ride Requests");

    // Truy vấn cơ sở dữ liệu Firebase để lấy dữ liệu của ride_request_id
    DatabaseEvent event = await newRequestsRef.child(ride_request_id).once();
    DataSnapshot dataSnapshot = event.snapshot;

    // Kiểm tra giá trị của dataSnapshot.value
    if (dataSnapshot.value != null) {
      // Chuyển đổi giá trị của dataSnapshot.value thành kiểu Map
      Map<String, dynamic> data = dataSnapshot.value as Map<String, dynamic>;

      // Lấy thông tin về điểm đến từ data
      var dropOffLatitude = data["dropoff"]?["latitude"]?.toString();
      var dropOffLongitude = data["dropoff"]?["longitude"]?.toString();
      var dropOffAddress = data["dropoff_address"]?.toString();
      print("PhamLy");
      print(dropOffAddress);

      // Gán thông tin vào hàm sendNotificationToDriver
      var dropOffMap = {
        "latitude": dropOffLatitude,
        "longitude": dropOffLongitude,
      };
      var destination = dropOffMap.toString();

      Map<String, String> headerMap = {
        'Content-Type': 'application/json',
        'Authorization': serverToken,
      };

      Map notificationMap = {
        'body': 'DropOff Address, ${dropOffAddress}',
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
    }
  }
}
