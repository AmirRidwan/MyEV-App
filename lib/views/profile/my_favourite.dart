import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../base/color_data.dart';
import '../../base/resizer/fetch_pixels.dart';
import '../../base/widget_utils.dart';
import '../../models/model_nearbylist.dart';
import '../../utils.dart';
import '../nearby/nearby_detail.dart';

class Favourite extends StatefulWidget {
  const Favourite({Key? key}) : super(key: key);

  @override
  State<Favourite> createState() => _FavouriteState();
}

class _FavouriteState extends State<Favourite>
    with SingleTickerProviderStateMixin {
  void finish() {
    Navigator.of(context).pop();
  }

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

  var horSpace = FetchPixels.getPixelHeight(20);

  late AnimationController controller;
  late Animation<double> scaleAnimation;

  List<ModelNearByList> favouriteLists =
      []; // List to store favorite charging stations
  List<String> favoriteStationIds =
      []; // List to store favorite station document IDs

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
    _fetchUserLocation();
    _fetchFavoriteStations(); // Fetch favorite charging stations from the database
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

  // Function to fetch favorite charging stations for the current user
  void _fetchFavoriteStations() async {
    try {
      String userId = getCurrentUserId();
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      List<String> favoriteStationIds =
          snapshot.docs.map((doc) => doc.id).toList();

      // Fetch the charging station details using the favorite station IDs
      List<ModelNearByList> favoriteStations =
          await _fetchChargingStationData(favoriteStationIds);

      setState(() {
        favouriteLists = favoriteStations;
      });
    } catch (e) {
      print('Error fetching favorite stations: $e');
    }
  }

  Map<String, dynamic>? stationData;

  // Function to fetch charging station data based on station IDs
  Future<List<ModelNearByList>> _fetchChargingStationData(
      List<String> stationIds) async {
    List<ModelNearByList> stations = [];

    for (String stationId in stationIds) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('charging_stations')
          .doc(stationId)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic>? stationData =
            snapshot.data() as Map<String, dynamic>?;
        if (stationData != null) {
          ModelNearByList station = ModelNearByList(
            stationData['stationId'] ?? "",
            stationData['name'] ?? "",
            stationData['address'] ?? "",
            stationData['connection'] ?? "",
            stationData['speed'] ?? "",
            stationData['price'] ?? "",
            stationData['location'] ?? "",
          );

          stations.add(station);
        }
      }
    }

    return stations;
  }

  // Method to unfavorite all stations for the current user
  void _unfavoriteAllStations() async {
    try {
      String userId = getCurrentUserId();
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Delete all favorite station documents in a batch write
      for (String stationId in favoriteStationIds) {
        // Remove the favorite from the user's favorites collection
        batch.delete(
          FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('favorites')
              .doc(stationId),
        );
      }

      await batch.commit();

      // Clear the list of favorite stations and favorite station IDs
      setState(() {
        favouriteLists.clear();
        favoriteStationIds.clear();
      });

      // Unfavorite each charging station
      for (String stationId in favoriteStationIds) {
        await FirebaseFirestore.instance
            .collection('charging_stations')
            .doc(stationId)
            .update({
          'favorites': FieldValue.arrayRemove([userId]),
        });
      }

      // Close the dialog after successful deletion
      Get.back();
    } catch (e) {
      print('Error unfavoriting stations: $e');
    }
  }

  Future<void> _handleRefresh() async {
    try {
      // Fetch the favorite charging stations from the database
      String userId = getCurrentUserId();
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      // Update the list of favorite station IDs
      favoriteStationIds = snapshot.docs.map((doc) => doc.id).toList();

      // Fetch the charging station details using the updated favorite station IDs
      List<ModelNearByList> favoriteStations =
          await _fetchChargingStationData(favoriteStationIds);

      // Update both the list of favorite stations and favorite station IDs
      setState(() {
        favouriteLists = favoriteStations;
      });
    } catch (e) {
      print('Error refreshing favorite stations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    FetchPixels(context);
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Color(0xff2d366f)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            "My Favourite",
            style: SafeGoogleFont(
              'Lato',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xff2d366f),
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Color(0xff9dd1ea),
        ),
        body: SafeArea(
          child: Column(
            children: [
              getVerSpace(FetchPixels.getPixelHeight(30)),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: favouriteLists.isEmpty
                      ? Center(
                          child: Text(
                            'No favorite added',
                            style: SafeGoogleFont(
                              'Lato',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: horSpace),
                          itemCount: favouriteLists.length,
                          primary: true,
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            ModelNearByList modelNearBy = favouriteLists[index];
                            ModelNearByList modelNearByList =
                                favouriteLists[index];

                            // Calculate the distance only if the user's location is available and the station has a valid location
                            String distance = userLocation != null &&
                                    modelNearByList.location != null
                                ? _calculateDistance(
                                    userLocation!.latitude,
                                    userLocation!.longitude,
                                    modelNearByList.location!.latitude,
                                    modelNearByList.location!.longitude,
                                  ).toStringAsFixed(
                                    2) // Displaying distance with 2 decimal places
                                : 'N/A';

                            return Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      bottom: FetchPixels.getPixelHeight(10)),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          FetchPixels.getPixelHeight(12)),
                                      boxShadow: [
                                        BoxShadow(
                                            color: shadowColor,
                                            offset: const Offset(0, 7),
                                            blurRadius: 33)
                                      ]),
                                  child: getPaddingWidget(
                                    EdgeInsets.symmetric(
                                        horizontal:
                                            FetchPixels.getPixelHeight(16)),
                                    Column(
                                      children: [
                                        getVerSpace(
                                            FetchPixels.getPixelHeight(16)),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            getHorSpace(
                                                FetchPixels.getPixelHeight(10)),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  getMultilineCustomFont(
                                                    modelNearBy.name ?? '',
                                                    18,
                                                    Colors.black,
                                                    txtHeight: FetchPixels
                                                        .getPixelHeight(1.5),
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily: "Lato",
                                                  ),
                                                  getVerSpace(FetchPixels
                                                      .getPixelHeight(9)),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      getSvgImage(
                                                          "location.svg",
                                                          width: FetchPixels
                                                              .getPixelHeight(
                                                                  19),
                                                          height: FetchPixels
                                                              .getPixelHeight(
                                                                  19)),
                                                      getHorSpace(FetchPixels
                                                          .getPixelHeight(4)),
                                                      Expanded(
                                                        child:
                                                            getMultilineCustomFont(
                                                          modelNearBy.address ??
                                                              '',
                                                          16,
                                                          Colors.black,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          txtHeight: FetchPixels
                                                              .getPixelHeight(
                                                                  1.5),
                                                          fontFamily: "Lato",
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  getVerSpace(FetchPixels
                                                      .getPixelHeight(9)),
                                                  Row(
                                                    children: [
                                                      getSvgImage("person.svg",
                                                          width: FetchPixels
                                                              .getPixelHeight(
                                                                  19),
                                                          height: FetchPixels
                                                              .getPixelHeight(
                                                                  19)),
                                                      getHorSpace(FetchPixels
                                                          .getPixelHeight(4)),
                                                      getCustomFont(
                                                        '${userLocation != null ? '$distance km' : 'N/A'}',
                                                        // Display the distance in kilometers with 2 decimal places
                                                        16,
                                                        Colors.black,
                                                        1,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontFamily: "Lato",
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        getVerSpace(
                                            FetchPixels.getPixelHeight(25)),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                        ),
                                        getVerSpace(
                                            FetchPixels.getPixelHeight(15)),
                                        getButton(
                                          context,
                                          Colors.white,
                                          "View Detail",
                                          buttonColor,
                                          () {
                                            // Check if the stationId is not null before navigating to the details page
                                            if (modelNearBy.stationId != null) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChargingStationDetailsPage(
                                                          stationId: modelNearBy
                                                              .stationId!),
                                                ),
                                              );
                                            } else {
                                              // Handle the case when the stationId is null (optional)
                                              // For example, show a toast or a message to inform the user that the station details are not available.
                                              print(
                                                  'Station ID is null. Details not available.');
                                            }
                                          },
                                          14,
                                          weight: FontWeight.w700,
                                          borderColor: buttonColor,
                                          isBorder: true,
                                          borderWidth: 1,
                                          borderRadius: BorderRadius.circular(
                                              FetchPixels.getPixelHeight(12)),
                                          buttonHeight:
                                              FetchPixels.getPixelHeight(44),
                                        ),
                                        getVerSpace(
                                            FetchPixels.getPixelHeight(20)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        finish();
        return false;
      },
    );
  }
}
