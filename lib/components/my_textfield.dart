import 'package:flutter/material.dart';

import '../utils.dart';

class MyTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white10),
              ),
              fillColor: Colors.white,
              filled: true,
              hintText: hintText,
              hintStyle: SafeGoogleFont(
                'Lato',
                fontSize: 16,
                color: Colors.grey,
              ),
          ),
        ),
      ),
    );
  }
}