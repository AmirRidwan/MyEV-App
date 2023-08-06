import 'package:evfinder/utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../base/resizer/fetch_pixels.dart';
import '../../models/model_leave_review.dart';

class Reviews extends StatefulWidget {
  final String stationId;
  const Reviews({Key? key, required this.stationId}) : super(key: key);

  @override
  State<Reviews> createState() => _ReviewsState();
}

String defaultUrl =
    'https://firebasestorage.googleapis.com/v0/b/evfinder-ad6f0.appspot.com/o/default_avatar.png?alt=media&token=aabd68a9-29ce-4f99-9c7b-7b47fae2070a';

class _ReviewsState extends State<Reviews> {
  String selectedSortOption = 'Newest';

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
          return Center(child: Text(
              'No reviews available',
                  style: SafeGoogleFont(
                    'Lato',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
          ));
        }

        // Convert query snapshot to a list of Review objects
        List<Review> reviewList = snapshot.data!.docs
            .map((doc) => Review.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        // Sort the reviewList based on the selected sorting option
        if (selectedSortOption == 'Newest') {
          reviewList.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
        } else if (selectedSortOption == 'Star Rating') {
          reviewList.sort((a, b) => b.rating!.compareTo(a.rating!));
        }


        return Padding(
          padding: const EdgeInsets.only(left: 16, right: 16,bottom: 16,top: 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Rating & Review",
                    style: SafeGoogleFont(
                      'Lato',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  // Add the sorting dropdown button
                  DropdownButton<String>(
                    value: selectedSortOption,
                    onChanged: (newValue) {
                      setState(() {
                        selectedSortOption = newValue!;
                      });
                    },
                    items: <String>['Newest', 'Star Rating'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildOverallRating(reviewList),
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
          ),
        );
      },
    );
  }

  int calculateStarCount(List<Review> reviewList, int star) {
    return reviewList.where((review) => review.rating == star).length;
  }

  Widget _buildOverallRating(List<Review> reviewList) {
    double overallRating = calculateOverallRating(reviewList);

    int fiveStarCount = calculateStarCount(reviewList, 5);
    int fourStarCount = calculateStarCount(reviewList, 4);
    int threeStarCount = calculateStarCount(reviewList, 3);
    int twoStarCount = calculateStarCount(reviewList, 2);
    int oneStarCount = calculateStarCount(reviewList, 1);

    List<RatingCount> ratingCounts = [
      RatingCount(5, fiveStarCount),
      RatingCount(4, fourStarCount),
      RatingCount(3, threeStarCount),
      RatingCount(2, twoStarCount),
      RatingCount(1, oneStarCount),
    ];

    int totalReviews =
        reviewList.length; // Calculate the total number of reviews

    return Column(
      children: [
        ...ratingCounts.map((ratingCount) {
          return Row(
            children: [
              Text(
                '${ratingCount.starCount} Star:',
                style: SafeGoogleFont('Lato', fontSize: 14),
              ),
              SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: ratingCount.count / totalReviews,
                  // Use totalReviews here
                  color: Colors.amber,
                  backgroundColor: Colors.grey[300],
                ),
              ),
              SizedBox(width: 8),
              Text('${ratingCount.count}'),
            ],
          );
        }).toList(),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${overallRating.toStringAsFixed(1)} out of 5',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Text(
              '${reviewList.length} ${reviewList.length == 1 ? 'Review' : 'Reviews'}', // Display the total reviews
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewItem(Review modelReview) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('users').doc(modelReview.userId).get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          // Handle the case where user data doesn't exist
          return SizedBox(); // Return an empty widget or appropriate placeholder
        }

        var userData = userSnapshot.data!.data() as Map<String, dynamic>;
        var displayName = userData['displayName'];
        var profileImageUrl = userData['profileImageUrl'];

        return Container(
          margin: EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                    ? NetworkImage(profileImageUrl)
                    : NetworkImage(defaultUrl),
                backgroundColor: Colors.white,
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName != null && displayName.isNotEmpty ? displayName : 'N/A',
                    style: SafeGoogleFont('Lato',
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(modelReview.review ?? '',
                      style: SafeGoogleFont('Lato',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54)),
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
                      onRatingUpdate: (rating) {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  double calculateOverallRating(List<Review> reviewList) {
    if (reviewList.isEmpty) {
      return 0.0;
    }

    num totalRating =
        reviewList.map((review) => review.rating ?? 0).reduce((a, b) => a + b);
    double overallRating = totalRating / reviewList.length;

    return overallRating.toDouble();
  }
}

class RatingCount {
  final int starCount;
  final int count;

  RatingCount(this.starCount, this.count);
}
