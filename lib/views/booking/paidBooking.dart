import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../utils.dart';
import 'LeaveReviewPage.dart';

class paidBooking extends StatefulWidget {
  final String currentUserId;

  const paidBooking({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State<paidBooking> createState() => _paidBookingState();
}

class _paidBookingState extends State<paidBooking> {
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
        List<Map<String, dynamic>> paidBookings = [];

        for (var bookingDoc in bookingSnapshot.docs) {
          final bookingData = bookingDoc.data()! as Map<String, dynamic>;
          bookingData['bookingId'] = bookingDoc.id;
          bookingData['bookingDateTime'] =
              (bookingData['bookingTimestamp'] as Timestamp?)?.toDate() ??
                  DateTime.now();
          bookingData['selectedDate'] =
              (bookingData['selectedDate'] as Timestamp?)?.toDate();

          // Check if the booking status is 'Paid'
          if (bookingData['bookingStatus'].toLowerCase() != 'unpaid') {
            QuerySnapshot<Map<String, dynamic>> reviewQuerySnapshot =
            await firestore.collection('reviews')
                .where('bookingId', isEqualTo: bookingDoc.id)
                .get();

            bookingData['reviewExists'] = reviewQuerySnapshot.docs.isNotEmpty;

            paidBookings.add(bookingData);
          }
        }

        setState(() {
          bookingData = paidBookings;
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
            'No paid booking found',
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
            bool canLeaveReview = booking['bookingStatus'].toLowerCase() == 'paid' && !booking['reviewExists'];

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
                      height: 212,
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
                                  SizedBox(width: 60),
                                  if (canLeaveReview)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xff2d366f),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ReviewPage(
                                              currentUserId: widget.currentUserId,
                                              bookingId: booking['bookingId'],
                                              stationId: booking['stationId'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                          'Leave Review',
                                        style: SafeGoogleFont(
                                            'Lato',
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
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