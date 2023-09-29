// ignore_for_file: prefer_const_constructors, deprecated_member_use, avoid_print
import 'dart:io';
import 'package:drivers_app/AllScreens/carInfoScreen.dart';
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
  // channel = const AndroidNotificationChannel(
  //   'high_importance_channel', // id
  //   'High Importance Notifications', // title
  //   description:
  //   'This channel is used for important notifications.', // description
  //   importance: Importance.high,
  // );

  //var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //     AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
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

void main() async{
  WidgetsFlutterBinding.ensureInitialized();//Khoi tao flutter framework
  await Firebase.initializeApp();//Khoi tao firebase
  //await FirebaseApi().initNotifications();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //LocalNotificationService.initialize();
  //
  // Tạo một GlobalKey để có thể truy cập context
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Chạy ứng dụng thông qua runApp và truyền navigatorKey
  runApp(MyApp(navigatorKey: navigatorKey));

  // Truyền navigatorKey vào phương thức initialize của PushNotificationService
  await PushNotificationService().initialize(navigatorKey.currentContext as BuildContext);
  // Add this line to ignore certificate validation
  HttpOverrides.global = MyHttpOverrides();

  currentfirebaseUser = FirebaseAuth.instance.currentUser;

  //runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key, required GlobalKey<NavigatorState> navigatorKey});

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
         // NotificationScreen.route:(context) => const NotificationScreen(),
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