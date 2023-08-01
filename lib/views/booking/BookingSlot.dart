import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/model_booking.dart';
import '../../utils.dart';

// Create a class to represent the payment methods
class PaymentMethod {
  final String name;
  final String description;

  PaymentMethod(this.name, this.description);
}

// Define the payment methods (you can add more if needed)
List<PaymentMethod> _paymentMethods = [
  PaymentMethod('Credit Card', 'Pay with Credit Card'),
  PaymentMethod('PayPal', 'Pay with PayPal'),
  PaymentMethod('Google Pay', 'Pay with Google Pay'),
  // Add more payment methods here
];

class BookingPage extends StatefulWidget {
  final String stationId; // ID of the charging station to book

  BookingPage({required this.stationId});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String selectedStartTime = '12:00 PM'; // Make sure this value is unique
  String selectedEndTime = '01:00 PM';
  int selectedHours = 1;
  TextEditingController _dateController = TextEditingController();

// The currently selected payment method
  PaymentMethod? _selectedPaymentMethod;

  void updateSelectedHours(double value) {
    setState(() {
      selectedHours = value.round();
      int startHour = int.parse(selectedStartTime.split(':')[0]);
      int endHour = startHour + selectedHours;
      selectedEndTime =
          '${endHour.toString().padLeft(2, '0')}:00 ${endHour >= 12 ? 'PM' : 'AM'}';
    });
  }

  String getCurrentUserId() {
    try {
      // Get the current user from FirebaseAuth
      User? user = FirebaseAuth.instance.currentUser;

      // Check if a user is signed in
      if (user != null) {
        // Return the user ID
        return user.uid;
      } else {
        // If no user is signed in, return an empty string or handle the case as per your requirements
        return '';
      }
    } catch (e) {
      // Handle any exceptions that may occur while getting the current user ID
      print('Error getting current user ID: $e');
      return '';
    }
  }

  // Update the booking status in Firestore
  Future<void> _updateBookingStatus(
      BuildContext context, Booking booking, String status) async {
    try {
      // Get the reference to the booking document
      DocumentReference bookingRef = FirebaseFirestore.instance
          .collection('bookings')
          .doc(booking.bookingId);

      // Update the booking status in Firestore
      await bookingRef.update({'bookingStatus': status});

      // Show a success message to the user if the status is updated to 'Paid'
      if (status == Booking.paidStatus) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Booking Successful'),
              content: Text('Your booking has been confirmed.'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(
                        context); // Navigate back to the ChargingStationDetailsPage
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Show a message to the user if the booking is canceled
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Booking Canceled'),
              content: Text('Your booking has been canceled.'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error updating booking status: $e');
      // Show an error message to the user if there was an issue with updating the status
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
                'There was an error while processing your booking. Please try again.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  // Simulate payment completion (Replace this with your actual payment processing logic)
  Future<bool?> _simulatePaymentCompletion(
      BuildContext context, Booking booking) async {
    return await showDialog<bool?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Booking Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Booking ID: ${booking.bookingId}'),
              SizedBox(height: 8),
              Text(
                  'Selected Date: ${booking.selectedDate.toString().split(' ')[0]}'),
              SizedBox(height: 8),
              Text('Start Time: ${booking.startTime}'),
              SizedBox(height: 8),
              Text('End Time: ${booking.endTime}'),
              SizedBox(height: 8),
              Text('Hours of Charge: ${booking.hoursOfCharge}'),
              SizedBox(height: 8),
              Text('Payment Method: ${booking.paymentMethod}'),
              SizedBox(height: 8),
              Text('Total Amount: RM${booking.totalAmount.toStringAsFixed(2)}'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Continue with the payment
                Navigator.pop(context, true);
              },
              child: Text('Continue Payment'),
            ),
            ElevatedButton(
              onPressed: () {
                // Cancel the booking
                Navigator.pop(context, false);
              },
              child: Text('Cancel Booking'),
            ),
          ],
        );
      },
    );
  }

  Future<double> _getChargingRate() async {
    // Fetch charging rate for the selected station from Firestore
    DocumentSnapshot<Map<String, dynamic>> stationSnapshot =
        await FirebaseFirestore.instance
            .collection('charging_stations')
            .doc(widget.stationId)
            .get();

    if (!stationSnapshot.exists) {
      // Handle the case where the charging station does not exist in the database
      print('Charging station not found.');
      throw Exception('Charging station not found.');
    }

    // Get the charging rate from the document snapshot and handle the nullable type
    num? chargingRate = stationSnapshot.data()?['chargingRate'];

    if (chargingRate == null) {
      // Handle the case where 'chargingRate' is not available in the document
      print('Charging rate not available.');
      throw Exception('Charging rate not available.');
    }

    return chargingRate.toDouble(); // Convert num to double
  }

  Future<void> _handlePayment() async {
    String selectedDateText = _dateController.text;
    if (selectedDateText.isEmpty) {
      // Show an error message if the date is not selected
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Date'),
            content: Text('Please enter a date.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    if (_selectedPaymentMethod == null) {
      // Show an error message if no payment method is selected
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Payment Method'),
            content: Text('Please choose a payment method.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Fetch the charging station availability from Firestore
    DocumentSnapshot<Map<String, dynamic>> stationSnapshot =
    await FirebaseFirestore.instance
        .collection('charging_stations')
        .doc(widget.stationId)
        .get();

    if (!stationSnapshot.exists) {
      // Handle the case where the charging station does not exist in the database
      print('Charging station not found.');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('The charging station does not exist in the database.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Check if the charging station is available for booking
    bool chargingStationAvailable = stationSnapshot.data()?['availability'] ?? false;

    if (!chargingStationAvailable) {
      // Show dialog if charging station is not available
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Charging Station Not Available'),
            content: Text('The charging station is currently not available for booking.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Calculate the total amount based on charging rate and hours of charge
    double chargingRate = await _getChargingRate();
    double totalAmount = chargingRate * selectedHours;
    DateTime selectedDate = DateTime.parse(_dateController.text);

    // Create a new Booking object with the booking details and initial status as 'Unpaid'
    Booking booking = Booking(
      bookingId: '',
      userId: getCurrentUserId(),
      stationId: widget.stationId,
      startTime: selectedStartTime,
      endTime: selectedEndTime,
      hoursOfCharge: selectedHours,
      paymentMethod: _selectedPaymentMethod!.name,
      totalAmount: totalAmount,
      bookingTimestamp: Timestamp.now(),
      bookingStatus: 'Unpaid',
      selectedDate:
          selectedDate, // Include the selectedDate in the Booking object
    );

    // Store the booking details in Firestore
    DocumentReference bookingRef = await FirebaseFirestore.instance
        .collection('bookings')
        .add(booking.toMap());

    // Update the bookingId with the newly generated ID from Firestore
    String newBookingId = bookingRef.id;
    booking = booking.copyWith(bookingId: newBookingId);

    // Simulate the payment completion and show the booking details
    bool? paymentSuccessful =
        await _simulatePaymentCompletion(context, booking);

    if (paymentSuccessful == true) {
      // Payment was successful, update the booking status to 'Paid'
      await _updateBookingStatus(context, booking, Booking.paidStatus);
    } else {
      // Payment was canceled, update the booking status to 'Unpaid'
      await _updateBookingStatus(context, booking, Booking.unpaidStatus);
    }
  }

  // Add this method inside the _BookingPageState class
  Future<String?> _getChargingStationName(String stationId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> stationSnapshot =
          await FirebaseFirestore.instance
              .collection('charging_stations')
              .doc(stationId)
              .get();

      if (stationSnapshot.exists) {
        return stationSnapshot.data()?['name'];
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching charging station name: $e');
      return null;
    }
  }

  // Create a list of time slots with valid times (current time or upcoming time)
  List<String> timeSlots = [
    '12:00 AM',
    '01:00 AM',
    '02:00 AM',
    '03:00 AM',
    '04:00 AM',
    '05:00 AM',
    '06:00 AM',
    '07:00 AM',
    '08:00 AM',
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
    '06:00 PM',
    '07:00 PM',
    '08:00 PM',
    '09:00 PM',
    '10:00 PM',
    '11:00 PM',
  ];

  Future<void> _selectDate(BuildContext context) async {
    // Get the current date
    final DateTime now = DateTime.now();

    // Show the date picker dialog
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year +
          1), // Allow picking dates up to 1 year from the current date
    );

    // Update the selected date in the text field
    if (pickedDate != null && pickedDate != now) {
      setState(() {
        _dateController.text = pickedDate.toString().split(
            ' ')[0]; // Display the selected date in the format YYYY-MM-DD
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  int _maxHours = 8; // Maximum number of hours available for charging

  // Slider widget for selecting hours of charge
  Slider _buildHourSlider() {
    return Slider(
      activeColor: Color(0xff2d366f),
      inactiveColor: Color(0xff9dd1ea),
      value: selectedHours.toDouble(),
      min: 1,
      max: _maxHours.toDouble(),
      // Adjust the max value to increase the range
      divisions: _maxHours - 1,
      // Increase the number of divisions
      onChanged: (double value) {
        updateSelectedHours(value);
      },
      label: '$selectedHours hour${selectedHours != 1 ? 's' : ''}',
    );
  }

  @override
  Widget build(BuildContext context) {
    // Radio button widget for each payment method
    Widget _buildPaymentMethodRadio(PaymentMethod paymentMethod) {
      return RadioListTile(
        title: Text(
          paymentMethod.name,
          style: SafeGoogleFont(
            'Lato',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Change text color to black
          ),
        ),
        subtitle: Text(
          paymentMethod.description,
          style: SafeGoogleFont(
            'Lato',
            fontSize: 14,
            color: Colors.black54, // Change text color to black
          ),
        ),
        value: paymentMethod,
        groupValue: _selectedPaymentMethod,
        onChanged: (value) {
          setState(() {
            _selectedPaymentMethod = value as PaymentMethod;
          });
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xff2d366f)),
          // Change icon color to black
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          "Booking Slot",
          style: SafeGoogleFont(
            'Lato',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xff2d366f), // Change text color to black
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Color(0xff9dd1ea),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<String?>(
                future: _getChargingStationName(widget.stationId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: Text(
                      'Loading...',
                      style: SafeGoogleFont(
                        'Lato',
                        fontSize: 16,
                        color: Colors.black, // Change text color to black
                      ),
                    ));
                  } else if (snapshot.hasData && snapshot.data != null) {
                    return Center(
                      child: Text(
                        '${snapshot.data}',
                        style: SafeGoogleFont(
                          'Lato',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Change text color to black
                        ),
                      ),
                    );
                  } else {
                    return Center(
                        child: Text(
                      'Charging Station Name Not Found',
                      style: SafeGoogleFont(
                        'Lato',
                        fontSize: 16,
                        color: Colors.black, // Change text color to black
                      ),
                    ));
                  }
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                readOnly: true,
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Select Date:',
                  labelStyle: SafeGoogleFont(
                    'Lato',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                  suffixIcon: Icon(Icons.calendar_today,
                      color: Colors.black), // Change icon color to black
                ),
                onTap: () {
                  // Show the date picker dialog when the text field is tapped
                  _selectDate(context);
                },
              ),
              SizedBox(height: 20),
              Text(
                'Select Start Time:',
                style: SafeGoogleFont(
                  'Lato',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Change text color to black
                ),
              ),
              SizedBox(height: 8),
              DropdownButton<String>(
                value: selectedStartTime,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedStartTime = newValue!;
                    int startHour = int.parse(selectedStartTime.split(':')[0]);
                    int endHour = startHour + selectedHours;
                    selectedEndTime =
                        '${endHour.toString().padLeft(2, '0')}:00 ${endHour >= 12 ? 'PM' : 'AM'}';
                  });
                },
                items: timeSlots.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: SafeGoogleFont(
                        'Lato',
                        fontSize: 16,
                        color: Colors.black, // Change text color to black
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Text(
                'Select Hours of Charge:',
                style: SafeGoogleFont(
                  'Lato',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              _buildHourSlider(),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'End Time:',
                    style: SafeGoogleFont(
                      'Lato',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Change text color to black
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    '$selectedEndTime',
                    style: SafeGoogleFont(
                      'Lato',
                      fontSize: 16,
                      color: Colors.black, // Change text color to black
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Choose Payment Method:',
                style: SafeGoogleFont(
                  'Lato',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              // radio button for each payment method
              Column(
                children: _paymentMethods.map((paymentMethod) {
                  return _buildPaymentMethodRadio(paymentMethod);
                }).toList(),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xff2d366f),
                  ),
                  onPressed: () {
                    _handlePayment();
                  },
                  child: Text(
                    'Confirm Booking',
                    style: SafeGoogleFont(
                      'Lato',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
