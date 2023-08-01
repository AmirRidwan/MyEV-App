import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evfinder/base/color_data.dart';
import 'package:evfinder/views/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/my_button.dart';
import '../components/my_passtextfield.dart';
import '../components/my_textfield.dart';
import '../utils.dart';
import 'forgot_pw_page.dart';

class LoginPage extends StatefulWidget {
  final bool showRegisterPage;
  final VoidCallback toggleScreens;

  const LoginPage(
      {Key? key, required this.showRegisterPage, required this.toggleScreens})
      : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text controller
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void toggleScreens() {
    setState(() {
      widget.toggleScreens(); // Call the toggleScreens callback
    });
  }

  Future<void> _login(BuildContext context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        String role = userData['role'];

        if (role == 'user') {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin');
        }
      } else {
        // Role doesn't exist, login as user by default
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print('Login error: $e');
      if (e is FirebaseAuthException) {
        showErrorMessage(e.code);
      } else {
        showErrorMessage('An error occurred');
      }
      // Handle login error
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blueAccent,
          title: Center(
            child: Text(
              message,
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe2e2e2),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // logo
                  Container(
                    height: 300,
                    width: 300,
                    child: const Image(
                      image: AssetImage('assets/images/myev-logo.png'),
                    ),
                  ),
                  // welcome back, you've been missed!
                  Center(
                    child: Text(
                      'LOGIN',
                      style: SafeGoogleFont(
                        'Lato',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xbf000000),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // email textfield
                  MyTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    obscureText: false,
                  ),

                  const SizedBox(height: 10),

                  // password textfield
                  MyPassTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),

                  const SizedBox(height: 10),

                  // forgot password?
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ForgotPasswordPage();
                                },
                              ),
                            );
                          },
                          child: Text(
                            'Forget Password?',
                            style: SafeGoogleFont(
                              'Lato',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // sign in button
                  MyButton(
                    text: "LOGIN",
                    onTap: () async => await _login(context),
                  ),

                  const SizedBox(height: 25),

                  // not a member? register now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Not a member?',
                        style: SafeGoogleFont(
                          'Lato',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return RegisterPage(
                                showRegisterPage: true,
                                toggleScreens: widget.toggleScreens,
                              );
                            }),
                          );
                        },
                        child: Text(
                          'Register now',
                          style: SafeGoogleFont(
                            'Lato',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
