// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, file_names

import 'package:drivers_app/AllScreens/mainscreen.dart';
import 'package:drivers_app/AllScreens/registerationScreen.dart';
import 'package:drivers_app/configMaps.dart';
import 'package:drivers_app/main.dart';
import 'package:flutter/material.dart';

class CarInfoScreen extends StatelessWidget {
  final TextEditingController carModelTextEditingController;
  final TextEditingController carNumberTextEditingController;
  final TextEditingController carColorTextEditingController;
  final TextEditingController carTypeTextEditingController;

  CarInfoScreen({Key? key})
      : carModelTextEditingController = TextEditingController(),
        carNumberTextEditingController = TextEditingController(),
        carColorTextEditingController = TextEditingController(),
        carTypeTextEditingController = TextEditingController(),
        super(key: key);

  static const String idScreen = "carinfo";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 22.0,),
              Image.asset("images/chooseCar.png", width: 390.0, height: 250.0,),
              Padding(
                padding: EdgeInsets.fromLTRB(22.0, 22.0, 22.0, 32.0),
                child: Column(
                  children: [
                    SizedBox(height: 12.0,),
                    Text(
                      "Enter Car Details",
                      style: TextStyle(fontFamily: "Brand-Bold", fontSize: 24.0),
                    ),
                    SizedBox(height: 26.0,),
                    TextField(
                      controller: carModelTextEditingController,
                      decoration: InputDecoration(
                        labelText: 'Car Model',
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    TextField(
                      controller: carNumberTextEditingController,
                      decoration: InputDecoration(
                        labelText: "Car Number",
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    TextField(
                      controller: carColorTextEditingController,
                      decoration: InputDecoration(
                        labelText: 'Car Color',
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    DropdownButtonFormField<String>(
                      value: carTypeTextEditingController.text.isNotEmpty ? carTypeTextEditingController.text : null,
                      onChanged: (String? newValue) {
                        carTypeTextEditingController.text = newValue!;
                      },
                      decoration: InputDecoration(
                        labelText: 'Car Type',
                      ),
                      items: <String>[
                        'bike',
                        'uber-go',
                        'uber-x',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 42.0,),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if(carModelTextEditingController.text.isEmpty){
                            displayToastMessage("Please write Car Model", context);
                          } else if(carNumberTextEditingController.text.isEmpty){
                            displayToastMessage("Please write Car Number", context);
                          } else if(carColorTextEditingController.text.isEmpty){
                            displayToastMessage("Please write Car Color", context);
                          } else if(carTypeTextEditingController.text.isEmpty){
                            displayToastMessage("Please select Car Type", context);
                          } else {
                            saveDriverCarInfo(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.orange,
                          side: BorderSide(color: Colors.lime),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "NEXT",
                              style: TextStyle(
                                fontSize: 38.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.black,
                              size: 26.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void saveDriverCarInfo(context){

    String userId = currentfirebaseUser!.uid;
    Map carInfoMap = {
      "car_color" : carColorTextEditingController.text,
      "car_number" : carNumberTextEditingController.text,
      "car_model": carModelTextEditingController.text,
      "type": carTypeTextEditingController.text,
    };
    driversRef.child(userId).child("car_details").set(carInfoMap);

    Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);

  }
}
