import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evfinder/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../components/my_button.dart';
import '../components/my_passtextfield.dart';
import '../components/my_textfield.dart';
import 'home/home_page.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  final bool showRegisterPage;
  final VoidCallback toggleScreens;

  const RegisterPage({
    Key? key,
    required this.showRegisterPage,
    required this.toggleScreens,
  }) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void toggleScreens() {
    setState(() {
      widget.toggleScreens(); // Call the toggleScreens callback
    });
  }

  bool _isLoading = false;

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });

    final String firstName = _firstNameController.text.trim();
    final String lastName = _lastNameController.text.trim();
    final String phoneNumber = _phoneNumberController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    try {
      if (password != confirmPassword) {
        throw FirebaseAuthException(
            code: 'passwords-mismatch', message: 'Passwords do not match.');
      }

      // Create user in Firebase Authentication
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the generated user ID
      final String userId = userCredential.user!.uid;

      // Save additional user data to Firestore with role as "user"
      await _firestore.collection('users').doc(userId).set({
        'userId': userId, // Include the user ID in the database
        'firstName': firstName,
        'lastName': lastName,
        'displayName': '$firstName $lastName',
        'phoneNumber': phoneNumber,
        'email': email,
        'role': 'user', // Set the role as "user"
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful!')),
      );

      // Navigate to home page after successful registration
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed.';

      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (e.code == 'passwords-mismatch') {
        errorMessage = 'Passwords do not match.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again later.')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffe2e2e2),
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
                    height: 250,
                    width: 250,
                    child: const Image(
                      image: AssetImage('assets/images/myev-logo.png'),
                    ),
                  ),
                  // let's create an account for you
                  Center(
                    child: Text(
                      'SIGN UP',
                      style: SafeGoogleFont(
                        'Lato',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xbf000000),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Firstname textfield
                  MyTextField(
                    controller: _firstNameController,
                    hintText: 'First Name',
                    obscureText: false,
                  ),

                  const SizedBox(height: 10),

                  // Lastname textfield
                  MyTextField(
                    controller: _lastNameController,
                    hintText: 'Last Name',
                    obscureText: false,
                  ),

                  const SizedBox(height: 10),

                  // Age textfield
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      child: IntlPhoneField(
                        controller: _phoneNumberController,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: 'Phone Number',
                          hintStyle: SafeGoogleFont(
                            'Lato',
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

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

                  // confirm password textfield
                  MyPassTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                    obscureText: true,
                  ),

                  const SizedBox(height: 25),

                  // sign in button
                  MyButton(
                    text: "SIGN UP",
                    onTap: _register,
                  ),

                  const SizedBox(height: 25),

                  // already have an account?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
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
                              return LoginPage(
                                showRegisterPage: false,
                                toggleScreens: widget.toggleScreens,
                              );
                            }),
                          );
                        },
                        child: Text(
                          'Login now',
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
