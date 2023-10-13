// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, avoid_print
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
          color: Color(0xFF00CCFF),
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 70),
            child: Column(
              children: [
                Text("Total Earnings", style: TextStyle(color: Colors.black,fontSize: 20),),
                Text("\$${Provider.of<AppData>(context,listen: false).earnings}", style: TextStyle(color: Colors.black,fontSize: 50,fontFamily: 'Brand Bold'),)
              ],
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(0),
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryScreen()));
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 18),
            child: Row(
              children: [
                Image.asset('images/uberx.png', width: 70,),
                SizedBox(width: 16),
                Text('Total Trips', style: TextStyle(fontSize: 16),),
                Expanded(child: Container(child: Text(Provider.of<AppData>(context,listen: false). tripCounters.toString(), textAlign: TextAlign.end, style: TextStyle(fontSize: 18),),),),
              ],
            ),
          ),
        ),
        Divider(height: 2.0,thickness: 2.0,),
      ],
    );
  }
}
