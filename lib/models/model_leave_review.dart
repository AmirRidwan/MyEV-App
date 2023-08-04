import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String bookingId;
  final String stationId;
  final String userId;
  final String profileImageUrl;
  final String displayName;
  final int rating;
  final String review;
  final Timestamp timestamp; // Keep timestamp as Timestamp type

  Review({
    required this.bookingId,
    required this.stationId,
    required this.userId,
    required this.profileImageUrl,
    required this.displayName,
    required this.rating,
    required this.review,
    required this.timestamp,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      bookingId: map['bookingId'],
      stationId: map['stationId'],
      userId: map['userId'],
      profileImageUrl: map['profileImageUrl'],
      displayName: map['displayName'],
      rating: map['rating'],
      review: map['review'],
      timestamp: map['timestamp'], // No conversion needed for Timestamp
    );
  }

  Map<String, dynamic> toJson() => {
    'bookingId': bookingId,
    'stationId': stationId,
    'userId': userId,
    'profileImageUrl': profileImageUrl,
    'displayName': displayName,
    'rating': rating,
    'review': review,
    'timestamp': timestamp,
  };
}
