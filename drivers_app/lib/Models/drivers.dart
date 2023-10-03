// ignore_for_file: non_constant_identifier_names

import 'package:firebase_database/firebase_database.dart';

class Drivers {
  late String name;
  late String phone;
  late String email;
  late String id;
  late String car_color;
  late String car_model;
  late String car_number;

  Drivers({
    required this.name,
    required this.phone,
    required this.email,
    required this.id,
    required this.car_color,
    required this.car_model,
    required this.car_number,
  });

  Drivers.fromSnapshot(DataSnapshot dataSnapshot) {
    id = dataSnapshot.key!;
    var value = dataSnapshot.value as Map<Object?, Object?>?;
    if (value != null) {
      phone = value["phone"] as String? ?? "";
      email = value["email"] as String? ?? "";
      name = value["name"] as String? ?? "";

      var carDetails = value["car_details"] as Map<Object?, Object?>?;
      if (carDetails != null) {
        car_color = carDetails["car_color"] as String? ?? "";
        car_model = carDetails["car_model"] as String? ?? "";
        car_number = carDetails["car_number"] as String? ?? "";
      }
    }
  }
}