import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ollie/common/app_typography.dart';

// Color(0xffFFE1A4)
// ignore: constant_identifier_names
const Color BackgroundColor = Color(0xffFFF4E2);
const Color kprimaryColor = Color(0xffFFDF94);
const Color ksecondaryColor = Color(0xffFFC866);
const Color txtColor = Color(0xFF1D2B45);
const Color grey = Color(0xff1D2B45);
const Color orange = Color(0xffF3BF6D);
const Color white = Colors.white;
// ignore: constant_identifier_names
const Color Black = Colors.black;
const Color buttonColor = Color(0xff463C33);
const Color cardbg = Color(0xFFF4EAD5);

// ignore: constant_identifier_names
const Color BGcolor = Color(0xffFFF4E2);

// ignore: constant_identifier_names
const Color HeadingColor = Color(0xff1E1818);
const bprimaryColor = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xff2A7EE0), Color(0xff3FC1F6)]);

TextStyle mediumTextStyle32 = appTextStyle(size: 32, color: txtColor, fontWeight: FontWeight.w500);
TextStyle mediumTextStyle24 = appTextStyle(size: AppFontSizes.titleLarge, color: txtColor, fontWeight: FontWeight.w500);
TextStyle mediumTextStyle16 = appTextStyle(size: AppFontSizes.body, color: txtColor, fontWeight: FontWeight.w500);
TextStyle mediumTextStyle18 = appTextStyle(size: AppFontSizes.bodyLarge, color: txtColor, fontWeight: FontWeight.w500);

TextStyle regularTextStyle16 = appTextStyle(size: AppFontSizes.body, color: txtColor);

TextStyle regularTextStyle18 = appTextStyle(size: AppFontSizes.bodyLarge, color: txtColor);
TextStyle regularTextStyle12 = appTextStyle(size: AppFontSizes.caption, color: txtColor);

TextStyle regularTextStyle14 = appTextStyle(size: AppFontSizes.small, color: txtColor);
TextStyle lightTextStyle14 = appTextStyle(size: AppFontSizes.small, color: txtColor, fontWeight: FontWeight.w300);
TextStyle lightTextStyle12 = appTextStyle(size: AppFontSizes.caption, color: txtColor, fontWeight: FontWeight.w300);
var horizontal20Padding = EdgeInsets.symmetric(horizontal: 20);
var horizontal40Padding = EdgeInsets.symmetric(horizontal: 40);

TextTheme appTextTheme() {
  return GoogleFonts.darkerGrotesqueTextTheme().copyWith(
    displayLarge: appTextStyle(size: AppFontSizes.display, color: HeadingColor, fontWeight: FontWeight.w700),
    displayMedium: appTextStyle(size: AppFontSizes.heading, color: HeadingColor, fontWeight: FontWeight.w700),
    headlineLarge: appTextStyle(size: AppFontSizes.heading, color: HeadingColor, fontWeight: FontWeight.w700),
    headlineMedium: appTextStyle(size: AppFontSizes.titleLarge, color: HeadingColor, fontWeight: FontWeight.w700),
    titleLarge: appTextStyle(size: AppFontSizes.titleLarge, color: HeadingColor, fontWeight: FontWeight.w700),
    titleMedium: appTextStyle(size: AppFontSizes.title, color: HeadingColor, fontWeight: FontWeight.w600),
    titleSmall: appTextStyle(size: AppFontSizes.bodyLarge, color: HeadingColor, fontWeight: FontWeight.w600),
    bodyLarge: appTextStyle(size: AppFontSizes.bodyLarge, color: txtColor),
    bodyMedium: appTextStyle(size: AppFontSizes.body, color: txtColor),
    bodySmall: appTextStyle(size: AppFontSizes.small, color: txtColor),
    labelLarge: appTextStyle(size: AppFontSizes.bodyLarge, color: txtColor, fontWeight: FontWeight.w600),
    labelMedium: appTextStyle(size: AppFontSizes.body, color: txtColor, fontWeight: FontWeight.w600),
    labelSmall: appTextStyle(size: AppFontSizes.caption, color: txtColor, fontWeight: FontWeight.w600),
  );
}
