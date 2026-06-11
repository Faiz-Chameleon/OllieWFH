class OthersCreatedAssistanceModel {
  bool? success;
  String? message;
  List<OthersCreatedAssistance>? data;

  OthersCreatedAssistanceModel({this.success, this.message, this.data});

  OthersCreatedAssistanceModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <OthersCreatedAssistance>[];
      json['data'].forEach((v) {
        data!.add(OthersCreatedAssistance.fromJson(v));
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

class OthersCreatedAssistance {
  String? id;
  String? scheduledAt;
  String? description;
  double? latitude;
  double? longitude;
  String? status;
  String? userId;
  User? user;
  List<Categories>? categories;
  List<VolunteerRequests>? volunteerRequests;

  OthersCreatedAssistance({
    this.id,
    this.scheduledAt,
    this.description,
    this.latitude,
    this.longitude,
    this.status,
    this.userId,
    this.user,
    this.categories,
    this.volunteerRequests,
  });

  OthersCreatedAssistance.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    scheduledAt = json['scheduledAt'];
    description = json['description'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    status = json['status'];
    userId = json['userId'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(Categories.fromJson(v));
      });
    }
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
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
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

class Categories {
  String? id;
  String? name;
  String? adminId;

  Categories({this.id, this.name, this.adminId});

  Categories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    adminId = json['adminId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['adminId'] = adminId;
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

// class OthersCreatedAssistanceModel {
//   bool? success;
//   String? message;
//   List<OthersCreatedAssistance>? data;

//   OthersCreatedAssistanceModel({this.success, this.message, this.data});

//   OthersCreatedAssistanceModel.fromJson(Map<String, dynamic> json) {
//     success = json['success'];
//     message = json['message'];
//     if (json['data'] != null) {
//       data = <OthersCreatedAssistance>[];
//       json['data'].forEach((v) {
//         data!.add(new OthersCreatedAssistance.fromJson(v));
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

// class OthersCreatedAssistance {
//   String? id;
//   String? scheduledAt;
//   String? description;
//   double? latitude;
//   double? longitude;
//   String? status;
//   String? userId;
//   User? user;
//   List<Categories>? categories;
//   List<VolunteerRequest>? volunters;

//   OthersCreatedAssistance({
//     this.id,
//     this.scheduledAt,
//     this.description,
//     this.latitude,
//     this.longitude,
//     this.status,
//     this.userId,
//     this.user,
//     this.categories,
//   });

//   OthersCreatedAssistance.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     scheduledAt = json['scheduledAt'];
//     description = json['description'];
//     latitude = json['latitude'];
//     longitude = json['longitude'];
//     status = json['status'];
//     userId = json['userId'];
//     user = json['user'] != null ? new User.fromJson(json['user']) : null;
//     if (json['categories'] != null) {
//       categories = <Categories>[];
//       json['categories'].forEach((v) {
//         categories!.add(new Categories.fromJson(v));
//       });
//     }
//     if (json['volunters'] != null) {
//       volunters = <VolunteerRequest>[];
//       json['volunters'].forEach((v) {
//         volunters!.add(VolunteerRequest.fromJson(v));
//       });
//     }
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
//     if (this.categories != null) {
//       data['categories'] = this.categories!.map((v) => v.toJson()).toList();
//     }
//     if (volunters != null) {
//       data['volunters'] = volunters!.map((v) => v.toJson()).toList();
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

// class Categories {
//   String? id;
//   String? name;
//   String? adminId;

//   Categories({this.id, this.name, this.adminId});

//   Categories.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     adminId = json['adminId'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['name'] = this.name;
//     data['adminId'] = this.adminId;
//     return data;
//   }
// }

// class VolunteerRequest {
//   final String id;
//   final String postId;
//   final String volunteerId;
//   final String status;
//   final DateTime createdAt;

//   VolunteerRequest({required this.id, required this.postId, required this.volunteerId, required this.status, required this.createdAt});

//   // Factory constructor to create a VolunteerRequest from JSON
//   factory VolunteerRequest.fromJson(Map<String, dynamic> json) {
//     return VolunteerRequest(
//       id: json['id'] as String,
//       postId: json['postId'] as String,
//       volunteerId: json['volunteerId'] as String,
//       status: json['status'] as String,
//       createdAt: DateTime.parse(json['createdAt'] as String),
//     );
//   }

//   // Convert VolunteerRequest object to JSON
//   Map<String, dynamic> toJson() {
//     return {'id': id, 'postId': postId, 'volunteerId': volunteerId, 'status': status, 'createdAt': createdAt.toIso8601String()};
//   }
// }
