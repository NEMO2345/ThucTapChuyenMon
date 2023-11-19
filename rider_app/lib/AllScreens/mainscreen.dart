// ignore_for_file: prefer_const_constructors, unnecessary_import, library_private_types_in_public_api, prefer_final_fields, unnecessary_new, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, sort_child_properties_last, prefer_interpolation_to_compose_strings, use_build_context_synchronously, avoid_print, non_constant_identifier_names, library_prefixes, unused_label, cast_from_null_always_fails, unnecessary_null_comparison, unused_element, unnecessary_cast, unused_local_variable, no_leading_underscores_for_local_identifiers, constant_pattern_never_matches_value_type, prefer_collection_literals, deprecated_member_use, avoid_unnecessary_containers, prefer_conditional_assignment, constant_identifier_names, avoid_function_literals_in_foreach_calls, unnecessary_brace_in_string_interps, await_only_futures
import 'dart:async';
import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rider_app/AllScreens/loginScreen.dart';
import 'package:rider_app/AllScreens/profileScreen.dart';
import 'package:rider_app/AllScreens/ratingScreen.dart';
import 'package:rider_app/AllScreens/registerationScreen.dart';
import 'package:rider_app/AllScreens/searchScreen.dart';
import 'package:rider_app/AllWidgets/CollectFareDialog.dart';
import 'package:rider_app/AllWidgets/Divider.dart';
import 'package:flutter_map/flutter_map.dart' show  FlutterMap, MapController, MapOptions, Marker, MarkerLayer, Polyline, PolylineLayer, TileLayer;
import 'package:latlong2/latlong.dart';
import 'package:rider_app/AllWidgets/noDriverAvailableDialog.dart';
import 'package:rider_app/AllWidgets/progressDialog.dart';
import 'package:rider_app/Assistants/AssistantMethods.dart';
import 'package:rider_app/Assistants/geoFireAssistant.dart';
import 'package:rider_app/Models/nearbyAvailableDrivers.dart';
import 'package:rider_app/configMaps.dart';
import 'package:rider_app/main.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Models/address.dart';
import 'api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart' as Loc;
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "mainScreen";
  const MainScreen({Key? key, this.firebaseUser}) : super(key: key);
  final User? firebaseUser;
  @override
  _MainScreenState createState() => _MainScreenState();
}
Loc.Location location = new Loc.Location();
bool _serviceEnabled = false;
Loc.PermissionStatus _permissionGranted = Loc.PermissionStatus.denied;
Loc.LocationData _locationData = null as Loc.LocationData;
const double MAXDISTANCE = 15000;

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin{
  // Raw coordinates got from  OpenRouteService
  List listOfPoints = [];
  String PickUpPoint = "";
  String Destination = "";
  double tripDirectionDetails = 0;
  double totalcalculateCost = 0;
  String formattedCost = '';
  // Conversion of listOfPoints into LatLng(Latitude, Longitude) list of points
  List<LatLng> points = [];
  double sourLatitude = 0;
  double sourLongitude = 0;
  double desLatitude = 0;
  double desLongitude = 0;
  double zoomSize = 15;
  double Latitude = 6.131015;
  double Longitude = 1.223898;
  String display_name_Location = "You address";
  double rideDetailContainerHeigth = 0;
  double requestRideContainerHeigth = 0;
  double searchContainerHeight = 420.0;
  double driverDetailsContainerHeight = 0;
  bool drawerOpen = true;
  bool nearbyAvailableDriverKeysLoaded = false;
  late DatabaseReference rideRequestRef;
  late List<NearbyAvailableDrivers> availableDrivers;
  String state = "normal";
  late StreamSubscription<DatabaseEvent> rideStreamSubscription;
  bool isRequestingPositionDetails = false;
  String uName = "";
  //function adjust requestRideContainerHeight
  Future<void> displayRequestRideContainer() async {
    setState(() {
      requestRideContainerHeigth = 250.0;
      rideDetailContainerHeigth = 0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = true;
    });
   await  saveRideRequest();
  }
  //Tuy chinh ride request detail
  void displayDriverDetailsContainer(){
    setState(() {
      requestRideContainerHeigth = 0.0;
      rideDetailContainerHeigth = 0.0;
      bottomPaddingOfMap = 270.0;
      driverDetailsContainerHeight = 310.0;
    });
  }

  resetApp(){
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 420.0;
      rideDetailContainerHeigth = 0;
      requestRideContainerHeigth = 0;
      bottomPaddingOfMap = 230.0;

      statusRide = "";
      driverName = "";
      driverPhone = "";
      carDetailsDriver = "";
      riderStatus = "Driver is coming";
      driverDetailsContainerHeight = 0.0;
    });
    getLocation();
  }

  MapController _mapController = MapController();
  //vi tri hien tai
  Future<dynamic> getLocation() async{
    _serviceEnabled = await location.serviceEnabled();
    if(!_serviceEnabled) _serviceEnabled = await location.requestService();

    _permissionGranted = await location.hasPermission();
    if(_permissionGranted == Loc.PermissionStatus.denied){
      _permissionGranted = await location.requestPermission();
    }
    _locationData = await location.getLocation();
    var response = await http.get(getinfoLocationUrl(Latitude.toString(),Longitude.toString()));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      display_name_Location = data['display_name'];
      print(data['display_name']);
    }
    print(_locationData);
    setState(() {
      _mapController.move(LatLng(_locationData.latitude!, _locationData.longitude!), zoomSize);
      Latitude = _locationData.latitude!;
      Longitude = _locationData.longitude!;
      display_name_Location ;
    });
    return _locationData;
  }
  //Xu li ham ticket
  void displayRideDetailContainer() async{
    await getLocation();
    setState(() {
      searchContainerHeight = 0;
      rideDetailContainerHeigth = 380.0;
      bottomPaddingOfMap = 380.0;
      drawerOpen = false;
    });
  }
  // Method to consume the OpenRouteService API
  getCoordinates(double sour_lat, double sour_lon, double des_lat, double des_lon) async {
    var response = await http.get(getRouteUrl("$sour_lon,$sour_lat",
        '$des_lon,$des_lat'));
    //print(response.statusCode);
    setState(() {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        listOfPoints = data['features'][0]['geometry']['coordinates'];
        points = listOfPoints
            .map((p) => LatLng(p[1].toDouble(), p[0].toDouble()))
            .toList();
      }
    });
  }
//Tinh khoang cach giua 2 diem
  double calculateDistance(double point1_latitude,double point1_longitude,double point2_latitude,double point2_longitude){
    const double earthRadius = 6371; // Đường kính trái đất (đơn vị kilômét)
    double dLat = _degreesToRadians(point2_latitude - point1_latitude);
    double dLon = _degreesToRadians(point2_longitude - point1_longitude);
    double a = pow(sin(dLat / 2), 2) +
        cos(_degreesToRadians(point1_latitude)) *
            cos(_degreesToRadians(point2_latitude)) *
            pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }
  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
  double calculateTotalDistance(List<LatLng> points) {
    double totalDistance = 0;
    for (int i = 0; i < points.length - 1; i++) {
      LatLng point1 = points[i];
      LatLng point2 = points[i + 1];
      double distance = calculateDistance(
          point1.latitude, point1.longitude, point2.latitude, point2.longitude);
      totalDistance += distance;
    }

    return totalDistance;
  }
  //Tinh thanh tien
  double calculateCost(double distance) {
    double cost = distance * 100.0;
    return cost;
  }
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  double bottomPaddingOfMap = 0;
  //Zoom lon
  void updateZoomSizePlus() {
    setState(() {
      zoomSize = zoomSize +1;
      _mapController.move(LatLng(Latitude, Longitude), zoomSize);
    });
    print(zoomSize);
  }
  //Zoom nho
  void updateZoomSizeMinus(){
    setState(() {
      zoomSize = zoomSize -1;
      _mapController.move(LatLng(Latitude, Longitude), zoomSize);
    });
    print(zoomSize);
  }
  @override
  void initState() {
    super.initState();
    getUserInfor();
    print(widget.firebaseUser?.uid.toString());
    getLocation();
    // initGeoFireListener();
    AssistantMethods.getCurrentOnlineUserInfo();
  }

  final DatabaseReference usersRef = FirebaseDatabase.instance.ref();
  //Save ride request to firebase
  Future<void> saveRideRequest() async {
    rideRequestRef = FirebaseDatabase.instance.ref().child("Ride Requests").push();
    Map pickUpLocMap = {
      "latitude": sourLatitude.toString(),
      "longitude": sourLongitude.toString(),
    };
    Map dropOffLocMap = {
      "latitude": desLatitude.toString(),
      "longitude": desLongitude.toString(),
    };
    String? name;
    String? phone;
    print(widget.firebaseUser!.uid.toString());
    final snapshot = await usersRef.child('users/'+widget.firebaseUser!.uid.toString()).get()
        .then((value) => {

      name = value.child("name").value as String?,
      phone = value.child("phone").value as String?,
      print(name),
      print(name)
    });
    Map rideInfoMap = {
      "driver_id" : "waiting",
      "payment_method" : "cash",
      "pickup" : pickUpLocMap,
      "dropoff" : dropOffLocMap,
      "created_at": DateTime.now().toString(),
      "rider_name": name,
      "rider_phone": phone,
      "pickup_address": PickUpPoint.toString(),
      "dropoff_address": Destination.toString(),
      "ride_type": carRideType,
    };
    print(pickUpLocMap);
    print(dropOffLocMap);
    print(name);
    print(phone);
    rideRequestRef.set(rideInfoMap);
    rideStreamSubscription = rideRequestRef.onValue.listen((event) async {

      if (event.snapshot.value == null) {
        return;
      }
      var snapshotValue = event.snapshot.value as Map<dynamic, dynamic>;

      if (snapshotValue["car_details"] != null) {
        setState(() {
          carDetailsDriver = snapshotValue["car_details"].toString();
        });
      }
      if (snapshotValue["driver_name"] != null) {
        setState(() {
          driverName = snapshotValue["driver_name"].toString();
        });
      }
      if (snapshotValue["driver_phone"] != null) {
        setState(() {
          driverPhone = snapshotValue["driver_phone"].toString();
        });
      }
      if (snapshotValue["driver_location"] != null) {
        double driverLat  = double.parse(snapshotValue["driver_location"]["latitude"].toString());
        double driverLng  = double.parse(snapshotValue["driver_location"]["longitude"].toString());
        LatLng driverCurrentLocation = LatLng(driverLat, driverLng);
        if(statusRide == "accepted"){
          print("ended1 "+ statusRide.toString());
          updateRideTimeToPickUpLoc(driverCurrentLocation);
        }else if(statusRide == "onride"){
          print("ended2 "+ statusRide.toString());
          updateRideTimeToDropOffLoc(driverCurrentLocation);
        }else if(statusRide == "arrived"){
          setState(() {
            riderStatus = "Driver has Arrived.";
          });
        }
      }
      // print("ended3"+ statusRide.toString());
      if (snapshotValue["status"] != null) {
        statusRide = snapshotValue["status"].toString();
      }
      if(statusRide == "accepted"){
        displayDriverDetailsContainer();
        Geofire.stopListener();
        deleteGeofileMarkers();
      }
      if(statusRide == "ended"){
        if(snapshotValue["fares"] != null){
          var res = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context)=> CollectFareDialog(paymentMethod:"cash" ,fareAmount: snapshotValue["fares"],),
          );
          String driverId = "";
          if(res == "close"){
            if(snapshotValue["driver_id"] != null){
              driverId = snapshotValue["driver_id"].toString();
            }
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => RatingScreen(driverId: driverId)));

            rideRequestRef.onDisconnect();
            // rideRequestRef.remove();
            rideStreamSubscription.cancel();
            resetApp();
          }
        }
      }
    });
  }
  void deleteGeofileMarkers(){
    setState(() {
      markers.clear();
    });
  }
  void updateRideTimeToPickUpLoc(LatLng driverCurrentLocation) async{
    if(isRequestingPositionDetails == false){
      isRequestingPositionDetails = true;
      var positionUserLatLng = LatLng(sourLatitude, sourLongitude);
      var details = await getCoordinates(driverCurrentLocation.latitude, driverCurrentLocation.longitude, positionUserLatLng.latitude, positionUserLatLng.longitude);
      if(details == null){
        return;
      }
      setState(() {
        riderStatus = "Driver is coming - "+  details.toString();
      });
      isRequestingPositionDetails = false;
    }
  }
  void updateRideTimeToDropOffLoc(LatLng driverCurrentLocation) async{
    if(isRequestingPositionDetails == false){
      isRequestingPositionDetails = true;

      var dropOffUserLaLng = LatLng(desLatitude, desLongitude);

      var details = await getCoordinates(driverCurrentLocation.latitude, driverCurrentLocation.longitude, dropOffUserLaLng.latitude, dropOffUserLaLng.longitude);
      if(details == null){
        return;
      }
      setState(() {
        riderStatus = "Going to Destination - "+  details.toString();
      });
      isRequestingPositionDetails = false;
    }
  }
  //cancel ride request
  void cancelRideRequest(){
    //  rideRequestRef.remove();
    setState(() {
      state = "normal";
    });
  }
  Future<void> getUserInfor() async {
    final DatabaseReference usersRef = FirebaseDatabase.instance.ref();
    final snapshot = await usersRef.child('users/'+widget.firebaseUser!.uid.toString()).get()
        .then((value) => {
      uName = (value.child("name").value as String?)!,

    });

  }
  @override
  Widget build(BuildContext context) {
    // createIconMarker();
    return Scaffold(
      key: scaffoldKey,
      drawer: Container(
        color: Colors.white,
        width: 255.0,
        child: Drawer(
          child: ListView(
            children: [
              //Drawer header
              Container(
                height: 165.0,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
                    },
                    child: Row(
                      children: [
                        Image.asset("images/user_icon.png", height: 65.0, width: 65.0),
                        SizedBox(width: 16.0),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              uName,
                              style: TextStyle(fontSize: 16.0, fontFamily: "Brand Bold"),
                            ),
                            SizedBox(height: 6.0),
                            Text("Visit Profile"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              DividerWidget(),
              SizedBox(height: 12.0,),
              //Drawer controller
              // ListTile(
              //   leading: Icon(Icons.history),
              //   title: Text("History", style: TextStyle(fontSize: 16.0),),
              // ),
              // ListTile(
              //   leading: Icon(Icons.person),
              //   title: Text("Visit Profile", style: TextStyle(fontSize: 16.0),),
              // ),
              GestureDetector(
                onTap: (){
                  displayToastMessage("Industrial vehicle", context);
                },
                child: ListTile(
                  leading: Icon(Icons.info),
                  title: Text("About", style: TextStyle(fontSize: 16.0),),
                ),
              ),
              GestureDetector(
                onTap: (){
                  FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
                },
                child: ListTile(
                  leading: Icon(Icons.info),
                  title: Text("Sign Out", style: TextStyle(fontSize: 16.0),),
                ),
              ),
            ],
          ),
        ),
      ),
      body:Stack(
        children: [
          Scaffold(
            body: FlutterMap(
              options: MapOptions(
                  zoom: zoomSize,
                  center: LatLng(Latitude, Longitude)
              ),
              mapController: _mapController,
              children: [
                // Layer that adds the map
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                ),
                // Layer that adds points the map
                MarkerLayer(
                  markers: [
                    // First Marker
                    Marker(
                      point: LatLng(sourLatitude == 0 ? Latitude: sourLatitude, sourLongitude == 0 ? Longitude : sourLongitude),
                      width: 80,
                      height: 80,
                      builder: (context) => IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.location_on),
                        color: Colors.green,
                        iconSize: 45,
                      ),
                    ),
                    Marker(
                      point: LatLng(Latitude, Longitude),
                      width: 80,
                      height: 80,
                      builder: (context) => IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.location_on),
                        color: Colors.blue,
                        iconSize: 45,
                      ),
                    ),
                    // Second Marker
                    Marker(
                      point: LatLng(desLatitude == 0 ? Latitude: desLatitude, desLongitude == 0 ? Longitude : desLongitude),
                      width: 80,
                      height: 80,
                      builder: (context) => IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.location_on),
                        color: Colors.red,
                        iconSize: 45,
                      ),
                    ),
                    for (int i = 0; i < markers.length; i++) markers[i]
                  ],
                ),
                // Polylines layer
                PolylineLayer(
                  polylineCulling: false,
                  polylines: [
                    Polyline(
                      points: points,
                      color: Colors.red,
                      strokeWidth: 5,
                      isDotted: true, // Use a dotted line style
                    ),
                  ],
                ),
              ],
            ),
          ),
          //HambugarButton for Drawer
          Positioned(
            top: 38.0,
            left: 22.0,
            child: GestureDetector(
              onTap: () {
                if (scaffoldKey.currentState != null)
                {
                  if(drawerOpen){
                    scaffoldKey.currentState!.openDrawer();
                  }else{
                    resetApp();
                  }
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      ),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon((drawerOpen) ? Icons.menu : Icons.close,color: Colors.black,),
                  radius: 20.0,
                ),
              ),
            ),
          ),
          //Zoom larger map screen
          Positioned(
            top:45.0,
            right: 22.0,
            child: GestureDetector(
              onTap: () {
                getLocation();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.transparent,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      ),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.control_point,color: Color(0xFF00CCFF),size: 50,),
                  radius: 20.0,
                ),
              ),
            ),
          ),
          //Zoom smaller map screen
          Positioned(
            bottom:400.0,
            right: 22.0,
            child: GestureDetector(
              onTap: () {
                updateZoomSizeMinus();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.transparent,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      ),
                    ),
                  ],
                ),

                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.indeterminate_check_box_rounded,color: Color(0xFF00CCFF),size: 50,),
                  radius: 20.0,
                ),
              ),
            ),
          ),
          //Add screen
          Positioned(
            bottom:350.0,
            right: 22.0,
            child: GestureDetector(
              onTap: () {
                updateZoomSizePlus();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.transparent,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      ),
                    ),
                  ],
                ),

                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.add_box,color: Color(0xFF00CCFF),size: 50,),
                  radius: 20.0,
                ),
              ),
            ),
          ),
          //Ride Details Ui
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            //child: SingleChildScrollView(
            child: AnimatedSize(
              curve: Curves.bounceIn,
              duration: new Duration(
                milliseconds: 160,
              ),
              child: Container(
                height: searchContainerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular((18.0)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17.0,vertical: 17.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6.0),
                      Text("Hi There, ",style: TextStyle(fontSize: 20.0,fontFamily: "Brand-Bold"),),
                      Text("Where you go? ",style: TextStyle(fontSize: 15.0,fontFamily: "Brand-Bold"),),
                      //Diem Dau
                      SizedBox(height:10.0 ),
                      GestureDetector(
                        onTap:() async {
                          showProgressDialog() {
                            Future.delayed(Duration(seconds: 3), () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => ProgressDialog(message: "Please wait..."),
                              );
                            });
                          }
                          final  Address address = await  Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen(Latitude: Latitude,Longitude: Longitude,)));
                          if(address != null){
                            setState(() {
                              sourLatitude = address.latitude;
                              sourLongitude = address.longitude;
                              PickUpPoint = address.placeName;
                            });
                            if (desLatitude != 0 && desLongitude != 0){
                              getCoordinates(sourLatitude,sourLongitude,desLatitude,desLongitude);
                            }
                            print('$sourLatitude, $sourLongitude');
                            _mapController.move(LatLng(sourLatitude, sourLongitude), zoomSize);
                          }
                          // displayRideDetailContainer();

                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF00CCFF),
                            borderRadius: BorderRadius.circular(
                                5.0
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 6.0,
                                spreadRadius: 0.5,
                                offset: Offset(0.7, 0.7),
                              )
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(Icons.search,color: Colors.black,),
                                SizedBox(width: 4.0,),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        PickUpPoint.length <= 200
                                            ? PickUpPoint
                                            : PickUpPoint.substring(0, 200),
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      // Text(
                                      //   PickUpPoint.length > 200
                                      //       ? PickUpPoint.substring(200)
                                      //       : "..",
                                      //   style: TextStyle(fontSize: 13),
                                      // ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      //Diem cuoi
                      GestureDetector(
                        onTap:() async {
                          showProgressDialog() {
                            Future.delayed(Duration(seconds: 3), () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => ProgressDialog(message: "Please wait..."),
                              );
                            });
                          }
                          final  Address address = await  Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen(Latitude: Latitude,Longitude: Longitude,)));
                          if(address != null){
                            setState(() {
                              desLatitude =address.latitude;
                              desLongitude = address.longitude;
                              Destination = address.placeName;
                              if (sourLatitude != 0 && sourLongitude != 0){
                                getCoordinates(sourLatitude,sourLongitude,desLatitude,desLongitude);
                                print("dropOff");
                                print(sourLatitude);
                                print(sourLongitude);
                                print("pickup");
                                print(desLatitude);
                                print(desLongitude);
                                List<LatLng> points = [
                                  LatLng(sourLatitude, sourLongitude),
                                  LatLng(desLatitude, desLongitude),
                                ];
                                tripDirectionDetails = calculateTotalDistance(points);
                                totalcalculateCost = calculateCost(tripDirectionDetails);
                                if (totalcalculateCost != null) {
                                  formattedCost = NumberFormat.currency(locale: 'en_US', symbol: '\$').format(totalcalculateCost);
                                } else {
                                  formattedCost = '0 \$';
                                }
                              }
                            });
                            print('$desLatitude, $desLongitude');
                            initGeoFireListener();
                            displayRideDetailContainer();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF00CCFF),
                            borderRadius: BorderRadius.circular(
                                5.0
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 6.0,
                                spreadRadius: 0.5,
                                offset: Offset(0.7, 0.7),
                              )
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: Colors.black),
                                SizedBox(width: 2.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        Destination.length <= 200
                                            ? Destination
                                            : Destination.substring(0, 200),
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      // Text(
                                      //   Destination.length > 40 ? Destination.substring(40) : " ",
                                      //   style: TextStyle(fontSize: 13),
                                      // ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.0,),
                      Row(
                        children: [
                          Icon(Icons.home, color: Color(0xFF00CCFF),),
                          SizedBox(width: 9.0,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                display_name_Location.length <= 90
                                    ? display_name_Location
                                    : display_name_Location.substring(0, 70),
                                style: TextStyle(fontSize: 9),
                              ),
                              Text(
                                display_name_Location.length > 90 && display_name_Location.length <= 180
                                    ? display_name_Location.substring(71,141)
                                    :"",
                                style: TextStyle(fontSize: 9),
                              ),

                              SizedBox(height: 6.0,),
                              Text(
                                "Your living home address",
                                style: TextStyle(color: Colors.blueAccent[200], fontSize: 12.0),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 19.0,),
                      DividerWidget(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          //Cash pay
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: AnimatedSize(
              curve: Curves.bounceIn,
              duration: new Duration(
                milliseconds: 160,
              ),
              child: Container(
                height: rideDetailContainerHeigth,

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight:Radius.circular(16.0),),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7,0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 17.0),
                  child: Column(
                    children: [
                      //bike ride
                      GestureDetector(
                        onTap: () async {
                          displayToastMessage("Searching Bike...", context);
                          setState(() {
                            state = "requesting";
                            carRideType = "bike";
                          });
                         await displayRequestRideContainer();
                        //  availableDrivers = GeoFireAssistant.nearByAvailableDriversList;
                          await searchNearestDriver();
                        },
                        child: Container(
                          width: double.infinity,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                Image.asset("images/bike.png",height: 70.0,width: 80.0,),
                                SizedBox(width: 16.0,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Bike", style: TextStyle(fontSize: 18.0, fontFamily: "Brand-Bold",),
                                    ),
                                    Text(
                                      ((tripDirectionDetails != null) ? tripDirectionDetails.toStringAsFixed(2) + " Km" : " 0 Km"), style: TextStyle(fontSize: 16.0,color: Colors.grey,),
                                    ),
                                  ],
                                ),
                                Expanded(child: Container()),
                                Text(
                                  formattedCost, style: TextStyle(fontFamily: "Brand-Bold",),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0,),
                      Divider(height: 2.0,thickness: 2.0,),
                      SizedBox(height: 10.0,),
                      //uber-go ride
                      GestureDetector(
                        onTap: () async {
                          displayToastMessage("Searching Uber-Go...", context);
                          setState(() {
                            state = "requesting";
                            carRideType="uber-go";
                          });
                          await displayRequestRideContainer();
                        //  availableDrivers = GeoFireAssistant.nearByAvailableDriversList;
                          await searchNearestDriver();
                        },
                        child: Container(
                          width: double.infinity,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                Image.asset("images/ubergo.png",height: 70.0,width: 80.0,),
                                SizedBox(width: 16.0,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Uber-Go", style: TextStyle(fontSize: 18.0, fontFamily: "Brand-Bold",),
                                    ),
                                    Text(
                                      ((tripDirectionDetails != null) ? tripDirectionDetails.toStringAsFixed(2) + " Km" : " 0 Km"), style: TextStyle(fontSize: 16.0,color: Colors.grey,),
                                    ),
                                  ],
                                ),
                                Expanded(child: Container()),
                                Text(
                                  formattedCost, style: TextStyle(fontFamily: "Brand-Bold",),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0,),
                      Divider(height: 2.0,thickness: 2.0,),
                      SizedBox(height: 10.0,),
                      //uber-x ride
                      GestureDetector(
                        onTap: () async {
                          displayToastMessage("Searching Uber-X...", context);
                          setState(() {
                            state = "requesting";
                            carRideType="uber-x";
                          });
                          await displayRequestRideContainer();
                        //  availableDrivers = GeoFireAssistant.nearByAvailableDriversList;
                          await searchNearestDriver();
                        },
                        child: Container(
                          width: double.infinity,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                Image.asset("images/uberx.png",height: 70.0,width: 80.0,),
                                SizedBox(width: 16.0,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Uber-X", style: TextStyle(fontSize: 18.0, fontFamily: "Brand-Bold",),
                                    ),
                                    Text(
                                      ((tripDirectionDetails != null) ? tripDirectionDetails.toStringAsFixed(2) + " Km" : " 0 Km"), style: TextStyle(fontSize: 16.0,color: Colors.grey,),
                                    ),
                                  ],
                                ),
                                Expanded(child: Container()),
                                Text(
                                  formattedCost, style: TextStyle(fontFamily: "Brand-Bold",),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0,),
                      Divider(height: 2.0,thickness: 2.0,),
                      SizedBox(height: 10.0,),
                      Container(
                        color: Color(0xFF00CCFF),
                        height: 60.0,
                        child:  Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: [
                              Icon(FontAwesomeIcons.moneyCheckDollar, size: 18.0, color: Colors.black,),
                              SizedBox(width: 16.0,),
                              Text("Cash"),
                              SizedBox(width: 6.0,),
                              Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 16.0,),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          //Request Cancel Ui
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0),topRight: Radius.circular(16.0),),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 0.5,
                    blurRadius: 16.0,
                    color: Colors.black,
                    offset: Offset(0.7,0.7),
                  ),
                ],
              ),
              height: requestRideContainerHeigth,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    SizedBox(height: 12.0),
                    SizedBox(
                      width: double.infinity,
                      child: ColorizeAnimatedTextKit(
                        onTap: () {
                          print("Tap Event");
                        },
                        text: [
                          'Requesting a Ride...',
                          'Please wait...',
                          'Finding a Driver...',
                        ],
                        textStyle: TextStyle(
                          fontSize: 55.0,
                          fontFamily: 'Signatra',
                        ),
                        colors: [
                          Colors.green,
                          Colors.purple,
                          Colors.pink,
                          Colors.blue,
                          Colors.yellow,
                          Colors.red,
                        ],
                        textAlign: TextAlign.center,
                        //alignment: AlignmentDirectional.topStart,
                      ),
                    ),
                    SizedBox(height: 22.0),
                    GestureDetector(
                      onTap:() async {
                        cancelRideRequest();
                        resetApp();
                      },
                      child: Container(
                        height: 60.0,
                        width: 60.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26.0),
                          border: Border.all(width: 2.0, color: Colors.grey),
                        ),
                        child: Icon(Icons.close,size: 26.0,),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Container(
                      width: double.infinity,
                      child: Text("Cancel Ride",textAlign: TextAlign.center, style: TextStyle(fontSize: 12.0),),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Display Assisned Driver Info
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0),topRight: Radius.circular(16.0),),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 0.5,
                    blurRadius: 16.0,
                    color: Colors.black54,
                    offset: Offset(0.7,0.7),
                  ),
                ],
              ),
              height: driverDetailsContainerHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0,vertical: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 6.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(riderStatus,textAlign: TextAlign.center,style: TextStyle(fontSize: 20.0,fontFamily: "Brand-Bold"),),
                      ],
                    ),
                    SizedBox(height: 22.0,),
                    Divider(height: 2.0, thickness: 2.0,),
                    SizedBox(height: 22.0,),
                    Text(carDetailsDriver, style: TextStyle(color: Colors.grey),),
                    Text(driverName,style: TextStyle(fontSize: 20.0),),
                    SizedBox(height: 22.0,),
                    Divider(height: 2.0, thickness: 2.0,),
                    SizedBox(height: 22.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              launch(('tel://${driverPhone}'));
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF00CCFF)),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(17.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    "Call Driver",
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Icon(
                                    Icons.call,
                                    color: Colors.white,
                                    size: 26.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



//Hien thi driver
  Future<void> initGeoFireListener() async {
    //Geofire.initialize("availableDrivers");
    // Lắng nghe và cập nhật tọa độ từ Firebase
    List<double> doubleArray = [];
    DatabaseReference _locationRef = FirebaseDatabase.instance.ref().child('availableDrivers');
    await  _locationRef.onValue.listen((event) {
      event.snapshot.children.forEach((element) async {
        NearbyAvailableDrivers nearbyAvailableDrivers = NearbyAvailableDrivers();
        nearbyAvailableDrivers.key = element.key as String;
        print(element.key);
        //Lay thong tin loai xe
        await  driversRef.child( element.key as String).child("car_details").child("type").onValue.listen((event) {
          // print("xe"+ event.snapshot.value.toString());
          if ( event.snapshot.value != null) {
            String carType = event.snapshot.value.toString();
            print("Loai xe trong ham khoi tao");
            nearbyAvailableDrivers.type = carType;
            print(carType);
          }
        });

        //Lay thong tin rating cua tai xe
        await  driversRef.child( element.key as String).child("ratings").onValue.listen((event) {
          print("Rating truce ");
          if ( event.snapshot.value != null) {
            print("Rating sau ");
            double ratings = double.parse(event.snapshot.value.toString());
            print("Rating trong ham khoi tao");
            print(ratings);
            nearbyAvailableDrivers.ratings = ratings;

          }
        });

        doubleArray.clear();
        element.children.forEach((valu2) {
          doubleArray.add(valu2.value as double);
          print(valu2.key);
          print(valu2.value);
        });
        nearbyAvailableDrivers.latitude = doubleArray[0];
        nearbyAvailableDrivers.longitude = doubleArray[1];
        GeoFireAssistant.nearByAvailableDriversList.add(nearbyAvailableDrivers);
      });
      // notifyDriver(GeoFireAssistant.nearByAvailableDriversList[0]);
      // availableDrivers.removeAt(0);
    });
    updateAvailableDriversOnMap();
  }
  Future<void> initGeoFireListener2() async {
    //Geofire.initialize("availableDrivers");
    // Lắng nghe và cập nhật tọa độ từ Firebase
    List<double> doubleArray = [];
    DatabaseReference _locationRef = FirebaseDatabase.instance.ref().child('availableDrivers');
    await  _locationRef.onValue.listen((event) {
      event.snapshot.children.forEach((element) async {
        NearbyAvailableDrivers nearbyAvailableDrivers = NearbyAvailableDrivers();
        nearbyAvailableDrivers.key = element.key as String;
        print(element.key);
        //Lay thong tin loai xe
        await  driversRef.child( element.key as String).child("car_details").child("type").onValue.listen((event) {
          // print("xe"+ event.snapshot.value.toString());
          if ( event.snapshot.value != null) {
            String carType = event.snapshot.value.toString();
            print("Loai xe trong ham khoi tao");
            nearbyAvailableDrivers.type = carType;
            print(carType);
          }
        });

        //Lay thong tin rating cua tai xe
        await  driversRef.child( element.key as String).child("ratings").onValue.listen((event) {
          print("Rating truce ");
          if ( event.snapshot.value != null) {
            print("Rating sau ");
            double ratings = double.parse(event.snapshot.value.toString());
            print("Rating trong ham khoi tao");
            print(ratings);
            nearbyAvailableDrivers.ratings = ratings;

          }
        });

        doubleArray.clear();
        element.children.forEach((valu2) {
          doubleArray.add(valu2.value as double);
          print(valu2.key);
          print(valu2.value);
        });
        nearbyAvailableDrivers.latitude = doubleArray[0];
        nearbyAvailableDrivers.longitude = doubleArray[1];
        GeoFireAssistant.nearByAvailableDriversList.add(nearbyAvailableDrivers);
      });
      GeoFireAssistant.nearByAvailableDriversList.forEach((element) {
        if(element.type == carRideType){
          notifyDriver(element);
        }
      });

      GeoFireAssistant.nearByAvailableDriversList.clear();
    });
    updateAvailableDriversOnMap();
  }
//Cap nhat tai xe
  List<Marker> markers = [];
  void updateAvailableDriversOnMap() {
    setState(() {
      markers.clear();
    });
    List<Marker> tMarkers = [];
    for (NearbyAvailableDrivers driver in GeoFireAssistant.nearByAvailableDriversList) {
      print("Distance between driver and customer: ");
      double distanceDriverCustomer = getDistanceFromLatLonInKm(Latitude,Longitude,driver.latitude,driver.longitude);
      print(distanceDriverCustomer);
      if(distanceDriverCustomer < MAXDISTANCE){
        LatLng driverAvailablePosition = LatLng(driver.latitude, driver.longitude);
        Marker marker = Marker(
          point: driverAvailablePosition,
          builder: (ctx) => Container(
            child: Image.asset('images/car_android.png', width: 40, height: 40),
          ),
          width: 40,
          height: 40,
        );
        tMarkers.add(marker);
      }
    }
    setState(() {
      markers = tMarkers;
    });
  }
  double getDistanceFromLatLonInKm(lat1,lon1,lat2,lon2) {
    var R = 6371; // Radius of the earth in km
    var dLat = deg2rad(lat2-lat1);  // deg2rad below
    var dLon = deg2rad(lon2-lon1);
    var a =
        sin(dLat/2) * sin(dLat/2) +
            cos(deg2rad(lat1)) * cos(deg2rad(lat2)) *
                sin(dLon/2) * sin(dLon/2)
    ;
    var c = 2 * atan2(sqrt(a), sqrt(1-a));
    var d = R * c; // Distance in km
    return d;
  }
  double deg2rad(deg) {
    return deg * (pi/180);
  }
//Dialog noDriverFound
  void noDriverFound(){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => NoDriverAvailableDialog()
    );
  }
  void SapXepTheoKhoangCachTangDan(List<NearbyAvailableDrivers> listAvailableDrivers){
    int n = listAvailableDrivers.length;
    bool swapped;

    do {
      swapped = false;

      for (int i = 0; i < n - 1; i++) {
        if (listAvailableDrivers[i].ratings < listAvailableDrivers[i + 1].ratings) {
          // Swap arr[i] and arr[i+1]
          NearbyAvailableDrivers temp = listAvailableDrivers[i];
          listAvailableDrivers[i] = listAvailableDrivers[i + 1];
          listAvailableDrivers[i + 1] = temp;
          swapped = true;
        }
      }
    } while (swapped);
  }

  NearbyAvailableDrivers findFilter(List<NearbyAvailableDrivers> listAvailableDrivers){
    List<NearbyAvailableDrivers> filteredDrivers = [];

    for( NearbyAvailableDrivers driver in listAvailableDrivers){
            if (driver.type == carRideType){
              filteredDrivers.add(driver);
            }
          }

    //SapXepTheoKhoangCachTangDan(filteredDrivers);


    // Tạo một danh sách xác suất dựa trên số sao của tài xế
    // final List<double> probabilities = filteredDrivers.map((driver) {
    //   return driver.ratings / 5.0; // Số sao chia cho 5 để có xác suất từ 0 đến 1
    // }).toList();


    //random tai xe dua tren so sao (xac xuat tich luy)
    // final random = Random();
    // final randNum = random.nextDouble();
    //
    // double cumulativeProb = 0;
    //
    // for (int i = 0; i < filteredDrivers.length; i++) {
    //   cumulativeProb += probabilities[i];
    //   if (randNum < cumulativeProb) {
    //     return filteredDrivers[i];
    //   }
    // }

    return filteredDrivers[0];

  }
//Tim kiem xe gan
  Future<void> searchNearestDriver()  async {
      await  initGeoFireListener2();

    // availableDrivers = GeoFireAssistant.nearByAvailableDriversList;

    if(availableDrivers.isEmpty){
      cancelRideRequest();
      resetApp();
      noDriverFound();
      return;
    }
    // String tokenTest = 'f5gfcX1QSnSC4dDGyp_-A9:APA91bF1dbXZrAEJAeNbP5SveSYYV8PddR2tpOtAaGjbn-CGG8iKUzca3NrdVQkaFwd4CsdHv4FGJY0cgGM9T2p5KA0PZiqv4Q-MRLOvhmf0zjJYDz-u9sOUZYaNgQrDha9GooLUgYyf';
    // AssistantMethods.sendNotificationToDriver(
    //     tokenTest, context, '-NjaKq1q3H8A8Sf57JgE');
    // return;

    // notifyDriver(findFilter(availableDrivers));
    // availableDrivers.removeAt(0);
    // var driver = findFilter(availableDrivers);
    //
    // driversRef.child(driver.key).child("car_details").child("type").onValue.listen((event) {
    //   print("xe"+ event.snapshot.value.toString());
    //   if ( event.snapshot.value != null) {
    //     String carType = event.snapshot.value.toString();
    //     if (carType == carRideType) {
    //       notifyDriver(driver);
    //       availableDrivers.removeAt(0);
    //     }
    //     else {
    //       displayToastMessage(
    //           carRideType + " drivers not available. Try again", context);
    //     }
    //   } else {
    //     displayToastMessage("No car found. Try again", context);
    //   }
    // });
  }
  //Send new request
  Future<void> notifyDriver(NearbyAvailableDrivers drivers)  async {
    DatabaseReference driversRef = FirebaseDatabase.instance.ref(
        "drivers/${drivers.key}");
    driversRef.child("newRide").set(rideRequestRef.key.toString());
    print("Id tai xe");

    driversRef.child("token").once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        String token = snapshot.value.toString();
        print("Token tai xe");
        print(token);
        AssistantMethods.sendNotificationToDriver(
            token, context, rideRequestRef.key);
        return;
      }
      const oneSecondPassed = Duration(seconds: 1);
      var timer = Timer.periodic(oneSecondPassed, (timer) {
        if (state != "requesting") {
          driversRef.child(drivers.key).child("newRide").set("cancelled");
          driversRef.child(drivers.key).child("newRide").onDisconnect();
          driverRequestTimeOut = 20;
          timer.cancel();
        }

        driverRequestTimeOut = driverRequestTimeOut - 1;

        driversRef
            .child(drivers.key)
            .child("newRide")
            .onValue
            .listen((event) {
          print("event" + event.snapshot.value.toString());
          if (event.snapshot.value.toString() == "accepted") {
            driversRef.child(drivers.key).child("newRide").onDisconnect();
            driverRequestTimeOut = 20;
            timer.cancel();
          }
        });
        if (driverRequestTimeOut == 0) {
          driversRef.child(drivers.key).child("newRide").set("timeout");
          driversRef.child(drivers.key).child("newRide").onDisconnect();
          driverRequestTimeOut = 20;
          timer.cancel();

          searchNearestDriver();
        }
      });
    });
  }
}
// void getRideType(){
//   rideRequestRef.child(userCurrentInfo!.id).child("car_details").child("type").once().then((DatabaseEvent event){
//     DataSnapshot snapshot = event.snapshot;
//     if(snapshot.value != null){
//       setState(() {
//         rideType =  snapshot.value.toString();
//       });
//     }
//   });
// }