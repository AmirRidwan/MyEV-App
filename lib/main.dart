import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:evfinder/views/admin/AdminHomePage.dart';
import 'package:evfinder/views/home/home_page.dart';
import 'package:evfinder/views/login_page.dart';
import 'package:evfinder/views/register_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'auth/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MyEV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AnimatedSplashScreen(
        splashIconSize: double.infinity,
        splash: Center(
          child: Container(
            height: 300,
            width: 300,
            child: const Image(
              image: AssetImage('assets/images/myev-logo.png'),
            ),
          ),
        ),
        nextScreen: LoginPage(
          showRegisterPage: false,
          toggleScreens: () {
            Navigator.pushNamed(context, '/register');
          },
        ),
        splashTransition: SplashTransition.fadeTransition,
        duration: 3000,
      ),
      routes: {
        '/home': (context) => HomePage(),
        '/admin': (context) => AdminHomePage(),
        '/register': (context) => RegisterPage(
              showRegisterPage: true,
              toggleScreens: () {
                Navigator.pushNamed(context, '/');
              },
            ),
      },
    );
  }
}
