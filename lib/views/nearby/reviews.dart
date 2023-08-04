import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../models/model_leave_review.dart';

class Reviews extends StatefulWidget {
  final String stationId;
  const Reviews({Key? key, required this.stationId}) : super(key: key);

  @override
  State<Reviews> createState() => _ReviewsState();
}

class _ReviewsState extends State<Reviews> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('stationId', isEqualTo: widget.stationId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No reviews available.'));
        }

        List<Review> reviewList = snapshot.data!.docs
            .map((doc) => Review.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        return Column(
          children: [
            _buildOverallRating(reviewList), // Display overall rating above the list
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: reviewList.length,
                itemBuilder: (context, index) {
                  Review modelReview = reviewList[index];
                  return _buildReviewItem(modelReview);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOverallRating(List<Review> reviewList) {
    double overallRating = calculateOverallRating(reviewList);

    return Align(
      alignment: Alignment.topRight,
      child: Column(
        children: [
          Text(
            'Overall Rating',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          RatingBar.builder(
            ignoreGestures: true,
            initialRating: overallRating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 24,
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              // You can implement further logic here if needed
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Review modelReview) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 16,
            backgroundImage: NetworkImage(modelReview?.profileImageUrl ?? ''),
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                modelReview.displayName ?? '',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                modelReview.review ?? '',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(
                width: 100, // Adjust this width as needed
                child: RatingBar.builder(
                  ignoreGestures: true,
                  initialRating: modelReview.rating?.toDouble() ?? 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 16,
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double calculateOverallRating(List<Review> reviewList) {
    if (reviewList.isEmpty) {
      return 0.0;
    }

    num totalRating = reviewList.map((review) => review.rating ?? 0).reduce((a, b) => a + b);
    double overallRating = totalRating / reviewList.length;

    return overallRating.toDouble();
  }
}
