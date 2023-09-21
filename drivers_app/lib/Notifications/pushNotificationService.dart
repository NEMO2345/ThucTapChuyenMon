// ignore_for_file: avoid_print
import 'package:drivers_app/configMaps.dart';
import 'package:drivers_app/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io' show Platform;

class PushNotificationService {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: $message");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpenedApp: $message");
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle onLaunch
    RemoteMessage? initialMessage = await firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print("onLaunch: $initialMessage");
    }

    // Handle onResume
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // print("onResume: $message");
      getRideRequest(message.data);
    });

    await firebaseMessaging.requestPermission();
    String? token = await getToken();
    if (token != null) {
      driversRef.child(currentfirebaseUser!.uid).child("token").set(token);
    }

    firebaseMessaging.subscribeToTopic("alldrivers");
    firebaseMessaging.subscribeToTopic("allusers");
  }

  Future<String?> getToken() async {
    String? token = await firebaseMessaging.getToken();
    print("this is token :: ");
    print(token);
    return token;
  }

  String getRideRequest(Map<String, dynamic> message) {
    String rideRequestId = "";
    if (Platform.isAndroid) {
      print("this is Ride Request Id :: ");
      rideRequestId = message['data']['ride_request_id'];
      print(rideRequestId);
    } else {
      print("this is Ride Request Id :: ");
      rideRequestId = message['ride_request_id'];
      print(rideRequestId);
    }
    return rideRequestId;
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print("onBackgroundMessage: $message");
  }
}