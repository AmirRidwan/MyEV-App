import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String bookingId;
  final String stationId;
  final String userId;
  final int rating;
  final String review;
  final Timestamp timestamp; // Keep timestamp as Timestamp type

  Review({
    required this.bookingId,
    required this.stationId,
    required this.userId,
    required this.rating,
    required this.review,
    required this.timestamp,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      bookingId: map['bookingId'],
      stationId: map['stationId'],
      userId: map['userId'],
      rating: map['rating'],
      review: map['review'],
      timestamp: map['timestamp'], // No conversion needed for Timestamp
    );
  }

  Map<String, dynamic> toJson() => {
    'bookingId': bookingId,
    'stationId': stationId,
    'userId': userId,
    'rating': rating,
    'review': review,
    'timestamp': timestamp,
  };
}
