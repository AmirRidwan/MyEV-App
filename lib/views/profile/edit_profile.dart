import 'dart:io';

import 'package:evfinder/base/color_data.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../../utils.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  File? _profileImage;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    if (userData.exists) {
      setState(() {
        _firstNameController.text = userData['firstName'];
        _lastNameController.text = userData['lastName'];
        _phoneNumberController.text = userData['phoneNumber'];
        _emailController.text = userData['email'];
        _profileImageUrl = userData['profileImageUrl'];
      });
    }
  }

  Future<void> _updateProfile() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();
    final email = _emailController.text.trim();

    try {
      String displayName = '$firstName $lastName';

      // Update the email in Firebase Authentication
      if (email != user?.email) {
        await user?.updateEmail(email);
      }

      String? newProfileImageUrl = _profileImageUrl;

      // Upload the new profile image if it has changed
      if (_profileImage != null) {
        final fileName = '${user!.uid}_profile_image.jpg';
        final destination = 'profile_images/$fileName';
        final storageRef = firebase_storage.FirebaseStorage.instance.ref(destination);
        await storageRef.putFile(_profileImage!);
        newProfileImageUrl = await storageRef.getDownloadURL();
      }

      // Update the profile information in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'email': email,
        'profileImageUrl': newProfileImageUrl,
        'displayName': displayName, // Update the display name in Firestore
      });

      setState(() {
        _profileImageUrl = newProfileImageUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile. $error')),
      );
    }
  }

  Future<void> _deleteProfilePicture() async {
    if (_profileImageUrl != null) {
      try {
        // Delete the profile picture from Firebase Storage
        await firebase_storage.FirebaseStorage.instance
            .refFromURL(_profileImageUrl!)
            .delete();

        // Delete the profileImageUrl field in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({'profileImageUrl': null});

        setState(() {
          _profileImageUrl = null;
          _profileImage = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile picture deleted successfully!')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete profile picture. $error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No profile picture to delete.')),
      );
    }
  }




  Future<void> _pickProfilePicture() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("_profileImageUrl: $_profileImageUrl");
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xff2d366f)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          "Edit Profile",
          style: SafeGoogleFont(
            'Lato',
            fontSize:  24,
            fontWeight:  FontWeight.bold,
            color:  Color(0xff2d366f),
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color(0xff9dd1ea),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Center(
                child: InkWell(
                  onTap: _pickProfilePicture,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : (_profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : AssetImage('assets/images/user.png')) as ImageProvider<Object>?,
                    backgroundColor: Colors.white,
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: _pickProfilePicture,
                            color: buttonColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: _deleteProfilePicture,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text(
                    "Delete Profile Picture",
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),
              Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                child: TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    labelText: 'First Name',
                    labelStyle: SafeGoogleFont(
                      'Lato',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    hintText: 'Enter your first name',
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                child: TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    labelText: 'Last Name',
                    labelStyle: SafeGoogleFont(
                      'Lato',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    hintText: 'Enter your last name',
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                child: TextFormField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    labelText: 'Phone Number',
                    labelStyle: SafeGoogleFont(
                      'Lato',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    hintText: 'Enter your phone number',
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(height: 25),
              Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    labelText: 'Email',
                    labelStyle: SafeGoogleFont(
                      'Lato',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    hintText: 'Enter your email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(height: 25),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton(
                    onPressed: _updateProfile,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xff2d366f),
                    ),
                    child: Text(
                      "Save Profile",
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
