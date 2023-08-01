import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../base/color_data.dart';
import '../../../base/constant.dart';
import '../../../base/resizer/fetch_pixels.dart';
import '../../../base/widget_utils.dart';
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
    // Implement the item change logic here
  }

  final PageController _controller = PageController(
    initialPage: 0,
  );

  late TabController tabController;
  var position = 0;

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
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
      body: Column(
        children: [
          Material(
            elevation: 4,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            color: Color(0xffFFC95B),
            child: Column(
              children: [
                SizedBox(height: 20),
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(14.0),
                  color: Colors.white,
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
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 16.0),
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
                SizedBox(height: 10),
                tabBar(),
                SizedBox(height: 10),
              ],
            ),
          ),
          pageView(),
        ],
      ),
    );
  }

  Widget pageView() {
    return Expanded(
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
              // Handle page change for unpaidBooking
            } else if (position == 1) {
              // Handle page change for paidBooking
            } else {
              // Handle page change for historyBooking
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
      Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        child: Container(
          height: FetchPixels.getPixelHeight(56),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: containerShadow,
                blurRadius: 33,
                offset: const Offset(0, 7),
              ),
            ],
            borderRadius: BorderRadius.circular(16),
          ),
          child: TabBar(
            indicatorColor: Colors.transparent,
            onTap: (index) {
              _controller.animateToPage(
                index,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
              setState(() {
                position = index;
                if (position == 0) {
                  // Handle tab change for unpaidBooking
                } else if (position == 1) {
                  // Handle tab change for paidBooking
                } else {
                  // Handle tab change for historyBooking
                }
              });
            },
            tabs: [
              Tab(
                child: Container(
                  decoration: position == 0
                      ? BoxDecoration(
                          color: slotbg,
                          borderRadius: BorderRadius.circular(16),
                        )
                      : null,
                  height: FetchPixels.getPixelHeight(40),
                  width: FetchPixels.getPixelHeight(108),
                  alignment: Alignment.center,
                  child: getCustomFont(
                    "Unpaid",
                    18,
                    position == 0 ? buttonColor : subtext,
                    1,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lato',
                  ),
                ),
              ),
              Tab(
                child: Container(
                  decoration: position == 1
                      ? BoxDecoration(
                          color: slotbg,
                          borderRadius: BorderRadius.circular(16),
                        )
                      : null,
                  height: FetchPixels.getPixelHeight(40),
                  width: FetchPixels.getPixelHeight(108),
                  alignment: Alignment.center,
                  child: getCustomFont(
                    "Paid",
                    18,
                    position == 1 ? buttonColor : subtext,
                    1,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lato',
                  ),
                ),
              ),
              Tab(
                child: Container(
                  decoration: position == 2
                      ? BoxDecoration(
                          color: slotbg,
                          borderRadius: BorderRadius.circular(16),
                        )
                      : null,
                  height: FetchPixels.getPixelHeight(40),
                  width: FetchPixels.getPixelHeight(108),
                  alignment: Alignment.center,
                  child: getCustomFont(
                    "History",
                    18,
                    position == 2 ? buttonColor : subtext,
                    1,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lato',
                  ),
                ),
              )
            ],
            controller: tabController,
          ),
        ),
      ),
    );
  }
}
