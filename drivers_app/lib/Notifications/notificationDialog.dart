// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers

import 'dart:async';

import 'package:drivers_app/AllScreens/newRideScreen.dart';
import 'package:drivers_app/AllScreens/registerationScreen.dart';
import 'package:drivers_app/Models/rideDetails.dart';
import 'package:drivers_app/configMaps.dart';
import 'package:drivers_app/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class NotificationDialog extends StatelessWidget {
  const  NotificationDialog({Key? key, required this.rideDetails}) : super(key: key);

  final RideDetails rideDetails;

  @override
  Widget build(BuildContext context) {

    Color diverStatusColorWhile = Colors.white;
    Color diverStatusColorGreen = Colors.green;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: Colors.transparent,
      elevation: 1.0,
      child: Container(
        margin: EdgeInsets.all(5.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.0),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 30.0,),
            Image.asset("images/taxi.png",width: 120.0,),
            SizedBox(height: 18.0,),
            Text("New Ride Request", style: TextStyle(fontFamily: "Brand-bold",fontSize: 18.0,),),
            Padding(
                padding: EdgeInsets.all(18.0),
              child: Column(
                children: [

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset("images/pickicon.png",height: 16.0,width: 16.0,),
                      SizedBox(width: 20.0,),
                      Expanded(
                        child: Container(
                          child: Text(rideDetails.pickup_address,style: TextStyle(fontSize: 18.0),),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.0,),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset("images/desticon.png",height: 16.0,width: 16.0,),
                      SizedBox(width: 20.0,),
                      Expanded(
                        child: Container(
                            child: Text(rideDetails.dropoff_address,style: TextStyle(fontSize: 18.0),),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.0,),

                ],
              ),
            ),

            SizedBox(height: 20.0,),
            Divider(height: 2.0,color: Colors.black, thickness: 2.0,),
            SizedBox(height: 8.0,),

            Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: diverStatusColorWhile, // Đặt màu xanh lá cho nút
                      padding: EdgeInsets.all(17.0),
                    ),
                    onPressed: () {
                        assetsAudioPlayer.stop();
                        Navigator.pop(context);

                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                        "Cancel".toUpperCase(),
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        // Icon(
                        //   Icons.phone_android,
                        //   color: Colors.white,
                        //   size: 26.0,
                        // ),
                      ],
                    ),
                  ),
                  SizedBox(width: 25.0,),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: diverStatusColorGreen, // Đặt màu xanh lá cho nút
                      padding: EdgeInsets.all(18.0),
                    ),
                    onPressed: () {
                      assetsAudioPlayer.stop();
                      checkAvailabilityOfRide(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Accept".toUpperCase(),
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        // Icon(
                        //   Icons.phone_android,
                        //   color: Colors.white,
                        //   size: 26.0,
                        // ),
                      ],
                    ),
                  ),
                 // SizedBox(width: 10.0,),
                ],
              ),
            ),

            SizedBox(height: 10.0,),
          ],
        ),
      ),
    );
  }
  void checkAvailabilityOfRide(context) {
    rideRequestRef.once().then((DatabaseEvent event) {
      DataSnapshot dataSnapshot = event.snapshot;
      Navigator.pop(context);
      String theRideId = "";
      // print("helooooooo");
      // print(dataSnapshot.value);
      // print(rideDetails.ride_request_id);
      if (dataSnapshot.value != null) {
        theRideId = dataSnapshot.value.toString();
      } else {
        displayToastMessage("Ride not exists.", context);
      }

      if (theRideId == rideDetails.ride_request_id) {
        rideRequestRef.set("accepted");
        Navigator.push(context, MaterialPageRoute(builder: (context) => NewRideScreen(rideDetails: rideDetails)));
      } else if (theRideId == "cancelled") {
        displayToastMessage("Ride has been Cancelled.", context);
      } else if (theRideId == "timeout") {
        displayToastMessage("Ride has time out.", context);
      } else {
        displayToastMessage("Ride not exists", context);
      }
    }, onError: (Object error) {
      // Xử lý lỗi nếu có
    });
  }
}
