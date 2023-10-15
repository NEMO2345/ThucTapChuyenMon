// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class CustomStarRating extends StatelessWidget {
  final double rating;
  final Color color;
  final bool allowHalfRating;
  final int starCount;
  final double size;

  const CustomStarRating({
    required this.rating,
    required this.color,
    required this.allowHalfRating,
    required this.starCount,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        IconData starIcon;
        if (index >= rating) {
          starIcon = Icons.star_border;
        } else if (index > rating - (allowHalfRating ? 0.5 : 1.0) && index < rating) {
          starIcon = Icons.star_half;
        } else {
          starIcon = Icons.star;
        }

        return Icon(
          starIcon,
          color: color,
          size: size,
        );
      }),
    );
  }
}