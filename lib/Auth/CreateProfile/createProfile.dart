import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:ollie/Auth/CreateProfile/create_profile_controller.dart';
import 'package:ollie/Auth/interests/wellcome_sreen.dart';
import 'package:ollie/CareCircle/assistance/tetris_game.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/Constants/constants.dart' as Colors;
import 'package:ollie/common/common.dart';
import 'package:ollie/common/filled_select_state.dart';

class CreateProfileScreen extends StatelessWidget {
  final CreateProfileController controller = Get.put(CreateProfileController());
  final _formKey = GlobalKey<FormState>();

  CreateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final baseFieldStyle = (textTheme.bodyLarge ?? const TextStyle()).copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 20.sp,
    );
    final dropdownValueStyle = baseFieldStyle.copyWith(color: Colors.Black);
    final dropdownHintStyle = baseFieldStyle.copyWith(color: const Color(0xFF6D6D6D));
    final dropdownErrorStyle = baseFieldStyle.copyWith(color: const Color(0xFFF44336));
    final labelFieldStyle = baseFieldStyle.copyWith(color: const Color(0xff0F1031));

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Theme(
          data: Theme.of(context).copyWith(textTheme: Theme.of(context).textTheme),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(color: BGcolor),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Image.asset("assets/images/Group 1000000919.png", fit: BoxFit.cover, width: double.infinity, height: 400.h),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        60.verticalSpace,
                        Row(
                          children: [
                            SizedBox(
                              width: 380.w,
                              child: Text(
                                "Create Profile",
                                style: TextStyle(color: HeadingColor, fontSize: 55.sp, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        30.verticalSpace,
                        CustomTextField(
                          controller: controller.firstNameController,
                          hintText: "Enter your First Name",
                          labelText: "First Name",

                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please enter your first name";
                            }
                            return null;
                          },
                        ),
                        20.verticalSpace,
                        CustomTextField(
                          controller: controller.lastNameController,
                          hintText: "Enter your Last Name",
                          labelText: "Last Name",
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please enter your last name";
                            }
                            return null;
                          },
                        ),
                        20.verticalSpace,
                        Obx(
                          () => DropdownButtonFormField2<String>(
                            isExpanded: true,
                            style: dropdownValueStyle,
                            decoration: customInputDecoration(
                              labelText: "",
                            ).copyWith(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              hintStyle: dropdownHintStyle,
                              errorStyle: dropdownErrorStyle,
                            ),
                            hint: Text(
                              'Select Gender',
                              style: dropdownHintStyle,
                              textAlign: TextAlign.left,
                            ),
                            value: controller.selectedGender.value.isEmpty ? null : controller.selectedGender.value,
                            items: ["Male", "Female", "Other"]
                                .map(
                                  (gender) => DropdownMenuItem<String>(
                                    value: gender,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(gender, style: dropdownValueStyle),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) => controller.selectedGender.value = value ?? '',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please select your gender";
                              }
                              return null;
                            },
                            dropdownStyleData: DropdownStyleData(
                              direction: DropdownDirection.textDirection,
                              elevation: 3,
                              maxHeight: 200,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: kprimaryColor),
                            ),
                          ),
                        ),
                        20.verticalSpace,
                        FormField<DateTime>(
                          validator: (_) {
                            if (controller.selectedDate.value == null) {
                              return "Please select your date of birth";
                            }
                            return null;
                          },
                          builder: (state) {
                            return Obx(() {
                              final selectedDate = controller.selectedDate.value;
                              final dateText = selectedDate == null
                                  ? "Select date of birth"
                                  : "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";

                              return InkWell(
                                onTap: () async {
                                  final pickedDate = await controller.pickDate(context);
                                  if (pickedDate != null) {
                                    state.didChange(pickedDate);
                                  }
                                },
                                borderRadius: BorderRadius.circular(50),
                                child: InputDecorator(
                                  decoration:
                                      customInputDecoration(
                                        hintText: "Select date of birth",

                                        labelText: "",
                                        suffixIcon: Icon(Icons.calendar_month, color: Colors.grey, size: 25.sp),
                                      ).copyWith(
                                        errorText: state.errorText,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                        hintStyle: dropdownHintStyle,
                                        errorStyle: dropdownErrorStyle,
                                      ),
                                  child: Text(
                                    dateText,
                                    style: selectedDate == null ? dropdownHintStyle : dropdownValueStyle,
                                  ),
                                ),
                              );
                            });
                          },
                        ),

                        20.verticalSpace,
                        IntlPhoneField(
                          dropdownTextStyle: dropdownValueStyle,

                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            errorStyle: dropdownErrorStyle,
                            labelText: "Phone Number",
                            labelStyle: labelFieldStyle,
                            hintText: "Enter your phone number",
                            filled: true,
                            hintStyle: labelFieldStyle,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.only(left: 30, bottom: 15, top: 15),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(50)),
                              borderSide: BorderSide(color: Color(0xff463C3380)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(50)),
                              borderSide: BorderSide(color: Color(0xff463C3380)),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(50)),
                              borderSide: BorderSide(color: Color(0xff463C3380)),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(50)),
                              borderSide: BorderSide(color: Color(0xff463C3380)),
                            ),
                          ),
                          initialCountryCode: 'CA',
                          validator: (phone) {
                            if (phone == null || phone.number.trim().isEmpty) {
                              return "Please enter your phone number";
                            }
                            return null;
                          },
                          onChanged: (phone) {
                            controller.phoneController.text = phone.completeNumber;
                          },
                          style: dropdownValueStyle,
                        ),

                        20.verticalSpace,
                        FormField<String>(
                          validator: (_) {
                            if (controller.countryValue.value.isEmpty) {
                              return "Please select your country";
                            }
                            if (controller.stateValue.value.isEmpty) {
                              return "Please select your state or province";
                            }
                            if (controller.cityValue.value.isEmpty) {
                              return "Please select your city";
                            }
                            return null;
                          },
                          builder: (state) {
                            const countryPlaceholder = "Select Country";
                            const statePlaceholder = "Select State/Province";
                            const cityPlaceholder = "Select City";

                            final decoration = customInputDecoration(
                              labelText: "",
                            ).copyWith(
                              contentPadding: const EdgeInsets.only(left: 30, bottom: 15, top: 15),
                              hintStyle: dropdownHintStyle,
                              errorStyle: dropdownErrorStyle,
                            );

                            void syncLocationField() {
                              final combinedValue = "${controller.countryValue.value}|${controller.stateValue.value}|${controller.cityValue.value}";
                              state.didChange(combinedValue);
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FilledSelectState(
                                  style: dropdownValueStyle,
                                  labelStyle: dropdownHintStyle,
                                  decoration: decoration,
                                  spacing: 20.0,
                                  selectedCountryLabel: countryPlaceholder,
                                  selectedStateLabel: statePlaceholder,
                                  selectedCityLabel: cityPlaceholder,
                                  onCountryChanged: (value) {
                                    controller.countryValue.value = value;
                                    controller.stateValue.value = "";
                                    controller.cityValue.value = "";
                                    syncLocationField();
                                  },
                                  onStateChanged: (value) {
                                    controller.stateValue.value = value;
                                    controller.cityValue.value = "";
                                    syncLocationField();
                                  },
                                  onCityChanged: (value) {
                                    controller.cityValue.value = value;
                                    syncLocationField();
                                  },
                                ),
                                if (state.hasError)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6, left: 12),
                                    child: Text(state.errorText ?? "", style: dropdownErrorStyle),
                                  ),
                              ],
                            );
                          },
                        ),
                        50.verticalSpace,
                        CustomButton(
                          text: "Continue",
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              Get.to(() => Well_Come_Screen(), transition: Transition.fadeIn);
                            }
                          },
                          width: 390.w,
                          height: 50.h,
                          color: buttonColor,
                          textColor: Colors.white,
                          fontSize: 18,
                        ),
                        80.verticalSpace,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
