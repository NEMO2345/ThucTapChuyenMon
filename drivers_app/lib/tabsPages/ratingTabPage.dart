// ignore_for_file: prefer_const_constructors, file_names, use_key_in_widget_constructors, library_private_types_in_public_api, unused_local_variable

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

import '../configMaps.dart';
import '../main.dart';

class RatingTabPage extends StatefulWidget {

  const RatingTabPage({super.key});

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingTabPage> {
  double startCounter = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateRatings();
  }

  @override
  Widget build(BuildContext context) {
    const btnColor = Colors.blueAccent;
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: btnColor,
      padding: const EdgeInsets.all(17.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(5.0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 22.0),
              Text(
                "Your's Rating",
                style: TextStyle(
                  fontSize: 20.0,
                  fontFamily: "Brand Bold",
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 22.0),
              Divider(height: 2.0, thickness: 2.0),
              SizedBox(height: 16.0),
              SmoothStarRating(
                rating: startCounter,
                color: Colors.green,
                allowHalfRating: false,
                starCount: 5,
                size: 45,
               // isReadonly: true,
                onRatingChanged: (value) {
                  setState(() {
                    startCounter = value;
                  });
                },
              ),
              SizedBox(height: 14.0),
              Text(title, style: TextStyle(fontSize: 55.0, fontFamily: "Signatra",color: Colors.green),),
              SizedBox(height: 16.0),

            ],
          ),
        ),
      ),
    );
  }
  void updateRatings(){
    driversRef.child(currentfirebaseUser!.uid).child("ratings").once().then((DatabaseEvent event){
      DataSnapshot dataSnapshot = event.snapshot;
      if( dataSnapshot.value != null){
        double ratings = double.parse(dataSnapshot.value.toString());
        startCounter = ratings;
        if (startCounter <= 1.5) {
          title = "Very Bad";
          return;
        }
        if (startCounter <= 2.5) {
          title = "Bad";
          return;
        }
        if (startCounter <= 3.5) {
          title = "Good";
          return;
        }
        if (startCounter <= 4.5) {
          title = "Very Good";
          return;
        }
        if (startCounter <= 5) {
          title = "Excellent";
          return;
        }
      }
    });
  }
}