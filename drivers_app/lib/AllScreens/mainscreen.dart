// ignore_for_file: prefer_const_constructors, unnecessary_import, library_private_types_in_public_api, prefer_final_fields, unnecessary_new, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, sort_child_properties_last, prefer_interpolation_to_compose_strings, use_build_context_synchronously, avoid_print, non_constant_identifier_names, library_prefixes, unused_label, cast_from_null_always_fails, unnecessary_null_comparison, unused_element, unnecessary_cast, unused_local_variable
import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:drivers_app/AllScreens/loginScreen.dart';
import 'package:drivers_app/AllWidgets/Divider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:drivers_app/Assistants/AssistantMethods.dart';
import 'package:drivers_app/configMaps.dart';
import 'api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart' as Loc;





class MainScreen extends StatefulWidget {
  static const String idScreen = "mainScreen";

  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

Loc.Location location = new Loc.Location();
bool _serviceEnabled = false;
Loc.PermissionStatus _permissionGranted = Loc.PermissionStatus.denied;
Loc.LocationData _locationData = null as Loc.LocationData;



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
  double searchContainerHeight = 310.0;

  bool drawerOpen = true;

  late DatabaseReference rideRequestRef;

  //function adjust requestRideContainerHeight
  void displayRequestRideContainer(){
    setState(() {
      requestRideContainerHeigth = 250.0;
      rideDetailContainerHeigth = 0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = true;
    });
    saveRideRequest();
  }

  resetApp(){
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 300.0;
      rideDetailContainerHeigth = 0;
      requestRideContainerHeigth = 0;
      bottomPaddingOfMap = 230.0;
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
        rideDetailContainerHeigth = 300.0;
        bottomPaddingOfMap = 230.0;
        drawerOpen = false;
    });

}

  // Method to consume the OpenRouteService API
  getCoordinates(double sour_lat, double sour_lon, double des_lat, double des_lon) async {

    var response = await http.get(getRouteUrl("$sour_lon,$sour_lat",
        '$des_lon,$des_lat'));
    // Requesting for openrouteservice api
    // var response = await http.get(getRouteUrl("1.243344,6.145332",
    //     '1.2160116523406839,6.125231015668568'));
    // var distance = jsonDecode(response.body)['features'][0]['summary']['distance'];
    print(response.statusCode);
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
  // double calculateDistanceBetweenPoints(List<LatLng> points, int index1, int index2) {
  //   if (points.length <= index1 || points.length <= index2) {
  //     throw ArgumentError('Invalid index');
  //   }
  //
  //   LatLng point1 = points[index1];
  //   LatLng point2 = points[index2];
  //
  //   return calculateDistance(
  //       point1.latitude, point1.longitude, point2.latitude, point2.longitude);
  // }
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
//end
  //Tinh tien
  double calculateCost(double distance) {
    double cost = distance * 100.0;
    return cost;
  }

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();


  double bottomPaddingOfMap = 0;

  void updateZoomSizePlus() {
    setState(() {
      zoomSize = zoomSize +1;
      _mapController.move(LatLng(Latitude, Longitude), zoomSize);
    });
    print(zoomSize);
  }
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
     getLocation();
    //  vsync: this;
    // duration: Duration(milliseconds: 500);
    AssistantMethods.getCurrentOnlineUserInfo();
  }

  void saveRideRequest(){
      rideRequestRef = FirebaseDatabase.instance.ref().child("Ride Requests").push();

      Map pickUpLocMap = {
        "latitude": sourLatitude.toString(),
        "longitude": sourLongitude.toString(),

      };
      Map dropOffLocMap = {
        "latitude": desLatitude.toString(),
        "longitude": desLongitude.toString(),
      };

      Map rideInfoMap = {
        "driver_id" : "waiting",
        "payment_method" : "cash",
        "pickup" : pickUpLocMap,
        "dropoff" : dropOffLocMap,
        "created_at": DateTime.now().toString(),
        "rider_name": userCurrentInfo?.name,
        "rider_phone": userCurrentInfo?.phone,
        "pickup_address": PickUpPoint.toString(),
        "dropoff_address": Destination.toString(),
      };
      rideRequestRef.set(rideInfoMap);

  }

  void cancelRideRequest(){
    rideRequestRef.remove();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Main Screen"),
      ),
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
                  child: Row(
                    children: [
                      Image.asset("images/user_icon.png",height: 65.0,width: 65.0,),
                      SizedBox(width: 16.0,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Profile Name",style: TextStyle(fontSize: 16.0,fontFamily: "Brand-Bold"),),
                          SizedBox(height: 6.0,),
                          Text("Visit Profile"),
                        ],
                      ),
                    ],
                  ),
                  ),
              ),

              DividerWidget(),
              SizedBox(height: 12.0,),

              //Drawer controller
              ListTile(
                leading: Icon(Icons.history),
                title: Text("History", style: TextStyle(fontSize: 16.0),),

              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text("Visit Profile", style: TextStyle(fontSize: 16.0),),

              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text("About", style: TextStyle(fontSize: 16.0),),

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
                  ],
                ),

                // Polylines layer
                PolylineLayer(
                  polylineCulling: false,
                  polylines: [
                    Polyline(
                      //Line chi duong
                        points: points, color: Colors.red, strokeWidth: 5),
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
                  child: Icon(Icons.control_point,color: Colors.white,size: 50,),
                  radius: 20.0,
                ),
              ),
            ),
          ),//Get position
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
                  child: Icon(Icons.indeterminate_check_box_rounded,color: Colors.white,size: 50,),
                  radius: 20.0,
                ),
              ),
            ),
          ),

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
                  child: Icon(Icons.add_box,color: Colors.white,size: 50,),
                  radius: 20.0,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}


