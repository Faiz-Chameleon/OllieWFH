// ignore: file_names
// ignore_for_file: use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import 'package:ollie/Constants/Constants.dart';

double responsiveFontSize(double base, {double min = 16, double max = 24}) {
  return base.sp.clamp(min, max).toDouble();
}

void appSnackbar(
  String title,
  String message, {
  SnackPosition snackPosition = SnackPosition.TOP,
  Duration duration = const Duration(seconds: 3),
  Color? backgroundColor,
  Color? colorText,
}) {
  _showAppSnackbarWhenReady(
    title,
    message,
    snackPosition: snackPosition,
    duration: duration,
    backgroundColor: backgroundColor,
    colorText: colorText,
  );
}

OverlayState? _snackbarOverlay() => Get.key.currentState?.overlay;

bool _canShowSnackbar() => _snackbarOverlay() != null;

void _showAppSnackbarWhenReady(
  String title,
  String message, {
  required SnackPosition snackPosition,
  required Duration duration,
  Color? backgroundColor,
  Color? colorText,
  int attempt = 0,
}) {
  if (_canShowSnackbar()) {
    try {
      _showAppSnackbar(
        title,
        message,
        snackPosition: snackPosition,
        duration: duration,
        backgroundColor: backgroundColor,
        colorText: colorText,
      );
      return;
    } catch (error) {
      debugPrint('Snackbar overlay was not ready: $error');
    }
  }

  if (attempt >= 3) {
    debugPrint(
      'Snackbar skipped because no overlay is available: $title - $message',
    );
    return;
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    Future<void>.delayed(const Duration(milliseconds: 80), () {
      _showAppSnackbarWhenReady(
        title,
        message,
        snackPosition: snackPosition,
        duration: duration,
        backgroundColor: backgroundColor,
        colorText: colorText,
        attempt: attempt + 1,
      );
    });
  });
}

void _showAppSnackbar(
  String title,
  String message, {
  required SnackPosition snackPosition,
  required Duration duration,
  Color? backgroundColor,
  Color? colorText,
}) {
  final isError =
      title.toLowerCase().contains('error') ||
      title.toLowerCase().contains('failed');
  final isSuccess = title.toLowerCase().contains('success');
  final textColor = colorText ?? (isError ? Colors.white : HeadingColor);
  final effectiveBackgroundColor =
      backgroundColor ??
      (isError
          ? buttonColor
          : isSuccess
          ? const Color(0xFFF3E7C6)
          : BGcolor);

  final overlay = _snackbarOverlay();
  if (overlay == null) {
    throw StateError('No navigator overlay is available');
  }

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) {
      final mediaQuery = MediaQuery.maybeOf(context);
      final topPadding = mediaQuery?.padding.top ?? 0;
      final bottomPadding = mediaQuery?.padding.bottom ?? 0;
      final isTop = snackPosition == SnackPosition.TOP;

      return Positioned(
        top: isTop ? topPadding + 16.h : null,
        bottom: isTop ? null : bottomPadding + 24.h,
        left: 16.w,
        right: 16.w,
        child: Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.horizontal,
          onDismissed: (_) {
            if (entry.mounted) {
              entry.remove();
            }
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: effectiveBackgroundColor,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.darkerGrotesque(
                      fontSize: responsiveFontSize(20, min: 18, max: 24),
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    message,
                    style: GoogleFonts.darkerGrotesque(
                      fontSize: responsiveFontSize(18, min: 16, max: 22),
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  overlay.insert(entry);
  Future<void>.delayed(duration, () {
    if (entry.mounted) {
      entry.remove();
    }
  });
}

TextStyle prominentFieldTextStyle({
  Color color = const Color.fromRGBO(15, 16, 49, 1),
  FontWeight fontWeight = FontWeight.w600,
}) {
  return TextStyle(
    color: color,
    fontWeight: fontWeight,
    fontSize: responsiveFontSize(18, min: 16, max: 22),
  );
}

TextStyle prominentFieldHintStyle({
  Color color = Colors.grey,
  FontWeight fontWeight = FontWeight.w600,
}) {
  return TextStyle(
    color: color,
    fontWeight: fontWeight,
    fontSize: responsiveFontSize(18, min: 16, max: 22),
  );
}

TextStyle prominentFieldErrorStyle({
  Color color = const Color.fromRGBO(244, 67, 54, 1),
}) {
  return TextStyle(
    color: color,
    fontWeight: FontWeight.w600,
    fontSize: responsiveFontSize(16, min: 14, max: 20),
  );
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: const BorderSide(color: Color(0xff463C3380)),
    );

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: prominentFieldTextStyle(color: const Color.fromRGBO(0, 0, 0, 1)),
      decoration: InputDecoration(
        errorStyle: prominentFieldErrorStyle(color: Colors.red),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
        labelText: labelText,
        labelStyle: prominentFieldTextStyle(color: Colors.black),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon != null
            ? GestureDetector(onTap: onSuffixTap, child: Icon(suffixIcon))
            : null,
        enabledBorder: border,
        focusedBorder: border,
        errorBorder: border,
        focusedErrorBorder: border,
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // ✅ Changed from VoidCallback to VoidCallback?
  final double width;
  final double height;
  final Color color;
  final Color textColor;
  final double fontSize;
  final BorderRadiusGeometry borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity,
    this.height = 58,
    this.color = buttonColor,
    this.textColor = white,
    this.fontSize = 16,
    this.borderRadius = const BorderRadius.all(Radius.circular(50)),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          tapTargetSize: MaterialTapTargetSize.padded,
          backgroundColor: color,
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: Text(
          text,
          maxLines: 1,
          softWrap: false,
          textAlign: TextAlign.center,
          style: GoogleFonts.darkerGrotesque(
            color: textColor,
            fontSize: responsiveFontSize(fontSize, min: 20, max: 30),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

InputDecoration customInputDecoration({
  required String labelText,
  String? hintText,
  Widget? suffixIcon,
  Widget? prefixIcon,
}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(50),
    borderSide: const BorderSide(color: Color(0xff463c3380)),
  );

  return InputDecoration(
    errorStyle: prominentFieldErrorStyle(),
    filled: true,
    fillColor: Colors.white,
    hintText: hintText,
    hintStyle: prominentFieldHintStyle(),
    contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
    labelText: labelText,
    labelStyle: prominentFieldTextStyle(color: Colors.grey),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    floatingLabelBehavior: FloatingLabelBehavior.never,
    enabledBorder: border,
    focusedBorder: border,
    errorBorder: border,
    focusedErrorBorder: border,
  );
}
