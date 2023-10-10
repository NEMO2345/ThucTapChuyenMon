// ignore_for_file: use_key_in_widget_constructors, avoid_unnecessary_containers

import 'package:flutter/cupertino.dart';

class MarkerWidget extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;
  final double rotation;

  const MarkerWidget({
    required this.imagePath,
    required this.width,
    required this.height,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Transform.rotate(
        angle: rotation,
        child: Image.asset(imagePath, width: width, height: height),
      ),
    );
  }
}