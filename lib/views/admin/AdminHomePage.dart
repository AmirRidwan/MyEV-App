import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evfinder/components/my_button.dart';
import 'package:evfinder/views/admin/AddChargingStationPage.dart';
import 'package:evfinder/views/admin/ManageBooking.dart';
import 'package:evfinder/views/admin/ManageEV.dart';
import 'package:evfinder/views/admin/ManageUserRoles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../utils.dart';

class AdminHomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  void _signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        centerTitle: true,
        title: Text(
          "DASHBOARD",
          style: SafeGoogleFont(
            'Lato',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xff2d366f),
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Color(0xff9dd1ea),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //user display name
            Container(
              child: Center(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Text('No data available for the current user.');
                    }

                    Map<String, dynamic> data =
                        snapshot.data!.data() as Map<String, dynamic>;

                    return Column(
                      children: [
                        SizedBox(height: 10),
                        Text(
                          'Welcome, ${data['firstName']} ${data['lastName']}!',
                          style: SafeGoogleFont(
                            'Lato',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: Color(0xff2d366f),
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              width: 380,
              height: 100,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Color(0xff2d366f),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManageBooking()),
                  );
                },
                icon: Icon(Icons.calendar_today),
                label: Text('Manage Bookings'),
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Color(0xff2d366f),
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              width: 380,
              height: 100,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Color(0xff2d366f),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddChargingStationPage()),
                  );
                },
                icon: Icon(Icons.ev_station),
                label: Text('Add EV Charging Stations'),
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Color(0xff2d366f),
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              width: 380,
              height: 100,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Color(0xff2d366f),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChargingStationPage()),
                  );
                  // Handle booking management
                  // Add your logic here
                },
                icon: Icon(Icons.flash_on),
                label:
                    Text('Manage EV Charging Stations Details & Availability'),
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Color(0xff2d366f),
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              width: 380,
              height: 100,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Color(0xff2d366f),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManageUserRole()),
                  );
                  // Handle booking management
                  // Add your logic here
                },
                icon: Icon(Icons.account_circle),
                label: Text('Manage User Role'),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: OutlinedButton(
                onPressed: () => _signOut(context),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text(
                  "Log Out",
                  style: SafeGoogleFont(
                    'Lato',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
