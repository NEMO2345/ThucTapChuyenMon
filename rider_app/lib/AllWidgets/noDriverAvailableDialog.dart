// ignore_for_file: prefer_const_constructors, prefer_const_declarations, use_key_in_widget_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class NoDriverAvailableDialog extends StatelessWidget {
  const NoDriverAvailableDialog({Key? key});

  @override
  Widget build(BuildContext context) {
    final btnColor = Colors.deepPurpleAccent;
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: btnColor,
      padding: const EdgeInsets.all(17.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10.0),
                Text(
                  'No driver found',
                  style: TextStyle(fontSize: 22.0, fontFamily: 'Brand-Bold'),
                ),
                SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'No available driver found nearby, we suggest you try again shortly',
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 30.0),
                ElevatedButton(
                  style: buttonStyle,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(17.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Close",
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Icon(
                          Icons.car_repair,
                          color: Colors.white,
                          size: 26.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}