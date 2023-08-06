import 'package:evfinder/utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Photos extends StatefulWidget {
  final String stationId;

  Photos({required this.stationId});

  @override
  _PhotosState createState() =>
      _PhotosState();
}

class _PhotosState
    extends State<Photos> {
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      DocumentSnapshot stationSnapshot = await FirebaseFirestore.instance
          .collection('charging_stations')
          .doc(widget.stationId)
          .get();

      if (stationSnapshot.exists) {
        setState(() {
          _imageUrls = List<String>.from(stationSnapshot['images']);
        });
      }
    } catch (error) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _imageUrls.isEmpty
          ? Center(
        child: Text(
            'No photos available',
          style: SafeGoogleFont(
              'Lato',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns in the grid
            crossAxisSpacing: 10.0, // Space between columns
            mainAxisSpacing: 10.0, // Space between rows
        ),
        itemCount: _imageUrls.length,
        itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10.0), // Adjust the border radius as needed
              child: Image.network(
                _imageUrls[index],
                fit: BoxFit.cover,
              ),
            );
        },
      ),
          )
    );
  }
}
