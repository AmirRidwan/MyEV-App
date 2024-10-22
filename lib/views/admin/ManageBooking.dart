import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils.dart';

class ManageBooking extends StatefulWidget {
  @override
  _ManageBookingState createState() => _ManageBookingState();
}

class _ManageBookingState extends State<ManageBooking> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Map<String, String?> chargingStationNames = {};
  Map<String, String?> chargingStationAddresses = {};

  @override
  void initState() {
    super.initState();
    _fetchBookingData();
    _fetchChargingStationNames();
    _fetchChargingStationAddresses();
  }

  List<Map<String, dynamic>> bookingData = [];

  Future<void> _fetchBookingData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await firestore.collection('bookings').get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          bookingData = snapshot.docs.map((doc) {
            final data = doc.data()! as Map<String, dynamic>;
            data['bookingId'] = doc.id; // Assign the document ID to 'bookingId'
            data['bookingDateTime'] =
                (data['bookingTimestamp'] as Timestamp?)?.toDate() ??
                    DateTime.now();
            data['selectedDate'] =
                (data['selectedDate'] as Timestamp?)?.toDate();
            return data;
          }).toList();
        });
      }
    } catch (e) {
      print('Error fetching booking data: $e');
    }
  }

  Future<void> _cancelBooking(Map<String, dynamic> booking) async {
    try {
      String bookingId = booking['bookingId'];
      // Remove the booking document from Firestore
      await firestore.collection('bookings').doc(bookingId).delete();
      // Refresh the booking data to reflect the changes
      _fetchBookingData();
    } catch (e) {
      print('Error canceling booking: $e');
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

  // Method to handle the refresh action
  Future<void> _refreshBookingData() async {
    await _fetchBookingData(); // Call the method to fetch the booking data again
  }

  void _editBookingDetails(Map<String, dynamic> booking) {
    TextEditingController statusController = TextEditingController(
      text: booking['bookingStatus'],
    );
    TextEditingController endTimeController = TextEditingController(
      text: booking['endTime'],
    );
    TextEditingController hoursOfChargeController = TextEditingController(
      text: booking['hoursOfCharge'].toString(),
    );
    TextEditingController paymentMethodController = TextEditingController(
      text: booking['paymentMethod'],
    );
    TextEditingController selectedDateController = TextEditingController(
      text: booking['selectedDate'].toString(),
    );
    TextEditingController startTimeController = TextEditingController(
      text: booking['startTime'],
    );
    TextEditingController totalAmountController = TextEditingController(
      text: booking['totalAmount'].toString(),
    );

    // Dropdown options for Booking Status
    final List<String> bookingStatusOptions = ['Paid', 'Unpaid'];

    // Dropdown options for Payment Method
    final List<String> paymentMethodOptions = [
      'PayPal',
      'Credit Card',
      'Google Pay',
      'E-Wallet'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Edit Details",
                  style: SafeGoogleFont(
                    'Lato',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                // Edit Booking Status
                // Booking Status Dropdown
                DropdownButtonFormField<String>(
                  value: booking['bookingStatus'],
                  items: bookingStatusOptions.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (selectedStatus) {
                    // Update the selected value
                    statusController.text = selectedStatus!;
                  },
                  decoration: InputDecoration(labelText: 'Booking Status'),
                ),
                SizedBox(height: 20),
                // Edit End Time
                TextFormField(
                  controller: endTimeController,
                  decoration: InputDecoration(labelText: 'End Time'),
                ),
                SizedBox(height: 20),
                // Edit Hours of Charge
                TextFormField(
                  controller: hoursOfChargeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Hours of Charge'),
                ),
                SizedBox(height: 20),
                // Edit Payment Method
                // Payment Method Dropdown
                DropdownButtonFormField<String>(
                  value: booking['paymentMethod'],
                  items: paymentMethodOptions.map((paymentMethod) {
                    return DropdownMenuItem<String>(
                      value: paymentMethod,
                      child: Text(paymentMethod),
                    );
                  }).toList(),
                  onChanged: (selectedPaymentMethod) {
                    // Update the selected value
                    paymentMethodController.text = selectedPaymentMethod!;
                  },
                  decoration: InputDecoration(labelText: 'Payment Method'),
                ),
                SizedBox(height: 20),
                // Edit Selected Date
                TextFormField(
                  controller: selectedDateController,
                  decoration: InputDecoration(labelText: 'Selected Date'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? newDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse(selectedDateController.text),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (newDate != null) {
                      selectedDateController.text = newDate.toString();
                    }
                  },
                ),
                SizedBox(height: 20),
                // Edit Start Time
                TextFormField(
                  controller: startTimeController,
                  decoration: InputDecoration(labelText: 'Start Time'),
                ),
                SizedBox(height: 20),
                // Edit Total Amount
                TextFormField(
                  controller: totalAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Total Amount'),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                            context); // Close the bottom sheet without saving changes
                      },
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Save the edited details back to Firestore
                        try {
                          String bookingId = booking['bookingId'];
                          await firestore
                              .collection('bookings')
                              .doc(bookingId)
                              .update({
                            'bookingStatus': statusController.text,
                            'endTime': endTimeController.text,
                            'hoursOfCharge':
                                double.parse(hoursOfChargeController.text),
                            'paymentMethod': paymentMethodController.text,
                            'selectedDate':
                                DateTime.parse(selectedDateController.text),
                            'startTime': startTimeController.text,
                            'totalAmount':
                                double.parse(totalAmountController.text),
                          });
                          Navigator.pop(
                              context); // Close the bottom sheet after saving changes
                          _fetchBookingData(); // Refresh the booking data to reflect the changes
                        } catch (e) {
                          print('Error updating booking details: $e');
                          // Handle error (show error message, etc.)
                        }
                      },
                      child: Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _searchQuery = ''; // Variable to store the user's search query

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xff2d366f)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          "Manage Booking",
          style: SafeGoogleFont(
            'Lato',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xff2d366f),
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Color(0xff9dd1ea),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _refreshBookingData();
          await _fetchChargingStationNames();
          await _fetchChargingStationAddresses();
        },
        child: Column(
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(25),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                        : Icon(Icons.search),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: bookingData.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> booking = bookingData[index];
                  // Define statusColor based on booking status
                  Color statusColor = booking['bookingStatus'].toLowerCase() == 'paid'
                      ? Colors.green
                      : Colors.red;
                  bool matchesSearchQuery = booking['bookingId']
                      .contains(_searchQuery) ||
                      booking['selectedDate'].toString().contains(_searchQuery) ||
                      booking['bookingStatus'].contains(_searchQuery) ||
                      booking['paymentMethod'].contains(_searchQuery);

                  if (_searchQuery.isNotEmpty && !matchesSearchQuery) {
                    return SizedBox.shrink(); // Hide the ListTile if no match
                  }

                  return Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    child: Material(
                      color: Colors.white,
                      elevation: 4,
                      borderRadius: BorderRadius.circular(10),
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
                                        'Booking ID: ${booking['bookingId']}',
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
                                          'Date: ${booking['selectedDate']}',
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
                                  ],
                                ),
                                SizedBox(height: 4),
                                Spacer(), // Add this to push buttons to the right
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        _editBookingDetails(booking);
                                      },
                                    ),
                                    SizedBox(height: 8),
                                    IconButton(
                                      icon: Icon(Icons.cancel),
                                      onPressed: () {
                                        _cancelBooking(booking);
                                      },
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
          ],
        ),
      ),
    );
  }
}
