// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget
{
  late String message;
  ProgressDialog({required this.message});
  @ override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Color(0xFF00CCFF),
      child: Container(
        margin: EdgeInsets.all(15.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              SizedBox(width: 6.0,),
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black),),
              SizedBox(width: 26.0,),
              Text(
                message,
                style: TextStyle(color: Colors.black,fontSize: 10.0) ,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

