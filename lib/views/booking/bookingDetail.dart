import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../controllers/FirestoreService.dart';
import '../../models/model_booking.dart';
import '../../utils.dart';
import 'LeaveReviewPage.dart';

class BookingDetailPage extends StatelessWidget {
  final String bookingId;

  const BookingDetailPage({required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Booking>(
      stream: FirestoreService().getBookingStream(bookingId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Color(0xff2d366f)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              centerTitle: true,
              title: Text(
                "Booking Details",
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
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final booking = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Color(0xff2d366f)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            title: Text(
              "Booking Details",
              style: SafeGoogleFont(
                'Lato',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xff2d366f),
              ),
            ),
            elevation: 2.0,
            backgroundColor: Color(0xff9dd1ea),
          ),
          backgroundColor: Colors.white,
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 896,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Booking Details Section
                    Column(
                      children: [
                        Text(
                          'Booking Details',
                          style: SafeGoogleFont(
                            'Lato',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.grey, //color of divider
                      height: 16,
                      thickness: 1,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.assignment_turned_in_outlined,
                          color: booking.bookingStatus == 'Paid'
                              ? Colors.green
                              : Colors.red,
                          size: 20,
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Status: ${booking.bookingStatus}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: booking.bookingStatus == 'Paid'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: Colors.transparent,
                          size: 20,
                        ),
                        SizedBox(width: 16),
                        Text(
                          '#${booking.bookingId}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_outlined,
                          color: Colors.black,
                          size: 20,
                        ),
                        SizedBox(width: 16),
                        Text(
                          '${booking.customerName ?? 'Unknown'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    FutureBuilder<Map<String, String>>(
                      future: FirestoreService()
                          .getChargingStationDetails(booking.stationId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('Location: Loading...');
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          String chargingStationName = snapshot.data!['name'] ??
                              'Unknown Charging Station';
                          String chargingStationAddress =
                              snapshot.data!['address'] ?? 'Unknown Address';

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                  SizedBox(width: 16),
                                  Text(
                                    chargingStationName,
                                    style: SafeGoogleFont(
                                      'Lato',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.transparent,
                                    size: 20,
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      chargingStationAddress,
                                      style: SafeGoogleFont('Lato',
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          color: Colors.black,
                          size: 20,
                        ),
                        SizedBox(width: 16),
                        // Add some space between the icon and the text
                        Text(
                          '${DateFormat('EEEE, dd MMM').format(booking.selectedDate)}',
                          style: SafeGoogleFont(
                            'Lato',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.black,
                          size: 20,
                        ),
                        SizedBox(width: 16),
                        Text(
                          '${booking.startTime} - ${booking.endTime}',
                          style: SafeGoogleFont(
                            'Lato',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.hourglass_bottom_outlined,
                          color: Colors.black,
                          size: 20,
                        ),
                        SizedBox(width: 16),
                        Text(
                          '${booking.hoursOfCharge} hours',
                          style: SafeGoogleFont(
                            'Lato',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Payment Section
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ListTileTheme(
                        contentPadding: EdgeInsets.all(0),
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          textColor: Colors.black,
                          iconColor: Colors.grey,
                          title: Row(
                            children: [
                              Icon(
                                Icons.monetization_on_outlined,
                                color: Colors.black,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Payment',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Payment Method',
                                        style: SafeGoogleFont(
                                          'Lato',
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '${booking.paymentMethod}',
                                        style: SafeGoogleFont(
                                          'Lato',
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total Amount',
                                        style: SafeGoogleFont(
                                          'Lato',
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        'RM${booking.totalAmount.toStringAsFixed(2)}',
                                        style: SafeGoogleFont(
                                          'Lato',
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                        color: Colors.grey, //color of divider
                        height: 16,
                        thickness: 1),
                    // Center Policy Section
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ListTileTheme(
                        contentPadding: EdgeInsets.all(0),
                        child: ExpansionTile(
                          textColor: Colors.black,
                          iconColor: Colors.grey,
                          title: Row(
                            children: [
                              Icon(
                                Icons.policy_outlined,
                                color: Colors.black,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Center Policy',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: Text(
                                      '1.',
                                      style: SafeGoogleFont(
                                        'Lato',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    title: Text(
                                      'All bookings must be made at least 24 hours in advance.',
                                      textAlign: TextAlign.justify,
                                      style: SafeGoogleFont(
                                        'Lato',
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    leading: Text(
                                      '2.',
                                      style: SafeGoogleFont(
                                        'Lato',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    title: Text(
                                      'Cancellation or rescheduling of bookings is allowed up to 6 hours before the scheduled start time.',
                                      textAlign: TextAlign.justify,
                                      style: SafeGoogleFont(
                                        'Lato',
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    leading: Text(
                                      '3.',
                                      style: SafeGoogleFont(
                                        'Lato',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    title: Text(
                                      'Failure to show up within 15 minutes of the scheduled start time will result in the booking being canceled and fees charged.',
                                      textAlign: TextAlign.justify,
                                      style: SafeGoogleFont(
                                        'Lato',
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    leading: Text(
                                      '4.',
                                      style: SafeGoogleFont(
                                        'Lato',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    title: Text(
                                      'Customers are responsible for the proper use of charging equipment, and any damages will be subject to additional fees.',
                                      textAlign: TextAlign.justify,
                                      style: SafeGoogleFont(
                                        'Lato',
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    leading: Text(
                                      '5.',
                                      style: SafeGoogleFont(
                                        'Lato',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    title: Text(
                                      'Please keep the charging station area clean and tidy for the convenience of other users.',
                                      textAlign: TextAlign.justify,
                                      style: SafeGoogleFont(
                                        'Lato',
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                        color: Colors.grey, //color of divider
                        height: 16,
                        thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Cancel Booking Button
                        if (booking.bookingStatus == 'Unpaid')
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.red, // Use your desired color
                            ),
                            onPressed: () async {
                              // Show the confirmation dialog
                              bool confirmCancel = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                      'Confirm Cancellation',
                                      style: TextStyle(
                                        fontFamily: 'Lato',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    content: Text(
                                      'Are you sure you want to cancel this booking?',
                                      style: TextStyle(
                                        fontFamily: 'Lato',
                                        fontSize: 16,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        child: Text(
                                          'No',
                                          style: TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: Text(
                                          'Yes',
                                          style: TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirmCancel == true) {
                                // Delete the booking from Firestore
                                await FirestoreService()
                                    .deleteBooking(booking.bookingId);

                                // Navigate back to the previous screen
                                Navigator.of(context).pop();
                              }
                            },
                            child: Text(
                              'Cancel Booking',
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        SizedBox(width: 10),
                        //Continue Payment Button
                        if (booking.bookingStatus == 'Unpaid')
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff2d366f),
                            ),
                            onPressed: () {
                              // Show the confirmation dialog
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                      'Confirm Payment',
                                      style: SafeGoogleFont(
                                        'Lato',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    content: Text(
                                      'Are you sure you want to proceed with the payment?',
                                      style: SafeGoogleFont(
                                        'Lato',
                                        fontSize: 16,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          'Cancel',
                                          style: SafeGoogleFont(
                                            'Lato',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Update the booking status to Paid in Firebase
                                          FirestoreService()
                                              .updateBookingStatus(
                                            bookingId: booking.bookingId,
                                            newStatus: 'Paid',
                                          );
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          'Confirm',
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
                            },
                            child: Text(
                              'Continue Payment',
                              style: SafeGoogleFont(
                                'Lato',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    FutureBuilder<bool>(
                      future: FirestoreService()
                          .doesReviewExistForBooking(booking.bookingId),
                      builder: (context, reviewSnapshot) {
                        if (reviewSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else {
                          bool reviewExists = reviewSnapshot.data ?? false;
                          bool canLeaveReview =
                              booking.bookingStatus == 'Paid' && !reviewExists;

                          if (canLeaveReview) {
                            return Align(
                              alignment: Alignment.bottomRight,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xff2d366f),
                                ),
                                onPressed: () {
                                  // Navigate to the review page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReviewPage(
                                          stationId: booking.stationId,
                                          currentUserId: booking.userId,
                                          bookingId: bookingId),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Leave Review',
                                  style: SafeGoogleFont(
                                    'Lato',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return SizedBox.shrink(); // Hide the button
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
