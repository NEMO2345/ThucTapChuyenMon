// ignore_for_file: prefer_const_constructors, unnecessary_import, library_private_types_in_public_api, prefer_final_fields, unnecessary_new, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, sort_child_properties_last, prefer_interpolation_to_compose_strings, use_build_context_synchronously, avoid_print

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/AllScreens/searchScreen.dart';
import 'package:rider_app/AllWidgets/Divider.dart';
import 'package:rider_app/Assistants/assistantMethods.dart';
import 'package:rider_app/DataHandle/appData.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "mainScreen";

  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  //GoogleMap
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController newGoogleMapController;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  late Position currentPosition;
  var geoLocator = Geolocator();
  double bottomPaddingOfMap = 0;


// Kiểm tra và yêu cầu quyền truy cập vị trí
  void checkLocationPermission() async {
    PermissionStatus status = await Permission.locationWhenInUse.status;

    if (status.isDenied) {
      // Hiển thị thông báo yêu cầu quyền
      await Permission.locationWhenInUse.request();
    }

    if (status.isGranted) {
      // Quyền truy cập vị trí đã được cấp, tiếp tục xử lý vị trí
      locatePositon();
    } else {
      // Quyền truy cập vị trí bị từ chối, xử lý trường hợp này
      // Hiển thị thông báo cho người dùng hoặc chuyển hướng đến cài đặt thiết bị
    }
  }
  void locatePositon() async{
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);
    //Geocoding : Chuyen doi toa do dia ly thanh v tri cu the
    CameraPosition cameraPosition = new CameraPosition(target: latLngPosition,zoom: 14);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address = await AssistantMethods.searchCoordinateAddress(position,context);
    print("This is your Address :: " + address);

    //print("Địa chỉ: ${position.toString()}");
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
      target: LatLng(37.4279613380664, - 122.08574955962),
      zoom: 14.4745,
  );
  //Googlemap

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
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            onMapCreated: (GoogleMapController controller)
            {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              setState(() {
                bottomPaddingOfMap = 265.0;
              });

              checkLocationPermission();
            },
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
                      onTap:(){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen()));
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
                              Text("Search Drop off"),
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
                                //Provider.of<AppData>(context)?.pickUpLocation?.placeName ?? "Add Home"
                              "449, Tang Nhon Phu A, Thu Duc city"
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
                    SizedBox(height: 16.0,),

                    Row(
                      children: [
                        Icon(Icons.work,color: Colors.grey,),
                        SizedBox(width: 12.0,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Add Work"),
                            SizedBox(height: 4.0,),
                            Text("Your office address",style: TextStyle(color: Colors.grey[200],fontSize:12.0 ),),

                          ],
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
}

