import 'package:flutter/material.dart';

class ConfirmPaymentPage extends StatelessWidget {
  final String stationName;
  final String startTime;
  final String endTime;
  final double hoursOfCharge;
  final String totalAmount;

  ConfirmPaymentPage({
    required this.stationName,
    required this.startTime,
    required this.endTime,
    required this.hoursOfCharge,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Charging Station: $stationName',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Start Time: $startTime'),
            Text('End Time: $endTime'),
            Text('Hours of Charge: ${hoursOfCharge.toStringAsFixed(2)} hours'),
            Text('Total Amount: $totalAmount'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Simulate payment processing for 2 seconds
                await Future.delayed(Duration(seconds: 2));

                // Navigate back to the BookingPage after successful payment
                Navigator.pop(context, true);
              },
              child: Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }
}
