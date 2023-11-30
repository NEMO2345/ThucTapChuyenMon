// ignore_for_file: prefer_const_constructors, deprecated_member_use, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, file_names

import 'package:drivers_app/Models/history.dart';
import 'package:flutter/material.dart';

class TripDetailsScreen extends StatelessWidget {
  final History trip;

  TripDetailsScreen({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image(
                image: AssetImage('images/BOOKme.png'),
                width: 300,
                height: 300,
              ),
              SizedBox(height: 10.0),
              ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: Colors.red,
                ),
                title: Text(
                  'PickUp Address:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  trip.pickup,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: Colors.lightGreen,
                ),
                title: Text(
                  'DropOff Address:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  trip.dropOff,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.calendar_today,
                  color: Colors.pink,
                ),
                title: Text(
                  'DateTime:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  trip.createdAt,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.attach_money,
                  color: Colors.red,
                ),
                title: Text(
                  'Trip fares:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${trip.fares} VND',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.payment,
                  color: Colors.red,
                ),
                title: Text(
                  'Payment Method:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  trip.paymentMethod,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.info,
                  color: Colors.blue,
                ),
                title: Text(
                  'Trip status:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  trip.status,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                    Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent,
                  onPrimary: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                    side: BorderSide(
                      color: Colors.orange,
                      width: 2,
                    ),
                  ),
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  'Back',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}