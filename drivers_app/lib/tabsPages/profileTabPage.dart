// ignore_for_file: prefer_const_constructors, file_names, prefer_interpolation_to_compose_strings, must_be_immutable, avoid_print, sort_child_properties_last
import 'package:drivers_app/AllScreens/settingsScreen.dart';
import 'package:drivers_app/configMaps.dart';
import 'package:drivers_app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';

class ProfileTabPage extends StatelessWidget {
  const ProfileTabPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.topRight,
              padding: EdgeInsets.only(top: 5.0, right: 1.0),
              child: RawMaterialButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
                },
                elevation: 2.0,
                fillColor: Colors.white,
                child: Icon(
                  Icons.settings,
                  color: Colors.orange,
                  size: 20.0,
                ),
                padding: EdgeInsets.all(10.0),
                shape: CircleBorder(),
              ),
            ),
            CircleAvatar(
              radius: 100.0,
              backgroundImage: NetworkImage(driversInformation!.image),
            ),
            Text(
              driversInformation!.name,
              style: TextStyle(
                fontSize: 65.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'Signatra',
              ),
            ),
            Text(
              title + " driver",
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
                letterSpacing: 2.5,
                fontWeight: FontWeight.bold,
                fontFamily: 'Brand-Regular'
              ),
            ),
            SizedBox(
              height: 20,
              width: 200,
              child: Divider(
                color: Colors.white,
              ),
            ),
            SizedBox(height: 40.0,),
            InfoCard(
                text: driversInformation!.phone,
                icon: Icons.phone,
                onPressed: () async{
                  print("This is phone");
                },
            ),
            InfoCard(
              text: driversInformation!.email,
              icon: Icons.email,
              onPressed: () async{
                print("This is email");
              },
            ),
            InfoCard(
              text: driversInformation!.car_color + " "+ driversInformation!.car_model+ " "+ driversInformation!.car_number,
              icon: Icons.car_repair,
              onPressed: () async{
                print("This is carInfo");
              },
            ),
            GestureDetector(
              onTap: (){
                Geofire.removeLocation(currentfirebaseUser!.uid);
                rideRequestRef.onDisconnect();
                rideRequestRef.remove();
               // rideRequestRef = null;
                FirebaseAuth.instance.signOut();
                Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
              },
              child: Card(
                color: Colors.red,
                margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 110.0),
                child: ListTile(
                  trailing: Icon(
                    Icons.follow_the_signs_outlined,
                    color: Colors.white,
                  ),
                  title: Text(
                    "Sign out",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontFamily: 'Brand Bold',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String text;
  final IconData? icon;
  void Function()? onPressed;

  InfoCard({super.key, required this.text, required this.icon,required this.onPressed,});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        color: Colors.orange,
        margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 25.0),
        child: ListTile(
          leading: Icon(
            icon,
            color: Colors.black,
          ),
          title: Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontFamily: 'Brand Bold',
            ),

          ),
        ),

      ),
    );
  }
}

