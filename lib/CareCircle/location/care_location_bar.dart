import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ollie/CareCircle/location/care_explore_screen.dart';
import 'package:ollie/CareCircle/location/care_location_controller.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/common/common.dart';

/// "Near you · Gulberg, Lahore · 10 km": where Care Circle's lists are centred.
/// Tapping it opens the explore map to pick another place or radius.
class CareLocationBar extends StatelessWidget {
  const CareLocationBar({super.key, required this.location});

  final CareLocationController location;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final unavailable =
          location.status.value == CareLocationStatus.unavailable &&
          location.location.value == null;
      final browsingElsewhere = location.isBrowsingElsewhere;

      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
        child: Material(
          color: unavailable
              ? const Color(0xFFFFEDE8)
              : browsingElsewhere
              ? const Color(0xFFFFE4A6)
              : const Color(0xFFF2ECE3),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Get.to(
              () => const CareExploreScreen(),
              transition: Transition.downToUp,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                children: [
                  Icon(
                    unavailable
                        ? Icons.location_off_outlined
                        : browsingElsewhere
                        ? Icons.travel_explore
                        : Icons.my_location,
                    size: 20,
                    color: Black,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      unavailable
                          ? location.errorMessage.value
                          : location.summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.darkerGrotesque(
                        fontSize: responsiveFontSize(18, min: 16, max: 21),
                        fontWeight: FontWeight.w700,
                        color: Black,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    unavailable ? 'Choose a place' : 'Change',
                    style: GoogleFonts.darkerGrotesque(
                      fontSize: responsiveFontSize(17, min: 15, max: 20),
                      fontWeight: FontWeight.w700,
                      color: buttonColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
