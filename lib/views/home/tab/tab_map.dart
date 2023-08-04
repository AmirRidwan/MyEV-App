import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

import '../../../base/color_data.dart';
import '../../../base/resizer/fetch_pixels.dart';
import '../../../base/widget_utils.dart';
import '../../../utils.dart';
import '../../booking/BookingSlot.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController _mapController;
  LocationData? _currentLocation;
  Set<Marker> _markers = {};

  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor markerCarIcon = BitmapDescriptor.defaultMarker;

  final TextEditingController _searchController = TextEditingController();
  String _selectedChargerType = '';
  String _selectedChargingSpeed = '';

  StreamSubscription? _chargingStationsSubscription;
  List<DocumentSnapshot> _chargingStations = [];
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _fetchChargingStations();
    addCustomIcon();
    addCustomCarIcon();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _chargingStationsSubscription?.cancel();
    super.dispose();
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

  void _fetchChargingStations() {
    _chargingStationsSubscription = FirebaseFirestore.instance
        .collection('charging_stations')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      setState(() {
        _chargingStations = snapshot.docs;
        _sortAndUpdateMarkers();
      });
    });

    // Call _sortAndUpdateMarkers() immediately after setting the subscription
    _sortAndUpdateMarkers();
  }

  void _sortAndUpdateMarkers() {
    _chargingStations.sort((a, b) {
      double distanceToA = _calculateDistance(
        _currentLocation!.latitude!,
        _currentLocation!.longitude!,
        a['location'].latitude,
        a['location'].longitude,
      );

      double distanceToB = _calculateDistance(
        _currentLocation!.latitude!,
        _currentLocation!.longitude!,
        b['location'].latitude,
        b['location'].longitude,
      );

      return distanceToA.compareTo(distanceToB);
    });

    // Call _updateMarkers() after updating _chargingStations
    _updateMarkers();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    Location location = Location();
    LocationData? locationData;
    try {
      locationData = await location.getLocation();
    } catch (error) {
      print('Error getting current location: $error');
    }

    setState(() {
      _currentLocation = locationData;
      _isLoadingLocation = false;
      _updateMarkers(); // Update markers when location changes
    });

    // Update the map's camera position to the current location
    if (_currentLocation != null) {
      _mapController.animateCamera(CameraUpdate.newLatLng(
        LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
      ));
    }
  }

  void _searchEVChargingLocation() {
    String searchTerm = _searchController.text.toLowerCase().trim();

    List<DocumentSnapshot> filteredStations =
        _chargingStations.where((station) {
      String address = station['address'].toString().toLowerCase();
      return address.contains(searchTerm);
    }).toList();

    setState(() {
      _markers = _buildMarkersFromStations(filteredStations);
    });
  }

  void addCustomIcon() {
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

  void addCustomCarIcon() {
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(200, 200)),
      "assets/images/CarIcon.png",
    ).then(
      (icon) {
        setState(() {
          markerCarIcon = icon;
        });
      },
    );
  }

  Set<Marker> _filteredMarkers = {}; // Store filtered markers
  List<DocumentSnapshot> _filteredChargingStations =
      []; // Store filtered charging stations
  List<LatLng> _polylineCoordinates =
      []; // Add this line to declare _polylineCoordinates

  void _updateMarkers() {
    List<DocumentSnapshot> filteredStations =
        _chargingStations.where((station) {
      String chargerType = station['chargerType'].toString();
      String chargingSpeed = station['chargingSpeed'].toString();

      bool matchesType =
          _selectedChargerType.isEmpty || chargerType == _selectedChargerType;
      bool matchesSpeed = _selectedChargingSpeed.isEmpty ||
          chargingSpeed == _selectedChargingSpeed;
      bool matchesSearch = _searchController.text.isEmpty ||
          station['address']
              .toString()
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());

      return matchesType && matchesSpeed && matchesSearch;
    }).toList();

    setState(() {
      _filteredMarkers = _buildMarkersFromStations(filteredStations);
      _filteredChargingStations =
          filteredStations; // Update the filtered charging stations list
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedChargerType = '';
      _selectedChargingSpeed = '';
      _updateMarkers();
    });
  }

  Set<Marker> _buildMarkersFromStations(List<DocumentSnapshot> stations) {
    Set<Marker> markers = {};

    // Add "You're here" marker
    if (_currentLocation != null) {
      Marker userMarker = Marker(
        markerId: MarkerId('user_marker'),
        position: LatLng(
          _currentLocation!.latitude!,
          _currentLocation!.longitude!,
        ),
        infoWindow: InfoWindow(
          title: "You're here",
        ),
        icon: markerCarIcon,
      );
      markers.add(userMarker);
    }

    for (DocumentSnapshot station in stations) {
      GeoPoint location = station['location'] as GeoPoint;
      LatLng latLng = LatLng(location.latitude, location.longitude);

      MarkerId markerId = MarkerId(station.id);

      Marker marker = Marker(
        markerId: markerId,
        position: latLng,
        infoWindow: InfoWindow(
          title: station['name'].toString(),
          snippet: station['address'].toString(),
        ),
        icon: markerIcon,
      );

      markers.add(marker);
    }

    return markers;
  }

  void _showRouteToChargingStation(DocumentSnapshot station) async {
    // Check if the user's current location is available
    if (_currentLocation == null) {
      return;
    }

    // Check if there's an existing polyline on the map and remove it
    if (_polylines.isNotEmpty) {
      setState(() {
        _polylines.clear();
      });
    }

    // Get the latitude and longitude of the charging station
    double destinationLatitude = station['location'].latitude;
    double destinationLongitude = station['location'].longitude;

    // Create the starting and destination coordinates
    LatLng originLatLng =
        LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
    LatLng destinationLatLng =
        LatLng(destinationLatitude, destinationLongitude);

    // Use the Directions API to get the route information
    List<LatLng> routeCoordinates =
        await _getRouteCoordinates(originLatLng, destinationLatLng);

    // Update the map with the route polyline and adjust the camera bounds
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        originLatLng.latitude < destinationLatLng.latitude
            ? originLatLng.latitude
            : destinationLatLng.latitude,
        originLatLng.longitude < destinationLatLng.longitude
            ? originLatLng.longitude
            : destinationLatLng.longitude,
      ),
      northeast: LatLng(
        originLatLng.latitude > destinationLatLng.latitude
            ? originLatLng.latitude
            : destinationLatLng.latitude,
        originLatLng.longitude > destinationLatLng.longitude
            ? originLatLng.longitude
            : destinationLatLng.longitude,
      ),
    );

    // Animate the camera to fit the bounds
    _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 150));

    // Draw the route polyline on the map
    _addPolyline(routeCoordinates);
  }

  void _addPolyline(List<LatLng> routeCoordinates) {
    Polyline polyline = Polyline(
      polylineId: PolylineId("route"),
      color: Colors.blue,
      points: routeCoordinates,
      width: 5,
    );

    setState(() {
      _polylines.add(polyline);
    });
  }

  Future<List<LatLng>> _getRouteCoordinates(
      LatLng origin, LatLng destination) async {
    // Replace with your own Google Maps API key
    String apiKey = 'AIzaSyAyXFlJRDBe3stJQBvAqysjpJ6xjwC4gis';

    // Request the route information from the Google Maps Directions API
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    // Perform the HTTP GET request and parse the response
    var response = await http.get(Uri.parse(url));
    var decodedJson = jsonDecode(response.body);

    // Extract the route polyline points from the response
    List<LatLng> polylineCoordinates = [];
    if (decodedJson['status'] == 'OK') {
      List<dynamic> routes = decodedJson['routes'][0]['legs'][0]['steps'];
      for (var route in routes) {
        String encodedPolyline = route['polyline']['points'];
        List<LatLng> decodedPolyline = PolylinePoints()
            .decodePolyline(encodedPolyline)
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
        polylineCoordinates.addAll(decodedPolyline);
      }
    }

    return polylineCoordinates;
  }

  Set<Polyline> _polylines =
      {}; // Add this line to define the _polylines variable

  LatLngBounds _getLatLngBounds(LatLng origin, LatLng destination) {
    double south = origin.latitude < destination.latitude
        ? origin.latitude
        : destination.latitude;
    double north = origin.latitude > destination.latitude
        ? origin.latitude
        : destination.latitude;
    double west = origin.longitude < destination.longitude
        ? origin.longitude
        : destination.longitude;
    double east = origin.longitude > destination.longitude
        ? origin.longitude
        : destination.longitude;
    return LatLngBounds(
        northeast: LatLng(north, east), southwest: LatLng(south, west));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              GoogleMap(
                zoomControlsEnabled: false,
                myLocationEnabled: false,
                mapType: MapType.normal,
                mapToolbarEnabled: false,
                polylines: _polylines,
                initialCameraPosition: _currentLocation != null
                    ? CameraPosition(
                        target: LatLng(
                          _currentLocation!.latitude!,
                          _currentLocation!.longitude!,
                        ),
                        zoom: 14.0,
                      )
                    : CameraPosition(
                        target: LatLng(3.1663819611475787, 101.53690995000055),
                        // Fallback position if current location is null
                        zoom: 14.0,
                      ),
                markers: _filteredMarkers,
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
              ),
              Positioned(
                top: 16.0,
                left: 16.0,
                right: 16.0,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(24.0),
                  color: Colors.white,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.0),
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
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search by address',
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 16.0),
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
                ),
              ),
              Positioned(
                top: 80.0,
                left: 16.0,
                right: 16.0,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(24.0),
                  color: Colors.white,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedChargerType,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                              onChanged: (String? value) {
                                if (value == '') {
                                  // Clear the filter
                                  _clearFilters();
                                } else {
                                  setState(() {
                                    _selectedChargerType = value ?? '';
                                    _updateMarkers();
                                  });
                                }
                              },
                              items: [
                                DropdownMenuItem<String>(
                                  value: '',
                                  child: Text(
                                    'All Charger Types',
                                    style: SafeGoogleFont(
                                      'Lato',
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'Type 1',
                                  child: Text(
                                    'Type 1',
                                    style: SafeGoogleFont(
                                      'Lato',
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'Type 2',
                                  child: Text(
                                    'Type 2',
                                    style: SafeGoogleFont(
                                      'Lato',
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'DC Fast Charging',
                                  child: Text(
                                    'DC Fast Charging',
                                    style: SafeGoogleFont(
                                      'Lato',
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 2.0),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedChargingSpeed,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              onChanged: (String? value) {
                                if (value == '') {
                                  // Clear the filter
                                  _clearFilters();
                                } else {
                                  setState(() {
                                    _selectedChargingSpeed = value ?? '';
                                    _updateMarkers();
                                  });
                                }
                              },
                              items: [
                                DropdownMenuItem<String>(
                                  value: '',
                                  child: Text(
                                    'All Charging Speeds',
                                    style: SafeGoogleFont(
                                      'Lato',
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'Slow',
                                  child: Text(
                                    'Slow',
                                    style: SafeGoogleFont(
                                      'Lato',
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'Medium',
                                  child: Text(
                                    'Medium',
                                    style: SafeGoogleFont(
                                      'Lato',
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'Fast',
                                  child: Text(
                                    'Fast',
                                    style: SafeGoogleFont(
                                      'Lato',
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 150.0,
                right: 15.0,
                child: FloatingActionButton(
                  backgroundColor: buttonColor,
                  onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                  child: _isLoadingLocation
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.my_location),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 150.0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filteredChargingStations.length,
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot station = _chargingStations[index];
                      bool availability = station['availability'];
                      String chargerType = station['chargerType'];
                      String chargingSpeed = station['chargingSpeed'];

                      // Calculate the distance to the charging station
                      double distanceToStation = _calculateDistance(
                        _currentLocation!.latitude!,
                        _currentLocation!.longitude!,
                        station['location'].latitude,
                        station['location'].longitude,
                      );

                      return GestureDetector(
                        onTap: () {
                          _mapController.animateCamera(
                            CameraUpdate.newLatLng(
                              LatLng(
                                station['location'].latitude,
                                station['location'].longitude,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(16.0),
                            child: Container(
                              width: 240.0, // Adjust the width here
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      station['name'].toString(),
                                      style: SafeGoogleFont(
                                        'Lato',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    // Display the distance information
                                    Text(
                                      'Distances: ${distanceToStation.toStringAsFixed(2)} km',
                                      style: SafeGoogleFont(
                                        'Lato',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 10.0),
                                    availability
                                        ? Text(
                                            'Available',
                                            style: SafeGoogleFont(
                                              'Lato',
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          )
                                        : Text(
                                            'Not Available',
                                            style: SafeGoogleFont(
                                              'Lato',
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                    SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              primary: buttonColor,
                                              onPrimary: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8, horizontal: 16),
                                            ),
                                            onPressed: () {
                                              showModalBottomSheet(
                                                enableDrag: true,
                                                isDismissible: true,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                    top: Radius.circular(25.0),
                                                  ),
                                                ),
                                                context: context,
                                                isScrollControlled: true,
                                                builder:
                                                    (BuildContext context) {
                                                  return Container(
                                                    padding:
                                                        EdgeInsets.all(16.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Center(
                                                          child: Text(
                                                            station['name']
                                                                .toString(),
                                                            style:
                                                                SafeGoogleFont(
                                                              'Lato',
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 10.0),
                                                        //Map view with markers
                                                        SizedBox(
                                                          height: 200,
                                                          child: GoogleMap(
                                                            initialCameraPosition:
                                                                CameraPosition(
                                                              target: LatLng(
                                                                station['location']
                                                                    .latitude,
                                                                station['location']
                                                                    .longitude,
                                                              ),
                                                              zoom: 16,
                                                            ),
                                                            zoomControlsEnabled:
                                                                false,
                                                            markers: Set<
                                                                Marker>.from([
                                                              Marker(
                                                                markerId: MarkerId(
                                                                    'chargingStation'),
                                                                position:
                                                                    LatLng(
                                                                  station['location']
                                                                      .latitude,
                                                                  station['location']
                                                                      .longitude,
                                                                ),
                                                                infoWindow:
                                                                    InfoWindow(
                                                                  title: station[
                                                                          'name']
                                                                      .toString(),
                                                                  snippet: station[
                                                                          'address']
                                                                      .toString(),
                                                                ),
                                                                icon:
                                                                    markerIcon,
                                                              ),
                                                            ]),
                                                          ),
                                                        ),
                                                        SizedBox(height: 8.0),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  'Address:',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Lato',
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black54,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 4.0),
                                                                Expanded(
                                                                  child: Text(
                                                                    '${station['address'].toString()}',
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Lato',
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .black54,
                                                                    ),
                                                                    softWrap:
                                                                        true, // Allow the address to wrap to a new line
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 8.0),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  'Charger Type:',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Lato',
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black54,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 4.0),
                                                                Text(
                                                                  '$chargerType',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Lato',
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black54,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 8.0),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  'Charging Speed:',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Lato',
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black54,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 4.0),
                                                                Text(
                                                                  '$chargingSpeed',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Lato',
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black54,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 8.0),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  'Operation Hour:',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Lato',
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black54,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 4.0),
                                                                Text(
                                                                  '${station['operationHour'].toString()}',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Lato',
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black54,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),

                                                        SizedBox(height: 16.0),
                                                        Center(
                                                          child: getButton(
                                                            context,
                                                            buttonColor,
                                                            "Book Slot",
                                                            Colors.white,
                                                            () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(builder:
                                                                      (BuildContext
                                                                          context) {
                                                                return BookingPage(
                                                                    stationId:
                                                                        station[
                                                                            'stationId']);
                                                              }));
                                                            },
                                                            18,
                                                            weight:
                                                                FontWeight.w700,
                                                            buttonHeight:
                                                                FetchPixels
                                                                    .getPixelHeight(
                                                                        44),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    FetchPixels
                                                                        .getPixelHeight(
                                                                            12)),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: Text(
                                              'VIEW DETAILS',
                                              style: SafeGoogleFont(
                                                'Lato',
                                                fontSize: 12,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              primary: buttonColor,
                                              onPrimary: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8, horizontal: 16),
                                            ),
                                            onPressed: () {
                                              _showRouteToChargingStation(
                                                  station);
                                            },
                                            child: Icon(Icons.directions),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
      ),
    );
  }
}
