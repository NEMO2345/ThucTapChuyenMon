import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:drivers_app/Models/drivers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drivers_app/Models/allUsers.dart';
import 'package:geolocator/geolocator.dart';

String mapKey = "AIzaSyC_1sHOAGI52bSK0bMYvSGT6lwE48D41Tg";

User? firebaseUser;
Users? userCurrentInfo;
User? currentfirebaseUser;

StreamSubscription<Position>? homeTabPageStreamSubscription;

final assetsAudioPlayer = AssetsAudioPlayer();



Drivers? driversInformation;