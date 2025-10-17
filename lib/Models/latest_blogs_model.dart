class LatestBlogs {
  bool? success;
  String? message;
  LatestBlogsDetails? data;

  LatestBlogs({this.success, this.message, this.data});

  LatestBlogs.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? new LatestBlogsDetails.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class LatestBlogsDetails {
  List<Blogs>? blogs;
  int? totalCount;

  LatestBlogsDetails({this.blogs, this.totalCount});

  LatestBlogsDetails.fromJson(Map<String, dynamic> json) {
    if (json['blogs'] != null) {
      blogs = <Blogs>[];
      json['blogs'].forEach((v) {
        blogs!.add(new Blogs.fromJson(v));
      });
    }
    totalCount = json['totalCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.blogs != null) {
      data['blogs'] = this.blogs!.map((v) => v.toJson()).toList();
    }
    data['totalCount'] = this.totalCount;
    return data;
  }
}

class Blogs {
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
  Count? cCount;

  Blogs({
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
    this.cCount,
  });

  Blogs.fromJson(Map<String, dynamic> json) {
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
    category = json['category'] != null
        ? new Category.fromJson(json['category'])
        : null;
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
