// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
  }

  class _SettingsPageState extends State<SettingsScreen> {
  bool notificationEnabled = true;
  bool darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
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
        children: [
          buildSettingItem(
            'Notifications',
            Switch(
              value: notificationEnabled,
              onChanged: (value) {
                setState(() {
                  notificationEnabled = value;
                  displayToastMessage(
                      notificationEnabled ? "Notifications On" : "Notifications Off",
                      context);
                });
              },
            ),
          ),
          buildSettingItem(
            'Language',
            Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LanguageSettingsPage(),
                ),
              );
            },
          ),
          buildSettingItem(
            'Account Information',
            Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (context) => InformationUserPage())
              // );
            },
          ),
        ],
      ),
    );
  }
  Widget buildSettingItem(String title, Widget trailing, {VoidCallback? onTap}) {
    return ListTile(
      title: Text(title),
      trailing: trailing,
      onTap: onTap,
    );
  }
  void displayToastMessage(String message, BuildContext context) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  }

class LanguageSettingsPage extends StatelessWidget {
  final List<String> languageList = ['Tiếng Việt', 'English', 'Español', 'Français', 'Deutsch', 'Italiano'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Language',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.orange,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: ListView.builder(
        itemCount: languageList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(languageList[index]),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${languageList[index]} has been chooser'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}