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

  Future<void> deleteBooking(String bookingId) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).delete();
    } catch (e) {
      print('Error deleting booking: $e');
    }
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

  Future<bool> doesReviewExistForBooking(String bookingId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> reviewQuerySnapshot =
      await FirebaseFirestore.instance.collection('reviews')
          .where('bookingId', isEqualTo: bookingId)
          .get();

      return reviewQuerySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking review existence: $e');
      return false;
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

  Future<void> updateBookingStatus({
    required String bookingId,
    required String newStatus,
  }) async {
    try {
      final bookingRef =
      FirebaseFirestore.instance.collection('bookings').doc(bookingId);
      await bookingRef.update({'bookingStatus': newStatus});
    } catch (e) {
      // Handle the error, if any
      print('Error updating booking status: $e');
    }
  }

}
