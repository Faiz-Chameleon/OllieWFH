// ignore: duplicate_ignore
// ignore: file_names, duplicate_ignore
// ignore: file_names, duplicate_ignore
// ignore: file_names, duplicate_ignore
// ignore: file_names
// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapPreview extends StatelessWidget {
  const GoogleMapPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.h,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: const GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(37.4219999, -122.0840575),
            zoom: 14,
          ),
          markers: <Marker>{},
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          zoomGesturesEnabled: false,
          scrollGesturesEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          liteModeEnabled: true, // ✅ Enables preview mode and prevents crashes
        ),
      ),
    );
  }
}
