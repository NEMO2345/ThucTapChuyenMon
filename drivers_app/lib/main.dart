// ignore_for_file: prefer_const_constructors, deprecated_member_use, avoid_print, use_key_in_widget_constructors
import 'dart:io';
import 'package:drivers_app/AllScreens/carInfoScreen.dart';
import 'package:drivers_app/DataHandler/appData.dart';
import 'package:drivers_app/Notifications/pushNotificationService.dart';
import 'package:drivers_app/configMaps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:drivers_app/AllScreens/loginScreen.dart';
import 'package:drivers_app/AllScreens/mainscreen.dart';
import 'package:drivers_app/AllScreens/registerationScreen.dart';
@pragma('vm:entry-point')

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await setupFlutterNotifications();
  print('Handling a background message ${message.messageId}');
}

late AndroidNotificationChannel channel;
bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

final navigatorKey = GlobalKey<NavigatorState>();
DatabaseReference usersRef = FirebaseDatabase.instance.reference().child("users");
DatabaseReference driversRef = FirebaseDatabase.instance.reference().child("drivers");
DatabaseReference newRequestsRef = FirebaseDatabase.instance.reference().child("Ride Requests");
DatabaseReference rideRequestRef = FirebaseDatabase.instance
    .reference()
    .child("drivers")
    .child(currentfirebaseUser!.uid)
    .child("newRide");

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppData()),
      ],
      child: MyApp(navigatorKey: navigatorKey),
    ),
  );

  await PushNotificationService().initialize(navigatorKey.currentContext as BuildContext);
  HttpOverrides.global = MyHttpOverrides();

  currentfirebaseUser = FirebaseAuth.instance.currentUser;
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Taxi Driver App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: FirebaseAuth.instance.currentUser == null ? LoginScreen.idScreen : MainScreen.idScreen,
      routes: {
        RegisterationScreen.idScreen: (context) => RegisterationScreen(),
        LoginScreen.idScreen: (context) => LoginScreen(),
        MainScreen.idScreen: (context) => MainScreen(),
        CarInfoScreen.idScreen: (context) => CarInfoScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}