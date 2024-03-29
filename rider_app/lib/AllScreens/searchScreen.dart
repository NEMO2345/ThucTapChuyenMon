// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:rider_app/Models/address.dart';
class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key, required this.Latitude, required this.Longitude} ) : super(key: key);
  final double Latitude;
  final double Longitude;
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    final double latitude = widget.Latitude;
    final double longitude = widget.Longitude;
    return Scaffold(
      appBar: AppBar(
      title: const Text(
        'Search',
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      backgroundColor: Colors.orange,
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
    ),
      body: OpenStreetMapSearchAndPick(
          center: LatLong(latitude, longitude),
          buttonColor: Colors.orange,
          buttonText: 'Set Location',
          onPicked: (pickedData) {
            Address address = Address();
            address.placeName = pickedData.addressName;
            address.latitude = pickedData.latLong.latitude;
            address.longitude = pickedData.latLong.longitude;
            Navigator.pop(context, address);
          }
      )
    );
  }
}
