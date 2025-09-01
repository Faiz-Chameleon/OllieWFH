class YourPostModel {
  bool? success;
  String? message;
  List<YourPostModelData>? data;

  YourPostModel({this.success, this.message, this.data});

  YourPostModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <YourPostModelData>[];
      json['data'].forEach((v) {
        data!.add(new YourPostModelData.fromJson(v));
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

class YourPostModelData {
  String? id;
  String? title;
  String? content;
  String? categoryId;
  String? image;
  String? userId;
  int? views;
  String? createdAt;
  String? updatedAt;
  User? user;
  Count? cCount;

  YourPostModelData({
    this.id,
    this.title,
    this.content,
    this.categoryId,
    this.image,
    this.userId,
    this.views,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.cCount,
  });

  YourPostModelData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    categoryId = json['categoryId'];
    image = json['image'];
    userId = json['userId'];
    views = json['views'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    cCount = json['_count'] != null ? new Count.fromJson(json['_count']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['content'] = this.content;
    data['categoryId'] = this.categoryId;
    data['image'] = this.image;
    data['userId'] = this.userId;
    data['views'] = this.views;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.cCount != null) {
      data['_count'] = this.cCount!.toJson();
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

class Count {
  int? userpostlikes;
  int? userpostcomments;

  Count({this.userpostlikes, this.userpostcomments});

  Count.fromJson(Map<String, dynamic> json) {
    userpostlikes = json['userpostlikes'];
    userpostcomments = json['userpostcomments'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userpostlikes'] = this.userpostlikes;
    data['userpostcomments'] = this.userpostcomments;
    return data;
  }
}
