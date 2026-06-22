import 'package:ollie/Models/supplement_model.dart';

class UserModel {
  final bool success;
  final String message;
  final UserData? data;

  UserModel({required this.success, required this.message, this.data});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      if (data != null) 'data': data!.toJson(),
    };
  }
}

class UserData {
  final String? id;
  String? email;
  final String? password;
  String? phoneNumber;
  String? firstName;
  String? lastName;
  String? dateOfBirth;
  String? gender;
  final String? deviceType;
  final String? deviceToken;
  final bool? isCreatedProfile;
  final String? image;
  final String? city;
  final String? country;
  final String? states;
  final String? userType;
  final bool? notificationOnAndOff;
  final String? emergencyContactNumber;
  final bool? wantDailySupplement;
  final bool? wantDailyActivities;
  final String? createdAt;
  final String? updatedAt;
  final bool? showAds;
  final List<dynamic>? wallet;
  final List<dynamic>? connectPurchase;
  final List<dynamic>? userSubscription;
  final List<SupplementData>? userSupplements;
  final String? userToken;

  UserData({
    this.id,
    this.email,
    this.password,
    this.phoneNumber,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.gender,
    this.deviceType,
    this.deviceToken,
    this.isCreatedProfile,
    this.image,
    this.city,
    this.country,
    this.states,
    this.userType,
    this.notificationOnAndOff,
    this.emergencyContactNumber,
    this.wantDailySupplement,
    this.wantDailyActivities,
    this.createdAt,
    this.updatedAt,
    this.showAds,
    this.wallet,
    this.connectPurchase,
    this.userSubscription,
    this.userSupplements,
    this.userToken,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      email: json['email'],
      password: json['password'],
      phoneNumber: json['phoneNumber'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      deviceType: json['deviceType'],
      deviceToken: json['deviceToken'],
      isCreatedProfile: _readBool(
        json['isCreatedProfile'] ?? json['isProfileCreated'],
      ),
      image: json['image'],
      city: json['city'],
      country: json['country'],
      states: json['states'],
      userType: json['userType'],
      notificationOnAndOff: json['notificationOnAndOff'],
      emergencyContactNumber: json['emergencyContactNumber'],
      wantDailySupplement: json['wantDailySupplement'],
      wantDailyActivities: json['wantDailyActivities'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      showAds: json['showAds'],
      wallet: json['Wallet'],
      connectPurchase: json['ConnectPurchase'],
      userSubscription: json['UserSubscription'],
      userSupplements: json['userSupplements'] is List
          ? (json['userSupplements'] as List)
                .whereType<Map>()
                .map(
                  (item) => SupplementData.fromJson(
                    item.map((key, value) => MapEntry(key.toString(), value)),
                  ),
                )
                .toList()
          : null,
      userToken: json['userToken'],
    );
  }

  static bool? _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'deviceType': deviceType,
      'deviceToken': deviceToken,
      'isCreatedProfile': isCreatedProfile,
      'image': image,
      'city': city,
      'country': country,
      'states': states,
      'userType': userType,
      'notificationOnAndOff': notificationOnAndOff,
      'emergencyContactNumber': emergencyContactNumber,
      'wantDailySupplement': wantDailySupplement,
      'wantDailyActivities': wantDailyActivities,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'showAds': showAds,
      'Wallet': wallet,
      'ConnectPurchase': connectPurchase,
      'UserSubscription': userSubscription,
      'userSupplements': userSupplements
          ?.map(
            (item) => {
              'id': item.id,
              'name': item.name,
              'dosage': item.dosage,
              'reminderEnabled': item.reminderEnabled,
              'reminderTime': item.reminderTime,
            },
          )
          .toList(),
      'userToken': userToken,
    };
  }
}
