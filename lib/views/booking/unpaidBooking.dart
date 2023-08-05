import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../utils.dart';
import 'LeaveReviewPage.dart';

class unpaidBooking extends StatefulWidget {
  final String currentUserId;

  const unpaidBooking({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State<unpaidBooking> createState() => _unpaidBookingState();
}

class _unpaidBookingState extends State<unpaidBooking> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> bookingData = [];
  Map<String, String?> chargingStationNames = {};
  Map<String, String?> chargingStationAddresses = {};


  Future<void> _fetchBookingData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> bookingSnapshot = await firestore
          .collection('bookings')
          .where('userId', isEqualTo: widget.currentUserId)
          .get();

      if (bookingSnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> unpaidBookings = [];

        for (var bookingDoc in bookingSnapshot.docs) {
          final bookingData = bookingDoc.data()! as Map<String, dynamic>;
          bookingData['bookingId'] = bookingDoc.id;
          bookingData['bookingDateTime'] =
              (bookingData['bookingTimestamp'] as Timestamp?)?.toDate() ??
                  DateTime.now();
          bookingData['selectedDate'] =
              (bookingData['selectedDate'] as Timestamp?)?.toDate();

          // Check if the booking status is 'Unpaid'
          if (bookingData['bookingStatus'].toLowerCase() != 'paid') {
            QuerySnapshot<Map<String, dynamic>> reviewQuerySnapshot =
            await firestore.collection('reviews')
                .where('bookingId', isEqualTo: bookingDoc.id)
                .get();

            unpaidBookings.add(bookingData);
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

  // Method to handle the refresh action
  Future<void> _refreshBookingData() async {
    await _fetchBookingData(); // Call the method to fetch the booking data again
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
              child: Text(
                'Cancel',
                style: SafeGoogleFont(
                  'Lato',
                  fontSize:  16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await _updatePaymentStatus(bookingId); // Update the payment status in Firestore
                Navigator.of(context).pop(); // Close the dialog
                _fetchBookingData(); // Refresh the widget to update the UI with the new payment status
              },
              child: Text(
                'Confirm',
                style: SafeGoogleFont(
                  'Lato',
                  fontSize:  16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCancelConfirmationDialog(String bookingId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cancel Booking',
            style: SafeGoogleFont(
              'Lato',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Text(
            'Are you sure you want to cancel this booking?',
            style: SafeGoogleFont(
              'Lato',
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'No',
                style: SafeGoogleFont(
                  'Lato',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await _cancelBooking(bookingId); // Cancel the booking and delete its record
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Yes',
                style: SafeGoogleFont(
                  'Lato',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
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

  Future<void> _fetchChargingStationAddresses() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await firestore.collection('charging_stations').get();
      if (snapshot.docs.isNotEmpty) {
        chargingStationAddresses = Map.fromIterable(snapshot.docs,
            key: (doc) => doc.id,
            value: (doc) => doc.data()?['address'] as String?);
      }
    } catch (e) {
      print('Error fetching charging station addresses: $e');
    }
  }

  // Method to cancel the booking and delete its record
  Future<void> _cancelBooking(String bookingId) async {
    try {
      // Delete the booking record from Firestore
      await firestore.collection('bookings').doc(bookingId).delete();

      // Refresh the booking data after cancellation
      await _fetchBookingData();
    } catch (e) {
      print('Error canceling booking: $e');
    }
  }

  // New method to fetch charging station address based on stationId
  String? getChargingStationAddress(String stationId) {
    return chargingStationAddresses[stationId];
  }

  @override
  void initState() {
    super.initState();
    // Fetch booking data and charging station names when the widget is first initialized
    _fetchBookingData();
    _fetchChargingStationNames();
    _fetchChargingStationAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _refreshBookingData();
          await _fetchChargingStationNames();
          await _fetchChargingStationAddresses();
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
            String? chargingStationName =
            chargingStationNames[booking['stationId']];
            String? chargingStationAddress =
            chargingStationAddresses[booking['stationId']];
            Color statusColor = booking['bookingStatus'].toLowerCase() ==
                'paid'
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
                    child: Container(
                      height: 240,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          SizedBox(width: 5),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${DateFormat('MMM').format(booking['selectedDate'])}',
                                style: SafeGoogleFont('Lato', fontSize: 14),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '${DateFormat('dd').format(booking['selectedDate'])}',
                                style: SafeGoogleFont('Lato', fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '${DateFormat('E').format(booking['selectedDate'])}',
                                style: SafeGoogleFont('Lato', fontSize: 14),
                              ),
                            ],
                          ),
                          SizedBox(width: 10),
                          VerticalDivider(
                            color: Colors.grey[350],
                            width: 24,
                            thickness: 1,
                            indent: 36,
                            endIndent: 36,
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
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
                              Container(
                                width: 260,
                                child: Expanded(
                                  child: Text(
                                    '${chargingStationAddress ?? 'N/A'}',
                                    style: SafeGoogleFont(
                                      'Lato',
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                    softWrap: true,
                                  ),
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    '${booking['startTime']} - ${booking['endTime']}',
                                    style: SafeGoogleFont(
                                      'Lato',
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.hourglass_bottom,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    '${booking['hoursOfCharge']} hours',
                                    style: SafeGoogleFont(
                                      'Lato',
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.payment,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    ' ${booking['paymentMethod']}',
                                    style: SafeGoogleFont(
                                      'Lato',
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.assignment_turned_in_outlined,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  SizedBox(width: 5),
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
                              Row(
                                children: [
                                  Icon(
                                    Icons.monetization_on_outlined,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'RM${booking['totalAmount'].toStringAsFixed(2)}',
                                    style: SafeGoogleFont(
                                      'Lato',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
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
                                          'Continue Payment',
                                          style: SafeGoogleFont(
                                            'Lato',
                                            fontSize:  16,
                                            fontWeight:  FontWeight.bold,
                                            color:  Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  SizedBox(width: 10),
                                  // Add "Cancel Booking" button if the booking is unpaid
                                  if (booking['bookingStatus'].toLowerCase() != 'paid')
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          primary: Color(0xFFC62828), // Use your desired color
                                        ),
                                        onPressed: () {
                                          _showCancelConfirmationDialog(booking['bookingId']);
                                        },
                                        child: Text(
                                          'Cancel Booking',
                                          style: SafeGoogleFont(
                                            'Lato',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
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