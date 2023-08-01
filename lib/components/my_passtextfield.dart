import 'package:flutter/material.dart';

import '../utils.dart';

class MyPassTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const MyPassTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  }) : super(key: key);

  @override
  _MyPassTextFieldState createState() => _MyPassTextFieldState();
}

class _MyPassTextFieldState extends State<MyPassTextField> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        child: TextField(
          controller: widget.controller,
          obscureText: _isObscure,
          decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white10),
            ),
            fillColor: Colors.white,
            filled: true,
            hintText: widget.hintText,
            hintStyle: SafeGoogleFont(
              'Lato',
              fontSize: 16,
              color: Colors.grey,
            ),
            suffixIcon: IconButton(
              icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _isObscure = !_isObscure;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
