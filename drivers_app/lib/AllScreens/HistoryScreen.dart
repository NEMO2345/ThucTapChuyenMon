// ignore_for_file: file_names, prefer_const_constructors

import 'package:drivers_app/AllScreens/tripDetailScreen.dart';
import 'package:drivers_app/AllWidgets/Historyitem.dart';
import 'package:drivers_app/DataHandler/appData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}


class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip History'),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.keyboard_arrow_left),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(0),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Điều hướng đến trang chi tiết thông tin chuyến đi
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TripDetailsScreen(
                    trip: Provider.of<AppData>(context, listen: false).tripHistoryDataList[index],
                  ),
                ),
              );
            },
            child: HistoryItem(
              history: Provider.of<AppData>(context, listen: false).tripHistoryDataList[index],
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) => Divider(thickness: 3.0, height: 3.0),
        itemCount: Provider.of<AppData>(context, listen: false).tripHistoryDataList.length,
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
      ),
    );
  }
}