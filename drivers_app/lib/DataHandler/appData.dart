// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';

class AppData extends ChangeNotifier{

  String earnings = "0";

  void updateEarnings(String updatedEarnings){
    earnings = updatedEarnings;
    notifyListeners();
  }

}