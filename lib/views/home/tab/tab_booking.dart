import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../../base/color_data.dart';
import '../../../base/constant.dart';
import '../../../base/resizer/fetch_pixels.dart';
import '../../../base/widget_utils.dart';
import '../../../utils.dart';
import '../../booking/bookingDetail.dart';
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
  CollectionReference stationsCollection =
  FirebaseFirestore.instance.collection('charging_stations');
  CollectionReference bookingsCollection =
  FirebaseFirestore.instance.collection('bookings');
  bool isTyping = false;
  var horSpace = FetchPixels.getPixelHeight(20);
  TextEditingController searchController = TextEditingController();
  var select = 0;

  onItemChanged() {
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horSpace),
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(14.0),
                    color: Colors.white,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child:
                            TypeAheadField(
                              textFieldConfiguration: TextFieldConfiguration(
                                onChanged: (text) {
                                  setState(() {
                                    isTyping = text.isNotEmpty;
                                  });
                                },
                                controller: searchController,
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                  border: InputBorder.none,
                                ),
                              ),
                              suggestionsCallback: (pattern) async {
                                if (!isTyping || pattern.isEmpty) {
                                  return [];
                                }
                                // Get the current user's ID
                                String currentUserId = getCurrentUserId();

                                // Reference to the Firestore collections
                                CollectionReference bookingsCollection =
                                FirebaseFirestore.instance.collection('bookings');
                                CollectionReference stationsCollection =
                                FirebaseFirestore.instance.collection('charging_stations');

                                // Query the Firestore collection based on the search pattern and user's ID
                                QuerySnapshot querySnapshot = await bookingsCollection
                                    .where('userId', isEqualTo: currentUserId)
                                    .get();

                                // Extract the data from the query snapshot
                                List<String> bookingIds = querySnapshot.docs.map((doc) => doc.id).toList();

                                return bookingIds;
                              },
                              itemBuilder: (context, suggestion) {
                                // Fetch the booking document using the suggestion (bookingId)
                                return FutureBuilder<DocumentSnapshot>(
                                  future: bookingsCollection.doc(suggestion).get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return ListTile(title: Text('Loading...'));
                                    }
                                    if (snapshot.hasError) {
                                      return ListTile(title: Text('Error loading suggestion: ${snapshot.error}'));
                                    }
                                    if (!snapshot.hasData || !snapshot.data!.exists) {
                                      return ListTile(title: Text('Invalid suggestion'));
                                    }

                                    // Get booking data
                                    Map<String, dynamic>? bookingData = snapshot.data!.data() as Map<String, dynamic>?;

                                    if (bookingData == null || bookingData.isEmpty) {
                                      return ListTile(title: Text('No booking data available'));
                                    }

                                    // Extract stationId from booking data
                                    String stationId = bookingData['stationId'];

                                    // Fetch the charging station document using stationId
                                    return FutureBuilder<DocumentSnapshot>(
                                      future: stationsCollection.doc(stationId).get(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return ListTile(title: Text('Loading station...'));
                                        }
                                        if (snapshot.hasError) {
                                          return ListTile(title: Text('Error loading station: ${snapshot.error}'));
                                        }
                                        if (!snapshot.hasData || !snapshot.data!.exists) {
                                          return ListTile(title: Text('Invalid station'));
                                        }

                                        // Get charging station data
                                        Map<String, dynamic>? stationData = snapshot.data!.data() as Map<String, dynamic>?;

                                        if (stationData == null || stationData.isEmpty) {
                                          return ListTile(title: Text('No station data available'));
                                        }

                                        // Extract station name and address
                                        String stationName = stationData['name'];
                                        String stationAddress = stationData['address'];

                                        // Build the suggestion item UI
                                        return ListTile(
                                          title: Text(stationName),
                                          subtitle: Text(stationAddress),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              onSuggestionSelected: (suggestion) async {
                                // Navigate to BookingDetailsPage and pass the selected suggestion
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookingDetailPage(bookingId: suggestion),
                                  ),
                                );
                              },
                            )
                          ),
                        ],
                      ),
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
