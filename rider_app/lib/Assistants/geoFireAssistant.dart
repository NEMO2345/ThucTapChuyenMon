// ignore_for_file: list_remove_unrelated_type, unrelated_type_equality_checks

import 'dart:math';

import 'package:rider_app/Models/nearbyAvailableDrivers.dart';

class GeoFireAssistant{
  static List<NearbyAvailableDrivers> nearByAvailableDriversList = [];

  static void removeDriverFromList(String key){
    int index = nearByAvailableDriversList.indexWhere((element) => element.key == key);
    nearByAvailableDriversList.remove(index);
  }

  static void updateDriverNearByLocation(NearbyAvailableDrivers driver){
    int index = nearByAvailableDriversList.indexWhere((element) => element.key == driver.key);
    nearByAvailableDriversList[index].latitude = driver.latitude;
    nearByAvailableDriversList[index].longitude = driver.longitude;
  }

  static double createRandomNumber(int num){
    var random = Random();
    int randNumber = random.nextInt(num);
    return randNumber.toDouble();
  }
}