import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../utils.dart';

class unpaidBooking extends StatefulWidget {
  final String currentUserId;

  const unpaidBooking({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State<unpaidBooking> createState() => _unpaidBookingState();
}

class _unpaidBookingState extends State<unpaidBooking> {
  // Firestore instance
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // List to store booking data
  List<Map<String, dynamic>> bookingData = [];
  Map<String, String?> chargingStationNames = {};

  // Method to fetch booking data from Firestore
  Future<void> _fetchBookingData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
          .collection('bookings')
          .where('userId', isEqualTo: widget.currentUserId)
          .get();
      if (snapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> unpaidBookings = [];
        for (var doc in snapshot.docs) {
          final data = doc.data()! as Map<String, dynamic>;
          data['bookingId'] = doc.id; // Assign the document ID to 'bookingId'
          data['bookingDateTime'] = (data['bookingTimestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
          data['selectedDate'] = (data['selectedDate'] as Timestamp?)?.toDate();

          // Check if the booking status is 'Paid'
          if (data['bookingStatus'].toLowerCase() != 'paid') {
            unpaidBookings.add(data);
          }
        }

        setState(() {
          bookingData = unpaidBookings;
        });
      }
    } catch (e) {
      print('Error fetching booking data: $e');
    }
  }


  // Method to update the payment status in Firestore
  Future<void> _updatePaymentStatus(String bookingId) async {
    try {
      await firestore.collection('bookings').doc(bookingId).update({
        'bookingStatus': 'Paid',
      });
    } catch (e) {
      print('Error updating payment status: $e');
    }
  }

  // Method to show the payment confirmation dialog
  Future<void> _showPaymentConfirmationDialog(String bookingId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              'Confirm Payment',
            style: SafeGoogleFont(
              'Lato',
              fontSize:  18,
              fontWeight:  FontWeight.bold,
              color:  Colors.black,
            ),
          ),
          content: Text(
              'Are you sure you want to make the payment?',
            style: SafeGoogleFont(
              'Lato',
              fontSize:  16,
              color:  Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _updatePaymentStatus(bookingId); // Update the payment status in Firestore
                Navigator.of(context).pop(); // Close the dialog
                _fetchBookingData(); // Refresh the widget to update the UI with the new payment status
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }


  // Method to handle the refresh action
  Future<void> _refreshBookingData() async {
    await _fetchBookingData(); // Call the method to fetch the booking data again
  }

  // Method to pre-fetch charging station names
  Future<void> _fetchChargingStationNames() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await firestore.collection('charging_stations').get();
      if (snapshot.docs.isNotEmpty) {
        chargingStationNames = Map.fromIterable(snapshot.docs,
            key: (doc) => doc.id, value: (doc) => doc.data()?['name'] as String?);
      }
    } catch (e) {
      print('Error fetching charging station names: $e');
    }
  }


  @override
  void initState() {
    super.initState();
    // Fetch booking data and charging station names when the widget is first initialized
    _fetchBookingData();
    _fetchChargingStationNames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _refreshBookingData(); // Trigger refresh when pulled down
          await _fetchChargingStationNames(); // Update charging station names
        },
        child: bookingData.isEmpty
            ? Center(
          child: Text(
            'No unpaid booking found',
            style: SafeGoogleFont(
              'Lato',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        )
            : ListView.builder(
          itemCount: bookingData.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> booking = bookingData[index];
            String? chargingStationName = chargingStationNames[booking['stationId']];

            // Determine the color based on the 'bookingStatus' value
            Color statusColor = booking['bookingStatus'].toLowerCase() == 'paid'
                ? Colors.green
                : Colors.red;

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            '${chargingStationName ?? 'N/A'}',
                            style: SafeGoogleFont(
                              'Lato',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                                'Status: ',
                              style: SafeGoogleFont(
                                'Lato',
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              '${booking['bookingStatus']}',
                              style: SafeGoogleFont(
                                'Lato',
                                fontSize: 14,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                            'Date: ${DateFormat('yyyy-MM-dd').format(booking['bookingDateTime'])}',
                          style: SafeGoogleFont(
                            'Lato',
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Selected Date: ${DateFormat('yyyy-MM-dd').format(booking['selectedDate'])}',
                          style: SafeGoogleFont(
                            'Lato',
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                            'Time: ${DateFormat('HH:mm').format(booking['bookingDateTime'])}',
                          style: SafeGoogleFont(
                            'Lato',
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                            'Start Time: ${booking['startTime']}',
                          style: SafeGoogleFont(
                            'Lato',
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                            'End Time: ${booking['endTime']}',
                          style: SafeGoogleFont(
                            'Lato',
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                            'Hours of Charge: ${booking['hoursOfCharge']}',
                          style: SafeGoogleFont(
                            'Lato',
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                            'Payment Method: ${booking['paymentMethod']}',
                          style: SafeGoogleFont(
                            'Lato',
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        // Add "Make Payment" button if the booking is unpaid
                        if (booking['bookingStatus'].toLowerCase() != 'paid')
                          Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xff2d366f),
                              ),
                              onPressed: () {
                                _showPaymentConfirmationDialog(booking['bookingId']);
                              },
                              child: Text(
                                  'Make Payment',
                                style: SafeGoogleFont(
                                  'Lato',
                                  fontSize:  16,
                                  fontWeight:  FontWeight.bold,
                                  color:  Colors.white,
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: 4),
                        Align(
                          alignment: Alignment.bottomRight,
                          child:
                          Text(
                              'Total Amount: RM${booking['totalAmount'].toStringAsFixed(2)}',
                            style: SafeGoogleFont(
                              'Lato',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}