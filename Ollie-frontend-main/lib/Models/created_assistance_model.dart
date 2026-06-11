class CreatedAssistanceModel {
  bool? success;
  String? message;
  List<CreatedAssistanceData>? data;

  CreatedAssistanceModel({this.success, this.message, this.data});

  CreatedAssistanceModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <CreatedAssistanceData>[];
      json['data'].forEach((v) {
        data!.add(CreatedAssistanceData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CreatedAssistanceData {
  String? id;
  String? scheduledAt;
  String? description;
  double? latitude;
  double? longitude;
  String? status;
  String? userId;
  User? user;
  List<VolunteerRequests>? volunteerRequests;

  CreatedAssistanceData({
    this.id,
    this.scheduledAt,
    this.description,
    this.latitude,
    this.longitude,
    this.status,
    this.userId,
    this.user,
    this.volunteerRequests,
  });

  CreatedAssistanceData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    scheduledAt = json['scheduledAt'];
    description = json['description'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    status = json['status'];
    userId = json['userId'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    if (json['volunteerRequests'] != null) {
      volunteerRequests = <VolunteerRequests>[];
      json['volunteerRequests'].forEach((v) {
        volunteerRequests!.add(VolunteerRequests.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['scheduledAt'] = scheduledAt;
    data['description'] = description;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['status'] = status;
    data['userId'] = userId;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (volunteerRequests != null) {
      data['volunteerRequests'] = volunteerRequests!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class User {
  String? id;
  String? email;
  String? password;
  String? phoneNumber;
  String? firstName;
  String? lastName;
  String? dateOfBirth;
  String? gender;
  String? deviceType;
  String? deviceToken;
  bool? isCreatedProfile;
  String? image;
  String? city;
  String? country;
  String? states;
  String? userType;
  bool? notificationOnAndOff;
  String? emergencyContactNumber;
  bool? wantDailySupplement;
  bool? wantDailyActivities;
  String? createdAt;
  String? updatedAt;
  bool? showAds;

  User({
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
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    password = json['password'];
    phoneNumber = json['phoneNumber'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    dateOfBirth = json['dateOfBirth'];
    gender = json['gender'];
    deviceType = json['deviceType'];
    deviceToken = json['deviceToken'];
    isCreatedProfile = json['isCreatedProfile'];
    image = json['image'];
    city = json['city'];
    country = json['country'];
    states = json['states'];
    userType = json['userType'];
    notificationOnAndOff = json['notificationOnAndOff'];
    emergencyContactNumber = json['emergencyContactNumber'];
    wantDailySupplement = json['wantDailySupplement'];
    wantDailyActivities = json['wantDailyActivities'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    showAds = json['showAds'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    data['password'] = password;
    data['phoneNumber'] = phoneNumber;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['dateOfBirth'] = dateOfBirth;
    data['gender'] = gender;
    data['deviceType'] = deviceType;
    data['deviceToken'] = deviceToken;
    data['isCreatedProfile'] = isCreatedProfile;
    data['image'] = image;
    data['city'] = city;
    data['country'] = country;
    data['states'] = states;
    data['userType'] = userType;
    data['notificationOnAndOff'] = notificationOnAndOff;
    data['emergencyContactNumber'] = emergencyContactNumber;
    data['wantDailySupplement'] = wantDailySupplement;
    data['wantDailyActivities'] = wantDailyActivities;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['showAds'] = showAds;
    return data;
  }
}

class VolunteerRequests {
  String? id;
  String? postId;
  String? volunteerId;
  String? status;
  String? createdAt;

  VolunteerRequests({this.id, this.postId, this.volunteerId, this.status, this.createdAt});

  VolunteerRequests.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    postId = json['postId'];
    volunteerId = json['volunteerId'];
    status = json['status'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['postId'] = postId;
    data['volunteerId'] = volunteerId;
    data['status'] = status;
    data['createdAt'] = createdAt;
    return data;
  }
}

// class CreatedAssistanceModel {
//   bool? success;
//   String? message;
//   List<CreatedAssistanceData>? data;

//   CreatedAssistanceModel({this.success, this.message, this.data});

//   CreatedAssistanceModel.fromJson(Map<String, dynamic> json) {
//     success = json['success'];
//     message = json['message'];
//     if (json['data'] != null) {
//       data = <CreatedAssistanceData>[];
//       json['data'].forEach((v) {
//         data!.add(new CreatedAssistanceData.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['success'] = this.success;
//     data['message'] = this.message;
//     if (this.data != null) {
//       data['data'] = this.data!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

// class CreatedAssistanceData {
//   String? id;
//   String? scheduledAt;
//   String? description;
//   double? latitude;
//   double? longitude;
//   String? status;
//   String? userId;
//   User? user;

//   CreatedAssistanceData({this.id, this.scheduledAt, this.description, this.latitude, this.longitude, this.status, this.userId, this.user});

//   CreatedAssistanceData.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     scheduledAt = json['scheduledAt'];
//     description = json['description'];
//     latitude = json['latitude'];
//     longitude = json['longitude'];
//     status = json['status'];
//     userId = json['userId'];
//     user = json['user'] != null ? new User.fromJson(json['user']) : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['scheduledAt'] = this.scheduledAt;
//     data['description'] = this.description;
//     data['latitude'] = this.latitude;
//     data['longitude'] = this.longitude;
//     data['status'] = this.status;
//     data['userId'] = this.userId;
//     if (this.user != null) {
//       data['user'] = this.user!.toJson();
//     }
//     return data;
//   }
// }

// class User {
//   String? id;
//   String? email;
//   String? password;
//   String? phoneNumber;
//   String? firstName;
//   String? lastName;
//   String? dateOfBirth;
//   String? gender;
//   String? deviceType;
//   String? deviceToken;
//   bool? isCreatedProfile;
//   String? image;
//   String? city;
//   String? country;
//   String? states;
//   String? userType;
//   bool? notificationOnAndOff;
//   String? emergencyContactNumber;
//   bool? wantDailySupplement;
//   bool? wantDailyActivities;
//   String? createdAt;
//   String? updatedAt;
//   bool? showAds;

//   User({
//     this.id,
//     this.email,
//     this.password,
//     this.phoneNumber,
//     this.firstName,
//     this.lastName,
//     this.dateOfBirth,
//     this.gender,
//     this.deviceType,
//     this.deviceToken,
//     this.isCreatedProfile,
//     this.image,
//     this.city,
//     this.country,
//     this.states,
//     this.userType,
//     this.notificationOnAndOff,
//     this.emergencyContactNumber,
//     this.wantDailySupplement,
//     this.wantDailyActivities,
//     this.createdAt,
//     this.updatedAt,
//     this.showAds,
//   });

//   User.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     email = json['email'];
//     password = json['password'];
//     phoneNumber = json['phoneNumber'];
//     firstName = json['firstName'];
//     lastName = json['lastName'];
//     dateOfBirth = json['dateOfBirth'];
//     gender = json['gender'];
//     deviceType = json['deviceType'];
//     deviceToken = json['deviceToken'];
//     isCreatedProfile = json['isCreatedProfile'];
//     image = json['image'];
//     city = json['city'];
//     country = json['country'];
//     states = json['states'];
//     userType = json['userType'];
//     notificationOnAndOff = json['notificationOnAndOff'];
//     emergencyContactNumber = json['emergencyContactNumber'];
//     wantDailySupplement = json['wantDailySupplement'];
//     wantDailyActivities = json['wantDailyActivities'];
//     createdAt = json['createdAt'];
//     updatedAt = json['updatedAt'];
//     showAds = json['showAds'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['email'] = this.email;
//     data['password'] = this.password;
//     data['phoneNumber'] = this.phoneNumber;
//     data['firstName'] = this.firstName;
//     data['lastName'] = this.lastName;
//     data['dateOfBirth'] = this.dateOfBirth;
//     data['gender'] = this.gender;
//     data['deviceType'] = this.deviceType;
//     data['deviceToken'] = this.deviceToken;
//     data['isCreatedProfile'] = this.isCreatedProfile;
//     data['image'] = this.image;
//     data['city'] = this.city;
//     data['country'] = this.country;
//     data['states'] = this.states;
//     data['userType'] = this.userType;
//     data['notificationOnAndOff'] = this.notificationOnAndOff;
//     data['emergencyContactNumber'] = this.emergencyContactNumber;
//     data['wantDailySupplement'] = this.wantDailySupplement;
//     data['wantDailyActivities'] = this.wantDailyActivities;
//     data['createdAt'] = this.createdAt;
//     data['updatedAt'] = this.updatedAt;
//     data['showAds'] = this.showAds;
//     return data;
//   }
// }
