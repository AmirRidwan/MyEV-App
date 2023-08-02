
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../base/color_data.dart';
import '../../base/resizer/fetch_pixels.dart';
import '../../base/widget_utils.dart';

class FullView extends StatefulWidget {
  final String stationId; // ID of the charging station to display


  const FullView({Key? key, required this.stationId}) : super(key: key);

  @override
  State<FullView> createState() => _FullViewState();
}

class _FullViewState extends State<FullView> {

  int select = 0;

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
        });
      }
    } catch (e) {
      print('Error fetching charging station data: $e');
    }
  }

  LatLng? userLocation;
  LatLng? chargingStationLocation;
  Set<Polyline> polylines = {};

  // Function to get the user's current location
  Future<void> _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  // Function to draw a polyline between user location and charging station location
  void _showPolylineOnMap() {
    if (userLocation != null && chargingStationLocation != null) {
      Polyline polyline = Polyline(
        polylineId: PolylineId('route'),
        color: Colors.blue,
        width: 5,
        points: [userLocation!, chargingStationLocation!],
      );

      setState(() {
        polylines.add(polyline);
      });
    }
  }

  @override
  void initState() {
    _fetchChargingStationData();
    _getUserLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FetchPixels(context);
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: FetchPixels.getPixelHeight(20)),
      primary: true,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      children: [
        getVerSpace(FetchPixels.getPixelHeight(50)),
        getCustomFont("ADDRESS", 16, textColor, 1, fontWeight: FontWeight.w500),
        getVerSpace(FetchPixels.getPixelHeight(8)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getSvgImage("location.svg",
                      height: FetchPixels.getPixelHeight(22),
                      width: FetchPixels.getPixelHeight(22)),
                  getHorSpace(FetchPixels.getPixelHeight(10)),
                  Expanded(
                    flex: 2,
                    child: getMultilineCustomFont(
                        chargingStationData?['address'] ?? 'Loading..',
                        16,
                        Colors.black,
                        fontWeight: FontWeight.w400,
                        txtHeight: FetchPixels.getPixelHeight(1.5)),
                  ),
                  getAssetImage("direction.png",
                      height: FetchPixels.getPixelHeight(52),
                      width: FetchPixels.getPixelHeight(44)),
                ],
              ),
            ),
          ],
        ),

        getVerSpace(FetchPixels.getPixelHeight(50)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getCustomFont("Charger Type", 16, textColor, 1,
                    fontWeight: FontWeight.w500),
                getVerSpace(FetchPixels.getPixelHeight(8)),
                getCustomFont(chargingStationData?['chargerType'] ?? 'Loading..', 16, Colors.black, 1,
                    fontWeight: FontWeight.w700)
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getCustomFont("Speed", 16, textColor, 1,
                    fontWeight: FontWeight.w500),
                getVerSpace(FetchPixels.getPixelHeight(8)),
                getCustomFont(chargingStationData?['chargingSpeed'] ?? 'Loading..', 16, Colors.black, 1,
                    fontWeight: FontWeight.w700)
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getCustomFont("Price Rate", 16, textColor, 1,
                    fontWeight: FontWeight.w500),
                getVerSpace(FetchPixels.getPixelHeight(8)),
                getCustomFont('RM${chargingStationData?['chargingRate'] ?? 'Loading..'}/hour', 16, Colors.black, 1,
                    fontWeight: FontWeight.w700)
              ],
            )
          ],
        ),
        getVerSpace(FetchPixels.getPixelHeight(20)),
      ],
    );
  }
}
