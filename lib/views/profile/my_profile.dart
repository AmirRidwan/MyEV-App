import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils.dart';
import 'edit_profile.dart';

class MyProfile extends StatefulWidget {
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final User? user = FirebaseAuth.instance.currentUser;
  String defaultUrl =
      'https://firebasestorage.googleapis.com/v0/b/evfinder-ad6f0.appspot.com/o/default_avatar.png?alt=media&token=aabd68a9-29ce-4f99-9c7b-7b47fae2070a';

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
          "My Profile",
          style: SafeGoogleFont(
            'Lato',
            fontSize:  36,
            fontWeight:  FontWeight.bold,
            color:  Color(0xff2d366f),
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Color(0xff9dd1ea),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: StreamBuilder<DocumentSnapshot<Object?>>(
          stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>?;

            final profileImageUrl = userData?['profileImageUrl'] as String?;
            final firstName = userData?['firstName'] as String? ?? '';
            final lastName = userData?['lastName'] as String? ?? '';
            final phoneNumber = userData?['phoneNumber'] as String? ?? '';
            final email = userData?['email'] as String? ?? '';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15),
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(profileImageUrl)
                        : NetworkImage(defaultUrl),
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 15),
                _buildProfileField('First Name', firstName),
                SizedBox(height: 16.0),
                _buildProfileField('Last Name', lastName),
                SizedBox(height: 16.0),
                _buildProfileField('Phone Number', phoneNumber),
                SizedBox(height: 16.0),
                _buildProfileField('Email', email),
                SizedBox(height: 25),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditProfile()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xff2d366f),
                      ),
                      child: Text(
                        "Edit Profile",
                        style: SafeGoogleFont(
                          'Lato',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: SafeGoogleFont(
              'Lato',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff2d366f),
            ),
          ),
          SizedBox(height: 8.0, width: 356),
          Text(
            value,
            style: SafeGoogleFont(
              'Lato',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
