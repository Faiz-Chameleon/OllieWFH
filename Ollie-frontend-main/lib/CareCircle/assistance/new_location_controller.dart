import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapController extends GetxController {
  var currentPosition = Rx<LatLng?>(null); // User's current location
  var selectedPosition = Rx<LatLng?>(null); // The position selected on the map
  var markers = Set<Marker>().obs; // Markers to be displayed on the map

  // Fetch current location of the user
  Future<void> fetchCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Handle error if location services are not enabled
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle error if permission is denied
        throw Exception('Location permission denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      currentPosition.value = LatLng(position.latitude, position.longitude);
    } catch (e) {
      // Catch any errors that occur during location fetching
      print("Error fetching location: $e");
      Get.snackbar("Error", "Failed to fetch location: $e");
    }
  }

  // Add a marker to the selected position
  void addMarker(LatLng position) {
    selectedPosition.value = position;
    markers.add(
      Marker(
        markerId: MarkerId('selected'),
        position: position,
        infoWindow: InfoWindow(title: "Selected Location"),
      ),
    );
  }

  @override
  void onInit() {
    super.onInit();
    fetchCurrentLocation(); // Fetch the user's location on initialization
  }
}
