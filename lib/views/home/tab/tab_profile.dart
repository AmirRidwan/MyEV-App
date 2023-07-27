import 'package:evfinder/utils.dart';
import 'package:evfinder/views/profile/my_booking.dart';
import 'package:evfinder/views/profile/my_car.dart';
import 'package:evfinder/views/profile/my_profile.dart';
import 'package:evfinder/views/profile/my_favourite.dart';
import 'package:evfinder/views/profile/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../components/my_button.dart';
import '../../profile/settings.dart';

class TabProfile extends StatefulWidget {
  const TabProfile({Key? key}) : super(key: key);

  @override
  State<TabProfile> createState() => _TabProfileState();
}

class _TabProfileState extends State<TabProfile> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    print('Current User: ${user?.email}');

    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 60),

          // profile pic
          SizedBox(
            child: Column(
              children: [
                Center(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return Text('No data available for the current user.');
                      }

                      Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

                      final profileImageUrl = data['profileImageUrl'] as String?;
                      final defaultImageUrl =
                          'https://firebasestorage.googleapis.com/v0/b/evfinder-ad6f0.appspot.com/o/default_avatar.png?alt=media&token=aabd68a9-29ce-4f99-9c7b-7b47fae2070a'; // Replace with your default profile image URL

                      return CircleAvatar(
                        radius: 50,
                        backgroundImage: profileImageUrl != null
                            ? NetworkImage(profileImageUrl)
                            : NetworkImage(defaultImageUrl),
                        backgroundColor: Colors.white,
                      );
                    },
                  ),
                ),

                //user display name
                Container(
                  child: Center(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return Text('No data available for the current user.');
                        }

                        Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

                        return Column(
                          children: [
                            SizedBox(height: 10),
                            Text(
                              '${data['firstName']} ${data['lastName']}',
                              style: SafeGoogleFont('Lato',
                              fontSize:  18,
                              fontWeight:  FontWeight.bold,
                              color:  Colors.black,),),
                          ],
                        );
                      },
                ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          //My profile
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (BuildContext context){
                      return MyProfile();
                    }
                )
                );
              },
              child: Container(
                height: 60,
                width: 356,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Row(
                  children: <Widget>[
                    Image.asset(
                        "assets/images/user.png",
                      width: 45,
                      height: 45,
                    ),
                    SizedBox(width: 20),
                    Center(
                      child: Text(
                        "My Profile",
                        style: SafeGoogleFont(
                          'Lato',
                          fontSize:  18,
                          fontWeight:  FontWeight.bold,
                          color:  Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          //My Favourite
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (BuildContext context){
                      return const Favourite();
                    }
                )
                );
              },
              child: Container(
                height: 60,
                width: 356,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Row(
                  children: <Widget>[
                    Image.asset(
                        "assets/images/bookmark.png",
                      width: 45,
                      height: 45,
                    ),
                    SizedBox(width: 20),
                    Center(
                      child: Text(
                        "My Favourite",
                        style: SafeGoogleFont(
                          'Lato',
                          fontSize:  18,
                          fontWeight:  FontWeight.bold,
                          color:  Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          //My booking
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (BuildContext context){
                      return MyBooking(currentUserId: user!.uid);
                    }
                )
                );
              },
              child: Container(
                height: 60,
                width: 356,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Row(
                  children: <Widget>[
                    Image.asset(
                        "assets/images/booking.png",
                      width: 45,
                      height: 45,
                    ),
                    SizedBox(width: 20),
                    Center(
                      child: Text(
                        "My Booking",
                        style: SafeGoogleFont(
                          'Lato',
                          fontSize:  18,
                          fontWeight:  FontWeight.bold,
                          color:  Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          //Setting
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (BuildContext context){
                      return const SettingPage();
                    }
                    )
                );
              },
              child: Container(
                height: 60,
                width: 356,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Row(
                  children: <Widget>[
                    Image.asset(
                        "assets/images/settings.png",
                      width: 45,
                      height: 45,
                    ),
                    SizedBox(width: 20),
                    Center(
                      child: Text(
                        "Setting",
                        style: SafeGoogleFont(
                          'Lato',
                          fontSize:  18,
                          fontWeight:  FontWeight.bold,
                          color:  Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedButton(
              onPressed: () => _signOut(context),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xff2d366f),
              ),
              child: Text(
                  "Log Out",
                style: SafeGoogleFont(
                  'Lato',
                  fontSize:  18,
                  fontWeight:  FontWeight.bold,
                  color:  Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
