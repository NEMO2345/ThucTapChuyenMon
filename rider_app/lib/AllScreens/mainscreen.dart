// ignore_for_file: prefer_const_constructors, unnecessary_import, library_private_types_in_public_api, prefer_final_fields, unnecessary_new, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, sort_child_properties_last, prefer_interpolation_to_compose_strings, use_build_context_synchronously, avoid_print

import 'dart:async';



import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:rider_app/AllScreens/searchScreen.dart';
import 'package:rider_app/AllWidgets/Divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../Models/address.dart';
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



class _MainScreenState extends State<MainScreen> {

  // Raw coordinates got from  OpenRouteService
  List listOfPoints = [];

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

  MapController _mapController = MapController();
///vi tri hien tai
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
     getLocation();
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
                        points: points, color: Colors.black, strokeWidth: 5),
                  ],
                ),
              ],
            ),

          ), //HambugarButton for Drawer
          Positioned(
            top:45.0,
            left: 22.0,
            child: GestureDetector(
              onTap: () {
                if (scaffoldKey.currentState != null) {
                  scaffoldKey.currentState!.openDrawer();
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
                  child: Icon(Icons.menu,color: Colors.black,),
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
          ),
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
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Container(
              height: 300.0,
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0,vertical: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 6.0),
                    Text("Hi There, ",style: TextStyle(fontSize: 12.0),),
                    Text("Where to? ",style: TextStyle(fontSize: 20.0,fontFamily: "Brand-Bold"),),
                    SizedBox(height:20.0 ),
                    GestureDetector(
                      onTap:() async {
                        final  Address address = await  Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen(Latitude: Latitude,Longitude: Longitude,)));
                       if(address != null){
                         setState(() {
                           sourLatitude = address.latitude;
                           sourLongitude = address.longitude;
                         });
                         if (desLatitude != 0 && desLongitude != 0){

                         }
                         print('$sourLatitude, $sourLongitude');

                         _mapController.move(LatLng(sourLatitude, sourLongitude), zoomSize);
                       }

                     },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                           5.0
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black54,
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
                              Icon(Icons.search,color: Colors.blueAccent,),
                              SizedBox(width: 10.0,),
                              Text("Sour"),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0,),
                    GestureDetector(
                      onTap:() async {
                        final  Address address = await  Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen(Latitude: Latitude,Longitude: Longitude,)));
                       if(address != null){
                         setState(() {
                           desLatitude =address.latitude;
                           desLongitude = address.longitude;
                           if (sourLatitude != 0 && sourLongitude != 0){
                             getCoordinates(sourLatitude,sourLongitude,desLatitude,desLongitude);
                           }
                         });
                         print('$desLatitude, $desLongitude');
                       }

                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                              5.0
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black54,
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
                              Icon(Icons.search,color: Colors.blueAccent,),
                              SizedBox(width: 10.0,),
                              Text("Destination"),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.0,),
                    Row(
                      children: [
                        Icon(Icons.home,color: Colors.grey,),
                        SizedBox(width: 12.0,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              display_name_Location.length <= 45
                                  ? display_name_Location
                                  : display_name_Location.substring(0, 45),

                            ),
                            Text(
                              display_name_Location.length > 45
                                  ? display_name_Location.substring(45)
                                  : " ",

                            ),
                            SizedBox(height: 4.0,),
                            Text(
                              "Your living home address",
                              style: TextStyle(color: Colors.grey[200], fontSize: 12.0),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 10.0,),
                    DividerWidget(),


                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

