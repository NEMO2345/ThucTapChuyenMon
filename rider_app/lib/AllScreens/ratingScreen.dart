// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, use_build_context_synchronously, unused_local_variable, avoid_print, file_names
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

class RatingScreen extends StatefulWidget {
  final String driverId;

  const RatingScreen({Key? key, required this.driverId}) : super(key: key);

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double startCounter = 0;
  String title = "";

  @override
  Widget build(BuildContext context) {
    const btnColor = Colors.orange;
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: btnColor,
      padding: const EdgeInsets.all(17.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey[200],
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
                "Rate this Driver",
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
                onRatingChanged: (value) {
                  startCounter = value;

                  if (startCounter == 1) {
                    setState(() {
                      title = "Very Bad";
                    });
                  }
                  if (startCounter == 2) {
                    setState(() {
                      title = "Bad";
                    });
                  }
                  if (startCounter == 3) {
                    setState(() {
                      title = "Good";
                    });
                  }
                  if (startCounter == 4) {
                    setState(() {
                      title = "Very Good";
                    });
                  }
                  if (startCounter == 5) {
                    setState(() {
                      title = "Excellent";
                    });
                  }
                },
              ),
              SizedBox(height: 14.0),
              Text(title, style: TextStyle(fontSize: 55.0, fontFamily: "Signatra",color: Colors.green),),
              SizedBox(height: 16.0),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    DatabaseReference driversRef = FirebaseDatabase.instance.ref("drivers/${widget.driverId}");

                    final snapshot = await driversRef.child("ratings").get();
                    double averageRatings =0;
                    if (snapshot.exists) {
                      print(snapshot.value);
                      double oldRatings =  double.parse(snapshot.value.toString());
                      double newRatings = oldRatings + startCounter;
                      averageRatings = newRatings / 2;
                    } else {
                      print('No data available.');
                      averageRatings = startCounter;
                    }
                    driversRef.child("ratings").set(averageRatings.toString());
                    Navigator.pop(context);

                  },
                  style: buttonStyle,
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Submit",
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30.0,),
            ],
          ),
        ),
      ),
    );
  }
}