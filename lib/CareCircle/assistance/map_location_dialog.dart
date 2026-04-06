// 📁 map_location_dialog.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'assistance_controller.dart';

const String darkMapStyle = '''[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#212121"}]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#212121"}]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [{"color": "#757575"}]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [{"color": "#2c2c2c"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#383838"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#000000"}]
  }
]''';

class MapLocationDialog extends StatefulWidget {
  const MapLocationDialog({super.key});

  @override
  State<MapLocationDialog> createState() => _MapLocationDialogState();
}

class _MapLocationDialogState extends State<MapLocationDialog> {
  final Assistance_Controller controller = Get.find();
  GoogleMapController? mapController;
  bool canUseDeviceLocation = false;

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controllerInstance) {
    mapController = controllerInstance;
    controllerInstance.setMapStyle(darkMapStyle);
  }

  Future<void> _getCurrentLocation() async {
    try {
      final granted = await controller.ensureLocationPermission();
      if (!mounted || !granted) {
        setState(() {
          canUseDeviceLocation = false;
        });
        return;
      }

      setState(() {
        canUseDeviceLocation = true;
      });

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);
      await controller.setLocationFromLatLng(currentLatLng);

      mapController?.moveCamera(CameraUpdate.newLatLng(currentLatLng));
    } catch (e) {
      Get.snackbar("Error", "Failed to get current location: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: double.infinity,
        height: 400,
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(target: controller.selectedLatLng.value ?? const LatLng(37.7749, -122.4194), zoom: 14),
              myLocationEnabled: canUseDeviceLocation,
              myLocationButtonEnabled: canUseDeviceLocation,
              onTap: (LatLng point) async {
                await controller.setLocationFromLatLng(point);
                Get.back();
              },
              markers: controller.selectedLatLng.value != null
                  ? {Marker(markerId: const MarkerId("selected"), position: controller.selectedLatLng.value!)}
                  : {},
            ),

            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.close, color: Colors.black),
                ),
              ),
            ),
            if (!canUseDeviceLocation)
              Positioned(
                left: 12,
                right: 56,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: const Text(
                    "Location permission is off. You can still tap anywhere on the map to choose a place.",
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
