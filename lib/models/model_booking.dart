import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String bookingId;
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
  final String? customerName;

  // Define constants for booking status
  static const String paidStatus = 'Paid';
  static const String unpaidStatus = 'Unpaid';

  Booking({
    required this.bookingId,
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
    this.customerName,
  });

  // Convert Booking object to a map representation for Firestore
  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
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
      'customerName': customerName, // Include customerName in the map
    };
  }

  // Create a Booking object from a Firestore document snapshot
  static Booking fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Booking(
      bookingId: snapshot.id,
      userId: data['userId'],
      stationId: data['stationId'],
      startTime: data['startTime'],
      endTime: data['endTime'],
      hoursOfCharge: data['hoursOfCharge'],
      paymentMethod: data['paymentMethod'],
      totalAmount: data['totalAmount'],
      bookingTimestamp: data['bookingTimestamp'],
      bookingStatus: data['bookingStatus'],
      selectedDate: (data['selectedDate'] as Timestamp).toDate(),
      customerName: data['customerName'],
    );
  }

  // Create a Booking object with default values for nullable fields
  factory Booking.empty() {
    return Booking(
      bookingId: '',
      userId: '',
      stationId: '',
      startTime: '',
      endTime: '',
      hoursOfCharge: 0,
      paymentMethod: '',
      totalAmount: 0.0,
      bookingTimestamp: Timestamp.now(),
      bookingStatus: '',
      selectedDate: DateTime.now(),
      customerName: null,
    );
  }

  // Create a copy of the Booking object with some fields updated
  Booking copyWith({
    String? bookingId,
    String? userId,
    String? stationId,
    String? startTime,
    String? endTime,
    int? hoursOfCharge,
    String? paymentMethod,
    double? totalAmount,
    Timestamp? bookingTimestamp,
    String? bookingStatus,
    DateTime? selectedDate,
    String? customerName,
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
      customerName: customerName ?? this.customerName,
    );
  }
}
