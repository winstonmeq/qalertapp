import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PostOnline extends StatefulWidget {
  final String emergency;
  final String latitude;
  final String longitude;
  final String purok;
  final String name;
  final String phone;
  final String barangay;
  final String position;
  final String munId;
  final String munName;
  final String provId;
  final String photoURL;

  PostOnline({
    required this.emergency,
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.phone,
    required this.purok,
    required this.barangay,
    required this.position,
    required this.munName,
    required this.munId,
    required this.provId,
    required this.photoURL
  });

  @override
  _PostOnlineState createState() => _PostOnlineState();
}

class _PostOnlineState extends State<PostOnline> {
  late TextEditingController _emergencyController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _purokController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _barangayController;
  late TextEditingController _positionController;
  late TextEditingController _situationController;
  late TextEditingController _munIdController;
  late TextEditingController _munNameController;
  late TextEditingController _provIdController;

  bool isloading = false;

  @override
  void initState() {
    super.initState();
    _emergencyController = TextEditingController(text: widget.emergency);
    _latitudeController = TextEditingController(text: widget.latitude);
    _longitudeController = TextEditingController(text: widget.longitude);
    _purokController = TextEditingController(text: widget.purok);
    _nameController = TextEditingController(text: widget.name);
    _phoneController = TextEditingController(text: widget.phone);
    _barangayController = TextEditingController(text: widget.barangay);
    _positionController = TextEditingController(text: widget.position);
    _situationController = TextEditingController(text: '');
    _munIdController = TextEditingController(text: widget.munId);
    _munNameController = TextEditingController(text: widget.munName);
    _provIdController = TextEditingController(text: widget.provId);
  }

  @override
  void dispose() {
    _emergencyController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _purokController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _barangayController.dispose();
    _positionController.dispose();
    _situationController.dispose();
    super.dispose();
  }

  Future<void> send2LocationDataToAPI(
      emergency, lat, long, name, purok, barangay, mobile, position, situation, munName, munId, provId, photoURL) async {
    final Map<String, dynamic> requestBody = {
      "emergency": emergency,
      "lat": lat,
      "long": long,
      "name": name,
      "purok": purok,
      "barangay": barangay,
      "munName": munName,
      "position": position,
      "mobile": mobile,
      "munId": munId,
      "provId": provId,
      "situation": situation,
      "photoURL":photoURL

    };

    setState(() {
      isloading = true;
    });

    final response = await http.post(
      Uri.parse(
          'https://qalert.uniall.tk/api/postnotify?token=mySecretAlertifyToken2025'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    setState(() {
      isloading = false; // Stop loading after response
    });

    if (response.statusCode == 201) {
      print('Successfully saved emergency in background mode');
      _showSuccessDialog('Thank you');
    } else {
      print(response.body);
      _showSuccessDialog('Failed to submit: ${response.statusCode}');
    }
  }

  void _showSuccessDialog(String content) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Success'),
        content: Text(content),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close the dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Posts Online',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isloading
          ? const Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red)),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _emergencyController,
              decoration: InputDecoration(
                labelText: 'Emergency',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _purokController,
              decoration: InputDecoration(
                labelText: 'Purok',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _barangayController,
              decoration: InputDecoration(
                labelText: 'Barangay',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _positionController,
              decoration: InputDecoration(
                labelText: 'Position',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _situationController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
                labelStyle: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              maxLines: 4,
              minLines: 4,
              keyboardType: TextInputType.multiline,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                send2LocationDataToAPI(
                  _emergencyController.text,
                  _latitudeController.text,
                  _longitudeController.text,
                  _nameController.text,
                  _purokController.text,
                  _barangayController.text,
                  _phoneController.text,
                  _positionController.text,
                  _situationController.text,
                   widget.munName,
                    widget.munId,
                   widget.provId,
                    widget.photoURL
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 26.0),
              ),
              icon: const Icon(Icons.post_add, color: Colors.white),
              label: const Text(
                'Submit',
                style: TextStyle(color: Colors.white, fontSize: 14.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}