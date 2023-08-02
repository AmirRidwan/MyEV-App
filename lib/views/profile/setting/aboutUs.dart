import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils.dart';

class AboutUsPage extends StatelessWidget {

  final String githubLink = 'https://github.com/AmirRidwan';
  final String facebookLink = 'https://www.facebook.com/amir.ridwan.393';


  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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
          "About Us",
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 80,
              backgroundImage: AssetImage('assets/images/myev-logo.png'),
            ),
            SizedBox(height: 16),
            Text(
              'MyEV: Electric Vehicle (EV) Charger Finder',
              style: SafeGoogleFont(
                  'Lato',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Version 1.0.0', // Replace with your app version
              style: SafeGoogleFont(
                'Lato',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'MyEV is a mobile application designed to help electric vehicle (EV) owners find nearby EV charging stations easily. '
                  'We are committed to providing the best user experience and promoting sustainable transportation solutions.',
              style: SafeGoogleFont(
                'Lato',
                fontSize: 16,
              ),
              textAlign: TextAlign.justify,
            ),
            Expanded(
              child: SizedBox(),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 16),
                Text(
                  'Contact Us:',
                  style: SafeGoogleFont(
                    'Lato',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Email: contact@myevapp.com',
                  style: SafeGoogleFont(
                    'Lato',
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Website: www.myevapp.com',
                  style: SafeGoogleFont(
                    'Lato',
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildCircularButton(
                  onTap: () => _launchURL(githubLink),
                  imagePath: 'assets/images/github_logo.png',
                ),
                SizedBox(width: 24),
                buildCircularButton(
                  onTap: () => _launchURL(facebookLink),
                  imagePath: 'assets/images/facebook_logo.png',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCircularButton({required VoidCallback onTap, required String imagePath}) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
          child: Image.asset(
            imagePath,
            height: 40,
            width: 40,
          ),
        ),
      ),
    );
  }
}
