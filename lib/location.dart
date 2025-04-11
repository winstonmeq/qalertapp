import 'package:another_telephony/telephony.dart';
import 'package:awesomenotification/postonline.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart'; // Add this import

class LocationPage extends StatefulWidget {


  final String emergency;
  final String latitude;
  final String longitude;
  final String purok;
  final String name;
  final String phone;
  final String barangay;
  final String position;
  final String munName;
  final String munId;
  final String provId;
  final String photoURL;

  LocationPage({
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
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  late GoogleMapController mapController;
  final MarkerId markerId = const MarkerId('location'); // Unique ID for the marker
  bool isInfoWindowVisible = true; // To toggle the custom InfoWindow

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    // Move camera to the provided coordinates
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(double.parse(widget.latitude), double.parse(widget.longitude)),
        18.0,
      ),
    );
  }

  // Function to share location
  void _shareLocation() {
    String locationDetails =
        'Emergency: ${widget.emergency}\n'
        'Name: ${widget.name}\n'
        'Phone: ${widget.phone}\n'
        'Barangay: ${widget.barangay}\n'
        'Position: ${widget.position}\n'
        'Coordinates: https://maps.google.com/?q=${widget.latitude},${widget.longitude}';
    //'Coordinates: https://www.openstreetmap.org/?mlat=${widget.latitude}&mlon=${widget.longitude}&zoom=18';

    Share.share(locationDetails); // Share the location details
  }

  void _call(String address) {
    final telephony = Telephony.instance;
    telephony.openDialer(address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Location',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red, // Use a strong color for emergencies
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: _shareLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 36.0),
              ),
              icon: const Icon(Icons.share, color: Colors.white),
              label: const Text(
                'Share',
                style: TextStyle(color: Colors.white, fontSize: 14.0),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(double.parse(widget.latitude), double.parse(widget.longitude)),
              zoom: 18.0,
            ),
            mapType: MapType.hybrid, // Use satellite imagery
            markers: {
              Marker(
                markerId: markerId,
                position: LatLng(double.parse(widget.latitude), double.parse(widget.longitude)),
                onTap: () {
                  setState(() {
                    isInfoWindowVisible = !isInfoWindowVisible; // Toggle visibility
                  });
                },
              ),
            },
          ),

          // Custom InfoWindow Overlay
          if (isInfoWindowVisible)
            Positioned(
              top: 40, // Adjust position as needed
              left: 20,
              right: 20,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.emergency,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Name: ${widget.name}',
                        style: const TextStyle(fontSize: 12),
                      ),

                      const SizedBox(height: 4),
                      Text(
                        'Purok: ${widget.purok}',
                        style: const TextStyle(fontSize: 12),
                      ),

                      const SizedBox(height: 4),
                      Text(
                        'Barangay: ${widget.barangay}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Position: ${widget.position}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Coordinates: ${widget.latitude}, ${widget.longitude}',
                        style: const TextStyle(fontSize: 12),
                      ),

                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                _call(widget.phone);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              ),
              icon: const Icon(Icons.call, color: Colors.white),
              label: const Text(
                'Call',
                style: TextStyle(color: Colors.white, fontSize: 14.0),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PostOnline(
                      emergency: widget.emergency,
                      latitude: widget.latitude,
                      longitude: widget.longitude,
                      name: widget.name,
                      phone: widget.phone,
                      purok: widget.purok,
                      barangay: widget.barangay,
                      position: widget.position,
                      munId: widget.munId,
                      munName: widget.munName,
                      photoURL: widget.photoURL,
                      provId: widget.provId,
                    ),
                  ),
                );

              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 46.0),
              ),
              icon: const Icon(Icons.ads_click_rounded, color: Colors.white),
              label: const Text(
                'Posts',
                style: TextStyle(color: Colors.white, fontSize: 14.0),
              ),
            ),



          ],
        ),
      ),
    );
  }
}