import 'package:cloud_firestore/cloud_firestore.dart';

class ModelNearByList {
  final String stationId;
  final String name;
  final String address;
  final String connection;
  final String speed;
  final String price;
  final GeoPoint? location; // Add the location property

  ModelNearByList(
      this.stationId,
      this.name,
      this.address,
      this.connection,
      this.speed,
      this.price,
      this.location, // Initialize the location property
      );
}
