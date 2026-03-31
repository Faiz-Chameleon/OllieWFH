// ignore: file_names
// ignore_for_file: use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ollie/Constants/Constants.dart';

TextStyle prominentFieldTextStyle({Color color = const Color.fromRGBO(15, 16, 49, 1), FontWeight fontWeight = FontWeight.w600}) {
  return TextStyle(color: color, fontWeight: fontWeight, fontSize: 20.sp);
}

TextStyle prominentFieldHintStyle({Color color = Colors.grey, FontWeight fontWeight = FontWeight.w600}) {
  return TextStyle(color: color, fontWeight: fontWeight, fontSize: 20.sp);
}

TextStyle prominentFieldErrorStyle({Color color = const Color.fromRGBO(244, 67, 54, 1)}) {
  return TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 20.sp);
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
        contentPadding: const EdgeInsets.only(left: 30, bottom: 15, top: 15),
        labelText: labelText,
        labelStyle: prominentFieldTextStyle(color: Colors.black),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon != null ? GestureDetector(onTap: onSuffixTap, child: Icon(suffixIcon)) : null,
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
    this.height = 50,
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
          backgroundColor: color,
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: Text(
          text,
          style: GoogleFonts.darkerGrotesque(color: textColor, fontSize: fontSize, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

InputDecoration customInputDecoration({required String labelText, String? hintText, Widget? suffixIcon, Widget? prefixIcon}) {
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
    contentPadding: const EdgeInsets.only(left: 30, bottom: 15, top: 15),
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
