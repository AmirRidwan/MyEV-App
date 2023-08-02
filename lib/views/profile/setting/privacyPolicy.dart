import 'package:flutter/material.dart';

import '../../../utils.dart';

class PrivacyPolicyPage extends StatelessWidget {
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
          "Privacy Policy",
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
        child: ListView(
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Welcome to MyEV: Electric Vehicle (EV) Charger Finder Mobile Application. '
                  'This Privacy Policy outlines how we collect, use, and protect your information '
                  'when you use our application:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.check),
              title: Text(
                'Information Collection and Use',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'We may collect and store personal information that you provide directly to us, '
                    'such as your name, email address, and location data. '
                    'We use this information to provide you with the services and features of the application, '
                    'including finding nearby EV charging stations.',
                textAlign: TextAlign.justify,
              ),
            ),
            ListTile(
              leading: Icon(Icons.check),
              title: Text(
                'Location Data',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'We may use your device\'s location data to provide you with location-based services, '
                    'such as finding nearby EV charging stations. '
                    'We do not share your location data with third parties, and it is used solely for the application\'s functionality.',
                textAlign: TextAlign.justify,
              ),
            ),
            ListTile(
              leading: Icon(Icons.check),
              title: Text(
                'Information Sharing and Disclosure',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'We do not sell, trade, or otherwise transfer your personal information to third parties. '
                    'We may share anonymized and aggregated data for statistical and research purposes.',
                textAlign: TextAlign.justify,
              ),
            ),
            ListTile(
              leading: Icon(Icons.check),
              title: Text(
                'Security',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'We take reasonable measures to protect your information from unauthorized access or disclosure. '
                    'However, no method of transmission over the internet or electronic storage is completely secure. '
                    'Therefore, we cannot guarantee absolute security.',
                textAlign: TextAlign.justify,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Changes to Privacy Policy',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'We may update this privacy policy from time to time. '
                  'Please check this page periodically for any changes. '
                  'Your continued use of the application after the changes will constitute your acceptance of the revised privacy policy.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
