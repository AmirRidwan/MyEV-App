import 'package:evfinder/views/profile/setting/aboutUs.dart';
import 'package:evfinder/views/profile/setting/changePassword.dart';
import 'package:evfinder/views/profile/setting/privacyPolicy.dart';
import 'package:evfinder/views/profile/setting/termsConditions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
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
          "Setting",
          style: SafeGoogleFont(
            'Lato',
            fontSize:  24,
            fontWeight:  FontWeight.bold,
            color:  Color(0xff2d366f),
          ),
          textAlign: TextAlign.center,
        ),
        elevation: 2.0,
        backgroundColor: Color(0xff9dd1ea),
      ),
      body: ListView(
        children: [
          SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(10),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (BuildContext context){
                        return ChangePasswordPage();
                      }
                  ),
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
                      SizedBox(width: 20),
                      Icon(CupertinoIcons.lock),
                      SizedBox(width: 20),
                      Text(
                        "Change Password",
                        style: SafeGoogleFont(
                          'Lato',
                          fontSize:  18,
                          fontWeight:  FontWeight.bold,
                          color:  Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

          //Terms & Conditions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Material(
              elevation: 4, // Add elevation here
              borderRadius: BorderRadius.circular(10),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (BuildContext context){
                        return TermsAndConditionsPage();
                      }
                  ),
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
                      SizedBox(width: 20),
                      Icon(Icons.note_alt_outlined),
                      SizedBox(width: 20),
                      Center(
                        child: Text(
                          "Terms & Conditions",
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
          ),

          //Privacy & Policy
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Material(
              elevation: 4, // Add elevation here
              borderRadius: BorderRadius.circular(10),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (BuildContext context){
                        return PrivacyPolicyPage();
                      }
                  ),
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
                      SizedBox(width: 20),
                      Icon(Icons.privacy_tip_outlined),
                      SizedBox(width: 20),
                      Center(
                        child: Text(
                          "Privacy Policy",
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
          ),

          //About Us
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Material(
              elevation: 4, // Add elevation here
              borderRadius: BorderRadius.circular(10),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (BuildContext context){
                        return AboutUsPage();
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
                      SizedBox(width: 20),
                      Icon(CupertinoIcons.info),
                      SizedBox(width: 20),
                      Center(
                        child: Text(
                          "About Us",
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
          ),
        ],
      ),

    );
  }
}
