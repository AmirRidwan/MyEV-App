import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils.dart';
import 'EditChargingStationPage.dart';

class ChargingStationPage extends StatefulWidget {
  @override
  _ChargingStationPageState createState() => _ChargingStationPageState();
}

class _ChargingStationPageState extends State<ChargingStationPage> {
  late Stream<QuerySnapshot> _chargingStationsStream;
  String searchQuery = '';
  String selectedChargerType = '';
  String selectedChargingSpeed = '';

  @override
  void initState() {
    super.initState();
    // Fetch charging station data from Firebase Firestore
    _chargingStationsStream =
        FirebaseFirestore.instance.collection('charging_stations').snapshots();
  }

  Future<void> _refreshData() async {
    // Fetch charging station data from Firebase Firestore again
    _chargingStationsStream =
        FirebaseFirestore.instance.collection('charging_stations').snapshots();
    // Wait for a short duration to simulate loading from Firestore
    await Future.delayed(Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xff2d366f)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          "Manage EV Charging Station",
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
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    searchQuery = '';
                                  });
                                },
                              )
                            : Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:10.0, vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter:',
                        style: SafeGoogleFont(
                          'Lato',
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      DropdownButton<String>(
                        value: selectedChargerType,
                        hint: Text('Charger Type'),
                        onChanged: (newValue) {
                          setState(() {
                            selectedChargerType = newValue!;
                          });
                        },
                        items: [
                          DropdownMenuItem(
                            child: Text(
                              'All Charger Type',
                              style: SafeGoogleFont(
                                'Lato',
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            value: '',
                          ),
                          DropdownMenuItem(
                            child: Text(
                              'Type 1',
                              style: SafeGoogleFont(
                                'Lato',
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            value: 'Type 1',
                          ),
                          DropdownMenuItem(
                            child: Text(
                              'Type 2',
                              style: SafeGoogleFont(
                                'Lato',
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            value: 'Type 2',
                          ),
                          DropdownMenuItem(
                            child: Text(
                              'DC Fast Charging',
                              style: SafeGoogleFont(
                                'Lato',
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            value: 'DC Fast Charging',
                          ),
                          // Add more dropdown items for charger types
                        ],
                      ),
                      DropdownButton<String>(
                        value: selectedChargingSpeed,
                        hint: Text('Charging Speed'),
                        onChanged: (newValue) {
                          setState(() {
                            selectedChargingSpeed = newValue!;
                          });
                        },
                        items: [
                          DropdownMenuItem(
                            child: Text(
                              'All Charging Speed',
                              style: SafeGoogleFont(
                                'Lato',
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            value: '',
                          ),
                          DropdownMenuItem(
                            child: Text(
                              'Slow',
                              style: SafeGoogleFont(
                                'Lato',
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            value: 'Slow',
                          ),
                          DropdownMenuItem(
                            child: Text(
                              'Medium',
                              style: SafeGoogleFont(
                                'Lato',
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            value: 'Slow',
                          ),
                          DropdownMenuItem(
                            child: Text(
                              'Fast',
                              style: SafeGoogleFont(
                                'Lato',
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            value: 'Fast',
                          ),
                          // Add more dropdown items for charging speeds
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _chargingStationsStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final chargingStations = snapshot.data!.docs;

                        // Apply search query filter
                        final filteredStations = chargingStations.where((station) {
                          final stationData =
                              station.data() as Map<String, dynamic>;
                          final stationName = stationData['name'] as String;
                          final stationAddress = stationData['address'] as String;
                          final queryLower = searchQuery.toLowerCase();
                          return stationName.toLowerCase().contains(queryLower) ||
                              stationAddress.toLowerCase().contains(queryLower);
                        }).toList();

                        // Apply charger type filter
                        final filteredByChargerType = selectedChargerType.isNotEmpty
                            ? filteredStations
                                .where((station) =>
                                    (station.data()
                                        as Map<String, dynamic>)['chargerType'] ==
                                    selectedChargerType)
                                .toList()
                            : filteredStations;

                        // Apply charging speed filter
                        final filteredByChargingSpeed = selectedChargingSpeed
                                .isNotEmpty
                            ? filteredByChargerType
                                .where((station) =>
                                    (station.data()
                                        as Map<String, dynamic>)['chargingSpeed'] ==
                                    selectedChargingSpeed)
                                .toList()
                            : filteredByChargerType;

                        if (filteredByChargingSpeed.isEmpty) {
                          return Center(child: Text('No results found'));
                        }

                        return ListView.builder(
                          itemCount: filteredByChargingSpeed.length,
                          itemBuilder: (context, index) {
                            final chargingStation = filteredByChargingSpeed[index];
                            final chargingStationData =
                                chargingStation.data() as Map<String, dynamic>;
                            final chargingStationId = chargingStation.id;
                            final bool isAvailable =
                                chargingStationData['availability'];
                            final geoPoint =
                                chargingStationData['location'] as GeoPoint;
                            final String address = chargingStationData['address'];
                            final String chargerType =
                                chargingStationData['chargerType'];
                            final String chargingSpeed =
                                chargingStationData['chargingSpeed'];

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: Material(
                                color: Colors.white,
                                elevation: 4,
                                borderRadius: BorderRadius.circular(10.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  margin: EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          chargingStationData['name'],
                                          style: SafeGoogleFont(
                                            'Lato',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Address: $address',
                                              style: SafeGoogleFont(
                                                'Lato',
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            SizedBox(height: 4.0),
                                            Text(
                                              'Charging Type: $chargerType',
                                              style: SafeGoogleFont(
                                                'Lato',
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            SizedBox(height: 4.0),
                                            Text(
                                              'Charging Speed: $chargingSpeed',
                                              style: SafeGoogleFont(
                                                'Lato',
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            SizedBox(height: 4.0),
                                            Text(
                                              'Latitude: ${geoPoint.latitude}, Longitude: ${geoPoint.longitude}',
                                              style: SafeGoogleFont(
                                                'Lato',
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: Switch(
                                          value: isAvailable,
                                          onChanged: (value) {
                                            // Update availability status in Firestore
                                            FirebaseFirestore.instance
                                                .collection('charging_stations')
                                                .doc(chargingStation.id)
                                                .update({'availability': value});
                                          },
                                        ),
                                      ),
                                      // Edit Details text button
                                      TextButton(
                                        onPressed: () {
                                          // Navigate to the EditChargingStationPage with the charging station ID
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditChargingStationPage(
                                                chargingStationId:
                                                    chargingStationId,
                                              ),
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          primary: Colors.white,
                                          backgroundColor: Color(0xff2d366f),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Text('Edit Details'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error fetching data'));
                      }

                      return Center(child: CircularProgressIndicator());
                    },
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

class ChargingStationSearchDelegate extends SearchDelegate<String> {
  @override
  String get searchFieldLabel => 'Search';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: theme.canvasColor,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
      textTheme: theme.textTheme.copyWith(
        headline6: TextStyle(color: Colors.grey),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Perform search based on query and display results
    return Container(); // Replace with your search results widget
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show suggestions as the user types in the search bar
    return Container(); // Replace with your suggestions widget
  }
}
