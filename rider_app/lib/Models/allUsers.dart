import 'package:firebase_database/firebase_database.dart';

class Users {
  late String id;
  late String email;
  late String name;
  late String phone;

  Users({required this.id, required this.email, required this.name, required this.phone});

  Users.fromSnapshot(DataSnapshot dataSnapshot) {
    id = dataSnapshot.key!;
    var data = dataSnapshot.value as Map<String, dynamic>?;

    email = (data?["email"] as String?) ?? "";
    name = (data?["name"] as String?) ?? "";
    phone = (data?["phone"] as String?) ?? "";
  }
}