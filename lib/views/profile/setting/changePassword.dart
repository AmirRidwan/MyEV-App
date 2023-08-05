import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../utils.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _isCurrentPasswordObscure = true;
  bool _isNewPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;

  void _toggleCurrentPasswordVisibility() {
    setState(() {
      _isCurrentPasswordObscure = !_isCurrentPasswordObscure;
    });
  }

  void _toggleNewPasswordVisibility() {
    setState(() {
      _isNewPasswordObscure = !_isNewPasswordObscure;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordObscure = !_isConfirmPasswordObscure;
    });
  }

  void _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!,
            password: _currentPasswordController.text,
          );

          await user.reauthenticateWithCredential(credential);

          await user.updatePassword(_newPasswordController.text);

          // Password changed successfully
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password changed successfully!')),
          );

          // Navigate back to the settings page
          Navigator.of(context).pop();
        }
      } catch (e) {
        // Handle error here (e.g., incorrect current password, network error, etc.)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error changing password: $e')),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xff2d366f)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          "Change Password",
          style: SafeGoogleFont(
            'Lato',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xff2d366f),
          ),
          textAlign: TextAlign.center,
        ),
        elevation: 2.0,
        backgroundColor: Color(0xff9dd1ea),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: _isLoading
              ? CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 4.0),
                            child: TextFormField(
                              controller: _currentPasswordController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Current Password',
                                suffixIcon: IconButton(
                                  onPressed: _toggleCurrentPasswordVisibility,
                                  icon: Icon(_isCurrentPasswordObscure
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                ),
                              ),
                              obscureText: _isCurrentPasswordObscure,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your current password.';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 4.0),
                            child: TextFormField(
                              controller: _newPasswordController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'New Password',
                                suffixIcon: IconButton(
                                  onPressed: _toggleNewPasswordVisibility,
                                  icon: Icon(
                                    _isNewPasswordObscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                              ),
                              obscureText: _isNewPasswordObscure,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your new password.';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters long.';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 4.0),
                            child: TextFormField(
                              controller: _confirmPasswordController,
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                  onPressed: _toggleConfirmPasswordVisibility,
                                  icon: Icon(
                                    _isConfirmPasswordObscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                              ),
                              obscureText: _isConfirmPasswordObscure,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your new password.';
                                }
                                if (value != _newPasswordController.text) {
                                  return 'Passwords do not match.';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xff2d366f),
                          ),
                          onPressed: _changePassword,
                          child: Text(
                              'Change Password',
                            style: SafeGoogleFont(
                              'Lato',
                              fontSize:  16,
                              fontWeight:  FontWeight.bold,
                              color:  Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
