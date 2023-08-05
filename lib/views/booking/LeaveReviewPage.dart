import 'package:evfinder/views/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/model_leave_review.dart';
import '../../utils.dart';

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

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()), // Replace TabHomePage with the actual name of your TabHome page
                (route) => false, // Remove all routes from the stack
          );

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xff2d366f)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          "Edit Profile",
          style: SafeGoogleFont(
            'Lato',
            fontSize:  24,
            fontWeight:  FontWeight.bold,
            color:  Color(0xff2d366f),
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color(0xff9dd1ea),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Leave a Review',
              style: SafeGoogleFont(
                  'Lato',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            Text(
                'Select your rating:',
              style: SafeGoogleFont(
                'Lato',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
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
