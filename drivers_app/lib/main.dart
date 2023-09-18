// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'dart:io';

import 'package:drivers_app/AllScreens/carInfoScreen.dart';
import 'package:drivers_app/configMaps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drivers_app/AllScreens/loginScreen.dart';
import 'package:drivers_app/AllScreens/mainscreen.dart';
import 'package:drivers_app/AllScreens/registerationScreen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();//Khoi tao flutter framework
  await Firebase.initializeApp();//Khoi tao firebase
  // Add this line to ignore certificate validation
  HttpOverrides.global = MyHttpOverrides();

  currentfirebaseUser = FirebaseAuth.instance.currentUser;

  runApp(const MyApp());
}

DatabaseReference usersRef = FirebaseDatabase.instance.reference().child("users");
DatabaseReference driversRef = FirebaseDatabase.instance.reference().child("drivers");
DatabaseReference rideRequestRef = FirebaseDatabase.instance.reference().child("drivers").child(currentfirebaseUser!.uid).child("newRide");

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(

      create: (BuildContext context) {  },
      child: MaterialApp(
        title: 'Taxi Driver App',
        theme: ThemeData(
         // fontFamily: "Brand Bold",
          primarySwatch: Colors.blue,//The banner color
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: FirebaseAuth.instance.currentUser == null ?LoginScreen.idScreen : MainScreen.idScreen,
        routes:
        {
          RegisterationScreen.idScreen: (context) => RegisterationScreen(),
          LoginScreen.idScreen: (context) => LoginScreen(),
          MainScreen.idScreen: (context) => MainScreen(),
          CarInfoScreen.idScreen: (context) => CarInfoScreen(),
        },
        debugShowCheckedModeBanner: false,//Remove the banner
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host,
          int port) => true;
  }

}