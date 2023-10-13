import 'package:firebase_database/firebase_database.dart';

class History{
  late String paymentMethod;
  late String createdAt;
  late String status;
  late String fares;
  late String dropOff;
  late String pickup;

  History({
    required this.paymentMethod,
    required this.createdAt,
    required this.status,
    required this.fares,
    required this.dropOff,
    required this.pickup,
  });

  // History.fromSnapshot(DataSnapshot snapshot){
  //   var data = snapshot.value as Map<String, dynamic>?;
  //   paymentMethod = (data?["payment_method"] as String?) ?? "";
  //   createdAt = (data?["created_at"] as String?) ?? "";
  //   status = (data?["status"] as String?) ?? "";
  //   fares = (data?["fares"] as String?) ?? "";
  //   dropOff = (data?["dropoff_address"] as String?) ?? "";
  //   pickup = (data?["pickup_address"] as String?) ?? "";
  // }
}