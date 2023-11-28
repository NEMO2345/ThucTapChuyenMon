// ignore_for_file: file_names, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers

import 'package:drivers_app/Assistants/AssistantMethods.dart';
import 'package:drivers_app/Models/history.dart';
import 'package:flutter/material.dart';

class HistoryItem extends StatelessWidget {

  final History history;
  const HistoryItem({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16,vertical: 16),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Row(
                  children: <Widget>[
                    Image.asset('images/pickicon.png',height: 16,width: 16,),
                    SizedBox(width: 18,),
                    Expanded(child: Container(child: Text(history.pickup.substring(0,45),overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 18),))),
                    SizedBox(width: 5,),
                    Text('\$${history.fares}',style: TextStyle(fontFamily: 'Brand Bold',fontSize: 16,color: Colors.black),),
                  ],
                ),
              ),

              SizedBox(height: 8,),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Image.asset('images/desticon.png',height: 16,width: 7.7,),
                  SizedBox(width: 18,),
                  Text(history.dropOff.substring(0,45),overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 18),),

                ],
              ),

              SizedBox(height: 15,),
              Text(AssistantMethods.formatTripDate(history.createdAt),style: TextStyle(color: Colors.grey),),
            ],
          ),
        ],
      ),
    );
  }
}


