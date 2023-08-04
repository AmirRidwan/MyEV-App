import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/model_leave_review.dart';

class ReviewPage extends StatefulWidget {
  final String currentUserId;
  final String bookingId;
  final String stationId;

  ReviewPage({
    required this.currentUserId,
    required this.bookingId,
    required this.stationId,
  });

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int _rating = 0;
  TextEditingController _reviewController = TextEditingController();
  late String _bookingId;
  late String _stationId;
  late String _userId;
  late String _profileImageUrl;
  late String _displayName;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> bookingSnapshot =
      await firestore.collection('bookings').doc(widget.bookingId).get();

      if (bookingSnapshot.exists) {
        setState(() {
          _bookingId = widget.bookingId;
          _stationId = bookingSnapshot.data()!['stationId'];
        });

        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await firestore.collection('users').doc(widget.currentUserId).get();

        if (userSnapshot.exists) {
          setState(() {
            _displayName = userSnapshot.data()!['displayName'];
          });

          if (userSnapshot.data()!.containsKey('profileImageUrl') &&
              userSnapshot.data()!['profileImageUrl'] != null) {
            _profileImageUrl = userSnapshot.data()!['profileImageUrl'];
          } else {
            // Use a default profile image URL here
            _profileImageUrl =
            'https://firebasestorage.googleapis.com/v0/b/evfinder-ad6f0.appspot.com/o/default_avatar.png?alt=media&token=aabd68a9-29ce-4f99-9c7b-7b47fae2070a';
          }
        }
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }


  void _submitReview() async {
    if (_rating > 0 && _reviewController.text.isNotEmpty) {
      try {
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          _userId = user.uid;

          Review newReview = Review(
            bookingId: _bookingId,
            stationId: _stationId,
            userId: _userId,
            profileImageUrl: _profileImageUrl,
            displayName: _displayName,
            rating: _rating,
            review: _reviewController.text,
            timestamp: Timestamp.fromDate(DateTime.now()),
          );

          await FirebaseFirestore.instance.collection('reviews').add(newReview.toJson());

          // Reset the rating and review text field
          setState(() {
            _rating = 0;
            _reviewController.clear();
          });

          // Show a success message or navigate to a different screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Review submitted successfully!')),
          );

          // Navigate back to the previous page
          Navigator.pop(context);

        } else {
          // Handle the case where the user is not logged in
        }
      } catch (e) {
        print('Error submitting review: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting review. Please try again later.')),
        );
      }
    } else {
      // Show an error message if the rating or review is missing
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a rating and review.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leave a Review'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Leave a Review',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Select your rating:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 1; i <= 5; i++)
                  InkWell(
                    onTap: () {
                      setState(() {
                        _rating = i;
                      });
                    },
                    child: Icon(
                      Icons.star,
                      size: 40,
                      color: i <= _rating ? Colors.yellow : Colors.grey,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: _reviewController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Write a review',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitReview,
              child: Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
