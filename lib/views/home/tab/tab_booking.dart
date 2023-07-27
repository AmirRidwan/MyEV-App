import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../base/color_data.dart';
import '../../../base/constant.dart';
import '../../../base/resizer/fetch_pixels.dart';
import '../../../base/widget_utils.dart';
import '../../../models/model_ongoing.dart';
import '../../../utils.dart';
import '../../booking/paidBooking.dart';
import '../../booking/historyBooking.dart';
import '../../booking/unpaidBooking.dart';

class TabBooking extends StatefulWidget {
  const TabBooking({Key? key}) : super(key: key);

  @override
  State<TabBooking> createState() => _TabBookingState();
}

class _TabBookingState extends State<TabBooking>
    with SingleTickerProviderStateMixin {
  var horSpace = FetchPixels.getPixelHeight(20);
  TextEditingController searchController = TextEditingController();
  var select = 0;

  onItemChanged(String value) {
  }

  final PageController _controller = PageController(
    initialPage: 0,
  );

  late TabController tabController;
  var position = 0;

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void close() {
    Constant.closeApp();
  }

  String getCurrentUserId() {
    try {
      // Get the current user from FirebaseAuth
      User? user = FirebaseAuth.instance.currentUser;

      // Check if a user is signed in
      if (user != null) {
        // Return the user ID
        return user.uid;
      } else {
        // If no user is signed in, return an empty string or handle the case as per your requirements
        return '';
      }
    } catch (e) {
      // Handle any exceptions that may occur while getting the current user ID
      print('Error getting current user ID: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFC95B),
      body: Column(
        children: [
          getVerSpace(FetchPixels.getPixelHeight(10)),
          getVerSpace(FetchPixels.getPixelHeight(16)),
          Positioned(
            top: 16.0,
            left: 16.0,
            right: 16.0,
            child: Container(
              width: 380,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: SafeGoogleFont(
                        'Lato',
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          getVerSpace(FetchPixels.getPixelHeight(20)),
          tabBar(),
          pageView()
        ],
      ),
    );
  }

  Expanded pageView() {
    return Expanded(
      flex: 1,
      child: PageView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        children: [
          unpaidBooking(currentUserId: getCurrentUserId()),
          paidBooking(currentUserId: getCurrentUserId()),
          historyBooking(currentUserId: getCurrentUserId()),
        ],
        onPageChanged: (value) {
          setState(() {
            position = value;
            if (position == 0) {
            } else if (position == 1) {
            } else {
            }
          });
          tabController.animateTo(value);
        },
      ),
    );
  }

  Widget tabBar() {
    return getPaddingWidget(
      EdgeInsets.symmetric(horizontal: horSpace),
      Container(
        height: FetchPixels.getPixelHeight(56),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: containerShadow,
                  blurRadius: 33,
                  offset: const Offset(0, 7))
            ],
            borderRadius:
            BorderRadius.circular(FetchPixels.getPixelHeight(12))),
        child: TabBar(
          indicatorColor: Colors.white,
          onTap: (index) {
            _controller.animateToPage(
              index,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
            setState(() {
              position = index;
              if (position == 0) {
              } else if (position == 1) {
              } else {
              }
            });
          },
          tabs: [
            Tab(
              child: Container(
                decoration: position == 0
                    ? BoxDecoration(
                    color: slotbg,
                    borderRadius: BorderRadius.circular(
                        FetchPixels.getPixelHeight(12)))
                    : null,
                height: FetchPixels.getPixelHeight(40),
                width: FetchPixels.getPixelHeight(108),
                alignment: Alignment.center,
                child: getCustomFont(
                    "Unpaid", 18, position == 0 ? buttonColor : subtext, 1,
                    fontWeight: FontWeight.bold, fontFamily: 'Lato'),
              ),
            ),
            Tab(
              child: Container(
                decoration: position == 1
                    ? BoxDecoration(
                    color: slotbg,
                    borderRadius: BorderRadius.circular(
                        FetchPixels.getPixelHeight(12)))
                    : null,
                height: FetchPixels.getPixelHeight(40),
                width: FetchPixels.getPixelHeight(108),
                alignment: Alignment.center,
                child: getCustomFont(
                    "Paid", 18, position == 1 ? buttonColor : subtext, 1,
                    fontWeight: FontWeight.bold, fontFamily: 'Lato'),
              ),
            ),
            Tab(
              child: Container(
                decoration: position == 2
                    ? BoxDecoration(
                    color: slotbg,
                    borderRadius: BorderRadius.circular(
                        FetchPixels.getPixelHeight(12)))
                    : null,
                height: FetchPixels.getPixelHeight(40),
                width: FetchPixels.getPixelHeight(108),
                alignment: Alignment.center,
                child: getCustomFont(
                    "History", 18, position == 2 ? buttonColor : subtext, 1,
                    fontWeight: FontWeight.bold,fontFamily: 'Lato'),
              ),
            )
          ],
          controller: tabController,
        ),
      ),
    );
  }
}
