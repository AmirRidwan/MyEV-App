import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../base/color_data.dart';
import '../../utils.dart';

// Enum to represent the sorting options
enum SortingOption {
  Newest,
  Alphabetic,
}

class MyBooking extends StatefulWidget {
  final String currentUserId;

  const MyBooking({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State<MyBooking> createState() => _MyBookingState();
}

class _MyBookingState extends State<MyBooking> {

  // Firestore instance
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  SortingOption currentSortingOption = SortingOption.Newest; // Default sorting option

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
        setState(() {
          bookingData = snapshot.docs.map((doc) {
            final data = doc.data()! as Map<String, dynamic>;
            data['bookingId'] = doc.id; // Assign the document ID to 'bookingId'
            data['bookingDateTime'] = (data['bookingTimestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
            return data;
          }).toList();
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
    _sortBookingData(); // Sort the data initially

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
          "My Booking",
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
      body: RefreshIndicator(
        onRefresh: () async {
          await _refreshBookingData(); // Trigger refresh when pulled down
          await _fetchChargingStationNames(); // Update charging station names
        },
        child: bookingData.isEmpty
            ? Center(child: CircularProgressIndicator())
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
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 1),
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
                      SizedBox(height: 4),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
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