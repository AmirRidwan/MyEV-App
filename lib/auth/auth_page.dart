import 'package:flutter/material.dart';

import '../views/login_page.dart';
import '../views/register_page.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showRegisterPage = false;

  void toggleScreens() {
    setState(() {
      showRegisterPage = !showRegisterPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showRegisterPage
        ? LoginPage(
      showRegisterPage: showRegisterPage,
      toggleScreens: toggleScreens,
    )
        : RegisterPage(
      showRegisterPage: showRegisterPage,
      toggleScreens: toggleScreens,
    );
  }
}
