// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors

import 'package:drivers_app/Models/rideDetails.dart';
import 'package:flutter/material.dart';

class NewRideScreen extends StatefulWidget {
  const NewRideScreen({Key? key, required this.rideDetails}) : super(key: key);
  final RideDetails rideDetails;

  @override
  _NewRideScreenState createState() => _NewRideScreenState();
}

class _NewRideScreenState extends State<NewRideScreen> {
  @override
  Widget build (BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: Text("New Ride"),
        ),
        body: Center(
          child: Text("This is New Ride Page"),
        ),
    );
  }
}
