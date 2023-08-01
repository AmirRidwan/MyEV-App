import 'package:evfinder/base/color_data.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String text;

  const MyButton({
    super.key,
    required this.onTap,
    required this.text
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(10),
          color: buttonColor,
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                text,
                style: SafeGoogleFont(
                  'Lato',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}