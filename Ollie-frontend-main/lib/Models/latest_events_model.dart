class LatesEventModel {
  bool? success;
  String? message;
  LatestEventsData? data;

  LatesEventModel({this.success, this.message, this.data});

  LatesEventModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? LatestEventsData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['eventName'] = eventName;
    data['eventDescription'] = eventDescription;
    data['eventDateAndTime'] = eventDateAndTime;
    data['eventAddress'] = eventAddress;
    data['eventStates'] = eventStates;
    data['eventCity'] = eventCity;
    data['eventCountry'] = eventCountry;
    data['eventParticipant'] = eventParticipant;
    data['image'] = image;
    data['createdById'] = createdById;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['isMark'] = isMark;
    return data;
  }
}
