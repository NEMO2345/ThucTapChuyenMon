// ignore_for_file: await_only_futures, non_constant_identifier_names, file_names, unused_local_variable, avoid_function_literals_in_foreach_calls
import 'dart:async';
import 'package:drivers_app/DataHandler/appData.dart';
import 'package:drivers_app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:drivers_app/Models/allUsers.dart';
import 'package:drivers_app/configMaps.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:drivers_app/Models/history.dart';

class AssistantMethods {
  static void getCurrentOnlineUserInfo() async {
    User? firebaseUser = await FirebaseAuth.instance.currentUser;
    String? userId = firebaseUser?.uid;

    if (userId != null) {
      DatabaseReference reference =
      FirebaseDatabase.instance.ref().child("users").child(userId);

      reference.once().then((DatabaseEvent snapshot) {
        DataSnapshot? dataSnapshot = snapshot.snapshot;

        if (dataSnapshot?.value != null) { // ignore: invalid_null_aware_operator
          userCurrentInfo = Users.fromSnapshot(dataSnapshot);
        }
      });
    }
  }
  static Future<void> disablehomeTabLiveLocationUpdates() async {
    homeTabPageStreamSubscription!.pause();
    Geofire.removeLocation(currentfirebaseUser!.uid);
  }
  static void enablehomeTabLiveLocationUpdates() {
    homeTabPageStreamSubscription!.resume();
    DatabaseReference driverRef = FirebaseDatabase.instance
        .ref().child('availableDrivers').child(currentfirebaseUser!.uid);

    driverRef.child('latitude').once().then((DataSnapshot snapshot) {
      double latitude = snapshot.value as double;

      driverRef.child('longitude').once().then((DataSnapshot snapshot) {
        double longitude = snapshot.value as double;
        Geofire.setLocation(currentfirebaseUser!.uid, latitude, longitude);
      } as FutureOr Function(Object value));
    } as FutureOr Function(Object value));
  }
  static void retrieveHistoryInfo(context) async{

    //retrieve and display Earnings
    driversRef.child(currentfirebaseUser!.uid).child("earnings").once().then((DatabaseEvent event){
      DataSnapshot dataSnapshot = event.snapshot;
      if( dataSnapshot.value != null){
          String earnings = dataSnapshot.value.toString();
          Provider.of<AppData>(context,listen: false).updateEarnings(earnings);
      }
    });
   // retrieve and display Trip History
    driversRef.child(currentfirebaseUser!.uid).child("history").once().then((DatabaseEvent event){
      DataSnapshot dataSnapshot = event.snapshot;
      int tripCounter = 0;
      if(dataSnapshot.value != null){
        //updates total number of trip counts to provider
        List<String> tripHistoryKeys = [];
        dataSnapshot.children.forEach((element) {
          tripCounter++;
          tripHistoryKeys.add(element.key.toString());
         // print(element.key);
        });

        Provider.of<AppData>(context,listen: false).updateTripsCounter(tripCounter);
        //update trip keys to provider

        Provider.of<AppData>(context,listen: false).clearTripHistoryData();
        Provider.of<AppData>(context,listen: false).updateTripKeys(tripHistoryKeys);
        obtainTripRequestHistoryData(context);
      }
    });
  }
  static void obtainTripRequestHistoryData(context){

    var keys = Provider.of<AppData>(context,listen: false).tripHistoryKeys;

    for(String key in keys){
        newRequestsRef.child(key).once().then((DatabaseEvent event){
          DataSnapshot snapshot = event.snapshot;
          if(snapshot.value != null){
            //print(snapshot.value);
            var history = History(paymentMethod: snapshot.child("payment_method").value.toString() ,
                createdAt:snapshot.child("created_at").value.toString(),
                status:snapshot.child("status").value.toString(),
                fares:snapshot.child("fares").value.toString(),
                dropOff:snapshot.child("dropoff_address").value.toString(),
                pickup:snapshot.child("pickup_address").value.toString());
            Provider.of<AppData>(context,listen: false).updateTripHistoryData(history);
          }
        });
    }
  }
  static String formatTripDate(String date){
    DateTime dateTime = DateTime.parse(date);
    String formattedDate = "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}";
    return formattedDate;
  }
}