import 'dart:math';

import 'package:evfinder/base/widget_utils.dart';
import 'package:evfinder/views/nearby/photos.dart';
import 'package:evfinder/views/nearby/reviews.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../base/color_data.dart';
import '../../base/constant.dart';
import '../../base/resizer/fetch_pixels.dart';
import '../booking/BookingSlot.dart';
import 'full_view.dart';

class ChargingStationDetailsPage extends StatefulWidget {
  final String stationId; // ID of the charging station to display

  ChargingStationDetailsPage({required this.stationId});

  @override
  _ChargingStationDetailsPageState createState() =>
      _ChargingStationDetailsPageState();
}

class _ChargingStationDetailsPageState extends State<ChargingStationDetailsPage>
    with SingleTickerProviderStateMixin {
  bool? availability;
  String openText = '';
  bool isFavorite = false;
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  Position? userLocation;

  // Helper function to calculate the distance.
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const int earthRadius = 6371; // Radius of the earth in km
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  // Helper function to convert degrees to radians.
  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  List<num> ratings = [];

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    setState(() {});
    super.initState();
    _fetchChargingStationData();
    addCustomIcon();
    _checkFavoriteStatus();
    _fetchUserLocation();
  }

  // Helper function to fetch user's location.
  Future<void> _fetchUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        userLocation = position;
      });
    } catch (e) {
      print("Error fetching user's location: $e");
    }
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

  void _toggleFavorite() async {
    try {
      // Get the current user's ID (you may implement your own method to get the user ID)
      String userId =
          getCurrentUserId(); // Replace this with your own method to get the user ID

      // Check if the user has already added the station to favorites
      DocumentSnapshot favoriteSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(widget.stationId)
          .get();

      // If the station is already a favorite, remove it
      if (favoriteSnapshot.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .doc(widget.stationId)
            .delete();
        setState(() {
          isFavorite = false;
        });
      } else {
        // If the station is not a favorite, add it
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .doc(widget.stationId)
            .set({});
        setState(() {
          isFavorite = true;
        });
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  Map<String, dynamic>? chargingStationData;

  Future<void> _fetchChargingStationData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('charging_stations')
          .doc(widget.stationId)
          .get();

      if (snapshot.exists) {
        setState(() {
          chargingStationData = snapshot.data() as Map<String, dynamic>;
          availability = chargingStationData?['availability'] as bool?;
          openText = availability == true ? 'Open' : 'Closed';
        });

        // Fetch reviews and calculate average rating
        QuerySnapshot reviewsSnapshot = await FirebaseFirestore.instance
            .collection('reviews')
            .where('stationId', isEqualTo: widget.stationId)
            .get();

        if (reviewsSnapshot.docs.isNotEmpty) {
          double totalRating = 0;
          for (var reviewDoc in reviewsSnapshot.docs) {
            totalRating += reviewDoc['rating'];
          }
          double averageRating = totalRating / reviewsSnapshot.docs.length;
          setState(() {
            ratings = [averageRating]; // Store the calculated average rating
          });
        } else {
          setState(() {
            ratings = []; // No reviews, so set ratings to an empty list
          });
        }
      }
    } catch (e) {
      print('Error fetching charging station data: $e');
    }
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      String userId = getCurrentUserId();

      DocumentSnapshot favoriteSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(widget.stationId)
          .get();

      setState(() {
        // Update the isFavorite state based on whether the station is a favorite or not
        isFavorite = favoriteSnapshot.exists;
      });
    } catch (e) {
      print('Error checking favorite status: $e');
    }
  }

  void finish() {
    Constant.backToPrev(context);
  }

  void addCustomIcon() async {
    BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/images/marker.png",
    ).then(
      (icon) {
        setState(() {
          markerIcon = icon;
        });
      },
    );
  }

  final PageController _controller = PageController(
    initialPage: 0,
  );

  late TabController tabController;
  var position = 0;

  var horSpace = FetchPixels.getPixelHeight(20);

  @override
  Widget build(BuildContext context) {

    print("Ratings list: $ratings");
    // Calculate the distance only if the user's location is available
    String distance = userLocation != null
        ? _calculateDistance(
            userLocation!.latitude,
            userLocation!.longitude,
            chargingStationData?['location']?.latitude ?? 0.0,
            chargingStationData?['location']?.longitude ?? 0.0,
          ).toStringAsFixed(2) // Displaying distance with 2 decimal places
        : 'N/A';

    return WillPopScope(
        child: Scaffold(
          bottomNavigationBar: Container(
            padding: EdgeInsets.only(
                left: FetchPixels.getPixelHeight(20),
                right: FetchPixels.getPixelHeight(20),
                bottom: FetchPixels.getPixelHeight(30)),
            child: Row(
              children: [
                Expanded(
                    child: getButton(
                        context, buttonColor, "Book Slot", Colors.white, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BookingPage(stationId: widget.stationId),
                    ),
                  );
                }, 16,
                        weight: FontWeight.w700,
                        buttonHeight: FetchPixels.getPixelHeight(44),
                        borderRadius: BorderRadius.circular(
                            FetchPixels.getPixelHeight(12)))),
                getHorSpace(FetchPixels.getPixelHeight(20)),
                Expanded(
                  child: getButton(
                    context,
                    isFavorite ? slotbg : Colors.white,
                    isFavorite ? "Added to Favourite" : "Add to Favourite",
                    isFavorite ? buttonColor : buttonColor,
                    () {
                      // Call the _toggleFavorite function when the button is pressed
                      _toggleFavorite();
                    },
                    16,
                    weight: FontWeight.w700,
                    buttonHeight: FetchPixels.getPixelHeight(44),
                    borderRadius:
                        BorderRadius.circular(FetchPixels.getPixelHeight(12)),
                    isBorder: true,
                    borderColor: buttonColor,
                    borderWidth: FetchPixels.getPixelHeight(1),
                  ),
                )
              ],
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                SizedBox(
                  height: FetchPixels.height,
                  child: Column(
                    children: [
                      Container(
                        height: FetchPixels.getPixelHeight(219),
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('charging_stations')
                              .doc(widget.stationId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }

                            final chargingStationData =
                                snapshot.data!.data() as Map<String, dynamic>?;
                            final GeoPoint? location =
                                chargingStationData?['location'] as GeoPoint?;

                            if (location == null) {
                              return Center(child: Text('Location not found.'));
                            }

                            final LatLng latLng =
                                LatLng(location.latitude, location.longitude);

                            return GoogleMap(
                              zoomControlsEnabled: false,
                              zoomGesturesEnabled: false,
                              scrollGesturesEnabled: false,
                              rotateGesturesEnabled: false,
                              tiltGesturesEnabled: false,
                              initialCameraPosition: CameraPosition(
                                target: latLng,
                                zoom: 15,
                              ),
                              markers: Set<Marker>.from([
                                Marker(
                                  markerId: MarkerId('charging_stations'),
                                  position: latLng,
                                  icon: markerIcon,
                                ),
                              ]),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: Column(
                    children: [
                      getVerSpace(FetchPixels.getPixelHeight(16)),
                      getPaddingWidget(
                        EdgeInsets.symmetric(
                            horizontal: FetchPixels.getPixelHeight(20)),
                        Row(
                          children: [
                            GestureDetector(
                              child: getSvgImage("arrow_left.svg",
                                  color: Colors.black),
                              onTap: () {
                                finish();
                              },
                            ),
                            // getHorSpace(FetchPixels.getPixelHeight(14)),
                            // getCustomFont("Detail", 20, Colors.white, 1,
                            //     fontWeight: FontWeight.w700)
                          ],
                        ),
                      ),
                      getVerSpace(FetchPixels.getPixelHeight(140)),
                      Expanded(
                          child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                              width: FetchPixels.width,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(
                                          FetchPixels.getPixelHeight(30)))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  getVerSpace(FetchPixels.getPixelHeight(23)),
                                  getPaddingWidget(
                                    EdgeInsets.symmetric(horizontal: horSpace),
                                    SizedBox(
                                      width: FetchPixels.getPixelHeight(237),
                                      child: getMultilineCustomFont(
                                          chargingStationData?['name'] ??
                                              'Loading..',
                                          20,
                                          Colors.black,
                                          fontWeight: FontWeight.w700,
                                          txtHeight:
                                              FetchPixels.getPixelHeight(1.3)),
                                    ),
                                  ),
                                  getVerSpace(FetchPixels.getPixelHeight(15)),
                                  getPaddingWidget(
                                    EdgeInsets.symmetric(horizontal: horSpace),
                                    Row(
                                      children: [
                                        getCustomFont(
                                          "${ratings.isNotEmpty ? ratings[0].toStringAsFixed(1) : 'N/A'}",
                                          14,
                                          Colors.black,
                                          1,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        getHorSpace(FetchPixels.getPixelHeight(2)),
                                        RatingBar(
                                          initialRating: ratings.isNotEmpty ? ratings[0].toDouble() : 0.0, // Convert num to double
                                          direction: Axis.horizontal,
                                          allowHalfRating: false,
                                          itemSize: FetchPixels.getPixelHeight(16),
                                          itemCount: 5,
                                          ratingWidget: RatingWidget(
                                            full: getSvgImage("like.svg"),
                                            half: getSvgImage("like.svg"),
                                            empty: getSvgImage("like_unselected.svg"),
                                          ),
                                          ignoreGestures: true,
                                          itemPadding: EdgeInsets.symmetric(
                                            horizontal: FetchPixels.getPixelHeight(2),
                                          ),
                                          onRatingUpdate: (rating) {},
                                        ),
                                        getHorSpace(FetchPixels.getPixelHeight(8)),
                                        getSvgImage(
                                          "person.svg",
                                          height: FetchPixels.getPixelHeight(20),
                                          width: FetchPixels.getPixelHeight(20),
                                        ),
                                        getHorSpace(FetchPixels.getPixelHeight(2)),
                                        getCustomFont(
                                          '${userLocation != null ? '$distance km' : 'N/A'}',
                                          14,
                                          Colors.black,
                                          1,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ],
                                    ),
                                  ),
                                  getVerSpace(FetchPixels.getPixelHeight(16)),
                                  getPaddingWidget(
                                    EdgeInsets.symmetric(horizontal: horSpace),
                                    getCustomFont(
                                        'OPEN ${chargingStationData?['operationHour'] ?? 'Loading..'}',
                                        16,
                                        Colors.black,
                                        1,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  getVerSpace(FetchPixels.getPixelHeight(16)),
                                  tabBar(),
                                  getVerSpace(FetchPixels.getPixelHeight(14)),
                                  Expanded(
                                    flex: 1,
                                    child: buildPageView(),
                                  ),
                                  getVerSpace(FetchPixels.getPixelHeight(20)),
                                ],
                              )),
                          Positioned(
                              child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: buttonColor,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(
                                        FetchPixels.getPixelHeight(24)),
                                    bottomLeft: Radius.circular(
                                        FetchPixels.getPixelHeight(24)))),
                            height: FetchPixels.getPixelHeight(39),
                            width: FetchPixels.getPixelHeight(104),
                            child: getCustomFont(
                                openText,
                                // Display the "OPEN" or "CLOSED" text based on availability
                                15,
                                Colors.white,
                                1,
                                fontWeight: FontWeight.w700),
                          ))
                        ],
                      ))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        onWillPop: () async {
          finish();
          return false;
        });
  }

  PageView buildPageView() {
    return PageView(
      physics: const BouncingScrollPhysics(),
      controller: _controller,
      scrollDirection: Axis.horizontal,
      children: [
        if (chargingStationData != null)
          FullView(stationId: chargingStationData!['stationId']),
        if (chargingStationData != null)
          Reviews(stationId: chargingStationData!['stationId']),
        if (chargingStationData != null)
        Photos(stationId: chargingStationData!['stationId']),
      ],
      onPageChanged: (value) {
        setState(() {
          position = value;
        });
        tabController.animateTo(value);
      },
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
          indicatorColor: Colors.transparent,
          onTap: (index) {
            _controller.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            setState(() {
              position = index;
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
                    "Full view", 16, position == 0 ? buttonColor : subtext, 1,
                    fontWeight: FontWeight.w700),
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
                    "Reviews", 16, position == 1 ? buttonColor : subtext, 1,
                    fontWeight: FontWeight.w700),
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
                    "Photos", 16, position == 2 ? buttonColor : subtext, 1,
                    fontWeight: FontWeight.w700),
              ),
            )
          ],
          controller: tabController,
        ),
      ),
    );
  }
}
