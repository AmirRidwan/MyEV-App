import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evfinder/base/color_data.dart';
import 'package:evfinder/models/charging_stations.dart';
import 'package:evfinder/views/nearby/nearby_detail.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:geolocator/geolocator.dart';

import '../../utils.dart';

class ListOfChargingStations extends StatefulWidget {
  const ListOfChargingStations({Key? key}) : super(key: key);

  @override
  State<ListOfChargingStations> createState() =>
      _ListOfChargingStationsState();
}

class _ListOfChargingStationsState extends State<ListOfChargingStations> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ChargingStation> _chargingStationList = [];
  List<DocumentSnapshot> _chargingStations = [];

  final TextEditingController _searchController = TextEditingController();
  String _selectedChargerType = 'all';
  String _selectedChargingSpeed = 'all';
  String _selectedAvailability = 'all';
  String _sortBy = 'Nearest'; // Track the selected sorting option
  double desiredRange = 100; // Declare desiredRange as a member variable

  Position? userLocation; // Define the userLocation property to hold the latitude and longitude.

  // Helper function to calculate the distance.
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const int earthRadius = 6371; // Radius of the earth in km
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  // Helper function to convert degrees to radians.
  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Helper function to compare charging stations by city name
  int _compareByCity(ChargingStation a, ChargingStation b) {
    return a.address.compareTo(b.address);
  }

  // Helper function to filter charging stations by range
  List<ChargingStation> _filterByRange(double desiredRange) {
    // Check if userLocation is available
    if (userLocation == null) {
      // Return an empty list as user location is not available
      return [];
    }

    // Filter the charging stations based on the desired range
    return _chargingStationList
        .where((station) =>
    _calculateDistance(
        userLocation!.latitude, // Use the null-aware operator here.
        userLocation!.longitude, // Use the null-aware operator here.
        station.latitude,
        station.longitude) <=
        desiredRange)
        .toList();
  }


  @override
  void initState() {
    super.initState();
    _fetchChargingStationData();
    _fetchUserLocation(); // Fetch user's location in the initState.
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

  void _updateChargingStationList() {
    List<DocumentSnapshot> filteredStations = _chargingStations.where((station) {
      String chargerType = station['chargerType'].toString();
      String chargingSpeed = station['chargingSpeed'].toString();
      bool availability = station['availability'];

      bool matchesType =
          _selectedChargerType == 'all' || chargerType == _selectedChargerType;
      bool matchesSpeed =
          _selectedChargingSpeed == 'all' || chargingSpeed == _selectedChargingSpeed;
      bool matchesAvailability =
          _selectedAvailability == 'all' ||
              availability == (_selectedAvailability == 'Available');

      return matchesType && matchesSpeed && matchesAvailability;
    }).toList();

    setState(() {
      _chargingStationList =
          filteredStations.map((doc) => ChargingStation.fromSnapshot(doc)).toList();
    });
  }

  void _searchEVChargingLocation() {
    String searchTerm = _searchController.text.toLowerCase().trim();

    List<DocumentSnapshot> filteredStations = _chargingStations.where((station) {
      String address = station['address'].toString().toLowerCase();
      return address.contains(searchTerm);
    }).toList();

    setState(() {
      _chargingStationList =
          filteredStations.map((doc) => ChargingStation.fromSnapshot(doc)).toList();
    });
  }

  Future<void> _fetchChargingStationData() async {
    QuerySnapshot chargingStationSnapshot =
    await _firestore.collection('charging_stations').get();
    List<ChargingStation> chargingStations = chargingStationSnapshot.docs
        .map((doc) => ChargingStation.fromSnapshot(doc))
        .toList();

    setState(() {
      _chargingStationList = chargingStations;
      _chargingStations = chargingStationSnapshot.docs;
    });
  }

  Future<void> _handleRefresh() async {
    // Implement the code to fetch new data or update the existing data
    // e.g., you can call _fetchChargingStationData() to fetch new data
    await _fetchChargingStationData();

    // Call _updateChargingStationList to apply the current filters/sorting
    _updateChargingStationList();
  }


  void _showFilterOptions(BuildContext context) async {
    final result = await showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 360,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Filter Options',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedChargerType,
                    decoration: InputDecoration(
                      labelText: 'Charger Type',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedChargerType = value ?? 'all';
                      });
                    },
                    items: [
                      DropdownMenuItem<String>(
                        value: 'all',
                        child: Text('All Charger Types'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Type 1',
                        child: Text('Type 1'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Type 2',
                        child: Text('Type 2'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'CHAdeMO',
                        child: Text('CHAdeMO'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Supercharger',
                        child: Text('Supercharger'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedChargingSpeed,
                    decoration: InputDecoration(
                      labelText: 'Charging Speed',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedChargingSpeed = value ?? 'all';
                      });
                    },
                    items: [
                      DropdownMenuItem<String>(
                        value: 'all',
                        child: Text('All Charging Speeds'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Slow',
                        child: Text('Slow'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Medium',
                        child: Text('Medium'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Fast',
                        child: Text('Fast'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedAvailability,
                    decoration: InputDecoration(
                      labelText: 'Availability',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedAvailability = value ?? 'all';
                      });
                    },
                    items: [
                      DropdownMenuItem<String>(
                        value: 'all',
                        child: Text('All Availability'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Available',
                        child: Text('Available'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Unavailable',
                        child: Text('Unavailable'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, 'apply');
                        },
                        child: Text('Apply Filter'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          _resetFilterOptions();
                        },
                        child: Text('Reset'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result == 'apply') {
      _updateChargingStationList();
    }
  }

  void _resetFilterOptions() {
    setState(() {
      _selectedChargerType = 'all';
      _selectedChargingSpeed = 'all';
      _selectedAvailability = 'all';
    });
  }

  void _showSortOptions(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(25),topLeft: Radius.circular(25)),
      ),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 320,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Sort by',
                    style: SafeGoogleFont(
                      'Lato',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    )
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    title: Text(
                        'Nearest',
                      style: SafeGoogleFont(
                        'Lato',
                        fontSize: 18,
                        color: Colors.black,
                      )
                    ),
                    leading: Radio<String>(
                      value: 'Nearest',
                      groupValue: _sortBy,
                      onChanged: (String? value) {
                        setState(() {
                          _sortBy = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(
                        'City',
                      style: SafeGoogleFont(
                        'Lato',
                        fontSize: 18,
                        color: Colors.black,
                      )
                    ),
                    leading: Radio<String>(
                      value: 'City',
                      groupValue: _sortBy,
                      onChanged: (String? value) {
                        setState(() {
                          _sortBy = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(
                        'Range',
                      style: SafeGoogleFont(
                        'Lato',
                        fontSize: 18,
                        color: Colors.black,
                      )
                    ),
                    leading: Radio<String>(
                      value: 'Range',
                      groupValue: _sortBy,
                      onChanged: (String? value) {
                        setState(() {
                          _sortBy = value!;
                        });
                      },
                    ),
                    // Show the slider under the "Range" option
                    trailing: _sortBy == 'Range'
                        ? Container(
                      width: 200,
                      child: Slider(
                        value: desiredRange,
                        onChanged: (double value) {
                          setState(() {
                            desiredRange = value;
                          });
                        },
                        min: 1,
                        max: 100,
                        divisions: 1000,
                        label: '${desiredRange.toStringAsFixed(0)} km',
                      ),
                    )
                        : null,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _sortBy);
                    },
                    child: Text(
                        'Apply',
                      style: SafeGoogleFont(
                        'Lato',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _sortBy = result;

        // Perform the sorting based on the selected option
        if (_sortBy == 'Nearest') {
          // Sort the charging stations based on distance to userLocation
          _chargingStationList.sort((a, b) {
            // Check if userLocation is not null before accessing its properties.
            if (userLocation == null) {
              // Handle the case where userLocation is null (location not available yet).
              // Return a default value, such as sorting both charging stations as equal.
              return 0;
            }

            double distanceToA = _calculateDistance(
              userLocation!.latitude, // Use the null-aware operator here.
              userLocation!.longitude, // Use the null-aware operator here.
              a.latitude,
              a.longitude,
            );

            double distanceToB = _calculateDistance(
              userLocation!.latitude, // Use the null-aware operator here.
              userLocation!.longitude, // Use the null-aware operator here.
              b.latitude,
              b.longitude,
            );

            // Compare the distances and return the result
            return distanceToA.compareTo(distanceToB);
          });
        }
        else if (_sortBy == 'City') {
          // Sort the charging stations based on city name, implement your logic here
          _chargingStationList.sort(_compareByCity);
        } else if (_sortBy == 'Range') {
          // Sort the charging stations based on range, implement your logic here
          _chargingStationList = _filterByRange(desiredRange);
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xff2d366f)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          "List of Charging Stations",
          style: SafeGoogleFont(
            'Lato',
            fontSize:  24,
            fontWeight:  FontWeight.bold,
            color:  Color(0xff2d366f),
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Color(0xff9dd1ea),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              children: [
                Container(
                  height: 80,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    color: Color(0xff9dd1ea),
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search by address',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.search),
                              onPressed: _searchEVChargingLocation,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 5),
                    child: RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: _chargingStationList.length,
                        itemBuilder: (BuildContext context, int index) {
                          ChargingStation chargingStation = _chargingStationList[index];

                          // Calculate the distance only if the user's location is available
                          String distance = userLocation != null
                              ? _calculateDistance(
                            userLocation!.latitude,
                            userLocation!.longitude,
                            chargingStation.latitude,
                            chargingStation.longitude,
                          ).toStringAsFixed(2) // Displaying distance with 2 decimal places
                              : 'N/A';

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChargingStationDetailsPage(
                                    stationId: chargingStation.stationId,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              width: 190,
                              margin: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey, width: 2),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    chargingStation.name,
                                    style: SafeGoogleFont(
                                      'Lato',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    )
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    chargingStation.address,
                                    style: SafeGoogleFont(
                                      'Lato',
                                      fontSize: 12,
                                      color: Colors.black54,
                                    )
                                  ),
                                  SizedBox(height: 5), // Add some spacing between address and distance
                                  Text(
                                    'Distance: ${userLocation != null ? '$distance km' : 'N/A'}', // Display the distance or 'N/A' if userLocation is null
                                    style: SafeGoogleFont(
                                      'Lato',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    )
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FractionalTranslation(
          translation: Offset(0.0, 0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 120, // Set a fixed width for both buttons
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showFilterOptions(context);
                  },
                  icon: Icon(Icons.filter_alt_rounded),
                  label: Text(
                    'Filter',
                    style: SafeGoogleFont(
                      'Lato',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: buttonColor,
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 4,
                  ),
                ),
              ),
              SizedBox(height: 8),
              SizedBox(
                width: 120, // Set a fixed width for both buttons
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showSortOptions(context);
                  },
                  icon: Icon(Icons.sort),
                  label: Text(
                    'Sort',
                    style: SafeGoogleFont(
                      'Lato',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: buttonColor,
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}
