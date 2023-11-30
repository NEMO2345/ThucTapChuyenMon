// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, avoid_print, sized_box_for_whitespace
import 'package:drivers_app/AllScreens/HistoryScreen.dart';
import 'package:drivers_app/DataHandler/appData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EarningTabPage extends StatelessWidget {
  const EarningTabPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/earning.png"),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 70),
            child: Column(
              children: [
                Text(
                  "Total Earnings",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                  ),
                ),
                Text(
                  "\$${Provider.of<AppData>(context, listen: false).earnings}",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 70,
                    fontFamily: 'Brand Bold',
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(height: 8.0, thickness: 2.0),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HistoryScreen()),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 18),
            child: Row(
              children: [
                Image.asset('images/uberx.png', width: 70),
                SizedBox(width: 16),
                Text('Total Trips', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Container(
                    child: Text(
                      Provider.of<AppData>(context, listen: false)
                          .tripCounters
                          .toString(),
                      textAlign: TextAlign.end,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(height: 2.0, thickness: 2.0),
        Container(
          height: 429,
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: 3,
            itemBuilder: (context, index) {
              List<Widget> images = [
                Image.asset('images/chooseCar.png'),
                Divider(height: 2.0, thickness: 0.0),
                Image.asset('images/chooseCar1.png'),
                Divider(height: 2.0, thickness: 0.0),
                Image.asset('images/chooseCar2.png'),
              ];
              return Container(
                height: 300,
                child: AspectRatio(
                  aspectRatio: 500 / 300,
                  child: PageView(
                    children: [
                      images[index],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}