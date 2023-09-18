// ignore_for_file: prefer_const_constructors, unnecessary_import, library_private_types_in_public_api, prefer_final_fields, unnecessary_new, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, sort_child_properties_last, prefer_interpolation_to_compose_strings, use_build_context_synchronously, avoid_print, non_constant_identifier_names, library_prefixes, unused_label, cast_from_null_always_fails, unnecessary_null_comparison, unused_element, unnecessary_cast, unused_local_variable, deprecated_member_use, depend_on_referenced_packages

import 'dart:async';

import 'package:drivers_app/configMaps.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:drivers_app/AllScreens/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart' as Loc;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_map/flutter_map.dart';


class HomeTabPage extends StatefulWidget {

  late TapUpDetails details;

  HomeTabPage({Key? key}) : super(key: key);

  @override
  _HomeTabPage createState() => _HomeTabPage();
}

Loc.Location location = new Loc.Location();
bool _serviceEnabled = false;
Loc.PermissionStatus _permissionGranted = Loc.PermissionStatus.denied;
Loc.LocationData _locationData = null as Loc.LocationData;

class _HomeTabPage extends State<HomeTabPage> with TickerProviderStateMixin {
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


  MapController _mapController = MapController();

//vi tri hien tai
  Future<dynamic> getLocation() async {
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

    return _locationData;
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

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  double bottomPaddingOfMap = 0;


  void updateZoomSizePlus() {
    setState(() {
      zoomSize = zoomSize + 1;
      _mapController.move(LatLng(Latitude, Longitude), zoomSize);
    });
    print(zoomSize);
  }

  void updateZoomSizeMinus() {
    setState(() {
      zoomSize = zoomSize - 1;
      _mapController.move(LatLng(Latitude, Longitude), zoomSize);
    });
    print(zoomSize);
  }

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
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
                    point: LatLng(sourLatitude == 0 ? Latitude : sourLatitude,
                        sourLongitude == 0 ? Longitude : sourLongitude),
                    width: 80,
                    height: 80,
                    builder: (context) =>
                        IconButton(
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
                    builder: (context) =>
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.location_on),
                          color: Colors.blue,
                          iconSize: 45,
                        ),
                  ),
                  // Second Marker
                  Marker(
                    point: LatLng(desLatitude == 0 ? Latitude : desLatitude,
                        desLongitude == 0 ? Longitude : desLongitude),
                    width: 80,
                    height: 80,
                    builder: (context) =>
                        IconButton(
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
                  Icons.control_point, color: Colors.white, size: 50,),
                radius: 20.0,
              ),
            ),
          ),
        ), //Get position
        Positioned(
          bottom: 400.0,
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
                child: Icon(
                  Icons.indeterminate_check_box_rounded, color: Colors.white,
                  size: 50,),
                radius: 20.0,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 350.0,
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
                child: Icon(Icons.add_box, color: Colors.white, size: 50,),
                radius: 20.0,
              ),
            ),
          ),
        ),
        Container(
          height: 140.0,
          width: double.infinity,
          color: Colors.black54,
        ),

        Positioned(
          top: 60.0,
          left: 0.0,
          right: 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // RenderBox box = context.findRenderObject() as RenderBox;
                    // var details;
                    // var localPosition = box.globalToLocal(details.globalPosition);
                    // var tapPosition = _mapController.center;
                    makerDriverOnlineNow();
                    getLocationLiveUpdates();
                    // saveLocationToFirebase(tapPosition);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green, // Đặt màu xanh lá cho nút
                    padding: EdgeInsets.all(17.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Offline Now - Go Online",
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Icon(
                        Icons.phone_android,
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
      ],
    );
  }
  void makerDriverOnlineNow() async {
    Geolocator geolocator = Geolocator();

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    double latitude = position.latitude;
    double longitude = position.longitude;

    Map<String, dynamic> myLocation = {
      "latitude": latitude,
      "longitude": longitude,
    };

    DatabaseReference driversRef = FirebaseDatabase.instance.reference().child(
        "availableDrivers");
    await driversRef.child(currentfirebaseUser!.uid).set(myLocation);
  }
  void getLocationLiveUpdates() {
    homeTabPageStreamSubscription = Geolocator.getPositionStream().listen(
          (Position position) {
        if (currentfirebaseUser != null) {
          Geofire.setLocation(
            currentfirebaseUser!.uid,
            position.latitude,
            position.longitude,
          );
        }
        LatLng latLng = LatLng(position.latitude, position.longitude);
        if (_mapController != null) {
          _mapController.move(latLng, zoomSize);
        }
      },
    );
  }

// void getLocationLiveUpdates() {
  //   StreamSubscription<Position> homeTabPageStreamSubscription;
  //   homeTabPageStreamSubscription =
  //       Geolocator.getPositionStream().listen((Position position) {
  //         var currentPosition = position;
  //         Geofire.setLocation(
  //             currentfirebaseUser!.uid, position.latitude, position.longitude);
  //         LatLng latLng = LatLng(position.latitude, position.longitude);
  //         _mapController.move(latLng, zoomSize);
  //       });
  // }
  //
  // void getLocationLiveUpdates() {
  //   StreamSubscription<Position> homeTabPageStreamSubscription;
  //   homeTabPageStreamSubscription =
  //       Geolocator.getPositionStream().listen((Position position) {
  //         var currentPosition = position;
  //         Geofire.setLocation(
  //             currentfirebaseUser!.uid, position.latitude, position.longitude);
  //         LatLng latLng = LatLng(position.latitude, position.longitude);
  //         _mapController.move(latLng, zoomSize);
  //       });
  // }
  //
  // void saveLocationToFirebase(LatLng tapPosition) async {
  //   double latitude = tapPosition.latitude;
  //   double longitude = tapPosition.longitude;
  //
  //   Map<String, dynamic> myLocation = {
  //     "latitude": latitude,
  //     "longitude": longitude,
  //   };
  //
  //   DatabaseReference driversRef = FirebaseDatabase.instance.reference().child("availableDrivers");
  //   await driversRef.child(currentfirebaseUser!.uid).set(myLocation);
  // }
}





