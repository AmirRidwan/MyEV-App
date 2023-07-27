import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String bookingId; // Add the bookingId field
  final String userId;
  final String stationId;
  final String startTime;
  final String endTime;
  final int hoursOfCharge;
  final String paymentMethod;
  final double totalAmount;
  final Timestamp bookingTimestamp;
  final String bookingStatus;
  final DateTime selectedDate;

  // Define constants for booking status
  static const String paidStatus = 'Paid';
  static const String unpaidStatus = 'Unpaid';

  Booking({
    required this.bookingId, // Add the bookingId field to the constructor
    required this.userId,
    required this.stationId,
    required this.startTime,
    required this.endTime,
    required this.hoursOfCharge,
    required this.paymentMethod,
    required this.totalAmount,
    required this.bookingTimestamp,
    required this.bookingStatus,
    required this.selectedDate,
  });

  // Convert Booking object to a map representation for Firestore
  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId, // Include the bookingId in the map
      'userId': userId,
      'stationId': stationId,
      'startTime': startTime,
      'endTime': endTime,
      'hoursOfCharge': hoursOfCharge,
      'paymentMethod': paymentMethod,
      'totalAmount': totalAmount,
      'bookingTimestamp': bookingTimestamp,
      'bookingStatus': bookingStatus,
      'selectedDate': Timestamp.fromDate(selectedDate),
    };
  }

  // Create a Booking object from a Firestore document snapshot
  static Booking fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Booking(
      bookingId: snapshot.id, // Extract the document ID as bookingId
      userId: data['userId'],
      stationId: data['stationId'],
      startTime: data['startTime'],
      endTime: data['endTime'],
      hoursOfCharge: data['hoursOfCharge'],
      paymentMethod: data['paymentMethod'],
      totalAmount: data['totalAmount'],
      bookingTimestamp: data['bookingTimestamp'],
      bookingStatus: data['bookingStatus'],
      selectedDate: data['selectedDate'],
    );
  }

  Booking copyWith({
    String? bookingId,
    String? userId,
    String? stationId,
    String? startTime,
    String? endTime,
    int? hoursOfCharge,
    String? paymentMethod,
    double? totalAmount,
    String? bookingDate,
    String? bookingTime,
    Timestamp? bookingTimestamp,
    String? bookingStatus,
    DateTime? selectedDate,

  }) {
    return Booking(
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      stationId: stationId ?? this.stationId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      hoursOfCharge: hoursOfCharge ?? this.hoursOfCharge,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      totalAmount: totalAmount ?? this.totalAmount,
      bookingTimestamp: bookingTimestamp ?? this.bookingTimestamp,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}
