import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/model_booking.dart';

class FirestoreService {
  final CollectionReference bookingsCollection =
  FirebaseFirestore.instance.collection('bookings');
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');

  Future<void> addBooking(Booking booking) async {
    await bookingsCollection.doc(booking.bookingId).set(booking.toMap());
  }

  Stream<Booking> getBookingStream(String bookingId) {
    return FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .snapshots()
        .transform(StreamTransformer.fromHandlers(handleData: (snapshot, sink) {
      final booking = Booking.fromSnapshot(snapshot);
      if (booking != null) {
        sink.add(booking);
      }
    }));
  }

  Future<String> getUserName(String userId) async {
    try {
      final userDoc = await usersCollection.doc(userId).get();
      if (userDoc.exists) {
        return userDoc['displayName'];
      }
      return 'Unknown User';
    } catch (e) {
      return 'Unknown User';
    }
  }

  Future<Map<String, String>> getChargingStationDetails(String stationId) async {
    try {
      DocumentSnapshot doc =
      await FirebaseFirestore.instance.collection('charging_stations').doc(stationId).get();

      if (doc.exists) {
        String name = doc['name'] ?? 'Unknown Charging Station';
        String address = doc['address'] ?? 'Unknown Address';

        return {
          'name': name,
          'address': address,
        };
      } else {
        return {
          'name': 'Unknown Charging Station',
          'address': 'Unknown Address',
        };
      }
    } catch (e) {
      print('Error getting charging station details: $e');
      return {
        'name': 'Unknown Charging Station',
        'address': 'Unknown Address',
      };
    }
  }

}
