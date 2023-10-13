// ignore_for_file: file_names
import 'package:drivers_app/Models/history.dart';
import 'package:flutter/cupertino.dart';

class AppData extends ChangeNotifier{

  String earnings = "0";
  int tripCounters = 0;
  List<String> tripHistoryKeys = [];
  List<History> tripHistoryDataList = [];


  void updateEarnings(String updatedEarnings){
    earnings = updatedEarnings;
    notifyListeners();
  }

  void updateTripsCounter(int tripCounter){
    tripCounters = tripCounter;
    notifyListeners();
  }

  void updateTripKeys(List<String> newKeys){
    tripHistoryKeys = newKeys;
    notifyListeners();
  }

  void updateTripHistoryData(History eachHistory){
    tripHistoryDataList.add(eachHistory);
    notifyListeners();
  }

  void clearTripHistoryData(){
    tripHistoryKeys.clear();
    tripHistoryDataList.clear();
  }
}