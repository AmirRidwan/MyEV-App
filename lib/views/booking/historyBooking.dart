import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../base/color_data.dart';
import '../../utils.dart';
import 'LeaveReviewPage.dart';
import 'bookingDetail.dart';

// Enum to represent the sorting options
enum SortingOption {
  Newest,
  Alphabetic,
}

class historyBooking extends StatefulWidget {
  final String currentUserId;

  const historyBooking({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State<historyBooking> createState() => _historyBookingState();
}

class _historyBookingState extends State<historyBooking> {

  // Firestore instance
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  SortingOption currentSortingOption = SortingOption.Newest; // Default sorting option

  // List to store booking data
  List<Map<String, dynamic>> bookingData = [];
  Map<String, String?> chargingStationNames = {};
  Map<String, String?> chargingStationAddresses = {};

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

  // Method to fetch booking data from Firestore
  Future<void> _fetchBookingData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> bookingSnapshot = await firestore
          .collection('bookings')
          .where('userId', isEqualTo: widget.currentUserId)
          .get();

      if (bookingSnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> allBookings = [];

        for (var bookingDoc in bookingSnapshot.docs) {
          final bookingData = bookingDoc.data()! as Map<String, dynamic>;
          bookingData['bookingId'] = bookingDoc.id;
          bookingData['bookingDateTime'] =
              (bookingData['bookingTimestamp'] as Timestamp?)?.toDate() ??
                  DateTime.now();
          bookingData['selectedDate'] =
              (bookingData['selectedDate'] as Timestamp?)?.toDate();

          QuerySnapshot<Map<String, dynamic>> reviewQuerySnapshot =
          await firestore.collection('reviews')
              .where('bookingId', isEqualTo: bookingDoc.id)
              .get();

          bookingData['reviewExists'] = reviewQuerySnapshot.docs.isNotEmpty;

          allBookings.add(bookingData);
        }

        setState(() {
          bookingData = allBookings;
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

  void _sortBookingData() {
    setState(() {
      if (currentSortingOption == SortingOption.Newest) {
        bookingData.sort((a, b) => b['bookingDateTime'].compareTo(a['bookingDateTime']));
      } else if (currentSortingOption == SortingOption.Alphabetic) {
        bookingData.sort((a, b) {
          String? nameA = chargingStationNames[a['stationId']];
          String? nameB = chargingStationNames[b['stationId']];
          return (nameA ?? '').compareTo(nameB ?? '');
        });
      }
    });
  }


  void _showSortingOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text(
                    'Sort by Newest',
                  style: SafeGoogleFont(
                    'Lato',
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  setState(() {
                    currentSortingOption = SortingOption.Newest;
                    _sortBookingData(); // Sort the data based on the selected option
                  });
                  Navigator.pop(context); // Close the bottom sheet after selecting an option
                },
              ),
              ListTile(
                leading: Icon(Icons.sort_by_alpha),
                title: Text(
                    'Sort by Alphabetic',
                  style: SafeGoogleFont(
                    'Lato',
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  setState(() {
                    currentSortingOption = SortingOption.Alphabetic;
                    _sortBookingData(); // Sort the data based on the selected option
                  });
                  Navigator.pop(context); // Close the bottom sheet after selecting an option
                },
              ),
            ],
          ),
        );
      },
    );
  }



  @override
  void initState() {
    super.initState();
    _fetchBookingData();
    _fetchChargingStationNames();
    _fetchChargingStationAddresses();
    _sortBookingData();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _refreshBookingData(); // Trigger refresh when pulled down
          await _fetchChargingStationNames(); // Update charging station names
          await _fetchChargingStationAddresses();
        },
        child: bookingData.isEmpty
            ? Center(
          child: Text(
            'No booking history found',
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
            String? chargingStationAddress = chargingStationAddresses[booking['stationId']];
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
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(
                        builder: (BuildContext context){
                          return BookingDetailPage(bookingId: bookingData[index]['bookingId']);
                        }
                    ),
                    );
                  },
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
              ),
            );
          },
        ),
      ),
      floatingActionButton: ElevatedButton.icon(
        onPressed: () {
          _showSortingOptionsBottomSheet();
        },
        icon: Icon(Icons.sort_rounded),
        label: Text(
          'Sort',
          style: SafeGoogleFont(
            'Lato',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          primary: buttonColor,
          onPrimary: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          elevation: 4,
        ),
      ),
      );
    }
}