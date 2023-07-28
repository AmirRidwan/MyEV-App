import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

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

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
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
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
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
      final List<LatLng> polylineCoordinates = _decodePolyline(decodedData['routes'][0]['overview_polyline']['points']);
      _addRoutePolyline(polylineCoordinates);
    } else {
      // Handle API error
      print('Failed to get directions: ${response.statusCode}');
      // Show an error message to the user.
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << (shift += 5);
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << (shift += 5);
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()));
    }
    return points;
  }

  void _fetchChargingStations(String origin, String destination) async {
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

          _chargingStations.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(
                title: doc['name'],
                snippet: 'Status: $availabilityText',
              ),
            ),
          );
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

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onSearchButtonPressed() {
    String startingLocation = startingLocationController.text;
    String destinationLocation = destinationLocationController.text;

    _calculateRoute(startingLocation, destinationLocation);
    _fetchChargingStations(startingLocation, destinationLocation);
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();
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
        title: Text('EV Charging Station Roadmap'),
      ),
      body: Column(
        children: [
          TextFormField(
            controller: startingLocationController,
            decoration: InputDecoration(labelText: 'Starting Location'),
          ),
          TextFormField(
            controller: destinationLocationController,
            decoration: InputDecoration(labelText: 'Destination Location'),
          ),
          ElevatedButton(
            onPressed: _onSearchButtonPressed,
            child: Text('Show Route and Charging Stations'),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: _initialCameraPosition != null
                  ? CameraPosition(
                target: LatLng(_initialCameraPosition!.latitude, _initialCameraPosition!.longitude),
                zoom: 12.0,
              )
                  : CameraPosition(
                target: LatLng(3.1663819611475787, 101.53690995000055), // Default location (Shah Alam)
                zoom: 12.0,
              ),
              markers: _chargingStations,
              polylines: _polylines,
              onMapCreated: _onMapCreated,
            ),
          ),
        ],
      ),
    );
  }
}
