import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils.dart';

class ManageUserRole extends StatefulWidget {
  @override
  _ManageUserRoleState createState() => _ManageUserRoleState();
}

class _ManageUserRoleState extends State<ManageUserRole> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<String> userRoles = ['Admin', 'User'];
  List<String> userRoleValues = ['admin', 'user']; // unique values for each role

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xff2d366f)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          "Manage User Role",
          style: SafeGoogleFont(
            'Lato',
            fontSize:  24,
            fontWeight:  FontWeight.bold,
            color:  Color(0xff2d366f),
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Color(0xff9dd1ea),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: firestore.collection('users').get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<DocumentSnapshot> documents = snapshot.data!.docs;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot document = documents[index];
              String firstName = document['firstName'].toString();
              String lastName = document['lastName'].toString();
              String currentRole = document['role'].toString();

              String displayName = '$firstName $lastName';

              return Container(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                child: Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text(displayName),
                        subtitle: Text('Current Role: $currentRole'),
                      ),
                    ),
                    Container(
                      width: 120.0,
                      child: DropdownButtonFormField<String>(
                        value: currentRole,
                        items: userRoles.map((String role) {
                          int index = userRoles.indexOf(role);
                          return DropdownMenuItem<String>(
                            value: userRoleValues[index],
                            child: Text(role),
                          );
                        }).toList(),
                        onChanged: (String? newRole) {
                          _changeUserRole(displayName, newRole!);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _changeUserRole(String displayName, String newRole) async {
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('users')
          .where('displayName', isEqualTo: displayName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String userId = querySnapshot.docs.first.id;

        await firestore.collection('users').doc(userId).update({
          'role': newRole,
        });
        print('User role updated successfully');
      } else {
        print('User not found');
      }
    } catch (e) {
      print('Error updating user role: $e');
    }
  }



}