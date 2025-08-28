// ignore_for_file: unnecessary_import

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ollie/Constants/constants.dart';

void showStyledCreditDialog({
  required BuildContext context,
  String title = "Use Credits?",
  String message = "Sending this request will deduct 1 credit from your balance. Do you want to continue?",
  String continueText = "Continue",
  String cancelText = "Cancel",
  VoidCallback? onContinue,
  VoidCallback? onCancel,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: const Color(0xFFFDF3DD), // Light beige background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E2A3B), // Dark navy heading
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF5D6670), // Muted text
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (onContinue != null) onContinue();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  continueText,
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (onCancel != null) onCancel();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF3F362E)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  cancelText,
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500, color: Color(0xFF3F362E)),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class TooltipShapeBorder extends ShapeBorder {
  final double arrowWidth;
  final double arrowHeight;
  final double borderRadius;

  const TooltipShapeBorder({this.arrowWidth = 12.0, this.arrowHeight = 8.0, this.borderRadius = 10.0});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path();
    final centerX = rect.center.dx;

    // Rounded corners
    path.moveTo(rect.left + borderRadius, rect.top);
    path.lineTo(centerX - (arrowWidth / 2), rect.top);
    path.lineTo(centerX, rect.top - arrowHeight); // Notch tip
    path.lineTo(centerX + (arrowWidth / 2), rect.top);
    path.lineTo(rect.right - borderRadius, rect.top);
    path.arcToPoint(Offset(rect.right, rect.top + borderRadius), radius: Radius.circular(borderRadius));
    path.lineTo(rect.right, rect.bottom - borderRadius);
    path.arcToPoint(Offset(rect.right - borderRadius, rect.bottom), radius: Radius.circular(borderRadius));
    path.lineTo(rect.left + borderRadius, rect.bottom);
    path.arcToPoint(Offset(rect.left, rect.bottom - borderRadius), radius: Radius.circular(borderRadius));
    path.lineTo(rect.left, rect.top + borderRadius);
    path.arcToPoint(Offset(rect.left + borderRadius, rect.top), radius: Radius.circular(borderRadius));
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();
}
