// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, deprecated_member_use, must_be_immutable, file_names, library_private_types_in_public_api, unused_field, prefer_final_fields, unrelated_type_equality_checks, non_constant_identifier_names, avoid_print, unnecessary_cast, unnecessary_null_comparison, unnecessary_type_check

import 'dart:io';

import 'package:drivers_app/AllScreens/registerationScreen.dart';
import 'package:drivers_app/configMaps.dart';
import 'package:drivers_app/main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChangeInfo extends StatefulWidget {
  @override
  _ChangeInfoState createState() => _ChangeInfoState();
}

class _ChangeInfoState extends State<ChangeInfo> {
  File? image;
  String? temporaryImage;

  TextEditingController nameTextEdittingController = TextEditingController();
  TextEditingController emailTextEdittingController = TextEditingController();
  TextEditingController phoneTextEdittingController = TextEditingController();
  TextEditingController carColorTextEdittingController = TextEditingController();
  TextEditingController carModelTextEdittingController = TextEditingController();
  TextEditingController carNumberTextEdittingController = TextEditingController();
  TextEditingController carTypeTextEdittingController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Change Information',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.orange,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 15),
        children: [
          InkWell(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      _uploadImage();
                    },
                    child: CircleAvatar(
                      radius: 100.0,
                      backgroundImage: temporaryImage != null ? FileImage(File(temporaryImage!)) as ImageProvider<Object>?
                          : driversInformation!.image != null
                          ? NetworkImage(
                          driversInformation!.image as String) as ImageProvider<
                          Object>?
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    driversInformation!.name ?? "Ly",
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: "Brand Bold",
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                ],
              ),
            ),
          ),
          Container(
            height: 1,
            color: Colors.grey,
            margin: EdgeInsets.symmetric(horizontal: 16),
          ),
          SizedBox(height: 10.0),
          TextField(
            controller: nameTextEdittingController,
            decoration: InputDecoration(
              labelText: 'Enter a new drivers name',
              prefixIcon: Icon(Icons.man),
            ),
          ),
          SizedBox(height: 10.0),
          TextField(
            controller: emailTextEdittingController,
            decoration: InputDecoration(
              labelText: 'Enter a new email',
              prefixIcon: Icon(Icons.email),
            ),
          ),
          TextField(
            controller: phoneTextEdittingController,
            decoration: InputDecoration(
              labelText: 'Enter a new phone',
              prefixIcon: Icon(Icons.phone),
            ),
          ),
          TextField(
            controller: carColorTextEdittingController,
            decoration: InputDecoration(
              labelText: 'Enter a new car colors',
              prefixIcon: Icon(Icons.collections_bookmark_sharp),
            ),
          ),
          TextField(
            controller: carModelTextEdittingController,
            decoration: InputDecoration(
              labelText: 'Enter a new car model',
              prefixIcon: Icon(Icons.confirmation_number_outlined),
            ),
          ),
          DropdownButtonFormField<String>(
            value: carTypeTextEdittingController.text.isNotEmpty
                ? carTypeTextEdittingController.text
                : null,
            onChanged: (String? newValue) {
              carTypeTextEdittingController.text = newValue!;
            },
            decoration: InputDecoration(
              labelText: 'Enter a new type',
              prefixIcon: Icon(Icons.directions_car),
            ),
            items: <String>[
              'bike',
              'uber-go',
              'uber-x',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          SizedBox(height: 10.0),
          SizedBox(height: 30),
          Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if(nameTextEdittingController.text.length < 4){
                    displayToastMessage("Name must be at-least 3 characters.", context);
                    }else if(!emailTextEdittingController.text.contains("@")){
                    displayToastMessage("Email address is not Valid.", context);
                    }else if(phoneTextEdittingController.text.isEmpty) {
                      displayToastMessage("Phone Number is madatory.", context);
                    }else if(carColorTextEdittingController.text.isEmpty){
                      displayToastMessage("Car color is not empty.", context);
                    }else if(carModelTextEdittingController.text.isEmpty){
                      displayToastMessage("Car model is not empty.", context);
                    }else if(carTypeTextEdittingController.text.isEmpty){
                      displayToastMessage("Please choose car type.", context);
                    }else{
                      changeInfo();
                    }

                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    textStyle: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontFamily: 'Brand Bold',
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: Colors.yellow,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text('Update'),
                ),
                SizedBox(width: 55),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    onPrimary: Colors.white,
                    textStyle: TextStyle(
                      fontSize: 15,
                      fontFamily: 'Brand Bold',
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Cancel'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage.path);
        temporaryImage = pickedImage.path;
      });
    }
  }

  Future<void> changeInfo() async {
    String newName = nameTextEdittingController.text;
    String newEmail = emailTextEdittingController.text;
    String newPhone = phoneTextEdittingController.text;
    String newCarColor = carColorTextEdittingController.text;
    String newCarModel = carModelTextEdittingController.text;
    String newCarType = carTypeTextEdittingController.text;
    // Upload image to Firebase Storage
    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = storage.ref().child('images/$imageName');
    await ref.putFile(image!);
    String imageUrl = await ref.getDownloadURL();

    driversRefUpdate.update({
        "email": newEmail,
        "name": newName,
        "phone": newPhone,
        "image": imageUrl,
      }).then((value) {}).catchError((error) {
        displayToastMessage("Error + $error", context);
      });
    driversRefUpdateCarDetail.update({
        "car_color": newCarColor,
        "car_model": newCarModel,
        "type": newCarType,
      }).then((value) {
        displayToastMessage("Update Successfully.", context);
        Navigator.pop(context);
      }).catchError((error) {
        displayToastMessage("Error + $error", context);
      });
  }
}