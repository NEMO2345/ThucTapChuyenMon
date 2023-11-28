// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings

import 'package:drivers_app/Assistants/AssistantMethods.dart';
import 'package:drivers_app/configMaps.dart';
import 'package:flutter/material.dart';

class CollectFareDialog extends StatelessWidget {

  final String paymentMethod;
  final double fareAmount;

  const CollectFareDialog({super.key, required this.paymentMethod,required this.fareAmount});

  @override
  Widget build(BuildContext context) {
    const btnColor = Color(0xFF00CCFF);
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: btnColor,
      padding: const EdgeInsets.all(17.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );

    return Dialog(
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
             Text("Trip Fare ("+ rideType.toUpperCase()+ ")" ),

             SizedBox(height: 22.0),
             Divider(),

             SizedBox(height: 16.0),
             Text(
              "\$${fareAmount.toStringAsFixed(2)}",
              style: TextStyle(fontFamily: "Brand-Bold", fontSize: 55.0),
            ),
            // Text(
            //   rideType == "bike"
            //       ? "\$${(0.5 * fareAmount).toStringAsFixed(2)}"
            //       : (rideType == "uber-go"
            //       ? "\$${(0.75 * fareAmount).toStringAsFixed(2)}"
            //       : "\$${fareAmount.toStringAsFixed(2)}"),
            //   style: TextStyle(fontFamily: "Brand-Bold", fontSize: 55.0),
            // ),

            const SizedBox(height: 16.0),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "This is the total trip amount, it has been charged to the rider.",
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                AssistantMethods.enablehomeTabLiveLocationUpdates();
              },
              style: buttonStyle,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Collect cash",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Icon(
                      Icons.attach_money,
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
    );
  }

}