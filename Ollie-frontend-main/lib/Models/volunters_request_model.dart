class GetVolunteersRequestModel {
  bool? success;
  String? message;
  List<VolunterRequestsData>? data;

  GetVolunteersRequestModel({this.success, this.message, this.data});

  GetVolunteersRequestModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <VolunterRequestsData>[];
      json['data'].forEach((v) {
        data!.add(VolunterRequestsData.fromJson(v));
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

class VolunterRequestsData {
  String? id;
  String? postId;
  String? volunteerId;
  String? status;
  String? createdAt;
  Post? post;
  Volunteer? volunteer;

  VolunterRequestsData({this.id, this.postId, this.volunteerId, this.status, this.createdAt, this.post, this.volunteer});

  VolunterRequestsData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    postId = json['postId'];
    volunteerId = json['volunteerId'];
    status = json['status'];
    createdAt = json['createdAt'];
    post = json['post'] != null ? Post.fromJson(json['post']) : null;
    volunteer = json['volunteer'] != null ? Volunteer.fromJson(json['volunteer']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['postId'] = postId;
    data['volunteerId'] = volunteerId;
    data['status'] = status;
    data['createdAt'] = createdAt;
    if (post != null) {
      data['post'] = post!.toJson();
    }
    if (volunteer != null) {
      data['volunteer'] = volunteer!.toJson();
    }
    return data;
  }
}

class Post {
  String? id;
  String? scheduledAt;
  String? description;
  double? latitude;
  double? longitude;
  String? status;
  String? userId;

  Post({this.id, this.scheduledAt, this.description, this.latitude, this.longitude, this.status, this.userId});

  Post.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    scheduledAt = json['scheduledAt'];
    description = json['description'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    status = json['status'];
    userId = json['userId'];
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
    return data;
  }
}

class Volunteer {
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

  Volunteer({
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

  Volunteer.fromJson(Map<String, dynamic> json) {
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
