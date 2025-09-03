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
        data!.add(new VolunterRequestsData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
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
    post = json['post'] != null ? new Post.fromJson(json['post']) : null;
    volunteer = json['volunteer'] != null ? new Volunteer.fromJson(json['volunteer']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['postId'] = this.postId;
    data['volunteerId'] = this.volunteerId;
    data['status'] = this.status;
    data['createdAt'] = this.createdAt;
    if (this.post != null) {
      data['post'] = this.post!.toJson();
    }
    if (this.volunteer != null) {
      data['volunteer'] = this.volunteer!.toJson();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['scheduledAt'] = this.scheduledAt;
    data['description'] = this.description;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['status'] = this.status;
    data['userId'] = this.userId;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['email'] = this.email;
    data['password'] = this.password;
    data['phoneNumber'] = this.phoneNumber;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['dateOfBirth'] = this.dateOfBirth;
    data['gender'] = this.gender;
    data['deviceType'] = this.deviceType;
    data['deviceToken'] = this.deviceToken;
    data['isCreatedProfile'] = this.isCreatedProfile;
    data['image'] = this.image;
    data['city'] = this.city;
    data['country'] = this.country;
    data['states'] = this.states;
    data['userType'] = this.userType;
    data['notificationOnAndOff'] = this.notificationOnAndOff;
    data['emergencyContactNumber'] = this.emergencyContactNumber;
    data['wantDailySupplement'] = this.wantDailySupplement;
    data['wantDailyActivities'] = this.wantDailyActivities;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['showAds'] = this.showAds;
    return data;
  }
}
