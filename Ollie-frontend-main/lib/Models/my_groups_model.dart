class MyGroupsModel {
  bool? success;
  String? message;
  List<MyGroupsData>? data;

  MyGroupsModel({this.success, this.message, this.data});

  MyGroupsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <MyGroupsData>[];
      json['data'].forEach((v) {
        data!.add(new MyGroupsData.fromJson(v));
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

class MyGroupsData {
  String? id;
  String? type;
  String? name;
  String? description;
  String? image;
  String? createdAt;
  String? updatedAt;
  LastMessage? lastMessage;
  int? memberCount;
  Participants? participants;

  MyGroupsData({
    this.id,
    this.type,
    this.name,
    this.description,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.lastMessage,
    this.memberCount,
    this.participants,
  });

  MyGroupsData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    lastMessage = json['lastMessage'] != null ? new LastMessage.fromJson(json['lastMessage']) : null;
    memberCount = json['memberCount'];
    participants = json['participants'] != null ? new Participants.fromJson(json['participants']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['name'] = this.name;
    data['description'] = this.description;
    data['image'] = this.image;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.lastMessage != null) {
      data['lastMessage'] = this.lastMessage!.toJson();
    }
    data['memberCount'] = this.memberCount;
    if (this.participants != null) {
      data['participants'] = this.participants!.toJson();
    }
    return data;
  }
}

class Participants {
  List<Users>? users;
  List<String?>? adminIds; // Updated to List<String?> instead of List<Null>

  Participants({this.users, this.adminIds});

  Participants.fromJson(Map<String, dynamic> json) {
    if (json['users'] != null) {
      users = <Users>[];
      json['users'].forEach((v) {
        users!.add(Users.fromJson(v));
      });
    }
    if (json['adminIds'] != null) {
      adminIds = <String?>[]; // Changed to List<String?> for nullable strings
      json['adminIds'].forEach((v) {
        adminIds!.add(v); // Just add the value directly
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.users != null) {
      data['users'] = this.users!.map((v) => v.toJson()).toList();
    }
    if (this.adminIds != null) {
      data['adminIds'] = this.adminIds;
    }
    return data;
  }
}

class Users {
  String? id;
  String? firstName;
  String? lastName;
  String? image;

  Users({this.id, this.firstName, this.lastName, this.image});

  Users.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['image'] = this.image;
    return data;
  }
}

class LastMessage {
  String? id;
  Null? content;
  String? attachmentUrl;
  String? attachmentType;
  String? chatRoomId;
  String? createdAt;
  String? senderId;
  Null? adminSenderId;
  Sender? sender;

  LastMessage({
    this.id,
    this.content,
    this.attachmentUrl,
    this.attachmentType,
    this.chatRoomId,
    this.createdAt,
    this.senderId,
    this.adminSenderId,
    this.sender,
  });

  LastMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    content = json['content'];
    attachmentUrl = json['attachmentUrl'];
    attachmentType = json['attachmentType'];
    chatRoomId = json['chatRoomId'];
    createdAt = json['createdAt'];
    senderId = json['senderId'];
    adminSenderId = json['adminSenderId'];
    sender = json['sender'] != null ? new Sender.fromJson(json['sender']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['content'] = this.content;
    data['attachmentUrl'] = this.attachmentUrl;
    data['attachmentType'] = this.attachmentType;
    data['chatRoomId'] = this.chatRoomId;
    data['createdAt'] = this.createdAt;
    data['senderId'] = this.senderId;
    data['adminSenderId'] = this.adminSenderId;
    if (this.sender != null) {
      data['sender'] = this.sender!.toJson();
    }
    return data;
  }
}

class Sender {
  String? id;
  String? firstName;
  String? lastName;
  Null? image;

  Sender({this.id, this.firstName, this.lastName, this.image});

  Sender.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['image'] = this.image;
    return data;
  }
}
