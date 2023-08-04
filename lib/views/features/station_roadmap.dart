import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';

import '../../utils.dart';

class StationRoadmap extends StatefulWidget {
  @override
  _StationRoadmapState createState() => _StationRoadmapState();
}

class _StationRoadmapState extends State<StationRoadmap> {
  TextEditingController startingLocationController = TextEditingController();
  TextEditingController destinationLocationController = TextEditingController();
  Position? _initialCameraPosition; // Position for user's current location

  GoogleMapController? mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _chargingStations = {};

  PolylinePoints polylinePoints = PolylinePoints();

  // Define the maximum distance (in meters) to consider a charging station as near the route.
  static const double maxDistanceToRoute =
  1000.0; // Adjust this value as needed.

  // Custom markers for origin, destination, and charging stations.
  BitmapDescriptor? originMarker;
  BitmapDescriptor? destinationMarker;
  BitmapDescriptor? chargingStationMarker;

  LatLng? originLatLng;
  LatLng? destinationLatLng;

  @override
  void initState() {
    super.initState();
    // Load custom marker icons when the widget is initialized.
    _loadCustomMarkers();
    _getUserLocation();
  }

  Future<void> _loadCustomMarkers() async {
    originMarker = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)), // Size of the marker image.
      'assets/images/destinationMarker.png',
    );

    destinationMarker = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)), // Size of the marker image.
      'assets/images/destinationMarker.png',
    );

    chargingStationMarker = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)), // Size of the marker image.
      'assets/images/marker.png',
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  Future<List<LatLng>> _decodePolyline(String encoded) async {
    List<LatLng> polylineCoordinates = [];
    List<PointLatLng> result = polylinePoints.decodePolyline(encoded);
    if (result.isNotEmpty) {
      polylineCoordinates = result.map((PointLatLng point) {
        return LatLng(point.latitude, point.longitude);
      }).toList();
    }
    return polylineCoordinates;
  }

  void _calculateRoute(String origin, String destination) async {
    if (origin.isEmpty || destination.isEmpty) {
      // Show an error message to the user about empty inputs.
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Location'),
            content: Text('Please enter location.'),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color(0xff2d366f),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'OK',
                  style: SafeGoogleFont(
                    'Lato',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      );
      return;
    }

    final String apiKey = 'AIzaSyAyXFlJRDBe3stJQBvAqysjpJ6xjwC4gis';
    final String apiUrl =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      final List<LatLng> polylineCoordinates = await _decodePolyline(
          decodedData['routes'][0]['overview_polyline']['points']);
      _addRoutePolyline(polylineCoordinates);

      // Fetch charging stations near the route.
      _fetchChargingStations(origin, destination, polylineCoordinates);

      // Convert the origin and destination locations to latitude and longitude.
      originLatLng = await _getLatLngFromAddress(origin);
      destinationLatLng = await _getLatLngFromAddress(destination);

      setState(() {
        _chargingStations
            .removeWhere((marker) => marker.markerId.value == 'destination');
        _chargingStations.add(_createDestinationMarker());

        if (originLatLng != null) {
          _chargingStations
              .removeWhere((marker) => marker.markerId.value == 'origin');
          _chargingStations.add(_createOriginMarker());
        }
      });
    } else {
      // Handle API error
      print('Failed to get directions: ${response.statusCode}');
      // Show an error message to the user.
    }
  }

  Future<LatLng?> _getLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location location = locations[0];
        return LatLng(location.latitude!, location.longitude!);
      }
    } catch (e) {
      print('Error getting LatLng from address: $e');
    }
    return null;
  }

  void _fetchChargingStations(String origin, String destination,
      List<LatLng> routeCoordinates) async {
    try {
      CollectionReference chargingStationsCollection =
      FirebaseFirestore.instance.collection('charging_stations');

      QuerySnapshot querySnapshot = await chargingStationsCollection.get();
      List<QueryDocumentSnapshot> documents = querySnapshot.docs;

      setState(() {
        _chargingStations.clear();

        for (var doc in documents) {
          GeoPoint location = doc['location'];
          double lat = location.latitude;
          double lng = location.longitude;

          bool isAvailable = doc['availability'] ?? false;
          String availabilityText = isAvailable ? 'Available' : 'Not Available';

          LatLng chargingStationLatLng = LatLng(lat, lng);

          // Calculate the distance between the charging station and each segment of the route.
          double minDistance = double.infinity;
          for (int i = 0; i < routeCoordinates.length - 1; i++) {
            double distanceToRoute = Geolocator.distanceBetween(
              chargingStationLatLng.latitude,
              chargingStationLatLng.longitude,
              routeCoordinates[i].latitude,
              routeCoordinates[i].longitude,
            );
            minDistance = min(minDistance, distanceToRoute);
          }

          if (minDistance <= maxDistanceToRoute) {
            _chargingStations.add(
              Marker(
                markerId: MarkerId(doc.id),
                position: chargingStationLatLng,
                icon: chargingStationMarker ?? BitmapDescriptor.defaultMarker,
                infoWindow: InfoWindow(
                  title: doc['name'],
                  snippet: 'Status: $availabilityText',
                ),
              ),
            );
          }
        }
      });
    } catch (e) {
      print('Error fetching charging station data: $e');
    }
  }

  void _addRoutePolyline(List<LatLng> polylineCoordinates) {
    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          points: polylineCoordinates,
          color: Colors.blue,
          width: 5,
        ),
      );
    });
  }

  Marker _createOriginMarker() {
    return Marker(
      markerId: MarkerId('origin'),
      position: originLatLng!,
      icon: originMarker ?? BitmapDescriptor.defaultMarker,
      // Use default marker if null.
      infoWindow: InfoWindow(title: 'Origin'),
    );
  }

  Marker _createDestinationMarker() {
    return Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng!,
      icon: destinationMarker ?? BitmapDescriptor.defaultMarker,
      // Use default marker if null.
      infoWindow: InfoWindow(title: 'Destination'),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onSearchButtonPressed() {
    String startingLocation = startingLocationController.text;
    String destinationLocation = destinationLocationController.text;

    _calculateRoute(startingLocation, destinationLocation);
  }

  void _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _initialCameraPosition = position;
      });
    } catch (e) {
      print('Error getting user location: $e');
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
          "EV Charging Station Roadmap",
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xff2d366f),
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Color(0xff9dd1ea),
      ),
      body: Column(
        children: [
          Material(
            elevation: 4,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            color: Color(0xff9dd1ea),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(14.0),
                        color: Colors.white,
                        child: Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          child: TextField(
                            style: SafeGoogleFont(
                              'Lato',
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                            controller: startingLocationController,
                            decoration: InputDecoration(
                              labelText: 'Starting Location',
                              labelStyle: SafeGoogleFont(
                                'Lato',
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      // Add some spacing between the text fields
                      Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(14.0),
                        color: Colors.white,
                        child: Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          child: TextField(
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                            controller: destinationLocationController,
                            decoration: InputDecoration(
                              labelText: 'Destination Location',
                              labelStyle: SafeGoogleFont(
                                'Lato',
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xff2d366f),
                  ),
                  onPressed: _onSearchButtonPressed,
                  child: Text(
                    'Show Route and Charging Stations',
                    style: SafeGoogleFont(
                      'Lato',
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              compassEnabled: true,
              initialCameraPosition: _initialCameraPosition != null
                  ? CameraPosition(
                target: LatLng(_initialCameraPosition!.latitude,
                    _initialCameraPosition!.longitude),
                zoom: 12.0,
              )
                  : CameraPosition(
                target: LatLng(3.1663819611475787, 101.53690995000055),
                // Default location (Shah Alam)
                zoom: 12.0,
              ),
              markers: {
                ..._chargingStations,
                if (originLatLng != null) _createOriginMarker(),
                if (destinationLatLng != null) _createDestinationMarker()
              },
              polylines: _polylines,
              onMapCreated: _onMapCreated,
            ),
          ),
        ],
      ),
    );
  }
}
