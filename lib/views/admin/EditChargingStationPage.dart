import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils.dart';

class EditChargingStationPage extends StatefulWidget {
  final String chargingStationId;

  EditChargingStationPage({required this.chargingStationId});

  @override
  _EditChargingStationPageState createState() =>
      _EditChargingStationPageState();
}

class _EditChargingStationPageState extends State<EditChargingStationPage> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  String _selectedChargerType = '';
  String _selectedChargingSpeed = '';
  bool _isLoading = true;

  // Define the available charger types and charging speeds
  List<String> _chargerTypes = ['Type 1', 'Type 2', 'DC Fast Charging', ''];
  List<String> _chargingSpeeds = ['Slow', 'Fast', ''];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _fetchChargingStationData();
  }

  Future<void> _fetchChargingStationData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('charging_stations')
          .doc(widget.chargingStationId)
          .get();
      final chargingStationData = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _nameController.text = chargingStationData['name'];
        _addressController.text = chargingStationData['address'];
        _selectedChargerType = chargingStationData['chargerType'] ?? '';
        _selectedChargingSpeed = chargingStationData['chargingSpeed'] ?? '';
        _isLoading = false; // Data fetching completed
      });
    } catch (error) {
      // Handle error if data fetching fails
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to fetch charging station details.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _updateChargingStationDetails() async {
    try {
      // Save updated charging station details to Firestore
      await FirebaseFirestore.instance
          .collection('charging_stations')
          .doc(widget.chargingStationId)
          .update({
        'name': _nameController.text,
        'address': _addressController.text,
        'chargerType': _selectedChargerType,
        'chargingSpeed': _selectedChargingSpeed,
      });

      // Show a snackbar to indicate that changes are saved
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Charging station details updated.'),
      ));

      // Wait for a short duration to let the snackbar show up
      await Future.delayed(Duration(seconds: 1));

      // Fetch charging station data again to update the page with the new changes
      _fetchChargingStationData();
    } catch (error) {
      // Handle error if the update fails
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to update charging station details.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
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
          "Edit Charging Station Details",
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedChargerType,
              onChanged: (newValue) {
                setState(() {
                  _selectedChargerType = newValue!;
                });
              },
              items: _chargerTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Charger Type'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedChargingSpeed,
              onChanged: (newValue) {
                setState(() {
                  _selectedChargingSpeed = newValue!;
                });
              },
              items: _chargingSpeeds.map((speed) {
                return DropdownMenuItem<String>(
                  value: speed,
                  child: Text(speed),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Charging Speed'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color(0xff2d366f),
              ),
              onPressed: _updateChargingStationDetails,
              child: Text(
                  'Save Changes',
                style: SafeGoogleFont(
                  'Lato',
                  fontSize:  16,
                  fontWeight:  FontWeight.bold,
                  color:  Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

