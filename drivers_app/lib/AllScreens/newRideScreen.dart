// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, non_constant_identifier_names, prefer_final_fields, must_call_super, unnecessary_import, library_prefixes, unnecessary_new, cast_from_null_always_fails, avoid_print, prefer_const_literals_to_create_immutables, sort_child_properties_last, avoid_unnecessary_containers, deprecated_member_use, unnecessary_null_comparison, constant_identifier_names
import 'dart:math';
import 'package:drivers_app/Assistants/mapKitAssistant.dart';
import 'package:drivers_app/Models/rideDetails.dart';
import 'package:drivers_app/configMaps.dart';
import 'package:drivers_app/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:drivers_app/AllScreens/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart' as Loc;

import '../AllWidgets/MarkerWidget.dart';
class NewRideScreen extends StatefulWidget {
  const NewRideScreen({Key? key, required this.rideDetails}) : super(key: key);
  final RideDetails rideDetails;

  @override
  _NewRideScreenState createState() => _NewRideScreenState();
}
Loc.Location location = new Loc.Location();
bool _serviceEnabled = false;
Loc.PermissionStatus _permissionGranted = Loc.PermissionStatus.denied;
Loc.LocationData _locationData = null as Loc.LocationData;
const double MAXDISTANCE = 15000;
class _NewRideScreenState extends State<NewRideScreen> with TickerProviderStateMixin {
  // Raw coordinates got from  OpenRouteService
  List listOfPoints = [];
  String PickUpPoint = "";
  String Destination = "";
  double tripDirectionDetails = 0;
  double totalcalculateCost = 0;
  String formattedCost = '';
  List<LatLng> points = [];
  double sourLatitude = 0;
  double sourLongitude = 0;
  double desLatitude = 0;
  double desLongitude = 0;
  double zoomSize = 15;
  double Latitude = 0;
  double Longitude =0;
  String display_name_Location = "You address";
  double rideDetailContainerHeigth = 0;
  double requestRideContainerHeigth = 0;
  double searchContainerHeight = 310.0;
  bool drawerOpen = true;



  MapController _mapController = MapController();

  var geolocator = Geolocator();
  String status = "accepted";
  String durationRide = "10 mins";
  bool isRequestingDirection = false;


  //vi tri hien tai
  Future<dynamic> getLocation() async {

    LatLng oldPos = LatLng(0, 0);
    var root = MapKitAssistant.getMarkerRotation(oldPos.latitude, oldPos.longitude, Latitude, Longitude);

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) _serviceEnabled = await location.requestService();

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == Loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
    }
    _locationData = await location.getLocation();


    var response = await http.get(
        getinfoLocationUrl(Latitude.toString(), Longitude.toString()));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      display_name_Location = data['display_name'];
      print(data['display_name']);
    }


    print(_locationData);
    setState(() {
      _mapController.move(
          LatLng(_locationData.latitude!, _locationData.longitude!), zoomSize);
      Latitude = _locationData.latitude!;
      Longitude = _locationData.longitude!;
      display_name_Location;
    });
    acceptRideRequest();
    oldPos = LatLng(Latitude, Longitude);
    updateRideDetails();
    String rideRequestId = widget.rideDetails.ride_request_id;
    DatabaseReference rideRequestRef = newRequestsRef.child(rideRequestId);
    Map<String, String> locMap = {
      "latitude": Latitude.toString(),
      "longitude": Longitude.toString(),
    };
    rideRequestRef.child("driver_location").set(locMap);
   // initGeoFireListener();
    return _locationData;
  }

  void initWay() {
    setState(() {
      sourLatitude = widget.rideDetails.pickup.latitude;
      sourLongitude = widget.rideDetails.pickup.longitude;
      desLatitude = widget.rideDetails.dropoff.latitude;
      desLongitude = widget.rideDetails.dropoff.longitude;
      getCoordinates(sourLatitude,sourLongitude,desLatitude,desLongitude);
    });
  }
  // Method to consume the OpenRouteService API
  getCoordinates(double sour_lat, double sour_lon, double des_lat,
      double des_lon) async {
    var response = await http.get(getRouteUrl("$sour_lon,$sour_lat",
        '$des_lon,$des_lat'));
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
  @override
  void initState() {
    super.initState();
    getLocation();
    initWay();
  }

  @override
  Widget build(BuildContext context) {
    LatLng oldPos = LatLng(0, 0);
    var root = MapKitAssistant.getMarkerRotation(oldPos.latitude, oldPos.longitude, Latitude, Longitude);


    return Scaffold(
      body: Stack(
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
                      point: LatLng(sourLatitude == 0 ? Latitude : sourLatitude, sourLongitude == 0 ? Longitude : sourLongitude),
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
                      point: LatLng(desLatitude == 0 ? Latitude : desLatitude, desLongitude == 0 ? Longitude : desLongitude),
                      width: 80,
                      height: 80,
                      builder: (context) => IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.location_on),
                        color: Colors.red,
                        iconSize: 45,
                      ),
                    ),
                    Marker(
                      point: LatLng(Latitude, Longitude),
                      builder: (ctx) => GestureDetector(
                        onTap: () {

                        },
                        child: MarkerWidget(
                          imagePath: 'images/car_android.png',
                          width: 40,
                          height: 40,
                          rotation: MapKitAssistant.getMarkerRotation(oldPos.latitude, oldPos.longitude, Latitude, Longitude),
                        ),
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

          Positioned(
            top: 45.0,
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
                  child: Icon(
                    Icons.control_point, color: Colors.blue, size: 50,),
                  radius: 20.0,
                ),
              ),
            ),
          ), //Get position

          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0),topRight: Radius.circular(16.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 16.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7,0.7),
                  ),
                ],
              ),
              height: 270.0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0,vertical: 18.0),
                child: Column(
                  children: [

                    Text(
                      durationRide,
                      style: TextStyle(fontSize: 14.0, fontFamily: "Brand-Bold",color: Colors.deepPurple),
                    ),

                    SizedBox(height: 6.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Pham Ly",style: TextStyle(fontFamily: "Brand-Bold",fontSize: 24.0),),
                        Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: Icon(Icons.phone_android),

                        ),
                      ],
                    ),

                    SizedBox(height: 26.0,),
                    Row(
                      children: [
                        Image.asset("images/pickicon.png",height: 16.0,width: 16.0,),
                        SizedBox(width: 18.0,),
                        Expanded(
                          child: Container(
                            child: Text(
                              "Street, 449",
                              style: TextStyle(fontSize: 18.0),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.0,),
                    Row(
                      children: [
                        Image.asset("images/desticon.png",height: 16.0,width: 16.0,),
                        SizedBox(width: 18.0,),
                        Expanded(
                          child: Container(
                            child: Text(
                              "Street, XaloHN",
                              style: TextStyle(fontSize: 18.0),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 26.0,),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor,
                          padding: EdgeInsets.all(17.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Arrived",
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Icon(
                              Icons.directions_car,
                              color: Colors.white,
                              size: 26.0,
                            ),
                          ],
                        ),
                      ),
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

  void acceptRideRequest() {
    String rideRequestId = widget.rideDetails.ride_request_id;
    DatabaseReference rideRequestRef = newRequestsRef.child(rideRequestId);

    rideRequestRef.child("status").set("accepted");
    rideRequestRef.child("driver_name").set(driversInformation?.name);
    rideRequestRef.child("driver_phone").set(driversInformation?.phone);
    rideRequestRef.child("driver_id").set(driversInformation?.id);
    rideRequestRef.child("car_details").set('${driversInformation?.car_color} - ${driversInformation?.car_model} - ${driversInformation?.car_number}');

    Map<String, String> locMap = {
      "latitude": Latitude.toString(),
      "longitude": Longitude.toString(),
    };
   rideRequestRef.child("driver_location").set(locMap);

   print(locMap);
  }
  void updateRideDetails() async{

    if(isRequestingDirection == false){
      isRequestingDirection = true;
      if(Latitude == null && Longitude == null){
        return;
      }
      var posLatLng = LatLng(Latitude, Longitude);
      LatLng destinationLatLng;
      if(status == "accepted"){
        destinationLatLng = widget.rideDetails.pickup;
      }else{
        destinationLatLng = widget.rideDetails.dropoff;
      }
      var directionDetails = await getinfoLocationUrl(posLatLng as String, destinationLatLng as String);
      if(directionDetails != null){
        setState(() {
          durationRide =  directionDetails.durationText;
        });
      }
      isRequestingDirection = false;
    }
  }
}







