import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../base/color_data.dart';
import '../../base/resizer/fetch_pixels.dart';
import '../../base/widget_utils.dart';
import '../../models/model_review.dart';


class Reviews extends StatefulWidget {
  const Reviews({Key? key}) : super(key: key);

  @override
  State<Reviews> createState() => _ReviewsState();
}

class _ReviewsState extends State<Reviews> {
  List<ModelReview> reviewLists = [
    ModelReview("review1.png",
        '“I Was A vrey First To Pleased With This Charging Satation”.'),
    ModelReview("review2.png",
        '“Thank You For Your Services That Save My Time Very Much”.'),
    ModelReview("review3.png",
        '“This app is very usefull for all the person in around, so thank you so much for this all”.'),
    ModelReview("review4.png",
        '“This app is very usefull for all the person in around, so thank you so much for this all”.')
  ];

  @override
  Widget build(BuildContext context) {
    FetchPixels(context);
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: FetchPixels.getPixelHeight(20)),
      primary: true,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            getCustomFont("Rating & Review", 17, Colors.black, 1,
                fontWeight: FontWeight.w700),
            getCustomFont("View All", 15, Colors.black, 1,
                fontWeight: FontWeight.w700)
          ],
        ),
        getVerSpace(FetchPixels.getPixelHeight(16)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                getCustomFont("4.5", 36, Colors.black, 1,
                    fontWeight: FontWeight.w700),
                getCustomFont("out of 5", 16, Colors.black, 1,
                    fontWeight: FontWeight.w500)
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    RatingBar(
                      initialRating: 5,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemSize: FetchPixels.getPixelHeight(11),
                      itemCount: 5,
                      ratingWidget: RatingWidget(
                        full: getSvgImage("like.svg"),
                        half: getSvgImage("like.svg"),
                        empty: getSvgImage("like_unselected.svg"),
                      ),
                      itemPadding: EdgeInsets.symmetric(
                          horizontal: FetchPixels.getPixelHeight(1)),
                      onRatingUpdate: (rating) {},
                    ),
                    getHorSpace(FetchPixels.getPixelHeight(6)),
                    LinearPercentIndicator(
                      width: FetchPixels.getPixelHeight(180),
                      animation: false,
                      lineHeight: FetchPixels.getPixelHeight(4),
                      percent: 1.0,
                      barRadius:
                      Radius.circular(FetchPixels.getPixelHeight(10)),
                      progressColor: buttonColor,
                      backgroundColor: borderColor,
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                getVerSpace(FetchPixels.getPixelHeight(6)),
                Row(
                  children: [
                    RatingBar(
                      initialRating: 4,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemSize: FetchPixels.getPixelHeight(11),
                      itemCount: 4,
                      ratingWidget: RatingWidget(
                        full: getSvgImage("like.svg"),
                        half: getSvgImage("like.svg"),
                        empty: getSvgImage("like_unselected.svg"),
                      ),
                      itemPadding: EdgeInsets.symmetric(
                          horizontal: FetchPixels.getPixelHeight(1)),
                      onRatingUpdate: (rating) {},
                    ),
                    getHorSpace(FetchPixels.getPixelHeight(6)),
                    LinearPercentIndicator(
                      width: FetchPixels.getPixelHeight(180),
                      animation: false,
                      lineHeight: FetchPixels.getPixelHeight(4),
                      percent: 0.60,
                      barRadius:
                      Radius.circular(FetchPixels.getPixelHeight(10)),
                      progressColor: buttonColor,
                      backgroundColor: borderColor,
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                getVerSpace(FetchPixels.getPixelHeight(6)),
                Row(
                  children: [
                    RatingBar(
                      initialRating: 3,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemSize: FetchPixels.getPixelHeight(11),
                      itemCount: 3,
                      ratingWidget: RatingWidget(
                        full: getSvgImage("like.svg"),
                        half: getSvgImage("like.svg"),
                        empty: getSvgImage("like_unselected.svg"),
                      ),
                      itemPadding: EdgeInsets.symmetric(
                          horizontal: FetchPixels.getPixelHeight(1)),
                      onRatingUpdate: (rating) {},
                    ),
                    getHorSpace(FetchPixels.getPixelHeight(6)),
                    LinearPercentIndicator(
                      width: FetchPixels.getPixelHeight(180),
                      animation: false,
                      lineHeight: FetchPixels.getPixelHeight(4),
                      percent: 0.25,
                      barRadius:
                      Radius.circular(FetchPixels.getPixelHeight(10)),
                      progressColor: buttonColor,
                      backgroundColor: borderColor,
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                getVerSpace(FetchPixels.getPixelHeight(6)),
                Row(
                  children: [
                    RatingBar(
                      initialRating: 2,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemSize: FetchPixels.getPixelHeight(11),
                      itemCount: 2,
                      ratingWidget: RatingWidget(
                        full: getSvgImage("like.svg"),
                        half: getSvgImage("like.svg"),
                        empty: getSvgImage("like_unselected.svg"),
                      ),
                      itemPadding: EdgeInsets.symmetric(
                          horizontal: FetchPixels.getPixelHeight(1)),
                      onRatingUpdate: (rating) {},
                    ),
                    getHorSpace(FetchPixels.getPixelHeight(6)),
                    LinearPercentIndicator(
                      width: FetchPixels.getPixelHeight(180),
                      animation: false,
                      lineHeight: FetchPixels.getPixelHeight(4),
                      percent: 0.40,
                      barRadius:
                      Radius.circular(FetchPixels.getPixelHeight(10)),
                      progressColor: buttonColor,
                      backgroundColor: borderColor,
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                getVerSpace(FetchPixels.getPixelHeight(6)),
                Row(
                  children: [
                    RatingBar(
                      initialRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemSize: FetchPixels.getPixelHeight(11),
                      itemCount: 1,
                      ratingWidget: RatingWidget(
                        full: getSvgImage("like.svg"),
                        half: getSvgImage("like.svg"),
                        empty: getSvgImage("like_unselected.svg"),
                      ),
                      itemPadding: EdgeInsets.symmetric(
                          horizontal: FetchPixels.getPixelHeight(1)),
                      onRatingUpdate: (rating) {},
                    ),
                    getHorSpace(FetchPixels.getPixelHeight(6)),
                    LinearPercentIndicator(
                      width: FetchPixels.getPixelHeight(180),
                      animation: false,
                      lineHeight: FetchPixels.getPixelHeight(4),
                      percent: 0.10,
                      barRadius:
                      Radius.circular(FetchPixels.getPixelHeight(10)),
                      progressColor: buttonColor,
                      backgroundColor: borderColor,
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
        getVerSpace(FetchPixels.getPixelHeight(12)),
        getCustomFont(
            '4 Reviews', 14, Colors.black, 1, fontWeight: FontWeight.w500,
            textAlign: TextAlign.end),
        getVerSpace(FetchPixels.getPixelHeight(16)),
        ListView.builder(
          primary: false,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: reviewLists.length,
          itemBuilder: (context, index) {
            ModelReview modelReview = reviewLists[index];
            return Container(
              margin: EdgeInsets.only(bottom: FetchPixels.getPixelHeight(24)),
              child: Row(
                children: [
                  getAssetImage(modelReview.image ?? '',
                      width: FetchPixels.getPixelHeight(32),
                      height: FetchPixels.getPixelHeight(32)),
                  getHorSpace(FetchPixels.getPixelHeight(6)),
                  Expanded(
                    child: getMultilineCustomFont(
                        modelReview.review ?? "", 12, subtext,
                        fontWeight: FontWeight.w600,
                        txtHeight: FetchPixels.getPixelHeight(1.3)),
                  )
                ],
              ),
            );
          },
        )
      ],
    );
  }
}
