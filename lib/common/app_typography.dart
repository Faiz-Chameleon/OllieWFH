import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFontSizes {
  const AppFontSizes._();

  static const double caption = 12;
  static const double small = 14;
  static const double body = 16;
  static const double bodyLarge = 18;
  static const double title = 20;
  static const double titleLarge = 24;
  static const double heading = 28;
  static const double display = 34;
}

double responsiveFontSize(double base, {double? min, double? max}) {
  final lowerBound = min ?? (base - 2).clamp(10, base).toDouble();
  final upperBound = max ?? (base + 2).clamp(base, 40).toDouble();
  return base.sp.clamp(lowerBound, upperBound).toDouble();
}

TextStyle appTextStyle({
  double size = AppFontSizes.body,
  Color? color,
  FontWeight fontWeight = FontWeight.w400,
  double? height,
}) {
  return GoogleFonts.darkerGrotesque(
    fontSize: responsiveFontSize(size),
    color: color,
    fontWeight: fontWeight,
    height: height,
  );
}
