import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../utils.dart';

class AddChargingStationPage extends StatefulWidget {
  @override
  _AddChargingStationPageState createState() => _AddChargingStationPageState();
}

class _AddChargingStationPageState extends State<AddChargingStationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _chargingRateController = TextEditingController();
  bool _availability = false;
  String? _chargerType;
  String? _chargingSpeed;
  String? _openingTime;
  String? _closingTime;
  List<String> _chargerTypes = ['Type 1', 'Type 2', 'DC Fast Charging'];
  List<String> _chargingSpeeds = ['Slow', 'Medium', 'Fast'];
  List<String> _operationHours = [
    '1 AM',
    '2 AM',
    '3 AM',
    '4 AM',
    '5 AM',
    '6 AM',
    '7 AM',
    '8 AM',
    '9 AM',
    '10 AM',
    '11 AM',
    '12 PM',
    '1 PM',
    '2 PM',
    '3 PM',
    '4 PM',
    '5 PM',
    '6 PM',
    '7 PM',
    '8 PM',
    '9 PM',
    '10 PM',
    '11 PM',
    '12 AM',
  ];

  List<DropdownMenuItem<String>> _buildDropdownMenuItems(List<String> items) {
    return items.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
  }

  List<XFile> _selectedImages = [];

  Future<void> _selectImages() async {
    if (_selectedImages.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have reached the maximum limit of 4 photos.')),
      );
      return;
    }

    List<XFile>? images = await ImagePicker().pickMultiImage();
    if (images != null) {
      // Calculate the number of images that can be added
      int remainingSlots = 4 - _selectedImages.length;

      // Add images up to the remaining available slots
      _selectedImages.addAll(images.take(remainingSlots));

      setState(() {
        // Update the state with the new selected images
      });
    }
  }

  Future<void> _uploadPhotos(List<XFile> imageFiles, String stationId) async {
    List<String> uploadedPhotoUrls = [];

    for (var imageFile in imageFiles) {
      Reference storageRef = FirebaseStorage.instance.ref().child('charging_station_photos/$stationId/${DateTime.now().toString()}.jpg');
      UploadTask uploadTask = storageRef.putFile(File(imageFile.path));
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      uploadedPhotoUrls.add(downloadUrl);
    }
    await FirebaseFirestore.instance.collection('charging_stations').doc(stationId).update({
      'images': uploadedPhotoUrls,
    });
  }

  Future<void> _addChargingStation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String name = _nameController.text.trim();
    String address = _addressController.text.trim();
    double latitude = double.parse(_latitudeController.text.trim());
    double longitude = double.parse(_longitudeController.text.trim());
    int chargingRate = int.parse(_chargingRateController.text.trim());
    GeoPoint location = GeoPoint(latitude, longitude);

    String operationHour = _openingTime! + ' - ' + _closingTime!;

    try {
      DocumentReference docRef =
      await FirebaseFirestore.instance.collection('charging_stations').add({
        'name': name,
        'address': address,
        'location': location,
        'availability': _availability,
        'chargerType': _chargerType,
        'chargingSpeed': _chargingSpeed,
        'operationHour': operationHour,
        'chargingRate': chargingRate,
        'images': [],
      });

      String stationId = docRef.id;

      await _uploadPhotos(_selectedImages, stationId);
      await docRef.update({
        'stationId': stationId,
      });

      // Clear form fields
      _nameController.clear();
      _addressController.clear();
      _latitudeController.clear();
      _longitudeController.clear();
      _chargingRateController.clear();
      _availability = false;
      _chargerType = null;
      _chargingSpeed = null;
      _openingTime = null;
      _closingTime = null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Charging station added successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add charging station.')),
      );
    }
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
          "Add Charging Station",
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: SingleChildScrollView(
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: SafeGoogleFont(
                            'Lato',
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          labelStyle: SafeGoogleFont(
                            'Lato',
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter an address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _latitudeController,
                              decoration: InputDecoration(
                                labelText: 'Latitude',
                                labelStyle: SafeGoogleFont(
                                  'Lato',
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                                prefixIcon: Icon(Icons.map),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter a latitude';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Expanded(
                            child: TextFormField(
                              controller: _longitudeController,
                              decoration: InputDecoration(
                                labelText: 'Longitude',
                                labelStyle: SafeGoogleFont(
                                  'Lato',
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                                prefixIcon: Icon(Icons.map),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter a longitude';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      SwitchListTile(
                        title: Text('Availability'),
                        value: _availability,
                        onChanged: (bool value) {
                          setState(() {
                            _availability = value;
                          });
                        },
                      ),
                      SizedBox(height: 10.0),
                      DropdownButtonFormField<String>(
                        value: _chargerType,
                        decoration: InputDecoration(
                          labelText: 'Charger Type',
                          labelStyle: SafeGoogleFont(
                            'Lato',
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          prefixIcon: Icon(Icons.ev_station),
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(
                              'Select a charger type',
                              style: SafeGoogleFont(
                                'Lato',
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          ..._buildDropdownMenuItems(_chargerTypes),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            _chargerType = value;
                          });
                        },
                      ),
                      SizedBox(height: 10.0),
                      DropdownButtonFormField<String>(
                        value: _chargingSpeed,
                        decoration: InputDecoration(
                          labelText: 'Charging Speed',
                          labelStyle: SafeGoogleFont(
                            'Lato',
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          prefixIcon: Icon(Icons.flash_on),
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(
                              'Select a charging speed',
                              style: SafeGoogleFont(
                                'Lato',
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          ..._buildDropdownMenuItems(_chargingSpeeds),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            _chargingSpeed = value;
                          });
                        },
                      ),
                      SizedBox(height: 10.0),
                      DropdownButtonFormField<String>(
                        value: _openingTime,
                        decoration: InputDecoration(
                          labelText: 'Opening Time',
                          labelStyle: SafeGoogleFont(
                            'Lato',
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(
                              'Select opening time',
                              style: SafeGoogleFont(
                                'Lato',
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          ..._buildDropdownMenuItems(_operationHours),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            _openingTime = value;
                          });
                        },
                      ),
                      SizedBox(height: 10.0),
                      DropdownButtonFormField<String>(
                        value: _closingTime,
                        decoration: InputDecoration(
                          labelText: 'Closing Time',
                          labelStyle: SafeGoogleFont(
                            'Lato',
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(
                              'Select closing time',
                              style: SafeGoogleFont(
                                'Lato',
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          ..._buildDropdownMenuItems(_operationHours),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            _closingTime = value;
                          });
                        },
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: _chargingRateController,
                        decoration: InputDecoration(
                          labelText: 'Charging Rate (per hour)',
                          labelStyle: SafeGoogleFont(
                            'Lato',
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter the charging rate per hour';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10.0),
                      Container(
                        height: 200,
                        child: GridView.builder(
                          itemCount: _selectedImages.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 10.0, // Space between columns
                            mainAxisSpacing: 10.0,
                            crossAxisCount: 4, // Adjust the number of columns as needed
                          ),
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                                child: Image.file(
                                    File(_selectedImages[index].path),
                                  fit: BoxFit.cover,
                                ),
                            );
                          },
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _selectImages,
                        child: Text('Upload Photos (Max 4)'),
                      ),
                      SizedBox(height: 20.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xff2d366f),
                        ),
                        onPressed: _addChargingStation,
                        child: Text(
                          'Add Charging Station',
                          style: SafeGoogleFont(
                            'Lato',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}