class BlogsOnFilters {
  bool? success;
  int? message;
  List<BlogsOnFiltersData>? data;

  BlogsOnFilters({this.success, this.message, this.data});

  BlogsOnFilters.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <BlogsOnFiltersData>[];
      json['data'].forEach((v) {
        data!.add(new BlogsOnFiltersData.fromJson(v));
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

class BlogsOnFiltersData {
  String? id;
  String? title;
  String? content;
  String? image;
  String? categoryId;
  String? adminId;
  Null? type;
  int? views;
  String? createdAt;
  String? updatedAt;
  Category? category;
  Admin? admin;
  Count? cCount;

  BlogsOnFiltersData({
    this.id,
    this.title,
    this.content,
    this.image,
    this.categoryId,
    this.adminId,
    this.type,
    this.views,
    this.createdAt,
    this.updatedAt,
    this.category,
    this.admin,
    this.cCount,
  });

  BlogsOnFiltersData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    image = json['image'];
    categoryId = json['categoryId'];
    adminId = json['adminId'];
    type = json['type'];
    views = json['views'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    category = json['category'] != null ? new Category.fromJson(json['category']) : null;
    admin = json['admin'] != null ? new Admin.fromJson(json['admin']) : null;
    cCount = json['_count'] != null ? new Count.fromJson(json['_count']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['content'] = this.content;
    data['image'] = this.image;
    data['categoryId'] = this.categoryId;
    data['adminId'] = this.adminId;
    data['type'] = this.type;
    data['views'] = this.views;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.category != null) {
      data['category'] = this.category!.toJson();
    }
    if (this.admin != null) {
      data['admin'] = this.admin!.toJson();
    }
    if (this.cCount != null) {
      data['_count'] = this.cCount!.toJson();
    }
    return data;
  }
}

class Category {
  String? id;
  String? name;
  String? adminId;

  Category({this.id, this.name, this.adminId});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    adminId = json['adminId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['adminId'] = this.adminId;
    return data;
  }
}

class Admin {
  String? id;
  String? email;
  String? password;
  Null? name;
  String? deviceToken;
  Null? otp;
  String? userType;
  String? image;

  Admin({this.id, this.email, this.password, this.name, this.deviceToken, this.otp, this.userType, this.image});

  Admin.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    password = json['password'];
    name = json['name'];
    deviceToken = json['deviceToken'];
    otp = json['otp'];
    userType = json['userType'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['email'] = this.email;
    data['password'] = this.password;
    data['name'] = this.name;
    data['deviceToken'] = this.deviceToken;
    data['otp'] = this.otp;
    data['userType'] = this.userType;
    data['image'] = this.image;
    return data;
  }
}

class Count {
  int? likes;
  int? comments;

  Count({this.likes, this.comments});

  Count.fromJson(Map<String, dynamic> json) {
    likes = json['likes'];
    comments = json['comments'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['likes'] = this.likes;
    data['comments'] = this.comments;
    return data;
  }
}
