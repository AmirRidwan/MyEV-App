import 'package:flutter/material.dart';

import '../../../utils.dart';

class TermsAndConditionsPage extends StatelessWidget {
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
          "Terms & Conditions",
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Terms and Conditions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Welcome to MyEV: Electric Vehicle (EV) Charger Finder Mobile Application. '
              'By using this application, you agree to be bound by the following terms and conditions:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.check),
              title: Text(
                'Accuracy of Information',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'The information provided in this application is for general information purposes only. '
                'We strive to keep the information accurate and up-to-date, but we cannot guarantee its accuracy. '
                'You should verify the information with relevant sources before relying on it for decision making.',
                textAlign: TextAlign.justify,
              ),
            ),
            ListTile(
              leading: Icon(Icons.check),
              title: Text(
                'Use of Location Data',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'This application uses your device\'s location data to provide you with nearby EV charging stations. '
                'By using this feature, you consent to the collection and use of your location data as described in our Privacy Policy.',
                textAlign: TextAlign.justify,
              ),
            ),
            ListTile(
              leading: Icon(Icons.check),
              title: Text(
                'User Responsibility',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'You are solely responsible for your use of this application. '
                'You agree not to use the application for any unlawful or prohibited activities. '
                'We shall not be liable for any damages or losses resulting from your use of the application.',
                textAlign: TextAlign.justify,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Changes to Terms and Conditions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'We may update these terms and conditions from time to time. '
              'Please check this page periodically for any changes. '
              'Your continued use of the application after the changes will constitute your acceptance of the revised terms and conditions.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
