import 'package:firebase_auth/firebase_auth.dart';
import 'package:rider_app/Models/allUsers.dart';

String mapKey = "AIzaSyC_1sHOAGI52bSK0bMYvSGT6lwE48D41Tg";

User? firebaseUser;
Users? userCurrentInfo;

int driverRequestTimeOut = 20;
String statusRide = "";
String riderStatus ="Driver is coming";
String carDetailsDriver = "";
String driverName = "";
String driverPhone = "";
double startCounter=0.0;
String title = "";
String carRideType="";

String serverToken = "key=AAAAsWnR3fc:APA91bEQ4iHrFGOH5hlJWOtJ-P9F6ACmR8N8UWHxpUUZCLz-SJn1TKHVSkRO3aX0blK_Ik2LknfT5dxp_tmIRU5izDu-MpCglLfUqxiDYw0IlpykGZvA5FfPwrWXxNbBqk3yA4m6WOd9";
String rideType = "";