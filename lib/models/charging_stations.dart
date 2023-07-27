import 'package:cloud_firestore/cloud_firestore.dart';

class ChargingStation {
  final String stationId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  ChargingStation({
    required this.stationId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory ChargingStation.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    GeoPoint geoPoint = data['location'] as GeoPoint; // Assuming 'location' is the field containing the GeoPoint
    double latitude = geoPoint.latitude;
    double longitude = geoPoint.longitude;

    return ChargingStation(
      stationId: snapshot.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      latitude: latitude,
      longitude: longitude,
    );
  }
}
