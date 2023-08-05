import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evfinder/views/features/list_of_charging_stations.dart';
import 'package:evfinder/views/features/station_roadmap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../../models/charging_stations.dart';
import '../../../utils.dart';
import '../../nearby/nearby_detail.dart';
import '../../profile/my_profile.dart';

class TabHome extends StatefulWidget {
  @override
  _TabHomeState createState() => _TabHomeState();
}

class _TabHomeState extends State<TabHome> {
  String? _cityName = 'Loading...';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? currentUserId;
  List<ChargingStation> _chargingStationList = [];
  String profileImageUrl = '';
  Position? userLocation;
  String defaultUrl =
      'https://firebasestorage.googleapis.com/v0/b/evfinder-ad6f0.appspot.com/o/default_avatar.png?alt=media&token=aabd68a9-29ce-4f99-9c7b-7b47fae2070a';

  TextEditingController _searchController = TextEditingController();
  List<ChargingStation> _searchResults = [];

  Future<List<ChargingStation>> _getSearchResults(String query) async {
    if (query.isEmpty) {
      return []; // Return an empty list if the query is empty
    }

    // Filter charging stations based on the query
    List<ChargingStation> results = _chargingStationList
        .where((station) =>
            station.name.toLowerCase().contains(query.toLowerCase()) ||
            station.address.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return results;
  }

  void _onSearchItemSelected(ChargingStation chargingStation) {
    // Navigate to charging station detail page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        return ChargingStationDetailsPage(stationId: chargingStation.stationId);
      }),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    getCurrentUser();
    _fetchChargingStationData();
    fetchProfileImageUrl(currentUserId!);
  }

  Future<void> getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    }
  }

  Future<void> fetchProfileImageUrl(String userId) async {
    try {
      // Retrieve document from Firestore
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      // Check if document exists
      if (doc.exists) {
        // Retrieve profile image URL field
        profileImageUrl =
            (doc.data() as Map<String, dynamic>)['profileImageUrl'] ?? '';
      } else {
        print('User document does not exist.');
      }
    } catch (e) {
      print('Error fetching profile image URL: $e');
    }

    if (profileImageUrl.isEmpty) {
      profileImageUrl = defaultUrl; // Set default profile image URL
    }
  }

  // Inside the _getCurrentLocation() function
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      userLocation = position;
    });

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    Placemark placemark = placemarks.first;
    setState(() {
      _cityName = placemark.locality;
    });

    // Fetch charging station data after getting the user's location
    _fetchChargingStationData();
  }

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

  Future<void> _fetchChargingStationData() async {
    QuerySnapshot chargingStationSnapshot =
        await _firestore.collection('charging_stations').get();
    List<ChargingStation> chargingStations = chargingStationSnapshot.docs
        .map((doc) => ChargingStation.fromSnapshot(doc))
        .toList();

    // Sort the charging stations based on distance to userLocation
    if (userLocation != null) {
      chargingStations.sort((a, b) {
        double distanceToA = _calculateDistance(
          userLocation!.latitude,
          userLocation!.longitude,
          a.latitude,
          a.longitude,
        );

        double distanceToB = _calculateDistance(
          userLocation!.latitude,
          userLocation!.longitude,
          b.latitude,
          b.longitude,
        );

        return distanceToA.compareTo(distanceToB);
      });
    }

    setState(() {
      _chargingStationList = chargingStations;
    });
  }

  Widget _Features({required String image, required String name}) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(10.0),
      color: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.grey, width: 2)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(image),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              name,
              style: SafeGoogleFont(
                'Lato',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            )
          ],
        ),
      ),
    );
  }

  // Method to handle the refresh action
  Future<void> _refreshData() async {
    await _getCurrentLocation();
    await getCurrentUser();
    await _fetchChargingStationData();
    await fetchProfileImageUrl(currentUserId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      color: Color(0xffFFC95B),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.blue,
                                        size: 18,
                                      ),
                                      Text(
                                        '${_cityName ?? 'Loading...'}'.toUpperCase(),
                                        style: SafeGoogleFont(
                                          'Lato',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () {
                                      _getCurrentLocation();
                                    },
                                    child: Text(
                                      'Change Location',
                                      style: SafeGoogleFont(
                                        'Lato',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 10, top: 5),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) {
                                      return MyProfile();
                                    }),
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 32,
                                  backgroundImage: profileImageUrl != null
                                      ? NetworkImage(profileImageUrl)
                                      : NetworkImage(defaultUrl),
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 9),
                        Text(
                          'Choose EV Charger \nNearby you',
                          style: SafeGoogleFont(
                            'Lato',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 16),
                        Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(24),
                          color: Colors.white,
                          child: TypeAheadFormField(
                            textFieldConfiguration: TextFieldConfiguration(
                              style: SafeGoogleFont(
                                'Lato',
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search',
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16.0),
                                border: InputBorder.none,
                              ),
                            ),
                            suggestionsCallback: (pattern) async {
                              // Fetch search results based on the typed query
                              return await _getSearchResults(pattern);
                            },
                            itemBuilder:
                                (context, ChargingStation suggestion) {
                              return ListTile(
                                title: Text(suggestion.name),
                                subtitle: Text(suggestion.address),
                              );
                            },
                            onSuggestionSelected:
                                (ChargingStation suggestion) {
                              _searchController.text = suggestion.name;
                              _onSearchItemSelected(suggestion);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Nearby Charging Stations',
                            style: SafeGoogleFont(
                              'Lato',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return ListOfChargingStations();
                              }));
                            },
                            child: Text('See All'),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Container(
                          height: 212,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _chargingStationList.length,
                            itemBuilder: (BuildContext context, int index) {
                              ChargingStation chargingStation = _chargingStationList[index];
                              String distance = userLocation != null
                                  ? _calculateDistance(
                                userLocation!.latitude,
                                userLocation!.longitude,
                                chargingStation.latitude,
                                chargingStation.longitude,
                              ).toStringAsFixed(2)
                                  : 'N/A';

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) => ChargingStationDetailsPage(
                                        stationId: chargingStation.stationId,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 250, // Adjust the width as needed
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            chargingStation.name,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            chargingStation.address,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'Distance: ${userLocation != null ? '$distance km' : 'N/A'}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Features',
                        style: SafeGoogleFont(
                          'Lato',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10), // Add SizedBox to give some space between the Text and the Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return StationRoadmap();
                                  },
                                ));
                              },
                              child: AspectRatio(
                                aspectRatio: 1.3, // Set the desired aspect ratio here
                                child: _Features(
                                  image: 'assets/images/roadmap.png',
                                  name: 'Station Roadmap',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12), // Add spacing between the two items in the Row
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return ListOfChargingStations();
                                  },
                                ));
                              },
                              child: AspectRatio(
                                aspectRatio: 1.3, // Set the desired aspect ratio here
                                child: _Features(
                                  image: 'assets/images/chargingstation.png',
                                  name: 'List of Charging Station',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
