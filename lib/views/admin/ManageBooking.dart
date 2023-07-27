import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../utils.dart';

class ManageBooking extends StatefulWidget {
  @override
  _ManageBookingState createState() => _ManageBookingState();
}

class _ManageBookingState extends State<ManageBooking> {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchBookingData();
  }

  List<Map<String, dynamic>> bookingData = [];

  Future<void> _fetchBookingData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
          .collection('bookings')
          .get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          bookingData = snapshot.docs.map((doc) {
            final data = doc.data()! as Map<String, dynamic>;
            data['bookingId'] = doc.id; // Assign the document ID to 'bookingId'
            data['bookingDateTime'] = (data['bookingTimestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
            data['selectedDate'] = (data['selectedDate'] as Timestamp?)?.toDate();
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
    final List<String> paymentMethodOptions = ['PayPal', 'Credit Card', 'E-Wallet'];

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
                    fontSize:  24,
                    fontWeight:  FontWeight.bold,
                    color:  Colors.black,
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
                        Navigator.pop(context); // Close the bottom sheet without saving changes
                      },
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Save the edited details back to Firestore
                        try {
                          String bookingId = booking['bookingId'];
                          await firestore.collection('bookings').doc(bookingId).update({
                            'bookingStatus': statusController.text,
                            'endTime': endTimeController.text,
                            'hoursOfCharge': double.parse(hoursOfChargeController.text),
                            'paymentMethod': paymentMethodController.text,
                            'selectedDate': DateTime.parse(selectedDateController.text),
                            'startTime': startTimeController.text,
                            'totalAmount': double.parse(totalAmountController.text),
                          });
                          Navigator.pop(context); // Close the bottom sheet after saving changes
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
            fontSize:  24,
            fontWeight:  FontWeight.bold,
            color:  Color(0xff2d366f),
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Color(0xff9dd1ea),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search...',
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
          Expanded(
            child: ListView.builder(
              itemCount: bookingData.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> booking = bookingData[index];
                // Check if the search query matches any relevant field
                bool matchesSearchQuery = booking['bookingId'].contains(_searchQuery) ||
                    booking['selectedDate'].toString().contains(_searchQuery) ||
                    booking['bookingStatus'].contains(_searchQuery) ||
                    booking['paymentMethod'].contains(_searchQuery);

                if (_searchQuery.isNotEmpty && !matchesSearchQuery) {
                  return SizedBox.shrink(); // Hide the ListTile if no match
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder( //<-- SEE HERE
                      side: BorderSide(width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(
                        'Booking ID: ${booking['bookingId']}',
                      style: SafeGoogleFont(
                        'Lato',
                        fontSize:  16,
                        fontWeight:  FontWeight.bold,
                        color:  Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      children: [
                        Text(
                            'Date: ${booking['selectedDate']}',
                          style: SafeGoogleFont(
                            'Lato',
                            fontSize:  14,
                            color:  Colors.black54,
                          ),
                        ),
                        Text(
                          'Date: ${booking['bookingStatus']}',
                          style: SafeGoogleFont(
                            'Lato',
                            fontSize:  14,
                            color:  Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _editBookingDetails(booking);
                      },
                    ),
                    leading: IconButton(
                      icon: Icon(Icons.cancel),
                      onPressed: () {
                        _cancelBooking(booking);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
