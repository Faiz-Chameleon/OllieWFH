class LatesEventModel {
  bool? success;
  String? message;
  LatestEventsData? data;

  LatesEventModel({this.success, this.message, this.data});

  LatesEventModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? new LatestEventsData.fromJson(json['data'])
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

class LatestEventsData {
  String? id;
  String? eventName;
  String? eventDescription;
  String? eventDateAndTime;
  String? eventAddress;
  String? eventStates;
  String? eventCity;
  String? eventCountry;
  int? eventParticipant;
  String? image;
  String? createdById;
  String? createdAt;
  String? updatedAt;
  bool? isMark;

  LatestEventsData({
    this.id,
    this.eventName,
    this.eventDescription,
    this.eventDateAndTime,
    this.eventAddress,
    this.eventStates,
    this.eventCity,
    this.eventCountry,
    this.eventParticipant,
    this.image,
    this.createdById,
    this.createdAt,
    this.updatedAt,
    this.isMark,
  });

  LatestEventsData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    eventName = json['eventName'];
    eventDescription = json['eventDescription'];
    eventDateAndTime = json['eventDateAndTime'];
    eventAddress = json['eventAddress'];
    eventStates = json['eventStates'];
    eventCity = json['eventCity'];
    eventCountry = json['eventCountry'];
    eventParticipant = json['eventParticipant'];
    image = json['image'];
    createdById = json['createdById'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    isMark = json['isMark'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['eventName'] = this.eventName;
    data['eventDescription'] = this.eventDescription;
    data['eventDateAndTime'] = this.eventDateAndTime;
    data['eventAddress'] = this.eventAddress;
    data['eventStates'] = this.eventStates;
    data['eventCity'] = this.eventCity;
    data['eventCountry'] = this.eventCountry;
    data['eventParticipant'] = this.eventParticipant;
    data['image'] = this.image;
    data['createdById'] = this.createdById;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['isMark'] = this.isMark;
    return data;
  }
}
