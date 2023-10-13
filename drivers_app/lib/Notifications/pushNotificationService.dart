
// ignore_for_file: avoid_print, unused_import, unused_element, prefer_interpolation_to_compose_strings

import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:drivers_app/Models/rideDetails.dart';
import 'package:drivers_app/Notifications/notificationDialog.dart';
import 'package:drivers_app/configMaps.dart';
import 'package:drivers_app/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

import 'package:latlong2/latlong.dart';

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize(BuildContext context) async {

    await FirebaseMessaging.instance.requestPermission();
     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final rideRequestId = getRideRequest(message.data);
      print("onBackgroundMessage: 2" + message.data.toString());
      retrieveRideRequestInfo(rideRequestId, context);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final rideRequestId = getRideRequest(message.data);
      print("onBackgroundMessage: 3" + message.data.toString());
      _firebaseMessagingBackgroundHandler(message);
      retrieveRideRequestInfo(rideRequestId, context);
    });


    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      driversRef.child(currentfirebaseUser!.uid).child("token").set(token);
    }

    _firebaseMessaging.subscribeToTopic("alldrivers");
    _firebaseMessaging.subscribeToTopic("allusers");
  }

    Future<String?> getToken() async {
    String? token = await _firebaseMessaging.getToken();
    print("this is token :: ");
    print(token);
    return token;
  }

  String getRideRequest(Map<String, dynamic> message) {
    return message['ride_request_id'] as String;
  }

  Future<void> retrieveRideRequestInfo(String rideRequestId, BuildContext context) async {
    newRequestsRef.child(rideRequestId).once().then((DatabaseEvent event) {
      DataSnapshot dataSnapShot = event.snapshot;
      if (dataSnapShot.value != null) {


        assetsAudioPlayer.open(Audio("sounds/alert.mp3"));
        assetsAudioPlayer.play();

        if (dataSnapShot.value is Map<dynamic, dynamic>) {
          Map<dynamic, dynamic> requestValue = dataSnapShot.value as Map<dynamic, dynamic>;

          double pickUpLocationLat = double.parse(requestValue['pickup']['latitude'].toString());
          double pickUpLocationLng = double.parse(requestValue['pickup']['longitude'].toString());
         // print(pickUpLocationLat);
          //print(pickUpLocationLng);
          String pickUpAddress = requestValue['pickup_address'].toString();

          double dropOffLocationLat = double.parse(requestValue['dropoff']['latitude'].toString());
          double dropOffLocationLng = double.parse(requestValue['dropoff']['longitude'].toString());
          // print("dropOff");
          // print(dropOffLocationLat);
          // print(dropOffLocationLng);
          String dropOffAddress = requestValue['dropoff_address'].toString();

          String paymentMethod = requestValue['payment_method'].toString();
          String riderName = requestValue['rider_name'].toString();
          String riderPhone = requestValue['rider_phone'].toString();


          RideDetails rideDetails = RideDetails(
            pickup_address: pickUpAddress,
            dropoff_address: dropOffAddress,
            pickup: LatLng(pickUpLocationLat, pickUpLocationLng),
            dropoff: LatLng(dropOffLocationLat, dropOffLocationLng),
            ride_request_id: rideRequestId,
            payment_method: paymentMethod,
            rider_name: riderName,
            rider_phone: riderPhone,
          );

          print("pickup_address: ");
          print(rideDetails.pickup_address);
          print(rideDetails.dropoff_address);
          print(rideDetails.pickup);
          print(rideDetails.dropoff);
          print(rideDetails.ride_request_id);
          print(rideDetails.payment_method);
          print(rideDetails.rider_name);

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => NotificationDialog(rideDetails: rideDetails),
          );
        } else {
          print("Invalid data format: Expected Map<dynamic, dynamic>");
        }
      }
    }).catchError((error) {
      print("Error: $error");
    });
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print("onBackgroundMessage: $message");
  }

}

